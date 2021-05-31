import brownie 
from test_sets_addresses import set_all_addresses
from test_multisig import mint

def test_coffee_buyer_balance_decreases(accounts, multisig,  payments, members, token):
    set_all_addresses(members, token, multisig, payments, accounts)
    mint(10**18, accounts[3], accounts, members, token, multisig, payments)


    balance_before = accounts[0].balance()
    payments.buyCoffee(1, {'from' : accounts[0], 'value' : 10**18 / 2500})
    balance_after = accounts[0].balance()

    assert balance_before - balance_after == 10**18 / 2500

def test_contract_balance_increases(accounts, multisig,  payments, members, token):
    set_all_addresses(members, token, multisig, payments, accounts)
    mint(10**18, accounts[3], accounts, members, token, multisig, payments)
    accounts[1].transfer(payments, 10**18)
    balance_before = payments.balance()
    payments.buyCoffee(1, {'from' : accounts[0], 'value' : 10**18 / 2500})
    balance_after = payments.balance()

    assert balance_after - balance_before == 10**18 / 2500

def test_pay_salary(accounts, multisig,  payments, members, token):
    set_all_addresses(members, token, multisig, payments, accounts)

    members.addWorker(accounts[0], 10**18, {'from' : accounts[7]})
    accounts[1].transfer(payments, 10**18)

    worker_balance_before = accounts[0].balance()
    contract_balance_before = payments.balance()
    payments.paySalaryToWorker({'from' : accounts[0]})
    worker_balance_after = accounts[0].balance()
    contract_balance_after = payments.balance()

    assert worker_balance_after - worker_balance_before == 10**18
    assert contract_balance_before - contract_balance_after == 10**18

def test_pay_to_provider(accounts, multisig,  payments, members, token):
    set_all_addresses(members, token, multisig, payments, accounts)
    members.addProvider(accounts[0], 10**18, {'from' : accounts[7]})
    accounts[1].transfer(payments, 10**18)
    
    provider_balance_before = accounts[0].balance()
    contract_balance_before = payments.balance()
    payments.payToProvider({'from' : accounts[0]})
    provider_balance_after = accounts[0].balance()
    contract_balance_after = payments.balance()

    assert provider_balance_after - provider_balance_before == 10**18
    assert contract_balance_before - contract_balance_after == 10**18

def test_pay_taxes(accounts, multisig,  payments, members, token):
    set_all_addresses(members, token, multisig, payments, accounts)
    mint(10**18, accounts[3], accounts, members, token, multisig, payments)
    accounts[1].transfer(payments, 10**18)

    payments.buyCoffee(1, {'from' : accounts[0], 'value' : 10**18 / 2500})

    contract_balance_before = payments.balance()
    taxes_keeper_balance_before = accounts[6].balance()
    payments.payTaxes({'from' : accounts[5]})
    taxes_keeper_balance_after = accounts[6].balance()
    contract_balance_after = payments.balance()

    assert taxes_keeper_balance_after - taxes_keeper_balance_before == (10**18 / 2500 * 13) / 100
    assert contract_balance_before - contract_balance_after == (10**18 / 2500 * 13) / 100

