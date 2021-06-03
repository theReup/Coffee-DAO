
pragma solidity ^0.5.0;

/**
    @notice This contract implements multisig votings by owners
    Owner can add one of listed votings
    Other owers can confirm any voting only once
    Voting is confirmed when half of owners + 1 confirmed voting
    Confirmed voting could be executed by owner 
    Every voting executes certain functions from another contract
 */


import "./Members.sol";
import "./governanceToken.sol";
import "./Payments.sol";

contract MultiSig {

    //events
    event mintVotingAdding(uint indexed amount, address indexed participant, uint indexed id);
    event mintExecution(uint indexed amount, address indexed participant, uint indexed id);
    event burnVotingAdding(uint indexed amount, address indexed participant, uint indexed id);
    event burnExecution(uint indexed amount, address indexed participant, uint indexed id);
    event addOwnerAdding(address indexed participant, uint indexed id);
    event addOwnerExecution(address indexed participant, uint indexed id);
    event removeOwnerAdding(address indexed participant, uint indexed id);
    event removeOwnerExecution(address indexed participant, uint indexed id);
    event newCoffeePriceVotingAdding(uint indexed newPrice, uint indexed id);
    event newCoffeePriceExecution(uint indexed newPrice, uint indexed id);
    event changeHumanResourcesStaffVotingAdding(address indexed newHumanResourcesStaff, uint indexed id);
    event changeHumanResourcesStaffExecution(address indexed newHumanResourcesStaff, uint indexed id);

    //storage

    Members m;

    governanceToken gt;

    Payments p;

    mapping ( uint => votings ) votingsId;//Ids of votings, needed to easily find transaction by id during confirmation and execituing
    mapping ( uint => mapping (address => bool) ) confirmedByOwner;// implements controll that each owner confirm certain voting only once
    
    uint public votingsCount;//counts votings to define their ids by votings addition

    // univercal structure for each voting
    struct votings{
        address payable participant;
        uint amount;
        uint confirmations;//counts confirmation of this voting
        bool isConfirmed;//checks while execution
        uint id;
        bool executed;//checks while execution
    }


    //functions

    /// @dev Allows to set governance token contract address
    /// @param _address is address of governance token contract address
    /// Address could be set only once by owner
    function setGovernanceTokenContractAddress(address payable _address) 
        external
    {
        require(address(gt) == address(0), "Can be set only once");
        require(m.isOwner(msg.sender), "Can be set only by owner");
        gt = governanceToken(_address);
    }

    /// @dev Allows to set members contract address
    /// @param _address is members contract address
    /// Address could be set only once by owner
    function setMembersContractAddress(address _address) 
        external
    {
        require(address(m) == address(0), "Can be set only once");
        m = Members(_address);
        require(m.isOwner(msg.sender), "Can be set only by owner");
    }

    /// @dev Allows to set payments contract address
    /// @param _address is payments contract address
    /// Address could be set only once by owner
    function setPaymentsContractAddress(address payable _address) 
        external
    {
        require(address(p) == address(0), "Can be set only once");
        p = Payments(_address);
        require(m.isOwner(msg.sender), "Can be set only by owner");
    }

    /// @dev Allows to view members contracts address
    /// Used in tests for correct connection between contracts
    function getMembersContractAddress() 
        external
        view
        returns (address)
    {
        return address(m);
    }

    /// @dev Allows to view gevernance token contract address
    /// Used in tests for correct connection between contracts
    function getGovernanceTokenContractAddress() 
        external
        view
        returns (address)
    {
        return address(gt);
    }

    /// @dev Allows to view payments contract address
    /// Used in tests for correct connection between contracts
    function getPaymentsContractAddress() 
        external
        view
        returns (address)
    {
        return address(p);
    }

    /// @dev Allows to get this contract address
    /// Used in tests for correct connection between contracts
    function getContractAddress() 
        external
        view
        returns (address)
    {
        return address(this);
    }

    /// @dev Allows to view confirmation status of certain voting
    /// @param id is id of voting you want to check status
    function viewConfirmationStatus(uint id) 
        external
        view
        returns (bool)
    {
        return votingsId[id].isConfirmed;
    }

    /// @dev Allows to confirm certain voting by owner
    /// @param id id voting id you want to confirm
    /// Reqiures that owner confirm only once
    function confirmVotings(uint id) 
        public
    {
        require(m.isOwner(msg.sender), "Only owner can confirm the voting");
        require(confirmedByOwner[id][msg.sender] == false, "Owner can confirm only once");
        confirmedByOwner[id][msg.sender] = true;
        votingsId[id].confirmations += 1;
        if(votingsId[id].confirmations > m.getOwnersLength() / 2)
        {
            votingsId[id].isConfirmed = true;
        }
    }

    //Votings addition functions

    /// @dev Allows to add voting of changing human resources staff
    /// @param newHumanResourcesStaff is new address you want to replace with extisting
    /// Adds new voting, sets given parameters, id of voting and increases voting count by one 
    function addChangeHumanResourcesStaffVoting(address payable newHumanResourcesStaff) 
        external
        returns (uint)
    {
        require(m.isOwner(msg.sender), "Only owner can add votings");
        votingsId[votingsCount] = votings({
            participant : newHumanResourcesStaff,
            amount : 0,
            id : votingsCount,
            isConfirmed : false,
            confirmations : 0,
            executed : false
        });
        emit changeHumanResourcesStaffVotingAdding(votingsId[votingsCount].participant, votingsCount);
        votingsCount += 1;
        return votingsCount - 1;
    }

    /// @dev Allows to add mint voting
    /// @param _amount is amount of token to be given to owner
    /// @param _owner is address who get tokens
    /// Adds new voting, sets given parameters, id of voting and increases voting count by one 
    function addMintVoting(uint _amount, address payable _owner) 
        external
        returns (uint)
    {
        require(m.isOwner(msg.sender), "Only owner can add votings");
        votingsId[votingsCount] = votings({
            participant : _owner,
            amount : _amount,
            id : votingsCount,
            isConfirmed : false,
            confirmations : 0,
            executed : false
        });
        
        emit mintVotingAdding(votingsId[votingsCount].amount, votingsId[votingsCount].participant, votingsCount);
        votingsCount += 1;
        return votingsCount - 1;
    }

    /// @dev Allows to add burn voting
    /// @param _amount is amount of token to be burned from balance
    /// @param _owner is address whoes tokens will be burned
    /// Adds new voting, sets given parameters, id of voting and increases voting count by one 
    function addBurnVoting(uint _amount, address payable _owner) 
        external
        returns (uint)
    {
        require(m.isOwner(msg.sender), "Only owner can add votings");
        votingsId[votingsCount] = votings({
            participant : _owner,
            amount : _amount,
            id : votingsCount,
            isConfirmed : false,
            confirmations : 0,
            executed : false
        });
        
        emit burnVotingAdding(votingsId[votingsCount].amount, votingsId[votingsCount].participant, votingsCount);
        votingsCount += 1;
        return votingsCount - 1;
    }

    /// @dev Allows to add voting of owner addition
    /// @param owner is new owner to be added
    /// Adds new voting, sets given parameters, id of voting and increases voting count by one 
    function addAddOwnerVoting(address payable owner) 
        external
        returns (uint)
    {
        require(m.isOwner(msg.sender), "Only owner can add votings");
        votingsId[votingsCount] = votings({
            participant : owner,
            amount : 0,
            id : votingsCount,
            isConfirmed : false,
            confirmations : 0,
            executed : false
        });
        
        emit addOwnerAdding(votingsId[votingsCount].participant, votingsCount);
        votingsCount += 1;
        return votingsCount - 1;
    }

    /// @dev Allows to add voting of owner removal
    /// @param owner is new owner to be removed
    /// Adds new voting, sets given parameters, id of voting and increases voting count by one 
    function addRemoveOwnerVoting(address payable owner) 
        external
        returns (uint)
    {
        require(m.isOwner(msg.sender), "Only owner can add votings");
        votingsId[votingsCount] = votings({
            participant : owner,
            amount : 0,
            id : votingsCount,
            isConfirmed : false,
            confirmations : 0,
            executed : false
        });
        
        emit removeOwnerAdding(votingsId[votingsCount].participant, votingsCount);
        votingsCount += 1;
        return votingsCount - 1;
    }

    /// @dev Allows to add voting of changing coffee price
    /// @param newPrice is new price of coffee
    /// Adds new voting, sets given parameters, id of voting and increases voting count by one 
    function addNewCoffeePriceVoting(uint newPrice) 
        external
        returns (uint)
    {
        require(m.isOwner(msg.sender), "Only owner can add votings");
        votingsId[votingsCount] = votings({
            participant : address(0),
            amount : newPrice,
            id : votingsCount,
            isConfirmed : false,
            confirmations : 0,
            executed : false
        });
        
        emit newCoffeePriceVotingAdding(votingsId[votingsCount].amount, votingsCount);
        votingsCount += 1;
        return votingsCount - 1;
    }

    //executing votings

    /// @dev Allows to execute human resources staff changing voting
    /// @param id is voting id you want to execute
    /// Checks execution and confirmation status before execution
    /// Calls changeHumanResourcesStaff() function inside members contract
    function executeChangeHumanResourcesStaffVoting(uint id) 
        external    
    {

        require(votingsId[id].executed == false, "Votings can be executed only once");
        require(votingsId[id].isConfirmed, "Only corfirmed voting could be executed");
        m.changeHumanResourcesStaff(votingsId[id].participant);
        votingsId[id].executed = true;
        emit changeHumanResourcesStaffExecution(votingsId[id].participant, id);
    }

    /// @dev Allows to execute mint voting
    /// @param id is voting id you want to execute
    /// Checks execution and confirmation status before execution
    /// Calls _mint() function inside governance token contract
    function executeMintVoting(uint id) 
        external    
    {
        require(votingsId[id].executed == false, "Votings can be executed only once");
        require(votingsId[id].isConfirmed, "Only corfirmed voting could be executed");
        gt._mint(votingsId[id].amount, votingsId[id].participant);
        votingsId[id].executed = true;
        emit mintExecution(votingsId[id].amount, votingsId[id].participant, id);
    }

    /// @dev Allows to execute burn voting
    /// @param id is voting id you want to execute
    /// Checks execution and confirmation status before execution
    /// Calls _burn() function inside governance token contract
    function executeBurnVoting(uint id) 
        external    
    {
        require(votingsId[id].executed == false, "Votings can be executed only once");
        require(votingsId[id].isConfirmed, "Only corfirmed voting could be executed");
        gt._burn(votingsId[id].amount, votingsId[id].participant);
        votingsId[id].executed = true;
        emit burnExecution(votingsId[id].amount, votingsId[id].participant, id);
    }

    /// @dev Allows to execute owner addition voting
    /// @param id is voting id you want to execute
    /// Checks execution and confirmation status before execution
    /// Calls addOwner() function inside members contract
    function executeAddOwnerVoting(uint id) 
        external    
    {
        require(votingsId[id].executed == false, "Votings can be executed only once");
        require(votingsId[id].isConfirmed, "Only corfirmed voting could be executed");
        m.addOwner(votingsId[id].participant);
        votingsId[id].executed = true;
        emit addOwnerExecution(votingsId[id].participant, id);
    }

    /// @dev Allows to execute owner removal voting
    /// @param id is voting id you want to execute
    /// Checks execution and confirmation status before execution
    /// Calls removeOwner() function inside members contract
    function executeRemoveOwnerVoting(uint id) 
        external    
    {

        require(votingsId[id].executed == false, "Votings can be executed only once");
        require(votingsId[id].isConfirmed, "Only corfirmed voting could be executed");
        m.removeOwner(votingsId[id].participant);
        votingsId[id].executed = true;
        emit removeOwnerExecution(votingsId[id].participant, id);
    }

    /// @dev Allows to execute owner removal voting
    /// @param id is voting id you want to execute
    /// Checks execution and confirmation status before execution
    /// Calls removeOwner() function inside members contract
    function executeNewCoffeePriceVoting(uint id) 
        external
    {
        require(votingsId[id].executed == false, "Votings can be executed only once");
        require(votingsId[id].isConfirmed, "Only corfirmed voting could be executed");
        p.changeCoffeePrice(votingsId[id].amount);
        votingsId[id].executed = true;
        emit newCoffeePriceExecution(votingsId[id].amount, id);
    }

}