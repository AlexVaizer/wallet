# Description
Provides a single Frontend for several sources:
- Monobank API (https://api.monobank.ua/docs/)
- Etherscan API (https://docs.etherscan.io/)

Works on Sinatra DSL (http://sinatrarb.com/)

Deployment and work is tested on Ubuntu 22.04.3 LTS hosted on AWS virtual machine with Ruby v3.0.2. See other dependencies here: https://github.com/AlexVaizer/wallet/blob/master/Gemfile
## Features
 - shows list of accounts from Monobank and Etherscan
 - shows list of transaction from Monobank and etherscan by Account ID
 - saves accounts info to the SQLite DB to minimize API calls quantity. Statements for the account are always fetched from API
## Security
 - Prod ENV is working through HTTPS protocol (HTTPS Served by NGINX, it redirects requests to local sinatra HTTP server)
 - There is a possibility to have several users with access to different accounts and different API Keys
 - Monobank and Etherscan Token and are taken from DB and are never sent anywhere except Monobank and Etherscan servers, respectively
 - JWT Auth
 - Passwords encrypted on DB level.


# Installation (For Ubuntu)
 - Install ruby v3.0.2 and other deps: `sudo apt install curl ruby-full ruby-bundler ruby-dev net-tools libsqlite3-dev sqlite3 build-essential zlib1g-dev libreadline-dev libssl-dev libcurl4-openssl-dev nginx snapd`
 - Prepare AWS credentials for Route53 DNS challenge https://certbot-dns-route53.readthedocs.io/en/stable/, save them to `/root/.aws/config` file
 - Install certbot and get SSL certificates: `sudo snap install core; sudo snap refresh core; sudo snap install --classic certbot; sudo snap install certbot-dns-route53; sudo certbot certonly --dns-route53` and copy the path where certificates are saved, you gonna need it on Service Setup step
 - Clone the repo: `git clone https://github.com/AlexVaizer/wallet.git`
 - Install dependencies: `cd ./wallet/ && bundle install`
 - Get a Monobank API Token: https://api.monobank.ua/, run clientInfo request to retrieve your Account IDs
 - Get an Etherscan API Token https://docs.etherscan.io/
 - Run service setup: `sudo ruby ./install.rb`, follow the instructions (USER-INPUT needed). This will
    - create a service file in `/etc/systemd/system/wallet.service` and
    - add nginx config to `/etc/nginx/sites-available`
    - Creates a code piece that will create some users on each server start.
 - RSA keypair for signing and verifying JWT tokens is generated on each server run, so tokens become invalid after restart.


# Run Server
## As a Service
**Service installation and run is tested on UBUNTU ONLY. If you use other operating system, run in debugging mode**

Run:
`sudo systemctl start nginx && sudo systemctl start wallet`.
Always starts with 'production' env.

If you want to run sinatra at **startup**, run `sudo systemctl enable wallet` once.

## Debugging mode or locally
Run `ruby ./install.rb` and fill all needed info, reply 'n' to question "Do you want to install service" - you'll get proper command to run the server locally.

# Stop Server
## As a service 
`sudo systemctl stop wallet && sudo systemctl stop nginx`

## In debugging mode
 - `ruby ./stop.rb` for Development, Test environments
 - `sudo ruby ./stop.rb` for Production

# Logging
If Sinatra runs as a service, logs are saved into `/var/log/syslog`

To see only Wallet logs, use `sudo journalctl --no-pager --since 00:00 SYSLOG_IDENTIFIER=wallet.service`

If you are running in debug mode, logs are outputted to the console.
