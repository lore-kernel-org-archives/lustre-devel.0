From: James Simmons <jsimmons@infradead.org>
Date: Wed, 14 Jun 2017 11:01:19 -0400
Subject: [lustre-devel] [PATCH 4/6] staging: lustre: lustre: add all missing
	indentifier names
In-Reply-To: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
References: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1497452481-31124-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Create identifier names missing from function prototypes as
reported by checkpatch.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/lprocfs_status.h |  4 ++--
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h | 27 ++++++++++++----------
 .../staging/lustre/lustre/llite/llite_internal.h   | 14 +++++------
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  2 +-
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |  4 ++--
 5 files changed, 27 insertions(+), 24 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 1e68c77..915283c 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -523,8 +523,8 @@ char *lprocfs_find_named_value(const char *buffer, const char *name,
 void lprocfs_stats_collect(struct lprocfs_stats *stats, int idx,
 			   struct lprocfs_counter *cnt);
 
-int lprocfs_single_release(struct inode *, struct file *);
-int lprocfs_seq_release(struct inode *, struct file *);
+int lprocfs_single_release(struct inode *inode, struct file *file);
+int lprocfs_seq_release(struct inode *inode, struct file *file);
 
 /* write the name##_seq_show function, call LPROC_SEQ_FOPS_RO for read-only
  * proc entries; otherwise, you will define name##_seq_write function also for
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 5d24b48..ec3b23c 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -79,11 +79,11 @@ static inline int ldlm_ns_empty(struct ldlm_namespace *ns)
 	return atomic_read(&ns->ns_bref) == 0;
 }
 
-void ldlm_namespace_move_to_active_locked(struct ldlm_namespace *,
-					  enum ldlm_side);
-void ldlm_namespace_move_to_inactive_locked(struct ldlm_namespace *,
-					    enum ldlm_side);
-struct ldlm_namespace *ldlm_namespace_first_locked(enum ldlm_side);
+void ldlm_namespace_move_to_active_locked(struct ldlm_namespace *ns,
+					  enum ldlm_side client);
+void ldlm_namespace_move_to_inactive_locked(struct ldlm_namespace *ns,
+					    enum ldlm_side client);
+struct ldlm_namespace *ldlm_namespace_first_locked(enum ldlm_side client);
 
 /* ldlm_request.c */
 /* Cancel lru flag, it indicates we cancel aged locks. */
@@ -130,16 +130,19 @@ enum ldlm_desc_ast_t {
 int ldlm_fill_lvb(struct ldlm_lock *lock, struct req_capsule *pill,
 		  enum req_location loc, void *data, int size);
 struct ldlm_lock *
-ldlm_lock_create(struct ldlm_namespace *ns, const struct ldlm_res_id *,
+ldlm_lock_create(struct ldlm_namespace *ns, const struct ldlm_res_id *id,
 		 enum ldlm_type type, enum ldlm_mode mode,
 		 const struct ldlm_callback_suite *cbs,
 		 void *data, __u32 lvb_len, enum lvb_type lvb_type);
-enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *, struct ldlm_lock **,
-				  void *cookie, __u64 *flags);
-void ldlm_lock_addref_internal(struct ldlm_lock *, enum ldlm_mode mode);
-void ldlm_lock_addref_internal_nolock(struct ldlm_lock *, enum ldlm_mode mode);
-void ldlm_lock_decref_internal(struct ldlm_lock *, enum ldlm_mode mode);
-void ldlm_lock_decref_internal_nolock(struct ldlm_lock *, enum ldlm_mode mode);
+enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *ns,
+				  struct ldlm_lock **lock, void *cookie,
+				  __u64 *flags);
+void ldlm_lock_addref_internal(struct ldlm_lock *lock, enum ldlm_mode mode);
+void ldlm_lock_addref_internal_nolock(struct ldlm_lock *lock,
+				      enum ldlm_mode mode);
+void ldlm_lock_decref_internal(struct ldlm_lock *lock, enum ldlm_mode mode);
+void ldlm_lock_decref_internal_nolock(struct ldlm_lock *lock,
+				      enum ldlm_mode mode);
 int ldlm_run_ast_work(struct ldlm_namespace *ns, struct list_head *rpc_list,
 		      enum ldlm_desc_ast_t ast_type);
 int ldlm_lock_remove_from_lru_check(struct ldlm_lock *lock, time_t last_use);
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 41a0c8d..cd3311a 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -718,14 +718,14 @@ struct page *ll_get_dir_page(struct inode *dir, struct md_op_data *op_data,
 struct inode *ll_iget(struct super_block *sb, ino_t hash,
 		      struct lustre_md *lic);
 int ll_test_inode_by_fid(struct inode *inode, void *opaque);
-int ll_md_blocking_ast(struct ldlm_lock *, struct ldlm_lock_desc *,
+int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 		       void *data, int flag);
 struct dentry *ll_splice_alias(struct inode *inode, struct dentry *de);
 void ll_update_times(struct ptlrpc_request *request, struct inode *inode);
 
 /* llite/rw.c */
 int ll_writepage(struct page *page, struct writeback_control *wbc);
-int ll_writepages(struct address_space *, struct writeback_control *wbc);
+int ll_writepages(struct address_space *mapping, struct writeback_control *wbc);
 int ll_readpage(struct file *file, struct page *page);
 void ll_readahead_init(struct inode *inode, struct ll_readahead_state *ras);
 int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io);
@@ -747,7 +747,7 @@ enum ldlm_mode ll_take_md_lock(struct inode *inode, __u64 bits,
 			       enum ldlm_mode mode);
 int ll_file_open(struct inode *inode, struct file *file);
 int ll_file_release(struct inode *inode, struct file *file);
-int ll_release_openhandle(struct inode *, struct lookup_intent *);
+int ll_release_openhandle(struct inode *inode, struct lookup_intent *it);
 int ll_md_real_close(struct inode *inode, fmode_t fmode);
 int ll_getattr(const struct path *path, struct kstat *stat,
 	       u32 request_mask, unsigned int flags);
@@ -778,9 +778,9 @@ int ll_dir_getstripe(struct inode *inode, void **lmmp, int *lmm_size,
 /* llite/dcache.c */
 
 extern const struct dentry_operations ll_d_ops;
-void ll_intent_drop_lock(struct lookup_intent *);
-void ll_intent_release(struct lookup_intent *);
-void ll_invalidate_aliases(struct inode *);
+void ll_intent_drop_lock(struct lookup_intent *it);
+void ll_intent_release(struct lookup_intent *it);
+void ll_invalidate_aliases(struct inode *inode);
 void ll_lookup_finish_locks(struct lookup_intent *it, struct inode *inode);
 int ll_revalidate_it_finish(struct ptlrpc_request *request,
 			    struct lookup_intent *it, struct inode *inode);
@@ -811,7 +811,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 int ll_show_options(struct seq_file *seq, struct dentry *dentry);
 void ll_dirty_page_discard_warn(struct page *page, int ioret);
 int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
-		  struct super_block *, struct lookup_intent *);
+		  struct super_block *sb, struct lookup_intent *it);
 int ll_obd_statfs(struct inode *inode, void __user *arg);
 int ll_get_max_mdsize(struct ll_sb_info *sbi, int *max_mdsize);
 int ll_get_default_mdsize(struct ll_sb_info *sbi, int *default_mdsize);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 63a10a9..64fcaef 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -75,7 +75,7 @@ static void lmv_activate_target(struct lmv_obd *lmv,
 static int lmv_set_mdc_active(struct lmv_obd *lmv, const struct obd_uuid *uuid,
 			      int activate)
 {
-	struct lmv_tgt_desc    *uninitialized_var(tgt);
+	struct lmv_tgt_desc *tgt = NULL;
 	struct obd_device      *obd;
 	u32		     i;
 	int		     rc = 0;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index d2707a3..c38e166 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -68,7 +68,7 @@ struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned int nfrags,
 void ptlrpc_set_add_new_req(struct ptlrpcd_ctl *pc,
 			    struct ptlrpc_request *req);
 int ptlrpc_expired_set(void *data);
-int ptlrpc_set_next_timeout(struct ptlrpc_request_set *);
+int ptlrpc_set_next_timeout(struct ptlrpc_request_set *set);
 void ptlrpc_resend_req(struct ptlrpc_request *request);
 void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req);
 void ptlrpc_assign_next_xid_nolock(struct ptlrpc_request *req);
@@ -79,7 +79,7 @@ void ptlrpc_set_add_new_req(struct ptlrpcd_ctl *pc,
 int ptlrpc_init_portals(void);
 void ptlrpc_exit_portals(void);
 
-void ptlrpc_request_handle_notconn(struct ptlrpc_request *);
+void ptlrpc_request_handle_notconn(struct ptlrpc_request *req);
 void lustre_assert_wire_constants(void);
 int ptlrpc_import_in_recovery(struct obd_import *imp);
 int ptlrpc_set_import_discon(struct obd_import *imp, __u32 conn_cnt);
-- 
1.8.3.1
