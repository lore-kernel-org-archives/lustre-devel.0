From: James Simmons <jsimmons@infradead.org>
Date: Wed, 14 Jun 2017 11:01:20 -0400
Subject: [lustre-devel] [PATCH 5/6] staging: lustre: lustre: several over 80
	characters cleanups
In-Reply-To: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
References: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1497452481-31124-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Cleanup many of the over 80 characters reported by checkpatch

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |  2 +-
 .../staging/lustre/lustre/include/lprocfs_status.h |  3 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |  5 ++--
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h | 13 +++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 33 ++++++++++++++--------
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |  3 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 14 +++++----
 drivers/staging/lustre/lustre/llite/file.c         |  3 +-
 .../staging/lustre/lustre/llite/llite_internal.h   | 10 +++++--
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  5 ++--
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |  3 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  6 ++--
 drivers/staging/lustre/lustre/llite/namei.c        |  6 ++--
 drivers/staging/lustre/lustre/llite/rw.c           |  6 ++--
 drivers/staging/lustre/lustre/llite/statahead.c    |  9 ++++--
 drivers/staging/lustre/lustre/llite/super25.c      |  3 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |  3 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        | 10 ++++---
 drivers/staging/lustre/lustre/lov/lov_pack.c       |  3 +-
 drivers/staging/lustre/lustre/lov/lov_pool.c       |  9 ++++--
 drivers/staging/lustre/lustre/lov/lproc_lov.c      | 12 +++++---
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        | 15 ++++++----
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |  5 ++--
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |  3 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    |  6 ++--
 .../staging/lustre/lustre/obdecho/echo_client.c    |  3 +-
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |  6 ++--
 drivers/staging/lustre/lustre/osc/osc_cache.c      | 10 +++++--
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |  4 ++-
 drivers/staging/lustre/lustre/osc/osc_request.c    | 14 +++++----
 drivers/staging/lustre/lustre/ptlrpc/client.c      | 21 ++++++++------
 drivers/staging/lustre/lustre/ptlrpc/import.c      |  8 +++---
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |  7 +++--
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c |  3 +-
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    | 15 ++++++----
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |  3 +-
 36 files changed, 184 insertions(+), 100 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 90a0c50..6e3b149 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1012,7 +1012,7 @@ struct cl_page_operations {
 #define CL_PAGE_HEADER(mask, env, page, format, ...)			  \
 do {									  \
 	if (cfs_cdebug_show(mask, DEBUG_SUBSYSTEM)) {			 \
-		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);		\
+		LIBCFS_DEBUG_MSG_DATA_DECL(msgdata, mask, NULL);	\
 		cl_page_header_print(env, &msgdata, lu_cdebug_printer, page); \
 		CDEBUG(mask, format, ## __VA_ARGS__);			\
 	}								     \
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 915283c..2d92055 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -577,7 +577,8 @@ void lprocfs_stats_collect(struct lprocfs_stats *stats, int idx,
 	{								\
 		return lprocfs_wr_##type(file, buffer, count, off);	\
 	}								\
-	static int name##_##type##_open(struct inode *inode, struct file *file) \
+	static int name##_##type##_open(struct inode *inode,		\
+					struct file *file)		\
 	{								\
 		return single_open(file, NULL, inode->i_private);	\
 	}								\
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index 08f97e2..8011368 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -241,8 +241,9 @@ void ldlm_extent_unlink_lock(struct ldlm_lock *lock)
 	}
 }
 
-void ldlm_extent_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
-				      union ldlm_policy_data *lpolicy)
+void
+ldlm_extent_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
+				 union ldlm_policy_data *lpolicy)
 {
 	lpolicy->l_extent.start = wpolicy->l_extent.start;
 	lpolicy->l_extent.end = wpolicy->l_extent.end;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index ec3b23c..cffdb94 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -88,7 +88,8 @@ void ldlm_namespace_move_to_inactive_locked(struct ldlm_namespace *ns,
 /* ldlm_request.c */
 /* Cancel lru flag, it indicates we cancel aged locks. */
 enum {
-	LDLM_LRU_FLAG_AGED	= BIT(0), /* Cancel aged locks (non lru resize). */
+	LDLM_LRU_FLAG_AGED	= BIT(0), /* Cancel aged locks (non lru resize).
+					   */
 	LDLM_LRU_FLAG_PASSED	= BIT(1), /* Cancel passed number of locks. */
 	LDLM_LRU_FLAG_SHRINK	= BIT(2), /* Cancel locks from shrinker. */
 	LDLM_LRU_FLAG_LRUR	= BIT(3), /* Cancel locks from lru resize. */
@@ -326,10 +327,12 @@ void ldlm_plain_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
 				     union ldlm_wire_policy_data *wpolicy);
 void ldlm_ibits_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
 				     union ldlm_policy_data *lpolicy);
-void ldlm_ibits_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
-				     union ldlm_wire_policy_data *wpolicy);
-void ldlm_extent_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
-				      union ldlm_policy_data *lpolicy);
+void
+ldlm_ibits_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
+				union ldlm_wire_policy_data *wpolicy);
+void
+ldlm_extent_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
+				 union ldlm_policy_data *lpolicy);
 void ldlm_extent_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
 				      union ldlm_wire_policy_data *wpolicy);
 void ldlm_flock_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index ddb4642..8599134 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1035,7 +1035,8 @@ void ldlm_grant_lock(struct ldlm_lock *lock, struct list_head *work_list)
 		ldlm_extent_add_lock(res, lock);
 	else if (res->lr_type == LDLM_FLOCK) {
 		/*
-		 * We should not add locks to granted list in the following cases:
+		 * We should not add locks to granted list in the following
+		 * cases:
 		 * - this is an UNLOCK but not a real lock;
 		 * - this is a TEST lock;
 		 * - this is a F_CANCELLK lock (async flock has req_mode == 0)
@@ -2050,13 +2051,16 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 		libcfs_debug_vmsg2(msgdata, fmt, args,
 				   " ns: \?\? lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: \?\? rrc=\?\? type: \?\?\? flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
 				   lock,
-				   lock->l_handle.h_cookie, atomic_read(&lock->l_refc),
+				   lock->l_handle.h_cookie,
+				   atomic_read(&lock->l_refc),
 				   lock->l_readers, lock->l_writers,
 				   ldlm_lockname[lock->l_granted_mode],
 				   ldlm_lockname[lock->l_req_mode],
-				   lock->l_flags, nid, lock->l_remote_handle.cookie,
+				   lock->l_flags, nid,
+				   lock->l_remote_handle.cookie,
 				   exp ? atomic_read(&exp->exp_refcount) : -99,
-				   lock->l_pid, lock->l_callback_timeout, lock->l_lvb_type);
+				   lock->l_pid, lock->l_callback_timeout,
+				   lock->l_lvb_type);
 		va_end(args);
 		return;
 	}
@@ -2066,7 +2070,8 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 		libcfs_debug_vmsg2(msgdata, fmt, args,
 				   " ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s [%llu->%llu] (req %llu->%llu) flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
 				   ldlm_lock_to_ns_name(lock), lock,
-				   lock->l_handle.h_cookie, atomic_read(&lock->l_refc),
+				   lock->l_handle.h_cookie,
+				   atomic_read(&lock->l_refc),
 				   lock->l_readers, lock->l_writers,
 				   ldlm_lockname[lock->l_granted_mode],
 				   ldlm_lockname[lock->l_req_mode],
@@ -2075,8 +2080,10 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				   ldlm_typename[resource->lr_type],
 				   lock->l_policy_data.l_extent.start,
 				   lock->l_policy_data.l_extent.end,
-				   lock->l_req_extent.start, lock->l_req_extent.end,
-				   lock->l_flags, nid, lock->l_remote_handle.cookie,
+				   lock->l_req_extent.start,
+				   lock->l_req_extent.end,
+				   lock->l_flags, nid,
+				   lock->l_remote_handle.cookie,
 				   exp ? atomic_read(&exp->exp_refcount) : -99,
 				   lock->l_pid, lock->l_callback_timeout,
 				   lock->l_lvb_type);
@@ -2086,7 +2093,8 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 		libcfs_debug_vmsg2(msgdata, fmt, args,
 				   " ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s pid: %d [%llu->%llu] flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu\n",
 				   ldlm_lock_to_ns_name(lock), lock,
-				   lock->l_handle.h_cookie, atomic_read(&lock->l_refc),
+				   lock->l_handle.h_cookie,
+				   atomic_read(&lock->l_refc),
 				   lock->l_readers, lock->l_writers,
 				   ldlm_lockname[lock->l_granted_mode],
 				   ldlm_lockname[lock->l_req_mode],
@@ -2096,7 +2104,8 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				   lock->l_policy_data.l_flock.pid,
 				   lock->l_policy_data.l_flock.start,
 				   lock->l_policy_data.l_flock.end,
-				   lock->l_flags, nid, lock->l_remote_handle.cookie,
+				   lock->l_flags, nid,
+				   lock->l_remote_handle.cookie,
 				   exp ? atomic_read(&exp->exp_refcount) : -99,
 				   lock->l_pid, lock->l_callback_timeout);
 		break;
@@ -2114,7 +2123,8 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				   lock->l_policy_data.l_inodebits.bits,
 				   atomic_read(&resource->lr_refcount),
 				   ldlm_typename[resource->lr_type],
-				   lock->l_flags, nid, lock->l_remote_handle.cookie,
+				   lock->l_flags, nid,
+				   lock->l_remote_handle.cookie,
 				   exp ? atomic_read(&exp->exp_refcount) : -99,
 				   lock->l_pid, lock->l_callback_timeout,
 				   lock->l_lvb_type);
@@ -2132,7 +2142,8 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				   PLDLMRES(resource),
 				   atomic_read(&resource->lr_refcount),
 				   ldlm_typename[resource->lr_type],
-				   lock->l_flags, nid, lock->l_remote_handle.cookie,
+				   lock->l_flags, nid,
+				   lock->l_remote_handle.cookie,
 				   exp ? atomic_read(&exp->exp_refcount) : -99,
 				   lock->l_pid, lock->l_callback_timeout,
 				   lock->l_lvb_type);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index cf3fc57..a2b659f 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -359,7 +359,8 @@ static int ldlm_pool_recalc(struct ldlm_pool *pl)
 	recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
 	if (recalc_interval_sec > 0) {
 		spin_lock(&pl->pl_lock);
-		recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
+		recalc_interval_sec = ktime_get_real_seconds() -
+				      pl->pl_recalc_time;
 
 		if (recalc_interval_sec > 0) {
 			/*
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 4028e11..96fb8a9 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1335,13 +1335,14 @@ typedef enum ldlm_policy_res (*ldlm_cancel_lru_policy_t)(
  * flags & LDLM_LRU_FLAG_LRUR	- use LRU resize policy (SLV from server) to
  *				  cancel not more than \a count locks;
  *
- * flags & LDLM_LRU_FLAG_PASSED - cancel \a count number of old locks (located at
- *				  the beginning of LRU list);
+ * flags & LDLM_LRU_FLAG_PASSED - cancel \a count number of old locks (located
+ *				  at the beginning of LRU list);
  *
- * flags & LDLM_LRU_FLAG_SHRINK - cancel not more than \a count locks according to
- *				  memory pressure policy function;
+ * flags & LDLM_LRU_FLAG_SHRINK - cancel not more than \a count locks according
+ *				  to memory pressure policy function;
  *
- * flags & LDLM_LRU_FLAG_AGED   - cancel \a count locks according to "aged policy".
+ * flags & LDLM_LRU_FLAG_AGED   - cancel \a count locks according to
+ *				  "aged policy".
  *
  * flags & LDLM_LRU_FLAG_NO_WAIT - cancel as many unused locks as possible
  *				   (typically before replaying locks) w/o
@@ -1355,7 +1356,8 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 	ldlm_cancel_lru_policy_t pf;
 	struct ldlm_lock *lock, *next;
 	int added = 0, unused, remained;
-	int no_wait = flags & (LDLM_LRU_FLAG_NO_WAIT | LDLM_LRU_FLAG_LRUR_NO_WAIT);
+	int no_wait = flags & (LDLM_LRU_FLAG_NO_WAIT |
+			       LDLM_LRU_FLAG_LRUR_NO_WAIT);
 
 	spin_lock(&ns->ns_lock);
 	unused = ns->ns_nr_unused;
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index ab1c85c..22d7939 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -605,7 +605,8 @@ int ll_file_open(struct inode *inode, struct file *file)
 			 * to get file with different fid.
 			 */
 			it->it_flags |= MDS_OPEN_LOCK | MDS_OPEN_BY_FID;
-			rc = ll_intent_file_open(file->f_path.dentry, NULL, 0, it);
+			rc = ll_intent_file_open(file->f_path.dentry, NULL, 0,
+						 it);
 			if (rc)
 				goto out_openerr;
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index cd3311a..e585f88 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -84,7 +84,9 @@ struct ll_dentry_data {
 
 struct ll_getname_data {
 	struct dir_context ctx;
-	char	    *lgd_name;      /* points to a buffer with NAME_MAX+1 size */
+	char		*lgd_name;	/* points to a buffer with NAME_MAX + 1
+					 * size
+					 */
 	struct lu_fid    lgd_fid;       /* target fid we are looking for */
 	int	      lgd_found;     /* inode matched? */
 };
@@ -637,7 +639,8 @@ static inline int ll_need_32bit_api(struct ll_sb_info *sbi)
 #if BITS_PER_LONG == 32
 	return 1;
 #elif defined(CONFIG_COMPAT)
-	return unlikely(in_compat_syscall() || (sbi->ll_flags & LL_SBI_32BIT_API));
+	return unlikely(in_compat_syscall() ||
+			(sbi->ll_flags & LL_SBI_32BIT_API));
 #else
 	return unlikely(sbi->ll_flags & LL_SBI_32BIT_API);
 #endif
@@ -1065,7 +1068,8 @@ struct ll_statahead_info {
 					     * hidden entries
 					     */
 				sai_agl_valid:1,/* AGL is valid for the dir */
-				sai_in_readpage:1;/* statahead is in readdir() */
+				sai_in_readpage:1;/* statahead is in readdir()
+						   */
 	wait_queue_head_t	sai_waitq;      /* stat-ahead wait queue */
 	struct ptlrpc_thread    sai_thread;     /* stat-ahead thread */
 	struct ptlrpc_thread    sai_agl_thread; /* AGL thread */
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 974a05d..98d350a 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -2574,8 +2574,9 @@ static int ll_linkea_decode(struct linkea_data *ldata, unsigned int linkno,
  *
  * \param[in]	  file	- File descriptor against which to perform the operation
  * \param[in,out] arg	- User-filled structure containing the linkno to operate
- *			  on and the available size. It is eventually filled with
- *			  the requested information or left untouched on error
+ *			  on and the available size. It is eventually filled
+ *			  with the requested information or left untouched on
+ *			  error
  *
  * \retval - 0 on success
  * \retval - Appropriate negative error code on failure
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index e50c637..db12c83 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -127,7 +127,8 @@ struct lustre_nfs_fid {
 };
 
 static struct dentry *
-ll_iget_for_nfs(struct super_block *sb, struct lu_fid *fid, struct lu_fid *parent)
+ll_iget_for_nfs(struct super_block *sb, struct lu_fid *fid,
+		struct lu_fid *parent)
 {
 	struct inode  *inode;
 	struct dentry *result;
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index aeae667..564761d 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -380,7 +380,8 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 					  const char __user *buffer,
 					  size_t count, loff_t *off)
 {
-	struct super_block *sb = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *seq = file->private_data;
+	struct super_block *sb = seq->private;
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	struct cl_client_cache *cache = sbi->ll_cache;
 	struct lu_env *env;
@@ -895,7 +896,8 @@ static ssize_t ll_unstable_stats_seq_write(struct file *file,
 					   const char __user *buffer,
 					   size_t count, loff_t *off)
 {
-	struct super_block *sb = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *seq = file->private_data;
+	struct super_block *sb = seq->private;
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	char kernbuf[128];
 	int val, rc;
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index a208a8b..54c18d9 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -281,6 +281,7 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 			truncate_inode_pages(inode->i_mapping, 0);
 
 			if (unlikely(!fid_is_zero(&lli->lli_pfid))) {
+				struct ll_sb_info *sbi = ll_i2sbi(inode);
 				struct inode *master_inode = NULL;
 				unsigned long hash;
 
@@ -295,7 +296,7 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 				       PFID(&lli->lli_pfid));
 
 				hash = cl_fid_build_ino(&lli->lli_pfid,
-							ll_need_32bit_api(ll_i2sbi(inode)));
+							ll_need_32bit_api(sbi));
 				/*
 				 * Do not lookup the inode with ilookup5,
 				 * otherwise it will cause dead lock,
@@ -738,7 +739,8 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 
 			*opened |= FILE_CREATED;
 		}
-		if (d_really_is_positive(dentry) && it_disposition(it, DISP_OPEN_OPEN)) {
+		if (d_really_is_positive(dentry) &&
+		    it_disposition(it, DISP_OPEN_OPEN)) {
 			/* Open dentry. */
 			if (S_ISFIFO(d_inode(dentry)->i_mode)) {
 				/* We cannot call open here as it might
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 1bac51f..9b68c4e 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -670,7 +670,8 @@ static void ras_stride_increase_window(struct ll_readahead_state *ras,
 
 	LASSERT(ras->ras_stride_length > 0);
 	LASSERTF(ras->ras_window_start + ras->ras_window_len
-		 >= ras->ras_stride_offset, "window_start %lu, window_len %lu stride_offset %lu\n",
+		 >= ras->ras_stride_offset,
+		 "window_start %lu, window_len %lu stride_offset %lu\n",
 		 ras->ras_window_start,
 		 ras->ras_window_len, ras->ras_stride_offset);
 
@@ -766,7 +767,8 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 			    PAGE_SHIFT;
 
 		CDEBUG(D_READA, "kmsp %llu mwp %lu mp %lu\n", kms_pages,
-		       ra->ra_max_read_ahead_whole_pages, ra->ra_max_pages_per_file);
+		       ra->ra_max_read_ahead_whole_pages,
+		       ra->ra_max_pages_per_file);
 
 		if (kms_pages &&
 		    kms_pages <= ra->ra_max_read_ahead_whole_pages) {
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 9bbca01..15b713c 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -571,7 +571,8 @@ static void sa_instantiate(struct ll_statahead_info *sai,
 	child = entry->se_inode;
 	if (child) {
 		/* revalidate; unlinked and re-created with the same name */
-		if (unlikely(!lu_fid_eq(&minfo->mi_data.op_fid2, &body->mbo_fid1))) {
+		if (unlikely(!lu_fid_eq(&minfo->mi_data.op_fid2,
+					&body->mbo_fid1))) {
 			entry->se_inode = NULL;
 			iput(child);
 			child = NULL;
@@ -1082,7 +1083,8 @@ static int ll_statahead_thread(void *arg)
 					struct ll_inode_info *clli;
 
 					clli = list_entry(sai->sai_agls.next,
-							  struct ll_inode_info, lli_agl_list);
+							  struct ll_inode_info,
+							  lli_agl_list);
 					list_del_init(&clli->lli_agl_list);
 					spin_unlock(&lli->lli_agl_lock);
 
@@ -1447,7 +1449,8 @@ static int revalidate_statahead_dentry(struct inode *dir,
 	if (entry->se_state == SA_ENTRY_SUCC && entry->se_inode) {
 		struct inode *inode = entry->se_inode;
 		struct lookup_intent it = { .it_op = IT_GETATTR,
-					    .it_lock_handle = entry->se_handle };
+					    .it_lock_handle = entry->se_handle
+		};
 		__u64 bits;
 
 		rc = md_revalidate_lock(ll_i2mdexp(dir), &it,
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 56f4b10..856390a 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -88,7 +88,8 @@ static int __init lustre_init(void)
 	struct timespec64 ts;
 	int i, rc, seed[2];
 
-	BUILD_BUG_ON(sizeof(LUSTRE_VOLATILE_HDR) != LUSTRE_VOLATILE_HDR_LEN + 1);
+	BUILD_BUG_ON(sizeof(LUSTRE_VOLATILE_HDR) !=
+		     LUSTRE_VOLATILE_HDR_LEN + 1);
 
 	/* print an address of _any_ initialized kernel symbol from this
 	 * module, to allow debugging with gdb that doesn't support data
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index f49db6c..c899fd0 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -222,7 +222,8 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 						      &RMF_MDT_BODY);
 			if (!body) {
 				if (it.it_lock_mode && lockh) {
-					ldlm_lock_decref(lockh, it.it_lock_mode);
+					ldlm_lock_decref(lockh,
+							 it.it_lock_mode);
 					it.it_lock_mode = 0;
 				}
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 64fcaef..7f0cb41 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1834,8 +1834,8 @@ static int lmv_early_cancel(struct obd_export *exp, struct lmv_tgt_desc *tgt,
 }
 
 /*
- * llite passes fid of an target inode in op_data->op_fid1 and id of directory in
- * op_data->op_fid2
+ * llite passes fid of an target inode in op_data->op_fid1 and id of directory
+ * in op_data->op_fid2
  */
 static int lmv_link(struct obd_export *exp, struct md_op_data *op_data,
 		    struct ptlrpc_request **request)
@@ -1916,7 +1916,8 @@ static int lmv_rename(struct obd_export *exp, struct md_op_data *op_data,
 	op_data->op_cap = cfs_curproc_cap_pack();
 
 	if (op_data->op_cli_flags & CLI_MIGRATE) {
-		LASSERTF(fid_is_sane(&op_data->op_fid3), "invalid FID " DFID "\n",
+		LASSERTF(fid_is_sane(&op_data->op_fid3),
+			 "invalid FID " DFID "\n",
 			 PFID(&op_data->op_fid3));
 
 		if (op_data->op_mea1) {
@@ -2415,7 +2416,8 @@ static int lmv_read_page(struct obd_export *exp, struct md_op_data *op_data,
 		return rc;
 
 	if (unlikely(lsm))
-		return lmv_read_striped_page(exp, op_data, cb_op, offset, ppage);
+		return lmv_read_striped_page(exp, op_data, cb_op, offset,
+					     ppage);
 
 	tgt = lmv_find_target(lmv, &op_data->op_fid1);
 	if (IS_ERR(tgt))
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 638b764..a6c90a6 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -350,7 +350,8 @@ int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
 	/* FIXME: Bug 1185 - copy fields properly when structs change */
 	/* struct lov_user_md_v3 and struct lov_mds_md_v3 must be the same */
 	BUILD_BUG_ON(sizeof(lum) != sizeof(struct lov_mds_md_v3));
-	BUILD_BUG_ON(sizeof(lum.lmm_objects[0]) != sizeof(lmmk->lmm_objects[0]));
+	BUILD_BUG_ON(sizeof(lum.lmm_objects[0]) !=
+		     sizeof(lmmk->lmm_objects[0]));
 
 	if (cpu_to_le32(LOV_MAGIC) != LOV_MAGIC &&
 	    (lmmk->lmm_magic == cpu_to_le32(LOV_MAGIC_V1) ||
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index 39daa17..0059aa8 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -106,7 +106,8 @@ static void *pool_key(struct hlist_node *hnode)
 	return pool->pool_name;
 }
 
-static int pool_hashkey_keycmp(const void *key, struct hlist_node *compared_hnode)
+static int pool_hashkey_keycmp(const void *key,
+			       struct hlist_node *compared_hnode)
 {
 	char *pool_name;
 	struct pool_desc *pool;
@@ -367,8 +368,12 @@ int lov_ost_pool_remove(struct ost_pool *op, __u32 idx)
 
 	for (i = 0; i < op->op_count; i++) {
 		if (op->op_array[i] == idx) {
+			size_t array_size;
+
+			array_size = (op->op_count - i - 1) *
+				     sizeof(op->op_array[0]);
 			memmove(&op->op_array[i], &op->op_array[i + 1],
-				(op->op_count - i - 1) * sizeof(op->op_array[0]));
+				array_size);
 			op->op_count--;
 			up_write(&op->op_rw_sem);
 			return 0;
diff --git a/drivers/staging/lustre/lustre/lov/lproc_lov.c b/drivers/staging/lustre/lustre/lov/lproc_lov.c
index eb6d30d..c028b6d 100644
--- a/drivers/staging/lustre/lustre/lov/lproc_lov.c
+++ b/drivers/staging/lustre/lustre/lov/lproc_lov.c
@@ -52,7 +52,8 @@ static ssize_t lov_stripesize_seq_write(struct file *file,
 					const char __user *buffer,
 					size_t count, loff_t *off)
 {
-	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *seq = file->private_data;
+	struct obd_device *dev = seq->private;
 	struct lov_desc *desc;
 	__u64 val;
 	int rc;
@@ -85,7 +86,8 @@ static ssize_t lov_stripeoffset_seq_write(struct file *file,
 					  const char __user *buffer,
 					  size_t count, loff_t *off)
 {
-	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *seq = file->private_data;
+	struct obd_device *dev = seq->private;
 	struct lov_desc *desc;
 	__u64 val;
 	int rc;
@@ -117,7 +119,8 @@ static ssize_t lov_stripetype_seq_write(struct file *file,
 					const char __user *buffer,
 					size_t count, loff_t *off)
 {
-	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *seq = file->private_data;
+	struct obd_device *dev = seq->private;
 	struct lov_desc *desc;
 	int val, rc;
 
@@ -149,7 +152,8 @@ static ssize_t lov_stripecount_seq_write(struct file *file,
 					 const char __user *buffer,
 					 size_t count, loff_t *off)
 {
-	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *seq = file->private_data;
+	struct obd_device *dev = seq->private;
 	struct lov_desc *desc;
 	int val, rc;
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index b1853ff..35f40ee 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -125,7 +125,8 @@ void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	char			*tmp;
 	__u64			 flags;
 
-	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) != sizeof(struct mdt_rec_create));
+	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) !=
+		     sizeof(struct mdt_rec_create));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
 	rec->cr_opcode   = REINT_CREATE;
@@ -189,7 +190,8 @@ void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	char *tmp;
 	__u64 cr_flags;
 
-	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) != sizeof(struct mdt_rec_create));
+	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) !=
+		     sizeof(struct mdt_rec_create));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
 	/* XXX do something about time, uid, gid */
@@ -336,7 +338,8 @@ void mdc_unlink_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 {
 	struct mdt_rec_unlink *rec;
 
-	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) != sizeof(struct mdt_rec_unlink));
+	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) !=
+		     sizeof(struct mdt_rec_unlink));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
 	rec->ul_opcode   = op_data->op_cli_flags & CLI_RM_ENTRY ?
@@ -359,7 +362,8 @@ void mdc_link_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 {
 	struct mdt_rec_link *rec;
 
-	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) != sizeof(struct mdt_rec_link));
+	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) !=
+		     sizeof(struct mdt_rec_link));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
 	rec->lk_opcode   = REINT_LINK;
@@ -407,7 +411,8 @@ void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 {
 	struct mdt_rec_rename *rec;
 
-	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) != sizeof(struct mdt_rec_rename));
+	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) !=
+		     sizeof(struct mdt_rec_rename));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
 	/* XXX do something about time, uid, gid */
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 3eb66ce..05ea024 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -587,7 +587,7 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 			mdc_set_open_replay_data(NULL, NULL, it);
 		}
 
-		if ((body->mbo_valid & (OBD_MD_FLDIREA | OBD_MD_FLEASIZE)) != 0) {
+		if (body->mbo_valid & (OBD_MD_FLDIREA | OBD_MD_FLEASIZE)) {
 			void *eadata;
 
 			mdc_update_max_ea_from_body(exp, body);
@@ -634,7 +634,8 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 
 				lmm = req_capsule_client_get(pill, &RMF_EADATA);
 				if (lmm)
-					memcpy(lmm, eadata, body->mbo_eadatasize);
+					memcpy(lmm, eadata,
+					       body->mbo_eadatasize);
 			}
 		}
 	} else if (it->it_op & IT_LAYOUT) {
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index eee0b66..bb69a60 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -94,7 +94,8 @@ int mgc_fsname2resid(char *fsname, struct ldlm_res_id *res_id, int type)
 }
 EXPORT_SYMBOL(mgc_fsname2resid);
 
-static int mgc_logname2resid(char *logname, struct ldlm_res_id *res_id, int type)
+static int mgc_logname2resid(char *logname, struct ldlm_res_id *res_id,
+			     int type)
 {
 	char *name_end;
 	int len;
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index fa0d38d..c30d735 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -73,7 +73,8 @@ static struct obd_device *obd_device_alloc(void)
 
 static void obd_device_free(struct obd_device *obd)
 {
-	LASSERTF(obd->obd_magic == OBD_DEVICE_MAGIC, "obd %p obd_magic %08x != %08x\n",
+	LASSERTF(obd->obd_magic == OBD_DEVICE_MAGIC,
+		 "obd %p obd_magic %08x != %08x\n",
 		 obd, obd->obd_magic, OBD_DEVICE_MAGIC);
 	if (obd->obd_namespace) {
 		CERROR("obd %p: namespace %p was not properly cleaned up (obd_force=%d)!\n",
@@ -346,7 +347,8 @@ void class_release_dev(struct obd_device *obd)
 {
 	struct obd_type *obd_type = obd->obd_type;
 
-	LASSERTF(obd->obd_magic == OBD_DEVICE_MAGIC, "%p obd_magic %08x != %08x\n",
+	LASSERTF(obd->obd_magic == OBD_DEVICE_MAGIC,
+		 "%p obd_magic %08x != %08x\n",
 		 obd, obd->obd_magic, OBD_DEVICE_MAGIC);
 	LASSERTF(obd == obd_devs[obd->obd_minor], "obd %p != obd_devs[%d] %p\n",
 		 obd, obd->obd_minor, obd_devs[obd->obd_minor]);
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 1c4a8fe..f4d49dc 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1304,7 +1304,8 @@ static int echo_client_kbrw(struct echo_device *ed, int rw, struct obdo *oa,
 
 			vrc = echo_client_page_debug_check(pgp->pg,
 							   ostid_id(&oa->o_oi),
-							   pgp->off, pgp->count);
+							   pgp->off,
+							   pgp->count);
 			if (vrc != 0 && rc == 0)
 				rc = vrc;
 		}
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 86f252d..f36273a 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -198,7 +198,8 @@ static ssize_t osc_cached_mb_seq_write(struct file *file,
 				       const char __user *buffer,
 				       size_t count, loff_t *off)
 {
-	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *seq = file->private_data;
+	struct obd_device *dev = seq->private;
 	struct client_obd *cli = &dev->u.cli;
 	long pages_number, rc;
 	char kernbuf[128];
@@ -413,7 +414,8 @@ static ssize_t osc_checksum_type_seq_write(struct file *file,
 					   const char __user *buffer,
 					   size_t count, loff_t *off)
 {
-	struct obd_device *obd = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *seq = file->private_data;
+	struct obd_device *obd = seq->private;
 	int i;
 
 	DECLARE_CKSUM_NAME;
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index d8a95f8..c20c7d7 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1141,8 +1141,9 @@ static int osc_extent_make_ready(const struct lu_env *env,
 	 * the size of file.
 	 */
 	if (!(last->oap_async_flags & ASYNC_COUNT_STABLE)) {
-		int last_oap_count = osc_refresh_count(env, last, OBD_BRW_WRITE);
+		int last_oap_count;
 
+		last_oap_count = osc_refresh_count(env, last, OBD_BRW_WRITE);
 		LASSERT(last_oap_count > 0);
 		LASSERT(last->oap_page_off + last_oap_count <= PAGE_SIZE);
 		last->oap_count = last_oap_count;
@@ -1619,7 +1620,9 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 		spin_lock(&cli->cl_loi_list_lock);
 
 		if (rc < 0) {
-			/* l_wait_event is interrupted by signal, or timed out */
+			/* l_wait_event is interrupted by signal, or
+			 * timed out
+			 */
 			list_del_init(&ocw.ocw_entry);
 			break;
 		}
@@ -1781,7 +1784,8 @@ static int osc_makes_hprpc(struct osc_object *obj)
 	return !list_empty(&obj->oo_hp_exts);
 }
 
-static void on_list(struct list_head *item, struct list_head *list, int should_be_on)
+static void on_list(struct list_head *item, struct list_head *list,
+		    int should_be_on)
 {
 	if (list_empty(item) && should_be_on)
 		list_add_tail(item, list);
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index 270212f..252c664 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -138,7 +138,9 @@ struct osc_object {
 	 * Manage write(dirty) extents.
 	 */
 	struct list_head	   oo_hp_exts; /* list of hp extents */
-	struct list_head	   oo_urgent_exts; /* list of writeback extents */
+	struct list_head	   oo_urgent_exts; /* list of writeback
+						    * extents
+						    */
 	struct list_head	   oo_rpc_exts;
 
 	struct list_head	   oo_reading_exts;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 922d0cb..cd306a0 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1229,7 +1229,7 @@ static int check_write_checksum(struct obdo *oa,
 
 	LCONSOLE_ERROR_MSG(0x132, "BAD WRITE CHECKSUM: %s: from %s inode " DFID " object " DOSTID " extent [%llu-%llu]\n",
 			   msg, libcfs_nid2str(peer->nid),
-			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_seq : (__u64)0,
+			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_seq : 0ULL,
 			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_oid : 0,
 			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_ver : 0,
 			   POSTID(&oa->o_oi), pga[0]->off,
@@ -1266,7 +1266,9 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 	/* set/clear over quota flag for a uid/gid */
 	if (lustre_msg_get_opc(req->rq_reqmsg) == OST_WRITE &&
 	    body->oa.o_valid & (OBD_MD_FLUSRQUOTA | OBD_MD_FLGRPQUOTA)) {
-		unsigned int qid[MAXQUOTAS] = { body->oa.o_uid, body->oa.o_gid };
+		unsigned int qid[MAXQUOTAS] = {
+			body->oa.o_uid, body->oa.o_gid
+		};
 
 		CDEBUG(D_QUOTA, "setdq for [%u %u] with valid %#llx, flags %x\n",
 		       body->oa.o_uid, body->oa.o_gid, body->oa.o_valid,
@@ -1431,10 +1433,11 @@ static int osc_brw_redo_request(struct ptlrpc_request *request,
 	/* cap resend delay to the current request timeout, this is similar to
 	 * what ptlrpc does (see after_reply())
 	 */
+	new_req->rq_sent = ktime_get_real_seconds();
 	if (aa->aa_resends > new_req->rq_timeout)
-		new_req->rq_sent = ktime_get_real_seconds() + new_req->rq_timeout;
+		new_req->rq_sent += new_req->rq_timeout;
 	else
-		new_req->rq_sent = ktime_get_real_seconds() + aa->aa_resends;
+		new_req->rq_sent += aa->aa_resends;
 	new_req->rq_generation_set = 1;
 	new_req->rq_import_generation = request->rq_import_generation;
 
@@ -1486,7 +1489,8 @@ static void sort_brw_pages(struct brw_page **array, int num)
 		for (i = stride ; i < num ; i++) {
 			tmp = array[i];
 			j = i;
-			while (j >= stride && array[j - stride]->off > tmp->off) {
+			while (array[j - stride]->off > tmp->off &&
+			       j >= stride) {
 				array[j] = array[j - stride];
 				j -= stride;
 			}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 1c77792..532fbdd 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -196,8 +196,8 @@ struct ptlrpc_bulk_desc *ptlrpc_prep_bulk_imp(struct ptlrpc_request *req,
 }
 EXPORT_SYMBOL(ptlrpc_prep_bulk_imp);
 
-void __ptlrpc_prep_bulk_page(struct ptlrpc_bulk_desc *desc,
-			     struct page *page, int pageoffset, int len, int pin)
+void __ptlrpc_prep_bulk_page(struct ptlrpc_bulk_desc *desc, struct page *page,
+			     int pageoffset, int len, int pin)
 {
 	struct bio_vec *kiov;
 
@@ -336,7 +336,8 @@ static void ptlrpc_at_adj_service(struct ptlrpc_request *req,
 	oldse = at_measured(&at->iat_service_estimate[idx], serv_est);
 	if (oldse != 0)
 		CDEBUG(D_ADAPTTO, "The RPC service estimate for %s ptl %d has changed from %d to %d\n",
-		       req->rq_import->imp_obd->obd_name, req->rq_request_portal,
+		       req->rq_import->imp_obd->obd_name,
+		       req->rq_request_portal,
 		       oldse, at_get(&at->iat_service_estimate[idx]));
 }
 
@@ -1138,7 +1139,9 @@ static int ptlrpc_import_delay_req(struct obd_import *imp,
 			  D_HA : D_ERROR, req, "IMP_CLOSED ");
 		*status = -EIO;
 	} else if (ptlrpc_send_limit_expired(req)) {
-		/* probably doesn't need to be a D_ERROR after initial testing */
+		/* probably doesn't need to be a D_ERROR after initial
+		 * testing
+		 */
 		DEBUG_REQ(D_HA, req, "send limit expired ");
 		*status = -ETIMEDOUT;
 	} else if (req->rq_send_state == LUSTRE_IMP_CONNECTING &&
@@ -1840,7 +1843,9 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 				spin_unlock(&req->rq_lock);
 
 				if (req->rq_timedout || req->rq_resend) {
-					/* This is re-sending anyway, let's mark req as resend. */
+					/* This is re-sending anyway,
+					 * let's mark req as resend.
+					 */
 					spin_lock(&req->rq_lock);
 					req->rq_resend = 1;
 					spin_unlock(&req->rq_lock);
@@ -2296,8 +2301,8 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 			lwi = LWI_TIMEOUT(cfs_time_seconds(timeout ? timeout : 1),
 					  ptlrpc_expired_set, set);
 
-		rc = l_wait_event(set->set_waitq, ptlrpc_check_set(NULL, set), &lwi);
-
+		rc = l_wait_event(set->set_waitq, ptlrpc_check_set(NULL, set),
+				  &lwi);
 		/*
 		 * LU-769 - if we ignored the signal because it was already
 		 * pending when we started, we need to handle it now or we risk
@@ -3075,7 +3080,7 @@ void ptlrpc_init_xid(void)
 	}
 
 	/* Always need to be aligned to a power-of-two for multi-bulk BRW */
-	BUILD_BUG_ON(((PTLRPC_BULK_OPS_COUNT - 1) & PTLRPC_BULK_OPS_COUNT) != 0);
+	BUILD_BUG_ON((PTLRPC_BULK_OPS_COUNT - 1) & PTLRPC_BULK_OPS_COUNT);
 	ptlrpc_last_xid &= PTLRPC_BULK_OPS_MASK;
 }
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 52cb1f0..f08879a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -159,6 +159,7 @@ int ptlrpc_set_import_discon(struct obd_import *imp, __u32 conn_cnt)
 
 	if (imp->imp_state == LUSTRE_IMP_FULL &&
 	    (conn_cnt == 0 || conn_cnt == imp->imp_conn_cnt)) {
+		char *nid = libcfs_nid2str(imp->imp_connection->c_peer.nid);
 		char *target_start;
 		int   target_len;
 
@@ -167,13 +168,12 @@ int ptlrpc_set_import_discon(struct obd_import *imp, __u32 conn_cnt)
 
 		if (imp->imp_replayable) {
 			LCONSOLE_WARN("%s: Connection to %.*s (at %s) was lost; in progress operations using this service will wait for recovery to complete\n",
-				      imp->imp_obd->obd_name, target_len, target_start,
-				      libcfs_nid2str(imp->imp_connection->c_peer.nid));
+				      imp->imp_obd->obd_name, target_len,
+				      target_start, nid);
 		} else {
 			LCONSOLE_ERROR_MSG(0x166, "%s: Connection to %.*s (at %s) was lost; in progress operations using this service will fail\n",
 					   imp->imp_obd->obd_name,
-					   target_len, target_start,
-					   libcfs_nid2str(imp->imp_connection->c_peer.nid));
+					   target_len, target_start, nid);
 		}
 		IMPORT_SET_STATE_NOLOCK(imp, LUSTRE_IMP_DISCON);
 		spin_unlock(&imp->imp_lock);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 5810bba..55ab12d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -1022,8 +1022,8 @@ struct req_msg_field RMF_LAYOUT_INTENT =
  * OST request field.
  */
 struct req_msg_field RMF_OST_BODY =
-	DEFINE_MSGF("ost_body", 0,
-		    sizeof(struct ost_body), lustre_swab_ost_body, dump_ost_body);
+	DEFINE_MSGF("ost_body", 0, sizeof(struct ost_body),
+		    lustre_swab_ost_body, dump_ost_body);
 EXPORT_SYMBOL(RMF_OST_BODY);
 
 struct req_msg_field RMF_OBD_IOOBJ =
@@ -2142,9 +2142,10 @@ void req_capsule_extend(struct req_capsule *pill, const struct req_format *fmt)
 	for (i = 0; i < RCL_NR; ++i) {
 		LASSERT(fmt->rf_fields[i].nr >= old->rf_fields[i].nr);
 		for (j = 0; j < old->rf_fields[i].nr - 1; ++j) {
-			const struct req_msg_field *ofield = FMT_FIELD(old, i, j);
+			const struct req_msg_field *ofield;
 
 			/* "opaque" fields can be transmogrified */
+			ofield = FMT_FIELD(old, i, j);
 			if (!ofield->rmf_swabber &&
 			    (ofield->rmf_flags & ~RMF_F_NO_SIZE_CHECK) == 0 &&
 			    (ofield->rmf_size == -1 ||
diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
index 110d9f5..c3a0daf 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
@@ -263,7 +263,8 @@ static int llog_client_read_header(const struct lu_env *env,
 	int rc;
 
 	LLOG_CLIENT_ENTRY(handle->lgh_ctxt, imp);
-	req = ptlrpc_request_alloc_pack(imp, &RQF_LLOG_ORIGIN_HANDLE_READ_HEADER,
+	req = ptlrpc_request_alloc_pack(imp,
+					&RQF_LLOG_ORIGIN_HANDLE_READ_HEADER,
 					LUSTRE_LOG_VERSION,
 					LLOG_ORIGIN_HANDLE_READ_HEADER);
 	if (!req) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index f874781..e874d0b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -289,7 +289,8 @@ static const char *ll_eopcode2str(__u32 opcode)
 					 const char __user *buffer,
 					 size_t count, loff_t *off)
 {
-	struct ptlrpc_service *svc = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *seq = file->private_data;
+	struct ptlrpc_service *svc = seq->private;
 	int bufpages;
 	int val;
 	int rc;
@@ -635,7 +636,8 @@ static ssize_t ptlrpc_lprocfs_nrs_seq_write(struct file *file,
 					    const char __user *buffer,
 					    size_t count, loff_t *off)
 {
-	struct ptlrpc_service *svc = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *seq = file->private_data;
+	struct ptlrpc_service *svc = seq->private;
 	enum ptlrpc_nrs_queue_type queue = PTLRPC_NRS_QUEUE_BOTH;
 	char *cmd;
 	char *cmd_copy = NULL;
@@ -1184,7 +1186,8 @@ void ptlrpc_lprocfs_unregister_obd(struct obd_device *obd)
 int lprocfs_wr_ping(struct file *file, const char __user *buffer,
 		    size_t count, loff_t *off)
 {
-	struct obd_device *obd = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *seq = file->private_data;
+	struct obd_device *obd = seq->private;
 	struct ptlrpc_request *req;
 	int rc;
 
@@ -1215,7 +1218,8 @@ int lprocfs_wr_ping(struct file *file, const char __user *buffer,
 int lprocfs_wr_import(struct file *file, const char __user *buffer,
 		      size_t count, loff_t *off)
 {
-	struct obd_device *obd = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *seq = file->private_data;
+	struct obd_device *obd = seq->private;
 	struct obd_import *imp = obd->u.cli.cl_import;
 	char *kbuf = NULL;
 	char *uuid;
@@ -1296,7 +1300,8 @@ int lprocfs_rd_pinger_recov(struct seq_file *m, void *n)
 int lprocfs_wr_pinger_recov(struct file *file, const char __user *buffer,
 			    size_t count, loff_t *off)
 {
-	struct obd_device *obd = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *seq = file->private_data;
+	struct obd_device *obd = seq->private;
 	struct client_obd *cli = &obd->u.cli;
 	struct obd_import *imp = cli->cl_import;
 	int rc, val;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 366f2ce..8c608bb 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -517,7 +517,8 @@ static int sptlrpc_req_replace_dead_ctx(struct ptlrpc_request *req)
 
 		set_current_state(TASK_INTERRUPTIBLE);
 		schedule_timeout(msecs_to_jiffies(MSEC_PER_SEC));
-	} else if (unlikely(!test_bit(PTLRPC_CTX_UPTODATE_BIT, &newctx->cc_flags))) {
+	} else if (unlikely(!test_bit(PTLRPC_CTX_UPTODATE_BIT,
+				      &newctx->cc_flags))) {
 		/*
 		 * new ctx not up to date yet
 		 */
-- 
1.8.3.1
