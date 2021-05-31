#!/usr/bin/python3

from brownie import Members, governanceToken, MultiSig, Payments, accounts


def main():
   return Members.deploy(accounts[3], accounts[4], accounts[5], accounts[7], {'from': accounts[0]})
   

def main():
   return governanceToken.deploy( {'from': accounts[0]})
   

def main():
   return Payments.deploy(accounts[8], 10**18 / 2500, 13, {'from': accounts[0]})
   

def main():
   return MultiSig.deploy( {'from': accounts[0]})

