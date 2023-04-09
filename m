Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 31B7FC77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:38:52 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWRW0QtXz22VH;
	Sun,  9 Apr 2023 05:21:09 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWLb3MTRz1yD0
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:16:55 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 2CDD51008485;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2B5102AB; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:13:03 -0400
Message-Id: <1681042400-15491-24-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 23/40] lustre: llite: replace lld_nfs_dentry
 flag with opencache handling
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

The lld_nfs_dentry flag was created for the case of caching the
open lock (opencache) when fetching fhandles for NFSv3. This same
path is used by the fhandle APIs. This lighter open changes key
behaviors since the open lock is always cached which we don't
want. Lustre introduced a way to modify caching the open lock
based on the number of opens done on a file within a certain
span of time. We can replace lld_nfs_dentry flag with the
new open lock caching. This way for fhandle handling we match
the open lock caching behavior of a normal file open.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16463
Lustre-commit: d7a85652f4fcb8319 ("LU-16463 llite: replace lld_nfs_dentry flag with opencache handling")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49237
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Etienne AUJAMES <eaujames@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/llite/file.c           | 26 ++++++++------------------
 fs/lustre/llite/llite_internal.h | 13 +++++++------
 fs/lustre/llite/llite_nfs.c      | 15 +--------------
 fs/lustre/llite/namei.c          |  8 +++++++-
 fs/lustre/llite/super25.c        |  2 ++
 5 files changed, 25 insertions(+), 39 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index a9d247c..fb8ede2 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -916,7 +916,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 		if (!it->it_disposition) {
 			struct dentry *dentry = file_dentry(file);
 			struct ll_sb_info *sbi = ll_i2sbi(inode);
-			struct ll_dentry_data *ldd;
+			int open_threshold = sbi->ll_oc_thrsh_count;
 
 			/* We cannot just request lock handle now, new ELC code
 			 * means that one of other OPEN locks for this file
@@ -927,22 +927,20 @@ int ll_file_open(struct inode *inode, struct file *file)
 			mutex_unlock(&lli->lli_och_mutex);
 			/*
 			 * Normally called under two situations:
-			 * 1. NFS export.
+			 * 1. fhandle / NFS export.
 			 * 2. A race/condition on MDS resulting in no open
 			 *    handle to be returned from LOOKUP|OPEN request,
 			 *    for example if the target entry was a symlink.
 			 *
-			 * In NFS path we know there's pathologic behavior
-			 * so we always enable open lock caching when coming
-			 * from there. It's detected by setting a flag in
-			 * ll_iget_for_nfs.
-			 *
 			 * After reaching number of opens of this inode
 			 * we always ask for an open lock on it to handle
 			 * bad userspace actors that open and close files
 			 * in a loop for absolutely no good reason
 			 */
-			ldd = ll_d2d(dentry);
+			/* fhandle / NFS path. */
+			if (lli->lli_open_thrsh_count != UINT_MAX)
+				open_threshold = lli->lli_open_thrsh_count;
+
 			if (filename_is_volatile(dentry->d_name.name,
 						 dentry->d_name.len,
 						 NULL)) {
@@ -951,17 +949,9 @@ int ll_file_open(struct inode *inode, struct file *file)
 				 * We do not want openlock for volatile
 				 * files under any circumstances
 				 */
-			} else if (ldd && ldd->lld_nfs_dentry) {
-				/* NFS path. This also happens to catch
-				 * open by fh files I guess
-				 */
-				it->it_flags |= MDS_OPEN_LOCK;
-				/* clear the flag for future lookups */
-				ldd->lld_nfs_dentry = 0;
-			} else if (sbi->ll_oc_thrsh_count > 0) {
+			} else if (open_threshold > 0) {
 				/* Take MDS_OPEN_LOCK with many opens */
-				if (lli->lli_open_fd_count >=
-				    sbi->ll_oc_thrsh_count)
+				if (lli->lli_open_fd_count >= open_threshold)
 					it->it_flags |= MDS_OPEN_LOCK;
 
 				/* If this is open after we just closed */
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 6bbc781..cdfc75e 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -72,7 +72,6 @@
 struct ll_dentry_data {
 	unsigned int			lld_sa_generation;
 	unsigned int			lld_invalid:1;
-	unsigned int			lld_nfs_dentry:1;
 	struct rcu_head			lld_rcu_head;
 };
 
@@ -145,11 +144,6 @@ struct ll_inode_info {
 	u64				lli_open_fd_write_count;
 	u64				lli_open_fd_exec_count;
 
-	/* Number of times this inode was opened */
-	u64				lli_open_fd_count;
-	/* When last close was performed on this inode */
-	ktime_t				lli_close_fd_time;
-
 	/* Protects access to och pointers and their usage counters */
 	struct mutex			lli_och_mutex;
 
@@ -162,6 +156,13 @@ struct ll_inode_info {
 	s64				lli_btime;
 	spinlock_t			lli_agl_lock;
 
+	/* inode specific open lock caching threshold */
+	u32				lli_open_thrsh_count;
+	/* Number of times this inode was opened */
+	u64				lli_open_fd_count;
+	/* When last close was performed on this inode */
+	ktime_t				lli_close_fd_time;
+
 	/* Try to make the d::member and f::member are aligned. Before using
 	 * these members, make clear whether it is directory or not.
 	 */
diff --git a/fs/lustre/llite/llite_nfs.c b/fs/lustre/llite/llite_nfs.c
index 3c4c9ef..232b2b3 100644
--- a/fs/lustre/llite/llite_nfs.c
+++ b/fs/lustre/llite/llite_nfs.c
@@ -114,7 +114,6 @@ struct inode *search_inode_for_lustre(struct super_block *sb,
 		struct lu_fid *fid, struct lu_fid *parent)
 {
 	struct inode *inode;
-	struct dentry *result;
 
 	if (!fid_is_sane(fid))
 		return ERR_PTR(-ESTALE);
@@ -131,19 +130,7 @@ struct inode *search_inode_for_lustre(struct super_block *sb,
 		return ERR_PTR(-ESTALE);
 	}
 
-	result = d_obtain_alias(inode);
-	if (IS_ERR(result))
-		return result;
-
-	/*
-	 * Need to signal to the ll_intent_file_open that
-	 * we came from NFS and so opencache needs to be
-	 * enabled for this one
-	 */
-	spin_lock(&result->d_lock);
-	ll_d2d(result)->lld_nfs_dentry = 1;
-	spin_unlock(&result->d_lock);
-	return result;
+	return d_obtain_alias(inode);
 }
 
 /**
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 9314a17..ada539e 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -1144,6 +1144,7 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	struct ll_sb_info *sbi = NULL;
 	struct pcc_create_attach pca = { NULL, NULL };
 	bool encrypt = false;
+	int open_threshold;
 	int rc = 0;
 
 	CDEBUG(D_VFSTRACE,
@@ -1224,7 +1225,12 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	 * we only need to request open lock if it was requested
 	 * for every open
 	 */
-	if (ll_i2sbi(dir)->ll_oc_thrsh_count == 1 &&
+	if (ll_i2info(dir)->lli_open_thrsh_count != UINT_MAX)
+		open_threshold = ll_i2info(dir)->lli_open_thrsh_count;
+	else
+		open_threshold = ll_i2sbi(dir)->ll_oc_thrsh_count;
+
+	if (open_threshold == 1 &&
 	    exp_connect_flags2(ll_i2mdexp(dir)) &
 	    OBD_CONNECT2_ATOMIC_OPEN_LOCK)
 		it->it_flags |= MDS_OPEN_LOCK;
diff --git a/fs/lustre/llite/super25.c b/fs/lustre/llite/super25.c
index 5349a25..50272a7 100644
--- a/fs/lustre/llite/super25.c
+++ b/fs/lustre/llite/super25.c
@@ -55,6 +55,8 @@ static struct inode *ll_alloc_inode(struct super_block *sb)
 		return NULL;
 
 	inode_init_once(&lli->lli_vfs_inode);
+	lli->lli_open_thrsh_count = UINT_MAX;
+
 	return &lli->lli_vfs_inode;
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
