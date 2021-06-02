pragma solidity ^0.5.0;

// SPDX-License-Identifier: MIT

import "./SafeMath.sol";

/**
    @title Bare-bones Token implementation
    @notice Based on the ERC-20 token standard as defined at
            https://eips.ethereum.org/EIPS/eip-20
 */
contract Members {

    //events

    using SafeMath for uint256;
    
    event ownerAddition(address indexed owner);
    event ownerRemoval(address indexed owner);
    event workerAddition(address indexed worker, uint indexed salary);
    event workerRemoval(address indexed worker);
    event providerAddition(address indexed provider, uint indexed payment);
    event providerRemoval(address indexed provider);
    event humanResourcesStaffChanging(address indexed newHumanResourcesStaff);
    //storage


    address multiSigAddress;

    mapping ( address => bool ) public isOwner;
    mapping ( address => bool ) public isWorker;
    mapping ( address => bool ) public isProvider;
    mapping ( address => uint ) public paymentToProvider;
    mapping ( address => uint ) public salary;
    address payable[] workers;//
    address payable[] public owners;//
    address payable[] providers;//
    address payable humanResourcesStaff;// address who can add and remove workers and providers
    uint constant public MAX_OWNERS_COUNT = 50;
    uint constant public MAX_WORKERS_COUNT = 50;
    uint constant public MAX_PROVIDERS_CONUT = 50;



    constructor(address payable owner_0, address payable owner_1, address payable owner_2, address payable _humanResourcesStaff)
        public
    {
        addOwner(owner_0);
        addOwner(owner_1);
        addOwner(owner_2);
        humanResourcesStaff = _humanResourcesStaff;
    }


    modifier ownerExists(address owner){
        require(isOwner[owner]);
        _;
    }
    
    modifier ownerDoesNotExists(address owner){
        require(!isOwner[owner]);
        _;
    }

    modifier workerExists(address worker){
        require(isWorker[worker]);
        _;
    }
    
    modifier workerDoesNotExists(address worker){
        require(!isWorker[worker]);
        _;
    }

    modifier providerExists(address provider){
        require(isProvider[provider]);
        _;
    }
    
    modifier providerDoesNotExists(address provider){
        require(!isProvider[provider]);
        _;
    }

    modifier addressNotNull(address _address){
        require(_address != address(0));
        _;
    }


    //functions
    function getOwnersLength()
        external
        view
        returns (uint) 
    {
        return owners.length;
    }

    function getMultiSigContractAddress() 
        external
        view
        returns (address)
    {
        return multiSigAddress;
    }

    /*function getIsOwnerStatus(address _owner) 
        external
        view
        returns (bool)
    {
        return isOwner[_owner];
    }*/

    function getHumanResourcesStaffAddress() 
        external
        view
        returns (address payable)
    {
        return humanResourcesStaff;
    }

    function getWorkersLength()
        external
        view
    returns (uint) 
    {
        return workers.length;
    }

    function getProvidersLength()
        external
        view
    returns (uint) 
    {
        return providers.length;
    }
    
    function getContractAddress()
        public
        view
        returns (address)
    {
        return address(this);
    }

    function setMultiSigContractAddress(address _address) 
        external
    {
        require(isOwner[msg.sender], "Can be set only by owner");
        require(multiSigAddress == address(0), "Multisig address sets only once");
        multiSigAddress = _address;
    }

    function getAllPayments()
        external
        view
        returns (uint)
    {
        uint payment = 0;
        for(uint i = 0;i < workers.length; i++){
            payment = SafeMath.add(salary[workers[i]], payment);
        }
        for(uint i = 0;i < providers.length; i++){
            payment = SafeMath.add(paymentToProvider[providers[i]], payment);
        }
        return payment;
    }




    /// @dev Allows to add new owner. 
    function addOwner(address payable owner)
        public
        ownerDoesNotExists(owner)
        addressNotNull(owner)
        
    {
        require(owners.length < MAX_OWNERS_COUNT, "Can not exceed max owners quantity");
        if(owners.length >= 3){
            require(msg.sender == multiSigAddress, "Only MultiSig Voting can add new owner");
        }
        isOwner[owner] = true;
        owners.push(owner);
        emit ownerAddition(owner);
    }


    function removeOwner(address payable owner)
        public
        ownerExists(owner)
    {
        require(owners.length > 3, "Quantity of owners cannot be less than 3");
        require(msg.sender == multiSigAddress, "Only multiSig voting can remove owner");
        isOwner[owner] = false;
        for(uint8 i = 0; i < owners.length - 1; i++){
            if(owners[i] == owner){
                owners[i] = owners[owners.length - 1];
                break;
            }
        }
        owners.length -= 1;
        emit ownerRemoval(owner);
    }


    function replaceOwner(address payable owner, address payable newOwner)
        public
        ownerExists(owner)
        ownerDoesNotExists(newOwner)
        addressNotNull(newOwner)
    {
        require(owner == msg.sender, "You can replace only your account");
        for(uint8 i = 0; i < owners.length -1 ; i++){
            if(owners[i] == owner){
                owners[i] = newOwner;
                break;
            }
        }
        isOwner[owner] = false;
        isOwner[newOwner] = true;
        emit ownerAddition(newOwner);
        emit ownerRemoval(owner);
    }

    function addWorker(address payable worker, uint _salary)
        public
        workerDoesNotExists(worker)
        addressNotNull(worker)
    {
        require(owners.length < MAX_WORKERS_COUNT, "Can not exceed max workers quantity");
        require(msg.sender == humanResourcesStaff, "Only one address can add, remove and replace workers");
        salary[worker] = _salary;
        isWorker[worker] = true;
        workers.push(worker);
        emit workerAddition(worker, _salary);
    }


    function removeWorker(address payable worker)
        public
        workerExists(worker)
    {
        require(msg.sender == humanResourcesStaff, "Only one address can add, remove and replace workers");
        isWorker[worker] = false;
        salary[worker] = 0;
        for(uint8 i = 0; i < workers.length - 1; i++){
            if(workers[i] == worker){
                workers[i] = workers[workers.length - 1];
                break;
            }
        }
        workers.length -= 1;
        emit workerRemoval(worker);
    }


    function replaceWorker(address payable worker, address payable newWorker)
        public
        workerExists(worker)
        workerDoesNotExists(newWorker)
        addressNotNull(newWorker)
    {
        require(owners.length < MAX_WORKERS_COUNT, "Can not exceed max providers quantity");
        require(msg.sender == humanResourcesStaff, "Only one address can add, remove and replace workers");
        for(uint8 i = 0; i < workers.length -1 ; i++){
            if(workers[i] == worker){
                workers[i] = newWorker;
                break;
            }
        }
        isWorker[worker] = false;
        isWorker[newWorker] = true;
        salary[newWorker] = salary[worker];
        salary[worker] = 0;
        emit workerAddition(newWorker, salary[newWorker]);
        emit workerRemoval(worker);
    }

    function addProvider(address payable provider, uint _payment)
        public
        providerDoesNotExists(provider)
        addressNotNull(provider)
        
    {
        require(msg.sender == humanResourcesStaff, "Only one address can add, remove and replace providers");
        paymentToProvider[provider] = _payment;
        isProvider[provider] = true;
        providers.push(provider);
        emit providerAddition(provider, _payment);
    }


    function removeProvider(address payable provider)
        public
        providerExists(provider)
    {
        require(msg.sender == humanResourcesStaff, "Only one address can add, remove and replace providers");
        isProvider[provider] = false;
        paymentToProvider[provider] = 0;
        for(uint8 i = 0; i < providers.length - 1; i++){
            if(providers[i] == provider){
                providers[i] = providers[providers.length - 1];
                break;
            }
        }
        providers.length -= 1;
        emit providerRemoval(provider);
    }


    function replaceProvider(address payable provider, address payable newProvider)
        public
        providerExists(provider)
        providerDoesNotExists(newProvider)
        addressNotNull(newProvider)
    {
        require(msg.sender == humanResourcesStaff, "Only one address can add, remove and replace providers");
        for(uint8 i = 0; i < providers.length -1 ; i++){
            if(providers[i] == provider){
                providers[i] = newProvider;
                break;
            }
        }
        isProvider[provider] = false;
        isProvider[newProvider] = true;
        paymentToProvider[newProvider] = paymentToProvider[provider];
        paymentToProvider[provider] = 0;
        emit providerAddition(newProvider, paymentToProvider[newProvider]);
        emit providerRemoval(provider);
    }

    function changeHumanResourcesStaff(address payable newHumanResourcesStaff) 
        external
        addressNotNull(newHumanResourcesStaff)
    {
        require(msg.sender == multiSigAddress, "Only multiSig voting can remove owner");
        require(newHumanResourcesStaff != humanResourcesStaff, "Change to the same address");
        humanResourcesStaff = newHumanResourcesStaff;
        emit humanResourcesStaffChanging(newHumanResourcesStaff);
    }

}