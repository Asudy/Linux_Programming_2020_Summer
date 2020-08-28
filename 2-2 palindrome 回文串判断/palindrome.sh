#!/bin/bash
# File:         palindrome.sh
# Purpose:      This script checks if the given word is a palindrome.
# Usage:        palindrome.sh word_to_check
# Author:       Asudy Wang | 王浚哲
# Student ID:   3180103011

if [ $# -ne 1 ] # 如果输入参数不为1个，报错
then
    if [ $# -lt 1 ]; then
        echo -n "Missing argument! "
    elif [ $# -gt 1 ]; then
        echo -n "Too many arguments! "
    fi
    echo "Usage: $0 word_to_check"  # 提示正确用法
    exit 1
fi

str=${1//[!a-zA-Z]}         # 仅保留字母字符
revstr=`echo $str | rev`    # 生成字符串的倒序字符串

# 如果原字符串=倒序字符串，输出“是”，否则输出“否”
[ "$str" = "$revstr" ] && echo "Word \"$str\" is a palindrome." || echo "Word \"$str\" is not a palindrome."