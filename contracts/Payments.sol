pragma solidity ^0.5.0;

/** 
    @notice This contract implements all payments from this contracts 
    to addresses and to this contract
    it has user function buy coffee

*/

import "./SafeMath.sol";
import './governanceToken.sol';

contract Payments {

    using SafeMath for uint;

    event coffeeBying(uint indexed amount);
    event salaryPayment(address indexed worker);
    event paymentToProvider(address indexed provider);
    event taxesPayment(uint indexed amount);
    event depositPayingToGovernanceToken(uint indexed amount);
    event coffeePriceChanging(uint indexed amount);

    mapping ( address => uint ) lastPaymentToWorker;//flag which allows to pay to worker once at 4 weeks
    mapping ( address => uint ) lastPaymentToProvider;//flag which allows to pay to provider once at 4 weeks
    uint lastTaxesPayment;//flag which allows to pay taxes once at 4 weeks

    //Here is defined another contracts
    address multiSigAddress;

    Members m;

    governanceToken gt;


    uint coffeePrice;
    address payable taxesReceiver;//to this address contract sends taxes
    uint taxesAmount;//amount of taxes in percents
    uint taxesToBePayed;// amount of taxes in ether
    uint governanceTokenDeposit;// amount of ether which is clean profit


    /// @dev Sets initial parameters such as
    /// @param _taxesReceiver is address who receives all taxes
    /// @param _coffeePrice is initial coffee price
    /// @param _taxesAmount is amount of taxes in percents
    constructor(address payable _taxesReceiver, uint _coffeePrice, uint _taxesAmount)
        public
    {
        coffeePrice = _coffeePrice;
        taxesReceiver = _taxesReceiver;
        taxesAmount = _taxesAmount;
    }

    /// @dev Allows to get ether 
    function() 
        external
        payable
    {
        
    }

    /// @dev Allows only once to set Members contract address
    /// @param _address is members contract address
    /// Member allows to check who is owner, get owners length ect.
    function setMembersContractAddress(address _address) 
        public
    {
        require(address(m) == address(0), "Can be set only once");
        m = Members(_address);
        require(m.isOwner(msg.sender), "Can be set only by owner");
    }

    /// @dev Allows to set only once governance token contract address
    /// @param _address is covernance token contract address
    /// governance token allows to destribute profit between owners
    function setGovernanceTokenContractAddress(address payable _address) 
        public
    {
        require(address(gt) == address(0), "Can be set only once");
        require(m.isOwner(msg.sender), "Can be set only by owner");
        gt = governanceToken(_address);
    }

    /// @dev Allows to set only once multiSig contract address
    /// @param _address is multisig contract address
    /// It allows to check that only multisig voting is calling some certain functions
    function setMultiSigContractAddress(address _address) 
        public
    {
        require(multiSigAddress == address(0), "Multisig address sets only once from multisig constructor");
        multiSigAddress = _address;
    }

    /// @dev Allows to set new coffee price only by multisig voting
    /// @param newPrice is new coffee price
    function changeCoffeePrice(uint newPrice)
        external
    {
        require(msg.sender == multiSigAddress, "Change coffee price can only multiSig voting");
        coffeePrice = newPrice;
        emit coffeePriceChanging(newPrice);
    }

    /// @dev Allows to see coffee price
    function getCoffeePrice() 
        external
        view
        returns (uint)
    {
        return coffeePrice;        
    }

    /// @dev Aloows to view members contract address
    /// Used in tests to check correct addresses setting betweeen all contracts
    function getMembersContractAddress() 
        external
        view
        returns (address)
    {
        return address(m);
    }

    /// @dev Aloows to view governance token contract address
    /// Used in tests to check correct addresses setting betweeen all contracts
    function getGovernanceTokenContractAddress() 
        external
        view
        returns (address)
    {
        return address(gt);
    }

    /// @dev Allows to view multiSig contract address
    /// Used in tests to check correct addresses setting betweeen all contracts
    function getMultiSigContractAddress() 
        external
        view
        returns (address)
    {
        return multiSigAddress;
    }

    /// @dev Allows to get this contract address
    /// Actualy used to get this address from another contracts
    function getContractAddress() 
        external
        view
        returns (address)
    {
        return address(this);
    }

    /// @dev Allows to view clean profit could be send to gevernance token contract
    function getGovernanceTokenDeposit() 
        external
        view
        returns (uint)
    {
        return governanceTokenDeposit;
    }

    /// @dev Allows to buy client coffee
    /// @param amount is quamtity of coffee cups
    /// This function straigth counts taxes and governance token deposit
    /// Taxes is increased by every coffee buying
    /// Governance token deposit increased when all payments to workers, providers and taxes are earned
    function buyCoffee(uint amount) 
        external
        payable
    {
        require(msg.value == SafeMath.mul(coffeePrice, amount), "Balance amount could be enough to pay");
        taxesToBePayed = SafeMath.add(SafeMath.mul(msg.value, taxesAmount) / 100, taxesToBePayed);
        if(address(this).balance > m.getAllPayments()){
            governanceTokenDeposit = SafeMath.add(governanceTokenDeposit, SafeMath.mul(msg.value, SafeMath.sub(100, taxesAmount)) / 100);
        }
        
        emit coffeeBying(amount);    
    }

    /// @dev Allows to pay deposit to governance token contract
    /// You can choose frequency of calling to controll gas commition
    function payDepositToGovernanceToken() 
        external
    {
        require(m.isOwner(msg.sender) == true, "Only owner can call deposit paying");
        gt.receiveEther.value(governanceTokenDeposit)();
        
        emit depositPayingToGovernanceToken(governanceTokenDeposit);
        governanceTokenDeposit = 0;
    }

    /// @dev Allows to pay salary to worker
    /// Only worker can get his payment once at 4 weeks 
    function paySalaryToWorker() 
        external    
    {    
        require(m.isWorker(msg.sender), "Only worker can call for salary");
        if(SafeMath.sub(now, lastPaymentToWorker[msg.sender]) > 4 * 3600 * 24 * 7){
            msg.sender.transfer(m.salary(msg.sender));
        }
        lastPaymentToWorker[msg.sender] = now;
        emit salaryPayment(msg.sender);
    }

    /// @dev Allows to pay ether to provider
    /// Only provider can get ether every 4 weeks
    function payToProvider() 
        external
    {
        require(m.isProvider(msg.sender), "Only provider can call for payment");
        if(SafeMath.sub(now, lastPaymentToProvider[msg.sender]) > 4 * 3600 * 24 * 7){
            msg.sender.transfer(m.paymentToProvider(msg.sender));
        }
        lastPaymentToProvider[msg.sender] = now;
        emit paymentToProvider(msg.sender);
    }

    /// @dev Allows to pay taxes to defined address
    /// Taxes could be paied only by owner once at 4 weeks
    function payTaxes() 
        external
    {
        require(m.isOwner(msg.sender), "Only owner can pay taxes");
        if(SafeMath.sub(now, lastTaxesPayment) > 4 * 3600 * 24 * 7){
            taxesReceiver.transfer(taxesToBePayed);
        }
        lastTaxesPayment = now;
        emit taxesPayment(taxesToBePayed);
        taxesToBePayed = 0;
    }

}