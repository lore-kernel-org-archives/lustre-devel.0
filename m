Return-Path: <SRS0=JyPa=L7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE31EC07E95
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:12:11 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8507B61A13
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:12:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8507B61A13
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1F78D338AA6;
	Wed,  7 Jul 2021 12:11:53 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4117721F888
 for <lustre-devel@lists.lustre.org>; Wed,  7 Jul 2021 12:11:20 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 3C2B610090E4;
 Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 33B339D8BA; Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  7 Jul 2021 15:11:03 -0400
Message-Id: <1625685076-1964-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
References: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/15] lustre: osc: Move shrink update to
 per-write
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
Cc: Patrick Farrell <farr0186@gmail.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <farr0186@gmail.com>

Updating the grant shrink interval is currently done for
each page submitted, rather than once per write.  Since
the grant shrink interval is in seconds, this is
unnecessary.

This came up because this function showed up in the perf
traces for https://review.whamcloud.com/#/c/38151/, and
it is called with the cl_loi_list_lock held.

Note that this change makes this access to the grant shrink
interval a 'dirty' access, without locking, but the grant
shrink interval is:
A) Already accessed like this in various places, and
B) can safely be out of date or suffer a lost update
without affecting correctness or performance.

IOR performance testing with this test:
mpirun -np 36 $IOR -o $LUSTRE -w -t 1M -b 2G -i 1 -F

No patches:
5942 MiB/s
With 38151:
14950 MiB/s
With 38151+this:
15320 MiB/s

WC-bug-id: https://jira.whamcloud.com/browse/LU-13419
Lustre-commit: c24c25dc1b84912 ("LU-13419 osc: Move shrink update to per-write")
Signed-off-by: Patrick Farrell <farr0186@gmail.com>
Reviewed-on: https://review.whamcloud.com/38214
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_cache.c | 1 -
 fs/lustre/osc/osc_io.c    | 5 +++++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 321e9d9..0f0daa1 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -1426,7 +1426,6 @@ static void osc_consume_write_grant(struct client_obd *cli,
 	pga->flag |= OBD_BRW_FROM_GRANT;
 	CDEBUG(D_CACHE, "using %lu grant credits for brw %p page %p\n",
 	       PAGE_SIZE, pga, pga->pg);
-	osc_update_next_shrink(cli);
 }
 
 /* the companion to osc_consume_write_grant, called when a brw has completed.
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index de214ba..67fe85b 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -354,6 +354,11 @@ int osc_io_commit_async(const struct lu_env *env,
 			pagevec_reinit(pvec);
 		}
 	}
+	/* The shrink interval is in seconds, so we can update it once per
+	 * write, rather than once per page.
+	 */
+	osc_update_next_shrink(osc_cli(osc));
+
 
 	/* Clean up any partially full pagevecs */
 	if (pagevec_count(pvec) != 0)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
