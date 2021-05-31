#!/usr/bin/python3
import brownie
from test_sets_addresses import set_all_addresses

def add_owner(address, accounts, members, token, multisig, payments):
    voting_id = multisig.addAddOwnerVoting(address)
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[5]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[4]})

    multisig.executeAddOwnerVoting(voting_id.return_value, {'from' : accounts[4]})

    return voting_id.return_value

def remove_owner(address, accounts, members, token, multisig, payments):
    voting_id = multisig.addRemoveOwnerVoting(address)
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[3]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[5]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[4]})
    

    multisig.executeRemoveOwnerVoting(voting_id.return_value, {'from' : accounts[4]})

    return voting_id.return_value

def mint(amount, address, accounts, members, token, multisig, payments):
    voting_id = multisig.addMintVoting(10**18, address)
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[5]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[4]})

    multisig.executeMintVoting(voting_id.return_value, {'from' : accounts[5]})

    return voting_id.return_value

def burn(amount, address, accounts, members, token, multisig, payments):
    voting_id = multisig.addBurnVoting(10**18, address)
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[3]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[4]})

    multisig.executeBurnVoting(voting_id.return_value, {'from' : accounts[5]})

    return voting_id.return_value


def test_add_owner_voting_test(accounts, members, token, multisig, payments):
    set_all_addresses(members, token, multisig, payments, accounts)

    add_owner(accounts[0], accounts, members, token, multisig, payments)

    assert members.getOwnersLength() == 4
    assert members.isOwner(accounts[0]) == 1

def test_remove_owner_voting(accounts, members, token, multisig, payments):
    set_all_addresses(members, token, multisig, payments, accounts)

    add_owner(accounts[0], accounts, members, token, multisig, payments)

    remove_owner(accounts[0], accounts, members, token, multisig, payments)

    assert members.getOwnersLength() == 3
    assert members.isOwner(accounts[0]) == 0

def test_correct_votings_count(accounts, members, token, multisig, payments):
    set_all_addresses(members, token, multisig, payments, accounts)

    voting_id1 = multisig.addMintVoting(10**18, accounts[3], {'from' : accounts[0]})

    voting_id2 = multisig.addMintVoting(10**18, accounts[4], {'from' : accounts[0]})

    voting_id3 = multisig.addMintVoting(10**18, accounts[3], {'from' : accounts[0]})

    assert voting_id1.return_value == 0
    assert voting_id2.return_value == 1
    assert voting_id3.return_value == 2
    

def test_coffee_voting(accounts, members, token, multisig, payments):
    set_all_addresses(members, token, multisig, payments, accounts)
    voting_id = multisig.addNewCoffeePriseVoting(10**18, {'from' : accounts[5]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[3]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[4]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[5]})
    multisig.executeNewCoffeePriseVoting(voting_id.return_value, {'from' : accounts[5]})

    assert payments.getCoffeePrise() == 10**18
