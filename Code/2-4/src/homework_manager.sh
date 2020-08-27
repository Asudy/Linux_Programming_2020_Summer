#!/bin/bash
# File:         homework_manager.sh
# Purpose:      A homework manager program implemented by bash script.
# Author:       Asudy Wang | 王浚哲
# Student ID:   3180103011

# 说明：
# 本程序实现简易作业管理系统，需要针对不同的用户类型（管理员、教师、学生）设计不同的操作。
# 因此程序由5个模块构成：
#       1. homework_manager.sh (Main Module)
#       2. admin.sh
#       3. teacher.sh
#       4. student.sh
#       5. password.sh (密码校验模块，因以上四个脚本都需调用其中的功能，故将其独立设计成单独的脚本文件。)
# 由此主模块进入程序主循环并调用相应模块完成对应功能。运行时需将5个文件存储在同一目录下。

# declare -x DEBUG=1  # 调试模式开关，控制程序是否清屏及打印某些错误信息

declare -x workDir=`dirname $0`;                            # 获得脚本的绝对路径
declare adminFile="$workDir/admin.sh"                       # 标识管理员功能模块脚本文件的变量（仅在本脚本中使用）
declare teacherFile="$workDir/teacher.sh"                   # 标识教师功能模块脚本文件的变量（仅在本脚本中使用）
declare studentFile="$workDir/student.sh"                   # 标识学生功能模块脚本文件的变量（仅在本脚本中使用）
declare -x checkPwdFile="$workDir/password.sh"              # 校验密码脚本
declare -x userInfoFile="$workDir/userInfo.dat"             # 存储用户数据（ID、姓名、密码）的文件
declare -x courseInfoFile="$workDir/courseInfo.dat"         # 存储课程数据、课程信息、课程作业的文件
declare -x studentCourseFile="$workDir/studentCourse.dat"   # 存储学生-课程相关数据的文件

# 如果文件缺失，报错退出
if [ ! "$DEBUG" ] ; then
if [ ! -e $adminFile -o ! -e $teacherFile -o ! -e $studentFile -o ! -e $checkPwdFile ] ; then
    echo "系统文件缺失！进入系统失败。"
    exit 1
fi
fi
chmod +x $adminFile $teacherFile $studentFile $checkPwdFile # 设置文件可执行权限

# 显示程序主菜单
show_menu() {
    echo "==================== 作业管理系统 ===================="
    echo "请选择您的用户类型："
    echo "1) 管理员     Admin"
    echo "2) 教师       Teacher"
    echo "3) 学生       Student"
    echo "0) 退出系统   Exit the system"
    echo "======================================================"
}

# 主程序（主循环），控制菜单显示、操作读取、校验密码、调用子程序
[ "$DEBUG" ] && echo "[DEBUG] Debug mode is currently ON."
[ "$DEBUG" ] || clear ; show_menu
while true ; do
    read -p "选择操作：" opCode
    [ "$DEBUG" ] || clear ; show_menu

    case $opCode in
        0)          # 退出程序
            echo -e "感谢使用！\nThanks for using!"
            sleep 1
            clear
            exit 0
            ;;
        1)          # 进入管理员菜单
            echo "请输入管理员账户：admin"
            while true ; do
                read -p "请输入管理员密码（初始密码123456，进入系统后请尽快修改密码。输入0返回上级）：" password    # 读取管理员密码
                [ "$password" == "0" ] && break
                . $checkPwdFile "admin" "$password" # 校验管理员密码
                if [ $? -eq 0 ] ; then
                    $adminFile "admin"              # 若校验成功则进入子程序，传入用户名'admin'
                    break
                else
                    [ "$DEBUG" ] || (clear ; show_menu)
                    echo "密码错误！请重新输入。"   # 若返回值非0则提示重新输入
                fi
            done
            [ "$DEBUG" ] || clear ; show_menu
            ;;
        2)          # 进入教师菜单
            while true ; do
                read -p "请输入教师账户（工号；输入0返回上级）：t" user     # 读取教师工号
                [ "$user" == "0" ] && break
                read -p "请输入教师密码（初始密码请询问管理员，进入系统后请尽快修改密码）：" password   # 读取教师密码
                . $checkPwdFile "t$user" "$password"    # 校验教师密码
                if [ $? -eq 0 ] ; then
                    $teacherFile "t$user"               # 校验成功则以't'+工号的账户进入子程序
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
                read -p "请输入学生账户（学号；输入0返回上级）：s" user     # 读取学生学号
                [ "$user" == "0" ] && break
                read -p "请输入学生密码（初始密码请询问您的教师，进入系统后请尽快修改密码）：" password     # 读取学生密码
                . $checkPwdFile "s$user" "$password"    # 校验学生密码
                if [ $? -eq 0 ] ; then
                    $studentFile "s$user"               # 校验成功则以's'+工号的账户进入子程序
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