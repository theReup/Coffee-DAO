#!/usr/bin/python3

import pytest
import brownie
from brownie import Members, governanceToken, MultiSig, Payments, accounts

@pytest.fixture(scope="function", autouse=True)
def isolate(fn_isolation):
    # perform a chain rewind after completing each test, to ensure proper isolation
    # https://eth-brownie.readthedocs.io/en/v1.10.3/tests-pytest-intro.html#isolation-fixtures
    pass


@pytest.fixture(scope="module")
def members(Members, accounts):
    return Members.deploy(accounts[3], accounts[4], accounts[5], accounts[7], {'from': accounts[0]})

@pytest.fixture(scope="module")
def token(governanceToken, accounts):
    return governanceToken.deploy( {'from': accounts[0]})

@pytest.fixture(scope="module")
def payments(Payments, accounts):
    return Payments.deploy(accounts[8], 10**18 / 2500, 13, {'from': accounts[0]})


@pytest.fixture(scope="module")
def multisig(MultiSig, accounts):
    return MultiSig.deploy( {'from': accounts[0]})



