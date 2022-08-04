Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B70F4C19F29
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:38:53 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Lyrws2289z23Jk;
	Wed,  3 Aug 2022 18:38:53 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4LyrwS0TqYz1y7l
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:32 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id BAE61100AFF9;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B710B8BBFC; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:37:54 -0400
Message-Id: <1659577097-19253-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 09/32] lustre: llite: enforce ROOT default on
 subdir mount
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
Cc: Lai Siyao <lai.siyao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lai Siyao <lai.siyao@whamcloud.com>

In subdirectory mount, the filesystem-wide default LMV doesn't take
effect. This fix includes the following changes:
* enforce the filesystem-wide default LMV on subdirectory mount if
  it's not set separately.
* "lfs getdirstripe -D <subdir_mount>" should print the
  filesystem-wide default LMV.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15910
Lustre-commit: a162e24d2da5e4bd6 ("LU-15910 llite: enforce ROOT default on subdir mount")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/47518
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c            | 75 ++++++++++++++++++++++++----------------
 fs/lustre/llite/llite_internal.h |  3 ++
 fs/lustre/llite/llite_lib.c      | 46 ++++++++++++++++++++++--
 3 files changed, 93 insertions(+), 31 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 6eaac9a..2b63c48 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -655,10 +655,9 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 	return rc;
 }
 
-static int ll_dir_get_default_layout(struct inode *inode, void **plmm,
-				     int *plmm_size,
-				     struct ptlrpc_request **request, u64 valid,
-				     enum get_default_layout_type type)
+int ll_dir_get_default_layout(struct inode *inode, void **plmm, int *plmm_size,
+			      struct ptlrpc_request **request, u64 valid,
+			      enum get_default_layout_type type)
 {
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct mdt_body *body;
@@ -1627,35 +1626,53 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 				lum = (struct lmv_user_md *)lmm;
 				lli = ll_i2info(inode);
-				if (lum->lum_max_inherit == LMV_INHERIT_NONE ||
-				    (lum->lum_max_inherit > 0 &&
-				     lum->lum_max_inherit < lli->lli_dir_depth)) {
-					rc = -ENODATA;
-					goto finish_req;
-				}
+				if (lum->lum_max_inherit !=
+				    LMV_INHERIT_UNLIMITED) {
+					if (lum->lum_max_inherit ==
+						LMV_INHERIT_NONE ||
+					    lum->lum_max_inherit <
+						LMV_INHERIT_END ||
+					    lum->lum_max_inherit >
+						LMV_INHERIT_MAX ||
+					    lum->lum_max_inherit <
+						lli->lli_dir_depth) {
+						rc = -ENODATA;
+						goto finish_req;
+					}
+
+					if (lum->lum_max_inherit ==
+					    lli->lli_dir_depth) {
+						lum->lum_max_inherit =
+							LMV_INHERIT_NONE;
+						lum->lum_max_inherit_rr =
+							LMV_INHERIT_RR_NONE;
+						goto out_copy;
+					}
 
-				if (lum->lum_max_inherit ==
-				    lli->lli_dir_depth) {
-					lum->lum_max_inherit = LMV_INHERIT_NONE;
-					lum->lum_max_inherit_rr =
-						LMV_INHERIT_RR_NONE;
-					goto out_copy;
-				}
-				if (lum->lum_max_inherit > lli->lli_dir_depth &&
-				    lum->lum_max_inherit <= LMV_INHERIT_MAX)
 					lum->lum_max_inherit -=
 						lli->lli_dir_depth;
+				}
 
-				if (lum->lum_max_inherit_rr >
-					lli->lli_dir_depth &&
-				    lum->lum_max_inherit_rr <=
-					LMV_INHERIT_RR_MAX)
-					lum->lum_max_inherit_rr -=
-						lli->lli_dir_depth;
-				else if (lum->lum_max_inherit_rr ==
-						lli->lli_dir_depth)
-					lum->lum_max_inherit_rr =
-						LMV_INHERIT_RR_NONE;
+				if (lum->lum_max_inherit_rr !=
+				    LMV_INHERIT_RR_UNLIMITED) {
+					if (lum->lum_max_inherit_rr ==
+						LMV_INHERIT_NONE ||
+					    lum->lum_max_inherit_rr <
+						LMV_INHERIT_RR_END ||
+					    lum->lum_max_inherit_rr >
+						LMV_INHERIT_RR_MAX ||
+					    lum->lum_max_inherit_rr <=
+						lli->lli_dir_depth) {
+						lum->lum_max_inherit_rr =
+							LMV_INHERIT_RR_NONE;
+						goto out_copy;
+					}
+
+					if (lum->lum_max_inherit_rr >
+					    lli->lli_dir_depth)
+						lum->lum_max_inherit_rr -=
+							lli->lli_dir_depth;
+				}
 			}
 out_copy:
 			if (copy_to_user(ulmv, lmm, lmmsize))
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 70a42d4..c350440 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1155,6 +1155,9 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 			     struct ptlrpc_request **request);
 int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 		     int set_default);
+int ll_dir_get_default_layout(struct inode *inode, void **plmm, int *plmm_size,
+			      struct ptlrpc_request **request, u64 valid,
+			      enum get_default_layout_type type);
 int ll_dir_getstripe_default(struct inode *inode, void **lmmp,
 			     int *lmm_size, struct ptlrpc_request **request,
 			     struct ptlrpc_request **root_request, u64 valid);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index b55a30f..5b80722 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2972,6 +2972,39 @@ void ll_open_cleanup(struct super_block *sb, struct req_capsule *pill)
 	ll_finish_md_op_data(op_data);
 }
 
+/* set filesystem-wide default LMV for subdir mount if it's enabled on ROOT. */
+static int ll_fileset_default_lmv_fixup(struct inode *inode,
+					struct lustre_md *md)
+{
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	struct ptlrpc_request *req = NULL;
+	union lmv_mds_md *lmm = NULL;
+	int size = 0;
+	int rc;
+
+	LASSERT(is_root_inode(inode));
+	LASSERT(!fid_is_root(&sbi->ll_root_fid));
+	LASSERT(!md->default_lmv);
+
+	rc = ll_dir_get_default_layout(inode, (void **)&lmm, &size, &req,
+				       OBD_MD_DEFAULT_MEA,
+				       GET_DEFAULT_LAYOUT_ROOT);
+	if (rc && rc != -ENODATA)
+		goto out;
+
+	rc = 0;
+	if (lmm && size) {
+		rc = md_unpackmd(sbi->ll_md_exp, &md->default_lmv, lmm, size);
+		if (rc < 0)
+			goto out;
+		rc = 0;
+	}
+out:
+	if (req)
+		ptlrpc_req_finished(req);
+	return rc;
+}
+
 int ll_prep_inode(struct inode **inode, struct req_capsule *pill,
 		  struct super_block *sb, struct lookup_intent *it)
 {
@@ -2993,8 +3026,17 @@ int ll_prep_inode(struct inode **inode, struct req_capsule *pill,
 	 * ll_update_lsm_md() may change md.
 	 */
 	if (it && (it->it_op & (IT_LOOKUP | IT_GETATTR)) &&
-	    S_ISDIR(md.body->mbo_mode) && !md.default_lmv)
-		default_lmv_deleted = true;
+	    S_ISDIR(md.body->mbo_mode) && !md.default_lmv) {
+		if (unlikely(*inode && is_root_inode(*inode) &&
+			     !fid_is_root(&sbi->ll_root_fid))) {
+			rc = ll_fileset_default_lmv_fixup(*inode, &md);
+			if (rc)
+				goto out;
+		}
+
+		if (!md.default_lmv)
+			default_lmv_deleted = true;
+	}
 
 	if (*inode) {
 		rc = ll_update_inode(*inode, &md);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
