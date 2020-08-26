#!/bin/bash
# File:         admin.sh
# Purpose:      Administrator module of the Homework Manager.
# Author:       Asudy Wang | 王浚哲
# Student ID:   3180103011

show_admin_menu() {
    echo "==================== 管理员菜单 ===================="
    echo "教师账号相关操作："
    echo "    1) 创建教师账号"
    echo "    2) 修改教师账号"
    echo "    3) 删除教师账号"
    echo "    4) 显示教师账号"
    echo "    5) 查找教师"
    echo "课程相关操作："
    echo "    6)  创建课程"
    echo "    7)  修改课程"
    echo "    8)  删除课程"
    echo "    9)  显示课程列表"
    echo "    10) 查询课程"
    echo "账号管理："
    echo "    11) 修改密码"
    echo
    echo "    0) 返回上级菜单"
    echo "===================================================="
}

# 创建教师账号，成功返回0、失败返回1。
create_teacher_account() {
    read -p "请输入教师工号：t" tid     # 为方便区分，教师账号前缀't'
    grep "^t$tid:" $userInfoFile 1>/dev/null 2>&1
    if [ $? -eq 0 ] ; then              # 教师工号为主键，重复则报错
        echo "该工号教师已存在，创建失败！"
        return 1
    fi
    read -p "请输入教师姓名：" tname
    read -p "请设置教师初始密码：" tpass
    echo "t$tid:${tname}:${tpass:=123456}" >> $userInfoFile # 账号、姓名、密码写入文件
    echo "教师 $tname 账户创建成功，初始密码 $tpass"
    return 0
}

# 修改给定工号教师姓名/密码，成功返回0、失败返回1。
modify_teacher_account() {
    read -p "请输入欲修改的教师工号：t" tid
    tinfo=`grep "^t$tid:" $userInfoFile`  # 试图从文件中找到这个教师的一行
    if [ -z "$tinfo" ] ; then   # 若$tinfo长度为0，则说明不存在这个工号，报错退出
        echo "该工号教师不存在，修改失败！"
        return 1
    fi
    
    oldName=`echo $tinfo | cut -d: -f2`
    oldPass=`echo $tinfo | cut -d: -f3`
    read -p "更改教师姓名（留空则保持不变）：$oldName -> " tname
    read -p "更改教师密码（留空则保持不变）：$oldPass -> " tpass
    if [ "$tname" -o "$tpass" ] ; then  # 若有任一更改，更新文件
        sed -i "/^t$tid:/c\t$tid:${tname:=$oldName}:${tpass:=$oldPass}" $userInfoFile
        echo "工号 $tid 教师账户信息修改成功！当前姓名：$tname；当前密码：$tpass"
    else
        echo "工号 $tid 教师账户信息未进行任何修改"
    fi
    return 0
}

# 删除给定工号的教师，成功返回0、失败返回1。
delete_teacher_account() {
    read -p "请输入欲删除的教师工号：t" tid
    grep "^t$tid:" $userInfoFile 2>/dev/null 1>&2 # 同上判断教师是否存在
    if [ $? -ne 0 ] ; then
        echo "工号 $tid 教师不存在，删除失败！"
        return 1
    fi
    sed -i "/^t$tid:/d" $userInfoFile    # 存在则删除
    echo "工号 $tid 教师删除成功！"
    return 0
}

# 列出数据库中所有教师
list_teachers() {
    grep "^t" $userInfoFile 2>/dev/null 1>&2 # 判断是否有记录，无记录则报错退出
    [ $? -ne 0 ] && echo "当前没有任何注册的教师" && return 1
    (echo "工号:姓名:密码" ; grep "^t" $userInfoFile) | column -ts: # 有记录，加上表头对齐显示输出
    return 0
}

# 根据给定的工号/姓名搜索教师
search_teacher() {
    read -p "请输入欲查找的教师工号或姓名（留空以查找空姓名的教师）：" tname
    if [ "$tname" ] ; then
        grep -ie "^t.*$tname.*:" -ie ":.*$tname.*:" $userInfoFile 2>/dev/null 1>&2 # 判断是否有记录，无记录则报错退出
    else
        grep -qs ":$tname:" $userInfoFile
    fi
    [ $? -ne 0 ] && echo "没有任何符合条件的教师" && return 1
    
    if [ "$tname" ] ; then
        (echo "工号:姓名:密码" ; grep -e "^t.*$tname.*:" -ie ":.*$tname.*:" $userInfoFile) | column -ts: # 有记录，加上表头对齐显示输出
    else
        (echo "工号:姓名:密码" ; grep ":$tname:" $userInfoFile) | column -ts:
    fi

    return 0
}

# 创建课程，成功返回0、失败返回1。
create_course() {
    [ ! -e $courseInfoFile ] && touch $courseInfoFile   # 若不存在课程信息文件，创建之。
    read -p "请输入课程号：c" cid     # 为方便区分，课程号前缀'c'
    grep "^c$cid:" $courseInfoFile 1>/dev/null 2>&1
    if [ $? -eq 0 ] ; then              # 课程号为主键，重复则报错
        echo "该课程号课程已存在，创建失败！"
        return 1
    fi
    read -p "请输入课程名：" cname
    read -p "请设置该课程任课教师工号：t" tid
    grep -qs "^t$tid:" $userInfoFile
    [ $? -ne 0 ] && echo "该工号教师不存在，创建失败！" && return 1
    echo "c$cid:${cname}:t${tid:-t000000}" >> $courseInfoFile # 账号、姓名、密码写入文件
    echo "课程 [c$cid]$cname 添加成功，任课教师工号 t$tid"
    return 0
}

# 修改课程信息，成功返回0、失败返回1。
modify_course() {
    [ ! -e $courseInfoFile ] && echo "还未创建任何课程，请先创建课程！" && return 1    # 检查文件是否存在
    read -p "请输入欲修改的课程号：c" cid
    cinfo=`grep "^c$cid:" $courseInfoFile`  # 试图从文件中找到这个课程的一行
    if [ -z "$cinfo" ] ; then   # 若$cinfo长度为0，则说明不存在这个课程号，报错退出
        echo "该课程号不存在，修改失败！"
        return 1
    fi
    
    oldName=`echo $cinfo | cut -d: -f2`
    oldTID=`echo $cinfo | cut -d: -f3`; oldTID=${oldTID:1}
    read -p "更改课程名（留空则保持不变）：$oldName -> " cname
    read -p "更改任课教师工号（留空则保持不变）：t$oldTID -> t" tid
    if [ "$cname" -o "$tid" ] ; then  # 若有任一更改，更新文件
        sed -i "/^c$cid:/c\c$cid:${cname:=$oldName}:t${tid:=$oldTID}" $courseInfoFile
        echo "课程号 $cid 课程信息修改成功！当前课程名：$cname；当前任课教师工号：t$tid"
    else
        echo "课程号 $cid 课程信息未进行任何修改"
    fi
    return 0
}

# 删除给定课程号的课程，成功返回0、失败返回1。
delete_course() {
    [ ! -e $courseInfoFile ] && echo "还未创建任何课程，请先创建课程！" && return 1    # 检查文件是否存在
    read -p "请输入欲删除的课程课程号：c" cid
    grep -qs "^c$cid:" $courseInfoFile # 同上判断课程是否存在
    if [ $? -ne 0 ] ; then
        echo "该课程号课程不存在，删除失败！"
        return 1
    fi
    sed -i "/^c$cid:/d" $courseInfoFile    # 存在则删除
    echo "课程号 $cid 课程删除成功！"
    return 0
}

# 列出数据库中所有课程
list_courses() {
    [ ! -e $courseInfoFile ] && echo "还未创建任何课程，请先创建课程！" && return 1    # 检查文件是否存在
    grep "^c" $courseInfoFile 2>/dev/null 1>&2 # 判断是否有记录，无记录则报错退出
    [ $? -ne 0 ] && echo "当前没有任何注册的课程" && return 1
    (echo "课程号:课程名:任课教师" ; grep "^c" $courseInfoFile) | column -ts: # 有记录，加上表头对齐显示输出
    return 0
}

# 根据给定的课程号/课程名搜索课程
search_course() {
    [ ! -e $courseInfoFile ] && echo "还未创建任何课程，请先创建课程！" && return 1    # 检查文件是否存在
    read -p "请输入课程查找关键字：" cname
    grep -qs "^c.*$cname" $courseInfoFile
    [ $? -ne 0 ] && echo "没有任何符合条件的课程" && return 1
    (echo "课程号:课程名称:任课教师工号" ; grep "^c.*$cname" $courseInfoFile) | column -ts:

    return 0
}

# 修改管理员密码
change_admin_pwd() {
    read -p "原密码：" oldPass
    . $checkPwdFile "admin" "$oldPass"
    [ $? -ne 0 ] && echo "原密码错误，修改失败！" && return 1
    read -p "新密码：" newPass
    read -p "确认新密码：" newPass2
    [ "$newPass" != "$newPass2" ] && echo "两次新密码输入不一致，修改失败！" && return 1
    sed -i "/^admin:/s/$oldPass$/$newPass/" $userInfoFile
    echo "管理员密码修改成功！当前密码：$newPass"
    return 0
}

[ "$DEBUG" ] || clear ; show_admin_menu
while true ; do
    read -p "选择操作：" opCode
    [ "$DEBUG" ] || clear ; show_admin_menu

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
        11) change_admin_pwd;;
        *)          # 其它输入，报错
            echo "选择无效！请重新输入。"
            echo "Selection not accepted! Please re-enter."
            ;;
    esac
done