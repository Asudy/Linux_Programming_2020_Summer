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

# 创建学生账号，成功返回0、失败返回1。
create_student_account() {
    read -p "请输入学生学号：s" sid     # 为方便区分，学生账号前缀's'
    grep "^s$sid:" $userInfoFile 1>/dev/null 2>&1
    if [ $? -eq 0 ] ; then              # 学生学号为主键，重复则报错
        echo "该学号学生已存在，创建失败！"
        return 1
    fi
    read -p "请输入学生姓名：" sname
    read -p "请设置学生初始密码：" spass
    echo "s$sid:${sname}:${spass:=123456}" >> $userInfoFile # 账号、姓名、密码写入文件
    echo "学生 $sname 账户创建成功，初始密码 $spass"
    return 0
}

# 修改给定学号学生姓名/密码，成功返回0、失败返回1。
modify_student_account() {
    read -p "请输入欲修改的学生学号：s" sid
    sinfo=`grep "^s$sid:" $userInfoFile`  # 试图从文件中找到这个学生的一行
    if [ -z "$tinfo" ] ; then   # 若$tinfo长度为0，则说明不存在这个学号，报错退出
        echo "该学号学生不存在，修改失败！"
        return 1
    fi
    
    oldName=`echo $sinfo | cut -d: -f2`
    oldPass=`echo $sinfo | cut -d: -f3`
    read -p "更改学生姓名（留空则保持不变）：$oldName -> " sname
    read -p "更改学生密码（留空则保持不变）：$oldPass -> " spass
    if [ "$sname" -o "$spass" ] ; then  # 若有任一更改，更新文件
        sed -i "/^s$sid:/c\s$sid:${sname:=$oldName}:${spass:=$oldPass}" $userInfoFile
        echo "学号 $sid 学生账户信息修改成功！当前姓名：$sname；当前密码：$spass"
    else
        echo "学号 $sid 学生账户信息未进行任何修改"
    fi
    return 0
}

# 删除给定学号的学生，成功返回0、失败返回1。
delete_student_account() {
    read -p "请输入欲删除的学生学号：s" sid
    grep "^s$sid:" $userInfoFile 2>/dev/null 1>&2 # 同上判断学生是否存在
    if [ $? -ne 0 ] ; then
        echo "学号 $sid 学生不存在，删除失败！"
        return 1
    fi
    sed -i "/^s$sid:/d" $userInfoFile    # 存在则删除
    echo "学号 $sid 学生删除成功！"
    return 0
}

# 列出数据库中所有学生
list_students() {
    grep "^s" $userInfoFile 2>/dev/null 1>&2 # 判断是否有记录，无记录则报错退出
    [ $? -ne 0 ] && echo "当前没有任何注册的学生" && return 1
    (echo "学号:姓名:密码" ; grep "^s" $userInfoFile) | column -ts: # 有记录，加上表头对齐显示输出
    return 0
}

# 根据给定的学号/姓名搜索学生
search_student() {
    read -p "请输入欲查找的学生学号或姓名（留空以查找空姓名的学生）：" sname
    if [ "$sname" ] ; then
        grep -ie "^s.*$sname.*:" -ie ":.*$sname.*:" $userInfoFile 2>/dev/null 1>&2 # 判断是否有记录，无记录则报错退出
    else
        grep -qs ":$sname:" $userInfoFile
    fi
    [ $? -ne 0 ] && echo "没有任何符合条件的学生" && return 1
    
    if [ "$sname" ] ; then
        (echo "学号:姓名:密码" ; grep -e "^s.*$sname.*:" -ie ":.*$sname.*:" $userInfoFile) | column -ts: # 有记录，加上表头对齐显示输出
    else
        (echo "学号:姓名:密码" ; grep ":$sname:" $userInfoFile) | column -ts:
    fi

    return 0
}

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