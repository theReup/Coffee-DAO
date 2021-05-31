#!/usr/bin/python3
import brownie
import pytest
from test_sets_addresses import set_all_addresses
from test_multisig import mint, add_owner, remove_owner, burn


#transfer tests

def test_balance_sender_decreased(members, token, multisig, payments, accounts):
    set_all_addresses(members, token, multisig, payments, accounts)

    mint(10**18, accounts[3], accounts, members, token, multisig, payments)
    sender_balance = token.balanceOf(accounts[3], {'from': accounts[5]})

    token.transfer(accounts[4], 10**18, {'from': accounts[3]})

    assert sender_balance == token.balanceOf(accounts[3]) + 10**18

def test_balance_recipient_increased(members, token, multisig, payments, accounts):
    set_all_addresses(members, token, multisig, payments, accounts)

    mint(10**18, accounts[3], accounts, members, token, multisig, payments)
    recipient_balance = token.balanceOf(accounts[4], {'from': accounts[5]})

    token.transfer(accounts[4], 10**18, {'from': accounts[3]})

    assert recipient_balance == token.balanceOf(accounts[4]) - 10**18

def test_total_suply_not_affected(members, token, multisig, payments, accounts):
    set_all_addresses(members, token, multisig, payments, accounts)

    mint(10**18, accounts[3], accounts, members, token, multisig, payments)
    total_suply_before = token.getTotalSuply()

    token.transfer(accounts[4], 10**18, {'from': accounts[3]})

    assert total_suply_before == token.getTotalSuply()

def test_transfer_to_self(members, token, multisig, payments, accounts):
    set_all_addresses(members, token, multisig, payments, accounts)

    mint(10**18, accounts[3], accounts, members, token, multisig, payments)
    sender_balance = token.balanceOf(accounts[3], {'from': accounts[0]})

    token.transfer(accounts[3], 10**18, {'from': accounts[3]})

    assert sender_balance == token.balanceOf(accounts[3], {'from': accounts[0]})

def test_zero_transfer(members, token, multisig, payments, accounts):
    set_all_addresses(members, token, multisig, payments, accounts)

    sender_balance = token.balanceOf(accounts[3], {'from': accounts[0]})
    recipient_balance = token.balanceOf(accounts[4], {'from': accounts[1]})

    token.transfer(accounts[4], 0, {'from': accounts[3]})

    assert sender_balance == token.balanceOf(accounts[3], {'from': accounts[0]})
    assert recipient_balance == token.balanceOf(accounts[4], {'from': accounts[1]})


#approve tests

@pytest.mark.parametrize("idx", range(5))
def test_initial_approval_is_zero(token, accounts, idx):
    assert token.allowance(accounts[0], accounts[idx]) == 0

def test_approve(token, accounts):
    token.approve(accounts[1], 10**19, {'from': accounts[0]})

    assert token.allowance(accounts[0], accounts[1]) == 10**19

def test_modify_approve(token, accounts):
    token.approve(accounts[1], 10**18, {'from': accounts[0]})
    token.approve(accounts[1], 1234, {'from': accounts[0]})

    assert token.allowance(accounts[0], accounts[1]) == 1234

def test_approve_self(token, accounts):
    token.approve(accounts[0], 10**19, {'from': accounts[0]})

    assert token.allowance(accounts[0], accounts[0]) == 10**19

def test_only_affects_target(token, accounts):
    token.approve(accounts[1], 10**19, {'from': accounts[0]})

    assert token.allowance(accounts[1], accounts[0]) == 0


def test_returns_true(token, accounts):
    tx = token.approve(accounts[1], 10**19, {'from': accounts[0]})

    assert tx.return_value is True

def test_approval_event_fires(accounts, token):
    tx = token.approve(accounts[1], 10**19, {'from': accounts[0]})

    assert len(tx.events) == 1
    assert tx.events["approval"].values() == [accounts[0], accounts[1], 10**19]


#transferFrom tests

def test_balance_owner_decreased(members, token, multisig, payments, accounts):
    set_all_addresses(members, token, multisig, payments, accounts)
    mint(10**18, accounts[3], accounts, members, token, multisig, payments)
    owner_balance = token.balanceOf(accounts[3], {'from': accounts[5]})

    token.approve(accounts[5], 10**18, {'from': accounts[3]})

    token.transferFrom(accounts[3], accounts[4], 10**18, {'from': accounts[5]})

    assert owner_balance == token.balanceOf(accounts[3]) + 10**18

def test_balance_recipient_increased(members, token, multisig, payments, accounts):
    set_all_addresses(members, token, multisig, payments, accounts)
    mint(10**18, accounts[3], accounts, members, token, multisig, payments)
    recipient_balance = token.balanceOf(accounts[4], {'from': accounts[5]})

    token.approve(accounts[5], 10**18, {'from': accounts[3]})
    allowance = token.allowance(accounts[3], accounts[5])

    token.transferFrom(accounts[3],accounts[4], 10**18, {'from': accounts[5]})

    assert recipient_balance == token.balanceOf(accounts[4]) - 10**18

def test_allowance_changes_after_approve(members, token, multisig, payments, accounts):
    set_all_addresses(members, token, multisig, payments, accounts)
    mint(10**18, accounts[3], accounts, members, token, multisig, payments)

    allowance_before_approve = token.allowance(accounts[3], accounts[5])

    token.approve(accounts[5], 10**18, {'from': accounts[3]})

    allowance_after_approve = token.allowance(accounts[3], accounts[5])

    assert allowance_after_approve == 10**18
    assert allowance_before_approve == 0

def test_allowance_changes_after_transfer_from(members, token, multisig, payments, accounts):
    set_all_addresses(members, token, multisig, payments, accounts)
    mint(10**18, accounts[3], accounts, members, token, multisig, payments)

    token.approve(accounts[5], 10**18, {'from': accounts[3]})

    allowance_before_transfer = token.allowance(accounts[3], accounts[5])

    token.transferFrom(accounts[3],accounts[4], 10**18, {'from': accounts[5]})

    allowance_after_transfer = token.allowance(accounts[3], accounts[5])

    assert allowance_after_transfer == 0
    assert allowance_before_transfer == 10**18

def test_approval_and_transfering_events_fire(members, token, multisig, payments, accounts):
    set_all_addresses(members, token, multisig, payments, accounts)
    mint(10**18, accounts[3], accounts, members, token, multisig, payments)

    tx = token.approve(accounts[5], 10**18, {'from': accounts[3]})

    tx1 = token.transferFrom(accounts[3],accounts[4], 10**18, {'from': accounts[5]})

    assert len(tx.events) == 1
    assert tx.events["approval"].values() == [accounts[3], accounts[5], 10**18]
    assert len(tx1.events) == 1
    assert tx1.events["transfering"].values() == [accounts[3], accounts[4], 10**18]

#burn tests

def test_balance_decreased(members, token, multisig, payments, accounts):
    set_all_addresses(members, token, multisig, payments, accounts)
    mint(10**18, accounts[3], accounts, members, token, multisig, payments)
    owner_balance = token.balanceOf(accounts[3])
    burn(10**18, accounts[3], accounts, members, token, multisig, payments)

    assert owner_balance == token.balanceOf(accounts[3]) + 10**18

def test_total_suply_decreased(members, token, multisig, payments, accounts):
    set_all_addresses(members, token, multisig, payments, accounts)
    mint(10**18, accounts[3], accounts, members, token, multisig, payments)
    total_suply = token.getTotalSuply()
    burn(10**18, accounts[3], accounts, members, token, multisig, payments)

    assert total_suply == token.getTotalSuply() + 10**18

#mint tests
    
def test_balance_increased(members, token, multisig, payments, accounts):
    set_all_addresses(members, token, multisig, payments, accounts)
    owner_balance = token.balanceOf(accounts[3], {'from': accounts[5]})

    mint(10**18, accounts[3], accounts, members, token, multisig, payments)

    assert owner_balance == token.balanceOf(accounts[3], {'from': accounts[5]}) - 10**18

def test_total_suply_increased(members, token, multisig, payments, accounts):
    set_all_addresses(members, token, multisig, payments, accounts)
    total_suply = token.getTotalSuply()

    mint(10**18, accounts[3], accounts, members, token, multisig, payments)

    assert total_suply == token.getTotalSuply() - 10**18
