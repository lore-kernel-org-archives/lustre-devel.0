From: Oleg Drokin <green@whamcloud.com>
Date: Wed, 22 Jul 2020 16:58:38 +0000
Subject: [lustre-devel] New tag 2.13.55
Message-ID: <81696147-A0C5-45ED-BE82-70B53F2BD2C2@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just added 2.13.55 tag in the main Kustre development branch repo. Changelog is below:

Alex Zhuravlev (4):
      LU-2225 tests: sanity/27 tests to poll for state
      LU-13520 ldiskfs: fastpath in bitmap prefetching
      LU-13195 osp: invalidate object on write error
      LU-12905 tests: wrappers for createmany and unlinkmany

Alexander Boyko (1):
      LU-13617 llite: don't hold inode_lock for security notify

Alexey Lyashkov (5):
      LU-10157 ptlrpc: separate number MD and refrences for bulk
      LU-10157 ptlrpc: fill md correctly.
      LU-10157 lnet: restore an maximal fragments count
      LU-13181 o2ib: fix page mapping error
      LU-12214 build: fix build with gss enabled

Amir Shehata (4):
      LU-10973 lnet: infrastructure to build the LUTF
      LU-13662 lnet: handle undefined parameters
      LU-13566 socklnd: fix local interface binding
      LU-13713 lnet: check rtr_nid is a gateway

Andreas Dilger (8):
      LU-13503 mdc: allow setting max_mod_rpcs_in_flight larger
      LU-13225 utils: fix install path for bash-completion
      LU-13675 o2iblnd: revert 'Timed out tx' patch
      LU-930 misc: update URLs in README
      LU-13721 utils: fix 'lfs find --pool' for PFL files
      LU-13673 misc: quiet compiler warning on armv7l
      LU-13680 osd-ldiskfs: handle large allocations
      LU-5338 tests: sanity-lfsck 11b allow larger last_id

Andriy Skulysh (1):
      LU-13467 llite: truncate deadlock with DoM files

Arshad Hussain (16):
      LU-6142 utils: Fix style issues for mount_lustre.c
      LU-6142 utils: Fix style issues for llog_reader.c
      LU-6142 utils: Fix style issues for lctl.c
      LU-6142 utils: Fix style issues for liblustreapi.c
      LU-6142 mdt: Fix style issues for mdt_xattr.c
      LU-6142 ost: Fix style issues for ost_handler.c
      LU-6142 osd-ldiskfs: Fix style issues for osd_oi.c
      LU-6142 mdt: Fix style issues for mdt_reint.c
      LU-6142 llite: Fix style issues for vvp_page.c
      LU-6142 lov: Fix style issues for lov_merge.c
      LU-6142 mdt: Fix style issues for mdt_recovery.c
      LU-6142 utils: Fix style issues for lfs.c
      LU-6142 mdt: Fix style issues for mdt_identity.c
      LU-13723 lustre: Convert ERR_PTR(PTR_ERR()) to ERR_CAST()
      LU-6142 osd-ldiskfs: Fix style issues for osd_io.c
      LU-6142 fld: Fix style issues for fld_cache.c

Bobi Jam (2):
      LU-13473 llite: don't check mirror info for page discard
      LU-12586 lov: one more fix to write_intent end for trunc

Chris Horn (5):
      LU-13509 ptlrpc: Clear bd_registered in ptlrpc_unregister_bulk
      LU-13501 lnet: Skip health and resends for single rail configs
      LU-13501 tests: Add tests for LNet health and resends
      LU-13606 lnet: Allow router to forward to healthier NID
      LU-13648 lnet: Set remote NI status in lnet_notify

Dominique Martinet (1):
      LU-5710 build: fix typo suggesting openssl-devel requirement

Elena Gryaznova (2):
      LU-12205 tests: host_nids_address() fix for MR setup
      LU-13297 tests: parallel-scale enhancement

Emoly Liu (5):
      LU-13635 lfs: add -D option back to lfs_migrate
      LU-13597 ofd: add more information to job_stats
      LU-13609 llog: list all the log files correctly on MGS/MDT
      LU-13460 lfs: make function print_failed_tgt() work correctly
      LU-13732 lfs: fid2path should match the root path correctly

Etienne AUJAMES (2):
      LU-13595 scripts: Add a debug option to lustre_rmmod
      LU-12549 utils: Check range of quota ID for "lfs" arguments

Hongchao Zhang (4):
      LU-13508 mdc: chlg device could be used after free
      LU-13653 mdt: ignore quota when creating slave stripe
      LU-13608 tgt: abort recovery while reading update llog
      LU-13667 ptlrpc: fix endless loop issue

James Nunez (2):
      LU-13701 tests: stop running sanity-lnet tests
      LU-13514 tests: remove upgrade images for conf-sanity

James Simmons (13):
      LU-9897 build: add binaries to .gitignore
      LU-12511 build: ignore kmod handling in spec file for  utilities only build
      LU-12511 utils: Move utilies specific values out of Lustre UAPI headers
      LU-8130 obd: convert obd_nid_hash to rhashtable
      LU-9325 mdt: replace simple_strtol() with kstrtol()
      LU-9441 llite: bind kthread thread to accepted node set
      LU-12511 lov: use lov_pattern_support() to verify lmm
      LU-9859 libcfs: Fix using smp_processor_id() in preemptible context
      LU-9897 utils: have lfs.c use lstddef.h
      LU-930 doc: update James Simmons contact info
      LU-9859 libcfs: move tgt_descs to standard Linux bitmaps.
      LU-6142 libcfs: resolve debug.c checkpatch issues
      LU-12514 utils: try lustre_tgt filesystem for mount

Jian Yu (8):
      LU-13488 kernel: new kernel [RHEL 8.2 4.18.0-193.1.2.el8]
      LU-13111 kernel: new kernel [SLES12 SP5 4.12.14-122.20.1]
      LU-13556 kernel: kernel update RHEL7.8 [3.10.0-1127.8.2.el7]
      LU-13488 kernel: RHEL 8.2 server support
      LU-13345 kernel: kernel update SLES12 SP4 [4.12.14-95.48.1]
      LU-13657 kernel: kernel update RHEL8.2 [4.18.0-193.6.3.el8_2]
      LU-13731 llite: include linux/mm_types.h for VM_FAULT_RETRY
      LU-13731 autoconf: check if VM_FAULT_RETRY is defined

John L. Hammond (3):
      LU-13690 mdd: remove warnings in obd_lookup()
      LU-13693 lfs: avoid opening regular files for getstripe
      LU-13693 lfs: check early for MDS_OPEN_DIRECTORY

K?vin Baillergeau (1):
      LU-13559 utils: fix lfs mirror delete error message

Lai Siyao (7):
      LU-13437 lmv: check stripe FID sanity
      LU-11025 dne: directory restripe and auto split
      LU-11025 mdt: remove unused code
      LU-13408 target: update in-memory per client data
      LU-13437 mdt: don't fetch LOOKUP lock for remote object
      LU-13437 mdt: rename misses remote LOOKUP lock revoke
      LU-13437 uapi: add OBD_CONNECT2_GETATTR_PFID

Li Dongyang (1):
      LU-13604 doc: update e2fsprogs to 1.45.6.wc1

Mikhail Pershin (3):
      LU-13600 ptlrpc: limit rate of lock replays
      LU-12785 dom: fix DoM component deletion code
      LU-13600 ptlrpc: re-enterable signal_completed_replay()

Mr NeilBrown (37):
      LU-6142 lustre: convert some container_of to *_safe
      LU-9859 libcfs: merge linux-debug.c into debug.c
      LU-11310 ldiskfs: Repair support for SUSE 15 again
      LU-12780 quota: don't use ptlrpc_thead of qmt_pool_recalc
      LU-6142 obdclass: convert calls to container_of0()
      LU-10391 lnet: fix uninitialize var in choose_ipv4_src()
      LU-9859 libcfs: merge linux-tracefile.c into tracefile.c
      LU-9859 libcfs: remove cfs_trace_refill_stack()
      LU-9859 libcfs: move cfs_trace_data data to tracefile.c
      LU-10934 tests: fix compilation without SELINUX
      LU-12780 scrub: all update to bitfields must be protected.
      LU-9679 obdclass: remove init to 0 from lustre_init_lsi()
      LU-8130 ptlrpc: convert conn_hash to rhashtable
      LU-8130 lu_object: convert lu_object cache to rhashtable
      LU-9859 libcfs: fold cfs_tracefile_*_arch into their only callers.
      LU-12678 o2iblnd: allocate init_qp_attr on stack.
      LU-12678 lnet: Fix some out-of-date comments.
      LU-12678 socklnd: don't fall-back to tcp_sendpage.
      LU-6142 lustre: convert use of container_of0 in include/
      LU-6142 lov: convert container_of0() calls.
      LU-9679 nrs: remove ts_opcodes bitmap.
      LU-9679 lustre: remove some "#ifdef CONFIG*" from .c files.
      LU-9859 libcfs: cleanup tracefile.h
      LU-12678 o2iblnd: Use ib_mtu_int_to_enum()
      LU-12768 o2iblnd: wait properly for fps->increasing.
      LU-12678 o2iblnd: use need_resched()
      LU-12678 o2iblnd: Use list_for_each_entry_safe
      LU-12678 socklnd: use need_resched()
      LU-12678 socklnd: use list_for_each_entry_safe()
      LU-12678 socklnd: convert various refcounts to refcount_t
      LU-9859 libcfs: don't call unshare_fs_struct()
      LU-9679 llite: annotate non-owner locking
      LU-12678 lnet: remove LNetMEUnlink and clean up related code
      LU-12678 socklnd: change ksnd_nthreads to atomic_t
      LU-9679 lov: annotate nested locking of obd_dev_mutex
      LU-9679 lustre: make ptlrpc_connection_put() static inline
      LU-9679 mdc: create mdc_acl.c

Mr. NeilBrown (1):
      LU-9859 libcfs: discard libcfs_prim.h

Nathaniel Clark (1):
      LU-9812 spec: Fail rpmbuild if with servers but unconfigured

NeilBrown (1):
      LU-9679 osc: simplify osc_extent_find()

Oleg Drokin (2):
      LU-13776 tests: make sure pjdfstest.sh writes to tmp
      New tag 2.13.55

Patrick Farrell (2):
      LU-11963 obd: Rename OS_STATE flags to OS_STATFS
      LU-13196 llite: Remove mutex on dio read

Qian Yingjin (2):
      LU-13546 pcc: exclude mmap_sanity tst8/tst9 from test list
      LU-13628 tests: replace btime with crtime for statx test

Sebastien Buisson (20):
      LU-12275 sec: documentation for client-side encryption
      LU-12275 sec: enable client side encryption
      LU-13628 tests: add sanityn test_106 to ALWAYS_EXCEPT
      LU-12275 sec: control client side encryption
      LU-12275 sec: encryption for write path
      LU-12275 sec: decryption for read path
      LU-12275 sec: deal with encrypted object size
      LU-12275 sec: support truncate for encrypted files
      LU-13580 tests: fix retrieval of SELinux context
      LU-12275 tests: exercise file content encryption/decryption
      LU-12275 sec: ioctls to handle encryption policies
      LU-13711 build: fix typo on SSL dependency for Ubuntu
      LU-13525 sec: better struct sepol_downcall_data
      LU-13754 gss: open sptlrpc init channel in R+W mode
      LU-12275 sec: introduce null algo for filename encryption
      LU-12275 sec: force file name encryption policy to null
      LU-12275 sec: atomicity of encryption context getting/setting
      LU-13593 ptlrpc: fix growing message buffer
      LU-12275 sec: encryption support for DoM files
      LU-12275 sec: check if page is empty with ZERO_PAGE

Sergey Cheremencev (2):
      LU-13677 quota: qunit sorting doesn't work
      LU-13586 tests: Quota Pools with PFL and SEL

Shaun Tancheff (7):
      LU-12477 ldiskfs: drop SUSE kernel 4.4 and earlier
      LU-13344 osd-ldiskfs: timespec64 is broken
      LU-13562 build: SUSE build support for azure, cray_ari_s
      LU-13476 llite: Fix lock ordering in pagevec_dirty
      LU-13581 build: xarray and lockdep_is_held const clash
      LU-13344 all: Separate debugfs and procfs handling
      LU-13485 build: Make parallel tests names unique

Sonia Sharma (1):
      LU-1742 o2iblnd: 'Timed out tx' error message

Vitaly Fertman (3):
      LU-13649 mdd: orhpan cleanup fix
      LU-13366 lod: check for extension size at instantiation time
      LU-13366 tests: add SEL support to racer

Vladimir Saveliev (1):
      LU-12687 osc: consume grants for direct I/O

Wang Shilong (9):
      LU-13365 ldlm: check slv and limit before updating
      LU-13180 osc: disable ext merging for rdma only pages and non-rdma
      LU-13134 obdclass: use offset instead of cp_linkage
      LU-13134 obdclass: re-declare cl_page variables to reduce its size
      LU-13134 osc: re-declare ops_from/to to shrink osc_page
      LU-13519 osd-ldiskfs: expand inode project quota for upgrading
      LU-13134 llite: fix to free cl_dio_aio properly
      LU-13697 llite: fix short io for AIO
      LU-13729 osd-ldiskfs: race access to iam_formats during setup

Yang Sheng (2):
      LU-10401 procs: print new line based on distro
      LU-11814 obdcalss: ensure LCT_QUIESCENT take sync
