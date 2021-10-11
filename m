Return-Path: <SRS0=0agL=O7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20C2AC433EF
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:58 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D766760EB6
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org D766760EB6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4F29F380C66;
	Mon, 11 Oct 2021 10:41:34 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5C35D21FDCE
 for <lustre-devel@lists.lustre.org>; Mon, 11 Oct 2021 10:40:56 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id BB383276;
 Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B862AD5A44; Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 11 Oct 2021 13:40:39 -0400
Message-Id: <1633974049-26490-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
References: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/20] lustre: osc: Do not attempt sending
 empty pages
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

From: Oleg Drokin <green@whamcloud.com>

Do not crash if trying to send a lock-prolonging emtpy read
to an old server, if the server does not support short reads.
Otherwise the client crashes when access the NULL page.

Fixes: 1febc3615e2b ("lustre: osc: Notify server if cache discard takes a long time")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14711
Lustre-commit: 1a409a3e6a7468597 ("LU-14711 osc: Do not attempt sending empty pages")
Signed-off-by: Oleg Drokin <green@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44654
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_request.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index def2ee7..e5b7453 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1567,6 +1567,12 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	    !imp_connect_shortio(cli->cl_import))
 		short_io_size = 0;
 
+	/* If this is an empty RPC to old server, just ignore it */
+	if (!short_io_size && !pga[0]->pg) {
+		ptlrpc_request_free(req);
+		return -ENODATA;
+	}
+
 	req_capsule_set_size(pill, &RMF_SHORT_IO, RCL_CLIENT,
 			     opc == OST_READ ? 0 : short_io_size);
 	if (opc == OST_READ)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
