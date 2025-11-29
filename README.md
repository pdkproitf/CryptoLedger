# Crypto Accounting System

Hi there!

If you're reading this, it means you're now at the coding exercise step of the engineering hiring process. We're really happy that you made it here and super appreciative of your time!

In this exercise you're asked to implement some features in an existing Rails application.

> 💡 The Rails application is an API

If you have any questions, don't hesitate to reach out to duong.le@coinhako.com.

## Background

Transactions on Coinhako record the trading actions performed by users. Our platform employs an accounting system to monitor these trading activities. Your task involves introducing an account statement functionality, enabling users to review their transaction records.

These transactions encompass various actions such as purchasing and selling cryptocurrencies, along with making deposits and withdrawals. Users have the flexibility to engage in the following activities:

* Buying BTC, ETH using USD.
* Selling BTC, ETH and receiving USD.
* Trading between BTC and ETH.

### What we want you to do

This project comes with a basic user and account model, but the data models are incomplete.

This exercise requires you to:

1. 📊 Complete data models
2. 🧮 Implement endpoints to facilitate transactions and provide data about accounts

Include tests and annotate code with comments where necessary.

#### 1. 📊 Complete data models

A user has multiple accounts where each account stores a different currency. For example, a user can have an account with USD and another account with SGD.

You will need to:

* Create a Transaction model with migration

* Complete the `balance` method in Account model 

#### 2. 🧮 Implement endpoints to faciliate transactions and provide data about accounts

Create new endpoints to allow users to perform the following actions:

- Create a new transaction
- Get a list of transactions
- Get a list of accounts

## NOTES.md

`NOTES.md` is for you to let us know your thoughts on this project if you were in charge of it.

Here are some examples of things we love reading in NOTES.md file:

* How you would extend the system to support 100+ currency pairs?
* How would you communicate errors and problems to the user?
* What columns could you add to the accounting models that you think would be helpful?
* Any other comments, questions, or thoughts that came up.

## Running the project

### Environment setup
- You can use SQLite for this exercise or swap for postgresql if it makes sense. You can install sqlite with `brew install sqlite`
- Ruby 3.2.2 installed. If you're new to ruby we recommend looking into [rbenv](https://github.com/rbenv/rbenv) to manage your ruby versions;
    - If you're using rbenv, run `rbenv install 3.2.2`
    - Then set your local ruby version to 3.2.2 by running `rbenv local 3.2.2`
- Bundler installed. If you don't have it, run `gem install bundler`
- To install project dependencies
    - Go into project `cd crypto-accounting-system`
    - Run `bundle install`
- Create a DB and run migrations
    - Run `rails db:create`
    - Run `rails db:migrate`
- At this point you should be almost good to go
    - Run `rails s` to start the server
    - You can now access the API at `http://localhost:3000`
- To run tests
    - Run `rspec spec` to run all tests
    - Observe a failed test. This is expected. You'll need to fix it as part of the exercise

## Tips
There's a lot of extra work we do in production that we don't need here. 

* You don't need to perfect writing tests for each scenario
* You don't need to solve every edge case. You can however, document your decisions and trade-offs in `NOTES.md`

Your code will be evaluated more on the quality than on completing the scope
