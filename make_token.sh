#!/bin/sh

#####################################################################
# usage:
#  sh make_token.sh 
# examples:
#  sh make_token.sh '{"username":"myUser","role":"myRole","minutes":1440}'
#####################################################################

resty lua/common/make_token.lua $1 $2
