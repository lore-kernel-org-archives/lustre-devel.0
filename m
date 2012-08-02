From: mohammad mohammadi <m_mohammadi_dinani@yahoo.com>
Date: Thu, 2 Aug 2012 02:40:49 -0700 (PDT)
Subject: [Lustre-devel] Build lustre 1.8 on centos 5.5
Message-ID: <1343900449.20361.YahooMailNeo@web125602.mail.ne1.yahoo.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

To whom it may concerns,

I want to build?Lustre 1.8 (or 2.1 if it's possible) on CentOS 5.5 with?kernel version 2.6.18.194.el5
I follow the instructions provided on the wiki.
One of the patches (applied on?drivers/scsi/isci/init.c)?is ignored, because it can't find the file.
It also fails while running make rpm.
The?instructions?and outputs?are:

# wget http://download.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
# rpm -ivh ./epel-release-5-4.noarch.rpm
# yum -y groupinstall "Development Tools" # yum -y install rpm-build redhat-rpm-config unifdef gnupg quilt git
# useradd -d /build build
# su build
# cd $HOME
# git clone git://git.whamcloud.com/fs/lustre-release.git # cd lustre-release
# git checkout --track -b b1_8 origin/b1_8
# sh ./autogen.sh 
# cd $HOME
# mkdir -p kernel/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
# cd kernel
# echo '%_topdir %(echo $HOME)/kernel/rpmbuild' > ~/.rpmmacros
# rpm -i http://vault.centos.org/5.5/os/SRPMS/kernel-2.6.18-194.el5.src.rpm
# rpmbuild -bp --target=`uname -m` ~/kernel/rpmbuild/SPECS/kernel-2.6.spec

# cd ~/kernel/rpmbuild/BUILD/kernel-2.6.18/linux-2.6.18.x86_64
# cp ~/lustre-release/lustre/kernel_patches/kernel_configs/kernel-2.6.18-2.6-rhel5-x86_64.config .config
# ln -s ~/lustre-release/lustre/kernel_patches/series/2.6-rhel5.series series
# ln -s ~/lustre-release/lustre/kernel_patches/patches patches
# quilt push -avApplying patch patches/blkdev_tunables-2.6-rhel5.patch
patching file include/linux/blkdev.h
Hunk #1 succeeded at 783 (offset -5 lines).
patching file include/scsi/scsi_host.h can't find file to patch at input line 36 Perhaps you used the wrong -p or --strip option?
The text leading up to this was:
--------------------------
|Index: linux-2.6.18-164.11.1/drivers/scsi/isci/init.c
|===================================================================
|--- linux-2.6.18-164.11.1/drivers/scsi/isci/init.c
|+++ linux-2.6.18-164.11.1/drivers/scsi/isci/init.c
--------------------------
No file to patch.  Skipping patch. 1 out of 1 hunk ignored 


# cd /build/kernel/rpmbuild/BUILD/kernel-2.6.18/linux-2.6.18.x86_64
# make oldconfig || make menuconfig
# make include/asm
# make include/linux/version.h
# make SUBDIRS=scripts
# make include/linux/utsrelease.h
# make rpm

fs/dcache.c: In function 'd_move_locked':
fs/dcache.c:1619: error: implicit declaration of function '__d_move'
fs/dcache.c: At top level:
fs/dcache.c:1645: error: redefinition of 'd_move_locked'
fs/dcache.c:1617: error: previous definition of 'd_move_locked' was here
make[3]: *** [fs/dcache.o] Error 1
make[2]: *** [fs] Error 2
error: Bad exit status from /var/tmp/rpm-tmp.6263 (%build) RPM build errors: Bad exit status from /var/tmp/rpm-tmp.6263 (%build)
make[1]: *** [rpm] Error 1
make: *** [rpm] Error 2

I would?appreciated?it if you could help me to solve the problem.

Thanks in advance
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20120802/dcbf28ba/attachment.htm>
