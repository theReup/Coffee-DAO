#!/usr/bin/python3
import pytest
from test_multisig import add_owner, mint, remove_owner
from test_sets_addresses import set_all_addresses

#adding removing and replacing test for owners
def test_init_num_of_owners_is_3(accounts, members, token, multisig, payments):
    len = members.getOwnersLength()
    
    assert len == 3

def test_length_increased_by_one(accounts, members, token, multisig, payments):
    set_all_addresses(members, token, multisig, payments, accounts)
    old_length = members.getOwnersLength({'from': accounts[0]})
    add_owner(accounts[0], accounts, members, token, multisig, payments)
    new_length = members.getOwnersLength({'from': accounts[0]})

    assert new_length - old_length == 1

def test_length_decreased_by_one(accounts, members, token, multisig, payments):
    set_all_addresses(members, token, multisig, payments, accounts)
    add_owner(accounts[0], accounts, members, token, multisig, payments)
    old_length = members.getOwnersLength()
    remove_owner(accounts[0], accounts, members, token, multisig, payments)
    new_length = members.getOwnersLength()

    assert old_length - new_length == 1

def test_const_length(accounts, members, token, multisig, payments):
    set_all_addresses(members, token, multisig, payments, accounts)
    add_owner(accounts[0], accounts, members, token, multisig, payments)
    old_length = members.getOwnersLength()
    members.replaceOwner(accounts[0], accounts[1], {'from': accounts[0]})
    new_length = members.getOwnersLength()

    assert old_length - new_length == 0

def test_owner_events_fire(accounts, members, token, multisig, payments):
    set_all_addresses(members, token, multisig, payments, accounts)
    add_owner(accounts[0], accounts, members, token, multisig, payments)
    tx =  members.replaceOwner(accounts[0], accounts[1], {'from': accounts[0]})

    assert len(tx.events) == 2
    assert tx.events["ownerRemoval"].values() == [accounts[0]]
    assert tx.events["ownerAddition"].values() == [accounts[1]]


#adding removing and replacing test for workers

def test_worker_length_increased_by_one(accounts, members, token, multisig, payments):
    old_length = members.getWorkersLength({'from': accounts[0]})
    members.addWorker(accounts[0], 10**18, {'from': accounts[7]})
    new_length = members.getWorkersLength({'from': accounts[0]})

    assert new_length - old_length == 1

def test_add_worker_event_fires(accounts, members, token, multisig, payments):
    tx =  members.addWorker(accounts[0], 10**18,{'from': accounts[7]})

    assert len(tx.events) == 1
    assert tx.events["workerAddition"].values() == [accounts[0], 10**18]

def test_worker_length_decreased_by_one(accounts, members, token, multisig, payments):
    members.addWorker(accounts[0], 10**18, {'from': accounts[7]})
    old_length = members.getWorkersLength()
    members.removeWorker(accounts[0], {'from': accounts[7]})
    new_length = members.getWorkersLength()

    assert old_length - new_length == 1

def test_remove_worker_event_fires(accounts, members, token, multisig, payments):
    members.addWorker(accounts[0], 10**18, {'from': accounts[7]})
    tx =  members.removeWorker(accounts[0], {'from': accounts[7]})

    assert len(tx.events) == 1
    assert tx.events["workerRemoval"].values() == [accounts[0]]

def test_worker_const_length(accounts, members, token, multisig, payments):
    members.addWorker(accounts[0], 10**18, {'from': accounts[7]})
    old_length = members.getWorkersLength()
    members.replaceWorker(accounts[0], accounts[1], {'from': accounts[7]})
    new_length = members.getWorkersLength()

    assert old_length - new_length == 0

def test_worker_events_fire(accounts, members, token, multisig, payments):
    members.addWorker(accounts[0], 10**18, {'from': accounts[7]})
    tx =  members.replaceWorker(accounts[0], accounts[1], {'from': accounts[7]})

    assert len(tx.events) == 2
    assert tx.events["workerRemoval"].values() == [accounts[0]]
    assert tx.events["workerAddition"].values() == [accounts[1], 10**18]


#adding removing and replacing test for providers

def test_provider_length_increased_by_one(accounts, members, token, multisig, payments):
    old_length = members.getProvidersLength({'from': accounts[7]})
    members.addProvider(accounts[0], 10**18, {'from': accounts[7]})
    new_length = members.getProvidersLength({'from': accounts[7]})

    assert new_length - old_length == 1

def test_add_provider_event_fires(accounts, members, token, multisig, payments):
    tx =  members.addProvider(accounts[0], 10**18,{'from': accounts[7]})

    assert len(tx.events) == 1
    assert tx.events["providerAddition"].values() == [accounts[0], 10**18]

def test_provider_length_decreased_by_one(accounts, members, token, multisig, payments):
    members.addProvider(accounts[0], 10**18, {'from': accounts[7]})
    old_length = members.getProvidersLength()
    members.removeProvider(accounts[0], {'from': accounts[7]})
    new_length = members.getProvidersLength()

    assert old_length - new_length == 1

def test_remove_provider_event_fires(accounts, members, token, multisig, payments):
    members.addProvider(accounts[0], 10**18, {'from': accounts[7]})
    tx =  members.removeProvider(accounts[0], {'from': accounts[7]})

    assert len(tx.events) == 1
    assert tx.events["providerRemoval"].values() == [accounts[0]]

def test_provider_const_length(accounts, members, token, multisig, payments):
    members.addProvider(accounts[0], 10**18, {'from': accounts[7]})
    old_length = members.getProvidersLength()
    members.replaceProvider(accounts[0], accounts[1], {'from': accounts[7]})
    new_length = members.getProvidersLength()

    assert old_length - new_length == 0

def test_provider_events_fire(accounts, members, token, multisig, payments):
    members.addProvider(accounts[0], 10**18, {'from': accounts[7]})
    tx =  members.replaceProvider(accounts[0], accounts[1], {'from': accounts[7]})

    assert len(tx.events) == 2
    assert tx.events["providerRemoval"].values() == [accounts[0]]
    assert tx.events["providerAddition"].values() == [accounts[1], 10**18]
