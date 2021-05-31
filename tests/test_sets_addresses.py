import brownie

def set_all_addresses(members, token, multisig, payments, accounts):
    members.setMultiSigContractAddress(multisig.getContractAddress(), {'from' : accounts[5]})
    token.setMembersContractAddress(members.getContractAddress(), {'from' : accounts[5]})
    token.setMultiSigContractAddress(multisig.getContractAddress(), {'from' : accounts[5]})
    multisig.setMembersContractAddress(members.getContractAddress(), {'from' : accounts[5]})
    multisig.setGovernanceTokenContractAddress(token.getContractAddress(), {'from' : accounts[5]})
    multisig.setPaymentsContractAddress(payments.getContractAddress(), {'from' : accounts[5]})

    payments.setMembersContractAddress(members.getContractAddress(), {'from' : accounts[5]})
    payments.setGovernanceTokenContractAddress(token.getContractAddress(), {'from' : accounts[5]})
    payments.setMultiSigContractAddress(multisig.getContractAddress(), {'from' : accounts[5]})


def test_correct_addresses_set(members, token, multisig, payments, accounts):
    set_all_addresses(members, token, multisig, payments, accounts)

    assert payments.getGovernanceTokenContractAddress() == token.getContractAddress()
    assert payments.getMembersContractAddress() == members.getContractAddress()
    assert payments.getMultiSigContractAddress() == multisig.getContractAddress()
    assert members.getMultiSigContractAddress() == multisig.getContractAddress()
    assert token.getMembersContractAddress() == members.getContractAddress()
    assert token.getMultiSigContractAddress() == multisig.getContractAddress()
    assert multisig.getMembersContractAddress() == members.getContractAddress()
    assert multisig.getGovernanceTokenContractAddress() == token.getContractAddress()
    assert multisig.getPaymentsContractAddress() == payments.getContractAddress()