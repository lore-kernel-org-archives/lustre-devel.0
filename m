Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 7F333C77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:30:40 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWMp5Dfjz226L;
	Sun,  9 Apr 2023 05:17:58 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWJm6QGYz216P
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:15:20 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 1A4BF1008481;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 190952B3; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:12:59 -0400
Message-Id: <1681042400-15491-20-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 19/40] lustre: fileset: check fileset for
 operations by fid
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

From: Sebastien Buisson <sbuisson@ddn.com>

Some operations by FID, such as lfs rmfid, must be aware of
subdirectory mount (fileset) so that they do not operate on files
that are outside of the namespace currently mounted by the client.

For lfs rmfid, we first proceed to a fid2path resolution. As fid2path
is already fileset aware, it fails if a file or a link to a file is
outside of the subdirectory mount. So we carry on with rmfid only
for FIDs for which the file and all links do appear under the
current fileset.

This new behavior is enabled as soon as we detect a subdirectory mount
is done (either directly or imposed by a nodemap fileset). This means
the new behavior does not impact normal, whole-namespace client mount.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16494
Lustre-commit: 9a72c073d33b04542 ("LU-16494 fileset: check fileset for operations by fid")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49696
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: jsimmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c            | 84 ++++++++++++++++++++++++++++++++++++++++
 fs/lustre/llite/file.c           | 55 ++++++++++++++------------
 fs/lustre/llite/llite_internal.h |  2 +
 3 files changed, 116 insertions(+), 25 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 56ef1bb..1298bd6 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1295,6 +1295,7 @@ int ll_rmfid(struct file *file, void __user *arg)
 {
 	const struct fid_array __user *ufa = arg;
 	struct inode *inode = file_inode(file);
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct fid_array *lfa = NULL;
 	size_t size;
 	unsigned int nr;
@@ -1325,8 +1326,91 @@ int ll_rmfid(struct file *file, void __user *arg)
 		goto free_rcs;
 	}
 
+	/* In case of subdirectory mount, we need to make sure all the files
+	 * for which we want to remove FID are visible in the namespace.
+	 */
+	if (!fid_is_root(&sbi->ll_root_fid)) {
+		struct fid_array *lfa_new = NULL;
+		int path_len = PATH_MAX, linkno;
+		struct getinfo_fid2path *gf;
+		int idx, last_idx = nr - 1;
+
+		lfa_new = kzalloc(size, GFP_NOFS);
+		if (!lfa_new) {
+			rc = -ENOMEM;
+			goto free_rcs;
+		}
+		lfa_new->fa_nr = 0;
+
+		gf = kmalloc(sizeof(*gf) + path_len + 1, GFP_NOFS);
+		if (!gf) {
+			rc = -ENOMEM;
+			goto free_rcs;
+		}
+
+		for (idx = 0; idx < nr; idx++) {
+			linkno = 0;
+			while (1) {
+				memset(gf, 0, sizeof(*gf) + path_len + 1);
+				gf->gf_fid = lfa->fa_fids[idx];
+				gf->gf_pathlen = path_len;
+				gf->gf_linkno = linkno;
+				rc = __ll_fid2path(inode, gf,
+						   sizeof(*gf) + gf->gf_pathlen,
+						   gf->gf_pathlen);
+				if (rc == -ENAMETOOLONG) {
+					struct getinfo_fid2path *tmpgf;
+
+					path_len += PATH_MAX;
+					tmpgf = krealloc(gf,
+						     sizeof(*gf) + path_len + 1,
+						     GFP_NOFS);
+					if (!tmpgf) {
+						kfree(gf);
+						kfree(lfa_new);
+						rc = -ENOMEM;
+						goto free_rcs;
+					}
+					gf = tmpgf;
+					continue;
+				}
+				if (rc)
+					break;
+				if (gf->gf_linkno == linkno)
+					break;
+				linkno = gf->gf_linkno;
+			}
+
+			if (!rc) {
+				/* All the links for this fid are visible in the
+				 * mounted subdir. So add it to the list of fids
+				 * to remove.
+				 */
+				lfa_new->fa_fids[lfa_new->fa_nr++] =
+					lfa->fa_fids[idx];
+			} else {
+				/* At least one link for this fid is not visible
+				 * in the mounted subdir. So add it at the end
+				 * of the list that will be hidden to lower
+				 * layers, and set -ENOENT as ret code.
+				 */
+				lfa_new->fa_fids[last_idx] = lfa->fa_fids[idx];
+				rcs[last_idx--] = rc;
+			}
+		}
+		kfree(gf);
+		kfree(lfa);
+		lfa = lfa_new;
+	}
+
+	if (lfa->fa_nr == 0) {
+		rc = rcs[nr - 1];
+		goto free_rcs;
+	}
+
 	/* Call mdc_iocontrol */
 	rc = md_rmfid(ll_i2mdexp(file_inode(file)), lfa, rcs, NULL);
+	lfa->fa_nr = nr;
 	if (!rc) {
 		for (i = 0; i < nr; i++)
 			if (rcs[i])
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 18f3302..a9d247c 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -2917,9 +2917,37 @@ static int fid2path_for_enc_file(struct inode *parent, char *gfpath,
 	return rc;
 }
 
-int ll_fid2path(struct inode *inode, void __user *arg)
+int __ll_fid2path(struct inode *inode, struct getinfo_fid2path *gfout,
+		  size_t outsize, __u32 pathlen_orig)
 {
 	struct obd_export *exp = ll_i2mdexp(inode);
+	int rc;
+
+	/* Append root FID after gfout to let MDT know the root FID so that
+	 * it can lookup the correct path, this is mainly for fileset.
+	 * old server without fileset mount support will ignore this.
+	 */
+	*gfout->gf_root_fid = *ll_inode2fid(inode);
+
+	/* Call mdc_iocontrol */
+	rc = obd_iocontrol(OBD_IOC_FID2PATH, exp, outsize, gfout, NULL);
+
+	if (!rc && gfout->gf_pathlen && gfout->gf_path[0] == '/') {
+		/* by convention, server side (mdt_path_current()) puts
+		 * a leading '/' to tell client that we are dealing with
+		 * an encrypted file
+		 */
+		rc = fid2path_for_enc_file(inode, gfout->gf_path,
+					   gfout->gf_pathlen);
+		if (!rc && strlen(gfout->gf_path) > pathlen_orig)
+			rc = -EOVERFLOW;
+	}
+
+	return rc;
+}
+
+int ll_fid2path(struct inode *inode, void __user *arg)
+{
 	const struct getinfo_fid2path __user *gfin = arg;
 	struct getinfo_fid2path *gfout;
 	u32 pathlen, pathlen_orig;
@@ -2950,34 +2978,11 @@ int ll_fid2path(struct inode *inode, void __user *arg)
 		goto gf_free;
 	}
 
-	/*
-	 * append root FID after gfout to let MDT know the root FID so that it
-	 * can lookup the correct path, this is mainly for fileset.
-	 * old server without fileset mount support will ignore this.
-	 */
-	*gfout->gf_root_fid = *ll_inode2fid(inode);
 	gfout->gf_pathlen = pathlen;
-
-	/* Call mdc_iocontrol */
-	rc = obd_iocontrol(OBD_IOC_FID2PATH, exp, outsize, gfout, NULL);
+	rc = __ll_fid2path(inode, gfout, outsize, pathlen_orig);
 	if (rc != 0)
 		goto gf_free;
 
-	if (gfout->gf_pathlen && gfout->gf_path[0] == '/') {
-		/* by convention, server side (mdt_path_current()) puts
-		 * a leading '/' to tell client that we are dealing with
-		 * an encrypted file
-		 */
-		rc = fid2path_for_enc_file(inode, gfout->gf_path,
-					   gfout->gf_pathlen);
-		if (rc)
-			goto gf_free;
-		if (strlen(gfout->gf_path) > gfin->gf_pathlen) {
-			rc = -EOVERFLOW;
-			goto gf_free;
-		}
-	}
-
 	if (copy_to_user(arg, gfout, sizeof(*gfout) + pathlen_orig))
 		rc = -EFAULT;
 
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 970b144..6bbc781 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1245,6 +1245,8 @@ int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
 int ll_fsync(struct file *file, loff_t start, loff_t end, int data);
 int ll_merge_attr(const struct lu_env *env, struct inode *inode);
 int ll_fid2path(struct inode *inode, void __user *arg);
+int __ll_fid2path(struct inode *inode, struct getinfo_fid2path *gfout,
+		  size_t outsize, u32 pathlen_orig);
 int ll_data_version(struct inode *inode, u64 *data_version, int flags);
 int ll_hsm_release(struct inode *inode);
 int ll_hsm_state_set(struct inode *inode, struct hsm_state_set *hss);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
