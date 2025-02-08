Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 1C8B5C02199
	for <lustre-devel@archiver.kernel.org>; Sat,  8 Feb 2025 00:37:40 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YqWwV6j9mz1y7B;
	Fri, 07 Feb 2025 16:31:06 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YqWw74PrZz1xf6
 for <lustre-devel@lists.lustre.org>; Fri, 07 Feb 2025 16:30:47 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm2-e204-208.ccs.ornl.gov [160.91.203.3])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 27D80182337;
 Fri,  7 Feb 2025 19:30:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 26B7B106BE17; Fri,  7 Feb 2025 19:30:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri,  7 Feb 2025 19:30:24 -0500
Message-ID: <20250208003027.180076-19-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250208003027.180076-1-jsimmons@infradead.org>
References: <20250208003027.180076-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 18/21] lustre: osc: Add debug
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <pfarrell@whamcloud.com>

This adds some minor additional debug for unaligned IO.

The purpose here is just to shorten the length of the
main patch by pulling out supporting bits.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13805
Lustre-commit: 6d1045d63a5bf33a1 ("LU-13805 osc: Add debug")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49988
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_page.c    |  2 ++
 fs/lustre/osc/osc_request.c | 13 +++++++++----
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index d4b3baf227b6..c428c3626676 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -201,6 +201,8 @@ static void osc_page_clip(const struct lu_env *env,
 	struct osc_page *opg = cl2osc_page(slice);
 	struct osc_async_page *oap = &opg->ops_oap;
 
+	CDEBUG(D_CACHE, "from %d, to %d\n", from, to);
+
 	opg->ops_from = from;
 	/* argument @to is exclusive, but @ops_to is inclusive */
 	opg->ops_to = to - 1;
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 3298a9923ea2..5c9f93b91609 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -2737,16 +2737,21 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 
 			list_add_tail(&oap->oap_rpc_item, &rpc_list);
 			if (starting_offset == OBD_OBJECT_EOF ||
-			    starting_offset > oap->oap_obj_off)
+			    starting_offset > oap->oap_obj_off) {
 				starting_offset = oap->oap_obj_off;
-			else
+			} else {
+				CDEBUG(D_CACHE,
+				       "page i:%d, oap->oap_obj_off %llu, oap->oap_page_off %u\n",
+				       i, oap->oap_obj_off, oap->oap_page_off);
 				LASSERT(!oap->oap_page_off);
-			if (ending_offset < oap->oap_obj_off + oap->oap_count)
+			}
+			if (ending_offset < oap->oap_obj_off + oap->oap_count) {
 				ending_offset = oap->oap_obj_off +
 						oap->oap_count;
-			else
+			} else {
 				LASSERT(oap->oap_page_off + oap->oap_count ==
 					PAGE_SIZE);
+			}
 		}
 		if (ext->oe_ndelay)
 			ndelay = true;
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
