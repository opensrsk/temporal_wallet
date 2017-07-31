Temporal Wallet
===============
A crypto currency wallet for allowing temporary or scheduled privileges to external addresses. 

# Premise
Users in a decentral world are willing to allow 3rd party services control of their funds with two requirements: 

* Access is temporary or for a defined period of time. 
* Access can be revoked at any time. 

# Overview
A Temporal Wallet is similar in function to a normal wallet allowing a user to securely deposit and withdrawal crypto currency. Uniquely, a Temporal Wallet also lets the user schedule a time for the control of funds to temporarily change ownership from one address to another. This can be done in one full transfer or at set increments. This method for timed fund release has numerous advantages, foremost is the decrease in potential fees of the executing blockchain. 

### Temporal Wallet Example: Dropbox Billing Subscription

1. Alice wants to send a large file cookie to Bob.
2. John runs an application that stores data on Dropbox and in return for a monthly service fee. 
3. Alice create a temporal wallet, sends crypto currency to the wallet.
4. Alice authorizes John's wallet address to recieve the currency at a set amount, for a set period.

### Temporal Wallet Example: SRSK Private Node launches Amazon's EC2 instances for clients every hour.

1. Alice wants to launch an Amazon EC2 cloud machine backup a copy of the block chain. 
2. A 3rd party service waits for a list of contracts to authorize it's address at a given Temporal Wallet for every address 
3. that needs an instance a service launches a new Amazon Cloud Machine. 
4. SRSK Private Node can now in a sense withdraw as much as was defined by the Temporal Wallet. 
