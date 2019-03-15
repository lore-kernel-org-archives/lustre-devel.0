From: Oleg Drokin <green@whamcloud.com>
Date: Fri, 15 Mar 2019 23:18:46 +0000
Subject: [lustre-devel] New tag 2.12.52
Message-ID: <3084B9EE-EDA2-41DC-B696-C8F23C9D758C@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

 I just tagged 2.12.52 in Lustre development master branch.

 Here?s the changelog:

Alex Zhuravlev (9):
      LU-10496 tests: disable 39k for DoM for a while
      LU-10143 osd-zfs: allocate sequence in advance
      LU-11058 tests: cleanup persistent checksum= in 77k
      LU-11920 lod: do not reset lds_def_comp_entries
      LU-11330 osd-zfs: hash for ./.. must be 0
      LU-9706 dt: remove dt_txn_hook_commit()
      LU-11951 ptlrpc: reset generation for old requests
      LU-12018 quota: do not start a thread under memory pressure
      LU-11855 utils: move declarations out of local blocks

Alexander Boyko (5):
      LU-10913 llog: add startcat for wrapped catalog
      LU-11591 llog: add synchronization for the last record
      LU-11924 osp: combine llog cancel operations
      LU-11934 mdc: don't use ACL at setattr
      LU-11975 test: fix for llog test 10h

Alexander Zarochentsev (2):
      LU-11881 utils: silence error message
      LU-8299 llite: ll_fault should fail for insane file offsets

Alexey Lyashkov (5):
      LU-11861 obdclass: fix build with debug kernel
      LU-11862 lfsck: avoid unexpected repairing
      LU-11111 lfsck: skip orphan processing
      LU-11413 lnet: use right rtr address
      LU-11413 lnet: use right address for routing message

Andreas Dilger (16):
      LU-11878 tests: don't fork-bomb sanity test_103b
      LU-4664 libcfs: allow file/func/line passed to CDEBUG()
      LU-10885 tests: fix up flocks_test bugs and code style
      LU-10885 llite: enable flock mount option by default
      LU-11797 tests: improve sanity test 272a checking
      LU-10171 lmv: avoid gratuitous 64-bit modulus
      LU-11770 osc: allow build without blk_integrity or crc-t10pi
      LU-930 utils: fix --verbose option for lfs-migrate.1
      LU-11917 tests: wait for test_257 to finish recovery
      LU-11584 osd-ldiskfs: fix lost+found object replace
      LU-11913 utils: allow "mq-deadline" as scheduler
      LU-11923 utils: fix mkfs.lustre meta_bg handling
      LU-11830 lov: avoid signed vs. unsigned comparison
      LU-11891 utils: getstripe use --mdt-index consistently
      LU-11880 build: allow Debian build on Raspbian
      LU-11329 misc: reorder Git .mailmap file

Andrew Perepechko (1):
      LU-11897 ost: improve memory allocation for ost

Andriy Skulysh (2):
      LU-11701 ptlrpc: eviction of lwp connection aborts requests
      LU-11702 o2iblnd: ibc_rxs is created and freed with different size

Ann Koehler (1):
      LU-11944 llite: Lock inode on tiny write if setuid/setgid set

Arshad Hussain (1):
      LU-6142 mgs: Fix style issues for mgs_nids.c

Artem Blagodarenko (1):
      LU-1365 tests: createmany outputs stat after 2 seconds

Aurelien Degremont (1):
      LU-11892 hsm: fix memory leak when scheduling HSM requests

Elena Gryaznova (2):
      LU-11586 tests: test_10() fix for FILESET set
      LU-11495 tests: zconf_mount_clients() fix to work with FILESET

Hongchao Zhang (1):
      LU-11768 test: reset qsd_time before test

James Nunez (7):
      LU-11915 tests: stop running conf-sanity test 110
      LU-10447 tests: replace $SETSTRIPE/$GETSTRIPE with $LFS
      LU-11401 tests: add version check sanity-flr tests
      LU-8346 tests: remove spaces around fail_val
      LU-11208 tests: add version check to sanity tests
      LU-11777 tests: add version check sanityn 102
      LU-11010 tests: remove return after skip for conf-sanity

James Simmons (7):
      LU-8130 libcfs: port working hash from upstream
      LU-11803 tests: don't assume obd device name
      LU-8066 osd: migrate from proc to sysfs
      LU-8130 libcfs: support latest rhashtable API
      LU-11838 llite: remove assert for acl refcount
      LU-8066 utils: have llapi_target_iterate use sysfs tree
      LU-9855 obd: use ldo_process_config for mdc and osc layer

Jian Yu (1):
      LU-11927 kernel: new kernel [SLES12 SP4 4.12.14-95.6.1]

Jinshan Xiong (1):
      LU-11811 mdt: Add a proc entry to set MDT to readonly

Lai Siyao (1):
      LU-11502 migrate: link parents lock may deadlock

Li Dongyang (2):
      LU-11775 osc: reduce atomic ops in osc_enter_cache_try
      LU-11775 osc: check if opg is in lru list without locking

Li Xi (1):
      LU-11974 llapi: improve llapi_layout_get_by_xattr(3) API

Lokesh Nagappa Jaliminche (1):
      LU-8365 ldiskfs: procfs entries for mballoc

Mikhail Pershin (1):
      LU-5604 tests: fix usage of drop_ldlm_reply() in tests

Nathan Dauchy (1):
      LU-8207 scripts: add auto-stripe option to lfs_migrate

Nathaniel Clark (4):
      LU-11720 spec: srpm should be free of kernel requiements
      LU-11876 dkms: Add missing Requires for zlib-devel
      LU-11947 scripts: handle ZFS targets in Lustre RA
      LU-12042 utils: Remove stray waring from lfs mkdir

NeilBrown (8):
      LU-9868 llite: handle DCACHE_PAR_LOOKUP in ll_dcompare
      LU-11838 socklnd:  use for_each_netdev() instead of lnet_ipif_enumerate()
      LU-11616 llite: replace smp_wb() with full memory barrier
      LU-9859 libcfs: replace cfs_srand() calls with add_device_randomness().
      LU-11089 obdclass: make key_set_version an atomic_t
      LU-11089 obdclass: use an rwsem instead of lu_key_initing_cnt.
      LU-9859 libcfs: use strim instead of cfs_trimwhite.
      LU-9859 libcfs: use a workqueue for rehash work.

Oleg Drokin (3):
      LU-11930 llite: Restore pio flags
      LU-11568 ldlm: Remove use of SLAB_DESTROY_BY_RCU for ldlm lock slab
      New tag 2.12.52

Patrick Farrell (8):
      LU-11825 llite: Remove ptask framework
      LU-11919 llite: Initialize cl_dirty_max_pages
      LU-11773 utils: add PFL flags support to YAML API
      LU-11905 mdc: Add RETURN to mdc_intent_open_pack
      LU-11206 tests: Use import_ready to check IDLE
      LU-11982 utils: Correct lfs migrate help
      LU-10143 tests: Add version check for interop
      LU-11943 llog: Reset current log on ENOSPC

Sebastien Buisson (3):
      LU-11749 tests: sanity-sec 23b exec commands on right node
      LU-11914 build: add a configure check for l_getsepol
      LU-11894 lnet: check for asymmetrical route messages

Sergey Cheremencev (1):
      LU-11765 ofd: return EAGAIN during 1st CLEANUP_ORPHAN

Thomas Stibor (3):
      LU-11899 utils: Possible resource/memory leaks
      LU-11960 build: Add missing libssl-dev DEB package
      LU-12033 build: Git ignore generated *.install files

Vladimir Saveliev (4):
      LU-11634 tests: sanityn/test_77 improvements
      LU-11911 lov: fix lov_iocontrol for inactive OST case
      LU-11759 tests: racer cleanup
      LU-11827 llog: protect cathandle in llog_cat_declare_add_rec

Wang Shilong (3):
      LU-11849 utils: fix to make exclude projid works
      LU-12020 llite: make sure name pack atomic
      LU-11243 lod: fix assertion and hang upon lod_add_device failure
