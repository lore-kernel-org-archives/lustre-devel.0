Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86CE7C77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:43:41 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWWc5vRFz22cC;
	Sun,  9 Apr 2023 05:24:44 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWWV14nWz216X
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:24:38 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 727111008494;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 712C02AB; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:13:18 -0400
Message-Id: <1681042400-15491-39-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 38/40] lustre: enc: file names encryption
 when using secure boot
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
Cc: Alex Deiter <alex.deiter@gmail.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alex Deiter <alex.deiter@gmail.com>

Secure boot activates lockdown mode in the Linux kernel.
And debugfs is restricted when the kernel is locked down.
This patch moves file names encryption from debugfs to sysfs.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16621
Lustre-commit: 716675fff642655c4 ("LU-16621 enc: file names encryption when using secure boot")
Signed-off-by: Alex Deiter <alex.deiter@gmail.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50219
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: jsimmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h |  1 +
 fs/lustre/llite/llite_lib.c      |  5 +++--
 fs/lustre/llite/lproc_llite.c    | 35 ++++++++++++++++++-----------------
 3 files changed, 22 insertions(+), 19 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index b101a71..72de8f7 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -737,6 +737,7 @@ struct ll_sb_info {
 	spinlock_t		ll_lock;
 	spinlock_t		ll_pp_extent_lock; /* pp_extent entry*/
 	spinlock_t		ll_process_lock; /* ll_rw_process_info */
+	struct lustre_sb_info	*lsi;
 	struct obd_uuid		ll_sb_uuid;
 	struct obd_export	*ll_md_exp;
 	struct obd_export	*ll_dt_exp;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 3774ca8..5a9bc61 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -79,7 +79,7 @@ static inline unsigned int ll_get_ra_async_max_active(void)
 	return cfs_cpt_weight(cfs_cpt_tab, CFS_CPT_ANY) >> 1;
 }
 
-static struct ll_sb_info *ll_init_sbi(void)
+static struct ll_sb_info *ll_init_sbi(struct lustre_sb_info *lsi)
 {
 	struct ll_sb_info *sbi = NULL;
 	unsigned long pages;
@@ -99,6 +99,7 @@ static struct ll_sb_info *ll_init_sbi(void)
 	mutex_init(&sbi->ll_lco.lco_lock);
 	spin_lock_init(&sbi->ll_pp_extent_lock);
 	spin_lock_init(&sbi->ll_process_lock);
+	sbi->lsi = lsi;
 	sbi->ll_rw_stats_on = 0;
 	sbi->ll_statfs_max_age = OBD_STATFS_CACHE_SECONDS;
 
@@ -1245,7 +1246,7 @@ int ll_fill_super(struct super_block *sb)
 	}
 
 	/* client additional sb info */
-	sbi = ll_init_sbi();
+	sbi = ll_init_sbi(lsi);
 	lsi->lsi_llsbi = sbi;
 	if (IS_ERR(sbi)) {
 		err = PTR_ERR(sbi);
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 48d93c6..8b6c86f 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1653,28 +1653,30 @@ static ssize_t ll_nosquash_nids_seq_write(struct file *file,
 
 LDEBUGFS_SEQ_FOPS(ll_nosquash_nids);
 
-static int ll_old_b64_enc_seq_show(struct seq_file *m, void *v)
+static ssize_t filename_enc_use_old_base64_show(struct kobject *kobj,
+						struct attribute *attr,
+						char *buffer)
 {
-	struct super_block *sb = m->private;
-	struct lustre_sb_info *lsi = s2lsi(sb);
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+	struct lustre_sb_info *lsi = sbi->lsi;
 
-	seq_printf(m, "%u\n",
-		   lsi->lsi_flags & LSI_FILENAME_ENC_B64_OLD_CLI ? 1 : 0);
-	return 0;
+	return scnprintf(buffer, PAGE_SIZE, "%u\n",
+			 lsi->lsi_flags & LSI_FILENAME_ENC_B64_OLD_CLI ? 1 : 0);
 }
 
-static ssize_t ll_old_b64_enc_seq_write(struct file *file,
-					const char __user *buffer,
-					size_t count, loff_t *off)
+static ssize_t filename_enc_use_old_base64_store(struct kobject *kobj,
+						 struct attribute *attr,
+						 const char *buffer,
+						 size_t count)
 {
-	struct seq_file *m = file->private_data;
-	struct super_block *sb = m->private;
-	struct lustre_sb_info *lsi = s2lsi(sb);
-	struct ll_sb_info *sbi = ll_s2sbi(sb);
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+	struct lustre_sb_info *lsi = sbi->lsi;
 	bool val;
 	int rc;
 
-	rc = kstrtobool_from_user(buffer, count, &val);
+	rc = kstrtobool(buffer, &val);
 	if (rc)
 		return rc;
 
@@ -1698,7 +1700,7 @@ static ssize_t ll_old_b64_enc_seq_write(struct file *file,
 	return count;
 }
 
-LDEBUGFS_SEQ_FOPS(ll_old_b64_enc);
+LUSTRE_RW_ATTR(filename_enc_use_old_base64);
 
 static int ll_pcc_seq_show(struct seq_file *m, void *v)
 {
@@ -1756,8 +1758,6 @@ struct ldebugfs_vars lprocfs_llite_obd_vars[] = {
 	  .fops =	&ll_nosquash_nids_fops			},
 	{ .name =	"pcc",
 	  .fops =	&ll_pcc_fops,				},
-	{ .name =	"filename_enc_use_old_base64",
-	  .fops =	&ll_old_b64_enc_fops,			},
 	{ NULL }
 };
 
@@ -1805,6 +1805,7 @@ struct ldebugfs_vars lprocfs_llite_obd_vars[] = {
 	&lustre_attr_opencache_threshold_ms.attr,
 	&lustre_attr_opencache_max_ms.attr,
 	&lustre_attr_inode_cache.attr,
+	&lustre_attr_filename_enc_use_old_base64.attr,
 	NULL,
 };
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
