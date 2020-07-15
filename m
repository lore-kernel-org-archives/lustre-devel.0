From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:44:41 -0400
Subject: [lustre-devel] [PATCH 00/37] lustre: latest patches landed to
 OpenSFS 07/14/2020
Message-ID: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Latest patches to landed to the OpenSFS tree as of July 14, 2020.
Please review to make sure they are correct.

Amir Shehata (2):
  lnet: socklnd: fix local interface binding
  lnet: check rtr_nid is a gateway

Andreas Dilger (1):
  lustre: misc: quiet compiler warning on armv7l

Chris Horn (2):
  lnet: Allow router to forward to healthier NID
  lnet: Set remote NI status in lnet_notify

Hongchao Zhang (1):
  lustre: ptlrpc: fix endless loop issue

James Simmons (1):
  lustre: ptlrpc: handle conn_hash rhashtable resize

Mikhail Pershin (1):
  lustre: ptlrpc: re-enterable signal_completed_replay()

Mr NeilBrown (18):
  lustre: osc: fix osc_extent_find()
  lustre: obdclass: remove init to 0 from lustre_init_lsi()
  lustre: lu_object: convert lu_object cache to rhashtable
  lnet: o2iblnd: allocate init_qp_attr on stack.
  lnet: Fix some out-of-date comments.
  lnet: socklnd: don't fall-back to tcp_sendpage.
  lustre: remove some "#ifdef CONFIG*" from .c files.
  lnet: o2iblnd: Use ib_mtu_int_to_enum()
  lnet: o2iblnd: wait properly for fps->increasing.
  lnet: o2iblnd: use need_resched()
  lnet: o2iblnd: Use list_for_each_entry_safe
  lnet: socklnd: use need_resched()
  lnet: socklnd: use list_for_each_entry_safe()
  lnet: socklnd: convert various refcounts to refcount_t
  lnet: libcfs: don't call unshare_fs_struct()
  lustre: llite: annotate non-owner locking
  lnet: remove LNetMEUnlink and clean up related code
  lnet: socklnd: change ksnd_nthreads to atomic_t

Sebastien Buisson (1):
  lustre: sec: better struct sepol_downcall_data

Shaun Tancheff (1):
  lustre: llite: Fix lock ordering in pagevec_dirty

Vladimir Saveliev (1):
  lustre: osc: consume grants for direct I/O

Wang Shilong (7):
  lustre: ldlm: check slv and limit before updating
  lustre: osc: disable ext merging for rdma only pages and non-rdma
  lustre: obdclass: use offset instead of cp_linkage
  lustre: obdclass: re-declare cl_page variables to reduce its size
  lustre: osc: re-declare ops_from/to to shrink osc_page
  lustre: llite: fix to free cl_dio_aio properly
  lustre: llite: fix short io for AIO

Yang Sheng (1):
  lustre: obdcalss: ensure LCT_QUIESCENT take sync

 fs/lustre/include/cl_object.h              |  34 +-
 fs/lustre/include/lu_object.h              |  28 +-
 fs/lustre/include/lustre_osc.h             |  12 +-
 fs/lustre/include/obd.h                    |  21 ++
 fs/lustre/ldlm/ldlm_request.c              |   8 +
 fs/lustre/llite/file.c                     |  32 +-
 fs/lustre/llite/llite_internal.h           |  29 ++
 fs/lustre/llite/llite_lib.c                |  54 +--
 fs/lustre/llite/rw26.c                     |  43 ++-
 fs/lustre/llite/vvp_dev.c                  | 105 ++----
 fs/lustre/llite/vvp_internal.h             |   3 +-
 fs/lustre/llite/vvp_io.c                   | 111 +++---
 fs/lustre/lov/lovsub_dev.c                 |   5 +-
 fs/lustre/mdc/mdc_request.c                |   8 +-
 fs/lustre/obdclass/cl_io.c                 |  19 +-
 fs/lustre/obdclass/cl_page.c               | 360 ++++++++++---------
 fs/lustre/obdclass/llog.c                  |   2 -
 fs/lustre/obdclass/lu_object.c             | 539 ++++++++++++++---------------
 fs/lustre/obdclass/lu_tgt_descs.c          |   2 +-
 fs/lustre/obdclass/obd_mount.c             |   6 +-
 fs/lustre/osc/osc_cache.c                  |  64 ++--
 fs/lustre/osc/osc_page.c                   |  21 +-
 fs/lustre/ptlrpc/connection.c              |  12 +-
 fs/lustre/ptlrpc/import.c                  |   6 +-
 fs/lustre/ptlrpc/niobuf.c                  |  12 +-
 fs/lustre/ptlrpc/pinger.c                  |  11 +-
 fs/lustre/ptlrpc/ptlrpcd.c                 |   1 -
 fs/lustre/ptlrpc/sec_lproc.c               | 134 ++++++-
 fs/lustre/ptlrpc/service.c                 |   3 -
 include/linux/lnet/api.h                   |   6 +-
 include/linux/lnet/lib-lnet.h              |   4 +-
 include/uapi/linux/lustre/lustre_user.h    |  16 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c           | 103 ++----
 net/lnet/klnds/o2iblnd/o2iblnd.h           |   2 -
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c        |  12 +-
 net/lnet/klnds/o2iblnd/o2iblnd_modparams.c |   4 +-
 net/lnet/klnds/socklnd/socklnd.c           |  97 +++---
 net/lnet/klnds/socklnd/socklnd.h           |  56 ++-
 net/lnet/klnds/socklnd/socklnd_cb.c        |  26 +-
 net/lnet/klnds/socklnd/socklnd_lib.c       |   8 +-
 net/lnet/lnet/api-ni.c                     |   5 +-
 net/lnet/lnet/lib-md.c                     |  62 ++--
 net/lnet/lnet/lib-me.c                     |  39 ---
 net/lnet/lnet/lib-move.c                   |  57 ++-
 net/lnet/lnet/router.c                     |   6 +-
 net/lnet/selftest/rpc.c                    |   1 -
 46 files changed, 1176 insertions(+), 1013 deletions(-)

-- 
1.8.3.1
