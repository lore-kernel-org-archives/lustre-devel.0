Return-Path: <SRS0=0agL=O7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67F8BC433EF
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:20 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0C97E60EBB
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 0C97E60EBB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 883C2380EC3;
	Mon, 11 Oct 2021 10:41:07 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A4D0B21FDCE
 for <lustre-devel@lists.lustre.org>; Mon, 11 Oct 2021 10:40:57 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id C92FE475;
 Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C7E72D5A44; Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 11 Oct 2021 13:40:44 -0400
Message-Id: <1633974049-26490-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
References: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/20] lustre: osc: use original cli for
 osc_lru_reclaim for debug msg
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

Before the list cleanup introduced in osc_lru_reclaim() the
variable cli was both passed in and used to scan the
cl_client_cache. After the scan was done then we use cli in
a debug message. It appears to be the original intent was to
use the original cli passed in for the debug message, not the
last scanned item. After the list cleanup patch landed now
cli can be NULL which can crash the node. The fix is to use
a separate struct client_obd variable for the scan and use
the original cli passed in for the debug message.

Fixes: ce96138f3692 ("lustre: use list_first_entry() in lustre subdirectory.")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15013
Lustre-commit: 3c6a1e94c652685fac7c ("LU-15013 osc: use original cli for osc_lru_reclaim for debug msg")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/44966
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/osc/osc_page.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index d471df2..cba5d02 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -696,6 +696,7 @@ static long osc_lru_reclaim(struct client_obd *cli, unsigned long npages)
 {
 	struct lu_env *env;
 	struct cl_client_cache *cache = cli->cl_cache;
+	struct client_obd *scan;
 	int max_scans;
 	u16 refcheck;
 	long rc = 0;
@@ -735,20 +736,20 @@ static long osc_lru_reclaim(struct client_obd *cli, unsigned long npages)
 
 	max_scans = refcount_read(&cache->ccc_users) - 2;
 	while (--max_scans > 0 &&
-	       (cli = list_first_entry_or_null(&cache->ccc_lru,
-					       struct client_obd,
-					       cl_lru_osc)) != NULL) {
+	       (scan = list_first_entry_or_null(&cache->ccc_lru,
+						struct client_obd,
+						cl_lru_osc)) != NULL) {
 
 		CDEBUG(D_CACHE, "%s: cli %p LRU pages: %ld, busy: %ld.\n",
-		       cli_name(cli), cli,
-		       atomic_long_read(&cli->cl_lru_in_list),
-		       atomic_long_read(&cli->cl_lru_busy));
+		       cli_name(scan), scan,
+		       atomic_long_read(&scan->cl_lru_in_list),
+		       atomic_long_read(&scan->cl_lru_busy));
 
-		list_move_tail(&cli->cl_lru_osc, &cache->ccc_lru);
-		if (osc_cache_too_much(cli) > 0) {
+		list_move_tail(&scan->cl_lru_osc, &cache->ccc_lru);
+		if (osc_cache_too_much(scan) > 0) {
 			spin_unlock(&cache->ccc_lru_lock);
 
-			rc = osc_lru_shrink(env, cli, npages, true);
+			rc = osc_lru_shrink(env, scan, npages, true);
 			spin_lock(&cache->ccc_lru_lock);
 			if (rc >= npages)
 				break;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
