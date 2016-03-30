# rpi_backup_script

#树梅派备份sd卡脚本
#2015-7-8 
#有问题询问,qq:42392
#备份出来的文件未压缩，恢复可用dd也可用ddrescue.
#ddrescue用法：ddrescue -d -D --force /home/rpi2_backup.img /dev/sd(X)
#当然，恢复后需要扩展分区，raspbian使用自带工具即可，其他系统需要手工扩展分区。
#具体实现，参照raspbian使用自带工具代码。
