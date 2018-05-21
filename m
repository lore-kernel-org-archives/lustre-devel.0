From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:13 +1000
Subject: [lustre-devel] [PATCH 18/30] staging: lustre: replace
 memory_presure funcitons by standard interfaces.
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731300.24196.12928786633700587955.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Use memalloc_noreclaim_save() and memalloc_noreclaim_restore(),
and for testing, just directly test the flag in current->flags

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_prim.h      |   31 --------------------
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   11 ++++---
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |    5 ++-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    2 +
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |    9 ++++--
 drivers/staging/lustre/lustre/osc/osc_cache.c      |    2 +
 drivers/staging/lustre/lustre/osc/osc_request.c    |    7 +++--
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |    7 +++--
 8 files changed, 25 insertions(+), 49 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h
index d4c5965c43b1..2b0dafb6155b 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h
@@ -48,35 +48,4 @@
 #define NUM_CACHEPAGES totalram_pages
 #endif
 
-static inline unsigned int memory_pressure_get(void)
-{
-	return current->flags & PF_MEMALLOC;
-}
-
-static inline void memory_pressure_set(void)
-{
-	current->flags |= PF_MEMALLOC;
-}
-
-static inline void memory_pressure_clr(void)
-{
-	current->flags &= ~PF_MEMALLOC;
-}
-
-static inline int cfs_memory_pressure_get_and_set(void)
-{
-	int old = memory_pressure_get();
-
-	if (!old)
-		memory_pressure_set();
-	return old;
-}
-
-static inline void cfs_memory_pressure_restore(int old)
-{
-	if (old)
-		memory_pressure_set();
-	else
-		memory_pressure_clr();
-}
 #endif
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 14450fd5957a..01b31a6bb588 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -22,6 +22,7 @@
  *
  */
 
+#include <linux/sched/mm.h>
 #include "socklnd.h"
 
 struct ksock_tx *
@@ -876,7 +877,7 @@ ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
 int
 ksocknal_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg)
 {
-	int mpflag = 1;
+	unsigned int mpflag = 0;
 	int type = lntmsg->msg_type;
 	struct lnet_process_id target = lntmsg->msg_target;
 	unsigned int payload_niov = lntmsg->msg_niov;
@@ -909,13 +910,13 @@ ksocknal_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg)
 				     tx_frags.paged.kiov[payload_niov]);
 
 	if (lntmsg->msg_vmflush)
-		mpflag = cfs_memory_pressure_get_and_set();
+		mpflag = memalloc_noreclaim_save();
 	tx = ksocknal_alloc_tx(KSOCK_MSG_LNET, desc_size);
 	if (!tx) {
 		CERROR("Can't allocate tx desc type %d size %d\n",
 		       type, desc_size);
 		if (lntmsg->msg_vmflush)
-			cfs_memory_pressure_restore(mpflag);
+			memalloc_noreclaim_restore(mpflag);
 		return -ENOMEM;
 	}
 
@@ -949,8 +950,8 @@ ksocknal_send(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg)
 
 	/* The first fragment will be set later in pro_pack */
 	rc = ksocknal_launch_packet(ni, tx, target);
-	if (!mpflag)
-		cfs_memory_pressure_restore(mpflag);
+	if (mpflag)
+		memalloc_noreclaim_restore(mpflag);
 
 	if (!rc)
 		return 0;
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 514e1845740e..878fbb9745a0 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -114,7 +114,7 @@ static struct cfs_trace_page *cfs_tage_alloc(gfp_t gfp)
 	struct cfs_trace_page *tage;
 
 	/* My caller is trying to free memory */
-	if (!in_interrupt() && memory_pressure_get())
+	if (!in_interrupt() && (current->flags & PF_MEMALLOC))
 		return NULL;
 
 	/*
@@ -192,7 +192,8 @@ cfs_trace_get_tage_try(struct cfs_trace_cpu_data *tcd, unsigned long len)
 		} else {
 			tage = cfs_tage_alloc(GFP_ATOMIC);
 			if (unlikely(!tage)) {
-				if (!memory_pressure_get() || in_interrupt())
+				if (!(current->flags & PF_MEMALLOC) ||
+				    in_interrupt())
 					pr_warn_ratelimited("cannot allocate a tage (%ld)\n",
 							    tcd->tcd_cur_pages);
 				return NULL;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 60464135161b..f8eaf8ff8d8d 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -2014,7 +2014,7 @@ LNetPut(lnet_nid_t self, struct lnet_handle_md mdh, enum lnet_ack_req ack,
 		       libcfs_id2str(target));
 		return -ENOMEM;
 	}
-	msg->msg_vmflush = !!memory_pressure_get();
+	msg->msg_vmflush = !!(current->flags & PF_MEMALLOC);
 
 	cpt = lnet_cpt_of_cookie(mdh.cookie);
 	lnet_res_lock(cpt);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 942d34f7a44c..4e6caf748961 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -39,6 +39,7 @@
 #define DEBUG_SUBSYSTEM S_LDLM
 
 #include <linux/libcfs/libcfs.h>
+#include <linux/sched/mm.h>
 #include <lustre_dlm.h>
 #include <obd_class.h>
 #include <linux/list.h>
@@ -387,7 +388,7 @@ static inline void init_blwi(struct ldlm_bl_work_item *blwi,
 	init_completion(&blwi->blwi_comp);
 	INIT_LIST_HEAD(&blwi->blwi_head);
 
-	if (memory_pressure_get())
+	if (current->flags & PF_MEMALLOC)
 		blwi->blwi_mem_pressure = 1;
 
 	blwi->blwi_ns = ns;
@@ -776,12 +777,14 @@ static int ldlm_bl_thread_need_create(struct ldlm_bl_pool *blp,
 static int ldlm_bl_thread_blwi(struct ldlm_bl_pool *blp,
 			       struct ldlm_bl_work_item *blwi)
 {
+	unsigned int flags = 0;
+
 	if (!blwi->blwi_ns)
 		/* added by ldlm_cleanup() */
 		return LDLM_ITER_STOP;
 
 	if (blwi->blwi_mem_pressure)
-		memory_pressure_set();
+		flags = memalloc_noreclaim_save();
 
 	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_PAUSE_CANCEL2, 4);
 
@@ -804,7 +807,7 @@ static int ldlm_bl_thread_blwi(struct ldlm_bl_pool *blp,
 					blwi->blwi_lock);
 	}
 	if (blwi->blwi_mem_pressure)
-		memory_pressure_clr();
+		memalloc_noreclaim_restore(flags);
 
 	if (blwi->blwi_flags & LCF_ASYNC)
 		kfree(blwi);
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index ba4a4bf3b0f1..f26983004843 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -2622,7 +2622,7 @@ int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
 	oap->oap_async_flags |= ASYNC_READY | ASYNC_URGENT;
 	spin_unlock(&oap->oap_lock);
 
-	if (memory_pressure_get())
+	if (current->flags & PF_MEMALLOC)
 		ext->oe_memalloc = 1;
 
 	ext->oe_urgent = 1;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 0f355c415474..64a3e4a2e05b 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -34,6 +34,7 @@
 #define DEBUG_SUBSYSTEM S_OSC
 
 #include <linux/libcfs/libcfs.h>
+#include <linux/sched/mm.h>
 
 #include <lustre_dlm.h>
 #include <lustre_net.h>
@@ -1654,7 +1655,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	struct cl_req_attr *crattr = NULL;
 	u64 starting_offset = OBD_OBJECT_EOF;
 	u64 ending_offset = 0;
-	int mpflag = 0;
+	unsigned int mpflag = 0;
 	int mem_tight = 0;
 	int page_count = 0;
 	bool soft_sync = false;
@@ -1677,7 +1678,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 
 	soft_sync = osc_over_unstable_soft_limit(cli);
 	if (mem_tight)
-		mpflag = cfs_memory_pressure_get_and_set();
+		mpflag = memalloc_noreclaim_save();
 
 	pga = kcalloc(page_count, sizeof(*pga), GFP_NOFS);
 	if (!pga) {
@@ -1791,7 +1792,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 
 out:
 	if (mem_tight != 0)
-		cfs_memory_pressure_restore(mpflag);
+		memalloc_noreclaim_restore(mpflag);
 
 	if (rc != 0) {
 		LASSERT(!req);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index 86883abaad2c..2897afb8806c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -32,6 +32,7 @@
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
+#include <linux/sched/mm.h>
 #include <obd_support.h>
 #include <lustre_net.h>
 #include <lustre_lib.h>
@@ -472,7 +473,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 {
 	int rc;
 	int rc2;
-	int mpflag = 0;
+	unsigned int mpflag = 0;
 	struct ptlrpc_connection *connection;
 	struct lnet_handle_me reply_me_h;
 	struct lnet_md reply_md;
@@ -558,7 +559,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 		lustre_msg_add_flags(request->rq_reqmsg, MSG_RESENT);
 
 	if (request->rq_memalloc)
-		mpflag = cfs_memory_pressure_get_and_set();
+		mpflag = memalloc_noreclaim_save();
 
 	rc = sptlrpc_cli_wrap_request(request);
 	if (rc) {
@@ -710,7 +711,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	ptlrpc_unregister_bulk(request, 0);
  out:
 	if (request->rq_memalloc)
-		cfs_memory_pressure_restore(mpflag);
+		memalloc_noreclaim_restore(mpflag);
 	return rc;
 }
 EXPORT_SYMBOL(ptl_send_rpc);
