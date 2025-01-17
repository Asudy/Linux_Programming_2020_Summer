### Problem 2-4

用bash编写程序，实现一个简单的**作业管理系统**。可以使用*图形*和*数据库软件包*来实现，也可以用文件形式实现数据的存储。系统至少具备以下的基本功能：

系统中根据不同的权限分为三类用户：管理员、教师、学生，简要说明如下：

1. ***管理员***

   1. 创建、修改、删除、显示（list）**教师帐号**；教师帐户包括教师工号、教师姓名，教师用户以教师工号登录。
   2. 创建、修改、删除课程；绑定（包括添加、删除）**课程**与教师用户。课程名称以简单的中文或英文命名。

2. ***教师***

   1. **对某门课程**，创建或导入、修改、删除学生帐户，根据学号查找学生帐号；学生帐号的基本信息包括学号和姓名，学生使用学号登录。
   2. **发布课程信息**。包括新建、编辑、删除、显示（list）课程信息等功能。
   3. **布置作业或实验**。包括新建、编辑、删除、显示（list）作业或实验等功能。
   4. 查找、打印所有学生的**完成作业情况**。

3. ***学生***

   在教师添加学生账户后，学生就可以登录系统，并**完成作业和实验**。基本功能：新建、编辑作业或实验功能；**查询作业或实验**完成情况。

要求：

1. 用bash脚本实现上述基本功能；其它功能可根据实际情况有添加。
2. 可以用一个简单的菜单“作业管理系统”界面。	
3. 本实验题要求提供以下文档：
    1. 有需求定义或功能描述文档。题中所提供功能需求非常简单，把这些需求详细化，允许你扩展和改变。
    2. 设计文档，包括设计思想、功能模块、数据结构、算法等
    3. 源程序。详细的注释和良好编程风格。
