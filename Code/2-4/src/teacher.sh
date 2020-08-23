#!/bin/bash
# File:         teacher.sh
# Purpose:      Teacher module of the Homework Manager.
# Author:       Asudy Wang | 王浚哲
# Student ID:   3180103011

show_teacher_menu() {
    echo "==================== 教师菜单 ===================="
    echo "学生账户相关操作："
    echo "    1)  创建学生账户"
    echo "    2)  修改学生账户"
    echo "    3)  删除学生账户"
    echo "    4)  显示学生账户"
    echo "    5)  查找学生"
    echo "课程信息相关操作："
    echo "    6)  创建课程信息"
    echo "    7)  修改课程信息"
    echo "    8)  删除课程信息"
    echo "    9)  显示课程信息列表"
    # echo "    10) 查询课程信息"
    echo "布置作业相关操作："
    echo "    11) 创建作业"
    echo "    12) 修改作业"
    echo "    13) 删除作业"
    echo "    14) 显示作业列表"
    # echo "    15) 查询作业"
    echo "账号管理："
    echo "    16) 修改密码"
    echo
    echo "    0) 返回上级菜单"
    echo "==================================================="
}

# create_student_account() {

# }

# modify_student_account() {

# }

# delete_student_account() {

# }

# list_students() {

# }

# search_student() {

# }

# create_course_info() {

# }

# modify_course_info() {

# }

# delete_course_info() {

# }

# list_course_info() {

# }

# create_assignment() {

# }

# modify_assignment() {

# }

# delete_assignment() {

# }

# list_assignments() {

# }

change_teacher_pwd() {
    read -p "原密码：" oldPass
    . $checkPwdFile "$1" "$oldPass"
    [ $? -ne 0 ] && echo "原密码错误，修改失败！" && return 1
    read -p "新密码：" newPass
    read -p "确认新密码：" newPass2
    [ "$newPass" != "$newPass2" ] && echo "两次新密码输入不一致，修改失败！" && return 1
    sed -i "/^$1:/s/$oldPass$/$newPass/" $userInfoFile
    echo "教工号 $1 教师密码修改成功！当前密码：$newPass"
    return 0
}

[ "$DEBUG" ] || clear ; show_teacher_menu
while true ; do
    read -p "选择操作：" opCode
    [ "$DEBUG" ] || clear ; show_teacher_menu

    case $opCode in
        0) exit 0;;   # 返回上级
        1) create_teacher_account;;
        2) modify_teacher_account;;
        3) delete_teacher_account;;
        4) list_teachers; echo;;
        5) search_teacher; echo;;
        6) create_course;;
        7) modify_course;;
        8) delete_course;;
        9) list_courses; echo;;
        10) search_course; echo;;
        16) change_teacher_pwd $1;;
        *)          # 其它输入，报错
            echo "选择无效！请重新输入。"
            echo "Selection not accepted! Please re-enter."
            ;;
    esac
done