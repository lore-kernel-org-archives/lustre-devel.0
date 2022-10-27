Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 04752FA3740
	for <lustre-devel@archiver.kernel.org>; Thu, 27 Oct 2022 14:17:48 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mync7202Mz21HM;
	Thu, 27 Oct 2022 07:09:27 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mynbv5tDwz21H2
 for <lustre-devel@lists.lustre.org>; Thu, 27 Oct 2022 07:09:15 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 829AF1009101;
 Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 7DA76FD4E1; Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 27 Oct 2022 10:05:35 -0400
Message-Id: <1666879542-10737-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
References: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/15] lustre: llite: adjust read count as
 file got truncated
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

From: Bobi Jam <bobijam@whamcloud.com>

File read will not notice the file size truncate by another node,
and continue to read 0 filled pages beyond the new file size.

This patch add a confinement in the read to prevent the issue and
add a test case verifying the fix.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16025
Lustre-commit: 4468f6c9d92448cb7 ("LU-16025 llite: adjust read count as file got truncated")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/47896
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <farr0186@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c          | 76 ++++++++++++++++++++++++++++++++++++++++-
 fs/lustre/llite/glimpse.c       |  7 +++-
 fs/lustre/lov/lov_cl_internal.h |  6 ++--
 fs/lustre/lov/lov_object.c      | 14 ++++----
 4 files changed, 92 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index f96557e..f35cddc 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1957,6 +1957,59 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 	return result;
 }
 
+/**
+ * Confine read iter lest read beyond the EOF
+ *
+ * @iocb	kernel iocb
+ * @to		reader iov_iter
+ *
+ * RETURN	0	success
+ *		<0	failure
+ *		>0	@iocb->ki_pos has passed the EOF
+ */
+static int file_read_confine_iter(struct lu_env *env, struct kiocb *iocb,
+				  struct iov_iter *to)
+{
+	struct cl_attr *attr = vvp_env_thread_attr(env);
+	struct file *file = iocb->ki_filp;
+	struct inode *inode = file_inode(file);
+	struct ll_inode_info *lli = ll_i2info(inode);
+	loff_t read_end = iocb->ki_pos + iov_iter_count(to);
+	loff_t kms;
+	loff_t size;
+	int rc;
+
+	cl_object_attr_lock(lli->lli_clob);
+	rc = cl_object_attr_get(env, lli->lli_clob, attr);
+	cl_object_attr_unlock(lli->lli_clob);
+	if (rc != 0)
+		return rc;
+
+	kms = attr->cat_kms;
+	/* if read beyond end-of-file, adjust read count */
+	if (kms > 0 && (iocb->ki_pos >= kms || read_end > kms)) {
+		rc = ll_glimpse_size(inode);
+		if (rc != 0)
+			return rc;
+
+		size = i_size_read(inode);
+		if (iocb->ki_pos >= size || read_end > size) {
+			CDEBUG(D_VFSTRACE,
+			       "%s: read [%llu, %llu] over eof, kms %llu, file_size %llu.\n",
+			       file_dentry(file)->d_name.name,
+			       iocb->ki_pos, read_end, kms, size);
+
+			if (iocb->ki_pos >= size)
+				return 1;
+
+			if (read_end > size)
+				iov_iter_truncate(to, size - iocb->ki_pos);
+		}
+	}
+
+	return rc;
+}
+
 static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 {
 	struct lu_env *env;
@@ -1967,6 +2020,7 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	ssize_t rc2;
 	ktime_t kstart = ktime_get();
 	bool cached;
+	bool stale_data = false;
 
 	CDEBUG(D_VFSTRACE|D_IOTRACE, "file %s:"DFID", ppos: %lld, count: %zu\n",
 	       file_dentry(file)->d_name.name,
@@ -1976,6 +2030,16 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	if (!iov_iter_count(to))
 		return 0;
 
+	env = cl_env_get(&refcheck);
+	if (IS_ERR(env))
+		return PTR_ERR(env);
+
+	result = file_read_confine_iter(env, iocb, to);
+	if (result < 0)
+		goto out;
+	else if (result > 0)
+		stale_data = true;
+
 	/**
 	 * Currently when PCC read failed, we do not fall back to the
 	 * normal read path, just return the error.
@@ -2012,8 +2076,18 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	else if (result == 0)
 		result = rc2;
 
-	cl_env_put(env, &refcheck);
 out:
+	cl_env_put(env, &refcheck);
+
+	if (stale_data && result > 0) {
+		/**
+		 * we've reached EOF before the read, the data read are cached
+		 * stale data.
+		 */
+		iov_iter_truncate(to, 0);
+		result = 0;
+	}
+
 	if (result > 0) {
 		ll_rw_stats_tally(ll_i2sbi(file_inode(file)), current->pid,
 				  file->private_data, iocb->ki_pos, result,
diff --git a/fs/lustre/llite/glimpse.c b/fs/lustre/llite/glimpse.c
index c55d079..0190cb5 100644
--- a/fs/lustre/llite/glimpse.c
+++ b/fs/lustre/llite/glimpse.c
@@ -206,7 +206,12 @@ int __cl_glimpse_size(struct inode *inode, int agl)
 		} else if (result == 0) {
 			result = cl_glimpse_lock(env, io, inode, io->ci_obj,
 						 agl);
-			if (!agl && result == -EAGAIN)
+			/**
+			 * need to limit retries for FLR mirrors if fast read
+			 * is short because of concurrent truncate.
+			 */
+			if (!agl && result == -EAGAIN &&
+			    !io->ci_tried_all_mirrors)
 				io->ci_need_restart = 1;
 		}
 
diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index 95dbb43..49cc40b 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -377,8 +377,10 @@ static inline struct lov_layout_entry *lov_entry(struct lov_object *lov, int i)
 }
 
 #define lov_for_layout_entry(lov, entry, start, end)			\
-	for (entry = lov_entry(lov, start);				\
-	     entry <= lov_entry(lov, end); entry++)
+	if (lov->u.composite.lo_entries &&				\
+	    lov->u.composite.lo_entry_count > 0)			\
+		for (entry = lov_entry(lov, start);			\
+		     entry <= lov_entry(lov, end); entry++)
 
 #define lov_foreach_layout_entry(lov, entry)				\
 	lov_for_layout_entry(lov, entry, 0,				\
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 064764c..5245fd6 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -847,19 +847,17 @@ static int lov_delete_composite(const struct lu_env *env,
 				struct lov_object *lov,
 				union lov_layout_state *state)
 {
-	struct lov_layout_composite *comp = &state->composite;
 	struct lov_layout_entry *entry;
 
 	dump_lsm(D_INODE, lov->lo_lsm);
 
 	lov_layout_wait(env, lov);
-	if (comp->lo_entries)
-		lov_foreach_layout_entry(lov, entry) {
-			if (entry->lle_lsme && lsme_is_foreign(entry->lle_lsme))
-				continue;
+	lov_foreach_layout_entry(lov, entry) {
+		if (entry->lle_lsme && lsme_is_foreign(entry->lle_lsme))
+			continue;
 
-			lov_delete_raid0(env, lov, entry);
-		}
+		lov_delete_raid0(env, lov, entry);
+	}
 
 	return 0;
 }
@@ -997,6 +995,8 @@ static int lov_attr_get_composite(const struct lu_env *env,
 
 	attr->cat_size = 0;
 	attr->cat_blocks = 0;
+	attr->cat_kms = 0;
+
 	lov_foreach_layout_entry(lov, entry) {
 		int index = lov_layout_entry_index(lov, entry);
 		struct cl_attr *lov_attr = NULL;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
