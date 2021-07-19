Return-Path: <SRS0=HxeM=ML=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B16BC07E9B
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:33:07 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id CF51E6113B
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:33:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF51E6113B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 52BCF34FA13;
	Mon, 19 Jul 2021 05:32:42 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D761B34F976
 for <lustre-devel@lists.lustre.org>; Mon, 19 Jul 2021 05:32:20 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id B0D306D3;
 Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id AF3B1BD; Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 19 Jul 2021 08:32:10 -0400
Message-Id: <1626697933-6971-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
References: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/18] lustre: llite: reset pfid after dir
 migration
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

A plain directory will be turned into to a stripe upon
migration/restripe, and reversely if target is plain directory, the
target stripe will be turned into directory after.

In the first case, set pfid, and in the latter case, clear pfid,
otherwise ll_lock_cancel_bits() will use the wrong master inode.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14459
Lustre-commit: abbe545a63b304e80 ("LU-14459 llite: reset pfid after dir migration")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/43289
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 10a9a95..88a1d17 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1401,10 +1401,12 @@ static struct inode *ll_iget_anon_dir(struct super_block *sb,
 				      struct lustre_md *md)
 {
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
+	struct ll_inode_info *lli;
 	struct mdt_body *body = md->body;
 	struct inode *inode;
 	ino_t ino;
 
+	LASSERT(md->lmv);
 	ino = cl_fid_build_ino(fid, sbi->ll_flags & LL_SBI_32BIT_API);
 	inode = iget_locked(sb, ino);
 	if (!inode) {
@@ -1413,10 +1415,8 @@ static struct inode *ll_iget_anon_dir(struct super_block *sb,
 		return ERR_PTR(-ENOENT);
 	}
 
+	lli = ll_i2info(inode);
 	if (inode->i_state & I_NEW) {
-		struct ll_inode_info *lli = ll_i2info(inode);
-		struct lmv_stripe_md *lsm = md->lmv;
-
 		inode->i_mode = (inode->i_mode & ~S_IFMT) |
 				(body->mbo_mode & S_IFMT);
 		LASSERTF(S_ISDIR(inode->i_mode), "Not slave inode " DFID "\n",
@@ -1432,12 +1432,17 @@ static struct inode *ll_iget_anon_dir(struct super_block *sb,
 		lli->lli_fid = *fid;
 		ll_lli_init(lli);
 
-		LASSERT(lsm);
 		/* master object FID */
 		lli->lli_pfid = body->mbo_fid1;
 		CDEBUG(D_INODE, "lli %p slave " DFID " master " DFID "\n",
 		       lli, PFID(fid), PFID(&lli->lli_pfid));
 		unlock_new_inode(inode);
+	} else {
+		/* in directory restripe/auto-split, a directory will be
+		 * transformed to a stripe if it's plain, set its pfid here,
+		 * otherwise ll_lock_cancel_bits() can't find the master inode.
+		 */
+		lli->lli_pfid = body->mbo_fid1;
 	}
 
 	return inode;
@@ -1547,6 +1552,12 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 	if (md->default_lmv)
 		ll_update_default_lsm_md(inode, md);
 
+	/* after dir migration/restripe, a stripe may be turned into a
+	 * directory, in this case, zero out its lli_pfid.
+	 */
+	if (unlikely(fid_is_norm(&lli->lli_pfid)))
+		fid_zero(&lli->lli_pfid);
+
 	/*
 	 * no striped information from request, lustre_md from req does not
 	 * include stripeEA, see ll_md_setattr()
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
