Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 2A605C05027
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:12:02 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15KG5Gq5z21BS;
	Mon, 23 Jan 2023 15:04:50 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15K73jjHz1yCj
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:04:43 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 5ABFD9EA;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 5862358987; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:30 -0500
Message-Id: <1674514855-15399-18-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 17/42] lustre: misc: rename lprocfs_stats
 functions
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andreas Dilger <adilger@whamcloud.com>

Rename lprocfs_{alloc,register,clear,free}_stats() to be
lprocfs_stats_*() so these functions can be found more easily
in relation to struct lprocfs_stats.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16231
Lustre-commit: 6293a8723d850d72e ("LU-16231 misc: rename lprocfs_stats functions")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48847
Reviewed-by: Ellis Wilson <elliswilson@microsoft.com>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lprocfs_status.h  |  6 +++---
 fs/lustre/ldlm/ldlm_pool.c          |  4 ++--
 fs/lustre/ldlm/ldlm_resource.c      |  4 ++--
 fs/lustre/llite/lproc_llite.c       | 14 +++++++-------
 fs/lustre/obdclass/lprocfs_status.c | 22 +++++++++++-----------
 fs/lustre/obdclass/lu_object.c      |  5 +++--
 fs/lustre/ptlrpc/lproc_ptlrpc.c     |  6 +++---
 7 files changed, 31 insertions(+), 30 deletions(-)

diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index ef923ae4ca37..c7a6dd71a931 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -439,9 +439,9 @@ u64 lprocfs_stats_collector(struct lprocfs_stats *stats, int idx,
 			    enum lprocfs_fields_flags field);
 
 extern struct lprocfs_stats *
-lprocfs_alloc_stats(unsigned int num, enum lprocfs_stats_flags flags);
-void lprocfs_clear_stats(struct lprocfs_stats *stats);
-void lprocfs_free_stats(struct lprocfs_stats **stats);
+lprocfs_stats_alloc(unsigned int num, enum lprocfs_stats_flags flags);
+void lprocfs_stats_clear(struct lprocfs_stats *stats);
+void lprocfs_stats_free(struct lprocfs_stats **stats);
 int ldebugfs_alloc_md_stats(struct obd_device *obd,
 			    unsigned int num_private_stats);
 void ldebugfs_free_md_stats(struct obd_device *obd);
diff --git a/fs/lustre/ldlm/ldlm_pool.c b/fs/lustre/ldlm/ldlm_pool.c
index 8c6491d97f73..f0e629c5dd24 100644
--- a/fs/lustre/ldlm/ldlm_pool.c
+++ b/fs/lustre/ldlm/ldlm_pool.c
@@ -597,7 +597,7 @@ static int ldlm_pool_debugfs_init(struct ldlm_pool *pl)
 	ldlm_add_var(&pool_vars[0], pl->pl_debugfs_entry, "state", pl,
 		     &lprocfs_pool_state_fops);
 
-	pl->pl_stats = lprocfs_alloc_stats(LDLM_POOL_LAST_STAT -
+	pl->pl_stats = lprocfs_stats_alloc(LDLM_POOL_LAST_STAT -
 					   LDLM_POOL_FIRST_STAT, 0);
 	if (!pl->pl_stats) {
 		rc = -ENOMEM;
@@ -652,7 +652,7 @@ static void ldlm_pool_sysfs_fini(struct ldlm_pool *pl)
 static void ldlm_pool_debugfs_fini(struct ldlm_pool *pl)
 {
 	if (pl->pl_stats) {
-		lprocfs_free_stats(&pl->pl_stats);
+		lprocfs_stats_free(&pl->pl_stats);
 		pl->pl_stats = NULL;
 	}
 	debugfs_remove_recursive(pl->pl_debugfs_entry);
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index 866f31dfdfa2..98c3e4fb4466 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -430,7 +430,7 @@ static void ldlm_namespace_debugfs_unregister(struct ldlm_namespace *ns)
 	debugfs_remove_recursive(ns->ns_debugfs_entry);
 
 	if (ns->ns_stats)
-		lprocfs_free_stats(&ns->ns_stats);
+		lprocfs_stats_free(&ns->ns_stats);
 }
 
 static void ldlm_namespace_sysfs_unregister(struct ldlm_namespace *ns)
@@ -448,7 +448,7 @@ static int ldlm_namespace_sysfs_register(struct ldlm_namespace *ns)
 	err = kobject_init_and_add(&ns->ns_kobj, &ldlm_ns_ktype, NULL,
 				   "%s", ldlm_ns_name(ns));
 
-	ns->ns_stats = lprocfs_alloc_stats(LDLM_NSS_LAST, 0);
+	ns->ns_stats = lprocfs_stats_alloc(LDLM_NSS_LAST, 0);
 	if (!ns->ns_stats) {
 		kobject_put(&ns->ns_kobj);
 		return -ENOMEM;
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 7157886c31cc..c4a514aa1e4f 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -680,7 +680,7 @@ static ssize_t ll_wr_track_id(struct kobject *kobj, const char *buffer,
 		sbi->ll_stats_track_type = STATS_TRACK_ALL;
 	else
 		sbi->ll_stats_track_type = type;
-	lprocfs_clear_stats(sbi->ll_stats);
+	lprocfs_stats_clear(sbi->ll_stats);
 	return count;
 }
 
@@ -1885,7 +1885,7 @@ int ll_debugfs_register_super(struct super_block *sb, const char *name)
 			    &ll_rw_offset_stats_fops);
 
 	/* File operations stats */
-	sbi->ll_stats = lprocfs_alloc_stats(LPROC_LL_FILE_OPCODES,
+	sbi->ll_stats = lprocfs_stats_alloc(LPROC_LL_FILE_OPCODES,
 					    LPROCFS_STATS_FLAG_NONE);
 	if (!sbi->ll_stats) {
 		err = -ENOMEM;
@@ -1902,7 +1902,7 @@ int ll_debugfs_register_super(struct super_block *sb, const char *name)
 	debugfs_create_file("stats", 0644, sbi->ll_debugfs_entry, sbi->ll_stats,
 			    &lprocfs_stats_seq_fops);
 
-	sbi->ll_ra_stats = lprocfs_alloc_stats(ARRAY_SIZE(ra_stat_string),
+	sbi->ll_ra_stats = lprocfs_stats_alloc(ARRAY_SIZE(ra_stat_string),
 					       LPROCFS_STATS_FLAG_NONE);
 	if (!sbi->ll_ra_stats) {
 		err = -ENOMEM;
@@ -1933,9 +1933,9 @@ int ll_debugfs_register_super(struct super_block *sb, const char *name)
 	return 0;
 
 out_ra_stats:
-	lprocfs_free_stats(&sbi->ll_ra_stats);
+	lprocfs_stats_free(&sbi->ll_ra_stats);
 out_stats:
-	lprocfs_free_stats(&sbi->ll_stats);
+	lprocfs_stats_free(&sbi->ll_stats);
 out_debugfs:
 	debugfs_remove_recursive(sbi->ll_debugfs_entry);
 
@@ -1962,8 +1962,8 @@ void ll_debugfs_unregister_super(struct super_block *sb)
 	kset_unregister(&sbi->ll_kset);
 	wait_for_completion(&sbi->ll_kobj_unregister);
 
-	lprocfs_free_stats(&sbi->ll_ra_stats);
-	lprocfs_free_stats(&sbi->ll_stats);
+	lprocfs_stats_free(&sbi->ll_ra_stats);
+	lprocfs_stats_free(&sbi->ll_stats);
 }
 
 static void ll_display_extents_info(struct ll_rw_extents_info *rw_extents,
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 5e4ad7c227b1..0d669f4dde15 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -1205,7 +1205,7 @@ int lprocfs_stats_alloc_one(struct lprocfs_stats *stats, unsigned int cpuid)
 	return rc;
 }
 
-struct lprocfs_stats *lprocfs_alloc_stats(unsigned int num,
+struct lprocfs_stats *lprocfs_stats_alloc(unsigned int num,
 					  enum lprocfs_stats_flags flags)
 {
 	struct lprocfs_stats *stats;
@@ -1259,12 +1259,12 @@ struct lprocfs_stats *lprocfs_alloc_stats(unsigned int num,
 	return stats;
 
 fail:
-	lprocfs_free_stats(&stats);
+	lprocfs_stats_free(&stats);
 	return NULL;
 }
-EXPORT_SYMBOL(lprocfs_alloc_stats);
+EXPORT_SYMBOL(lprocfs_stats_alloc);
 
-void lprocfs_free_stats(struct lprocfs_stats **statsh)
+void lprocfs_stats_free(struct lprocfs_stats **statsh)
 {
 	struct lprocfs_stats *stats = *statsh;
 	unsigned int num_entry;
@@ -1286,7 +1286,7 @@ void lprocfs_free_stats(struct lprocfs_stats **statsh)
 	kvfree(stats->ls_cnt_header);
 	kvfree(stats);
 }
-EXPORT_SYMBOL(lprocfs_free_stats);
+EXPORT_SYMBOL(lprocfs_stats_free);
 
 u64 lprocfs_stats_collector(struct lprocfs_stats *stats, int idx,
 			      enum lprocfs_fields_flags field)
@@ -1312,12 +1312,12 @@ u64 lprocfs_stats_collector(struct lprocfs_stats *stats, int idx,
 }
 EXPORT_SYMBOL(lprocfs_stats_collector);
 
-void lprocfs_clear_stats(struct lprocfs_stats *stats)
+void lprocfs_stats_clear(struct lprocfs_stats *stats)
 {
 	struct lprocfs_counter *percpu_cntr;
-	int i, j;
 	unsigned int num_entry;
 	unsigned long flags = 0;
+	int i, j;
 
 	num_entry = lprocfs_stats_lock(stats, LPROCFS_GET_NUM_CPU, &flags);
 
@@ -1347,7 +1347,7 @@ void lprocfs_clear_stats(struct lprocfs_stats *stats)
 
 	lprocfs_stats_unlock(stats, LPROCFS_GET_NUM_CPU, &flags);
 }
-EXPORT_SYMBOL(lprocfs_clear_stats);
+EXPORT_SYMBOL(lprocfs_stats_clear);
 
 static ssize_t lprocfs_stats_seq_write(struct file *file,
 				       const char __user *buf,
@@ -1356,7 +1356,7 @@ static ssize_t lprocfs_stats_seq_write(struct file *file,
 	struct seq_file *seq = file->private_data;
 	struct lprocfs_stats *stats = seq->private;
 
-	lprocfs_clear_stats(stats);
+	lprocfs_stats_clear(stats);
 
 	return len;
 }
@@ -1601,7 +1601,7 @@ int ldebugfs_alloc_md_stats(struct obd_device *obd,
 		return -EINVAL;
 
 	num_stats = ARRAY_SIZE(mps_stats) + num_private_stats;
-	stats = lprocfs_alloc_stats(num_stats, 0);
+	stats = lprocfs_stats_alloc(num_stats, 0);
 	if (!stats)
 		return -ENOMEM;
 
@@ -1630,7 +1630,7 @@ void ldebugfs_free_md_stats(struct obd_device *obd)
 		return;
 
 	obd->obd_md_stats = NULL;
-	lprocfs_free_stats(&stats);
+	lprocfs_stats_free(&stats);
 }
 EXPORT_SYMBOL(ldebugfs_free_md_stats);
 
diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index 7ecd0c4faee7..468dd43b6151 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -1091,7 +1091,7 @@ int lu_site_init(struct lu_site *s, struct lu_device *top)
 		init_waitqueue_head(&bkt->lsb_waitq);
 	}
 
-	s->ls_stats = lprocfs_alloc_stats(LU_SS_LAST_STAT, 0);
+	s->ls_stats = lprocfs_stats_alloc(LU_SS_LAST_STAT, 0);
 	if (!s->ls_stats) {
 		kvfree(s->ls_bkts);
 		s->ls_bkts = NULL;
@@ -1147,7 +1147,7 @@ void lu_site_fini(struct lu_site *s)
 	}
 
 	if (s->ls_stats)
-		lprocfs_free_stats(&s->ls_stats);
+		lprocfs_stats_free(&s->ls_stats);
 }
 EXPORT_SYMBOL(lu_site_fini);
 
@@ -1163,6 +1163,7 @@ int lu_site_init_finish(struct lu_site *s)
 	if (result == 0)
 		list_add(&s->ls_linkage, &lu_sites);
 	up_write(&lu_sites_guard);
+
 	return result;
 }
 EXPORT_SYMBOL(lu_site_init_finish);
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index 603259dcd3eb..e0b85bd9f74e 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -198,7 +198,7 @@ ptlrpc_ldebugfs_register(struct dentry *root, char *dir,
 	LASSERT(!*debugfs_root_ret);
 	LASSERT(!*stats_ret);
 
-	svc_stats = lprocfs_alloc_stats(EXTRA_MAX_OPCODES + LUSTRE_MAX_OPCODES,
+	svc_stats = lprocfs_stats_alloc(EXTRA_MAX_OPCODES + LUSTRE_MAX_OPCODES,
 					0);
 	if (!svc_stats)
 		return;
@@ -1257,7 +1257,7 @@ void ptlrpc_lprocfs_unregister_service(struct ptlrpc_service *svc)
 	debugfs_remove_recursive(svc->srv_debugfs_entry);
 
 	if (svc->srv_stats)
-		lprocfs_free_stats(&svc->srv_stats);
+		lprocfs_stats_free(&svc->srv_stats);
 }
 
 void ptlrpc_lprocfs_unregister_obd(struct obd_device *obd)
@@ -1269,7 +1269,7 @@ void ptlrpc_lprocfs_unregister_obd(struct obd_device *obd)
 	debugfs_remove_recursive(obd->obd_svc_debugfs_entry);
 
 	if (obd->obd_svc_stats)
-		lprocfs_free_stats(&obd->obd_svc_stats);
+		lprocfs_stats_free(&obd->obd_svc_stats);
 }
 EXPORT_SYMBOL(ptlrpc_lprocfs_unregister_obd);
 
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
