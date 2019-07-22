From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:52:14 -0400
Subject: [lustre-devel] [PATCH 07/11] lustre: osc: checkpatch cleanup
In-Reply-To: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
References: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563760338-806-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Many checkpatch errors exist in the osc layer. This address
a good chuck of them. Other are left since future patches will
cleanup those areas. Others will need more code rework so this
patch handles the simple cases. This is a good step forward
toward proper kernel code style compliance.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/lproc_osc.c    |  7 ++++---
 fs/lustre/osc/osc_cache.c    | 15 +++++----------
 fs/lustre/osc/osc_internal.h |  6 ++++--
 fs/lustre/osc/osc_lock.c     |  6 ++++--
 fs/lustre/osc/osc_object.c   |  6 ++++--
 fs/lustre/osc/osc_page.c     |  3 ++-
 fs/lustre/osc/osc_quota.c    | 20 ++++++++++++--------
 fs/lustre/osc/osc_request.c  | 38 ++++++++++++++++----------------------
 8 files changed, 51 insertions(+), 50 deletions(-)

diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index 299a69f..eb724f4 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -197,7 +197,8 @@ static ssize_t osc_cached_mb_seq_write(struct file *file,
 				       const char __user *buffer,
 				       size_t count, loff_t *off)
 {
-	struct obd_device *dev = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *m = file->private_data;
+	struct obd_device *dev = m->private;
 	struct client_obd *cli = &dev->u.cli;
 	long pages_number, rc;
 	char kernbuf[128];
@@ -251,7 +252,6 @@ static ssize_t cur_dirty_bytes_show(struct kobject *kobj,
 	struct client_obd *cli = &dev->u.cli;
 
 	return sprintf(buf, "%lu\n", cli->cl_dirty_pages << PAGE_SHIFT);
-
 }
 LUSTRE_RO_ATTR(cur_dirty_bytes);
 
@@ -405,7 +405,8 @@ static ssize_t osc_checksum_type_seq_write(struct file *file,
 					   const char __user *buffer,
 					   size_t count, loff_t *off)
 {
-	struct obd_device *obd = ((struct seq_file *)file->private_data)->private;
+	struct seq_file *m = file->private_data;
+	struct obd_device *obd = m->private;
 	DECLARE_CKSUM_NAME;
 	char kernbuf[10];
 	int i;
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index f8fddbf..46d578e 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -393,13 +393,6 @@ static void osc_extent_free(struct kref *kref)
 		LDLM_LOCK_PUT(ext->oe_dlmlock);
 		ext->oe_dlmlock = NULL;
 	}
-#if 0
-	// When cl_object_put drop the need for 'env',
-	// this code can be enabled.
-	cl_object_put(osc2cl(ext->oe_obj));
-
-	kmem_cache_free(osc_extent_kmem, ext);
-#endif
 }
 
 static struct osc_extent *osc_extent_get(struct osc_extent *ext)
@@ -1547,19 +1540,21 @@ static bool osc_enter_cache_try(struct client_obd *cli,
 				struct osc_async_page *oap,
 				int bytes)
 {
+	bool rc = false;
+
 	OSC_DUMP_GRANT(D_CACHE, cli, "need:%d\n", bytes);
 
 	if (osc_reserve_grant(cli, bytes) < 0)
-		return false;
+		return rc;
 
 	if (cli->cl_dirty_pages < cli->cl_dirty_max_pages &&
 	    atomic_long_read(&obd_dirty_pages) + 1 <= obd_max_dirty_pages) {
 		osc_consume_write_grant(cli, &oap->oap_brw_page);
-		return true;
+		rc = true;
 	} else {
 		__osc_unreserve_grant(cli, bytes, bytes);
-		return false;
 	}
+	return rc;
 }
 
 #define __wait_event_idle_exclusive_timeout_cmd(wq_head, condition,	\
diff --git a/fs/lustre/osc/osc_internal.h b/fs/lustre/osc/osc_internal.h
index 4033365..95f5b93 100644
--- a/fs/lustre/osc/osc_internal.h
+++ b/fs/lustre/osc/osc_internal.h
@@ -48,7 +48,8 @@ enum async_flags {
 					* added to an rpc
 					*/
 	ASYNC_URGENT		= 0x2, /* page must be put into an RPC
-					* before return */
+					* before return
+					*/
 	ASYNC_COUNT_STABLE	= 0x4, /* ap_refresh_count will not be
 					* called to give the caller a
 					* chance to update or cancel
@@ -178,7 +179,8 @@ struct osc_device {
 
 static inline struct osc_device *obd2osc_dev(const struct obd_device *d)
 {
-	return container_of_safe(d->obd_lu_dev, struct osc_device, od_cl.cd_lu_dev);
+	return container_of_safe(d->obd_lu_dev, struct osc_device,
+				 od_cl.cd_lu_dev);
 }
 
 extern struct lu_kmem_descr osc_caches[];
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index 612305a..65b734ea 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -212,12 +212,14 @@ static void osc_lock_lvb_update(const struct lu_env *env,
 		if (size > dlmlock->l_policy_data.l_extent.end)
 			size = dlmlock->l_policy_data.l_extent.end + 1;
 		if (size >= oinfo->loi_kms) {
-			LDLM_DEBUG(dlmlock, "lock acquired, setting rss=%llu, kms=%llu",
+			LDLM_DEBUG(dlmlock,
+				   "lock acquired, setting rss=%llu, kms=%llu",
 				   lvb->lvb_size, size);
 			valid |= CAT_KMS;
 			attr->cat_kms = size;
 		} else {
-			LDLM_DEBUG(dlmlock, "lock acquired, setting rss=%llu; leaving kms=%llu, end=%llu",
+			LDLM_DEBUG(dlmlock,
+				   "lock acquired, setting rss=%llu; leaving kms=%llu, end=%llu",
 				   lvb->lvb_size, oinfo->loi_kms,
 				   dlmlock->l_policy_data.l_extent.end);
 		}
diff --git a/fs/lustre/osc/osc_object.c b/fs/lustre/osc/osc_object.c
index 98a0b6c..7468729 100644
--- a/fs/lustre/osc/osc_object.c
+++ b/fs/lustre/osc/osc_object.c
@@ -125,7 +125,8 @@ static void osc_object_free(const struct lu_env *env, struct lu_object *obj)
 int osc_lvb_print(const struct lu_env *env, void *cookie,
 		  lu_printer_t p, const struct ost_lvb *lvb)
 {
-	return (*p)(env, cookie, "size: %llu mtime: %llu atime: %llu ctime: %llu blocks: %llu",
+	return (*p)(env, cookie,
+		    "size: %llu mtime: %llu atime: %llu ctime: %llu blocks: %llu",
 		    lvb->lvb_size, lvb->lvb_mtime, lvb->lvb_atime,
 		    lvb->lvb_ctime, lvb->lvb_blocks);
 }
@@ -137,7 +138,8 @@ static int osc_object_print(const struct lu_env *env, void *cookie,
 	struct lov_oinfo *oinfo = osc->oo_oinfo;
 	struct osc_async_rc *ar = &oinfo->loi_ar;
 
-	(*p)(env, cookie, "id: " DOSTID " idx: %d gen: %d kms_valid: %u kms %llu rc: %d force_sync: %d min_xid: %llu ",
+	(*p)(env, cookie,
+	     "id: " DOSTID " idx: %d gen: %d kms_valid: %u kms %llu rc: %d force_sync: %d min_xid: %llu ",
 	     POSTID(&oinfo->loi_oi), oinfo->loi_ost_idx,
 	     oinfo->loi_ost_gen, oinfo->loi_kms_valid, oinfo->loi_kms,
 	     ar->ar_rc, ar->ar_force_sync, ar->ar_min_xid);
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index ce911b8..8d541df 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -284,7 +284,8 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 {
 	struct osc_async_page *oap = &opg->ops_oap;
 
-	LASSERTF(oap->oap_magic == OAP_MAGIC, "Bad oap magic: oap %p, magic 0x%x\n",
+	LASSERTF(oap->oap_magic == OAP_MAGIC,
+		 "Bad oap magic: oap %p, magic 0x%x\n",
 		 oap, oap->oap_magic);
 	LASSERT(oap->oap_async_flags & ASYNC_READY);
 	LASSERT(oap->oap_async_flags & ASYNC_COUNT_STABLE);
diff --git a/fs/lustre/osc/osc_quota.c b/fs/lustre/osc/osc_quota.c
index 555f1be..5fa85c6 100644
--- a/fs/lustre/osc/osc_quota.c
+++ b/fs/lustre/osc/osc_quota.c
@@ -52,8 +52,8 @@ int osc_quota_chkdq(struct client_obd *cli, const unsigned int qid[])
 	for (type = 0; type < MAXQUOTAS; type++) {
 		struct osc_quota_info *oqi;
 
-		oqi = rhashtable_lookup_fast(&cli->cl_quota_hash[type], &qid[type],
-					     quota_hash_params);
+		oqi = rhashtable_lookup_fast(&cli->cl_quota_hash[type],
+					     &qid[type], quota_hash_params);
 		if (oqi) {
 			/* Must not access oqi here, it could have been
 			 * freed by osc_quota_setdq()
@@ -73,7 +73,8 @@ int osc_quota_chkdq(struct client_obd *cli, const unsigned int qid[])
 
 static void osc_quota_free(struct rcu_head *head)
 {
-	struct osc_quota_info *oqi = container_of(head, struct osc_quota_info, rcu);
+	struct osc_quota_info *oqi = container_of(head, struct osc_quota_info,
+						  rcu);
 
 	kmem_cache_free(osc_quota_kmem, oqi);
 }
@@ -123,8 +124,8 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 
 		/* lookup the ID in the per-type hash table */
 		rcu_read_lock();
-		oqi = rhashtable_lookup_fast(&cli->cl_quota_hash[type], &qid[type],
-					     quota_hash_params);
+		oqi = rhashtable_lookup_fast(&cli->cl_quota_hash[type],
+					     &qid[type], quota_hash_params);
 		if ((flags & fl_quota_flag(type)) != 0) {
 			/* This ID is getting close to its quota limit, let's
 			 * switch to sync I/O
@@ -140,7 +141,8 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 			}
 
 			rc = rhashtable_lookup_insert_fast(&cli->cl_quota_hash[type],
-							   &oqi->oqi_hash, quota_hash_params);
+							   &oqi->oqi_hash,
+							   quota_hash_params);
 			/* race with others? */
 			if (rc) {
 				kmem_cache_free(osc_quota_kmem, oqi);
@@ -162,7 +164,8 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 				continue;
 			}
 			if (rhashtable_remove_fast(&cli->cl_quota_hash[type],
-						   &oqi->oqi_hash, quota_hash_params) == 0)
+						   &oqi->oqi_hash,
+						   quota_hash_params) == 0)
 				call_rcu(&oqi->rcu, osc_quota_free);
 			rcu_read_unlock();
 			CDEBUG(D_QUOTA, "%s: setdq to remove for %s %d (%p)\n",
@@ -187,7 +190,8 @@ int osc_quota_setup(struct obd_device *obd)
 	int i, type;
 
 	for (type = 0; type < MAXQUOTAS; type++) {
-		if (rhashtable_init(&cli->cl_quota_hash[type], &quota_hash_params) != 0)
+		if (rhashtable_init(&cli->cl_quota_hash[type],
+				    &quota_hash_params) != 0)
 			break;
 	}
 
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 9484b9a..a64b8ab 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1413,32 +1413,26 @@ static int check_write_checksum(struct obdo *oa,
 				      aa->aa_ppga, OST_WRITE, cksum_type);
 
 	if (cksum_type != cksum_type_unpack(aa->aa_oa->o_flags))
-		msg = "the server did not use the checksum type specified in the original request - likely a protocol problem"
-			;
+		msg = "the server did not use the checksum type specified in the original request - likely a protocol problem";
 	else if (new_cksum == server_cksum)
-		msg = "changed on the client after we checksummed it - likely false positive due to mmap IO (bug 11742)"
-			;
+		msg = "changed on the client after we checksummed it - likely false positive due to mmap IO (bug 11742)";
 	else if (new_cksum == client_cksum)
 		msg = "changed in transit before arrival at OST";
 	else
-		msg = "changed in transit AND doesn't match the original - likely false positive due to mmap IO (bug 11742)"
-			;
-
-	LCONSOLE_ERROR_MSG(
-		0x132,
-		"%s: BAD WRITE CHECKSUM: %s: from %s inode " DFID
-		" object " DOSTID
-		" extent [%llu-%llu], original client csum %x (type %x), server csum %x (type %x), client csum now %x\n",
-		aa->aa_cli->cl_import->imp_obd->obd_name,
-		msg, libcfs_nid2str(peer->nid),
-		oa->o_valid & OBD_MD_FLFID ? oa->o_parent_seq : (u64)0,
-		oa->o_valid & OBD_MD_FLFID ? oa->o_parent_oid : 0,
-		oa->o_valid & OBD_MD_FLFID ? oa->o_parent_ver : 0,
-		POSTID(&oa->o_oi), aa->aa_ppga[0]->off,
-		aa->aa_ppga[aa->aa_page_count - 1]->off +
-		aa->aa_ppga[aa->aa_page_count - 1]->count - 1,
-		client_cksum, cksum_type_unpack(aa->aa_oa->o_flags),
-		server_cksum, cksum_type, new_cksum);
+		msg = "changed in transit AND doesn't match the original - likely false positive due to mmap IO (bug 11742)";
+
+	LCONSOLE_ERROR_MSG(0x132,
+			   "%s: BAD WRITE CHECKSUM: %s: from %s inode " DFID " object " DOSTID " extent [%llu-%llu], original client csum %x (type %x), server csum %x (type %x), client csum now %x\n",
+			   aa->aa_cli->cl_import->imp_obd->obd_name,
+			   msg, libcfs_nid2str(peer->nid),
+			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_seq : (u64)0,
+			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_oid : 0,
+			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_ver : 0,
+			   POSTID(&oa->o_oi), aa->aa_ppga[0]->off,
+			   aa->aa_ppga[aa->aa_page_count - 1]->off +
+			   aa->aa_ppga[aa->aa_page_count - 1]->count - 1,
+			   client_cksum, cksum_type_unpack(aa->aa_oa->o_flags),
+			   server_cksum, cksum_type, new_cksum);
 
 	return 1;
 }
-- 
1.8.3.1
