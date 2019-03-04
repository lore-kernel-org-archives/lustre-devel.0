From: NeilBrown <neilb@suse.com>
Date: Mon, 04 Mar 2019 17:31:38 +1100
Subject: [lustre-devel] [PATCH 00/28] More lustre patches...
Message-ID: <155168107971.31333.14345309795939467246.stgit@noble.brown>
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

BTW I've updated my lustre branch to 5.0-rc8 with all the patches that
have been around for a while and received review.  All these are in
lustre-testing.

Thanks,
NeilBrown

---

NeilBrown (28):
      lustre: embed typ_kobj in obd_type
      lustre: collect all resource releasing for obj_type.
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
      lustre: lov: use GFP_NOFS to allocate lo_entries.
      lustre: vvp_dev; increment *pos in .next
      lustre: obdclass: discard process_quota_config
      lustre: obdclass: remove unnecessary code from lustre_init_lsi()
      lustre: ldlm: discard l_lock from struct ldlm_lock.
      lustre: ldlm: don't access l_resource when not locked.
      lustre: ldlm: drop SLAB_TYPESAFE_BY_RCU from ldlm_lock slab.
      lustre: ldlm: simplify lock_mode_to_index()
      lustre: use list_move where appropriate.


 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   10 -
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    6 -
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    3 
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |    3 
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |    3 
 drivers/staging/lustre/lnet/lnet/config.c          |    3 
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   16 +
 drivers/staging/lustre/lnet/selftest/console.c     |    7 -
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   11 -
 .../staging/lustre/lustre/include/lustre_export.h  |    1 
 .../staging/lustre/lustre/include/lustre_handles.h |   22 --
 .../staging/lustre/lustre/include/lustre_import.h  |    2 
 drivers/staging/lustre/lustre/include/lustre_net.h |    4 
 drivers/staging/lustre/lustre/include/obd.h        |   45 +---
 drivers/staging/lustre/lustre/include/obd_class.h  |    8 -
 .../staging/lustre/lustre/include/obd_support.h    |   10 -
 drivers/staging/lustre/lustre/ldlm/l_lock.c        |   21 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |    3 
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |    2 
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |    7 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |  101 ++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |   23 ++
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |   18 --
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    3 
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    9 -
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    6 -
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |    4 
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |    2 
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    4 
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    2 
 drivers/staging/lustre/lustre/lov/lov_object.c     |    2 
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    6 -
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    8 -
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    1 
 drivers/staging/lustre/lustre/obdclass/genops.c    |  238 ++++++++++----------
 .../lustre/lustre/obdclass/lprocfs_status.c        |   20 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    2 
 .../lustre/lustre/obdclass/lustre_handles.c        |   62 ++---
 .../staging/lustre/lustre/obdclass/obd_config.c    |   11 -
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |    6 -
 drivers/staging/lustre/lustre/obdclass/obd_sysfs.c |   21 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |    4 
 drivers/staging/lustre/lustre/osc/osc_request.c    |    2 
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   12 -
 drivers/staging/lustre/lustre/ptlrpc/import.c      |    3 
 drivers/staging/lustre/lustre/ptlrpc/service.c     |   17 +
 46 files changed, 330 insertions(+), 444 deletions(-)

--
Signature
