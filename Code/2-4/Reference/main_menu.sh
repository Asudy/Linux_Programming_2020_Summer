#!/bin/bash
# url:  https://blog.csdn.net/lishichengyan/article/details/78193051
# url2: https://blog.csdn.net/hello_peter1/article/details/107073841 (Simpler)
#本程序由四个文件组成，以下是main_menu模块
#main_menu是主界面，通过它调用管理员、教师、学生三个模块
chmod +x admin_module #设置管理员模块为可执行
chmod +x teacher_module #设置教师模块为可执行
chmod +x student_module #设置学生模块为可执行
while true
do
	#主界面菜单如下：
	echo "================================================="
	echo "欢迎使用作业管理系统"
	echo "本系统支持三种不同的用户类型，请选择您的用户类型："
	echo "1-管理员"
	echo "2-教师"
	echo "3-学生"
	echo "0-退出本程序"
	echo "================================================="
read choice #读取用户输入，根据不同输入进入不同模块
case $choice in
	1)./admin_module;; #管理员模块独立成一个文件，此处去调用它
	2)./teacher_module;; #教师模块独立成一个文件，此处去调用它
	3)./student_module;; #学生模块独立成一个文件，此处去调用它
	0) #输入0退出程序
		clear
		echo "感谢您的使用，再见！"
		sleep 1
		exit 0;;
	*) #若是有其他输入，给出警告
		echo "只能输入0、1、2、3中的一个"
		echo "请检查您的输入！"
		sleep 2
		clear;;
esac
done