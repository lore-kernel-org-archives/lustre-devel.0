From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:36:59 -0400
Subject: [lustre-devel] [PATCH 000/124] missing patches from Lustre 2.7
	release
Message-ID: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

This batch of patches includes various cleanups and fixes from
the Lustre 2.7 release. Most of these patches are removal of
cruft and unsigned to signed comparsion fixes. Also added in
the latest LNet fixes as well.

Alexander Boyko (3):
  staging: lustre: at: net AT after connect
  staging: lustre: mgc: add nid iteration
  staging: lustre: ptlrpc: fix race between connect vs resend

Alexander Zarochentsev (1):
  staging: lustre: obdclass: optimize busy loop wait

Alexey Lyashkov (1):
  staging: lustre: ldlm: evict clients returning errors on ASTs

Amir Shehata (1):
  staging: lustre: ptlrpc: Suppress error message when imp_sec is freed

Andreas Dilger (3):
  staging: lustre: build: bump build version warnings to x.y.53
  staging: lustre: ptlrpc: quiet errors on initial connection
  staging: lustre: lprocfs: cleanup stats locking code

Artem Blagodarenko (1):
  staging: lustre: client: Fix mkdir -i 1 from DNE2 client to DNE1 server

Bob Glossman (2):
  staging: lustre: llite: fix dup flags names
  staging: lustre: obdclass: eliminate NULL error return

Bobi Jam (7):
  staging: lustre: llite: update ras stride offset
  staging: lustre: clio: lu_ref_del() mismatch ref add scope
  staging: lustre: fiemap: set FIEMAP_EXTENT_LAST correctly
  staging: lustre: clio: add coo_getstripe interface
  staging: lustre: osc: osc_object_ast_clear() LBUG
  staging: lustre: clio: rename coo_attr_set to coo_attr_update
  staging: lustre: clio: pass fid for OST setattr

Dmitry Eremin (18):
  staging: lustre: fix comparison between signed and unsigned
  staging: lustre: obdclass: fix comparison between signed and unsigned
  staging: lustre: llite: Compare of unsigned value against 0 is always true
  staging: lustre: obd: change type of lmv_tgt_desc->ltd_idx to u32
  staging: lustre: lmv: change type of lmv_obd->tgts_size to u32
  staging: lustre: lmv: remove dead code
  staging: lustre: mdc: fix comparison between signed and unsigned
  staging: lustre: ldlm: count of pools is unsigned long
  staging: lustre: lu_dirent_calc_size() return type to size_t
  staging: lustre: obdclass: change lu_site->ls_purge_start to unsigned
  staging: lustre: changelog: fix comparison between signed and unsigned
  staging: lustre: obdclass: lu_htable_order() return type to long
  staging: lustre: obdclass: change loop indexes to unsigned
  staging: lustre: obd: change brw_page->count to unsigned
  staging: lustre: obdclass: change cl_fault_io->ft_nob to size_t
  staging: lustre: ptlrpc: fix comparison between signed and unsigned
  staging: lustre: osc: change cl_extent_tax and *grants to unsigned
  staging: lustre: obd: change type of cl_conn_count to size_t

Doug Oucharek (3):
  staging: lustre: lnet: Ensure routing is turned on first time
  staging: lustre: lnet: Enable setting per NI peer_credits
  staging: lustre: o2iblnd: Put back work queue check previously removed

Fan Yong (3):
  staging: lustre: lmv: move some inline functions to lustre_lmv.h
  staging: lustre: lmv: add testing for bad name hash
  staging: lustre: llite: pack suppgid to MDS correctly

Henri Doreau (4):
  staging: lustre: mdc: Report D_CHANGELOG messages as D_HSM
  staging: lustre: Flexible changelog format.
  staging: lustre: llite: Add ioctl to get parent fids from link EA.
  staging: lustre: changelog: Proper record remapping

James Simmons (4):
  staging: lustre: ldlm: restore some of the interval functionality
  staging: lustre: obd: restore linkea support
  staging: lustre: obd: use proper flags for call_usermodehelper
  staging: lustre: update version to 2.5.99

Jian Yu (1):
  staging: lustre: replace direct HZ access with kernel APIs

Jinshan Xiong (4):
  staging: lustre: lov: adjust page bufsize after layout change
  staging: lustre: llite: allow setting stripes to specify OSTs
  staging: lustre: ldlm: revert the changes for lock canceling policy
  staging: lustre: ldlm: move LDLM_GID_ANY to lustre_dlm.h

Johann Lombardi (1):
  staging: lustre: grant: quiet message on grant waiting timeout

John L. Hammond (27):
  staging: lustre: ldlm: fix a use after free in ldlm_resource_get()
  staging: lustre: obd: add lnb_ prefix to members of struct niobuf_local
  staging: lustre: obd: add rnb_ prefix to struct niobuf_remote members
  staging: lustre: llite: add LL_LEASE_{RD,WR,UN}LCK
  staging: lustre: lmv: fix some byte order issues
  staging: lustre: lmv: release locks if lmv_intent_lock() fails
  staging: lustre: lmv: release request in lmv_revalidate_slaves()
  staging: lustre: remove RCU2HANDLE macro
  staging: lustre: llite: remove lookup_flags from ll_lookup_it()
  staging: lustre: llite: remove mode from ll_create_it()
  staging: lustre: llite: turn mode to umode_t for ll_new_inode()
  staging: lustre: llite: style cleanup for ll_mkdir
  staging: lustre: llite: no need to check dentry is NULL
  staging: lustre: cleanup lustre_lib.h
  staging: lustre: remove lustre_lite.h
  staging: lustre: obd: rename LUSTRE_STRIPE_MAXBYTES
  staging: lustre: llite: don't call make_bad_inode() on an old inode
  staging: lustre: obd: cleanup struct md_op_data and uses
  staging: lustre: lov: remove LL_IOC_RECREATE_{FID,OBJ}
  staging: lustre: lov: remove unused {get,set}_info handlers
  staging: lustre: fix messages with missing newlines
  staging: lustre: obd: remove unused obd methods
  staging: lustre: echo: replace lov_stripe_md with lov_oinfo
  staging: lustre: llite: remove ll_objects_destroy()
  staging: lustre: lov: flatten struct lov_stripe_md
  staging: lustre: llite: unlock inode size in ll_lov_setstripe_ea_info()
  staging: lustre: remove lustre/include/linux/

Lai Siyao (5):
  staging: lustre: statahead: statahead thread wait for RPCs to finish
  staging: lustre: statahead: use dcache-like interface for sa entry
  staging: lustre: statahead: ll_intent_drop_lock() called in spinlock
  staging: lustre: statahead: race in start/stop statahead
  staging: lustre: statahead: small fixes and cleanup

Li Xi (4):
  staging: lustre: llite: fix ll_statahead_thread() problems on failure
  staging: lustre: ptlrpc: enlarge OST_MAXREQSIZE for 4MB RPC
  staging: lustre: llog: add newly opened llog at tail of handle list
  staging: lustre: llite: enforce pool name length limit

Liang Zhen (1):
  staging: lustre: libcfs: check mask returned by cpumask_of_node

Mikhail Pershin (1):
  staging: lustre: ptlrpc: prevent request timeout grow due to recovery

Nathaniel Clark (1):
  staging: lustre: ldlm: Recalculate interval in ldlm_pool_recalc()

Ned Bass (2):
  staging: lustre: llite: make default_easize writeable in /sysfs
  staging: lustre: mdc: cl_default_mds_easize not refreshed

Niu Yawei (3):
  staging: lustre: obdclass: serialize lu_site purge
  staging: lustre: osc: update kms in brw_interpret() properly
  staging: lustre: recovery: don't replay closed open

Patrick Farrell (1):
  staging: lustre: osc: debug to match extent to brw RPC

Prakash Surya (2):
  staging: lustre: llite: Replace write mutex with range lock
  staging: lustre: vvp: Use lockless __generic_file_aio_write

Quentin Bouget (1):
  staging: lustre: lnet: potential deadlock in lnet

Sebastien Buisson (1):
  staging: lustre: lnet: check if ni is in current net namespace

Stephen Champion (2):
  staging: lustre: misc: Reduce exposure to overflow on page counters.
  staging: lustre: llite: handle concurrent use of cob_transient_pages

Vitaly Fertman (3):
  staging: lustre: ldlm: reconstruct proper flags on enqueue resend
  staging: lustre: ldlm: resend AST callbacks
  staging: lustre: ldlm: per-export lock callback timeout

Wang Shilong (1):
  staging: lustre: ptlrpc: fix magic return value of ptlrpc_init_portals

Yang Sheng (1):
  staging: lustre: llite: ensure all data flush out when umount

Yoshifumi Uemura (1):
  staging: lustre: mdc: Proper accessing struct lov_user_md

frank zago (4):
  staging: lustre: llog: prevent out-of-bound index
  staging: lustre: misc: remove unnecessary EXPORT_SYMBOL
  staging: lustre: obdclass: remove unnecessary EXPORT_SYMBOL
  staging: lustre: ptlrpc: remove unnecessary EXPORT_SYMBOL

wang di (6):
  staging: lustre: lmv: honor MDT index when creating volatile file
  staging: lustre: lmv: Do not ignore ENOENT in lmv_unlink
  staging: lustre: lmv: Do not revalidate stripes with master lock
  staging: lustre: llite: lock the inode to be migrated
  staging: lustre: mdt: add indexing option to default dir stripe
  staging: lustre: lmv: fix parent FID for migration

 .../lustre/include/linux/libcfs/libcfs_private.h   |   12 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |    2 +
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   10 +
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   |   17 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   46 +-
 drivers/staging/lustre/lnet/lnet/config.c          |   14 +
 drivers/staging/lustre/lnet/lnet/lib-md.c          |   24 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   11 +
 drivers/staging/lustre/lnet/lnet/router.c          |   10 +-
 drivers/staging/lustre/lustre/fid/fid_lib.c        |    2 -
 drivers/staging/lustre/lustre/fld/fld_request.c    |    2 -
 drivers/staging/lustre/lustre/include/cl_object.h  |   29 +-
 .../staging/lustre/lustre/include/interval_tree.h  |   26 +
 .../lustre/lustre/include/linux/lustre_lite.h      |   91 --
 .../lustre/lustre/include/linux/lustre_user.h      |   66 -
 .../staging/lustre/lustre/include/lprocfs_status.h |  134 ++-
 drivers/staging/lustre/lustre/include/lu_object.h  |   16 +-
 .../lustre/lustre/include/lustre/lustre_idl.h      |   57 +-
 .../lustre/lustre/include/lustre/lustre_user.h     |  254 +++-
 drivers/staging/lustre/lustre/include/lustre_cfg.h |   26 +-
 .../{linux/lustre_compat25.h => lustre_compat.h}   |    6 +-
 drivers/staging/lustre/lustre/include/lustre_dlm.h |    5 +
 .../staging/lustre/lustre/include/lustre_eacl.h    |    1 +
 .../staging/lustre/lustre/include/lustre_handles.h |    2 -
 .../staging/lustre/lustre/include/lustre_import.h  |    2 +
 drivers/staging/lustre/lustre/include/lustre_lib.h |   36 -
 .../staging/lustre/lustre/include/lustre_linkea.h  |   79 ++
 .../staging/lustre/lustre/include/lustre_lite.h    |   85 --
 drivers/staging/lustre/lustre/include/lustre_lmv.h |   69 +-
 drivers/staging/lustre/lustre/include/lustre_mdc.h |   37 +-
 drivers/staging/lustre/lustre/include/lustre_net.h |   56 +-
 .../staging/lustre/lustre/include/lustre_param.h   |    3 +
 .../include/{linux => }/lustre_patchless_compat.h  |    0
 .../lustre/lustre/include/lustre_req_layout.h      |   20 +-
 drivers/staging/lustre/lustre/include/lustre_ver.h |    6 +-
 drivers/staging/lustre/lustre/include/obd.h        |  213 ++--
 drivers/staging/lustre/lustre/include/obd_class.h  |   65 +-
 .../staging/lustre/lustre/include/obd_support.h    |    9 +-
 drivers/staging/lustre/lustre/ldlm/interval_tree.c |  100 ++-
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |    3 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |    2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |    8 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    5 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |    5 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |   45 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   70 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    9 +-
 drivers/staging/lustre/lustre/llite/Makefile       |    2 +-
 drivers/staging/lustre/lustre/llite/dcache.c       |    6 +-
 drivers/staging/lustre/lustre/llite/dir.c          |   39 +-
 drivers/staging/lustre/lustre/llite/file.c         |  323 ++---
 drivers/staging/lustre/lustre/llite/glimpse.c      |    1 -
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |    2 +-
 drivers/staging/lustre/lustre/llite/lcommon_misc.c |    1 -
 drivers/staging/lustre/lustre/llite/llite_close.c  |    1 -
 .../staging/lustre/lustre/llite/llite_internal.h   |  299 +++--
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  247 +++-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |    2 -
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |    1 -
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  104 ++-
 drivers/staging/lustre/lustre/llite/namei.c        |  201 ++--
 drivers/staging/lustre/lustre/llite/range_lock.c   |  233 ++++
 drivers/staging/lustre/lustre/llite/range_lock.h   |   82 ++
 drivers/staging/lustre/lustre/llite/rw.c           |   20 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |   19 +-
 drivers/staging/lustre/lustre/llite/statahead.c    | 1391 +++++++++-----------
 drivers/staging/lustre/lustre/llite/super25.c      |    1 -
 drivers/staging/lustre/lustre/llite/symlink.c      |    1 -
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |    1 -
 drivers/staging/lustre/lustre/llite/vvp_internal.h |    9 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |   31 +-
 drivers/staging/lustre/lustre/llite/vvp_lock.c     |    1 -
 drivers/staging/lustre/lustre/llite/vvp_object.c   |   13 +-
 drivers/staging/lustre/lustre/llite/vvp_page.c     |   22 +-
 drivers/staging/lustre/lustre/llite/vvp_req.c      |    3 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |   20 +-
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |    1 -
 drivers/staging/lustre/lustre/lmv/lmv_fld.c        |   16 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |   94 +-
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |   17 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  310 +++--
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c      |    2 +-
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |   10 +-
 drivers/staging/lustre/lustre/lov/lov_dev.c        |    1 -
 drivers/staging/lustre/lustre/lov/lov_ea.c         |   14 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h   |    9 -
 drivers/staging/lustre/lustre/lov/lov_io.c         |    3 +
 drivers/staging/lustre/lustre/lov/lov_merge.c      |   39 -
 drivers/staging/lustre/lustre/lov/lov_obd.c        |  289 +----
 drivers/staging/lustre/lustre/lov/lov_object.c     |   49 +-
 drivers/staging/lustre/lustre/lov/lov_pack.c       |   60 +-
 drivers/staging/lustre/lustre/lov/lov_request.c    |   78 --
 drivers/staging/lustre/lustre/lov/lovsub_object.c  |    6 +-
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |   30 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   29 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |   19 +-
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |   19 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   74 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |   27 +-
 drivers/staging/lustre/lustre/obdclass/Makefile    |    2 +-
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |    7 +-
 drivers/staging/lustre/lustre/obdclass/cl_object.c |   48 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |   16 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |   15 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    |    8 -
 drivers/staging/lustre/lustre/obdclass/linkea.c    |  201 +++
 .../lustre/lustre/obdclass/linux/linux-module.c    |    3 +-
 .../lustre/lustre/obdclass/linux/linux-sysctl.c    |    3 +-
 drivers/staging/lustre/lustre/obdclass/llog.c      |    8 +-
 drivers/staging/lustre/lustre/obdclass/llog_cat.c  |    6 +-
 .../staging/lustre/lustre/obdclass/llog_internal.h |    5 +
 drivers/staging/lustre/lustre/obdclass/llog_obd.c  |    1 -
 drivers/staging/lustre/lustre/obdclass/llog_swab.c |   25 +-
 .../lustre/lustre/obdclass/lprocfs_status.c        |    2 -
 drivers/staging/lustre/lustre/obdclass/lu_object.c |  117 ++-
 .../lustre/lustre/obdclass/lustre_handles.c        |    7 +-
 .../staging/lustre/lustre/obdclass/lustre_peer.c   |    1 -
 .../staging/lustre/lustre/obdclass/obd_config.c    |   15 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |    6 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |  168 +--
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |   31 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  144 ++-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |    4 +-
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    6 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |   37 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |    4 +-
 drivers/staging/lustre/lustre/osc/osc_object.c     |    7 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |   88 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |  296 +----
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  113 +-
 drivers/staging/lustre/lustre/ptlrpc/connection.c  |    5 -
 drivers/staging/lustre/lustre/ptlrpc/events.c      |    6 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |  316 +++---
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |   83 +-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |   33 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |  147 +--
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |    1 -
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |    9 +-
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |    2 -
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |   26 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |   13 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c  |    1 -
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |    5 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |   13 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |   80 +-
 145 files changed, 4253 insertions(+), 3944 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/include/linux/lustre_lite.h
 delete mode 100644 drivers/staging/lustre/lustre/include/linux/lustre_user.h
 rename drivers/staging/lustre/lustre/include/{linux/lustre_compat25.h => lustre_compat.h} (96%)
 create mode 100644 drivers/staging/lustre/lustre/include/lustre_linkea.h
 delete mode 100644 drivers/staging/lustre/lustre/include/lustre_lite.h
 rename drivers/staging/lustre/lustre/include/{linux => }/lustre_patchless_compat.h (100%)
 create mode 100644 drivers/staging/lustre/lustre/llite/range_lock.c
 create mode 100644 drivers/staging/lustre/lustre/llite/range_lock.h
 create mode 100644 drivers/staging/lustre/lustre/obdclass/linkea.c
