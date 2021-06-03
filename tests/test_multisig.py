#!/usr/bin/python3
import brownie
from test_sets_addresses import set_all_addresses

def add_owner(address, accounts, members, token, multisig, payments):
    voting_id = multisig.addAddOwnerVoting(address, {'from' : accounts[5]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[5]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[4]})

    multisig.executeAddOwnerVoting(voting_id.return_value, {'from' : accounts[4]})

    return voting_id.return_value

def remove_owner(address, accounts, members, token, multisig, payments):
    voting_id = multisig.addRemoveOwnerVoting(address, {'from' : accounts[5]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[3]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[5]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[4]})
    

    multisig.executeRemoveOwnerVoting(voting_id.return_value, {'from' : accounts[4]})

    return voting_id.return_value

def mint(amount, address, accounts, members, token, multisig, payments):
    voting_id = multisig.addMintVoting(amount, address, {'from' : accounts[5]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[5]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[4]})

    multisig.executeMintVoting(voting_id.return_value, {'from' : accounts[5]})

    return voting_id.return_value

def burn(amount, address, accounts, members, token, multisig, payments):
    voting_id = multisig.addBurnVoting(amount, address, {'from' : accounts[5]})
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

    voting_id1 = multisig.addMintVoting(10**18, accounts[3], {'from' : accounts[5]})

    voting_id2 = multisig.addMintVoting(10**18, accounts[4], {'from' : accounts[5]})

    voting_id3 = multisig.addMintVoting(10**18, accounts[3], {'from' : accounts[5]})

    assert voting_id1.return_value == 0
    assert voting_id2.return_value == 1
    assert voting_id3.return_value == 2
    


def test_coffee_voting(accounts, members, token, multisig, payments):
    set_all_addresses(members, token, multisig, payments, accounts)
    voting_id = multisig.addNewCoffeePriceVoting(10**18, {'from' : accounts[5]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[3]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[4]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[5]})
    tx = multisig.executeNewCoffeePriceVoting(voting_id.return_value, {'from' : accounts[5]})

    assert payments.getCoffeePrice() == 10**18
    assert len(voting_id.events) == 1
    assert len(tx.events) == 2
    assert voting_id.events["newCoffeePriceVotingAdding"].values() == [10**18, voting_id.return_value]
    assert tx.events["newCoffeePriceExecution"].values() == [10**18, voting_id.return_value]

def test_human_resources_change(accounts, members, token, multisig, payments):
    set_all_addresses(members, token, multisig, payments, accounts)
    
    tx = multisig.addChangeHumanResourcesStaffVoting(accounts[1], {'from' : accounts[5]})
    
    _id = tx.return_value

    confirm_status_1 = multisig.viewConfirmationStatus(_id)
    multisig.confirmVotings(_id, {'from' : accounts[3]})
    multisig.confirmVotings(_id, {'from' : accounts[4]})

    confirm_status_2 = multisig.viewConfirmationStatus(_id)

    multisig.executeChangeHumanResourcesStaffVoting(_id)

    assert confirm_status_1 == 0
    assert confirm_status_2 == 1
    assert members.getHumanResourcesStaffAddress() == accounts[1]
    assert len(tx.events) == 1
    assert tx.events["changeHumanResourcesStaffVotingAdding"].values() == [accounts[1], _id]

def test_add_owner_events_fires(accounts, members, token, multisig, payments):
    set_all_addresses(members, token, multisig, payments, accounts)
    voting_id = multisig.addAddOwnerVoting(accounts[0], {'from' : accounts[5]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[5]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[4]})

    tx = multisig.executeAddOwnerVoting(voting_id.return_value, {'from' : accounts[4]})

    assert len(voting_id.events) == 1
    assert len(tx.events) == 2
    assert voting_id.events["addOwnerAdding"].values() == [accounts[0], voting_id.return_value]
    assert tx.events["addOwnerExecution"].values() == [accounts[0], voting_id.return_value]

def test_remove_owner_events_fires(accounts, members, token, multisig, payments):
    set_all_addresses(members, token, multisig, payments, accounts)
    add_owner(accounts[0], accounts, members, token, multisig, payments)
    voting_id = multisig.addRemoveOwnerVoting(accounts[0], {'from' : accounts[5]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[5]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[4]})
    multisig.confirmVotings(voting_id.return_value, {'from' : accounts[3]})

    tx = multisig.executeRemoveOwnerVoting(voting_id.return_value, {'from' : accounts[4]})

    assert len(voting_id.events) == 1
    assert len(tx.events) == 2
    assert voting_id.events["removeOwnerAdding"].values() == [accounts[0], voting_id.return_value]
    assert tx.events["removeOwnerExecution"].values() == [accounts[0], voting_id.return_value]


def test_mint_events_fires(accounts, members, token, multisig, payments):
    set_all_addresses(members, token, multisig, payments, accounts)

    tx1 = multisig.addMintVoting(10**18, accounts[5], {'from' : accounts[5]})

    multisig.confirmVotings(tx1.return_value, {'from' : accounts[5]})
    multisig.confirmVotings(tx1.return_value, {'from' : accounts[4]})

    tx2 = multisig.executeMintVoting(tx1.return_value, {'from' : accounts[5]})

    assert len(tx1.events) == 1
    assert len(tx2.events) == 2
    assert tx1.events["mintVotingAdding"].values() == [10**18, accounts[5], tx1.return_value]
    assert tx2.events["mintExecution"].values() == [10**18, accounts[5], tx1.return_value]

def test_burn_events_fires(accounts, members, token, multisig, payments):
    set_all_addresses(members, token, multisig, payments, accounts)

    mint(10**18, accounts[5], accounts, members, token, multisig, payments)

    tx1 = multisig.addBurnVoting(10**18, accounts[5], {'from' : accounts[5]})

    multisig.confirmVotings(tx1.return_value, {'from' : accounts[5]})
    multisig.confirmVotings(tx1.return_value, {'from' : accounts[4]})

    tx2 = multisig.executeBurnVoting(tx1.return_value, {'from' : accounts[5]})

    assert len(tx1.events) == 1
    assert len(tx2.events) == 2
    assert tx1.events["burnVotingAdding"].values() == [10**18, accounts[5], tx1.return_value]
    assert tx2.events["burnExecution"].values() == [10**18, accounts[5], tx1.return_value]


