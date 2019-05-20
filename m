From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 May 2019 08:50:42 -0400
Subject: [lustre-devel] [PATCH v2 00/29] More lustre patches
Message-ID: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Some of these I posted before but didn't get a formal Reviewed-by.
Some needed some revision.
Some did get a reviewed-by, but depend on patches in the above
categories.

Others are brand new.

James Simmons (1):
  lustre: llite: don't use class_setup_tunables()

NeilBrown (27):
  lustre: llite: fix error in vvp_pgcache seqfile.
  lustre: llite: replace lli_trunc_sem
  lustre: lov: use GFP_NOFS to allocate lo_entries.
  lustre: embed typ_kobj in obd_type
  lustre: obd: collect all resource releasing for obj_type.
  lustre: obd_type: use typ_kobj.name as typ_name
  lustre: obd_type: discard obd_types linked list.
  lustre: obd_type: discard obd_type_lock
  lustre: obdclass: don't copy ops structures in to new type.
  lustre: obdclass: fix module load locking.
  lustre: convert rsi_sem to a spinlock.
  lustre: ldlm: discard varname in ldlm_pool.
  lustre: lprocfs: use log2.h macros instead of shift loop.
  lustre: handles: discard h_owner in favour of h_ops
  lustre: handle: move refcount into the lustre_handle.
  lustre: discard OBD_FREE_RCU
  lustre: portals_handle: rename ops to owner
  lustre: portals_handle: remove locking from class_handle2object()
  lustre: portals_handle: use hlist for hash lists.
  lustre: portals_handle: discard h_lock.
  lustre: remove unused fields from struct obd_device
  lustre: obd_sysfs: error-check value stored in jobid_var
  lustre: obdclass: discard process_quota_config
  lustre: obdclass: remove unnecessary code from lustre_init_lsi()
  lustre: ldlm: discard l_lock from struct ldlm_lock.
  lustre: ldlm: don't access l_resource when not locked.
  lustre: ldlm: drop SLAB_TYPESAFE_BY_RCU from ldlm_lock slab.

Patrick Farrell (1):
  lustre: llite: ll_fault fixes

 fs/lustre/include/lustre_dlm.h           |  11 --
 fs/lustre/include/lustre_export.h        |   1 -
 fs/lustre/include/lustre_handles.h       |  22 +--
 fs/lustre/include/lustre_import.h        |   2 -
 fs/lustre/include/lustre_net.h           |   4 +-
 fs/lustre/include/obd.h                  |  45 +++---
 fs/lustre/include/obd_class.h            |  10 +-
 fs/lustre/include/obd_support.h          |  10 --
 fs/lustre/ldlm/l_lock.c                  |  20 ++-
 fs/lustre/ldlm/ldlm_internal.h           |   2 -
 fs/lustre/ldlm/ldlm_lib.c                |   2 +-
 fs/lustre/ldlm/ldlm_lock.c               | 101 ++++++-------
 fs/lustre/ldlm/ldlm_lockd.c              |  24 ++-
 fs/lustre/ldlm/ldlm_pool.c               |  18 +--
 fs/lustre/ldlm/ldlm_resource.c           |   9 +-
 fs/lustre/llite/llite_internal.h         |   3 +-
 fs/lustre/llite/llite_lib.c              |   9 +-
 fs/lustre/llite/llite_mmap.c             |   6 +-
 fs/lustre/llite/lproc_llite.c            |  45 ++++--
 fs/lustre/llite/vvp_dev.c                |   1 +
 fs/lustre/llite/vvp_io.c                 |  28 +++-
 fs/lustre/lmv/lmv_obd.c                  |   4 +-
 fs/lustre/lov/lov_obd.c                  |   2 +-
 fs/lustre/lov/lov_object.c               |   6 +-
 fs/lustre/mdc/mdc_request.c              |   6 +-
 fs/lustre/mgc/mgc_request.c              |  13 +-
 fs/lustre/obdclass/class_obd.c           |  27 +---
 fs/lustre/obdclass/genops.c              | 247 +++++++++++++------------------
 fs/lustre/obdclass/lprocfs_status.c      |  20 +--
 fs/lustre/obdclass/lu_object.c           |   2 +-
 fs/lustre/obdclass/lustre_handles.c      |  62 +++-----
 fs/lustre/obdclass/obd_config.c          |  30 ----
 fs/lustre/obdclass/obd_mount.c           |   6 +-
 fs/lustre/obdclass/obd_sysfs.c           |  21 ++-
 fs/lustre/obdecho/echo_client.c          |   4 +-
 fs/lustre/osc/osc_request.c              |   2 +-
 fs/lustre/ptlrpc/client.c                |   2 +-
 fs/lustre/ptlrpc/service.c               |   4 +-
 include/uapi/linux/lustre/lustre_ioctl.h |   1 -
 39 files changed, 352 insertions(+), 480 deletions(-)

-- 
1.8.3.1
