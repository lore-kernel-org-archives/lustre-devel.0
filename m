Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E7E38C433FE
	for <lustre-devel@archiver.kernel.org>; Sun, 28 Nov 2021 23:28:29 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 81F0620573A;
	Sun, 28 Nov 2021 15:28:17 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B4833200E02
 for <lustre-devel@lists.lustre.org>; Sun, 28 Nov 2021 15:28:00 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 95CF1246;
 Sun, 28 Nov 2021 18:27:56 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 88D63C1AEC; Sun, 28 Nov 2021 18:27:56 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 28 Nov 2021 18:27:40 -0500
Message-Id: <1638142074-5945-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
References: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/19] lnet: libcfs: add timeout to
 cfs_race() to fix race
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

From: Alex Zhuravlev <bzzz@whamcloud.com>

there is no guarantee for the branches in cfs_race() to be executed
in strict order, thus it's possible that the second branch (with
cfs_race_state=1) is executed before the first branch and then another
thread executing the first branch gets stuck.

this construction is used for testing only and as a
workaround it's enough to timeout.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13358
Lustre-commit: 2d2d381f35ee00431 ("LU-13358 libcfs: add timeout to cfs_race() to fix race")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/43161
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/libcfs/libcfs_fail.h | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/libcfs/libcfs_fail.h b/include/linux/libcfs/libcfs_fail.h
index 45166c5..731401b 100644
--- a/include/linux/libcfs/libcfs_fail.h
+++ b/include/linux/libcfs/libcfs_fail.h
@@ -213,8 +213,14 @@ static inline void cfs_race_wait(u32 id)
 
 			cfs_race_state = 0;
 			CERROR("cfs_race id %x sleeping\n", id);
-			rc = wait_event_interruptible(cfs_race_waitq,
-						      cfs_race_state != 0);
+			/*
+			 * XXX: don't wait forever as there is no guarantee
+			 * that this branch is executed first. for testing
+			 * purposes this construction works good enough
+			 */
+			rc = wait_event_interruptible_timeout(cfs_race_waitq,
+							      cfs_race_state != 0,
+							      5 * HZ);
 			CERROR("cfs_fail_race id %x awake: rc=%d\n", id, rc);
 		}
 	}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
