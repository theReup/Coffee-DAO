
pragma solidity ^0.5.0;

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
    event newCoffeePriseVotingAdding(uint indexed newPrise, uint indexed id);
    event newCoffeePriseExecution(uint indexed newPrise, uint indexed id);
    event changeHumanResourcesStaffVotingAdding(address indexed newHumanResourcesStaff, uint indexed id);
    event changeHumanResourcesStaffExecution(address indexed newHumanResourcesStaff, uint indexed id);

    //storage

    Members m;

    governanceToken gt;

    Payments p;

    mapping ( uint => votings ) votingsId;//Ids of votings, needed to easily find transaction by id during confirmation
    mapping ( uint => mapping (address => bool) ) confirmedByOwner;
    
    uint public votingsCount;

    struct votings{
        address payable participant;
        uint amount;
        uint confirmations;
        bool isConfirmed;
        uint id;
        bool executed;
    }



    function setGovernanceTokenContractAddress(address payable _address) 
        external
    {
        require(address(gt) == address(0), "Can be set only once");
        require(m.isOwner(msg.sender), "Can be set only by owner");
        gt = governanceToken(_address);
    }

    function setMembersContractAddress(address _address) 
        external
    {
        require(address(m) == address(0), "Can be set only once");
        m = Members(_address);
        require(m.isOwner(msg.sender), "Can be set only by owner");
    }

    function setPaymentsContractAddress(address payable _address) 
        external
    {
        require(address(p) == address(0), "Can be set only once");
        p = Payments(_address);
        require(m.isOwner(msg.sender), "Can be set only by owner");
    }

    function getMembersContractAddress() 
        external
        view
        returns (address)
    {
        return address(m);
    }
    function getGovernanceTokenContractAddress() 
        external
        view
        returns (address)
    {
        return address(gt);
    }

    function getPaymentsContractAddress() 
        external
        view
        returns (address)
    {
        return address(p);
    }
    

    function getContractAddress() 
        external
        view
        returns (address)
    {
        return address(this);
    }

    function viewConfirmationStatus(uint id) 
        external
        view
        returns (bool)
    {
        return votingsId[id].isConfirmed;
    }


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


    //Votings

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

    function addNewCoffeePriseVoting(uint newPrise) 
        external
        returns (uint)
    {
        require(m.isOwner(msg.sender), "Only owner can add votings");
        votingsId[votingsCount] = votings({
            participant : address(0),
            amount : newPrise,
            id : votingsCount,
            isConfirmed : false,
            confirmations : 0,
            executed : false
        });
        
        emit newCoffeePriseVotingAdding(votingsId[votingsCount].amount, votingsCount);
        votingsCount += 1;
        return votingsCount - 1;
    }

    //executing votings


    function executeChangeHumanResourcesStaffVoting(uint id) 
        external    
    {

        require(votingsId[id].executed == false, "Votings can be executed only once");
        require(votingsId[id].isConfirmed, "Only corfirmed voting could be executed");
        m.changeHumanResourcesStaff(votingsId[id].participant);
        emit changeHumanResourcesStaffExecution(votingsId[id].participant, id);
    }

    function executeMintVoting(uint id) 
        external    
    {

        require(votingsId[id].executed == false, "Votings can be executed only once");
        require(votingsId[id].isConfirmed, "Only corfirmed voting could be executed");
        gt._mint(votingsId[id].amount, votingsId[id].participant);
        emit mintExecution(votingsId[id].amount, votingsId[id].participant, id);
    }

    function executeBurnVoting(uint id) 
        external    
    {

        require(votingsId[id].executed == false, "Votings can be executed only once");
        require(votingsId[id].isConfirmed, "Only corfirmed voting could be executed");
        gt._burn(votingsId[id].amount, votingsId[id].participant);
        votingsId[id].executed = true;
        emit burnExecution(votingsId[id].amount, votingsId[id].participant, id);
    }

    function executeAddOwnerVoting(uint id) 
        external    
    {

        require(votingsId[id].executed == false, "Votings can be executed only once");
        require(votingsId[id].isConfirmed, "Only corfirmed voting could be executed");
        m.addOwner(votingsId[id].participant);
        votingsId[id].executed = true;
        emit addOwnerExecution(votingsId[id].participant, id);
    }

    function executeRemoveOwnerVoting(uint id) 
        external    
    {

        require(votingsId[id].executed == false, "Votings can be executed only once");
        require(votingsId[id].isConfirmed, "Only corfirmed voting could be executed");
        m.removeOwner(votingsId[id].participant);
        votingsId[id].executed = true;
        emit removeOwnerExecution(votingsId[id].participant, id);
    }

    function executeNewCoffeePriseVoting(uint id) 
        external
    {
        require(votingsId[id].executed == false, "Votings can be executed only once");
        require(votingsId[id].isConfirmed, "Only corfirmed voting could be executed");
        p.changeCoffeePrise(votingsId[id].amount);
        votingsId[id].executed = true;
        emit newCoffeePriseExecution(votingsId[id].amount, id);
    }

}