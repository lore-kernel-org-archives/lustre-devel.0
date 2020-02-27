From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:44 -0500
Subject: [lustre-devel] [PATCH 296/622] lustre: mdt: fix
 mdt_dom_discard_data() timeouts
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-297-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

The mdt_dom_discard_data() issues new lock to cause data
discard for all conflicting client locks. This was done in
context of unlink RPC processing and may cause it to be stuck
waiting for client to cancel their locks leading to cascading
timeouts for any other locks waiting on the same resource and
parent directory.

Patch skips discard lock waiting in the current context by
using own CP callback for that which doesn't wait for blocking
locks. They will be finished later by LDLM and cleaned up in
that completion callback. So current thread just makes sure
discard locks are taken and BL ASTs are sent but doesn't wait
for lock granting and that fixes the original problem.

At the same time that opens window for race with data being
flushed on client, so it is possible that new IO from client
will happen on just unlinked object causing error message and
it is not possible to distinguish that case from other
possibly critical situations. To solve that the unlinked object
is pinned in memory while until discard lock is granted.
Therefore, such objects can be easily distinguished as stale one
and any IO against it can be just silently ignored.

Older clients are not fully compatible with async DoM discard so
patch adds also new connection flag ASYNC_DISCARD to distinguish
old clients and use old blocking discard for then.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11359
Lustre-commit: 9c028e74c220 ("LU-11359 mdt: fix mdt_dom_discard_data() timeouts")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34071
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h         |  2 ++
 fs/lustre/ldlm/ldlm_internal.h         |  5 +----
 fs/lustre/ldlm/ldlm_request.c          | 13 +++++++++++++
 fs/lustre/llite/llite_lib.c            | 19 ++++++++++++-------
 fs/lustre/llite/namei.c                | 12 +++++++++++-
 fs/lustre/obdclass/lprocfs_status.c    |  1 +
 fs/lustre/osc/osc_cache.c              |  2 +-
 fs/lustre/ptlrpc/service.c             | 23 +++++++++++++++++++++++
 fs/lustre/ptlrpc/wiretest.c            |  2 ++
 include/uapi/linux/lustre/lustre_idl.h |  3 +++
 10 files changed, 69 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 355049f..4060bb4 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -1082,6 +1082,8 @@ static inline struct ldlm_lock *ldlm_handle2lock(const struct lustre_handle *h)
 	return lock;
 }
 
+int is_granted_or_cancelled_nolock(struct ldlm_lock *lock);
+
 int ldlm_error2errno(enum ldlm_error error);
 
 #if LUSTRE_TRACKS_LOCK_EXP_REFS
diff --git a/fs/lustre/ldlm/ldlm_internal.h b/fs/lustre/ldlm/ldlm_internal.h
index ede48b2..3789496 100644
--- a/fs/lustre/ldlm/ldlm_internal.h
+++ b/fs/lustre/ldlm/ldlm_internal.h
@@ -310,10 +310,7 @@ static inline int is_granted_or_cancelled(struct ldlm_lock *lock)
 	int ret = 0;
 
 	lock_res_and_lock(lock);
-	if (ldlm_is_granted(lock) && !ldlm_is_cp_reqd(lock))
-		ret = 1;
-	else if (ldlm_is_failed(lock) || ldlm_is_cancel(lock))
-		ret = 1;
+	ret = is_granted_or_cancelled_nolock(lock);
 	unlock_res_and_lock(lock);
 
 	return ret;
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 45d70d4..71892a5 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -138,6 +138,19 @@ static void ldlm_expired_completion_wait(struct ldlm_lock *lock, u32 conn_cnt)
 		   obd2cli_tgt(obd), imp->imp_connection->c_remote_uuid.uuid);
 }
 
+int is_granted_or_cancelled_nolock(struct ldlm_lock *lock)
+{
+	int ret = 0;
+
+	check_res_locked(lock->l_resource);
+	if (ldlm_is_granted(lock) && !ldlm_is_cp_reqd(lock))
+		ret = 1;
+	else if (ldlm_is_failed(lock) || ldlm_is_cancel(lock))
+		ret = 1;
+	return ret;
+}
+EXPORT_SYMBOL(is_granted_or_cancelled_nolock);
+
 /**
  * Calculate the Completion timeout (covering enqueue, BL AST, data flush,
  * lock cancel, and their replies). Used for lock completion timeout on the
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index ba477ad..a89189c 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -213,7 +213,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				   OBD_CONNECT2_FLR |
 				   OBD_CONNECT2_LOCK_CONVERT |
 				   OBD_CONNECT2_ARCHIVE_ID_ARRAY |
-				   OBD_CONNECT2_LSOM;
+				   OBD_CONNECT2_LSOM |
+				   OBD_CONNECT2_ASYNC_DISCARD;
 
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
@@ -2054,13 +2055,17 @@ void ll_delete_inode(struct inode *inode)
 	struct address_space *mapping = &inode->i_data;
 	unsigned long nrpages;
 
-	if (S_ISREG(inode->i_mode) && lli->lli_clob)
-		/* discard all dirty pages before truncating them, required by
-		 * osc_extent implementation at LU-1030.
+	if (S_ISREG(inode->i_mode) && lli->lli_clob) {
+		/* It is last chance to write out dirty pages,
+		 * otherwise we may lose data while umount.
+		 *
+		 * If i_nlink is 0 then just discard data. This is safe because
+		 * local inode gets i_nlink 0 from server only for the last
+		 * unlink, so that file is not opened somewhere else
 		 */
-		cl_sync_file_range(inode, 0, OBD_OBJECT_EOF,
-				   CL_FSYNC_LOCAL, 1);
-
+		cl_sync_file_range(inode, 0, OBD_OBJECT_EOF, inode->i_nlink ?
+				   CL_FSYNC_LOCAL : CL_FSYNC_DISCARD, 1);
+	}
 	truncate_inode_pages_final(mapping);
 
 	/* Workaround for LU-118: Note nrpages may not be totally updated when
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index ee3ce70..c3e8de4 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -224,8 +224,18 @@ void ll_lock_cancel_bits(struct ldlm_lock *lock, u64 to_cancel)
 	u64 bits = to_cancel;
 	int rc;
 
-	if (!inode)
+	if (!inode) {
+		/* That means the inode is evicted most likely and may cause
+		 * the skipping of lock cleanups below, so print the message
+		 * about that in log.
+		 */
+		if (lock->l_resource->lr_lvb_inode)
+			LDLM_DEBUG(lock,
+				   "can't take inode for the lock (%sevicted)\n",
+				   lock->l_resource->lr_lvb_inode->i_state &
+				   I_FREEING ? "" : "not ");
 		return;
+	}
 
 	if (!fid_res_name_eq(ll_inode2fid(inode),
 			     &lock->l_resource->lr_name)) {
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 55057cf..c244adb 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -125,6 +125,7 @@
 	"lsom",			/* 0x800 */
 	"pcc",			/* 0x1000 */
 	"plain_layout",		/* 0x2000 */
+	"async_discard",	/* 0x4000 */
 	NULL
 };
 
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index a02adac..8ffd8f9 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2926,7 +2926,7 @@ int osc_cache_writeback_range(const struct lu_env *env, struct osc_object *obj,
 				 * [start, end] must contain this extent
 				 */
 				EASSERT(ext->oe_start >= start &&
-					ext->oe_max_end <= end, ext);
+					ext->oe_end <= end, ext);
 				osc_extent_state_set(ext, OES_LOCKING);
 				ext->oe_owner = current;
 				list_move_tail(&ext->oe_link, &discard_list);
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index d93cf14..8e6013a 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -2367,8 +2367,13 @@ static int ptlrpc_hr_main(void *arg)
 	struct ptlrpc_hr_thread	*hrt = arg;
 	struct ptlrpc_hr_partition *hrp = hrt->hrt_partition;
 	LIST_HEAD(replies);
+	struct lu_env *env;
 	int rc;
 
+	env = kzalloc(sizeof(*env), GFP_NOFS);
+	if (!env)
+		return -ENOMEM;
+
 	unshare_fs_struct();
 
 	rc = cfs_cpt_bind(ptlrpc_hr.hr_cpt_table, hrp->hrp_cpt);
@@ -2381,6 +2386,15 @@ static int ptlrpc_hr_main(void *arg)
 		      threadname, hrp->hrp_cpt, ptlrpc_hr.hr_cpt_table, rc);
 	}
 
+	rc = lu_context_init(&env->le_ctx, LCT_MD_THREAD | LCT_DT_THREAD |
+			     LCT_REMEMBER | LCT_NOREF);
+	if (rc)
+		goto out_env;
+
+	rc = lu_env_add(env);
+	if (rc)
+		goto out_ctx_fini;
+
 	atomic_inc(&hrp->hrp_nstarted);
 	wake_up(&ptlrpc_hr.hr_waitq);
 
@@ -2394,13 +2408,22 @@ static int ptlrpc_hr_main(void *arg)
 					     struct ptlrpc_reply_state,
 					     rs_list);
 			list_del_init(&rs->rs_list);
+			/* refill keys if needed */
+			lu_env_refill(env);
+			lu_context_enter(&env->le_ctx);
 			ptlrpc_handle_rs(rs);
+			lu_context_exit(&env->le_ctx);
 		}
 	}
 
 	atomic_inc(&hrp->hrp_nstopped);
 	wake_up(&ptlrpc_hr.hr_waitq);
 
+	lu_env_remove(env);
+out_ctx_fini:
+	lu_context_fini(&env->le_ctx);
+out_env:
+	kfree(env);
 	return 0;
 }
 
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index fb57def..34c1d13 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1156,6 +1156,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_PCC);
 	LASSERTF(OBD_CONNECT2_PLAIN_LAYOUT == 0x2000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_PLAIN_LAYOUT);
+	LASSERTF(OBD_CONNECT2_ASYNC_DISCARD == 0x4000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_ASYNC_DISCARD);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index f7ea744..86395b7 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -810,6 +810,9 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT2_LSOM	       0x800ULL	/* LSOM support */
 #define OBD_CONNECT2_PCC	       0x1000ULL /* Persistent Client Cache */
 #define OBD_CONNECT2_PLAIN_LAYOUT      0x2000ULL /* Plain Directory Layout */
+#define OBD_CONNECT2_ASYNC_DISCARD     0x4000ULL /* support async DoM data
+						  * discard
+						  */
 
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
-- 
1.8.3.1
