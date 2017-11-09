From: Oleg Drokin <oleg.drokin@intel.com>
Date: Thu, 9 Nov 2017 14:53:44 -0500
Subject: [lustre-devel] New tag 2.10.55
Message-ID: <AC167227-4CAD-41FD-96E5-3032B3DF15FE@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I tagged a new tag 2.10.55 in the Lustre master community development branch yesterday

   Here?s the changelog.

Alex Zhuravlev (4):
      LU-9660 ptlrpc: do not wakeup every second
      LU-9578 llite: use security context if it's enabled in the kernel
      LU-10041 osd: osd-zfs to choose dnode size
      LU-7251 osp: do not assign commit callback to every thandle

Alexander Boyko (4):
      LU-8344 test: fix sanity 256
      LU-4134 obdclass: obd_device improvement
      LU-8475 target: use slab allocation
      LU-10015 o2iblnd: fix race at kiblnd_connect_peer

Alexey Lyashkov (1):
      LU-9782 osd-ldiskfs: avoid extra search

Amir Shehata (2):
      LU-9990 lnet: add backwards compatibility for YAML config
      LU-10089 o2iblnd: use IB_MR_TYPE_SG_GAPS

Andreas Dilger (9):
      LU-9462 doc: update lfs setstripe man page and usage
      LU-4923 osd-ldiskfs: dirdata is not needed on MGS
      LU-7990 llite: increase whole-file readahead to RPC size
      LU-9452 ldlm: remove MSG_CONNECT_LIBCLIENT support
      LU-4705 mdc: improve mdc_enqueue() error message
      LU-10046 misc: replace LASSERT() with CLASSERT()
      LU-9611 lov: allow lov.*.stripe{size,count}=-1 param
      LU-7813 lov: rename LOV_MAGIC_V*_DEF to *_DEFINED
      LU-8174 mdt: remove use of typedef mds_reint_t

Ben Evans (1):
      LU-7988 hsm: wake up cdt when requests are empty

Bob Glossman (6):
      LU-10047 tests: stop skipping test_102 subtests
      LU-9469 ldiskfs: add additional attach_jinode call
      LU-9956 kernel: kernel upgrade [SLES12 SP3 4.4.82-6.3]
      LU-10023 kernel: kernel update [SLES12 SP3 4.4.82-6.9]
      LU-10142 kernel: kernel update RHEL7.4 [3.10.0-693.5.2.el7]
      LU-10164 kernel: kernel update [SLES12 SP3 4.4.92-6.18]

Bruno Faccini (1):
      LU-9994 obdclass: fix llog_cat_id2handle() error handling

Chris Horn (1):
      LU-10119 scripts: Correct shebang/hashpling format

Elena Gryaznova (1):
      LU-8721 tests: add parallel-scale fio test

Gu Zheng (1):
      LU-9951 lustre_compat: add wrapper function for posix_acl_update_mode

Henri Doreau (2):
      LU-9416 hsm: add kkuc before sending registration RPCs
      LU-10141 llapi: integer overflow in llapi_changelog_start

James Nunez (5):
      LU-9741 test: Correct check of stripe count for directories
      LU-9860 tests: Run command on MGS for conf-sanity 33a
      LU-9968 tests: correct stripe index sanity 300g
      LU-10101 tests: correct sanity-quota call to quota_error
      LU-10152 tests: reformat after conf-sanity test 99

James Simmons (4):
      LU-9019 ofd: migrate to 64 bit time
      LU-9897 utils: remove libcfsutils.a and libptlctl.a
      LU-8066 obd: migrate to ksets
      LU-9019 ldlm: migrate the rest of the code to 64 bit time

Jan Kara (1):
      LU-9558 llite: port lustre to unified handling of bdi

John L. Hammond (4):
      LU-9983 ko2iblnd: allow for discontiguous fragments
      LU-9405 utils: remove device path parsing from mount.lustre
      LU-10132 llite: handle xattr cache refill race
      LU-10086 libcfs: use dynamic minors for /dev/{lnet,obd}

Nathaniel Clark (5):
      LU-10051 build: Build with ZFS 0.7.2
      LU-9752 man: Reference zgenhostid instead of genhostid
      LU-10098 scripts: Fix mounted check in Lustre RA
      LU-10007 pacemaker: Use lctl and load lustre
      LU-10150 build: Build with ZFS 0.7.3

Oleg Drokin (1):
      New tag 2.10.55

Patrick Farrell (1):
      LU-10131 llite: Update i_nlink on unlink

Qian Yingjin (1):
      LU-9140 nrs: measure the runtime of dd directly

Sebastien Buisson (2):
      LU-9672 gss: fix expiration time of sunrpc cache
      LU-9946 nodemap: have fileset on default nodemap.

Steve Guminski (3):
      LU-5170 lfs: Standardize error messages in lfs_setstripe()
      LU-6051 utils: allow lfs_migrate to handle hard links
      LU-10199 utils: disable sanity test 56xb

Wang Shilong (1):
      LU-10029 osd-ldiskfs: make project inherit attr removeable

Wei Liu (1):
      LU-9158 test: Use project ID for project quota for quota_scan

Yang Sheng (2):
      LU-9908 tests: force umount client in test 70e, 41b, and 105
      LU-9814 ldiskfs: restore simple_strtol in prealloc

dilip krishnagiri (1):
      LU-9590 tests: remove replay-single tests from ALWAYS_EXCEPT
