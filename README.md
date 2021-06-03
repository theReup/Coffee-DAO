# DAO coffee☕☕☕

## notice 
This project implements Decentraliesed Autonomous Outomation of trivial coffee house buissness by using blockchain and smart contracts.
Decentralised structure of project allows buissness to be owned by some quantity of people.
The main idia of usage blockchain is, that multiownered buissness controlled only by smart contracts what allowes prevent centrilised decisions by one owner.
Multisig structure requires that important desicions (owner addition, coffee price changing etc.) are confirmed by more than half owners.
It means that buissness is multiownered, meanwhile one not reliable owner can't effect to optimal buissness controll.
Aslo big advantage is that all project is to the view by anyone. In multiowners case it means that no one can cheat nowhere.

## Realization concepts
Different owners can have different part of profit by using governance token. Owner get ether proportianaly to his balance of tokens.
To mint and burn tokens necessary to implement multisig voting. Also our project has centralised part, this is ability to add/remove workers and providers by one employee. This is not to much importtant things in buissness controll generally and it could be fullfilled by one employee. Also it does not mean full addiction of one man desicions. This approach is indirectly decentralised, because choosing of this position always done by multisig voting. Worker payments, provider payments and taxes payments allowed not frequenty than every 4 weeks. 

## Application
Practicaly this project can be used only after reworking, because it just presents opportunities and advantages of blockchain based outomation. Every buissness has diffefent structure and approach, it means that each investor choose functional by hisself. This project is the base to the next more huge projects, client usage, multisig votings and employee staff could be expanded. Every single project will be changing due to type of buissness and investors preferences.

## Usage and deploy
There is two ways to test the functional features of this projects
1) Deploy it in Ropsten TESTNET via your MetaMask accounts + Remix IDE (import *.sol files from github repository or your local machine copy) and check the results in https://ropsten.etherscan.io/
2) Deploing ethereum node via Geth in dev mode + Remix IDE (import .sol files from github repository or your local machine copy) and 
check from there

We are using the second way cause it more faster.

1.Copy this repository to Remix IDE: https://remix.ethereum.org/
2.Install Geth (https://geth.ethereum.org/downloads/) and run on your local machine:
```shell
$ geth --http --http.corsdomain="https://remix.ethereum.org" --http.api web3,eth,debug,personal,net --vmdebug --datadir ./ethereum --dev --allow-insecure-unlock console
```
3.Set the ENVIRONMENT parameter in Remix to WEB3 provider
4. Deploy contracts and test!!!
