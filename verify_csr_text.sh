#!/bin/bash

##########################################
# by Paul Borowicz                       
#
# This is designed to verify a csr file
#
##########################################

#### help 
if [ "$1" = "" -o "$1" = "-h" -o "$1" = "--help" ]; then
  echo "Usage: $0 <csr_file>"
  exit
fi

openssl req -verify -text -noout -in $1 | more
