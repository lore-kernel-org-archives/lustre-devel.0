From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 18:18:00 +1100
Subject: [lustre-devel] [PATCH 12/16] staging: lustre: use
 wait_event_timeout in ptlrpcd()
In-Reply-To: <151358127190.5099.12792810096274074963.stgit@noble>
References: <151358127190.5099.12792810096274074963.stgit@noble>
Message-ID: <151358148023.5099.3845154685635781293.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

We can replace l_wait_event() with
wait_event_noload_timeout() here providing we call the
timeout function when wait_event_timeout() returns zero.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   12 ++++++++----
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |    9 +++++----
 3 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 81b7a7046d82..3e6d22beb9f5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -2125,9 +2125,8 @@ int ptlrpc_expire_one_request(struct ptlrpc_request *req, int async_unlink)
  * Callback used when waiting on sets with l_wait_event.
  * Always returns 1.
  */
-int ptlrpc_expired_set(void *data)
+int ptlrpc_expired_set(struct ptlrpc_request_set *set)
 {
-	struct ptlrpc_request_set *set = data;
 	struct list_head *tmp;
 	time64_t now = ktime_get_real_seconds();
 
@@ -2164,6 +2163,11 @@ int ptlrpc_expired_set(void *data)
 	 */
 	return 1;
 }
+static int ptlrpc_expired_set_void(void *data)
+{
+	struct ptlrpc_request_set *set = data;
+	return ptlrpc_expired_set(set);
+}
 
 /**
  * Sets rq_intr flag in \a req under spinlock.
@@ -2286,7 +2290,7 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 			 * so we allow interrupts during the timeout.
 			 */
 			lwi = LWI_TIMEOUT_INTR_ALL(HZ,
-						   ptlrpc_expired_set,
+						   ptlrpc_expired_set_void,
 						   ptlrpc_interrupted_set, set);
 		else
 			/*
@@ -2295,7 +2299,7 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 			 * complete, or an in-flight req times out.
 			 */
 			lwi = LWI_TIMEOUT((timeout ? timeout : 1) * HZ,
-					  ptlrpc_expired_set, set);
+					  ptlrpc_expired_set_void, set);
 
 		rc = l_wait_event(set->set_waitq, ptlrpc_check_set(NULL, set), &lwi);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index f9decbd1459d..6dd52d99d454 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -68,7 +68,7 @@ void ptlrpc_request_cache_free(struct ptlrpc_request *req);
 void ptlrpc_init_xid(void);
 void ptlrpc_set_add_new_req(struct ptlrpcd_ctl *pc,
 			    struct ptlrpc_request *req);
-int ptlrpc_expired_set(void *data);
+int ptlrpc_expired_set(struct ptlrpc_request_set *set);
 int ptlrpc_set_next_timeout(struct ptlrpc_request_set *set);
 void ptlrpc_resend_req(struct ptlrpc_request *request);
 void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index 0bdf1f54629b..b7df38e71946 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -434,16 +434,17 @@ static int ptlrpcd(void *arg)
 	 * new_req_list and ptlrpcd_check() moves them into the set.
 	 */
 	do {
-		struct l_wait_info lwi;
 		int timeout;
 
 		timeout = ptlrpc_set_next_timeout(set);
-		lwi = LWI_TIMEOUT((timeout ? timeout : 1) * HZ,
-				  ptlrpc_expired_set, set);
 
 		lu_context_enter(&env.le_ctx);
 		lu_context_enter(env.le_ses);
-		l_wait_event(set->set_waitq, ptlrpcd_check(&env, pc), &lwi);
+		if (wait_event_noload_timeout(set->set_waitq,
+					      ptlrpcd_check(&env, pc),
+					      (timeout ? timeout : 1) * HZ) == 0)
+			ptlrpc_expired_set(set);
+
 		lu_context_exit(&env.le_ctx);
 		lu_context_exit(env.le_ses);
 
