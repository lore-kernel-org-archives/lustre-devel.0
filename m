Return-Path: <SRS0=27wn=LH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F52FC49360
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:21 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id DDD6D611CA
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDD6D611CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7CD2421F5EA;
	Sun, 13 Jun 2021 16:12:04 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 836AC21CB16
 for <lustre-devel@lists.lustre.org>; Sun, 13 Jun 2021 16:11:42 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B9152100B030;
 Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id AC4EA9C316; Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 13 Jun 2021 19:11:15 -0400
Message-Id: <1623625897-17706-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
References: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/27] lustre: llite: default lsm update may
 memory leak
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

ll_update_default_lsm_md() should check whether lli_default_lsm_md
is set before setting it to the data from lustre_md, and if it's set,
release the old data to avoid memory leak

WC-bug-id: https://jira.whamcloud.com/browse/LU-14004
Lustre-commit: cd2ad336177f8f31 ("LU-14004 llite: default lsm update may memory leak")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40103
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c | 35 ++++++++++++++++-------------------
 1 file changed, 16 insertions(+), 19 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 39bdee0..e98972d 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1505,30 +1505,27 @@ static void ll_update_default_lsm_md(struct inode *inode, struct lustre_md *md)
 			}
 			up_write(&lli->lli_lsm_sem);
 		}
-	} else if (lli->lli_default_lsm_md) {
-		/* update default lsm if it changes */
+		return;
+	}
+
+	if (lli->lli_default_lsm_md) {
+		/* do nonthing if default lsm isn't changed */
 		down_read(&lli->lli_lsm_sem);
 		if (lli->lli_default_lsm_md &&
-		    !lsm_md_eq(lli->lli_default_lsm_md, md->default_lmv)) {
-			up_read(&lli->lli_lsm_sem);
-			down_write(&lli->lli_lsm_sem);
-			if (lli->lli_default_lsm_md)
-				lmv_free_memmd(lli->lli_default_lsm_md);
-			lli->lli_default_lsm_md = md->default_lmv;
-			lsm_md_dump(D_INODE, md->default_lmv);
-			md->default_lmv = NULL;
-			up_write(&lli->lli_lsm_sem);
-		} else {
+		    lsm_md_eq(lli->lli_default_lsm_md, md->default_lmv)) {
 			up_read(&lli->lli_lsm_sem);
+			return;
 		}
-	} else {
-		/* init default lsm */
-		down_write(&lli->lli_lsm_sem);
-		lli->lli_default_lsm_md = md->default_lmv;
-		lsm_md_dump(D_INODE, md->default_lmv);
-		md->default_lmv = NULL;
-		up_write(&lli->lli_lsm_sem);
+		up_read(&lli->lli_lsm_sem);
 	}
+
+	down_write(&lli->lli_lsm_sem);
+	if (lli->lli_default_lsm_md)
+		lmv_free_memmd(lli->lli_default_lsm_md);
+	lli->lli_default_lsm_md = md->default_lmv;
+	lsm_md_dump(D_INODE, md->default_lmv);
+	md->default_lmv = NULL;
+	up_write(&lli->lli_lsm_sem);
 }
 
 static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
