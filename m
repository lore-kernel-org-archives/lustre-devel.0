From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 18:18:00 +1100
Subject: [lustre-devel] [PATCH 05/16] staging: lustre: introduce and use
 l_wait_event_abortable()
In-Reply-To: <151358127190.5099.12792810096274074963.stgit@noble>
References: <151358127190.5099.12792810096274074963.stgit@noble>
Message-ID: <151358147998.5099.13286478253284938255.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

lustre sometimes wants to wait for an event, but abort if
one of a specific list of signals arrives.  This is a little
bit like wait_event_killable(), except that the signals are
identified a different way.

So introduce l_wait_event_abortable() which provides this
functionality.
Having separate functions for separate needs is more in line
with the pattern set by include/linux/wait.h, than having a
single function which tries to include all possible needs.

Also introduce l_wait_event_abortable_exclusive().

Note that l_wait_event() return -EINTR on a signal, while
Linux wait_event functions return -ERESTARTSYS.
l_wait_event_abortable_exclusive follows the Linux pattern.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_lib.h |   24 ++++++++++++++++++++
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   12 +++++-----
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   12 +++-------
 drivers/staging/lustre/lustre/obdclass/genops.c    |    9 +++-----
 drivers/staging/lustre/lustre/obdclass/llog_obd.c  |    5 ++--
 drivers/staging/lustre/lustre/osc/osc_page.c       |    6 ++---
 drivers/staging/lustre/lustre/osc/osc_request.c    |    6 ++---
 7 files changed, 43 insertions(+), 31 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index fcf31c779e98..d64306291b47 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -425,4 +425,28 @@ do {										\
 		__ret = __wait_event_noload_timeout(wq_head, condition, timeout);\
 	__ret;									\
 })
+
+/* l_wait_event_abortable() is a bit like wait_event_killable()
+ * except there is a fix set of signals which will abort:
+ * LUSTRE_FATAL_SIGS
+ */
+#define l_wait_event_abortable(wq, condition)				\
+({									\
+	sigset_t __blocked;						\
+	int __ret = 0;							\
+	__blocked = cfs_block_sigsinv(LUSTRE_FATAL_SIGS);		\
+	__ret = wait_event_interruptible(wq, condition);		\
+	cfs_restore_sigs(__blocked);					\
+	__ret;								\
+})
+
+#define l_wait_event_abortable_exclusive(wq, condition)			\
+({									\
+	sigset_t __blocked;						\
+	int __ret = 0;							\
+	__blocked = cfs_block_sigsinv(LUSTRE_FATAL_SIGS);		\
+	__ret = wait_event_interruptible_exclusive(wq, condition);	\
+	cfs_restore_sigs(__blocked);					\
+	__ret;								\
+})
 #endif /* _LUSTRE_LIB_H */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 2e66825c8f4b..30044357616d 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -879,7 +879,6 @@ static int __ldlm_namespace_free(struct ldlm_namespace *ns, int force)
 	ldlm_namespace_cleanup(ns, force ? LDLM_FL_LOCAL_ONLY : 0);
 
 	if (atomic_read(&ns->ns_bref) > 0) {
-		struct l_wait_info lwi = LWI_INTR(LWI_ON_SIGNAL_NOOP, NULL);
 		int rc;
 
 		CDEBUG(D_DLMTRACE,
@@ -887,11 +886,12 @@ static int __ldlm_namespace_free(struct ldlm_namespace *ns, int force)
 		       ldlm_ns_name(ns), atomic_read(&ns->ns_bref));
 force_wait:
 		if (force)
-			lwi = LWI_TIMEOUT(msecs_to_jiffies(obd_timeout *
-					  MSEC_PER_SEC) / 4, NULL, NULL);
-
-		rc = l_wait_event(ns->ns_waitq,
-				  atomic_read(&ns->ns_bref) == 0, &lwi);
+			rc = wait_event_timeout(ns->ns_waitq,
+						atomic_read(&ns->ns_bref) == 0,
+						obd_timeout * HZ / 4) ? 0 : -ETIMEDOUT;
+		else
+			rc = l_wait_event_abortable(ns->ns_waitq,
+						    atomic_read(&ns->ns_bref) == 0);
 
 		/* Forced cleanups should be able to reclaim all references,
 		 * so it's safe to wait forever... we can't leak locks...
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 0a9183f271f5..33dc15e9aebb 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -986,16 +986,12 @@ void ll_put_super(struct super_block *sb)
 	}
 
 	/* Wait for unstable pages to be committed to stable storage */
-	if (!force) {
-		struct l_wait_info lwi = LWI_INTR(LWI_ON_SIGNAL_NOOP, NULL);
-
-		rc = l_wait_event(sbi->ll_cache->ccc_unstable_waitq,
-				  !atomic_long_read(&sbi->ll_cache->ccc_unstable_nr),
-				  &lwi);
-	}
+	if (!force)
+		rc = l_wait_event_abortable(sbi->ll_cache->ccc_unstable_waitq,
+					    !atomic_long_read(&sbi->ll_cache->ccc_unstable_nr));
 
 	ccc_count = atomic_long_read(&sbi->ll_cache->ccc_unstable_nr);
-	if (!force && rc != -EINTR)
+	if (!force && rc != -ERESTARTSYS)
 		LASSERTF(!ccc_count, "count: %li\n", ccc_count);
 
 	/* We need to set force before the lov_disconnect in
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 78f0fa1dff45..2aa350214c63 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -1332,7 +1332,6 @@ static bool obd_request_slot_avail(struct client_obd *cli,
 int obd_get_request_slot(struct client_obd *cli)
 {
 	struct obd_request_slot_waiter orsw;
-	struct l_wait_info lwi;
 	int rc;
 
 	spin_lock(&cli->cl_loi_list_lock);
@@ -1347,11 +1346,9 @@ int obd_get_request_slot(struct client_obd *cli)
 	orsw.orsw_signaled = false;
 	spin_unlock(&cli->cl_loi_list_lock);
 
-	lwi = LWI_INTR(LWI_ON_SIGNAL_NOOP, NULL);
-	rc = l_wait_event(orsw.orsw_waitq,
-			  obd_request_slot_avail(cli, &orsw) ||
-			  orsw.orsw_signaled,
-			  &lwi);
+	rc = l_wait_event_abortable(orsw.orsw_waitq,
+				    obd_request_slot_avail(cli, &orsw) ||
+				    orsw.orsw_signaled);
 
 	/*
 	 * Here, we must take the lock to avoid the on-stack 'orsw' to be
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_obd.c b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
index 28bbaa2136ac..26aea114a29b 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
@@ -104,7 +104,6 @@ EXPORT_SYMBOL(__llog_ctxt_put);
 
 int llog_cleanup(const struct lu_env *env, struct llog_ctxt *ctxt)
 {
-	struct l_wait_info lwi = LWI_INTR(LWI_ON_SIGNAL_NOOP, NULL);
 	struct obd_llog_group *olg;
 	int rc, idx;
 
@@ -129,8 +128,8 @@ int llog_cleanup(const struct lu_env *env, struct llog_ctxt *ctxt)
 		CERROR("Error %d while cleaning up ctxt %p\n",
 		       rc, ctxt);
 
-	l_wait_event(olg->olg_waitq,
-		     llog_group_ctxt_null(olg, idx), &lwi);
+	l_wait_event_abortable(olg->olg_waitq,
+			     llog_group_ctxt_null(olg, idx));
 
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 20094b6309f9..6fdd521feb21 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -759,7 +759,6 @@ static long osc_lru_reclaim(struct client_obd *cli, unsigned long npages)
 static int osc_lru_alloc(const struct lu_env *env, struct client_obd *cli,
 			 struct osc_page *opg)
 {
-	struct l_wait_info lwi = LWI_INTR(LWI_ON_SIGNAL_NOOP, NULL);
 	struct osc_io *oio = osc_env_io(env);
 	int rc = 0;
 
@@ -782,9 +781,8 @@ static int osc_lru_alloc(const struct lu_env *env, struct client_obd *cli,
 
 		cond_resched();
 
-		rc = l_wait_event(osc_lru_waitq,
-				  atomic_long_read(cli->cl_lru_left) > 0,
-				  &lwi);
+		rc = l_wait_event_abortable(osc_lru_waitq,
+					    atomic_long_read(cli->cl_lru_left) > 0);
 
 		if (rc < 0)
 			break;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 45b1ebf33363..074b5ce6284c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -552,14 +552,12 @@ static int osc_destroy(const struct lu_env *env, struct obd_export *exp,
 
 	req->rq_interpret_reply = osc_destroy_interpret;
 	if (!osc_can_send_destroy(cli)) {
-		struct l_wait_info lwi = LWI_INTR(LWI_ON_SIGNAL_NOOP, NULL);
-
 		/*
 		 * Wait until the number of on-going destroy RPCs drops
 		 * under max_rpc_in_flight
 		 */
-		l_wait_event_exclusive(cli->cl_destroy_waitq,
-				       osc_can_send_destroy(cli), &lwi);
+		l_wait_event_abortable_exclusive(cli->cl_destroy_waitq,
+					       osc_can_send_destroy(cli));
 	}
 
 	/* Do not wait for response */
