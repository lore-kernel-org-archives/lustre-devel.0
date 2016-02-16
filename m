From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:50 -0500
Subject: [lustre-devel] [PATCH 18/45] staging/lustre/fld: Adjust NULL
	comparison codestyle
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-19-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

All instances of "x == NULL" are changed to "!x" and
"x != NULL" to "x"

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/fld/fld_cache.c    | 10 +++-----
 drivers/staging/lustre/lustre/fld/fld_internal.h |  2 +-
 drivers/staging/lustre/lustre/fld/fld_request.c  | 32 +++++++++++-------------
 drivers/staging/lustre/lustre/fld/lproc_fld.c    | 11 ++------
 4 files changed, 22 insertions(+), 33 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fld/fld_cache.c b/drivers/staging/lustre/lustre/fld/fld_cache.c
index d9459e5..a7026a9 100644
--- a/drivers/staging/lustre/lustre/fld/fld_cache.c
+++ b/drivers/staging/lustre/lustre/fld/fld_cache.c
@@ -65,7 +65,7 @@ struct fld_cache *fld_cache_init(const char *name,
 {
 	struct fld_cache *cache;
 
-	LASSERT(name != NULL);
+	LASSERT(name);
 	LASSERT(cache_threshold < cache_size);
 
 	cache = kzalloc(sizeof(*cache), GFP_NOFS);
@@ -100,7 +100,7 @@ void fld_cache_fini(struct fld_cache *cache)
 {
 	__u64 pct;
 
-	LASSERT(cache != NULL);
+	LASSERT(cache);
 	fld_cache_flush(cache);
 
 	if (cache->fci_stat.fst_count > 0) {
@@ -218,8 +218,6 @@ static int fld_cache_shrink(struct fld_cache *cache)
 	struct list_head *curr;
 	int num = 0;
 
-	LASSERT(cache != NULL);
-
 	if (cache->fci_cache_count < cache->fci_cache_size)
 		return 0;
 
@@ -414,7 +412,7 @@ static int fld_cache_insert_nolock(struct fld_cache *cache,
 		}
 	}
 
-	if (prev == NULL)
+	if (!prev)
 		prev = head;
 
 	CDEBUG(D_INFO, "insert range "DRANGE"\n", PRANGE(&f_new->fce_range));
@@ -499,7 +497,7 @@ int fld_cache_lookup(struct fld_cache *cache,
 	cache->fci_stat.fst_count++;
 	list_for_each_entry(flde, head, fce_list) {
 		if (flde->fce_range.lsr_start > seq) {
-			if (prev != NULL)
+			if (prev)
 				*range = prev->fce_range;
 			break;
 		}
diff --git a/drivers/staging/lustre/lustre/fld/fld_internal.h b/drivers/staging/lustre/lustre/fld/fld_internal.h
index 12eb164..59eabda 100644
--- a/drivers/staging/lustre/lustre/fld/fld_internal.h
+++ b/drivers/staging/lustre/lustre/fld/fld_internal.h
@@ -169,7 +169,7 @@ struct fld_cache_entry
 static inline const char *
 fld_target_name(struct lu_fld_target *tar)
 {
-	if (tar->ft_srv != NULL)
+	if (tar->ft_srv)
 		return tar->ft_srv->lsf_name;
 
 	return (const char *)tar->ft_exp->exp_obd->obd_name;
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index d92c01b..222d18d 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -148,9 +148,9 @@ again:
 		fld->lcf_name, hash, seq, fld->lcf_count);
 
 	list_for_each_entry(target, &fld->lcf_targets, ft_chain) {
-		const char *srv_name = target->ft_srv != NULL  ?
+		const char *srv_name = target->ft_srv ?
 			target->ft_srv->lsf_name : "<null>";
-		const char *exp_name = target->ft_exp != NULL ?
+		const char *exp_name = target->ft_exp ?
 			(char *)target->ft_exp->exp_obd->obd_uuid.uuid :
 			"<null>";
 
@@ -183,13 +183,13 @@ fld_client_get_target(struct lu_client_fld *fld, u64 seq)
 {
 	struct lu_fld_target *target;
 
-	LASSERT(fld->lcf_hash != NULL);
+	LASSERT(fld->lcf_hash);
 
 	spin_lock(&fld->lcf_lock);
 	target = fld->lcf_hash->fh_scan_func(fld, seq);
 	spin_unlock(&fld->lcf_lock);
 
-	if (target != NULL) {
+	if (target) {
 		CDEBUG(D_INFO, "%s: Found target (idx %llu) by seq %#llx\n",
 		       fld->lcf_name, target->ft_idx, seq);
 	}
@@ -207,10 +207,10 @@ int fld_client_add_target(struct lu_client_fld *fld,
 	const char *name;
 	struct lu_fld_target *target, *tmp;
 
-	LASSERT(tar != NULL);
+	LASSERT(tar);
 	name = fld_target_name(tar);
-	LASSERT(name != NULL);
-	LASSERT(tar->ft_srv != NULL || tar->ft_exp != NULL);
+	LASSERT(name);
+	LASSERT(tar->ft_srv || tar->ft_exp);
 
 	if (fld->lcf_flags != LUSTRE_FLD_INIT) {
 		CERROR("%s: Attempt to add target %s (idx %llu) on fly - skip it\n",
@@ -236,7 +236,7 @@ int fld_client_add_target(struct lu_client_fld *fld,
 	}
 
 	target->ft_exp = tar->ft_exp;
-	if (target->ft_exp != NULL)
+	if (target->ft_exp)
 		class_export_get(target->ft_exp);
 	target->ft_srv = tar->ft_srv;
 	target->ft_idx = tar->ft_idx;
@@ -264,7 +264,7 @@ int fld_client_del_target(struct lu_client_fld *fld, __u64 idx)
 			list_del(&target->ft_chain);
 			spin_unlock(&fld->lcf_lock);
 
-			if (target->ft_exp != NULL)
+			if (target->ft_exp)
 				class_export_put(target->ft_exp);
 
 			kfree(target);
@@ -326,8 +326,6 @@ int fld_client_init(struct lu_client_fld *fld,
 	int cache_size, cache_threshold;
 	int rc;
 
-	LASSERT(fld != NULL);
-
 	snprintf(fld->lcf_name, sizeof(fld->lcf_name),
 		 "cli-%s", prefix);
 
@@ -379,13 +377,13 @@ void fld_client_fini(struct lu_client_fld *fld)
 				     &fld->lcf_targets, ft_chain) {
 		fld->lcf_count--;
 		list_del(&target->ft_chain);
-		if (target->ft_exp != NULL)
+		if (target->ft_exp)
 			class_export_put(target->ft_exp);
 		kfree(target);
 	}
 	spin_unlock(&fld->lcf_lock);
 
-	if (fld->lcf_cache != NULL) {
+	if (fld->lcf_cache) {
 		if (!IS_ERR(fld->lcf_cache))
 			fld_cache_fini(fld->lcf_cache);
 		fld->lcf_cache = NULL;
@@ -402,12 +400,12 @@ int fld_client_rpc(struct obd_export *exp,
 	int		    rc;
 	struct obd_import     *imp;
 
-	LASSERT(exp != NULL);
+	LASSERT(exp);
 
 	imp = class_exp2cliimp(exp);
 	req = ptlrpc_request_alloc_pack(imp, &RQF_FLD_QUERY, LUSTRE_MDS_VERSION,
 					FLD_QUERY);
-	if (req == NULL)
+	if (!req)
 		return -ENOMEM;
 
 	op = req_capsule_client_get(&req->rq_pill, &RMF_FLD_OPC);
@@ -436,7 +434,7 @@ int fld_client_rpc(struct obd_export *exp,
 		goto out_req;
 
 	prange = req_capsule_server_get(&req->rq_pill, &RMF_FLD_MDFLD);
-	if (prange == NULL) {
+	if (!prange) {
 		rc = -EFAULT;
 		goto out_req;
 	}
@@ -463,7 +461,7 @@ int fld_client_lookup(struct lu_client_fld *fld, u64 seq, u32 *mds,
 
 	/* Can not find it in the cache */
 	target = fld_client_get_target(fld, seq);
-	LASSERT(target != NULL);
+	LASSERT(target);
 
 	CDEBUG(D_INFO, "%s: Lookup fld entry (seq: %#llx) on target %s (idx %llu)\n",
 			fld->lcf_name, seq, fld_target_name(target), target->ft_idx);
diff --git a/drivers/staging/lustre/lustre/fld/lproc_fld.c b/drivers/staging/lustre/lustre/fld/lproc_fld.c
index 41ceaa8..da31281 100644
--- a/drivers/staging/lustre/lustre/fld/lproc_fld.c
+++ b/drivers/staging/lustre/lustre/fld/lproc_fld.c
@@ -60,8 +60,6 @@ fld_debugfs_targets_seq_show(struct seq_file *m, void *unused)
 	struct lu_client_fld *fld = (struct lu_client_fld *)m->private;
 	struct lu_fld_target *target;
 
-	LASSERT(fld != NULL);
-
 	spin_lock(&fld->lcf_lock);
 	list_for_each_entry(target,
 				&fld->lcf_targets, ft_chain)
@@ -76,8 +74,6 @@ fld_debugfs_hash_seq_show(struct seq_file *m, void *unused)
 {
 	struct lu_client_fld *fld = (struct lu_client_fld *)m->private;
 
-	LASSERT(fld != NULL);
-
 	spin_lock(&fld->lcf_lock);
 	seq_printf(m, "%s\n", fld->lcf_hash->fh_name);
 	spin_unlock(&fld->lcf_lock);
@@ -102,9 +98,8 @@ fld_debugfs_hash_seq_write(struct file *file,
 		return -EFAULT;
 
 	fld = ((struct seq_file *)file->private_data)->private;
-	LASSERT(fld != NULL);
 
-	for (i = 0; fld_hash[i].fh_name != NULL; i++) {
+	for (i = 0; fld_hash[i].fh_name; i++) {
 		if (count != strlen(fld_hash[i].fh_name))
 			continue;
 
@@ -114,7 +109,7 @@ fld_debugfs_hash_seq_write(struct file *file,
 		}
 	}
 
-	if (hash != NULL) {
+	if (hash) {
 		spin_lock(&fld->lcf_lock);
 		fld->lcf_hash = hash;
 		spin_unlock(&fld->lcf_lock);
@@ -132,8 +127,6 @@ fld_debugfs_cache_flush_write(struct file *file, const char __user *buffer,
 {
 	struct lu_client_fld *fld = file->private_data;
 
-	LASSERT(fld != NULL);
-
 	fld_cache_flush(fld->lcf_cache);
 
 	CDEBUG(D_INFO, "%s: Lookup cache is flushed\n", fld->lcf_name);
-- 
2.1.0
