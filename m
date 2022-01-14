Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 4A563C433EF
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:39:35 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1355C3AD841;
	Thu, 13 Jan 2022 17:38:58 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 497883AD7BC
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:12 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id F22BA100F34A;
 Thu, 13 Jan 2022 20:38:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id EE92DA8103; Thu, 13 Jan 2022 20:38:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:37:59 -0500
Message-Id: <1642124283-10148-21-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
References: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 20/24] lustre: llite: Switch pcc to
 lookup_one_len
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

From: Patrick Farrell <pfarrell@whamcloud.com>

Using kern_path to lookup files in the PCC cache means we
are subject to user namespaces, so the PCC volume must be
mapped in to a container or the cached files cannot be
found.

One solution is to switch to using lookup_one_len - this is
what the code which *creates* PCC files does.  This
manually walks the path from the root, which avoids
namespace issues.

This is appropriate because PCC is kernel functionality -
the user should not be able to directly access the volume,
but it should be accessible as a cache.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15170
Lustre-commit: f3be560031cc7022a ("LU-15170 llite: Switch pcc to lookup_one_len")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45436
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/pcc.c | 119 +++++++++++++++++++++++++++++++++++---------------
 1 file changed, 84 insertions(+), 35 deletions(-)

diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index 85114b8..8bdf681e 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -1085,7 +1085,7 @@ void pcc_inode_free(struct inode *inode)
  * reduce overhead:
  * (fid->f_oid >> 16 & oxFFFF)/FID
  */
-#define MAX_PCC_DATABASE_PATH (6 * 5 + FID_NOBRACE_LEN + 1)
+#define PCC_DATASET_MAX_PATH (6 * 5 + FID_NOBRACE_LEN + 1)
 static int pcc_fid2dataset_path(char *buf, int sz, struct lu_fid *fid)
 {
 	return scnprintf(buf, sz, "%04x/%04x/%04x/%04x/%04x/%04x/"
@@ -1160,21 +1160,6 @@ static int pcc_get_layout_info(struct inode *inode, struct cl_layout *clt)
 	return rc < 0 ? rc : 0;
 }
 
-static int pcc_fid2dataset_fullpath(char *buf, int sz, struct lu_fid *fid,
-				    struct pcc_dataset *dataset)
-{
-	return scnprintf(buf, sz, "%s/%04x/%04x/%04x/%04x/%04x/%04x/"
-			 DFID_NOBRACE,
-			 dataset->pccd_pathname,
-			 (fid)->f_oid       & 0xFFFF,
-			 (fid)->f_oid >> 16 & 0xFFFF,
-			 (unsigned int)((fid)->f_seq       & 0xFFFF),
-			 (unsigned int)((fid)->f_seq >> 16 & 0xFFFF),
-			 (unsigned int)((fid)->f_seq >> 32 & 0xFFFF),
-			 (unsigned int)((fid)->f_seq >> 48 & 0xFFFF),
-			 PFID(fid));
-}
-
 /* Must be called with pcci->pcci_lock held */
 static void pcc_inode_attach_init(struct pcc_dataset *dataset,
 				  struct pcc_inode *pcci,
@@ -1221,6 +1206,72 @@ static inline bool pcc_inode_has_layout(struct pcc_inode *pcci)
 	return pcci->pcci_layout_gen != CL_LAYOUT_GEN_NONE;
 }
 
+static struct dentry *pcc_lookup(struct dentry *base, char *pathname)
+{
+	char *ptr = NULL, *component;
+	struct dentry *parent;
+	struct dentry *child = ERR_PTR(-ENOENT);
+
+	ptr = pathname;
+
+	/* move past any initial '/' to the start of the first path component*/
+	while (*ptr == '/')
+		ptr++;
+
+	/* store the start of the first path component */
+	component = ptr;
+
+	parent = dget(base);
+	while (ptr) {
+		/* find the start of the next component - if we don't find it,
+		 * the current component is the last component
+		 */
+		ptr = strchr(ptr, '/');
+		/* put a NUL char in place of the '/' before the next compnent
+		 * so we can treat this component as a string; note the full
+		 * path string is NUL terminated to this is not needed for the
+		 * last component
+		 */
+		if (ptr)
+			*ptr = '\0';
+
+		/* look up the current component */
+		inode_lock(parent->d_inode);
+		child = lookup_one_len(component, parent, strlen(component));
+		inode_unlock(parent->d_inode);
+
+		/* repair the path string: put '/' back in place of the NUL */
+		if (ptr)
+			*ptr = '/';
+
+		dput(parent);
+
+		if (IS_ERR_OR_NULL(child))
+			break;
+
+		/* we may find a cached negative dentry */
+		if (!d_is_positive(child)) {
+			dput(child);
+			child = NULL;
+			break;
+		}
+
+		/* descend in to the next level of the path */
+		parent = child;
+
+		/* move the pointer past the '/' to the next component */
+		if (ptr)
+			ptr++;
+		component = ptr;
+	}
+
+	/* NULL child means we didn't find anything */
+	if (!child)
+		child = ERR_PTR(-ENOENT);
+
+	return child;
+}
+
 static int pcc_try_dataset_attach(struct inode *inode, u32 gen,
 				  enum lu_pcc_type type,
 				  struct pcc_dataset *dataset,
@@ -1229,9 +1280,8 @@ static int pcc_try_dataset_attach(struct inode *inode, u32 gen,
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct pcc_inode *pcci = lli->lli_pcc_inode;
 	const struct cred *old_cred;
-	struct dentry *pcc_dentry;
-	struct path path;
-	char *pathname;
+	struct dentry *pcc_dentry = NULL;
+	char pathname[PCC_DATASET_MAX_PATH];
 	u32 pcc_gen;
 	int rc;
 
@@ -1239,27 +1289,27 @@ static int pcc_try_dataset_attach(struct inode *inode, u32 gen,
 	    !(dataset->pccd_flags & PCC_DATASET_RWPCC))
 		return 0;
 
-	pathname = kzalloc(PATH_MAX, GFP_KERNEL);
-	if (!pathname)
-		return -ENOMEM;
-
-	pcc_fid2dataset_fullpath(pathname, PATH_MAX, &lli->lli_fid, dataset);
+	rc = pcc_fid2dataset_path(pathname, PCC_DATASET_MAX_PATH,
+				  &lli->lli_fid);
 
 	old_cred = override_creds(pcc_super_cred(inode->i_sb));
-	rc = kern_path(pathname, LOOKUP_FOLLOW, &path);
-	if (rc) {
+	pcc_dentry = pcc_lookup(dataset->pccd_path.dentry, pathname);
+	if (IS_ERR(pcc_dentry)) {
+		rc = PTR_ERR(pcc_dentry);
+		CDEBUG(D_CACHE, "%s: path lookup error on "DFID":%s: rc = %d\n",
+		       ll_i2sbi(inode)->ll_fsname, PFID(&lli->lli_fid),
+		       pathname, rc);
 		/* ignore this error */
 		rc = 0;
 		goto out;
 	}
 
-	pcc_dentry = path.dentry;
 	rc = __vfs_getxattr(pcc_dentry, pcc_dentry->d_inode, pcc_xattr_layout,
 			    &pcc_gen, sizeof(pcc_gen));
 	if (rc < 0) {
 		/* ignore this error */
 		rc = 0;
-		goto out_put_path;
+		goto out_put_pcc_dentry;
 	}
 
 	rc = 0;
@@ -1271,7 +1321,7 @@ static int pcc_try_dataset_attach(struct inode *inode, u32 gen,
 			pcci = kmem_cache_zalloc(pcc_inode_slab, GFP_NOFS);
 			if (!pcci) {
 				rc = -ENOMEM;
-				goto out_put_path;
+				goto out_put_pcc_dentry;
 			}
 
 			pcc_inode_init(pcci, lli);
@@ -1294,11 +1344,10 @@ static int pcc_try_dataset_attach(struct inode *inode, u32 gen,
 		pcc_layout_gen_set(pcci, gen);
 		*cached = true;
 	}
-out_put_path:
-	path_put(&path);
+out_put_pcc_dentry:
+	dput(pcc_dentry);
 out:
 	revert_creds(old_cred);
-	kfree(pathname);
 	return rc;
 }
 
@@ -2072,11 +2121,11 @@ static int __pcc_inode_create(struct pcc_dataset *dataset,
 	struct dentry *child;
 	int rc = 0;
 
-	path = kzalloc(MAX_PCC_DATABASE_PATH, GFP_NOFS);
+	path = kzalloc(PCC_DATASET_MAX_PATH, GFP_NOFS);
 	if (!path)
 		return -ENOMEM;
 
-	pcc_fid2dataset_path(path, MAX_PCC_DATABASE_PATH, fid);
+	pcc_fid2dataset_path(path, PCC_DATASET_MAX_PATH, fid);
 
 	base = pcc_mkdir_p(dataset->pccd_path.dentry, path, 0);
 	if (IS_ERR(base)) {
@@ -2084,7 +2133,7 @@ static int __pcc_inode_create(struct pcc_dataset *dataset,
 		goto out;
 	}
 
-	snprintf(path, MAX_PCC_DATABASE_PATH, DFID_NOBRACE, PFID(fid));
+	snprintf(path, PCC_DATASET_MAX_PATH, DFID_NOBRACE, PFID(fid));
 	child = pcc_create(base, path, 0);
 	if (IS_ERR(child)) {
 		rc = PTR_ERR(child);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
