#!/bin/bash
# File:         admin.sh
# Purpose:      Student module of the Homework Manager.
# Author:       Asudy Wang | 王浚哲
# Student ID:   3180103011

# 显示学生主菜单
show_student_menu() {
    echo "欢迎您！同学 $1"
    echo "==================== 学生菜单 ===================="
    echo "查询："
    echo "    1) 查询加入的课程"
    echo "    2) 查询课程信息（公告）"
    echo "    3) 查询个人作业"
    echo "编辑作业："
    echo "    4) 编辑课程作业"
    echo "账号管理："
    echo "    5) 修改个人信息（姓名）"
    echo "    6) 修改密码"
    echo
    echo "    0) 返回上级菜单"
    echo "==================================================="
}

# 列出当前学生加入的课程
list_enrolled_courses() {
    [ -e $studentCourseFile ] && grep -qs "^$1:.*::enrolled$" $studentCourseFile    # 查询文件中是否记录了该同学加入的课程
    [ $? -ne 0 ] && echo "您未加入任何课程" && return 1

    ( 
        echo "课程号:课程名:任课教师"   # 添加表头
        # 根据$studentCourseFile查找该同学加入的所有课程号，再在$courseInfoFile中查询这些课程号对应的所有课程名、任课教师，逐行处理信息后输出
        grep "^$1:.*::enrolled$" $studentCourseFile | cut -d: -f2 | xargs -I {} grep "^{}:" $courseInfoFile | \
        while read line ; do
            tname=$(grep "^$(echo $line | cut -d: -f3):" $userInfoFile | cut -d: -f2)   # 用工号在$userInfoFile中查找教师姓名
            echo "${line/%/:$tname}" | cut -d: -f1,2,4  # 输出表内容（多个数据表进行自然连接后根据需要的顺序输出）
        done
    ) | column -ts:     # 制表输出

    return 0
}

# 列出加入课程的课程信息
list_course_info() {
    [ -e $studentCourseFile ] && grep -qs "^$1:.*::enrolled$" $studentCourseFile    # 查询文件中是否记录了该同学加入的课程
    [ $? -ne 0 ] && echo "您未加入任何课程" && return 1

    ( 
        echo "课程号:课程名:任课教师:课程信息"    # 添加表头
        # 根据$studentCourseFile查找该同学加入的所有课程号，再在$courseInfoFile中查询这些课程号对应的所有课程信息，逐行处理信息后输出
        grep "^$1:.*::enrolled$" $studentCourseFile | cut -d: -f2 | xargs -I {} grep "^m.*:{}$" $courseInfoFile | \
        while read line ; do
            cid=`echo $line | cut -d: -f3`
            mContent=`echo $line | cut -d: -f2`
            cname=`grep "^$cid:" $courseInfoFile | cut -d: -f2`
            tname=$(grep "^$(grep "^$cid:" $courseInfoFile | cut -d: -f3):" $userInfoFile | cut -d: -f2)
            echo "$cid:$cname:$tname:$mContent" # 输出表内容（多个数据表进行自然连接后根据需要的顺序输出）
        done
    ) | column -ts:     # 制表输出

    return 0
}

# 查询本人作业
list_assignments() {
    [ -e $studentCourseFile ] && grep -qs "^$1:.*:a.*:" $studentCourseFile  # 查询文件中是否记录了该同学需要完成的作业
    [ $? -ne 0 ] && echo "您目前没有任何作业" && return 1

    ( 
        echo "作业编号:课程名:作业说明:本人作业内容"                       # 添加表头
        grep "^$1:.*:a.*:" $studentCourseFile | while read line ; do    
            cid=`echo $line | cut -d: -f2`
            aid=`echo $line | cut -d: -f3`
            aContent=`echo $line | cut -d: -f4`
            cname=`grep "^$cid:" $courseInfoFile | cut -d: -f2`
            ainfo=`grep "^$aid:" $courseInfoFile | cut -d: -f2`
            echo "$aid:$cname:$ainfo:$aContent" # 输出表内容（多个数据表进行自然连接后根据需要的顺序输出）
        done
    ) | column -ts:     # 制表输出

    return 0
}

# 编辑课程作业
edit_assignment() {
    [ -e $studentCourseFile ] && grep -qs "^$1:.*:a.*:" $studentCourseFile  # 查询文件中是否记录了该同学需要完成的作业
    [ $? -ne 0 ] && echo "您目前没有任何作业" && return 1

    echo "您当前的作业有：" && list_assignments $1   # 利用上一个函数(list_assignments)列出该同学的作业
    read -p "请选择您要编辑的作业编号：a" aid
    grep -qs "^$1:.*:a$aid:" $studentCourseFile     # 确认是否有这个作业
    [ $? -ne 0 ] && echo "您没有被布置作业编号 a$aid 作业，操作失败" && return 1
    
    oldContent=`grep "^$1:.*:a$aid:" $studentCourseFile | cut -d: -f4`  # 获得旧内容并进行显示
    echo -e "旧内容：\n$oldContent"
    echo "请输入新内容（留空保持不变）："
    read newContent

    if [ "$newContent" ] ; then while true ; do     # 确认提交后才修改文件
            read -p "确认提交？(Y/n): " op
            case ${op:-Y} in
                y|yes|Y|Yes|YES)    # 确认
                    sed -i "/^$1:.*:a$aid:/s/:$oldContent$/:$newContent/" $studentCourseFile    # 修改文件错误
                    if [ $? -eq 0 ] ; then
                        echo "作业 a$aid 内容成功修改！"
                        return 0
                    else
                        [ "$DEBUG" ] && echo "sed替换错误"  # Debug信息
                        return 1
                    fi ;;
                n|no|N|No|NO)       # 取消
                    echo "作业 a$aid 内容修改已撤销"
                    return 0 ;;
                *)                  # 其它输入，报错，进入下一循环
                    echo "输入不合法，请重新选择";;
            esac
        done
    else
        echo "作业 a$aid 内容修改已撤销"
    fi

    return 0
}

# 修改学生账户姓名
change_student_info() {
    oldName=`grep "^$1:" $userInfoFile | cut -d: -f2`   # 获得旧姓名
    echo "学号 ${1:1} 同学当前姓名：$oldName"
    read -p "请输入您的新姓名（留空取消修改）：" sname
    if [ "$sname" -a "$sname" != "$oldName" ] ; then    # 新姓名与旧姓名不同才修改
        sed -i "/^$1:/s/:$oldName:/:$sname:/" $userInfoFile # 修改文件
        [ $? -eq 0 ] && echo "学号 ${1:1} 同学姓名修改成功！当前姓名：$sname"
    else
        echo "您的姓名未进行任何修改"
    fi
    return 0
}

# 修改学生账户密码
change_student_pwd() {
    read -p "原密码：" oldPass
    . $checkPwdFile "$1" "$oldPass" # 校验密码，$1为学生学号，登录后由该脚本调用者传入
    [ $? -ne 0 ] && echo "原密码错误，修改失败！" && return 1
    read -p "新密码：" newPass
    read -p "确认新密码：" newPass2
    [ "$newPass" != "$newPass2" ] && echo "两次新密码输入不一致，修改失败！" && return 1
    sed -i "/^$1:/s/$oldPass$/$newPass/" $userInfoFile  # 在文件中修改用户密码
    echo "学号 $1 同学密码修改成功！当前密码：$newPass"
    return 0
}

# 学生界面主循环
[ "$DEBUG" ] || clear ; 
userName=`grep "^$1:" $userInfoFile | cut -d: -f2`  # 得到登录学生的姓名，用于菜单显示
show_student_menu $userName
while true ; do
    read -p "选择操作：" opCode
    [ "$DEBUG" ] || clear ; show_student_menu $userName

    case $opCode in
        0) exit 0;;                         # 返回上级
        1) list_enrolled_courses $1; echo;; # 查询加入的课程
        2) list_course_info $1; echo;;      # 查询课程信息（公告）
        3) list_assignments $1; echo;;      # 查询作业
        4) edit_assignment $1;;             # 编辑作业
        5) change_student_info $1;;         # 修改个人信息
        6) change_student_pwd $1;;          # 修改密码
        *)                                  # 其它输入，报错
            echo "选择无效！请重新输入。"
            echo "Selection not accepted! Please re-enter."
            ;;
    esac
done