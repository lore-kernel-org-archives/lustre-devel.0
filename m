Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95CA8C4338F
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:32 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5137260F36
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 5137260F36
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id F12F0352E3D;
	Mon,  2 Aug 2021 12:51:22 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D3C9C352B7B
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:50:58 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 73C471008050;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 7246FC2F50; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:35 -0400
Message-Id: <1627933851-7603-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
References: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/25] lustre: osc: Improve
 osc_queue_sync_pages
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

This patch was split and partially done in:
https://review.whamcloud.com/38214

So the text below refers to the combination of this patch
and that one.  This patch now just improves a looped atomic
add by replacing with a single one.  The rest of the grant
calcuation change is in
https://review.whamcloud.com/38214

(I am retaining the text below to show the performance
 improvement)
----------
osc_queue_sync_pages now has a grant calculation component,
this has a pretty painful impact on the new faster DIO
performance.  Specifically, per page ktime_get() and the
per-page atomic_add cost close to 10% of total CPU time in
the DIO path.

We can make this per batch of pages rather than for each
page, which reduces this cost from 10% of CPU to almost
nothing.

This improves write performance by about 10% (but has no
effect on reads, since they don't use grant).

This patch reduces i/o time in ms/GiB by:
Write: 10 ms/GiB
Read: 0 ms/GiB

Totals:
Write: 158 ms/GiB
Read: 161 ms/GiB

mpirun -np 1 $IOR -w -t 1G -b 64G -o $FILE --posix.odirect

Before patch:
write     6071

After patch:
write     6470

(Read is similar.)

This also fixes a mistake in d23d4cb67c / LU-13419 where it
removed the shrink interval update entirely from the direct
i/o path.

Fixes: d23d4cb67c ("lustre: osc: Move shrink update to per-write")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13419
Lustre-commit: 87c4535f7a5d239a ("LU-13799 osc: Improve osc_queue_sync_pages")
Signed-off-by: Patrick Farrell <farr0186@gmail.com>
Reviewed-on: https://review.whamcloud.com/39482
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_cache.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 50f6477..69cf9ba 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2715,8 +2715,8 @@ int osc_queue_sync_pages(const struct lu_env *env, struct cl_io *io,
 			list_for_each_entry(oap, list, oap_pending_item) {
 				osc_consume_write_grant(cli,
 							&oap->oap_brw_page);
-				atomic_long_inc(&obd_dirty_pages);
 			}
+			atomic_long_add(page_count, &obd_dirty_pages);
 			osc_unreserve_grant_nolock(cli, grants, 0);
 			ext->oe_grants = grants;
 		} else {
@@ -2730,6 +2730,7 @@ int osc_queue_sync_pages(const struct lu_env *env, struct cl_io *io,
 			"not enough grant available, switching to sync for this i/o\n");
 		}
 		spin_unlock(&cli->cl_loi_list_lock);
+		osc_update_next_shrink(cli);
 	}
 
 	ext->oe_is_rdma_only = !!(brw_flags & OBD_BRW_RDMA_ONLY);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
