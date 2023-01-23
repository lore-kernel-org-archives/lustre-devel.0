Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 71678C25B50
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:18:36 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15Md1VpHz21KB;
	Mon, 23 Jan 2023 15:06:53 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15K04YpZz219y
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:04:36 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 5349D8EF;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 504B658991; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:28 -0500
Message-Id: <1674514855-15399-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/42] lustre: ptlrpc: Add LCME_FL_PARITY to
 wirecheck
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
Cc: Shaun Tancheff <shaun.tancheff@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Shaun Tancheff <shaun.tancheff@hpe.com>

- LCME_FL_PARITY should be included in wiretest

Fixes: 9eafb96659 ("lustre: ec: add necessary structure member for EC file")
WC-bug-id: https://jira.whamcloud.com/browse/LU-16366
Lustre-commit: dce487f53a6f78355 ("LU-16366 build: Add LCME_FL_PARITY to wirecheck")
Signed-off-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49311
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/wiretest.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index bf12435262d4..372dc1014878 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1678,6 +1678,7 @@ void lustre_assert_wire_constants(void)
 	BUILD_BUG_ON(LCME_FL_INIT != 0x00000010);
 	BUILD_BUG_ON(LCME_FL_NOSYNC != 0x00000020);
 	BUILD_BUG_ON(LCME_FL_EXTENSION != 0x00000040);
+	BUILD_BUG_ON(LCME_FL_PARITY != 0x00000080);
 	BUILD_BUG_ON(LCME_FL_NEG != 0x80000000);
 
 	/* Checks for struct lov_comp_md_v1 */
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
