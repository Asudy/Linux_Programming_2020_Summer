#!/bin/bash
# File:         password.sh
# Purpose:      Check if the given password matches the username, using $userInfoFile.
# Usage:        password.sh user password
# Return:       0-the pwd matches the username, 1-it doesn't match, 2-argument error.
# Author:       Asudy Wang | 王浚哲
# Student ID:   3180103011

if [ $# -ne 2 ] ; then
    echo "$0: Check password error: missing or too many arguments"
    return 2
fi

[ ! -e $userInfoFile ] && echo "admin:Administrator:123456" > $userInfoFile
chmod 700 $userInfoFile

n=`sed -ne "/^\<$1\>/{/\<$2\>$/p}" $userInfoFile | wc -l`
if [ $n -eq 1 ] ; then
    return 0
else
    [ "$DEBUG" ] && echo "check_pwd: Lines = $n"
    return 1
fi