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
    echo "    10) 查询课程信息"
    echo "布置作业相关操作："
    echo "    11) 创建作业"
    echo "    12) 修改作业"
    echo "    13) 删除作业"
    echo "    14) 显示作业列表"
    echo "    15) 查询作业"
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
    
    oldContent=`echo $sinfo | cut -d: -f2`
    oldPass=`echo $sinfo | cut -d: -f3`
    read -p "更改学生姓名（留空则保持不变）：$oldContent -> " sname
    read -p "更改学生密码（留空则保持不变）：$oldPass -> " spass
    if [ "$sname" -o "$spass" ] ; then  # 若有任一更改，更新文件
        sed -i "/^s$sid:/c\s$sid:${sname:=$oldContent}:${spass:=$oldPass}" $userInfoFile
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

# 创建课程信息，成功返回0、失败返回1。
create_course_info() {
    [ ! -e $courseInfoFile ] && echo "课程信息文件不存在，请联系管理员创建课程！" && return 1    # 检查文件是否存在
    read -p "请输入课程信息编号：m" mid     # 为方便区分，课程信息编号前缀'm'
    grep "^m$mid:" $courseInfoFile 1>/dev/null 2>&1
    if [ $? -eq 0 ] ; then              # 编号为主键，重复则报错
        echo "该编号课程信息已存在，创建失败！"
        return 1
    fi
    read -p "请设置该课程信息所属课程：c" cid
    grep -qs "^c$cid:" $courseInfoFile
    if [ $? -ne 0 ] ; then
        echo "该课程不存在，课程信息创建失败！"
        return 1
    else
        grep -qs "^c$cid:.*:$1$" $courseInfoFile
        [ $? -ne 0 ] && echo "您不是该课程的任课老师，课程信息创建失败！" && return 1
    fi
    read -p "请输入课程信息内容：" mContent
    echo "m$mid:${mContent}:c${cid}" >> $courseInfoFile # 信息编号、信息内容、课程号写入文件
    echo "课程信息 [m$mid]$mContent 添加成功，所属课程 c$cid"
    return 0
}

# 修改课程信息，成功返回0、失败返回1。
modify_course_info() {
    [ ! -e $courseInfoFile ] && echo "课程信息文件不存在，请联系管理员创建课程！" && return 1    # 检查文件是否存在
    read -p "请输入欲修改的编号：m" mid
    minfo=`grep "^m$mid:" $courseInfoFile`  # 试图从文件中找到这个课程信息的一行
    if [ -z "$minfo" ] ; then   # 若$minfo长度为0，则说明不存在这个编号，报错退出
        echo "该编号课程信息不存在，修改失败！"
        return 1
    fi
    
    oldContent=`echo $minfo | cut -d: -f2`
    oldCID=`echo $minfo | cut -d: -f3`; oldCID=${oldCID:1}
    read -p "更改所属课程（留空则保持不变）：c$oldCID -> c" cid
    grep -qs "^c$cid:.*:$1$" $courseInfoFile
    [ $? -ne 0 ] && echo "您不是该课程的任课老师，修改失败！" && return 1
    echo "更改课程信息内容（留空则保持不变）：$oldContent ->"
    read mContent
    if [ "$mContent" -o "$cid" ] ; then  # 若有任一更改，更新文件
        sed -i "/^m$mid:/c\m$mid:${mContent:=$oldContent}:c${cid:=$oldCID}" $courseInfoFile
        echo "编号 m$mid 课程信息信息修改成功！当前课程信息内容：$mContent；当前所属课程：c$cid"
    else
        echo "编号 m$mid 课程信息信息未进行任何修改"
    fi
    return 0
}

# 删除给定编号的课程信息，成功返回0、失败返回1。
delete_course_info() {
    [ ! -e $courseInfoFile ] && echo "课程信息文件不存在，请联系管理员创建课程！" && return 1    # 检查文件是否存在
    read -p "请输入欲删除的课程信息编号：m" mid
    grep -qs "^m$mid:" $courseInfoFile # 同上判断课程信息是否存在
    [ $? -ne 0 ] && echo "该编号课程信息不存在，删除失败！" && return 1
    cid=`grep "^m$mid:" $courseInfoFile | cut -d: -f3`  # cid="c####"
    tid=`grep "^$cid:" $courseInfoFile | cut -d: -f3`  # tid="t####"
    [ "$tid" != "$1" ] && echo "您不是该课程的任课老师，删除失败！" && return 1
    sed -i "/^m$mid:/d" $courseInfoFile
    echo "编号 m$mid 课程信息删除成功！"
    return 0
}

# 列出数据库中所有课程信息
list_course_info() {
    [ ! -e $courseInfoFile ] && echo "课程信息文件不存在，请联系管理员创建课程！" && return 1    # 检查文件是否存在
    grep -qs "^m" $courseInfoFile # 判断是否有记录，无记录则报错退出
    [ $? -ne 0 ] && echo "当前没有任何课程信息" && return 1
    (echo "编号:课程信息内容:所属课程号" ; grep "^m" $courseInfoFile) | column -ts: # 有记录，加上表头对齐显示输出
    return 0
}

# 根据给定的编号/课程信息名搜索课程信息
search_course_info() {
    [ ! -e $courseInfoFile ] && echo "课程信息文件不存在，请联系管理员创建课程！" && return 1    # 检查文件是否存在
    read -p "请输入课程信息查找关键字：" mContent
    grep -qs "^m.*$mContent" $courseInfoFile
    [ $? -ne 0 ] && echo "没有任何符合条件的课程信息" && return 1
    
    (echo "编号:课程信息内容:所属课程号" ; grep "^m.*$mContent" $courseInfoFile) | column -ts:

    return 0
}

# 创建课程作业，成功返回0、失败返回1。
create_assignment() {
    [ ! -e $courseInfoFile ] && echo "课程作业文件不存在，请联系管理员创建课程！" && return 1    # 检查文件是否存在
    read -p "请输入课程作业编号：a" aid     # 为方便区分，课程作业编号前缀'm'
    grep "^a$aid:" $courseInfoFile 1>/dev/null 2>&1
    if [ $? -eq 0 ] ; then              # 编号为主键，重复则报错
        echo "该编号课程作业已存在，创建失败！"
        return 1
    fi
    read -p "请设置该课程作业所属课程：c" cid
    grep -qs "^c$cid:" $courseInfoFile
    if [ $? -ne 0 ] ; then
        echo "该课程不存在，课程作业创建失败！"
        return 1
    else
        grep -qs "^c$cid:.*:$1$" $courseInfoFile
        [ $? -ne 0 ] && echo "您不是该课程的任课老师，课程作业创建失败！" && return 1
    fi
    read -p "请输入课程作业内容：" aContent
    echo "a$aid:${aContent}:c${cid}" >> $courseInfoFile # 作业编号、作业内容、课程号写入文件
    echo "课程作业 [a$aid]$aContent 添加成功，所属课程 c$cid"
    return 0
}

# 修改课程作业，成功返回0、失败返回1。
modify_assignment() {
    [ ! -e $courseInfoFile ] && echo "课程作业文件不存在，请联系管理员创建课程！" && return 1    # 检查文件是否存在
    read -p "请输入欲修改的编号：a" aid
    ainfo=`grep "^a$aid:" $courseInfoFile`  # 试图从文件中找到这个课程作业的一行
    if [ -z "$ainfo" ] ; then   # 若$ainfo长度为0，则说明不存在这个编号，报错退出
        echo "该编号课程作业不存在，修改失败！"
        return 1
    fi
    
    oldContent=`echo $ainfo | cut -d: -f2`
    oldCID=`echo $ainfo | cut -d: -f3`; oldCID=${oldCID:1}
    read -p "更改所属课程（留空则保持不变）：c$oldCID -> c" cid
    grep -qs "^c$cid:.*:$1$" $courseInfoFile
    [ $? -ne 0 ] && echo "您不是该课程的任课老师，修改失败！" && return 1
    echo "更改课程作业内容（留空则保持不变）：$oldContent ->"
    read aContent
    if [ "$aContent" -o "$cid" ] ; then  # 若有任一更改，更新文件
        sed -i "/^a$aid:/c\a$aid:${aContent:=$oldContent}:c${cid:=$oldCID}" $courseInfoFile
        echo "编号 a$aid 课程作业作业修改成功！当前课程作业内容：$aContent；当前所属课程：c$cid"
    else
        echo "编号 a$aid 课程作业作业未进行任何修改"
    fi
    return 0
}

# 删除给定编号的课程作业，成功返回0、失败返回1。
delete_assignment() {
    [ ! -e $courseInfoFile ] && echo "课程作业文件不存在，请联系管理员创建课程！" && return 1    # 检查文件是否存在
    read -p "请输入欲删除的课程作业编号：a" aid
    grep -qs "^a$aid:" $courseInfoFile # 判断课程作业是否存在
    [ $? -ne 0 ] && echo "该编号课程作业不存在，删除失败！" && return 1
    cid=`grep "^a$aid:" $courseInfoFile | cut -d: -f3`  # cid="c####"
    tid=`grep "^$cid:" $courseInfoFile | cut -d: -f3`  # tid="t####"
    [ "$tid" != "$1" ] && echo "您不是该课程的任课老师，删除失败！" && return 1
    sed -i "/^a$aid:/d" $courseInfoFile
    echo "编号 a$aid 课程作业删除成功！"
    return 0
}

# 列出数据库中所有课程作业
list_assignments() {
    [ ! -e $courseInfoFile ] && echo "课程作业文件不存在，请联系管理员创建课程！" && return 1    # 检查文件是否存在
    grep -qs "^a" $courseInfoFile # 判断是否有记录，无记录则报错退出
    [ $? -ne 0 ] && echo "当前没有任何课程作业" && return 1
    (echo "编号:作业内容:所属课程号" ; grep "^a" $courseInfoFile) | column -ts: # 有记录，加上表头对齐显示输出
    return 0
}

# 根据给定的编号/课程作业名搜索课程作业
search_assignment() {
    [ ! -e $courseInfoFile ] && echo "课程作业文件不存在，请联系管理员创建课程！" && return 1    # 检查文件是否存在
    read -p "请输入作业查找关键字：" aContent
    grep -qs "^a.*$aContent" $courseInfoFile
    [ $? -ne 0 ] && echo "没有任何符合条件的课程作业" && return 1
    
    (echo "编号:作业内容:所属课程号" ; grep "^a.*$aContent" $courseInfoFile) | column -ts:

    return 0
}

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
        1) create_student_account;;
        2) modify_student_account;;
        3) delete_student_account;;
        4) list_students; echo;;
        5) search_student; echo;;
        6) create_course_info;;
        7) modify_course_info;;
        8) delete_course_info;;
        9) list_course_info; echo;;
        10) search_course_info; echo;;
        11) create_assignment;;
        12) modify_assignment;;
        13) delete_assignment;;
        14) list_assignments; echo;;
        15) search_assignment; echo;;
        16) change_teacher_pwd $1;;
        *)          # 其它输入，报错
            echo "选择无效！请重新输入。"
            echo "Selection not accepted! Please re-enter."
            ;;
    esac
done