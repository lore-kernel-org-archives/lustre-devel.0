From: Oleg Drokin <green@whamcloud.com>
Date: Wed, 27 May 2020 22:53:35 +0000
Subject: [lustre-devel] New tag 2.13.54
Message-ID: <8EF25751-5B6F-4FFD-A134-65E3E85A3E32@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

  I just tagged 2.13.54 in Lustre master development branch. Longer period than usual, but this baseline seems to be
  holding up particularly well in all sorts of testing, so here?s hoping it?ll stay this good and better
  throughout the rest of the cycle.

  Here?s the changelog:
Alex Zhuravlev (11):
      LU-10395 osd: stop OI at device shutdown
      LU-13127 libcfs: make noise to console if CRC32 is missing
      LU-13383 ofd: lazy atime update
      LU-11269 ptlrpc: request's counter in import
      LU-13402 target: never exclude MDT/OST from last_rcvd
      LU-13174 tests: sanity-quota to convert minutes into seconds
      LU-13432 tests: test-framework to preserver MODOPTS_LIBCFS
      LU-13246 osd: unlock os_lock if it was locked
      LU-12003 osd: take reference to object in osd_trunc_lock()
      LU-6006 tests: add sleep 1 after command in background
      LU-13557 quota: remove inline declarations

Alexander Boyko (4):
      LU-10395 tests: add test_280 sanity
      LU-13356 client: don't use OBD_CONNECT_MNE_SWAB
      LU-7653 lod: fix stripe allocation during recovery
      LU-13411 llog: allow delete of zero size llog

Alexander Zarochentsev (2):
      LU-13399 lfsck: tune lfsck repair message
      LU-13389 tgt: not rollback obsolete rq

Alexey Lyashkov (3):
      LU-12214 build: fix make rpms
      LU-12214 build: fix build without lustre_utils
      LU-13416 ldiskfs: don't corrupt data on journal replay

Alexey Zhuravlev (1):
      LU-12652 ldiskfs: disable credits check in 4.18

Amir Shehata (10):
      LU-13385 lnet: Calculate IB service-id
      LU-12312 lnet: handle no discovery flag
      LU-10973 lnet: dump cyaml to buffer
      LU-13461 lnet: restrict gateway selection
      LU-10973 lnet: initialize buffers properly
      LU-13471 lnet: use the same src nid for discovery
      LU-13478 lnet: handle discovery off properly
      LU-13477 lnet: Force full discovery cycle
      LU-13472 lnet: set route aliveness properly
      LU-13553 lnd: gracefully handle unexpected events

Andreas Dilger (15):
      LU-11025 tests: only set crush for newer builds
      LU-13169 tests: quiet debug messages during tests
      LU-13404 utils: fix lfs mirror duplicate file check
      LU-12506 mdc: clean up code style for mdc_locks.c
      LU-13417 utils: lfs setdirstripe -D -i -1 should work
      LU-13352 tests: fix subtest duration for ONLY_REPEAT
      LU-10401 tests: fix error from 'tr -d='
      LU-13449 tgt: fix recovery timer comparisons
      LU-13138 tests: measure 'dd' time more accurately
      LU-13168 tests: verify truncated xattr is handled
      LU-13499 obd: fix printing of client connection UUID
      LU-13486 llite: restore ll_dcompare()
      LU-12931 ldlm: use proper units for timeouts
      LU-13427 lmv: do not print MDTs that are inactive
      LU-13187 tests: improve sanity test_129 checking

Andrew Perepechko (1):
      LU-13309 osd-ldiskfs: speedup osd_bufs_get/put

Andriy Skulysh (1):
      LU-13455 ptlrpc: connect to MDT stucks

Arshad Hussain (8):
      LU-6142 fid: Fix style issues for fid_handler.c
      LU-6142 fid: Fix style issues for fid_request.c
      LU-6142 fid: Fix style issues for fid_store.c
      LU-6142 utils: Fix style issues for portals.c
      LU-6142 utils: Fix style issues for lustre_rsync.c
      LU-6142 utils: Fix style issues for obd.c
      LU-6142 utils: Fix style issues for mkfs_lustre.c
      LU-6142 utils: Fix style issues for lustre_cfg.c

Artem Blagodarenko (1):
      LU-12846 tests: verify orphan upgrade compatibilty

Bobi Jam (2):
      LU-13429 lov: lov_io_sub_init()) ASSERTION
      LU-13137 llite: do not flush COW pages from mapping

Bruno Faccini (1):
      LU-13262 ldlm: no current source if lu_ref_del not in same tsk

Chris Horn (10):
      LU-13454 lnet: Handle health stats for reply to optimized GET
      LU-12222 lnet: Introduce constant for the lolnd NID
      LU-12222 lnet: Primary NID of lolnd NID is the lolnd NID
      LU-13502 lnet: Add MD options for response tracking
      LU-12222 ptlrpc: Check if NID is local, not just lolnd NID
      LU-13510 lnet: Correct the default LND timeout
      LU-13510 lnet: Add lnet_lnd_timeout to sysfs
      LU-13510 lnet: Add lnet_lnd_timeout to lnetctl
      LU-13510 lnd: Allow independent ko2iblnd timeout
      LU-13510 lnd: Allow independent socklnd timeout

Elena Gryaznova (4):
      LU-13272 tests: customise dom-performance
      LU-13275 tests: enhance racer with failover
      LU-13445 tests: enhance ha.sh to support different users
      LU-13585 tests: add mustfail check

Emoly Liu (4):
      LU-13425 lfs: support numeric hash type by "lfs migrate -H"
      LU-13375 flr: inherit the correct layout by "mirror extend -N"
      LU-13301 lfs: return error when setstripe -o on inactive OSTs
      LU-13460 lfs: use correct obd index in print_failed_tgt()

Gian-Carlo DeFazio (2):
      LU-13224 utils: expose llapi_param* functions
      LU-13353 quota: add man page for lfs quota

Hongchao Zhang (1):
      LU-13464 target: abort recovery if timer fail

James Nunez (3):
      LU-13097 tests: set fail_loc on all MDS sanityn 43j
      LU-11643 tests: revert new images and tests for upgrade patch
      LU-13065 tests: clean up runtests

James Simmons (20):
      LU-6174 lod: remove incorrect ll_do_div64
      LU-13258 llite: bind readahead workqueue to CPT set
      LU-13274 uapi: make lnet UAPI headers C99 compliant
      LU-6202 obd: replace OBD_IOC_NO_TRANSNO with sysfs file
      LU-12477 kernel: remove dev_read_only handling
      LU-13258 ptlrpc: bind pinger workqueue to CPT set
      LU-9019 obd: express timeouts in timeout_t
      LU-13274 uapi: make lustre UAPI headers pass CONFIG_UAPI_HEADER_TEST
      LU-6142 build: match lnet comment style to linux net layer
      LU-10391 socklnd: properly order headers in socklnd.h
      LU-12477 ldiskfs: last cleanups
      LU-12511 build: avoid building rpm with --disable-modules
      LU-9859 libcfs: handle missing refcount.h
      LU-9859 libcfs: hide struct cfs_cpt_table internals
      LU-9859 libcfs: add support for Xarray
      LU-12511 build: don't use OpenSFS UAPI headers with --disable-modules
      LU-13344 lnet: stop using struct timeval
      LU-6142 libcfs: fix tab and alignment issues for libcfs_string.c
      LU-13258 obdclass: bind zombie export cleanup workqueue
      LU-11621 utils: optimize lhsmtool_posix with copy_file_range()

Jian Yu (5):
      LU-13347 kernel: new kernel [RHEL 7.8 3.10.0-1127.el7]
      LU-13347 kernel: RHEL 7.8 server support
      LU-13421 kernel: kernel update RHEL8.1 [4.18.0-147.8.1.el8_1]
      LU-13405 kernel: kernel update SLES15 SP1 [4.12.14-197.37.1]
      LU-13369 kernel: kernel update RHEL7.7 [3.10.0-1062.18.1.el7]

John L. Hammond (1):
      LU-13238 ofd: add OFD access logs

K?vin Baillergeau (1):
      LU-13433 doc: fix lfs mirror "delete" and "split" doc

Lai Siyao (11):
      LU-11025 dne: refactor dir migration
      LU-11025 lod: refactor lod_mdt_alloc_qos/rr()
      LU-11025 mdt: don't save remote lock if op not from client
      LU-11025 uapi: add OBD_CONNECT2_FIDMAP
      LU-12974 lfsck: dryrun mode shouldn't repair for layout
      LU-11025 obdclass: add lu_device_operations::ldo_fid_alloc()
      LU-11025 osd: osd_attr_get() returns dirent count
      LU-11025 dne: support directory restripe
      LU-13357 lod: implement striped directory .dio_lookup
      LU-13522 mdt: count mdt_mds_mds_conns upon reconnect
      LU-13481 dne: improve temp file name check

Li Dongyang (1):
      LU-13479 kernel: only enable integrity metadata for reads and writes

Mikhail Pershin (6):
      LU-10465 lod: adjust component stripe size
      LU-13424 mdt: fix DOM entry check
      LU-12785 dom: adjust DOM stripe size by free space
      LU-13415 dom: use DoM optimization for DOM+OST files
      LU-13426 mdd: correctly swap OIs during migration
      LU-13535 lfsck: fix possible PFL layout corruption

Mr NeilBrown (56):
      LU-12780 quota: don't use ptlrpc_thread for qmt_reba_thread
      LU-9679 lustre: add OBD_ALLOC_PTR_ARRAY() and others
      LU-10391 lnet: simplify use of lnet_count_acceptor_nets()
      LU-10391 socklnd: use interface index to track local addr
      LU-6142 lustre: make ldebugfs_add_vars a void function
      LU-6142 lustre: remove ldebugfs_seq_create wrapper function
      LU-6142 lustre: remove ldebugfs_register_stats() wrapper
      LU-6142 lustre: remove ldebugfs_add_simple() wrapper.
      LU-6142 lustre: no need to check debugfs return values
      LU-12780 osp: don't use ptlrpc_thread for osp_sync_thread()
      LU-13005 lnet: drop refcounting from event queues.
      LU-13005 lnet: remove lib-eq.
      LU-13005 lnet: remove 'eq' from names, use 'handler'
      LU-13004 lnet: don't embed whole lnet_md in lnet_event
      LU-13005 lnet: Support checking for MD leaks.
      LU-10391 lnet: change lnet_sock_connect to take sockaddr
      LU-13004 lnet: merge lnet_md_alloc into lnet_md_build.
      LU-13004 lnet: always put a page list into struct lnet_libmd
      LU-13004 lnet: discard kvec option from lnet_libmd.
      LU-13004 lnet: remove msg_iov from lnet_msg.
      LU-13004 lnet: remove the 'struct kvec' arg from lnd_send
      LU-9679 osd: use OBD_ALLOC_PTR_ARRAY() and others
      LU-6142 lustre: Remove inappropriate uses of BIT() macro.
      LU-12780 target: don't use ptlrpc_thread for txn_commit_thread
      LU-9859 libcfs: remove conditional compilation from libcfs_cpu.c
      LU-9679 obdclass: use OBD_ALLOC_PTR_ARRAY() and others
      LU-9679 various: use OBD_ALLOC_PTR_ARRAY() and others
      LU-6142 libcfs: use BIT() macro where appropriate
      LU-6142 lnet: use BIT() macro where appropriate
      LU-6142 osd-zfs: convert container_of0() to container_of()
      LU-10467 llite: clean up pcc_layout_wait()
      LU-6142 misc: declare static chars as const where possible.
      LU-9859 libcfs: replace memory_presure functions by standard interfaces
      LU-11310 ldiskfs: Repair support for SUSE 15 GA and SP1
      LU-12477 ldiskfs: finish removing HAVE_CLEAR_RDONLY_ON_PUT
      LU-9679 lodlov: use OBD_ALLOC_PTR_ARRAY() and others
      LU-9679 target: use OBD_ALLOC_PTR_ARRAY() and FREE
      LU-6142 kernel: use kmem_cache_zalloc as appropriate.
      LU-13004 lnet: remove lnet_extract_iov()
      LU-13004 lnet: remove lnet_copy_flat2iov and ..iov2flat
      LU-13004 lnet: simplify ksock_tx.
      LU-13004 socklnd: discard tx_iov.
      LU-9859 libcfs: discard cfs_block_sigsinv()
      LU-9859 libcfs: move tcd locking across to tracefile.c
      LU-9679 mdt: use OBD_ALLOC_PTR_ARRAY() and FREE
      LU-9679 ptlrpc: use OBD_ALLOC_PTR_ARRAY() and FREE
      LU-6142 lustre: use BIT() macro where appropriate in include
      LU-6142 lustre: use BIT() macro where appropriate
      LU-6142 osd-ldiskfs: convert container_of0() to container_of()
      LU-6142 lustre: convert some container_of0 to container_of
      LU-10467 ptlrpc: change LONG_UNLINK to PTLRPC_REQ_LONG_UNLINK
      LU-6142 llite: use %pd to report dentry names.
      LU-9679 lnet: tidy lnet_discover and fix mem accounting bug.
      LU-13004 gnilnd: discard struct kvec arg.
      LU-13004 gnilnd: remove support for GNILND_BUF_VIRT_*
      LU-13004 lnet: always pass struct lnet_md by reference.

Nathaniel Clark (1):
      LU-12100 tests: Use least qunit to set limit

NeilBrown (3):
      LU-9679 osc: convert oe_refc to kref
      LU-4801 ldlm: discard l_lock from struct ldlm_lock.
      LU-9859 libcfs: make signal-blocking functions inline

Oleg Drokin (7):
      LU-13131 osc: Always send all HP RPCs requests
      LU-9868 llite: Get rid of ll_dcompare
      Revert "LU-4801 ldlm: discard l_lock from struct ldlm_lock."
      LU-13470 ptlrpc: return proper write count from ping_store
      LU-13131 osc: Do not wait for grants for too long
      LU-13131 osc: Ensure immediate departure of sync write pages
      New tag 2.13.54

Patrick Farrell (1):
      LU-13134 clio: cl_page index compaction

Qian Yingjin (2):
      LU-11971 utils: Send file creation time to clients
      LU-10934 llite: integrate statx() API with Lustre

Sam Atkinson (1):
      LU-13441 osd-zfs: remove OSD thread info cache size assertion

Sebastien Buisson (12):
      LU-13156 tests: wait for nodemap update in sanity-selinux
      LU-13430 vfs: add ll_vfs_getxattr/ll_vfs_setxattr compat macro
      LU-13431 llite: rework preferred IO size
      LU-12275 sec: add llcrypt as file encryption library
      LU-12730 tests: sync file before checking LSOM
      LU-13064 sec: check permissions for changelogs access
      LU-13465 mgs: re-introduce mgs_set_info for interop purpose
      LU-13465 vfs: make ll_vfs_setxattr return -EOPNOTSUPP
      LU-13466 mgc: protect from NULL exp in mgc_enqueue()
      LU-12854 nodemap: allow boolean value for audit_mode
      LU-13549 build: fix zfs/spl config checks
      LU-13528 llite: prevent MAX_DIO_SIZE 32-bit truncation

Sergey Cheremencev (2):
      LU-930 doc: update MAINTAINERS and mailmap
      LU-11023 quota: quota pools for OSTs

Shaun Tancheff (6):
      LU-13418 gnilnd: CFS_ALLOC_PTR_ARRAY typos
      LU-13423 tests: cleanup_netns correctly set result
      LU-13004 lnet: Correct signature in gnilnd.h
      LU-13539 all: Cleanup LASSERTF uses missing newlines
      LU-13485 build: Enable 2 stage configure tests
      LU-13555 build: Map mainline kernel on rhel to rhel

Swapnil Pimpale (1):
      LU-3606 fallocate: Implement fallocate preallocate operation

Vitaly Fertman (3):
      LU-13388 lod: unprotected access to component entries
      LU-13366 doc: add SEL options to util's man pages
      LU-13366 utils: SEL yaml and copy file support

Vladimir Saveliev (1):
      LU-13279 tests: sanityn.sh:test_20 takes DoM into account

Wang Shilong (10):
      LU-13134 obdclass: use slab allocation for cl_page
      LU-13377 llite: fix dead loop for short write
      LU-13386 llite: allow current readahead to exceed reservation
      LU-13394 llite: avoid sending OST RPC for project setting
      LU-12043 llite: fix to submit complete read block with ra disabled
      LU-13373 llite: fix to verify write in ll_file_get_iov_count()
      LU-13490 lustre: fix to make jobstats work for async ra
      LU-13541 llite: fix possible divide zero in ll_use_fast_io()
      LU-13493 llite: check if page truncated in ll_write_begin()
      LU-13412 llite: fix read if readahead window smaller than rpc size

Wei Liu (2):
      LU-11643 tests: add new images and tests for upgrade tests
      LU-12662 tests: Add new pjdfstest into tests

Yang Sheng (6):
      LU-11814 obd: Crashed while mount in parallel
      LU-12846 mdd: return error while delete failed
      LU-13349 llite: statahead should skip entry while fid changed
      LU-13054 ldiskfs: htree_node wrongly granted
      LU-13054 ldiskfs: split htree_lock as separate patch
      LU-10401 tests: add -F so list_param prints entry type
