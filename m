From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed,  2 Nov 2016 21:24:53 -0400
Subject: [lustre-devel] [PATCH 03/14] staging/lustre: conflicting PW & PR
	extent locks on a client
In-Reply-To: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
References: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1478136304-867780-4-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Andriy Skulysh <andriy.skulysh@seagate.com>, Oleg Drokin <green@linuxhacker.ru>

From: Andriy Skulysh <andriy.skulysh@seagate.com>

PW lock isn't replayed once a lock is marked
LDLM_FL_CANCELING and glimpse lock doesn't wait for
conflicting locks on the client. So the server will
grant a PR lock in response to the glimpse lock request,
which conflicts with the PW lock in LDLM_FL_CANCELING
state on the client.

Lock in LDLM_FL_CANCELING state may still have pending IO,
so it should be replayed until LDLM_FL_BL_DONE is set to
avoid granted conflicting lock by a server.

Seagate-bug-id: MRP-3311
Signed-off-by: Andriy Skulysh <andriy.skulysh@seagate.com>
Reviewed-on: http://review.whamcloud.com/20345
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8175
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/obd_support.h |  3 +++
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c    | 20 ++++++++++++++++++++
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c   |  4 ++--
 drivers/staging/lustre/lustre/osc/osc_request.c     |  1 +
 4 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 7f3f8cd..aaedec7 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -321,6 +321,8 @@ extern char obd_jobid_var[];
 #define OBD_FAIL_LDLM_CP_CB_WAIT4	 0x322
 #define OBD_FAIL_LDLM_CP_CB_WAIT5	 0x323
 
+#define OBD_FAIL_LDLM_GRANT_CHECK        0x32a
+
 /* LOCKLESS IO */
 #define OBD_FAIL_LDLM_SET_CONTENTION     0x385
 
@@ -343,6 +345,7 @@ extern char obd_jobid_var[];
 #define OBD_FAIL_OSC_CP_ENQ_RACE	 0x410
 #define OBD_FAIL_OSC_NO_GRANT	    0x411
 #define OBD_FAIL_OSC_DELAY_SETTIME	 0x412
+#define OBD_FAIL_OSC_DELAY_IO		 0x414
 
 #define OBD_FAIL_PTLRPC		  0x500
 #define OBD_FAIL_PTLRPC_ACK	      0x501
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index ecf472e..a7b34e4 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -193,6 +193,26 @@ void ldlm_extent_add_lock(struct ldlm_resource *res,
 	 * add the locks into grant list, for debug purpose, ..
 	 */
 	ldlm_resource_add_lock(res, &res->lr_granted, lock);
+
+	if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_GRANT_CHECK)) {
+		struct ldlm_lock *lck;
+
+		list_for_each_entry_reverse(lck, &res->lr_granted,
+					    l_res_link) {
+			if (lck == lock)
+				continue;
+			if (lockmode_compat(lck->l_granted_mode,
+					    lock->l_granted_mode))
+				continue;
+			if (ldlm_extent_overlap(&lck->l_req_extent,
+						&lock->l_req_extent)) {
+				CDEBUG(D_ERROR, "granting conflicting lock %p %p\n",
+				       lck, lock);
+				ldlm_resource_dump(D_ERROR, res);
+				LBUG();
+			}
+		}
+	}
 }
 
 /** Remove cancelled lock from resource interval tree. */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 43856ff..6e704c7 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1846,7 +1846,7 @@ static int ldlm_chain_lock_for_replay(struct ldlm_lock *lock, void *closure)
 	 * bug 17614: locks being actively cancelled. Get a reference
 	 * on a lock so that it does not disappear under us (e.g. due to cancel)
 	 */
-	if (!(lock->l_flags & (LDLM_FL_FAILED | LDLM_FL_CANCELING))) {
+	if (!(lock->l_flags & (LDLM_FL_FAILED | LDLM_FL_BL_DONE))) {
 		list_add(&lock->l_pending_chain, list);
 		LDLM_LOCK_GET(lock);
 	}
@@ -1915,7 +1915,7 @@ static int replay_one_lock(struct obd_import *imp, struct ldlm_lock *lock)
 	int flags;
 
 	/* Bug 11974: Do not replay a lock which is actively being canceled */
-	if (ldlm_is_canceling(lock)) {
+	if (ldlm_is_bl_done(lock)) {
 		LDLM_DEBUG(lock, "Not replaying canceled lock:");
 		return 0;
 	}
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 091558e..8023561 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1823,6 +1823,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	DEBUG_REQ(D_INODE, req, "%d pages, aa %p. now %ur/%dw in flight",
 		  page_count, aa, cli->cl_r_in_flight,
 		  cli->cl_w_in_flight);
+	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_DELAY_IO, cfs_fail_val);
 
 	ptlrpcd_add_req(req);
 	rc = 0;
-- 
2.7.4
