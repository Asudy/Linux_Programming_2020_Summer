#!/bin/bash
# File:         myinfo.sh
# Purpose:      This script counts ordinary files, dir files & executable files and sums 
#               the size of ordinary files.
# Usage:        myinfo.sh dir_name
# Author:       Asudy Wang | 王浚哲
# Student ID:   3180103011

if [ $# -ne 1 ] # 如果输入参数不为1个，则报错
then
    echo "Usage: $0 dir_name"
    exit 1
elif [ ! -d "$1" ]  # 如果输入的参数的文件夹不存在，则报错
    then
        echo "$0: $1: No such directory"
        exit 1
else    # 进入主程序
    dirName="$1"    # 保存文件夹名字
    declare -i ordFileCnt=0 dirCnt=0 exeFileCnt=0 ordFileTotByte=0  # 初始化统计变量

    for file in $dirName/*  # 遍历所有文件
    do
        if [ -d "$file" ]   # 如果是文件夹，文件夹计数+1
        then
            dirCnt+=1
        elif [ -x "$file" ] # 如果是可执行文件，可执行文件计数+1
        then
            exeFileCnt+=1
        elif [ -f "$file" ] # 如果是普通文件，普通文件计数+1并通过 ls 命令得到文件字节数，累加
        then
            ordFileCnt+=1
            set -- `ls -l $file`
            ordFileTotByte+=$5  # 文件字节数在 ls -l 命令返回的第5个域
        fi
    done

    echo                                                    # 输出结果
    echo "---------- Info of dir: $dirName ----------"
    echo "    1) Oridinary file count:      $ordFileCnt"
    echo "    2) Oridinary file size count: ${ordFileTotByte} Byte"
    echo "    3) Directory count:           $dirCnt"
    echo "    4) Executable file count:     $exeFileCnt"
    echo

    exit 0
fi