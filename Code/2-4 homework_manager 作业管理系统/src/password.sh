#!/bin/bash
# File:         password.sh
# Purpose:      Check if the given password matches the username, using $userInfoFile.
# Usage:        password.sh user password
# Return:       0-the pwd matches the username, 1-it doesn't match, 2-argument error.
# Author:       Asudy Wang | 王浚哲
# Student ID:   3180103011

if [ $# -ne 2 ] ; then  # 传入参数个数不对，报错返回
    echo "$0: Check password error: missing or too many arguments"
    return 2
fi

# 如果还没有用户信息文件，创建并写入管理员初始密码
[ ! -e $userInfoFile ] && echo "admin:Administrator:123456" > $userInfoFile
chmod 700 $userInfoFile     # 更改用户信息文件权限

n=`sed -ne "/^\<$1\>/{/\<$2\>$/p}" $userInfoFile | wc -l`   # 在用户信息文件中查找给出的用户名和密码，统计行数
if [ $n -eq 1 ] ; then  # 行数为1，则校验成功
    return 0
else    # 行数不为1，则校验失败
    [ "$DEBUG" ] && echo "check_pwd: User = $1, Pass = $2, Lines = $n"
    return 1
fi