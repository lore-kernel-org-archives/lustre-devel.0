Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 90533C433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:32:35 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A972321FB53;
	Sun, 20 Mar 2022 06:31:57 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5479621F3E8
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:18 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 5CDF5EF7;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 586BBD6A26; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:46 -0400
Message-Id: <1647783064-20688-33-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 32/50] lustre: llite: LL_IOC_LMV_GETSTRIPE
 'default' shows inherit layout
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
Cc: Lai Siyao <lai.siyao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lai Siyao <lai.siyao@whamcloud.com>

Once system-wide default LMV is set, "lfs getdirstripe -D subdir"
should show inherited layout from it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15200
Lustre-commit: 61b1fad9e3fb21edc ("LU-15200 llite: "lfs getdirstripe -D" shows inherit layout")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45570
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c | 39 ++++++++++++++++++++++++++++++++++++++-
 1 file changed, 38 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index b4870d9..d3df4d0 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -759,7 +759,7 @@ int ll_dir_getstripe_default(struct inode *inode, void **plmm, int *plmm_size,
 	rc = ll_dir_get_default_layout(inode, (void **)&lmm, &lmm_size,
 				       &req, valid, 0);
 	if (rc == -ENODATA && !fid_is_root(ll_inode2fid(inode)) &&
-	    !(valid & (OBD_MD_MEA|OBD_MD_DEFAULT_MEA)) && root_request) {
+	    !(valid & OBD_MD_MEA) && root_request) {
 		int rc2 = ll_dir_get_default_layout(inode, (void **)&lmm,
 						    &lmm_size, &root_req, valid,
 						    GET_DEFAULT_LAYOUT_ROOT);
@@ -1602,6 +1602,43 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 				goto finish_req;
 			}
 
+			if (root_request) {
+				struct lmv_user_md *lum;
+				struct ll_inode_info *lli;
+
+				lum = (struct lmv_user_md *)lmm;
+				lli = ll_i2info(inode);
+				if (lum->lum_max_inherit == LMV_INHERIT_NONE ||
+				    (lum->lum_max_inherit > 0 &&
+				     lum->lum_max_inherit < lli->lli_dir_depth)) {
+					rc = -ENODATA;
+					goto finish_req;
+				}
+
+				if (lum->lum_max_inherit ==
+				    lli->lli_dir_depth) {
+					lum->lum_max_inherit = LMV_INHERIT_NONE;
+					lum->lum_max_inherit_rr =
+						LMV_INHERIT_RR_NONE;
+					goto out_copy;
+				}
+				if (lum->lum_max_inherit > lli->lli_dir_depth &&
+				    lum->lum_max_inherit <= LMV_INHERIT_MAX)
+					lum->lum_max_inherit -=
+						lli->lli_dir_depth;
+
+				if (lum->lum_max_inherit_rr >
+					lli->lli_dir_depth &&
+				    lum->lum_max_inherit_rr <=
+					LMV_INHERIT_RR_MAX)
+					lum->lum_max_inherit_rr -=
+						lli->lli_dir_depth;
+				else if (lum->lum_max_inherit_rr ==
+						lli->lli_dir_depth)
+					lum->lum_max_inherit_rr =
+						LMV_INHERIT_RR_NONE;
+			}
+out_copy:
 			if (copy_to_user(ulmv, lmm, lmmsize))
 				rc = -EFAULT;
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
