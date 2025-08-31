# Description
Provides a single Frontend for several sources:
- Monobank API (https://api.monobank.ua/docs/)
- Etherscan API (https://docs.etherscan.io/)

Works on Sinatra DSL (http://sinatrarb.com/)

Deployment and work is tested on Ubuntu 22.04.3 LTS hosted on AWS virtual machine with Ruby v3.0.2. See other dependencies here: https://github.com/AlexVaizer/wallet/blob/master/Gemfile
## Features
 - shows list of accounts from Monobank and Etherscan
 - shows list of transaction from Monobank and etherscan by Account ID
 - saves accounts info to the **mongodb** to minimize API calls quantity. Statements for the account are always fetched from API.
## Security
 - Prod ENV is working through HTTPS protocol (HTTPS Served by NGINX, it redirects requests to local sinatra HTTP server.). **You must run sinatra always on 127.0.0.1 interface only to be sure it is not exposed to anyone except you**
 - There is a possibility to have several users with access to different Mono/ETH accounts and different API Keys
 - Monobank and Etherscan Token and are taken from DB and are never sent anywhere except Monobank and Etherscan servers, respectively
 - JWT Auth
 - Passwords encrypted on DB level. API keys are not. to be done.


# Installation (For Ubuntu 24)
## Preparing Dependencis
 - Run `sudo apt update -y && sudo apt upgrade -y`
 - Install ruby v3.2.3 and other deps for building the gems:
   ```
   sudo apt install -y curl ruby-full ruby-bundler ruby-dev net-tools build-essential zlib1g-dev libreadline-dev libssl-dev libcurl4-openssl-dev 
   ```
 - Install Nginx and Snapd `sudo apt install -y nginx snapd`
 - Install Mongodb Community edition
   ```
   curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
   echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
   sudo apt update -y
   sudo apt install -y mongodb-org
   sudo systemctl start mongod
   sudo systemctl enable mongod
   ```
 - Prepare AWS credentials for Route53 DNS challenge https://certbot-dns-route53.readthedocs.io/en/stable/, save them to `/root/.aws/config` file. Example:
  ```
[default]
aws_access_key_id=AKIARITUFNGBFHDURNGBF
aws_secret_access_key=8SS8So+VWPHXilbgVMHlx7Z+UK/HYDjwN55HDTw
  ```
 - Install certbot: `sudo snap install core; sudo snap refresh core; sudo snap install --classic certbot`
 - Install AWS Route53 plugin `sudo snap install certbot-dns-route53`
 - Start the certificates generation: `sudo certbot certonly --dns-route53`
 - Copy the path where certificates were saved, you gonna need it on Service Setup step
 - Create pre and post hooks to restart nginx during certificates renewal:
   ```
   sudo sh -c 'printf "#!/bin/sh\nservice nginx stop\n" > /etc/letsencrypt/renewal-hooks/pre/nginx.sh'
   sudo sh -c 'printf "#!/bin/sh\nservice nginx start\n" > /etc/letsencrypt/renewal-hooks/post/nginx.sh'
   sudo chmod 755 /etc/letsencrypt/renewal-hooks/pre/nginx.sh
   sudo chmod 755 /etc/letsencrypt/renewal-hooks/post/nginx.sh
   ```
## Installing the wallet
 - Clone the repo: `git clone https://github.com/AlexVaizer/wallet.git`
 
 - Install dependencies: `cd ./wallet/ && bundle install`
 - Get a Monobank API Token: https://api.monobank.ua/, run clientInfo request to retrieve your Account IDs
 - Get an Etherscan API Token https://docs.etherscan.io/
 - Run service setup: `sudo ruby ./install.rb`, follow the instructions (USER-INPUT needed). This will
    - create a service file in `.services/wallet.service`. You need to manually copy it to /etc/systemd/system/ 
    - add nginx config to `.services/{YOUR_DOMAIN_NAME}` . Copy it to `/etc/nginx/sites-available` and uncomment needed sections. Script will provide needed instructions
 - RSA keypair for signing and verifying JWT tokens is stored in DB, fallback one stored in code. Please be sure to generate your own RSA 2048 keys and add next settings into Props collection (refer to `Contoller::Settings::SETTINGS_TABLE_NAME` for specific collection name)
   ```
   {"_id":"sinatra.jwt.keys.sign": "value": "PRIVATE_KEY_CONTENT"}
   {"_id":"sinatra.jwt.keys.verify": "value": "PUBLIC_KEY_CONTENT"}
   ```
## Run Server
### As a Service
**Service installation and run is tested on UBUNTU ONLY. If you use other operating system, run in debugging mode**

Run:
`sudo systemctl start nginx && sudo systemctl start wallet`.

If you want to run sinatra at **startup**, run `sudo systemctl enable wallet && sudo systemctl enable nginx` once.

### Debugging mode or locally
Run `ruby ./install.rb` and fill all needed info, reply 'n' to question "Do you want to install service" - you'll get proper command to run the server locally.

## Stop Server
### As a service 
`sudo systemctl stop wallet && sudo systemctl stop nginx`

### In debugging mode
 - `ruby ./stop.rb` for Development, Test environments
 - `sudo ruby ./stop.rb` for Production

## Logging
If Sinatra runs as a service, logs are saved into `/var/log/syslog`

To see only Wallet logs, use `sudo journalctl --no-pager --since 00:00 SYSLOG_IDENTIFIER=wallet.service`

If you are running in debug mode, logs are outputted to the console.
