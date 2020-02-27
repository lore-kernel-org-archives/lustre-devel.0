From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:33 -0500
Subject: [lustre-devel] [PATCH 045/622] lustre: ldlm: fix l_last_activity
 usage
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-46-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Boyko <c17825@cray.com>

When race happen between ldlm_server_blocking_ast() and
ldlm_request_cancel(), the at_measured() is called with wrong
value equal to current time. And even worse, ldlm_bl_timeout() can
return current_time*1.5.
Before a time functions was fixed by LU-9019(fdeeed2fb) for 64bit,
this race leads to ETIMEDOUT at ptlrpc_import_delay_req() and
client eviction during bl ast sending. The wrong type conversion
take a place at pltrpc_send_limit_expired() at cfs_time_seconds().

We should not take cancels into accoount if the BLAST is not send,
just because the last_activity is not properly initialised - it
destroys the AT completely.
The patch devides l_last_activity to the client l_activity and
server l_blast_sent for better understanding. The l_blast_sent is
used for blocking ast only to measure time between BLAST and
cancel request.

For example:
 server cancels blocked lock after 1518731697s
 waiting_locks_callback()) ### lock callback timer expired after 0s:
 evicting client

WC-bug-id: https://jira.whamcloud.com/browse/LU-10945
Lustre-commit: e09d273cb5f2 ("LU-10945 ldlm: fix l_last_activity usage")
Signed-off-by: Alexander Boyko <c17825@cray.com>
Cray-bug-id: LUS-5736
Reviewed-on: https://review.whamcloud.com/32133
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Vitaly Fertman <c17818@cray.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Mikhal Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h | 13 +++++++------
 fs/lustre/ldlm/ldlm_lock.c     |  1 +
 fs/lustre/ldlm/ldlm_request.c  | 14 +++++++-------
 3 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 1a19b35..6ad12a3 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -708,12 +708,6 @@ struct ldlm_lock {
 	wait_queue_head_t		l_waitq;
 
 	/**
-	 * Seconds. It will be updated if there is any activity related to
-	 * the lock, e.g. enqueue the lock or send blocking AST.
-	 */
-	time64_t			l_last_activity;
-
-	/**
 	 * Time, in nanoseconds, last used by e.g. being matched by lock match.
 	 */
 	ktime_t				l_last_used;
@@ -735,6 +729,13 @@ struct ldlm_lock {
 
 	/** Private storage for lock user. Opaque to LDLM. */
 	void				*l_ast_data;
+
+	/**
+	 * Seconds. It will be updated if there is any activity related to
+	 * the lock at client, e.g. enqueue the lock.
+	 */
+	time64_t			l_activity;
+
 	/* Separate ost_lvb used mostly by Data-on-MDT for now.
 	 * It is introduced to don't mix with layout lock data.
 	 */
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 894b99b..1bf387a 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -420,6 +420,7 @@ static struct ldlm_lock *ldlm_lock_new(struct ldlm_resource *resource)
 	lu_ref_init(&lock->l_reference);
 	lu_ref_add(&lock->l_reference, "hash", lock);
 	lock->l_callback_timeout = 0;
+	lock->l_activity = 0;
 
 #if LUSTRE_TRACKS_LOCK_EXP_REFS
 	INIT_LIST_HEAD(&lock->l_exp_refs_link);
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 3991a8f..67c23fc 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -114,9 +114,9 @@ static void ldlm_expired_completion_wait(struct ldlm_lock *lock, u32 conn_cnt)
 
 		LDLM_ERROR(lock,
 			   "lock timed out (enqueued at %lld, %llds ago); not entering recovery in server code, just going back to sleep",
-			   (s64)lock->l_last_activity,
+			   (s64)lock->l_activity,
 			   (s64)(ktime_get_real_seconds() -
-				 lock->l_last_activity));
+				 lock->l_activity));
 		if (ktime_get_seconds() > next_dump) {
 			last_dump = next_dump;
 			next_dump = ktime_get_seconds() + 300;
@@ -133,8 +133,8 @@ static void ldlm_expired_completion_wait(struct ldlm_lock *lock, u32 conn_cnt)
 	ptlrpc_fail_import(imp, conn_cnt);
 	LDLM_ERROR(lock,
 		   "lock timed out (enqueued at %lld, %llds ago), entering recovery for %s@%s",
-		   (s64)lock->l_last_activity,
-		   (s64)(ktime_get_real_seconds() - lock->l_last_activity),
+		   (s64)lock->l_activity,
+		   (s64)(ktime_get_real_seconds() - lock->l_activity),
 		   obd2cli_tgt(obd), imp->imp_connection->c_remote_uuid.uuid);
 }
 
@@ -182,7 +182,7 @@ static int ldlm_completion_tail(struct ldlm_lock *lock, void *data)
 		LDLM_DEBUG(lock, "client-side enqueue: granted");
 	} else {
 		/* Take into AT only CP RPC, not immediately granted locks */
-		delay = ktime_get_real_seconds() - lock->l_last_activity;
+		delay = ktime_get_real_seconds() - lock->l_activity;
 		LDLM_DEBUG(lock, "client-side enqueue: granted after %lds",
 			   delay);
 
@@ -245,7 +245,7 @@ int ldlm_completion_ast(struct ldlm_lock *lock, u64 flags, void *data)
 
 	timeout = ldlm_cp_timeout(lock);
 
-	lock->l_last_activity = ktime_get_real_seconds();
+	lock->l_activity = ktime_get_real_seconds();
 
 	if (imp) {
 		spin_lock(&imp->imp_lock);
@@ -725,7 +725,7 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 	lock->l_export = NULL;
 	lock->l_blocking_ast = einfo->ei_cb_bl;
 	lock->l_flags |= (*flags & (LDLM_FL_NO_LRU | LDLM_FL_EXCL));
-	lock->l_last_activity = ktime_get_real_seconds();
+	lock->l_activity = ktime_get_real_seconds();
 
 	/* lock not sent to server yet */
 	if (!reqp || !*reqp) {
-- 
1.8.3.1
