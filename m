Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 67F1AC433FE
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:33:42 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7B57F21FCE1;
	Sun, 20 Mar 2022 06:32:33 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D69F821CA7D
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:09 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id E75F4ED4;
 Sun, 20 Mar 2022 09:31:07 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D944BE4201; Sun, 20 Mar 2022 09:31:07 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:16 -0400
Message-Id: <1647783064-20688-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/50] lustre: osc: Fix grant test for ARM
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

If both OST and OSC support OBD_CONNECT_GRANT_PARAM, OST side will not
change client side claimed grant (a.k.a. o_grant_used) regardless of
the client page size. So no grant loss in this case.

Fixes: 4d8c38a8a882 ("lustre: grant: add support for OBD_CONNECT_GRANT_PARAM")
WC-bug-id: https://jira.whamcloud.com/browse/LU-11596
Lustre-commit: 7d3edce0650f0b66b ("LU-11596 osc: Fix and re-enable sanity grant test for ARM")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: Jian Yu <yujian@whamcloud.com>
Signed-off-by: Xinliang Liu <xinliang.liu@linaro.org>
Reviewed-on: https://review.whamcloud.com/40758
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/osc/osc_cache.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 7b7b49f..7bd28c5 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -905,11 +905,13 @@ int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
 
 	if (!sent) {
 		lost_grant = ext->oe_grants;
-	} else if (blocksize < PAGE_SIZE &&
+	} else if (cli->cl_ocd_grant_param == 0 &&
+		   blocksize < PAGE_SIZE &&
 		   last_count != PAGE_SIZE) {
-		/* For short writes we shouldn't count parts of pages that
-		 * span a whole chunk on the OST side, or our accounting goes
-		 * wrong.  Should match the code in filter_grant_check.
+		/* For short writes without OBD_CONNECT_GRANT support, we
+		 * shouldn't count parts of pages that span a whole chunk on
+		 * the OST side, or our accounting goes wrong. Should match
+		 * the code in tgt_grant_check.
 		 */
 		int offset = last_off & ~PAGE_MASK;
 		int count = last_count + (offset & (blocksize - 1));
@@ -1505,11 +1507,11 @@ static void osc_unreserve_grant(struct client_obd *cli,
  * used, we should return these grants to OST. There're two cases where grants
  * can be lost:
  * 1. truncate;
- * 2. blocksize at OST is less than PAGE_SIZE and a partial page was
- *    written. In this case OST may use less chunks to serve this partial
- *    write. OSTs don't actually know the page size on the client side. so
- *    clients have to calculate lost grant by the blocksize on the OST.
- *    See filter_grant_check() for details.
+ * 2. Without OBD_CONNECT_GRANT support and blocksize at OST is less than
+ *    PAGE_SIZE and a partial page was written. In this case OST may use less
+ *    chunks to serve this partial write. OSTs don't actually know the page
+ *    size on the client side. so clients have to calculate lost grant by the
+ *    blocksize on the OST. See tgt_grant_check() for details.
  */
 static void osc_free_grant(struct client_obd *cli, unsigned int nr_pages,
 			   unsigned int lost_grant, unsigned int dirty_grant)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
