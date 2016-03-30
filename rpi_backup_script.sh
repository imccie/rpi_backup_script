#/bin/bash


#树梅派备份sd卡脚本
#2015-7-8 
#有问题询问,qq:42392
#备份出来的文件未压缩，恢复可用dd也可用ddrescue.
#ddrescue用法：ddrescue -d -D --force /home/rpi2_backup.img /dev/sd(X)
#当然，恢复后需要扩展分区，raspbian使用自带工具即可，其他系统需要手工扩展分区。
#具体实现，参照raspbian使用自带工具代码。

if [[ $# -eq 0 ]] ; then
    echo "Please enter sd card device info, e.g. /dev/sdb or sdb"
    exit 0
fi

basedir=/home
rootdev="$1"2
bootdev="$1"1
size=`df -B MB --output=source,target,used | grep $rootdev | awk '{print $3}' | awk -F "MB" '{print $1}'`
org_bootp=`df --output=source,target | grep $bootdev | awk '{print $2}'`
org_rootp=`df --output=source,target | grep $rootdev | awk '{print $2}'`

if [[ $org_bootp == "" ]] ; then
    echo "boot target not found "
    exit 0
fi
if [[ $org_rootp == "" ]] ; then
    echo "root target not found "
    exit 0
fi
if [[ $size == "" ]] ; then
    echo "size was zero? "
    exit 0
fi

#echo $org_bootp
#echo $org_rootp

let size+=600
# Create the disk and partition it
echo "Creating image file for Raspberry Pi2 FileSystem Backup!"
dd if=/dev/zero of=${basedir}/rpi2_backup.img bs=1M count=$size
parted ${basedir}/rpi2_backup.img --script -- mklabel msdos
parted ${basedir}/rpi2_backup.img --script -- mkpart primary fat32 0 64
parted ${basedir}/rpi2_backup.img --script -- mkpart primary ext4 64 -1

# Set the partition variables
loopdevice=`losetup -f --show ${basedir}/rpi2_backup.img`
device=`kpartx -va $loopdevice| sed -E 's/.*(loop[0-9])p.*/\1/g' | head -1`
device="/dev/mapper/${device}"
bootp=${device}p1
rootp=${device}p2

echo "Please Wait a moment..."
sleep 5
# Create file systems
mkfs.vfat $bootp
mkfs.ext4 $rootp

mkdir -p ${basedir}/bootp ${basedir}/root
mount $bootp ${basedir}/bootp
mount $rootp ${basedir}/root

chktempdir=`mount | grep ${basedir}/root `

if [[ $chktempdir == "" ]] ; then
echo "error , no partition mounted."
kpartx -dv $loopdevice
losetup -d $loopdevice
exit 0
fi

echo "Rsyncing Boot files into image file"
rsync -HPavz -q ${org_bootp}/ ${basedir}/bootp/

echo "Rsyncing rootfs into image file"
rsync -HPavz -q ${org_rootp}/ ${basedir}/root/

sync

sleep 10

umount $bootp
umount $rootp
kpartx -dv $loopdevice
losetup -d $loopdevice

rm -R ${basedir}/bootp
rm -R ${basedir}/root




echo "done!"


