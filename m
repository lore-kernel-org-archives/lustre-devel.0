From: Oleg Drokin <green@whamcloud.com>
Date: Tue, 24 Jul 2018 04:00:39 +0000
Subject: [lustre-devel] New tag 2.11.53
Message-ID: <20C0EAB6-A384-435E-96D4-22840D361C42@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I just tagged a new tag 2.11.53 in Lustre master tree.

Here?s the changelog:

Alex Zhuravlev (3):
      LU-7236 ptlrpc: idle connections can disconnect
      LU-10048 osd: async truncate
      LU-11097 utils: add libuuid for llverdev

Alexander Boyko (4):
      LU-6399 lnet: socket cleanup
      LU-10945 ldlm: fix l_last_activity usage
      LU-11117 ptlrpc: don't zero request handle
      LU-10893 tests: allow to disable dm-flakey layer

Amir Shehata (1):
      LU-11064 lnd: determine gaps correctly

Andreas Dilger (5):
      LU-10264 misc: fix possible array overflow
      LU-10921 utils: improve lfs setstripe error message
      LU-10855 ptlrpc: remove obsolete OBD RPC opcodes
      LU-10855 ptlrpc: assign specific values to MGS opcodes
      LU-10855 ptlrpc: remove obsolete LLOG_ORIGIN_* RPCs

Andrew Perepechko (1):
      LU-10964 build: armv7 client build fixes

Andriy Skulysh (2):
      LU-11004 ptlrpc: Serialize procfs access to scp_hist_reqs using mutex
      LU-11098 ptlrpc: ASSERTION(!list_empty(imp->imp_replay_cursor))

Arshad Hussain (2):
      LU-7943 mdd: Move assignment after LASSERT()
      LU-10370 ofd: truncate does not update blocks count on client

Bob Glossman (3):
      LU-10897 kernel: kernel upgrade RHEL7.5 [3.10.0-862.2.3.el7]
      LU-11043 kernel: kernel update RHEL7.5 [3.10.0-862.3.2.el7]
      LU-11065 kernel: kernel update [SLES12 SP3 4.4.132-94.33]

Bruno Faccini (3):
      LU-10680 mdd: create gc thread when no current transaction
      LU-10527 obdclass: don't recycle loghandle upon ENOSPC
      LU-10734 tests: ensure current GC interval is over

Chris Horn (1):
      LU-11044 osd-ldiskfs: ext4_dir_operations uses iterate_shared

Chuck Fossen (1):
      LU-10963 gnilnd: stats variables overflow assert

Dmitry Eremin (1):
      LU-4423 ptlrpc: use delayed_work in sec_gc

Emoly Liu (6):
      LU-10907 tests: improve nodemap_test_setup()
      LU-10979 test: correct the version code check in sanity-sec.sh
      LU-10980 test: correct the version code check in sanityn.sh
      LU-10972 test: get client uuid correctly
      LU-10906 checksum: enable/disable checksum correctly
      LU-11099 doc: include "-N" option to lfs_setstripe.1

Fan Yong (6):
      LU-11024 osd-zfs: properly detect ZFS dnode accounting
      LU-10419 lfsck: signal master engine when stop
      LU-9764 lfsck: reset LFSCK trace file if fail to load it
      LU-9751 snapshot: set PATH for remote zfs commands
      LU-10120 lsnapshot: handle dash in fsname
      LU-11079 llite: control concurrent statahead instances

Giuseppe Di Natale (1):
      LU-6160 osd-zfs: Fix refcount_add call

Gregoire Pichon (1):
      LU-739 utils: remove references to lustre 1.4 upgrade flag

Hongchao Zhang (1):
      LU-7816 quota: add default quota setting support

James Nunez (5):
      LU-11010 tests: remove calls to return after skip()
      LU-8972 tests: remove conf-sanity test from ALWAYS_EXCEPT
      LU-10971 tests: use changelog routines in lustre-rsync-test
      LU-11058 tests: stop running sanity test 77k
      LU-11161 tests: stop running sanity test 160g

James Simmons (9):
      LU-9325 obdclass: handle strings correctly in lmd_find_delimiter
      LU-9325 libcfs: handle complex strings in cfs_str2num_check
      LU-10886 build: fix WARNING: modpost: missing MODULE_LICENSE()
      LU-10997 build: add files to .gitignore
      LU-8066 llite: Preparation to move /proc/fs/lustre/llite to sysfs
      LU-8066 llite: replace ll_process_config with class_modify_config
      LU-9325 llog: replace simple_strtol with kstrtol
      LU-8066 osc: fix idle_timeout handling
      LU-8066 llite: replace ll_process_config with class_modify_config

Joe Grund (1):
      LU-11026 lustre-dkms should require patch or quilt

John L. Hammond (14):
      LU-10699 hsm: add local object storage to MDTs
      LU-10855 llog: remove llog_cancel()
      LU-10978 utils: preserve lustre_rsync state
      LU-10989 utils: correct lustre_rsync changelog clear logic
      LU-10855 llog: remove obsolete llog handlers
      LU-11014 mdt: intent handling simplification
      LU-11054 lnet: remove non-error error message
      LU-11069 llite: correct file position after appending writes
      LU-11051 obd: remove obd_{get,put}ref()
      LU-11014 mdt: remove enum mdt_it_code
      LU-11045 test: use provided directory in racer/racer.sh
      LU-11052 obd: remove OBD ops based stats
      LU-11074 mdc: set correct body eadatasize for getxattr()
      LU-11157 obd: keep dirty_max_pages a round number of MB

Lai Siyao (2):
      LU-4684 mdt: improve directory stripe lock
      LU-4684 xattr: add list support for remote object

Li Dongyang (1):
      LU-10560 osd: bio_integrity_enabled was removed

Li Xi (2):
      LU-10472 osd-ldiskfs: add T10PI support for BIO
      LU-10472 osc: add T10PI support for RPC checksum

Mikhail Pershin (5):
      LU-10808 lod: align wrong DoM stripe values with defaults
      LU-10808 lod: remove DoM component if DoM is disabled
      LU-10175 ptlrpc: add LOCK_CONVERT connection flag
      LU-10175 ldlm: handle lock converts in cancel handler
      LU-11003 ldlm: don't add canceling lock back to LRU

Minh Diep (1):
      LU-11034 build: update changelog for Ubuntu 18.04

Nathaniel Clark (4):
      LU-10843 mgs: allow snapshot after MGS remount
      LU-10898 tests: enable conf-sanity 32a/32d
      LU-11019 build: Update ZFS/SPL to 0.7.9
      LU-11066 systemd: Add IB dependencies to lnet.service

NeilBrown (5):
      LU-9859 libcfs: rearrange placement of CPU partition management code.
      LU-4423 libcfs: disable preempt while sampling processor id.
      LU-8130 ldlm: store name directly in namespace.
      LU-4423 obd: backport of lu_object changes upstream
      LU-4423 ldlm: use delayed_work for ldlm_pools_recalc

Oleg Drokin (5):
      LU-10938 ptlrpc: Add WBC connect flag
      LU-11015 lov: Move lov_tgts_kobj init to lov_setup
      Revert "LU-8066 llite: replace ll_process_config with class_modify_config"
      LU-10990 osc: increase default max_dirty_mb to 2G
      New tag 2.11.53

Parinay Kondekar (1):
      LU-6511 osd-ldiskfs: Fix all irregular indentation for osd_iam.c

Patrick Farrell (1):
      LU-10648 ldlm: Reduce debug to console during eviction

Quentin Bouget (2):
      LU-9474 tests: remove unneeded hsm_set_param for raolu tests
      LU-10796 tests: standardize changelog testing in sanity-hsm

Saurabh Tandan (1):
      LU-10977 test: add version check to sanity test_60ab

Sebastien Buisson (2):
      LU-9727 tests: exercise new changelog fields and records
      LU-11049 ssk: correctly handle null byte by lgss_sk

Vladimir Saveliev (2):
      LU-11131 target: keep reply data bit set on failover
      LU-11132 compile: fix LC_BI_BDEV for old kernels

Wang Shilong (3):
      LU-11017 quota: ignore quota for CAP_SYS_RESOURCE properly
      LU-11086 test: reset quota setting properly
      LU-10986 lfs: make lfs project tolerant errors

Yang Sheng (2):
      LU-9230 ldlm: speed up preparation for list of lock cancel
      LU-11003 ldlm: fix for l_lru usage
