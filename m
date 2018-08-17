From: Oleg Drokin <green@whamcloud.com>
Date: Fri, 17 Aug 2018 20:24:57 +0000
Subject: [lustre-devel] New tag 2.11.54
Message-ID: <88C7E25C-EB5E-497C-91F0-547162BC7831@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

  I just tagged 2.11.54 in the Lustre community master branch.

  Here?s the changelog:

Alex Zhuravlev (1):
      LU-10928 tests: sanity/133b should wait a bit

Alexander Boyko (2):
      LU-11156 scrub: skip project quota inode
      LU-11186 ofd: fix for a final oid at sequence

Andreas Dilger (4):
      LU-11147 llite: add newline to llite.*.offset_stats
      LU-10254 tests: fix racer version checks
      LU-9538 utils: fix lfs xattr.h header usage
      LU-1895 tests: don't fail mmp test_5 due to race

Arshad Hussain (3):
      LU-11087 osd-ldiskfs: Fix style issues for osd_compat.c
      LU-11094 osd-ldiskfs: Fix style issues for osd_quota.c
      LU-6142 obdclass: Fix style issues for obdo_server.c

Bobi Jam (7):
      LU-8708 osc: depart grant shrinking from pinger
      LU-11022 lfs: accept specifing comp_id in mirror split
      LU-11138 lfs: getstripe display certain mirror(s)
      LU-9007 lod: improve obj alloc for FLR file
      LU-10916 lfs: improve lfs mirror resync
      LU-11127 test: sanity-flr OST not recovery fast enough
      LU-9007 lod: get rid of comp ost in use array

Fan Yong (1):
      LU-10288 lfsck: layout LFSCK for mirrored file

Hongchao Zhang (4):
      LU-10683 osd_zfs: set offset in page correctly
      LU-11141 quota: reset adjust schedule when updating lqe
      LU-11174 quota: use sync io to test quota
      LU-11153 quota: initialize ver for default quota

James Nunez (7):
      LU-5638 tests: resume running sanity-quota tests
      LU-11010 tests: remove calls to return after skip()
      LU-11141 tests: put sanity-quota 61 on slow list
      LU-11166 tests: remove use of /proc/fs/jbd2/*/history file
      LU-7372 tests: stop running replay-dual test 26
      LU-11171 tests: set parameters for racer_on_nfs
      LU-10940 tests: skip sanity test 802 when quota enabled

James Simmons (10):
      LU-8066 osp: migrate from proc to sysfs
      LU-6142 ko2iblnd: remove typedefs from ko2iblnd
      LU-8066 llite: move /proc/fs/lustre/llite/blocksize to sysfs
      LU-8066 llite: move /proc/fs/lustre/llite/kbytes* to sysfs
      LU-8066 llite: move /proc/fs/lustre/llite/files* to sysfs
      LU-8066 llite: move /proc/fs/lustre/llite/client_type to sysfs
      LU-8066 llite: move /proc/fs/lustre/llite/fstype to sysfs
      LU-10947 build: test if xfsprogs are installed
      LU-10627 tests: don't use libtool wrapper for applications
      LU-11176 systemd: use univeral path for modprobe

Jian Yu (2):
      LU-11115 lod: skip max_create_count=0 OST in QoS and RR algorithms
      LU-11159 kernel: kernel update RHEL7.5 [3.10.0-862.9.1.el7]

John L. Hammond (5):
      LU-11108 mdt: propagate errors in mdt_getxattr()
      LU-11107 mdt: handle nonexistent xattrs correctly
      LU-11083 tests: automatically load external modules
      LU-11109 mdt: handle zero length xattr values correctly
      LU-11152 test: work around find bug in sanity 133[fg]

Lai Siyao (6):
      LU-11103 lod: add lock for lod_object layout
      LU-11102 ldlm: run local lock bl_ast only when necessary
      LU-11104 mdt: rename may cause deadlock
      LU-11148 ldlm: enable trybits for PDO lock
      LU-11102 test: test fewer files on ZFS system
      LU-4684 migrate: pack lmv ea in migrate rpc

Li Dongyang (1):
      LU-11071 build: Add server build support for Ubuntu 18.04

Michael Kuhn (1):
      LU-9087 build: add support for DKMS debs

Mikhail Pershin (3):
      LU-11120 test: add compilebench and DNE tests
      LU-10181 mds: init cpt params for mdt IO service
      LU-10181 mdt: read on open for DoM files

Minh Diep (2):
      LU-11068 build: remove invalid kernel srpm location
      LU-11149 build: enable KMP for Mellanox build

Nathaniel Clark (1):
      LU-11160 build: Fix uuid / blkid dependency

Oleg Drokin (1):
      New tag 2.11.54

Patrick Farrell (2):
      LU-10970 tests: make sure write is complete
      LU-11027 doc: Add lockahead to llapi_ladvise man

Qian Yingjin (3):
      LU-11032 hsm: memory leak in mdt_hsm_cdt_cleanup
      LU-9538 mdt: Lazy size on MDT
      LU-9538 utils: Tool for syncing file LSOM xattr

Quentin Bouget (1):
      LU-9474 tests: replace import_file with copytool import

Teddy Zheng (1):
      LU-10114 hsm: add OBD_CONNECT2_ARCHIVE_ID_ARRAY to pass archive_id lists in array

Yang Sheng (2):
      LU-11129 kernel: kernel update RHEL7.5 [3.10.0-862.6.3.el7]
      LU-11062 libcfs: use save_stack_trace for stack dump
