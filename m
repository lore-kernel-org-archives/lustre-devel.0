From: Oleg Drokin <oleg.drokin@intel.com>
Date: Tue, 22 Aug 2017 12:10:45 -0400
Subject: [lustre-devel] new tag 2.10.52
Message-ID: <1BBE5547-428A-413F-9B0F-6CF04EC1EE60@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just tagged 2.10.52 in master development branch of Lustre community tree.

   Here's the changelog:

Alex Zhuravlev (1):
      LU-7899 osd: batch EA updates

Amir Shehata (1):
      LU-9817 lnet: safe access to msg

Andreas Dilger (1):
      LU-8619 lbuild: update ZFS to use 0.7.1

Andriy Skulysh (1):
      LU-8578 ldlm: ELC shouldn't wait on lock flush

Bob Glossman (2):
      LU-9712 kernel: correct malformed ChangeLog
      LU-9816 kernel: kernel upgrade RHEL7.4 [3.10.0-693.el7]

Brian J. Murrell (2):
      LU-9731 Limit work-around to EL7 only
      LU-9850 patchless client should conflict patched kernel

Bruno Faccini (1):
      LU-9744 mdt: avoid wrong CLF_HSM_DIRTY report in ChangeLog

Chris Hanna (1):
      LU-8275 tests: add flag to enable secret shared key for tests

Deepa Dinamani (1):
      LU-9558 kernel: replace CURRENT_TIME macro

Dmitry Eremin (1):
      LU-8066 libcfs: migrate to debugfs

Elena Gryaznova (1):
      LU-8618 tests: ha.sh improvements

Emoly Liu (1):
      LU-9376 tests: remove sanity.sh test_103b

Fan Yong (1):
      LU-9499 lfsck: set target bitmap properly

Hongchao Zhang (2):
      LU-9364 test: wait rmultiop_start to start
      LU-9235 libcfs: don't dump stack if just touched

James Nunez (4):
      LU-9826 tests: Do not run conf-sanity 32b with ZFS
      LU-9295 test: skip sanity-lfsck 9 less than 2.8
      LU-9887 tests: ignore error sanity-lfsck test 9a,b
      LU-9888 tests: Do not run conf-sanity 32b with ZFS

James Simmons (9):
      LU-7356 build: handle configure options for mount plugin
      LU-9019 mgs: migrate to 64 bit time
      LU-6142 socklnd: remove typedefs from ksocklnd
      LU-9758 build: allow disabling lustre test and iokit rpm creation
      LU-8958 llite: remove llite_loop left overs
      LU-6245 uapi: move libcfs/lnet UAPI header into own uapi directory
      LU-6245 tests: remove it_test
      LU-6401 uapi: migrate remaining uapi headers to uapi directory
      LU-8066 obd: fix LPROC_SEQ_FOPS macros for debugfs

Jinshan Xiong (2):
      LU-9054 tests: disable test_312 due to zdb issue
      LU-8999 quota: fix quota iteration interface

Lai Siyao (2):
      LU-9748 lod: safely access update log stat
      LU-9725 quota: always deregister lwp

Nathaniel Clark (2):
      LU-9799 mount: Call read_ldd with initialized mount type
      LU-9745 dkms: Fix included dkms.conf file

Oleg Drokin (3):
      LU-9829 lnet: Properly dereference string pointer
      LU-9832 tests: Use sys/sysmacros.h for major/minor/makedev
      New tag 2.10.52

Ruth A Klundt (1):
      LU-9494 test: Improve message for skipping tests

Sergey Cheremencev (1):
      LU-9266 hsm: don't add request when cdt is stopped

Steve Guminski (3):
      LU-6210 utils: Use C99 initializer in jt_nodemap_test_id()
      LU-6210 utils: Use C99 initializer in jt_nodemap_del_range()
      LU-6210 utils: Use C99 struct initializers in lsnapshot

Wang Shilong (1):
      LU-9597 ofd: fix race for project setattr

Wei Liu (1):
      LU-9826 test: Recreate disk2_7-zfs image to have a bigger file system

dilip krishnagiri (1):
      LU-9012 contrib: to rename file ending with :rhel5.ed
