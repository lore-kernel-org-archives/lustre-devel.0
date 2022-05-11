Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id CA1E0C433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 11 May 2022 19:39:01 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AB31C21C914;
	Wed, 11 May 2022 12:38:58 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D021E216163
 for <lustre-devel@lists.lustre.org>; Wed, 11 May 2022 12:38:47 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 8A61EED4;
 Wed, 11 May 2022 15:38:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 81C075894D; Wed, 11 May 2022 15:38:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>, Sebastien Buisson <sbuisson@ddn.com>
Date: Wed, 11 May 2022 15:38:40 -0400
Message-Id: <1652297923-16141-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1652297923-16141-1-git-send-email-jsimmons@infradead.org>
References: <1652297923-16141-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 2/5] lustre: obdclass: llog to handle gaps
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

due to old errors an update llog can contain gaps in index.
this shouldn't block llog processing and recovery. actual
gaps in transaction sequence should be catched by VBR.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15645
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/46837
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/llog.c | 25 +++++++++----------------
 1 file changed, 9 insertions(+), 16 deletions(-)

diff --git a/fs/lustre/obdclass/llog.c b/fs/lustre/obdclass/llog.c
index 768bc47..acede87 100644
--- a/fs/lustre/obdclass/llog.c
+++ b/fs/lustre/obdclass/llog.c
@@ -430,23 +430,16 @@ static int llog_process_thread(void *arg)
 				continue;
 			}
 
-			if (rec->lrh_index != index) {
-				/*
-				 * the last time we couldn't parse the block due
-				 * to corruption, thus has no idea about the
-				 * next index, take it from the block, once.
+			if (rec->lrh_index > index) {
+				/* the record itself looks good, but we met a
+				 * gap which can be result of old bugs, just
+				 * keep going
 				 */
-				if (refresh_idx) {
-					refresh_idx = false;
-					index = rec->lrh_index;
-				} else {
-					CERROR("%s: "DFID" Invalid record: index %u but expected %u\n",
-					       loghandle2name(loghandle),
-					       PFID(&loghandle->lgh_id.lgl_oi.oi_fid),
-					       rec->lrh_index, index);
-					rc = -ERANGE;
-					goto out;
-				}
+				CERROR("%s: "DFID" index %u, expected %u\n",
+				       loghandle2name(loghandle),
+				       PFID(&loghandle->lgh_id.lgl_oi.oi_fid),
+				       rec->lrh_index, index);
+				index = rec->lrh_index;
 			}
 
 			CDEBUG(D_OTHER,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
