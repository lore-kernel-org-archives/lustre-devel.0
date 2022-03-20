Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8BB8CC433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:32:42 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A6ED521CAD9;
	Sun, 20 Mar 2022 06:32:00 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6656E21CB93
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:20 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 7DF36EFF;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 7ACA6AB; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:54 -0400
Message-Id: <1647783064-20688-41-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 40/50] lustre: osc: osc_extent_wait() deadlock
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
Cc: Andriy Skulysh <andriy.skulysh@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andriy Skulysh <andriy.skulysh@hpe.com>

Thread 1:
vvp_io_write_commit
osc_io_commit_async
osc_page_cache_add
osc_extent_find
osc_extent_wait

Thread 2:
ptlrpcd_check
ptlrpc_check_set
brw_queue_work
osc_extent_make_ready
vvp_page_make_ready_start
__lock_page

We must not hold a page lock while we do osc_extent_find()

HPE-bug-id: LUS-10414
Fixes: f8a5fb036a ("lustre: vvp: dirty pages with pagevec")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15477
Lustre-commit: 821a8d7b481d34a54 ("LU-15477 osc: osc_extent_wait() deadlock")
Signed-off-by: Andriy Skulysh <andriy.skulysh@hpe.com>
Reviewed-on: https://review.whamcloud.com/46281
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_cache.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 7bd28c5..072cfac 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2487,16 +2487,17 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 		LASSERT(ergo(grants > 0, grants >= tmp));
 
 		rc = 0;
+
+		/* We must not hold a page lock while we do osc_enter_cache()
+		 * or osc_extent_find(), so we must mark dirty & unlock
+		 * any pages in the write commit pagevec.
+		 */
+		if (pagevec_count(pvec)) {
+			cb(env, io, pvec);
+			pagevec_reinit(pvec);
+		}
+
 		if (grants == 0) {
-			/* We haven't allocated grant for this page, and we
-			 * must not hold a page lock while we do enter_cache,
-			 * so we must mark dirty & unlock any pages in the
-			 * write commit pagevec.
-			 */
-			if (pagevec_count(pvec)) {
-				cb(env, io, pvec);
-				pagevec_reinit(pvec);
-			}
 			rc = osc_enter_cache(env, cli, oap, tmp);
 			if (rc == 0)
 				grants = tmp;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
