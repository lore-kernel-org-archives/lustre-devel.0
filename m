Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 37E9FC433F5
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:39:02 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id F37CB3AD921;
	Thu, 13 Jan 2022 17:38:45 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9344C3AD7BC
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:12 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 017F7100F34B;
 Thu, 13 Jan 2022 20:38:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id F3238DF4C4; Thu, 13 Jan 2022 20:38:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:38:00 -0500
Message-Id: <1642124283-10148-22-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
References: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 21/24] lustre: llite: revalidate dentry if
 LOOKUP lock fetched
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

Once ll_inode_revalidate() fetches LOOKUP lock, it should revalidate
dentry, so subsequent lookup can find it in dcache.

It should also update lli_dir_depth.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15200
Lustre-commit: 92fadf9cc1d06b21b ("LU-15200 llite: revalidate dentry if LOOKUP lock fetched")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45599
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dcache.c         | 19 +++++++++++++++++--
 fs/lustre/llite/file.c           |  2 +-
 fs/lustre/llite/llite_internal.h |  2 +-
 3 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/dcache.c b/fs/lustre/llite/dcache.c
index a074a2c..d9fb0cd 100644
--- a/fs/lustre/llite/dcache.c
+++ b/fs/lustre/llite/dcache.c
@@ -200,15 +200,30 @@ void ll_prune_aliases(struct inode *inode)
 
 int ll_revalidate_it_finish(struct ptlrpc_request *request,
 			    struct lookup_intent *it,
-			    struct inode *inode)
+			    struct dentry *de)
 {
+	struct inode *inode = d_inode(de);
+	u64 bits = 0;
+	int rc;
+
 	if (!request)
 		return 0;
 
 	if (it_disposition(it, DISP_LOOKUP_NEG))
 		return -ENOENT;
 
-	return ll_prep_inode(&inode, &request->rq_pill, NULL, it);
+	rc = ll_prep_inode(&inode, &request->rq_pill, NULL, it);
+	if (rc)
+		return rc;
+
+	ll_set_lock_data(ll_i2sbi(inode)->ll_md_exp, inode, it,
+			 &bits);
+	if (bits & MDS_INODELOCK_LOOKUP) {
+		ll_update_dir_depth(de->d_parent->d_inode, inode);
+		d_lustre_revalidate(de);
+	}
+
+	return rc;
 }
 
 void ll_lookup_finish_locks(struct lookup_intent *it, struct inode *inode)
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index dec0109..d9b1457 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -5033,7 +5033,7 @@ static int ll_inode_revalidate(struct dentry *dentry, enum ldlm_intent_flags op)
 		goto out;
 	}
 
-	rc = ll_revalidate_it_finish(req, &oit, inode);
+	rc = ll_revalidate_it_finish(req, &oit, dentry);
 	if (rc != 0) {
 		ll_intent_release(&oit);
 		goto out;
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 8c7361a..dd338f2 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1177,7 +1177,7 @@ int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
 void ll_prune_aliases(struct inode *inode);
 void ll_lookup_finish_locks(struct lookup_intent *it, struct inode *inode);
 int ll_revalidate_it_finish(struct ptlrpc_request *request,
-			    struct lookup_intent *it, struct inode *inode);
+			    struct lookup_intent *it, struct dentry *de);
 
 /* llite/llite_lib.c */
 extern const struct super_operations lustre_super_operations;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
