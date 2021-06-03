pragma solidity ^0.5.0;

import "./SafeMath.sol";

/**
    @notice This contract contains all onwers, workers, and providers base
    with appropriated salaries and payments
    Also is allows to add/remove/replace owners by multisig voting,
    add/remove/replace workers and provider by on address without voting
    its address called humanResourcesStaff who also could be changed by nultisig voting
 */
contract Members {

    using SafeMath for uint;

    //events
    
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
    address payable[] workers;
    address payable[] public owners;
    address payable[] providers;
    address payable humanResourcesStaff;// address who can add and remove workers and providers without multisig voting
    uint constant public MAX_OWNERS_COUNT = 50;
    uint constant public MAX_WORKERS_COUNT = 50;
    uint constant public MAX_PROVIDERS_CONUT = 50;


    /// @dev Allows to set initial state of 3 owners and human resources staff
    /// @param owner_0 is one of the 3 initial owners
    /// @param owner_1 is one of the 3 initial owners
    /// @param owner_2 is one of the 3 initial owners
    /// @param _humanResourcesStaff // address who can add and remove workers and providers without multisig voting
    /// Always needed to existing of 3 owners otherwise multisig logic will be not applicable
    constructor(address payable owner_0, address payable owner_1, address payable owner_2, address payable _humanResourcesStaff)
        public
    {
        addOwner(owner_0);
        addOwner(owner_1);
        addOwner(owner_2);
        humanResourcesStaff = _humanResourcesStaff;
    }


    // modifiers
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

    /// @dev Allows to view multisig contract address
    /// Used in tests to check correct setting of addresses between contracts
    function getMultiSigContractAddress() 
        external
        view
        returns (address)
    {
        return multiSigAddress;
    }

    /// @dev Allows to view quantity of owners
    function getOwnersLength()
        external
        view
        returns (uint) 
    {
        return owners.length;
    }

    /// @dev Allows to view quantity of workers 
    function getWorkersLength()
        external
        view
    returns (uint) 
    {
        return workers.length;
    }

    /// @dev Allows to view quantity of providers
    function getProvidersLength()
        external
        view
    returns (uint) 
    {
        return providers.length;
    }

    /// @dev Allows to view human resources staff address
    function getHumanResourcesStaffAddress() 
        external
        view
        returns (address payable)
    {
        return humanResourcesStaff;
    }
    
    /// @dev Allows to get this contract address
    /// Used to set connection between contracts
    function getContractAddress()
        public
        view
        returns (address)
    {
        return address(this);
    }

    /// @dev Allows to set multisig contract address only once by owner
    /// This address allows to call certain functions only by multisig voting
    function setMultiSigContractAddress(address _address) 
        external
    {
        require(isOwner[msg.sender], "Can be set only by owner");
        require(multiSigAddress == address(0), "Multisig address sets only once");
        multiSigAddress = _address;
    }

    /// @dev Allows to view amount of regular payments to workers and providers 
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

    /// @dev Allows to add new owner only by multisig voting
    /// @param owner is payable address of new owner
    /// Checks max count condition and multisig voting condition beginnig from 3, 
    /// because when owners less than 3 they are added from constructor 
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

    /// @dev Allows to remove owner only by multisig voting
    /// @param owner is payable address of owner to be removed
    /// Checks owners count condition: owners could not be less than 3, otherwise the multisig logic is not applicable
    /// Checks multisig voting condition
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

    /// @dev Allows to replace new owner address with existing without multisig voting
    /// @param owner is existing owner address to be removed
    /// @param newOwner is new not existing address to be added
    /// This function can be called only from existing owner to be removed
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

    /// @dev Allows to add new worker and set his salary only by human resources staff
    /// @param worker is address of worker to be added
    /// @param _salary is workers salary once at 4 weeks
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

    /// @dev Allows to remove existing worker only by human resources staff
    /// @param worker is worker address to be removed
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

    /// @dev Allows to replace existing worker address with another new
    /// @param worker is existing worker to be removed
    /// @param newWorker is new worker to be added
    /// Only existing worker address to be removed can call this function
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

    /// @dev Allows to add provider and set payment only by human resources staff
    /// @param provider is new provider address to be added
    /// @param _payment is providers payment every 4 weeks
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

    /// @dev Allows to remove existing provider only by human resources staff
    /// @param provider is provider address to be removed
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

    /// @dev Allows to replace existing provider with another new
    /// @param provider is provider address to be removed
    /// @param newProvider is new provider address to be added
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

    /// @dev Allows to change human resource staff only by multisig voting
    /// @param newHumanResourcesStaff is new address to replace existing
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