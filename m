Return-Path: <SRS0=WSMT=J7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2BAFC433B4
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:10:39 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3184B610E6
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:10:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3184B610E6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C918B21F73A;
	Mon,  3 May 2021 17:10:31 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7E6AA21F3B4
 for <lustre-devel@lists.lustre.org>; Mon,  3 May 2021 17:10:23 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 288EEEE0;
 Mon,  3 May 2021 20:10:20 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1E84B8AD44; Mon,  3 May 2021 20:10:20 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  3 May 2021 20:10:07 -0400
Message-Id: <1620087016-17857-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
References: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/14] lnet: Router ping timeout with
 discovery disabled
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
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

Discovery pings are used to determine the health of gateways and
associated routes. Ping replies from gateways with dynamic discovery
(DD) disabled (or if DD is disabled locally) are handled in
a special routine, lnet_router_discovery_ping_reply(), but this
function and related code doesn't handle the case where a discovery
ping hits the response tracker timeout and is unlinked by the
monitor thread. In this case, an UNLINK event is generated and we
do not call the lnet_router_discovery_ping_reply(). For gateways
with DD enabled (and DD enabled locally), we handle this case
in lnet_router_discovery_complete(). If discovery failed then
lp_dc_error is set and we mark all routes down for the gateway. We
can simply extend this logic to the case of gateways w/DD disabled
(or DD disabled locally).

Fixes: dc80207e3a ("lnet: fix asym routing with multi-hop")
HPE-bug-id: LUS-9612
WC-bug-id: https://jira.whamcloud.com/browse/LU-14206
Lustre-commit: 173d86c6e9a704a8 ("LU-14206 lnet: Router ping timeout with discovery disabled")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/40923
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/router.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index ae7582ca..e179997 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -495,11 +495,11 @@ bool lnet_is_route_alive(struct lnet_route *route)
 	lp->lp_alive = lp->lp_dc_error == 0;
 	spin_unlock(&lp->lp_lock);
 
-	/* ping replies are being handled when discovery is disabled */
-	if (lnet_is_discovery_disabled_locked(lp))
-		return;
-
 	if (!lp->lp_dc_error) {
+		/* ping replies are being handled when discovery is disabled */
+		if (lnet_is_discovery_disabled_locked(lp))
+			return;
+
 		/* mark single-hop routes. If the remote net is not configured
 		 * on the gateway we assume this is intentional and we mark the
 		 * gateway as multi-hop
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
