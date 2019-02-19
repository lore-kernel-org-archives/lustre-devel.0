From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Feb 2019 11:09:04 +1100
Subject: [lustre-devel] [PATCH 00/37] More lustre patches from obdclass
Message-ID: <155053473693.24125.6976971762921761309.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

These patches are all a result of my reading of obdclass code,
though some of them extend will beyond obdclass.
One has been posted already but was buggy, another few replace
an earlier patch which, as James pointed out, didn't really
go far enough.

I've done some testing (and found a bug) but haven't completed a full
test run yet.  So both comments and testing most welcome.

NeilBrown

---

NeilBrown (37):
      lustre: obdclass: char obd_ioctl_getdata type.
      lustre: llite: don't use class_setup_tunables()
      lustre: embed typ_kobj if obd_type
      lustre: collect all resource releasing for obj_type.
      lustre: obd_type: use typ_kobj.name as typ_name
      lustre: obd_type: discard obd_types linked list.
      lustre: obd_type: discard obd_type_lock
      lustre: obdclass: don't copy ops structures in to new type.
      lustre: obdclass: fix module load locking.
      lustre: kernelcomm: pass correct gfp_t to kmalloc.
      lustre: kernelcomm: make libcfs_kkuc_msg_put static.
      lustre: remove unused function in linkea.
      lustre: llog: remove lgh_hdr_lock.
      lustre: llog: change lgh_refcount to struct kref.
      lustre: llog_obd: Convert loc_refcount to refcount_t
      lustre: obdclass: typo: Banlance -> Balance
      lustre: simplify lprocfs_read_frac_helper.
      lustre: obdclass: discard lprocfs_single/seq_release
      lustre: discard lprocfs_strnstr()
      lustre: convert rsi_sem to a spinlock.
      lustre: remove several MAX_STRING_SIZE defines.
      lustre: lprocfs: use log2.h macros instead of shift loop.
      lustre: prefer to use tabs for alignment.
      lustre: lu_object: remove extra newline from debug printing.
      lustre: deprecate libcfs_debug_vmsg2
      lustre: remove libcfs_debug_vmsg2
      lustre: discard lu_ref
      lustre: remove scope and source from class_incref and class_decref.
      lustre: handles: discard h_owner in favour of h_ops
      lustre: handle: move refcount into the lustre_handle.
      lustre: discard OBD_FREE_RCU
      lustre: portals_handle: rename ops to owner
      lustre: portals_handle: remove locking from class_handle2object()
      lustre: portals_handle: use hlist for hash lists.
      lustre: portals_handle: discard h_lock.
      lustre: remove unused fields from struct obd_device
      lustre: obd_sysfs: error-check value stored in jobid_var


 .../lustre/include/linux/libcfs/libcfs_cpu.h       |    2 
 .../lustre/include/linux/libcfs/libcfs_crypto.h    |   10 -
 .../lustre/include/linux/libcfs/libcfs_debug.h     |   35 +-
 .../lustre/include/linux/libcfs/libcfs_fail.h      |   12 -
 .../lustre/include/linux/libcfs/libcfs_hash.h      |   24 +
 .../lustre/include/linux/libcfs/libcfs_private.h   |    2 
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    4 
 .../staging/lustre/include/linux/lnet/socklnd.h    |    2 
 .../lustre/include/uapi/linux/lnet/libcfs_debug.h  |  124 +++----
 .../lustre/include/uapi/linux/lnet/libcfs_ioctl.h  |   56 +--
 .../lustre/include/uapi/linux/lnet/lnet-types.h    |   10 -
 .../lustre/include/uapi/linux/lnet/lnetst.h        |   14 -
 .../lustre/include/uapi/linux/lnet/nidstr.h        |    6 
 .../include/uapi/linux/lustre/lustre_fiemap.h      |    2 
 .../lustre/include/uapi/linux/lustre/lustre_idl.h  |  350 +++++++++----------
 .../lustre/include/uapi/linux/lustre/lustre_user.h |  378 ++++++++++----------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   60 ++-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |   32 +-
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |   63 +--
 drivers/staging/lustre/lnet/libcfs/tracefile.h     |    2 
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |    4 
 drivers/staging/lustre/lnet/selftest/timer.c       |    8 
 drivers/staging/lustre/lustre/fld/lproc_fld.c      |    2 
 drivers/staging/lustre/lustre/include/cl_object.h  |    6 
 .../staging/lustre/lustre/include/lprocfs_status.h |    7 
 drivers/staging/lustre/lustre/include/lu_object.h  |   45 --
 drivers/staging/lustre/lustre/include/lu_ref.h     |  178 ---------
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   26 -
 .../staging/lustre/lustre/include/lustre_export.h  |    1 
 .../staging/lustre/lustre/include/lustre_handles.h |   22 -
 .../staging/lustre/lustre/include/lustre_import.h  |    8 
 .../lustre/lustre/include/lustre_kernelcomm.h      |    1 
 .../staging/lustre/lustre/include/lustre_linkea.h  |    8 
 drivers/staging/lustre/lustre/include/lustre_log.h |   21 -
 drivers/staging/lustre/lustre/include/lustre_net.h |    4 
 drivers/staging/lustre/lustre/include/obd.h        |   62 +--
 drivers/staging/lustre/lustre/include/obd_class.h  |   18 -
 .../staging/lustre/lustre/include/obd_support.h    |   10 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |    2 
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |  252 ++++++-------
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   12 -
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   12 -
 drivers/staging/lustre/lustre/llite/dir.c          |   18 -
 drivers/staging/lustre/lustre/llite/file.c         |    2 
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |    2 
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   20 -
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |   10 -
 drivers/staging/lustre/lustre/llite/rw.c           |    6 
 drivers/staging/lustre/lustre/llite/rw26.c         |    6 
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |   20 -
 drivers/staging/lustre/lustre/llite/vvp_internal.h |    2 
 drivers/staging/lustre/lustre/llite/vvp_io.c       |    5 
 drivers/staging/lustre/lustre/llite/xattr.c        |    2 
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    6 
 drivers/staging/lustre/lustre/lov/lov_ea.c         |    2 
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   43 +-
 drivers/staging/lustre/lustre/lov/lov_object.c     |    2 
 drivers/staging/lustre/lustre/lov/lovsub_dev.c     |    1 
 drivers/staging/lustre/lustre/lov/lproc_lov.c      |    2 
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |    2 
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    6 
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |   32 +-
 drivers/staging/lustre/lustre/obdclass/Makefile    |    2 
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |    8 
 drivers/staging/lustre/lustre/obdclass/cl_object.c |    2 
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |    5 
 drivers/staging/lustre/lustre/obdclass/class_obd.c |   19 -
 drivers/staging/lustre/lustre/obdclass/genops.c    |  258 ++++++--------
 .../staging/lustre/lustre/obdclass/kernelcomm.c    |    5 
 drivers/staging/lustre/lustre/obdclass/linkea.c    |  150 --------
 drivers/staging/lustre/lustre/obdclass/llog.c      |   17 -
 drivers/staging/lustre/lustre/obdclass/llog_obd.c  |   14 -
 .../lustre/lustre/obdclass/lprocfs_status.c        |  102 +----
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   46 +-
 drivers/staging/lustre/lustre/obdclass/lu_ref.c    |   45 --
 .../lustre/lustre/obdclass/lustre_handles.c        |   59 +--
 .../staging/lustre/lustre/obdclass/obd_config.c    |   20 -
 drivers/staging/lustre/lustre/obdclass/obd_sysfs.c |   27 +
 .../staging/lustre/lustre/obdecho/echo_client.c    |    4 
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   12 -
 drivers/staging/lustre/lustre/osc/osc_lock.c       |    2 
 drivers/staging/lustre/lustre/osc/osc_page.c       |    2 
 drivers/staging/lustre/lustre/osc/osc_request.c    |   44 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    2 
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |    2 
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   42 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |    4 
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |    2 
 88 files changed, 1077 insertions(+), 1904 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/include/lu_ref.h
 delete mode 100644 drivers/staging/lustre/lustre/obdclass/lu_ref.c

--
Signature
