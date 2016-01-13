#!/usr/bin/env bash
#Configure and download debian based systems and so they can support qemu

USE_APTITUDE_INSTEAD_OF_APTGET=1

APT_INSTALLER_STRING=apt-get
if [ "$USE_APTITUDE_INSTEAD_OF_APTGET" == 1 ]
then
  APT_INSTALLER_STRING=aptitude
fi

#sudo "$APT_INSTALLER_STRING" update
sudo "$APT_INSTALLER_STRING" install qemu qemu-user-static binfmt-support

qemu_arm_interpreter=$(update-binfmts --display | grep -EA 7 "^qemu-arm[ \t]+\([a-zA-Z]+\):" | grep interpreter | sed 's/^.\+=[ \t]\+//')

wget --content-disposition -N https://downloads.raspberrypi.org/raspbian_lite_latest
rm -vf $(ls *-raspbian-*.zip | sort -n | head -n-1)
unzip -vuo -d . *-raspbian-*.zip
rm -vf $(ls *-raspbian-*.img | sort -n | head -n-1)
cp -vuf *-raspbian-*.img ./raspbian_lite_latest.img
cp -vf ./raspbian_lite_latest.img ./raspbian_lite_latest.MODIFIED.img
dd if=/dev/zero bs=1M count=1024 >> raspbian_lite_latest.MODIFIED.img
parted -s raspbian_lite_latest.MODIFIED.img print
diskEnd=$(parted -s raspbian_lite_latest.MODIFIED.img print | grep -E "^Disk[ \t]+[^:]+:[ \t][0-9]+MB$" | sed 's/^Disk[ \t]\+[^:]\+:[ \t]\([0-9]\+\)MB$/\1/')
part2Start=$(parted -s raspbian_lite_latest.MODIFIED.img print | grep -EA 2 "^Number[ \t]+" | tail -n 1 | sed 's/^[ \t]\+2//' | sed 's/[ \t]\+/ /g' | cut -f 2 -d " " | sed 's/MB$//')
sectorSize=$(parted -s raspbian_lite_latest.MODIFIED.img print | grep -E "^Sector[ \t]+size[ \t]+\(logical/physical\):[ \t]+[0-9]+B/[0-9]+B$" | sed 's/^Sector[ \t]\+size[ \t]\+(logical\/physical):[ \t]\+[0-9]\+B\/\([0-9]\+\)B$/\1/')
bootStartSector=$(fdisk -lu raspbian_lite_latest.MODIFIED.img | tail -n 2 | head -n 1 | sed 's/[ \t]\+/ /g' | cut -f 2 -d " ")
part2StartSector=$(fdisk -lu raspbian_lite_latest.MODIFIED.img | tail -n 1 | sed 's/[ \t]\+/ /g' | cut -f 2 -d " ")
echo part2Start "$part2Start" diskEnd "$diskEnd" sectorSize "$sectorSize" bootStartSector "$bootStartSector" part2StartSector "$part2StartSector"
parted -s raspbian_lite_latest.MODIFIED.img rm 2
parted -s raspbian_lite_latest.MODIFIED.img mkpart primary "$part2Start" "$diskEnd"
#parted -s raspbian_lite_latest.MODIFIED.img resize 2 "$part2Start" "$diskEnd"
parted -s raspbian_lite_latest.MODIFIED.img print
created_loopback_device=$(sudo losetup -f --show -o $(($part2StartSector*$sectorSize)) raspbian_lite_latest.MODIFIED.img)
valid_loopback_device=$(echo "$created_loopback_device" | grep -E "^/dev/loop[0-9]+$")
if [ ! "$valid_loopback_device" == "" ]
then
	sudo e2fsck -fp "$created_loopback_device"
	sudo resize2fs "$created_loopback_device"

	sudo losetup -d "$created_loopback_device"
fi

#CREATE SCRIPT THAT WILL PERFORM OPERATIONS WITHIN CHROOT
echo "#/usr/bin/env sh" > OPERATIONS_WITHIN_CHROOT.sh
echo >> OPERATIONS_WITHIN_CHROOT.sh
echo "uname -a" >> OPERATIONS_WITHIN_CHROOT.sh
echo "locale-gen" >> OPERATIONS_WITHIN_CHROOT.sh
echo "locale -a" >> OPERATIONS_WITHIN_CHROOT.sh
echo "apt-get -y install aptitude" >> OPERATIONS_WITHIN_CHROOT.sh
echo "aptitude -y update" >> OPERATIONS_WITHIN_CHROOT.sh
echo "aptitude -y upgrade" >> OPERATIONS_WITHIN_CHROOT.sh
echo "aptitude -y dist-upgrade" >> OPERATIONS_WITHIN_CHROOT.sh
echo "aptitude -y install openssh-server openvpn dante-server" >> OPERATIONS_WITHIN_CHROOT.sh
echo >> OPERATIONS_WITHIN_CHROOT.sh
echo "sync" >> OPERATIONS_WITHIN_CHROOT.sh
echo "sleep 1" >> OPERATIONS_WITHIN_CHROOT.sh
echo "sync" >> OPERATIONS_WITHIN_CHROOT.sh
echo "exit" >> OPERATIONS_WITHIN_CHROOT.sh

echo "LANG=\"en_US.ISO-8859-15\"" > default_locale
> blank_file
mkdir ./rpi_mnt
sudo mount raspbian_lite_latest.MODIFIED.img -o loop,offset=$(($part2StartSector*$sectorSize)),rw ./rpi_mnt
sudo mount raspbian_lite_latest.MODIFIED.img -o loop,offset=$(($bootStartSector*$sectorSize)),rw ./rpi_mnt/boot
cd ./rpi_mnt
sudo mount --bind /dev dev/
sudo mount --bind /sys sys/
sudo mount --bind /proc proc/
sudo mount --bind /dev/pts dev/pts

sudo cp -vf "$qemu_arm_interpreter" usr/bin/
sudo mv -vf etc/ld.so.preload{,.ORIGINAL}
sudo cp -vf ../blank_file etc/ld.so.preload
sudo cp -vf ../default_locale etc/default/locale
sudo cp -vf etc/locale.gen ../locale.gen
sudo chmod a+rw ../locale.gen
cat ../locale.gen | sed 's/[ \t]*#[ \t]*en_US/en_US/' > ../locale.gen.NEW
sudo cp -vf ../locale.gen.NEW etc/locale.gen
sudo cp -vf ../OPERATIONS_WITHIN_CHROOT.sh root/
sudo sync
sleep 1
sudo sync

sudo chroot . bin/sh /root/OPERATIONS_WITHIN_CHROOT.sh
sudo sync
sleep 1
sudo sync

sudo mv -vf etc/ld.so.preload{.ORIGINAL,}
sudo sync
sleep 10

sudo umount -f dev/pts
sudo umount -f proc
sudo umount -f sys
sudo umount -f dev
cd ..
sudo umount -f ./rpi_mnt/boot
sudo umount -f ./rpi_mnt

sudo chmod a+rw ./*


