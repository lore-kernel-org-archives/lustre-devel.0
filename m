Return-Path: <SRS0=0agL=O7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C04DC433FE
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:00 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A275D60EB6
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:40:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org A275D60EB6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A55BC380B75;
	Mon, 11 Oct 2021 10:40:58 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AC78821FB84
 for <lustre-devel@lists.lustre.org>; Mon, 11 Oct 2021 10:40:53 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id A4D27258;
 Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9B7ACA9502; Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 11 Oct 2021 13:40:30 -0400
Message-Id: <1633974049-26490-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
References: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/20] lustre: nfs: don't store parent fid
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

It's not necessary to store parent fid in lli_pfid, because MDT
can get it's parent fid from linkea, and now that DNE stripe
directory stores master inode fid in lli_pfid, stop storing parent
fid to avoid conflict.

WC-bug-id: https://jira.whamcloud.com/browse/LU-3544
Lustre-commit: 6512bfc74b152ef ("LU-3544 nfs: don't store parent fid")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: http://review.whamcloud.com/10692
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: wangdi <di.wang@intel.com>
Reviewed-by: Nathaniel Clark <nclark@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_nfs.c | 13 -------------
 1 file changed, 13 deletions(-)

diff --git a/fs/lustre/llite/llite_nfs.c b/fs/lustre/llite/llite_nfs.c
index 6be2309..07fcad6 100644
--- a/fs/lustre/llite/llite_nfs.c
+++ b/fs/lustre/llite/llite_nfs.c
@@ -135,19 +135,6 @@ struct inode *search_inode_for_lustre(struct super_block *sb,
 	if (IS_ERR(result))
 		return result;
 
-	/**
-	 * In case d_obtain_alias() found a disconnected dentry, always update
-	 * lli_pfid to allow later operation (normally open) have parent fid,
-	 * which may be used by MDS to create data.
-	 */
-	if (parent) {
-		struct ll_inode_info *lli = ll_i2info(inode);
-
-		spin_lock(&lli->lli_lock);
-		lli->lli_pfid = *parent;
-		spin_unlock(&lli->lli_lock);
-	}
-
 	/*
 	 * Need to signal to the ll_intent_file_open that
 	 * we came from NFS and so opencache needs to be
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
