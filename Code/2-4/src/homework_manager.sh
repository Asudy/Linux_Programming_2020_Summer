#!/bin/bash
# File:         homework_manager.sh
# Purpose:      A homework manager program implemented by bash script.
# Author:       Asudy Wang | 王浚哲
# Student ID:   3180103011

# 说明：
# 本程序实现作业管理系统，需要针对不同的用户类型（管理员、教师、学生）设计不同的操作。
# 因此程序由4个模块构成：
#       1. homework_manager.sh (Main Module)
#       2. admin
#       3. teacher
#       4. student
# 由此主模块进入程序主循环并调用相应模块完成对应功能。运行时需将4个文件存储在同一目录下。

declare -x DEBUG=1

declare -x workDir=`dirname $0`;
declare adminFile="$workDir/admin.sh"
declare teacherFile="$workDir/teacher.sh"
declare studentFile="$workDir/student.sh"
declare -x checkPwdFile="$workDir/password.sh"      # 校验密码程序
declare -x userInfoFile="$workDir/userInfo.dat"     # 存储用户数据（ID、姓名、密码）的文件
declare -x courseInfoFile="$workDir/courseInfo.dat" # 存储课程数据（ID、课程名、授课教师）的文件
declare -x SLEEPINTERVAL=1

# 如果文件缺失，报错退出
if [ ! "$DEBUG" ] ; then
if [ ! -e $adminFile -o ! -e $teacherFile -o ! -e $studentFile -o ! -e $checkPwdFile ] ; then
    echo "系统文件缺失！进入系统失败。"
    exit 1
fi
fi
chmod +x $adminFile $teacherFile $studentFile   # 设置文件可执行权限

show_menu() {
    echo "==================== 作业管理系统 ===================="
    echo "请选择您的用户类型："
    echo "1) 管理员     Admin"
    echo "2) 教师       Teacher"
    echo "3) 学生       Student"
    echo "0) 退出系统   Exit the system"
    echo "======================================================"
}

# Purpose:  Check if the given password matches the username, using $userInfoFile.
# Usage:    check_pwd user password
# Return:   0-the pwd matches the username, 1-it doesn't match, 2-argument error.
# check_pwd() {
#     if [ $# -ne 2 ] ; then
#         echo "$0: Check password error: missing or too many arguments"
#         return 2
#     fi

#     [ ! -e $userInfoFile ] && echo "admin Administrator 123456" > $userInfoFile
#     chmod 700 $userInfoFile

#     n=`sed -ne "/^\<$1\>/{/\<$2\>$/p}" $userInfoFile | wc -l`
#     if [ $n -eq 1 ] ; then
#         return 0
#     else
#         [ "$DEBUG" ] && echo "check_pwd: Lines = $n"
#         return 1
#     fi
# }

# 主程序（主循环）
[ "$DEBUG" ] || clear ; show_menu
while true ; do
    read -p "选择操作：" opCode
    [ "$DEBUG" ] || clear ; show_menu

    case $opCode in
        0)          # 退出程序
            echo -e "感谢使用！\nThanks for using!"
            sleep $SLEEPINTERVAL
            clear
            exit 0
            ;;
        1)          # 进入管理员菜单
            echo "请输入管理员账户：admin"
            while true ; do
                read -p "请输入管理员密码（初始密码123456，进入系统后请尽快修改密码。输入0返回上级）：" password
                [ "$password" == "0" ] && break
                . $checkPwdFile "admin" "$password"
                if [ $? -eq 0 ] ; then
                    $adminFile "admin"
                    break
                else
                    [ "$DEBUG" ] || (clear ; show_menu)
                    echo "密码错误！请重新输入。"
                fi
            done
            [ "$DEBUG" ] || clear ; show_menu
            ;;
        2)          # 进入教师菜单
            while true ; do
                read -p "请输入教师账户（工号；输入0返回上级）：" user
                [ "$user" == "0" ] && break
                read -p "请输入教师密码（初始密码请询问管理员，进入系统后请尽快修改密码）：" password
                . $checkPwdFile "t$user" "$password"
                if [ $? -eq 0 ] ; then
                    $teacherFile "t$user"
                    break
                else
                    [ "$DEBUG" ] || (clear ; show_menu)
                    echo "用户名或密码错误！请重新输入。"
                fi
            done
            [ "$DEBUG" ] || clear ; show_menu
            ;;
        3)          # 进入学生菜单
            while true ; do
                read -p "请输入学生账户（学号；输入0返回上级）：" user
                [ "$user" == "0" ] && break
                read -p "请输入学生密码（初始密码请询问您的教师，进入系统后请尽快修改密码）：" password
                . $checkPwdFile "s$user" "$password"
                if [ $? -eq 0 ] ; then
                    $studentFile "s$user"
                    break
                else
                    [ "$DEBUG" ] || (clear ; show_menu)
                    echo "用户名或密码错误！请重新输入。"
                fi
            done
            [ "$DEBUG" ] || clear ; show_menu
            ;;
        *)          # 其它输入，报错
            echo "选择无效！请重新输入。"
            echo "Selection not accepted! Please re-enter."
            ;;
    esac
done