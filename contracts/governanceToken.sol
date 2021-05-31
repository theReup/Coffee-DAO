pragma solidity ^0.5.0;


import "./SafeMath.sol";
import "./Members.sol";

contract governanceToken {

    using SafeMath for uint256;

    event mint(uint indexed amount, address payable indexed owner);
    event burn(uint indexed amount, address payable indexed owner);
    event transfering(address indexed sender, address indexed recipient, uint amount);
    event etherReceiving(uint indexed amount);
    event payingEtherToOwner(address payable owner, uint indexed amount);
    event approval(address from, address to, uint amount);

    //constants

    uint public totalSuply;

    Members m;

    address multiSigAddress;

    //storage

    mapping ( address => uint ) private ownersDeposit;//ether amount could be payed to owner 
    mapping ( address => uint ) public _balances;
    mapping ( address => mapping(address => uint)) public allowed;// amount of token you approve to spend by another account


    //modifiers

    modifier addressNotNull(address _address){
        require(_address != address(0));
        _;
    }


    /// @dev Fallback function calls reciveEther
    /// Requires that all ether could be deposited
    function()
        external 
        payable
    {
        receiveEther();
    }

    //functions

    /// @dev Allows to get owners ether deposit outside of contract
    function getOwnerDeposit()
        external  
        view
        returns (uint)
    {
        return ownersDeposit[msg.sender];
    }

    /// @dev Allows to get contract address outside of contract
    /// Used for test with sending ether to contract
    function getContractAddress()
        external 
        view 
        returns(address)
    {
        return address(this);
    }

    /// @dev Allows to get total suply of tokens outside of contract
    function getTotalSuply()
        external
        view
        returns (uint)
    {
        return totalSuply;
    }

    function getMembersContractAddress() 
        external
        view
        returns (address)
    {
        return address(m);
    }

    function getMultiSigContractAddress() 
        external
        view
        returns (address)
    {
        return multiSigAddress;        
    }

    function setMembersContractAddress(address _address) 
        external
    {
        require(address(m) == address(0), "Can be set only once");
        m = Members(_address);
        require(m.isOwner(msg.sender), "Can be set only by owner");
    }

    function setMultiSigContractAddress(address _address) 
        external
    {
        require(m.isOwner(msg.sender), "Can be set only by owner");
        require(multiSigAddress == address(0), "Multisig address sets only once");
        multiSigAddress = _address;
    }

    /// @dev Allows to get amount of owners tokens
    /// @param account is owner which token balance you want to get
    function balanceOf(address account)
        public
        view
        returns (uint)
    {
        return _balances[account];
    }

    /// @dev Allows to get amount of token approved to spend
    /// @param owner is account who allowes to spend his tokens
    /// @param spender is account who allowed to spend tokens of owner
    function allowance(address owner, address spender) 
        public
        view
        returns (uint)
    {
        return allowed[owner][spender];
    }

    /// @dev Allows to mint tokens only by admin address
    /// @param amount is quantity of tokens to be minted
    /// @param owner is who gets amount of tokens
    function _mint(uint amount, address payable owner)
        public
    {
        require(m.isOwner(owner), "Address is not owner to get tokens");
        require(msg.sender == multiSigAddress, "Can be called only from MultiSig contract, only after confirmed voting");
        totalSuply = totalSuply.add(amount);
        _balances[owner] = _balances[owner].add(amount);
        emit mint(amount, owner);
        
    }

    /// @dev Allows to burn tokens only by admin address
    /// @param amount is quantity of tokens to be burned
    /// @param owner is whoes tokens will be burned
    function _burn(uint amount, address payable owner)
        public
    {
        require(m.isOwner(owner), "Address is not owner to burn his tokens");
        require(msg.sender == multiSigAddress, "Can be called only from MultiSig contract, only after confirmed voting");
        require(_balances[owner] >= amount, "Balance of tokens could bo more than burning amount");
        totalSuply = totalSuply.sub(amount);
        _balances[owner] = _balances[owner].sub(amount);
        emit burn(amount, owner);
    }

    /// @dev Allows to transfer tokens from owner to another
    /// @param sender is woner who sends tokens
    /// @param recipient is owner who gets tokens from sender
    /// @param amount is quantity of token to be transfered
    function _transfer(address sender, address recipient, uint amount)
        internal
        addressNotNull(sender)
        addressNotNull(recipient)
    {

        require(_balances[sender] >= amount, "Sender balance is less than transfer amount");
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit transfering(sender, recipient, amount);
    }

    /// @dev Allows to call transfer function from outside of contract
    /// @param to is owner who gets tokens from sender
    /// @param amount is quantity of token to be transfered
    /// requires that you can transfer tokens only from your address
    function transfer(address to, uint amount)
        external
        returns (bool)
    {
        require(m.isOwner(msg.sender), "Only owner can transfer tokens");
        require(m.isOwner(to), "Only owner can receive tokens");
        _transfer(msg.sender, to, amount);
        return m.isOwner(msg.sender);
    }

    /// @dev Allows receive ether from outside of conctract
    /// After receiving decreases deposits of owners proportional to their token balances
    function receiveEther() 
        public
        payable
    {
        require(totalSuply != 0, "No owners to get ether");
        for(uint i = 0; i < m.getOwnersLength(); i++){
            ownersDeposit[m.owners(i)] = ownersDeposit[m.owners(i)].add(
                SafeMath.mul(balanceOf(m.owners(i)), msg.value) / totalSuply
            );
        }
        emit etherReceiving(msg.value);
    }

    /// @dev Allows owner to get his all ether deposit
    /// After paying sets deposit to zero
    function payEtherToOwner()
        external
    {
        require(m.isOwner(msg.sender), "Only owner can have deposit");
        require(ownersDeposit[msg.sender] != 0, "No ehter to pay owner");
        msg.sender.transfer(ownersDeposit[msg.sender]);
        emit payingEtherToOwner(msg.sender, ownersDeposit[msg.sender]);
        ownersDeposit[msg.sender] = 0;
    }

    /// @dev Allows approve spending your tokens by another account
    /// @param spender is owner who can spend your tokens
    /// @param amount is quantity of tokens could be spend
    /// Only owner of tokens can set spender of his tokens and amount
    function approve(address payable spender, uint amount)
        external
        returns (bool)
        {
            allowed[msg.sender][spender] = amount;
            emit approval(msg.sender, spender, amount);
            return true;
        }

    /// @dev Allows transfer tokens from sender to recipient by another account 
    /// @param from is address who approved spending his tokens by msg.sender
    /// @param to is recipient who gets tokens from owner
    /// @param amount is quantity of tokens to be transfered to recipient
    /// This transfer can be succesful only after approval amount and address who can spend tokens 
    function transferFrom(address payable from, address payable to, uint amount)
        external
        returns (bool)
    {
        require(m.isOwner(from), "Only owner can transfer tokens");
        require(m.isOwner(to), "Only owner can receive tokens");
        require(allowed[from][msg.sender] >= amount);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(amount);
        _transfer(from, to, amount);
        return true;
    }
}
