From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:33 -0500
Subject: [lustre-devel] [PATCH 00/28] OpenSFS backport for Nov 15 2020
Message-ID: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Backport of various patches from the OpenSFS tree. Fixes for mmap
and fscrypto has been included which impacted new kernels. This
work has been validated against:

sanity-lnet.sh
sanity.sh
sanity-hsm.sh
sanity-sec.sh
sanity-pcc.sh

Alexander Boyko (2):
  lustre: ptlrpc: remove unused code at pinger
  lustre: ptlrpc: decrease time between reconnection

Amir Shehata (1):
  lnet: o2iblnd: Don't retry indefinitely

Andriy Skulysh (2):
  lustre: llite: ASSERTION( last_oap_count > 0 ) failed
  lustre: ldlm: BL AST vs failed lock enqueue race

Aurelien Degremont (2):
  lustre: ptlrpc: throttle RPC resend if network error
  lustre: ptlrpc: don't log connection 'restored' inappropriately

Brian Behlendorf (1):
  lnet: o2iblnd: 'Timed out tx' error message

Hongchao Zhang (1):
  lustre: lov: doesn't check lov_refcount

James Simmons (1):
  llite: remove splice_read handling for PCC

John L. Hammond (1):
  lnet: o2ib: raise bind cap before resolving address

Lai Siyao (3):
  lustre: llite: rmdir releases inode on client
  lustre: mdc: remote object support getattr from cache
  lustre: llite: pass name in getattr by FID

Mikhail Pershin (2):
  lustre: ptlrpc: introduce OST_SEEK RPC
  lustre: clio: SEEK_HOLE/SEEK_DATA on client side

Mr NeilBrown (2):
  lustre: llite: disable statahead_agl for sanity test_56ra
  lustre: seq_file .next functions must update *pos

NeilBrown (1):
  lustre: use memalloc_nofs_save() for GFP_NOFS kvmalloc allocations.

Oleg Drokin (2):
  lustre: ldlm: Fix unbounded OBD_FAIL_LDLM_CANCEL_BL_CB_RACE wait
  lustre: llite: Avoid eternel retry loops with MAP_POPULATE

Sebastien Buisson (6):
  lustre: gss: update sequence in case of target disconnect
  lustre: sec: O_DIRECT for encrypted file
  lustre: sec: restrict fallocate on encrypted files
  lustre: sec: encryption with different client PAGE_SIZE
  lustre: sec: require enc key in case of O_CREAT only
  lustre: sec: fix O_DIRECT and encrypted files

Vitaly Fertman (1):
  lustre: ldlm: group locks for DOM IBIT lock

 .../client_side_encryption/access_semantics.txt    |   3 -
 fs/lustre/include/cl_object.h                      |  10 +
 fs/lustre/include/lustre_export.h                  |   5 +
 fs/lustre/include/lustre_net.h                     |   5 -
 fs/lustre/include/lustre_osc.h                     |   4 +
 fs/lustre/include/lustre_req_layout.h              |   1 +
 fs/lustre/include/obd.h                            |   1 +
 fs/lustre/ldlm/ldlm_inodebits.c                    |   2 +
 fs/lustre/ldlm/ldlm_lock.c                         |  12 +-
 fs/lustre/ldlm/ldlm_lockd.c                        |   4 +-
 fs/lustre/ldlm/ldlm_request.c                      |   5 +-
 fs/lustre/llite/dir.c                              |   1 -
 fs/lustre/llite/file.c                             | 115 ++++++++++--
 fs/lustre/llite/llite_internal.h                   |   1 -
 fs/lustre/llite/llite_lib.c                        |  19 +-
 fs/lustre/llite/llite_mmap.c                       |  10 +-
 fs/lustre/llite/namei.c                            |  24 ++-
 fs/lustre/llite/pcc.c                              |  33 +---
 fs/lustre/llite/pcc.h                              |   5 -
 fs/lustre/llite/rw26.c                             |  27 ++-
 fs/lustre/llite/statahead.c                        |  31 ++--
 fs/lustre/llite/super25.c                          |  11 ++
 fs/lustre/llite/vvp_io.c                           |  53 +++++-
 fs/lustre/lmv/lmv_intent.c                         |  22 ++-
 fs/lustre/lmv/lmv_obd.c                            |   8 +-
 fs/lustre/lov/lov_io.c                             |  99 +++++++++-
 fs/lustre/lov/lov_obd.c                            |   3 +-
 fs/lustre/lov/lov_object.c                         |  13 +-
 fs/lustre/lov/lov_pool.c                           |   2 +-
 fs/lustre/mdc/mdc_dev.c                            |  14 +-
 fs/lustre/mdc/mdc_locks.c                          |   1 -
 fs/lustre/obdclass/cl_io.c                         |  12 ++
 fs/lustre/obdclass/lprocfs_status.c                |   1 +
 fs/lustre/obdecho/echo_client.c                    |   7 +-
 fs/lustre/osc/osc_io.c                             | 143 ++++++++++++++-
 fs/lustre/osc/osc_request.c                        |  95 +++++++---
 fs/lustre/ptlrpc/client.c                          |  20 ++
 fs/lustre/ptlrpc/events.c                          |   5 +
 fs/lustre/ptlrpc/import.c                          |  52 +++++-
 fs/lustre/ptlrpc/layout.c                          |   5 +
 fs/lustre/ptlrpc/lproc_ptlrpc.c                    |   4 +-
 fs/lustre/ptlrpc/niobuf.c                          |   2 -
 fs/lustre/ptlrpc/pinger.c                          | 202 +++++----------------
 fs/lustre/ptlrpc/sec.c                             |   4 +-
 fs/lustre/ptlrpc/sec_null.c                        |   8 -
 fs/lustre/ptlrpc/wiretest.c                        |  14 +-
 include/uapi/linux/lustre/lustre_idl.h             |   3 +
 net/lnet/klnds/o2iblnd/o2iblnd.h                   |   2 +
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c                |  48 ++++-
 net/lnet/klnds/o2iblnd/o2iblnd_modparams.c         |   2 +-
 50 files changed, 834 insertions(+), 339 deletions(-)

-- 
1.8.3.1
