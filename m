Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D053C433B4
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:59 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id EEE9761396
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EEE9761396
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C508021F8A2;
	Mon,  5 Apr 2021 00:52:25 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4E2F221F8B5
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:27 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 1B1C6E3F;
 Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1837F90AAE; Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:51:02 -0400
Message-Id: <1617583870-32029-34-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 33/41] lustre: convert snprintf to scnprintf
 as appropriate
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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

From: Mr NeilBrown <neilb@suse.de>

The return value of snprintf() is the number of bytes that would have
been copies into the buffer if it was large enough.
Many places in the code use it as though it were the number of bytes
actually copied.  In practice this (almost?) never makes a difference.
However it is poor style to use the wrong interfaces as it might one
day be copied to somewhere that it does make a difference.

So change these instances of snprintf to scnprintf which DOES return
the number of bytes actually copied.
This is all places where the return value is simply returned to the
call, and a couple of others.

Also change the declared buffer size in a couple of places to the
actual buffer size (PAGE_SIZE in these cases).

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: a03765b2da70fb92 ("LU-6142 lustre: convert snprintf to scnprintf as appropriate")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39744
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/lproc_llite.c  | 30 +++++++++++++++---------------
 fs/lustre/llite/pcc.c          | 38 +++++++++++++++++++-------------------
 fs/lustre/obdclass/obd_sysfs.c |  6 +++---
 3 files changed, 37 insertions(+), 37 deletions(-)

diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index a2e61e1..ec241a4 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -726,7 +726,7 @@ static ssize_t statahead_running_max_show(struct kobject *kobj,
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
 
-	return snprintf(buf, 16, "%u\n", sbi->ll_sa_running_max);
+	return scnprintf(buf, 16, "%u\n", sbi->ll_sa_running_max);
 }
 
 static ssize_t statahead_running_max_store(struct kobject *kobj,
@@ -882,7 +882,7 @@ static ssize_t statfs_max_age_show(struct kobject *kobj, struct attribute *attr,
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
 
-	return snprintf(buf, PAGE_SIZE, "%u\n", sbi->ll_statfs_max_age);
+	return scnprintf(buf, PAGE_SIZE, "%u\n", sbi->ll_statfs_max_age);
 }
 
 static ssize_t statfs_max_age_store(struct kobject *kobj,
@@ -920,8 +920,8 @@ static ssize_t max_easize_show(struct kobject *kobj,
 		return rc;
 
 	/* Limit xattr size returned to userspace based on kernel maximum */
-	return snprintf(buf, PAGE_SIZE, "%u\n",
-			ealen > XATTR_SIZE_MAX ? XATTR_SIZE_MAX : ealen);
+	return scnprintf(buf, PAGE_SIZE, "%u\n",
+			 ealen > XATTR_SIZE_MAX ? XATTR_SIZE_MAX : ealen);
 }
 LUSTRE_RO_ATTR(max_easize);
 
@@ -951,8 +951,8 @@ static ssize_t default_easize_show(struct kobject *kobj,
 		return rc;
 
 	/* Limit xattr size returned to userspace based on kernel maximum */
-	return snprintf(buf, PAGE_SIZE, "%u\n",
-			ealen > XATTR_SIZE_MAX ? XATTR_SIZE_MAX : ealen);
+	return scnprintf(buf, PAGE_SIZE, "%u\n",
+			 ealen > XATTR_SIZE_MAX ? XATTR_SIZE_MAX : ealen);
 }
 
 /**
@@ -1094,8 +1094,8 @@ static ssize_t max_read_ahead_async_active_show(struct kobject *kobj,
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
 
-	return snprintf(buf, PAGE_SIZE, "%u\n",
-			sbi->ll_ra_info.ra_async_max_active);
+	return scnprintf(buf, PAGE_SIZE, "%u\n",
+			 sbi->ll_ra_info.ra_async_max_active);
 }
 
 static ssize_t max_read_ahead_async_active_store(struct kobject *kobj,
@@ -1139,8 +1139,8 @@ static ssize_t read_ahead_async_file_threshold_mb_show(struct kobject *kobj,
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
 
-	return snprintf(buf, PAGE_SIZE, "%lu\n",
-	     PAGES_TO_MiB(sbi->ll_ra_info.ra_async_pages_per_file_threshold));
+	return scnprintf(buf, PAGE_SIZE, "%lu\n",
+			 PAGES_TO_MiB(sbi->ll_ra_info.ra_async_pages_per_file_threshold));
 }
 
 static ssize_t
@@ -1260,8 +1260,8 @@ static ssize_t file_heat_show(struct kobject *kobj,
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
 
-	return snprintf(buf, PAGE_SIZE, "%u\n",
-			!!(sbi->ll_flags & LL_SBI_FILE_HEAT));
+	return scnprintf(buf, PAGE_SIZE, "%u\n",
+			 !!(sbi->ll_flags & LL_SBI_FILE_HEAT));
 }
 
 static ssize_t file_heat_store(struct kobject *kobj,
@@ -1296,8 +1296,8 @@ static ssize_t heat_decay_percentage_show(struct kobject *kobj,
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
 
-	return snprintf(buf, PAGE_SIZE, "%u\n",
-		       (sbi->ll_heat_decay_weight * 100 + 128) / 256);
+	return scnprintf(buf, PAGE_SIZE, "%u\n",
+			 (sbi->ll_heat_decay_weight * 100 + 128) / 256);
 }
 
 static ssize_t heat_decay_percentage_store(struct kobject *kobj,
@@ -1330,7 +1330,7 @@ static ssize_t heat_period_second_show(struct kobject *kobj,
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
 
-	return snprintf(buf, PAGE_SIZE, "%u\n", sbi->ll_heat_period_second);
+	return scnprintf(buf, PAGE_SIZE, "%u\n", sbi->ll_heat_period_second);
 }
 
 static ssize_t heat_period_second_store(struct kobject *kobj,
diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index 28ca9cb..297189c9 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -1088,15 +1088,15 @@ void pcc_inode_free(struct inode *inode)
 #define MAX_PCC_DATABASE_PATH (6 * 5 + FID_NOBRACE_LEN + 1)
 static int pcc_fid2dataset_path(char *buf, int sz, struct lu_fid *fid)
 {
-	return snprintf(buf, sz, "%04x/%04x/%04x/%04x/%04x/%04x/"
-			DFID_NOBRACE,
-			(fid)->f_oid       & 0xFFFF,
-			(fid)->f_oid >> 16 & 0xFFFF,
-			(unsigned int)((fid)->f_seq       & 0xFFFF),
-			(unsigned int)((fid)->f_seq >> 16 & 0xFFFF),
-			(unsigned int)((fid)->f_seq >> 32 & 0xFFFF),
-			(unsigned int)((fid)->f_seq >> 48 & 0xFFFF),
-			PFID(fid));
+	return scnprintf(buf, sz, "%04x/%04x/%04x/%04x/%04x/%04x/"
+			 DFID_NOBRACE,
+			 (fid)->f_oid       & 0xFFFF,
+			 (fid)->f_oid >> 16 & 0xFFFF,
+			 (unsigned int)((fid)->f_seq       & 0xFFFF),
+			 (unsigned int)((fid)->f_seq >> 16 & 0xFFFF),
+			 (unsigned int)((fid)->f_seq >> 32 & 0xFFFF),
+			 (unsigned int)((fid)->f_seq >> 48 & 0xFFFF),
+			 PFID(fid));
 }
 
 static inline const struct cred *pcc_super_cred(struct super_block *sb)
@@ -1163,16 +1163,16 @@ static int pcc_get_layout_info(struct inode *inode, struct cl_layout *clt)
 static int pcc_fid2dataset_fullpath(char *buf, int sz, struct lu_fid *fid,
 				    struct pcc_dataset *dataset)
 {
-	return snprintf(buf, sz, "%s/%04x/%04x/%04x/%04x/%04x/%04x/"
-			DFID_NOBRACE,
-			dataset->pccd_pathname,
-			(fid)->f_oid       & 0xFFFF,
-			(fid)->f_oid >> 16 & 0xFFFF,
-			(unsigned int)((fid)->f_seq       & 0xFFFF),
-			(unsigned int)((fid)->f_seq >> 16 & 0xFFFF),
-			(unsigned int)((fid)->f_seq >> 32 & 0xFFFF),
-			(unsigned int)((fid)->f_seq >> 48 & 0xFFFF),
-			PFID(fid));
+	return scnprintf(buf, sz, "%s/%04x/%04x/%04x/%04x/%04x/%04x/"
+			 DFID_NOBRACE,
+			 dataset->pccd_pathname,
+			 (fid)->f_oid       & 0xFFFF,
+			 (fid)->f_oid >> 16 & 0xFFFF,
+			 (unsigned int)((fid)->f_seq       & 0xFFFF),
+			 (unsigned int)((fid)->f_seq >> 16 & 0xFFFF),
+			 (unsigned int)((fid)->f_seq >> 32 & 0xFFFF),
+			 (unsigned int)((fid)->f_seq >> 48 & 0xFFFF),
+			 PFID(fid));
 }
 
 /* Must be called with pcci->pcci_lock held */
diff --git a/fs/lustre/obdclass/obd_sysfs.c b/fs/lustre/obdclass/obd_sysfs.c
index 5fc638f..e6fb1b9 100644
--- a/fs/lustre/obdclass/obd_sysfs.c
+++ b/fs/lustre/obdclass/obd_sysfs.c
@@ -218,7 +218,7 @@ static ssize_t pinger_show(struct kobject *kobj, struct attribute *attr,
 static ssize_t jobid_var_show(struct kobject *kobj, struct attribute *attr,
 			      char *buf)
 {
-	return snprintf(buf, PAGE_SIZE, "%s\n", obd_jobid_var);
+	return scnprintf(buf, PAGE_SIZE, "%s\n", obd_jobid_var);
 }
 
 static ssize_t jobid_var_store(struct kobject *kobj, struct attribute *attr,
@@ -252,7 +252,7 @@ static ssize_t jobid_var_store(struct kobject *kobj, struct attribute *attr,
 static ssize_t jobid_name_show(struct kobject *kobj, struct attribute *attr,
 			       char *buf)
 {
-	return snprintf(buf, PAGE_SIZE, "%s\n", obd_jobid_name);
+	return scnprintf(buf, PAGE_SIZE, "%s\n", obd_jobid_name);
 }
 
 static ssize_t jobid_name_store(struct kobject *kobj, struct attribute *attr,
@@ -283,7 +283,7 @@ static ssize_t jobid_this_session_show(struct kobject *kobj,
 	rcu_read_lock();
 	jid = jobid_current();
 	if (jid)
-		ret = snprintf(buf, PAGE_SIZE, "%s\n", jid);
+		ret = scnprintf(buf, PAGE_SIZE, "%s\n", jid);
 	rcu_read_unlock();
 	return ret;
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
