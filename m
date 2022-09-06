Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 80E89C6FA86
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:56:03 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7lR18bVz1yBR;
	Mon,  5 Sep 2022 18:56:03 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7lD1tWvz1y6t
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:52 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id CEB17100B009;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C8A3358992; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:27 -0400
Message-Id: <1662429337-18737-15-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
References: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 14/24] lustre: llite: Unify range unlock
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

From: Patrick Farrell <pfarrell@whamcloud.com>

Correct parallel_dio condition and unify range unlock code
block.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15811
Lustre-commit: 36c34af60767bd5da ("LU-15811 llite: Unify range unlock")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/48000
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 92e450f..8152821 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1750,20 +1750,12 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 		ll_cl_add(inode, env, io, LCC_RW);
 		rc = cl_io_loop(env, io);
 		ll_cl_remove(inode, env);
-
-		if (range_locked && !is_parallel_dio) {
-			CDEBUG(D_VFSTRACE, "Range unlock [%llu, %llu]\n",
-			       range.rl_start,
-			       range.rl_last);
-			range_unlock(&lli->lli_write_tree, &range);
-			range_locked = false;
-		}
 	} else {
 		/* cl_io_rw_init() handled IO */
 		rc = io->ci_result;
 	}
 
-	if (is_parallel_dio) {
+	if (io->ci_dio_aio && !is_aio) {
 		struct cl_sync_io *anchor = &io->ci_dio_aio->cda_sync;
 
 		/* for dio, EIOCBQUEUED is an implementation detail,
@@ -1780,11 +1772,14 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 		rc2 = cl_sync_io_wait_recycle(env, anchor, 0, 0);
 		if (rc2 < 0)
 			rc = rc2;
+	}
 
-		if (range_locked) {
-			range_unlock(&lli->lli_write_tree, &range);
-			range_locked = false;
-		}
+	if (range_locked) {
+		CDEBUG(D_VFSTRACE, "Range lock [%llu, %llu]\n",
+		       range.rl_start,
+		       range.rl_last);
+		range_unlock(&lli->lli_write_tree, &range);
+		range_locked = false;
 	}
 
 	/*
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
