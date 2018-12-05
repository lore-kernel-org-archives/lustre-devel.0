From: Oleg Drokin <green@whamcloud.com>
Date: Wed, 5 Dec 2018 03:04:20 +0000
Subject: [lustre-devel] 2.12.0-RC1
Message-ID: <1BB5E562-1961-4615-9480-6B335305B086@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just tagged first RC for 2.12 release. Here?s the changelog:

Ake Sandgren (2):
      LU-11541 build: Adjust OFED check for DKMS enabled MLNX OFED.
      LU-11541 build: Use correct kernel version for DKMS MLNX OFED.

Alex Zhuravlev (6):
      LU-11347 osd: do not use pagecache for I/O
      LU-11288 osc: re-check target versus available grant
      LU-10406 mdt: invalidate cache upon LDLM lock
      LU-11406 mdt: mdt_reint_setxattr() to check rr_eadata
      LU-11483 ldlm ofd_lvbo_init() and mdt_lvbo_fill() create env
      LU-11663 osd-zfs: write partial pages with correct offset

Alexander Boyko (1):
      LU-11392 tests: check race for llog_process_thread

Alexander Zarochentsev (1):
      LU-11130 osd-ldiskfs: create non-empty local agent symlinks

Alexey Lyashkov (1):
      LU-11020 osp: fix race during lov_objids update

Amir Shehata (9):
      LU-11474 lnet: unlink md if fail to send recovery
      LU-11476 lnet: set the health status correctly
      LU-11472 lnet: Decrement health on timeout
      LU-11530 lnet: properly error check sensitivity
      LU-11468 lnet: configure recovery interval
      LU-11469 lnet: fix "debug recovery" output
      LU-11514 lnet: separate ni state from recovery
      LU-11468 lnet: set recovery interval from lnetctl
      LU-11570 lnet: update changelog

Andreas Dilger (22):
      LU-11196 tests: clean up after conf-sanity test_101
      LU-1757 osc: clarify short_io_bytes is maximum value
      LU-1095 misc: quiet console messages at startup
      LU-11282 tests: log skip message for sanityn test_19
      LU-11417 llapi: add llapi_layout_get_by_xattr(3) API
      LU-11429 mdt: rename mdt_remote_permission
      LU-10801 utils: fix lfs_migrate argument parsing
      LU-10030 idl: use proper ATTR/MDS_ATTR/MDS_OPEN flags
      LU-11124 utils: add "lfs getstripe -N" option
      LU-7770 lov: fix statfs for conf-sanity test_50b
      LU-11516 mdd: do not assert on missing orphan
      LU-11556 tests: fix set_persistent_param_and_check breakage
      LU-11163 libcfs: fix CPT NUMA memory failures
      LU-930 doc: update Lustre Changelog kernel versions
      LU-11329 misc: populate MAINTAINERS file
      LU-10695 tests: fix sanity-lfsck test_23c
      Revert "LU-8130 ptlrpc: convert conn_hash to rhashtable"
      LU-9538 utils: update description of ldiskfs xattrs
      LU-10030 hsm: make changelog flag argument an enum
      LU-11597 tests: fix O_DIRECT test usage for ARM
      LU-11527 tests: fix sanity 270a for ARM
      LU-10576 tests: allow log files to be created/removed

Ann Koehler (1):
      LU-9793 ptlrpc: Do not map unrecognized ELDLM errnos to EIO

Arshad Hussain (24):
      LU-6142 obdclass: Fix style issues for obdo.c
      LU-6142 obdclass: Fix style issues for llog_test.c
      LU-6142 obdclass: Fix style issues for obd_mount.c
      LU-6142 obdclass: Fix style issues for dt_object.c
      LU-6142 obdclass: Fix style issues for llog_obd.c
      LU-6142 obdclass: Fix style issues for llog_ioctl.c
      LU-6142 lov: Fix style issues for lov_dev.c
      LU-6142 lov: Fix style issues for lov_offset.c
      LU-6142 lov: Fix style issues for lov_pack.c
      LU-6142 lov: Fix style issues for lov_request.c
      LU-6142 lov: Fix style issues for lovsub_dev.c
      LU-6142 lov: Fix style issues for lovsub_object.c
      LU-6142 lov: Fix style issues for lov_ea.c
      LU-6142 quota: Fix style issues for qsd_lock.c
      LU-6142 obdclass: Fix style issues for lprocfs_status.c
      LU-6142 obdclass: Fix style issues for llog_swab.c
      LU-6142 obdclass: Fix style issues for idmap.c
      LU-6142 lov: Fix style issues for lov_io.c
      LU-6142 lov: Fix style issues for lov_lock.c
      LU-6142 lov: Fix style issues for lov_page.c
      LU-6142 ofd: Fix style issues for ofd_obd.c
      LU-6142 fld: Fix style issues for fld_handler.c
      LU-6142 fld: Fix style issues for fld_index.c
      LU-6142 fld: Fix style issues for fld_request.c

Artem Blagodarenko (1):
      LU-11535 ldiskfs: allocate extra ldiskfs_ext_path for root

Ben Evans (1):
      LU-4939 utils: allow configuration through yaml files

Bobi Jam (3):
      LU-11158 mdt: grow lvb buffer to hold layout
      LU-10258 lfs: lfs mirror write command
      LU-11582 llite: protect reading inode->i_data.nrpages

Chris Hanna (1):
      LU-9795 tests: exclude several tests which conflict with SSK

Elena Gryaznova (9):
      LU-11490 tests: fix rr_alloc() test to use FSNAME
      LU-11080 tests: skip async update recovery tests
      LU-11498 tests: remove duplicate write_disjoint test name
      LU-11499 tests: skip test_56ba for old server
      LU-11489 tests: retry power off/on several times
      LU-11522 tests: sanity-sec/27 unable to remount client
      LU-11492 tests: fix thread_sanity() defect
      LU-11494 tests: sanity-quota/22 syntax error fix
      LU-11497 tests: improve ha.sh to set striped dirs

Hongchao Zhang (3):
      LU-11390 quota: mark over-quota flag correctly
      LU-11425 quota: support quota for DoM
      LU-5152 quota: disable sync chgrp to OSTs

James Nunez (6):
      LU-11473 doc: add lfs-getsom man page
      LU-11329 utils: create tests maintainers list
      LU-11010 tests: remove calls to return after skip()
      LU-11373 tests: increase debug limit sanity 60b
      LU-11564 tests: add version check sanity-hsm tests
      LU-11561 ofd: return attr syncjournal to sync_journal

James Simmons (13):
      LU-8066 llite: make llite/lov and lmv symlinks
      LU-6142 llite: move CONFIG_SECURITY handling to llite_internal.h
      LU-8066 obd: use correct names for conn_uuid
      LU-6142 lnd: create enum kib_dev_caps
      LU-11152 lnd: test fpo_fmr_poool pointer instead of special bool
      LU-8066 llite: Move all remaining procfs entries to debugfs
      LU-10937 mgc: restore mgc binding for sptlrpc
      LU-8602 gss: Properly port gss to newer crypto api.
      LU-8066 lod: replace class_process_proc_param()
      LU-11071 osd-ldiskfs: support bio integrity with Ubuntu 18
      LU-11071 build: add files to .gitignore
      LU-10335 test: enable sanity 130 tests for Ubuntu
      LU-10626 test: create custom udev rule

Jian Yu (5):
      LU-11448 kernel: kernel update RHEL7.5 [3.10.0-862.14.4.el7]
      LU-11525 kernel: new kernel [RHEL7.6 3.10.0-957.el7]
      LU-10965 doc: add mirror options to "lfs find" in lfs.1
      LU-11596 tests: disable several sanity sub-tests for ARM
      LU-11652 kernel: kernel update [SLES12 SP3 4.4.162-94.69]

Jinshan Xiong (3):
      LU-11427 lod: create layout in mdo_create()
      LU-11427 llite: optimize read on open pages
      LU-11654 mdd: check ucred before using it

John L. Hammond (8):
      LU-11369 hsm: allow non-owner writers to set HSM state dirty
      LU-11479 rsync: replicate attributes of file in .lustrerepl
      LU-11488 test: ignore statfs from precreate in sanity 133b()
      Revert "LU-6142 obdclass: Fix style issues for obd_mount.c"
      LU-11380 mdc: move empty xattr handling to mdc layer
      LU-11445 obd: remove portals handle from OBD import
      LU-11519 hsm: handle hsd_request_count == 0 properly
      LU-11662 llite: handle -ENODATA in ll_layout_fetch()

Lai Siyao (13):
      LU-11418 osd-zfs: call stop_cb if transaction start fail
      LU-4684 migrate: replace PFID via source
      LU-11419 lfsck: lfsck_namespace_shrink_linkea() dead loop
      LU-4684 lod: parse layout for migrating directory
      LU-4684 llite: add lock for dir layout data
      LU-11508 mdt: reject DoM file migration
      LU-11611 mdt: incorrect return value in mdt_reint_unlink
      LU-11418 llog: refresh remote llog upon -ESTALE
      LU-8777 mdt: add parameter to disable remote/striped dir
      LU-11642 mdt: revoke remote LOOKUP lock in dir layout shrink
      LU-11642 lmv: allocate fid on parent MDT in migrate
      LU-11668 debug: print object type in mdd_parent_fid
      LU-11668 mdt: check parent type in rename/migrate

Li Dongyang (5):
      LU-11440 doc: recommend e2fsprogs 1.44.3.wc1
      LU-8391 ldlm: check double grant race after resource change
      LU-11071 build: kernel update Ubuntu 18.04
      LU-9906 clio: use pagevec_release for many pages
      LU-11071 build: use --with-linux-obj for ubuntu

Li Xi (3):
      LU-10472 osd-ldiskfs: T10PI between RPC and BIO
      LU-11697 osc: wrong page offset for T10PI checksum
      LU-11697 ost: do not reuse T10PI guards of unaligned page write

Mikhail Pershin (4):
      LU-11276 ldlm: don't apply ELC to converting and DOM locks
      LU-11430 tests: get MDC stats by index
      LU-11102 ldlm: don't skip bl_ast for local lock
      LU-11595 mdt: fix read-on-open for big PAGE_SIZE

Minh Diep (2):
      LU-11553 kernel: new kernel [RHEL7.5 4.14.0-49.13.1.el7a]
      LU-11553 build: add download 7.5alternate for MOFED

Nathaniel Clark (5):
      LU-11193 llog: Do not write to read-only devices
      LU-11393 osd-zfs: time struct changes
      LU-11461 scripts: Support symlink target
      LU-11563 build: Only add l_tunedisk udev rule to server
      LU-2836 tests: Re-enable sanity-quota/3,6 for ZFS

Olaf Faaland (2):
      LU-11329 misc: Add LLNL reviewers to MAINTAINERS
      LU-11567 utils: llog_reader print changelog index

Oleg Drokin (2):
      LU-11511 fix build breakage with LMV_HASH_FLAG_DEAD undeclared
      New Release candidate 2.12.0-RC1

Patrick Farrell (6):
      LU-11454 ptlrpc: Make CPU binding switchable
      LU-11199 mdt: Attempt lookup lock on open
      LU-11482 flr: Inherit flags from template
      LU-10337 mdt: Allow open of open orphans
      LU-11423 osc: Do not walk full extent list
      LU-11329 utils: Add maintainer entries

Qian Yingjin (3):
      LU-11450 mdd: avoid logging trusted.som xattr in changelogs
      LU-11599 ldlm: printing negative time on logs for recovery
      LU-11466 mdt: Skip SOM xattr update for DoM-only files

Quentin Bouget (5):
      LU-8950 tests: do not use make_custom_file_for_progress()
      LU-8324 hsm: prioritize one RESTORE once in a while
      LU-11519 hsm: improve the testing of hsm.max_requests
      LU-11572 tests: make sanity-hsm test_260c reliable
      LU-11653 hsm: copytool registration wakes the coordinator

Robert Read (1):
      LU-6142 libcfs: Enforce kernel coding style for libcfs/debug.c

Sebastien Buisson (9):
      LU-11057 tests: exercise 'network' client mount option
      LU-11524 tests: fix sanity-sec test_31 for all situations
      LU-9795 mdt: only set groups if GID is not squashed
      LU-9795 gss: fix gss-based integrity check for multi-rail
      LU-8602 gss: get rid of cfs_crypto_hash_desc
      LU-9795 gss: properly handle mgssec
      LU-8602 gss: support OpenSSL 1.1
      LU-11635 gss: proper gss build for client-only
      LU-11645 tests: fix sanity-sec test 31

Sergey Cheremencev (1):
      LU-11536 ofd: ofd_create_hdl may return 0 in case of ENOSPC

Sonia Sharma (3):
      LU-11371 socklnd: dynamically set LND parameters
      LU-10876 lnet: peer deletion code may hide error
      LU-11389 lnet: increase lnet transaction timeout

Teddy Zheng (1):
      LU-10114 hsm: increase upper limit of maximum HSM backends registered with MDT

Tony Hutter (1):
      LU-11507 osd-zfs: Use zfs_refcount_add if available

Wang Shilong (1):
      LU-11101 quota: fix setattr project check

Yang Sheng (1):
      LU-11453 class: use INIT_LIST_HEAD_RCU instead INIT_LIST_HEAD
