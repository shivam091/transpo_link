# TranspoLink

Emphasizing the connection between suppliers, buyers, and logistics.

**© 2025, TranspoLink LLP or its affiliates, all rights reserved.**

## Introduction

Centralized application for logistics company to manage all orders to be transported from suppliers to buyers
along with the warehouse details and various modes of transport.
One stop solution database for **TranspoLink LLP**.

## Requirements

- Ruby: Ruby 3.3+
- Rails: Rails 8.0+
- PostgreSQL: 14+

## Installation

1. **Clone the Repository**

   ```shell
   git clone git@github.com:shivam091/transpo_link.git
   ```

2. **Set Up PostgreSQL User**

   Run the following script to create a PostgreSQL user:

   ```shell
   bash script/create_postgres_user.sh
   ```

   You can also provide username and password as arguments:

   ```shell
   bash script/create_postgres_user.sh myuser mypassword
   ```

   This will:
   - Create a PostgreSQL user (if it does not exist)
   - Grant superuser privileges
   - Set a password for the user

3. **Run the Configuration Rake Task**

   ```shell
   rake transpo_link:configure
   ```

## Author

[Harshal LADHE](https://shivam091.github.io/)
