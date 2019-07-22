From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 22:12:12 -0400
Subject: [lustre-devel] [PATCH 00/10] lustre: push patches ready from
 lustre-testing
Message-ID: <1563761542-3708-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Several patches from lustre-testing have been reviewed and tested.
They are ready to land to the main lustre branch. One patch in
lustre-testing to remove set_cblist in ptlrpc has been replaced by
a patch from John Hammond that removed even more.

John L. Hammond (1):
  lustre: ptlrpc: simplify struct ptlrpc_request_set

NeilBrown (9):
  lustre: ldlm: discard varname in ldlm_pool.
  lustre: lprocfs: use log2.h macros instead of shift loop.
  lustre: ptlrpc: make ptlrpc_bulk_frag_ops always const.
  lustre: mgc: remove llog_process_lock
  lustre: don't declare extern variables in C files.
  lnet: socklnd: fix infinite loop in ksocknal_push()
  lustre: ptlrpc: remove inline on non-inlined functions.
  lustre: convert rsi_sem to a spinlock.
  lustre: ptlrpc: make ptlrpc_last_xid an atomic64_t

 fs/lustre/include/lustre_net.h      | 47 +-------------------
 fs/lustre/include/obd_class.h       | 25 +----------
 fs/lustre/ldlm/ldlm_internal.h      |  2 -
 fs/lustre/ldlm/ldlm_pool.c          | 18 +++-----
 fs/lustre/ldlm/ldlm_resource.c      |  2 -
 fs/lustre/llite/llite_lib.c         |  8 ++--
 fs/lustre/llite/lproc_llite.c       |  4 +-
 fs/lustre/lov/lov_obd.c             | 85 ++++++++++++-------------------------
 fs/lustre/mgc/mgc_request.c         |  6 +--
 fs/lustre/obdclass/lprocfs_status.c | 18 +++-----
 fs/lustre/ptlrpc/client.c           | 82 ++++++++++++++---------------------
 fs/lustre/ptlrpc/import.c           |  1 -
 fs/lustre/ptlrpc/ptlrpc_module.c    |  5 ---
 net/lnet/klnds/socklnd/socklnd.c    |  2 +-
 14 files changed, 82 insertions(+), 223 deletions(-)

-- 
1.8.3.1
