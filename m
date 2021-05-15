Return-Path: <SRS0=EXfh=KK=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50D5EC433ED
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:31 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 1295861355
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1295861355
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CAC5121FA9D;
	Sat, 15 May 2021 06:06:22 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1A8D621E068
 for <lustre-devel@lists.lustre.org>; Sat, 15 May 2021 06:06:17 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 9694E1006EA1;
 Sat, 15 May 2021 09:06:12 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 948BA98158; Sat, 15 May 2021 09:06:12 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sat, 15 May 2021 09:06:10 -0400
Message-Id: <1621083970-32463-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1621083970-32463-1-git-send-email-jsimmons@infradead.org>
References: <1621083970-32463-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/13] lustre: llite: Introduce inode open
 heat counter
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

From: Oleg Drokin <green@whamcloud.com>

Initial framework to support detection of naive apps that
assume open-closes are "free" and proceed to open/close
same files between minute operations.

We will track number of file opens per inode and last time inode
was closed.

Initially we'll expose these controls:
llite/opencache_threshold_count - enables functionality and controls after how
                                  many opens open lock is requested
llite/opencache_threshold_ms    - if any reopen happens within this time (in
                                  ms), the open would trigger open lock request
llite/opencache_max_ms          - If last close was longer than this many ms
                                  ago - start counting opens from zero again

Once enough useful data is collected we can look into adding a heatmap
or another similar mechanism to better manage it and enable it
by default with sensible settings.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10948
Lustre-commit: 41d99c4902836b726 ("LU-10948 llite: Introduce inode open heat counter")
Signed-off-by: Oleg Drokin <green@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32158
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c           |  70 ++++++++++++++++++++----
 fs/lustre/llite/llite_internal.h |  32 +++++++++--
 fs/lustre/llite/llite_lib.c      |   5 ++
 fs/lustre/llite/lproc_llite.c    | 112 +++++++++++++++++++++++++++++++++++++--
 fs/lustre/llite/namei.c          |   7 +++
 5 files changed, 210 insertions(+), 16 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index ffddec6..26aa7be 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -43,6 +43,7 @@
 #include <linux/sched.h>
 #include <linux/mount.h>
 #include <linux/falloc.h>
+#include <linux/ktime.h>
 
 #include <uapi/linux/lustre/lustre_fiemap.h>
 #include <uapi/linux/lustre/lustre_ioctl.h>
@@ -414,6 +415,8 @@ int ll_file_release(struct inode *inode, struct file *file)
 		lli->lli_async_rc = 0;
 	}
 
+	lli->lli_close_fd_time = ktime_get();
+
 	rc = ll_md_close(inode, file);
 
 	if (CFS_FAIL_TIMEOUT_MS(OBD_FAIL_PTLRPC_DUMP_LOG, cfs_fail_val))
@@ -745,6 +748,29 @@ static int ll_local_open(struct file *file, struct lookup_intent *it,
 	return 0;
 }
 
+void ll_track_file_opens(struct inode *inode)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+
+	/* do not skew results with delays from never-opened inodes */
+	if (ktime_to_ns(lli->lli_close_fd_time))
+		ll_stats_ops_tally(sbi, LPROC_LL_INODE_OPCLTM,
+			   ktime_us_delta(ktime_get(), lli->lli_close_fd_time));
+
+	if (ktime_after(ktime_get(),
+			ktime_add_ms(lli->lli_close_fd_time,
+				     sbi->ll_oc_max_ms))) {
+		lli->lli_open_fd_count = 1;
+		lli->lli_close_fd_time = ns_to_ktime(0);
+	} else {
+		lli->lli_open_fd_count++;
+	}
+
+	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_INODE_OCOUNT,
+			   lli->lli_open_fd_count);
+}
+
 /* Open a file, and (for the very first open) create objects on the OSTs at
  * this time.  If opened with O_LOV_DELAY_CREATE, then we don't do the object
  * creation or open until ll_lov_setstripe() ioctl is called.
@@ -791,6 +817,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 	if (S_ISDIR(inode->i_mode))
 		ll_authorize_statahead(inode, fd);
 
+	ll_track_file_opens(inode);
 	if (is_root_inode(inode)) {
 		file->private_data = fd;
 		return 0;
@@ -868,6 +895,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 		LASSERT(*och_usecount == 0);
 		if (!it->it_disposition) {
 			struct dentry *dentry = file_dentry(file);
+			struct ll_sb_info *sbi = ll_i2sbi(inode);
 			struct ll_dentry_data *ldd;
 
 			/* We cannot just request lock handle now, new ELC code
@@ -884,20 +912,42 @@ int ll_file_open(struct inode *inode, struct file *file)
 			 *    handle to be returned from LOOKUP|OPEN request,
 			 *    for example if the target entry was a symlink.
 			 *
-			 * Only fetch MDS_OPEN_LOCK if this is in NFS path,
-			 * marked by a bit set in ll_iget_for_nfs. Clear the
-			 * bit so that it's not confusing later callers.
+			 * In NFS path we know there's pathologic behavior
+			 * so we always enable open lock caching when coming
+			 * from there. It's detected by setting a flag in
+			 * ll_iget_for_nfs.
 			 *
-			 * NB; when ldd is NULL, it must have come via normal
-			 * lookup path only, since ll_iget_for_nfs always calls
-			 * ll_d_init().
+			 * After reaching number of opens of this inode
+			 * we always ask for an open lock on it to handle
+			 * bad userspace actors that open and close files
+			 * in a loop for absolutely no good reason
 			 */
 			ldd = ll_d2d(dentry);
-			if (ldd && ldd->lld_nfs_dentry) {
+			if (filename_is_volatile(dentry->d_name.name,
+						 dentry->d_name.len,
+						 NULL)) {
+				/* There really is nothing here, but this
+				 * make this more readable I think.
+				 * We do not want openlock for volatile
+				 * files under any circumstances
+				 */
+			} else if (ldd && ldd->lld_nfs_dentry) {
+				/* NFS path. This also happens to catch
+				 * open by fh files I guess
+				 */
+				it->it_flags |= MDS_OPEN_LOCK;
+				/* clear the flag for future lookups */
 				ldd->lld_nfs_dentry = 0;
-				if (!filename_is_volatile(dentry->d_name.name,
-							  dentry->d_name.len,
-							  NULL))
+			} else if (sbi->ll_oc_thrsh_count > 0) {
+				/* Take MDS_OPEN_LOCK with many opens */
+				if (lli->lli_open_fd_count >=
+				    sbi->ll_oc_thrsh_count)
+					it->it_flags |= MDS_OPEN_LOCK;
+
+				/* If this is open after we just closed */
+				else if (ktime_before(ktime_get(),
+						      ktime_add_ms(lli->lli_close_fd_time,
+								   sbi->ll_oc_thrsh_ms)))
 					it->it_flags |= MDS_OPEN_LOCK;
 			}
 
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 03d2796..72aa564 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -137,9 +137,15 @@ struct ll_inode_info {
 	struct obd_client_handle       *lli_mds_read_och;
 	struct obd_client_handle       *lli_mds_write_och;
 	struct obd_client_handle       *lli_mds_exec_och;
-	u64			   lli_open_fd_read_count;
-	u64			   lli_open_fd_write_count;
-	u64			   lli_open_fd_exec_count;
+	u64				lli_open_fd_read_count;
+	u64				lli_open_fd_write_count;
+	u64				lli_open_fd_exec_count;
+
+	/* Number of times this inode was opened */
+	u64				lli_open_fd_count;
+	/* When last close was performed on this inode */
+	ktime_t				lli_close_fd_time;
+
 	/* Protects access to och pointers and their usage counters */
 	struct mutex			lli_och_mutex;
 
@@ -765,6 +771,19 @@ struct ll_sb_info {
 	unsigned int		ll_heat_decay_weight;
 	unsigned int		ll_heat_period_second;
 
+	/* Opens of the same inode before we start requesting open lock */
+	u32			  ll_oc_thrsh_count;
+
+	/* Time in ms between last inode close and next open to be considered
+	 * instant back to back and would trigger an open lock request
+	 */
+	u32			  ll_oc_thrsh_ms;
+
+	/* Time in ms after last file close that we no longer count prior
+	 * opens
+	 */
+	u32			  ll_oc_max_ms;
+
 	/* filesystem fsname */
 	char			ll_fsname[LUSTRE_MAXFSNAME + 1];
 
@@ -788,6 +807,10 @@ struct ll_sb_info {
 #define SBI_DEFAULT_HEAT_DECAY_WEIGHT	((80 * 256 + 50) / 100)
 #define SBI_DEFAULT_HEAT_PERIOD_SECOND	(60)
 
+#define SBI_DEFAULT_OPENCACHE_THRESHOLD_COUNT	(5)
+#define SBI_DEFAULT_OPENCACHE_THRESHOLD_MS	(100) /* 0.1 second */
+#define SBI_DEFAULT_OPENCACHE_THRESHOLD_MAX_MS	(60000) /* 1 minute */
+
 /*
  * per file-descriptor read-ahead data.
  */
@@ -1029,6 +1052,8 @@ enum {
 	LPROC_LL_REMOVEXATTR,
 	LPROC_LL_INODE_PERM,
 	LPROC_LL_FALLOCATE,
+	LPROC_LL_INODE_OCOUNT,
+	LPROC_LL_INODE_OPCLTM,
 	LPROC_LL_FILE_OPCODES
 };
 
@@ -1088,6 +1113,7 @@ enum ldlm_mode ll_take_md_lock(struct inode *inode, u64 bits,
 int ll_file_release(struct inode *inode, struct file *file);
 int ll_release_openhandle(struct inode *inode, struct lookup_intent *it);
 int ll_md_real_close(struct inode *inode, fmode_t fmode);
+void ll_track_file_opens(struct inode *inode);
 int ll_getattr(const struct path *path, struct kstat *stat,
 	       u32 request_mask, unsigned int flags);
 int ll_getattr_dentry(struct dentry *de, struct kstat *stat, u32 request_mask,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index ada2b625c..0c914c9 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -190,6 +190,11 @@ static struct ll_sb_info *ll_init_sbi(void)
 	/* Per-filesystem file heat */
 	sbi->ll_heat_decay_weight = SBI_DEFAULT_HEAT_DECAY_WEIGHT;
 	sbi->ll_heat_period_second = SBI_DEFAULT_HEAT_PERIOD_SECOND;
+
+	/* Per-fs open heat level before requesting open lock */
+	sbi->ll_oc_thrsh_count = SBI_DEFAULT_OPENCACHE_THRESHOLD_COUNT;
+	sbi->ll_oc_max_ms = SBI_DEFAULT_OPENCACHE_THRESHOLD_MAX_MS;
+	sbi->ll_oc_thrsh_ms = SBI_DEFAULT_OPENCACHE_THRESHOLD_MS;
 	return sbi;
 out_destroy_ra:
 	kfree(sbi->ll_foreign_symlink_upcall);
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 16d1497..cd8394c 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1369,6 +1369,105 @@ static ssize_t heat_period_second_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(heat_period_second);
 
+static ssize_t opencache_threshold_count_show(struct kobject *kobj,
+					      struct attribute *attr,
+					      char *buf)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+
+	if (sbi->ll_oc_thrsh_count)
+		return snprintf(buf, PAGE_SIZE, "%u\n",
+				sbi->ll_oc_thrsh_count);
+	else
+		return snprintf(buf, PAGE_SIZE, "off\n");
+}
+
+static ssize_t opencache_threshold_count_store(struct kobject *kobj,
+					       struct attribute *attr,
+					       const char *buffer,
+					       size_t count)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+	unsigned int val;
+	int rc;
+
+	rc = kstrtouint(buffer, 10, &val);
+	if (rc) {
+		bool enable;
+		/* also accept "off" to disable and "on" to always cache */
+		rc = kstrtobool(buffer, &enable);
+		if (rc)
+			return rc;
+		val = enable;
+	}
+	sbi->ll_oc_thrsh_count = val;
+
+	return count;
+}
+LUSTRE_RW_ATTR(opencache_threshold_count);
+
+static ssize_t opencache_threshold_ms_show(struct kobject *kobj,
+					   struct attribute *attr,
+					   char *buf)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+
+	return snprintf(buf, PAGE_SIZE, "%u\n", sbi->ll_oc_thrsh_ms);
+}
+
+static ssize_t opencache_threshold_ms_store(struct kobject *kobj,
+					    struct attribute *attr,
+					    const char *buffer,
+					    size_t count)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+	unsigned int val;
+	int rc;
+
+	rc = kstrtouint(buffer, 10, &val);
+	if (rc)
+		return rc;
+
+	sbi->ll_oc_thrsh_ms = val;
+
+	return count;
+}
+LUSTRE_RW_ATTR(opencache_threshold_ms);
+
+static ssize_t opencache_max_ms_show(struct kobject *kobj,
+				     struct attribute *attr,
+				     char *buf)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+
+	return snprintf(buf, PAGE_SIZE, "%u\n", sbi->ll_oc_max_ms);
+}
+
+static ssize_t opencache_max_ms_store(struct kobject *kobj,
+				      struct attribute *attr,
+				      const char *buffer,
+				      size_t count)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+	unsigned int val;
+	int rc;
+
+	rc = kstrtouint(buffer, 10, &val);
+	if (rc)
+		return rc;
+
+	sbi->ll_oc_max_ms = val;
+
+	return count;
+}
+LUSTRE_RW_ATTR(opencache_max_ms);
+
 static int ll_unstable_stats_seq_show(struct seq_file *m, void *v)
 {
 	struct super_block *sb = m->private;
@@ -1568,6 +1667,8 @@ struct ldebugfs_vars lprocfs_llite_obd_vars[] = {
 	&lustre_attr_max_read_ahead_mb.attr,
 	&lustre_attr_max_read_ahead_per_file_mb.attr,
 	&lustre_attr_max_read_ahead_whole_mb.attr,
+	&lustre_attr_max_read_ahead_async_active.attr,
+	&lustre_attr_read_ahead_async_file_threshold_mb.attr,
 	&lustre_attr_read_ahead_range_kb.attr,
 	&lustre_attr_checksums.attr,
 	&lustre_attr_checksum_pages.attr,
@@ -1587,8 +1688,9 @@ struct ldebugfs_vars lprocfs_llite_obd_vars[] = {
 	&lustre_attr_file_heat.attr,
 	&lustre_attr_heat_decay_percentage.attr,
 	&lustre_attr_heat_period_second.attr,
-	&lustre_attr_max_read_ahead_async_active.attr,
-	&lustre_attr_read_ahead_async_file_threshold_mb.attr,
+	&lustre_attr_opencache_threshold_count.attr,
+	&lustre_attr_opencache_threshold_ms.attr,
+	&lustre_attr_opencache_max_ms.attr,
 	NULL,
 };
 
@@ -1624,12 +1726,16 @@ static void sbi_kobj_release(struct kobject *kobj)
 	{ LPROC_LL_LLSEEK,	LPROCFS_TYPE_LATENCY,	"seek" },
 	{ LPROC_LL_FSYNC,	LPROCFS_TYPE_LATENCY,	"fsync" },
 	{ LPROC_LL_READDIR,	LPROCFS_TYPE_LATENCY,	"readdir" },
+	{ LPROC_LL_INODE_OCOUNT, LPROCFS_TYPE_REQS |
+				 LPROCFS_CNTR_AVGMINMAX |
+				 LPROCFS_CNTR_STDDEV,	"opencount" },
+	{ LPROC_LL_INODE_OPCLTM, LPROCFS_TYPE_LATENCY,	"openclosetime" },
 	/* inode operation */
 	{ LPROC_LL_SETATTR,	LPROCFS_TYPE_LATENCY,	"setattr" },
 	{ LPROC_LL_TRUNC,	LPROCFS_TYPE_LATENCY,	"truncate" },
 	{ LPROC_LL_FLOCK,	LPROCFS_TYPE_LATENCY,	"flock" },
 	{ LPROC_LL_GETATTR,	LPROCFS_TYPE_LATENCY,	"getattr" },
-	{ LPROC_LL_FALLOCATE,	 LPROCFS_TYPE_LATENCY,	"fallocate" },
+	{ LPROC_LL_FALLOCATE,	LPROCFS_TYPE_LATENCY,	"fallocate" },
 	/* dir inode operation */
 	{ LPROC_LL_CREATE,	LPROCFS_TYPE_LATENCY,	"create" },
 	{ LPROC_LL_LINK,	LPROCFS_TYPE_LATENCY,	"link" },
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 6ed2943..f5f34b0 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -1148,6 +1148,13 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 
 	OBD_FAIL_TIMEOUT(OBD_FAIL_LLITE_CREATE_FILE_PAUSE2, cfs_fail_val);
 
+	/* We can only arrive at this path when we have no inode, so
+	 * we only need to request open lock if it was requested
+	 * for every open
+	 */
+	if (ll_i2sbi(dir)->ll_oc_thrsh_count == 1)
+		it->it_flags |= MDS_OPEN_LOCK;
+
 	/* Dentry added to dcache tree in ll_lookup_it */
 	de = ll_lookup_it(dir, dentry, it, &secctx, &secctxlen, &pca, encrypt,
 			  &encctx, &encctxlen);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
