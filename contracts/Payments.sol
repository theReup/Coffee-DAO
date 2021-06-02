pragma solidity ^0.5.0;

import "./SafeMath.sol";
//import "./mbers.sol";
import './governanceToken.sol';

contract Payments {

    event coffeeBying(uint indexed amount);
    event salaryPayment(address indexed worker);
    event paymentToProvider(address indexed provider);
    event taxesPayment(uint indexed amount);
    event depositPayingToGovernanceToken(uint indexed amount);

    mapping ( address => uint ) lastPaymentToWorker;
    mapping ( address => uint ) lastPaymentToProvider;
    uint lastTaxesPayment;

    address multiSigAddress;

    Members m;

    governanceToken gt;

    uint coffeePrise;
    address payable taxesReceiver;//to this address contract send taxes
    uint taxesAmount;//in percents
    uint taxesToBePayed;// ether amount to be payed as taxes
    uint governanceTokenDeposit;

    constructor(address payable _taxesReceiver, uint _coffePrise, uint _taxesAmount)
        public
    {
        coffeePrise = _coffePrise;
        taxesReceiver = _taxesReceiver;
        taxesAmount = _taxesAmount;
    }

    function() 
        external
        payable
    {
        
    }

    function setMembersContractAddress(address _address) 
        public
    {
        require(address(m) == address(0), "Can be set only once");
        m = Members(_address);
        require(m.isOwner(msg.sender), "Can be set only by owner");
    }

    function setGovernanceTokenContractAddress(address payable _address) 
        public
    {
        require(address(gt) == address(0), "Can be set only once");
        require(m.isOwner(msg.sender), "Can be set only by owner");
        gt = governanceToken(_address);
    }


    function setMultiSigContractAddress(address _address) 
        public
    {
        require(multiSigAddress == address(0), "Multisig address sets only once from multisig constructor");
        multiSigAddress = _address;
    }



    function changeCoffeePrise(uint newPrise)
        external
    {
        require(msg.sender == multiSigAddress, "Change coffee prise can only multiSig voting");
        coffeePrise = newPrise;
    }

    function getCoffeePrise() 
        external
        view
        returns (uint)
    {
        return coffeePrise;        
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
    function getMultiSigContractAddress() 
        external
        view
        returns (address)
    {
        return multiSigAddress;
    }

    function getContractAddress() 
        external
        view
        returns (address)
    {
        return address(this);
    }

    function getGovernanceTokenDeposit() 
        external
        view
        returns (uint)
    {
        return governanceTokenDeposit;
    }

    function buyCoffee(uint amount) 
        external
        payable
    {
        require(msg.value == SafeMath.mul(coffeePrise, amount), "Balance amount could be enough to pay");
        taxesToBePayed = SafeMath.add(SafeMath.mul(msg.value, taxesAmount) / 100, taxesToBePayed);
        if(address(this).balance > m.getAllPayments()){
            governanceTokenDeposit = SafeMath.add(governanceTokenDeposit, SafeMath.mul(msg.value, SafeMath.sub(100, taxesAmount)) / 100);
        }
        
        emit coffeeBying(amount);    
    }

    function payDepositToGovernanceToken() 
        external
    {
        require(m.isOwner(msg.sender) == true, "Only owner can call deposit paying");
        gt.receiveEther.value(governanceTokenDeposit)();
        
        emit depositPayingToGovernanceToken(governanceTokenDeposit);
        governanceTokenDeposit = 0;
    }

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