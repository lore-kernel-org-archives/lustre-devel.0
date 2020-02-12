From: Oleg Drokin <green@whamcloud.com>
Date: Wed, 12 Feb 2020 06:22:23 +0000
Subject: [lustre-devel] New tag 2.13.52
Message-ID: <FFAF5468-1DB5-48DB-8CDC-5EF0ECEA7FA8@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

I just tagged 2.13.52 in Lustre development branch. Here?s the changelog:

Alex Zhuravlev (5):
      LU-13098 ptlrpc: supress connection restored message
      LU-13130 tests: sanity-scrub to use full device size with ZFS
      LU-12133 osd-zfs: set blocksize to 8K for llog objects
      LU-12988 ldiskfs: skip non-loaded groups at cr=0/1
      LU-12988 ldiskfs: mballoc to prefetch groups

Alexander Boyko (2):
      LU-13093 osd: fix osd_attr_set race
      LU-12593 osd: up i_append_sem during errors

Alexander Zarochentsev (1):
      LU-13128 osc: glimpse and lock cancel race

Alexey Lyashkov (3):
      LU-12214 selinux: Remove concatenating of selinux context
      LU-12991 lnet: lnet response entries leak
      LU-13036 lnet: avoid extra memory consumption

Amir Shehata (1):
      LU-13049 lnet: peer lookup handle shutdown

Andreas Dilger (11):
      LU-12865 tests: fix sanity 160f to be more robust
      LU-8066 lfsck: use underscores in lfsck status files
      LU-12470 tests: increase pdirops timeout
      LU-12521 llapi: add separate fsname and instance API
      Revert "LU-13120 build: Fix ZFS dependancies for osd-zfs-mount"
      LU-11644 ptlrpc: show target name in req_history
      LU-12518 llite: proper names/types for offset/pages
      LU-12871 mdd: enable Changelog garbage collection
      LU-13164 uapi: remove unused LUSTRE_DIRECTIO_FL
      LU-13063 tests: remove checks for old RHEL versions
      LU-13145 lnet: use conservative health timeouts

Andriy Skulysh (3):
      LU-7791 ldlm: signal vs CP callback race
      LU-13101 llite: eviction during ll_open_cleanup()
      LU-13165 mdt: MSG_RESENT can be improperly cleared.

Arshad Hussain (1):
      LU-12923 libcfs: Remove CLASSERT() for libcfs_private.h

Chris Horn (7):
      LU-12756 lnet: Avoid extra lnet_remotenet lookup
      LU-12756 lnet: Remove unused vars in lnet_find_route_locked
      LU-12756 lnet: Refactor lnet_compare_routes
      LU-12919 lnet: Fix source specified route selection
      LU-13147 tests: Cleanup sanity-lnet on test failure
      Revert "LU-12222 lnet: Check if we're sending to ourselves"
      LU-12889 lnet: Do not assume peers are MR capable

Emoly Liu (1):
      LU-12852 pfl: restrict the stripe count correctly

James Nunez (7):
      LU-12928 tests: start running recovery-small 136
      LU-13053 tests: fix conf-sanity call to  umount_ldiskfs
      LU-13063 tests: stop running sanity test 411
      LU-1538 tests: standardize test script init ? failover
      LU-13194 tests: check server version sanityn 104
      LU-10447 tests: deprecate use of $SETSTRIPE/$GETSTRIPE
      LU-11607 tests: replace version/fstype calls in sanity/n

James Simmons (5):
      LU-13119 osd-ldiskfs: set f_cred for app armour
      LU-12822 uapi: properly pack data structures
      LU-12977 ldiskfs: properly take inode_lock() for truncates
      LU-9859 libcfs: move files out of libcfs/linux
      LU-12598 osd-ldiskfs: always return errors for osd_ios_lf_fill

Jian Yu (1):
      LU-12791 kernel: kernel update RHEL 8.0 [4.18.0-80.11.2.el8_0]

Jinshan Xiong (2):
      LU-4198 clio: turn on lockless for some kind of IO
      LU-4198 clio: AIO support for direct IO

Lai Siyao (3):
      LU-13121 llite: fix deadlock in ll_update_lsm_md()
      LU-13163 mdc: new kernel function xa_is_value()
      LU-13191 osp: handle -EROFS in osp_sync_interpret()

Mikhail Pershin (4):
      LU-13115 mdt: handle mdt_pack_sectx_in_reply() errors
      LU-10664 tests: fix MPI tests in dom-performance.sh
      LU-13136 dom: check read-on-open buffer presents in reply
      LU-10198 llog: keep llog handle alive until last reference

Mr NeilBrown (25):
      LU-9679 llite: fix possible race with module unload.
      LU-13004 ptlrpc: Allow BULK_BUF_KIOV to accept a kvec
      LU-13005 lnet: discard LNetEQGet and LNetEQWait
      LU-10467 ptlrpc: refactor waiting in ptlrpc_set_wait()
      LU-12678 socklnd: initialize the_ksocklnd at compile-time.
      LU-12678 lnet: make "struct lnet_lnd" always "const".
      LU-12678 lnet: remove locking protection ln_testprotocompat
      LU-10467 obdclass: convert waiting in cl_sync_io_wait().
      LU-9679 modules: use list_move were appropriate.
      LU-13004 target: convert tgt_send_buffer to use KIOV
      LU-12678 lnet: remove dead code: lnet_fini_locks()
      LU-12678 lnet: fix small race in unloading klnd modules.
      LU-12678 lnet: me: discard struct lnet_handle_me
      LU-12678 socklnd: convert peers hash table to hashtable.h
      LU-10467 lustre: convert most users of LWI_TIMEOUT_INTERVAL()
      LU-10467 lustre: convert users of back_to_sleep()
      LU-10467 ptlrpc: convert waiters on set->set_waitq
      LU-10467 ldlm: convert waiting in ldlm_flock_completion_ast()
      LU-10467 ldlm: convert waiting in ldlm_completion_ast()
      LU-10467 ptlrpc: convert use of l_wait_event_exclusive_head()
      LU-9679 general: add missing spaces to folded strings.
      LU-9679 lnet: discard lnet_print_text_bufs()
      LU-9679 lnet: use LIST_HEAD() for local lists.
      LU-9679 lustre: use LIST_HEAD() for local lists.
      LU-11300 lnet: remove lnd_query interface.

NeilBrown (6):
      LU-8130 lu_object: factor out extra per-bucket data
      LU-12460 llite: replace lli_trunc_sem
      LU-12542 handle: remove locking from class_handle2object()
      LU-12542 handle: use hlist for hash lists.
      LU-12542 handle: discard h_lock.
      LU-8304 libcfs: convert debug_ctlwq to a completion.

Olaf Faaland (1):
      LU-11114 llite: Update mdc and lite stats on open|creat

Oleg Drokin (1):
      New tag 2.13.52

Patrick Farrell (2):
      LU-12518 llite: Accept EBUSY for page unaligned read
      LU-11939 tgt: Do not assert during grant cleanup

Quentin Bouget (1):
      LU-12806 llapi: use name_to_handle_at in llapi_fd2fid

Sebastien Buisson (2):
      LU-13152 llapi: llapi_layout_get_by_xattr groks DoM
      LU-13142 lod: cleanup layout checking

Serguei Smirnov (1):
      LU-11385 odbclass: Handle gracefully if nsproxy is NULL

Shaun Tancheff (8):
      LU-13039 quota: Ensure local buffer is null terminated
      LU-13141 ldiskfs: block alloc performance patch
      LU-12904 ldiskfs: Add ldiskfs support for linux 5.4
      LU-12968 mgs: Prevent reading past end of buffer
      LU-13120 build: Fix ZFS dependancies for osd-zfs-mount
      LU-12861 libcfs: Cleanup use of bare printk
      LU-12634 gss: uid_keyring and session_keyring moved
      LU-13183 ldiskfs: Drop remove truncate warning patch

Swapnil Pimpale (2):
      LU-3606 fsx: Add fallocate operation to fsx
      LU-3606 lustre: Reserve OST_FALLOCATE(fallocate) opcode

Tatsushi Takamura (1):
      LU-12287 lnet: handling device failure by IB event handler

Vitaly Fertman (1):
      LU-11276 ldlm: fix lock convert races

Vladimir Saveliev (1):
      LU-13099 lmv: disable statahead for remote objects

Wang Shilong (5):
      LU-13092 lbuild: include lbuild-{fc,rhel,sles} to SIGNATURE
      LU-13117 libcfs: fix to match right key in cfs_get_environ()
      LU-13154 test: skip sanity-quota 66 if MDS version < 2.12.4
      LU-13134 obdclass: use slab allocation for cl_dio_aio
      LU-13180 lustre: reserve bit for RDMA-only memory RPC
