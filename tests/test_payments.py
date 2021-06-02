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
    assert payments.getGovernanceTokenDeposit({'from' : accounts[5]}) == 10**18 * (100 - 13) / 250000 

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
    taxes_keeper_balance_before = accounts[8].balance()
    payments.payTaxes({'from' : accounts[5]})
    taxes_keeper_balance_after = accounts[8].balance()
    contract_balance_after = payments.balance()

    assert taxes_keeper_balance_after - taxes_keeper_balance_before == (10**18 / 2500 * 13) / 100
    assert contract_balance_before - contract_balance_after == (10**18 / 2500 * 13) / 100

def test_test(accounts, multisig,  payments, members, token):
    set_all_addresses(members, token, multisig, payments, accounts)
    mint(10**18, accounts[3], accounts, members, token, multisig, payments)

    before = token.balance()
    accounts[0].transfer(token, 10**18)

    assert token.balance() - before == 10**18

def test_pay_deposit_to_governance_token(accounts, multisig,  payments, members, token):
    set_all_addresses(members, token, multisig, payments, accounts)
    mint(10**18, accounts[3], accounts, members, token, multisig, payments)
    mint(10**18, accounts[4], accounts, members, token, multisig, payments)
    mint(10**18, accounts[5], accounts, members, token, multisig, payments)

    payments.buyCoffee(1, {'from' : accounts[0], 'value' : 10**18 / 2500})

    token_balance_before = token.balance()
    payments_balacne_before = payments.balance()
    deposit = payments.getGovernanceTokenDeposit()
    payments.payDepositToGovernanceToken({'from' : accounts[5]})
    payments_balance_after = payments.balance()
    token_balance_after = token.balance()

    assert payments_balacne_before - payments_balance_after == deposit
    assert token_balance_after - token_balance_before == deposit
    assert payments.getGovernanceTokenDeposit() == 0
    assert token.balanceOf(accounts[3]) == token.balanceOf(accounts[4])
    assert token.balanceOf(accounts[4]) == token.balanceOf(accounts[5])
    assert token.getOwnerDeposit({'from' : accounts[3]}) + token.getOwnerDeposit({'from' : accounts[4]}) + token.getOwnerDeposit({'from' : accounts[5]}) == deposit

def test_all_payments(accounts, multisig,  payments, members, token):
    set_all_addresses(members, token, multisig, payments, accounts)
    mint(10**18, accounts[3], accounts, members, token, multisig, payments)
    members.addWorker(accounts[0], 10**18, {'from': accounts[7]})
    members.addWorker(accounts[1], 10**18, {'from': accounts[7]})

    payments_balance_1_stage = payments.balance()

    payments.buyCoffee(2000, {'from' : accounts[0], 'value' : 2000 * 10**18 / 2500})
    deposit_2_stage = payments.getGovernanceTokenDeposit()

    payments.buyCoffee(3000, {'from' : accounts[1], 'value' : 3000 * 10**18 / 2500})
    deposit_3_stage = payments.getGovernanceTokenDeposit()
    payments_balance_3_stage = payments.balance()

    payments.buyCoffee(5000, {'from' : accounts[2], 'value' : 5000 * 10**18 / 2500})
    deposit_4_stage = payments.getGovernanceTokenDeposit()
    payments_balance_4_stage = payments.balance()

    payments.payDepositToGovernanceToken({'from' : accounts[5]})

    assert payments_balance_3_stage - payments_balance_1_stage == 2 * 10**18
    assert deposit_2_stage == 0
    assert deposit_3_stage == 0
    assert deposit_4_stage == (2 * 10**18) * (100 - 13) / 100
    assert payments.balance() == (2 * 10**18) * 13 / 100 + 2 * 10**18
    assert token.balance() == (2 * 10**18) * (100 - 13) / 100
    assert payments.getGovernanceTokenDeposit() == 0




