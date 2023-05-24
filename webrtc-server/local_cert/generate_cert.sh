#!/bin/bash

openssl req -x509 -newkey rsa:4096 -keyout fullchain.pem -out privkey.pem -days 365 -nodes
