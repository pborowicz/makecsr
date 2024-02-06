#! /bin/bash

## this script is called by the csr and key creation script
## by Paul Borowicz

### UNCOMMENT NEXT 2 LINES FOR DEBUGGING
#set -x
#trap read debug

#######################
### Define Variables ##
#######################
country="US"
read -e -i "$country" -p "Country: " input
country="${input:-$country}"

state="NY"
read -e -i "$state" -p "State: " input
state="${input:-$state}"

locality="New York"
read -e -i "$locality" -p "Locality: " input
locality="${input:-$locality}"

oname="Example"
read -e -i "$oname" -p "Organization Name: " input
oname="${input:-$oname}"

ounit="IT dept"
read -e -i "$ounit" -p "Local Name: " input
ounit="${input:-$ounit}"

email="support@example.com"
read -e -i "$email" -p "Email: " input
email="${input:-$email}"

#check if there is a "-h" or "--help" for help, or no $1 
if [ -z "$1"  ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
echo "This script will generate the req.cf used to generate a certificate for Navient, unix team."
echo ""
echo "Usage: $0 server name2 name3 name4  -names are optionsl"
echo ""
echo "example: $0 nunifiunx030.usa-ed.net nunifiunx030 paul_server.navient.com" 
echo "----- you can supply up to 4 extra names, navient csr request requires at least the fqdn and hostname"
echo "----- Example: ./create_csr_key.sh nunifiunx070.usa-ed.net nunifiunx070"
exit
fi


###############
# create req.cf based on these settings
# this is used to generate the cert
#############

echo '[ req ]' >req.cf  # clear req file contents
echo 'default_bits        = 4096' >>req.cf
echo 'default_md        = sha512' >> req.cf
echo 'distinguished_name  = subject' >>req.cf
echo 'req_extensions      = req_ext' >>req.cf
#echo 'string_mask         = utf8only' >>req.cf
echo 'encrypt_key           = no' >>req.cf
echo 'prompt = no' >>req.cf
echo '[ subject ]' >>req.cf
echo 'countryName             = ' ${country} >>req.cf
echo 'stateOrProvinceName        = '${state} >>req.cf
echo 'localityName                = '"${locality}" >>req.cf
echo 'organizationName  = ' "${oname}" >>req.cf
echo 'organizationalUnitName         = '"${ounit}" >>req.cf
echo 'commonName                  = '"${1}" >>req.cf
echo 'emailAddress                = '"${email}" >>req.cf
echo '[ req_ext ]' >>req.cf
echo 'subjectAltName = @alt_names' >>req.cf
echo '[ alt_names ]' >>req.cf
echo 'DNS.1 =' 	"${1}" >> req.cf
# check if there is a secondary names and add it
if [[ ! -z "${2}" ]];then echo "DNS.2 = ${2}" >>req.cf; fi
#check if there is a 3rd name and add it
if [[ ! -z "${3}" ]];then echo "DNS.3 = ${3}" >>req.cf; fi
#check if there is a 4th name and add it
if [[ ! -z "${4}" ]];then  echo "DNS.4 = ${4}" >>req.cf; fi

###################
### Openssl command to generate cert
###################
echo "generating key and csr"
openssl req -config req.cf -days 730 -new -keyout keys/$1.key -out csr/$1.csr

##########################
######### openssl command to decrypt ke
#############################
echo "unsecureing key"
openssl rsa -in keys/$1.key -out keys/$1.key.unsecure


