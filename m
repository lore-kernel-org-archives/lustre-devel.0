Return-Path: <SRS0=Xi2l=P3=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDDD2C433FE
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:03 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 94B5061053
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 94B5061053
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id F3AD221E053;
	Mon,  8 Nov 2021 07:07:59 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (SMTP3.CCS.ORNL.GOV [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0B2DA21C967
 for <lustre-devel@lists.lustre.org>; Mon,  8 Nov 2021 07:07:51 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 2DF21222A;
 Mon,  8 Nov 2021 10:07:46 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2B002E07E1; Mon,  8 Nov 2021 10:07:46 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Nov 2021 10:07:39 -0500
Message-Id: <1636384063-13838-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
References: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/15] lustre: vfs: set_nlink() is not
 race-safe
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
Cc: Andrew Perepechko <andrew.perepechko@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andrew Perepechko <andrew.perepechko@hpe.com>

set_nlink() is not atomic wrt race with itself and
the following warning may be triggered by VFS:

WARNING: CPU: 5 PID: 195090 at fs/inode.c:241 __destroy_inode+0xdb/0xf0

It does not seem important what exact nlink value is the result
of the race. However, we need to protect the superblock remove
counter.

HPE-bug-id: LUS-9825
WC-bug-id: https://jira.whamcloud.com/browse/LU-15081
Lustre-commit: 12b05772fdb6d0808 ("LU-15081 vfs: set_nlink() is not race-safe")
Signed-off-by: Andrew Perepechko <andrew.perepechko@hpe.com>
Reviewed-on: https://review.whamcloud.com/45191
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c      |  3 +++
 fs/lustre/llite/llite_lib.c |  5 ++++-
 fs/lustre/llite/namei.c     | 10 ++++++++--
 fs/lustre/lmv/lmv_intent.c  |  2 ++
 4 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 1e4ff49..6755671 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -5041,7 +5041,10 @@ static int ll_merge_md_attr(struct inode *inode)
 	if (rc)
 		return rc;
 
+	spin_lock(&inode->i_lock);
 	set_nlink(inode, attr.cat_nlink);
+	spin_unlock(&inode->i_lock);
+
 	inode->i_blocks = attr.cat_blocks;
 	i_size_write(inode, attr.cat_size);
 
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 51823b5..147e680 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2448,8 +2448,11 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 		inode->i_gid = make_kgid(&init_user_ns, body->mbo_gid);
 	if (body->mbo_valid & OBD_MD_FLPROJID)
 		lli->lli_projid = body->mbo_projid;
-	if (body->mbo_valid & OBD_MD_FLNLINK)
+	if (body->mbo_valid & OBD_MD_FLNLINK) {
+		spin_lock(&inode->i_lock);
 		set_nlink(inode, body->mbo_nlink);
+		spin_unlock(&inode->i_lock);
+	}
 	if (body->mbo_valid & OBD_MD_FLRDEV)
 		inode->i_rdev = old_decode_dev(body->mbo_rdev);
 
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index fe7fdbb..a0192da 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -1867,8 +1867,11 @@ static int ll_unlink(struct inode *dir, struct dentry *dchild)
 	 * the link count so the inode can be freed immediately.
 	 */
 	body = req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY);
-	if (body->mbo_valid & OBD_MD_FLNLINK)
+	if (body->mbo_valid & OBD_MD_FLNLINK) {
+		spin_lock(&dchild->d_inode->i_lock);
 		set_nlink(dchild->d_inode, body->mbo_nlink);
+		spin_unlock(&dchild->d_inode->i_lock);
+	}
 
 	ll_update_times(request, dir);
 	ll_stats_ops_tally(ll_i2sbi(dir), LPROC_LL_UNLINK,
@@ -1938,8 +1941,11 @@ static int ll_rmdir(struct inode *dir, struct dentry *dchild)
 		 * immediately.
 		 */
 		body = req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY);
-		if (body->mbo_valid & OBD_MD_FLNLINK)
+		if (body->mbo_valid & OBD_MD_FLNLINK) {
+			spin_lock(&dchild->d_inode->i_lock);
 			set_nlink(dchild->d_inode, body->mbo_nlink);
+			spin_unlock(&dchild->d_inode->i_lock);
+		}
 	}
 
 	ptlrpc_req_finished(request);
diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index 88201e6..93da2b3 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -252,7 +252,9 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 
 			i_size_write(inode, body->mbo_size);
 			inode->i_blocks = body->mbo_blocks;
+			spin_lock(&inode->i_lock);
 			set_nlink(inode, body->mbo_nlink);
+			spin_unlock(&inode->i_lock);
 			inode->i_atime.tv_sec = body->mbo_atime;
 			inode->i_ctime.tv_sec = body->mbo_ctime;
 			inode->i_mtime.tv_sec = body->mbo_mtime;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
