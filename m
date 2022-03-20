Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 20BADC433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:32:49 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C751A21FA03;
	Sun, 20 Mar 2022 06:32:03 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 03E7121F9D5
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:23 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id A44B01031;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A23CFD6A26; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:31:04 -0400
Message-Id: <1647783064-20688-51-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 50/50] lustre: ptlrpc: Use after free of
 'conn' in rhashtable retry
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
Cc: Shaun Tancheff <shaun.tancheff@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Shaun Tancheff <shaun.tancheff@hpe.com>

Use after free of 'conn' in the uncommon case of
rhashtable_lookup_get_insert_fast failing with -EBUSY or -ENOMEM

Move kfree(conn) below the retry and set conn2 to NULL
on error, propagating to conn and returning to the caller.

HPE-bug-id: LUS-10776
Fixes: ac2370ac2b ("staging: lustre: ptlrpc: convert conn_hash to rhashtable");
WC-bug-id: https://jira.whamcloud.com/browse/LU-15634
Lustre-commit: 9dcbf8b3d44f9bb2b ("LU-15634 ptlrpc: Use after free of 'conn' in rhashtable retry")
Signed-off-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-on: https://review.whamcloud.com/46763
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/connection.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/ptlrpc/connection.c b/fs/lustre/ptlrpc/connection.c
index 8dbaea40..d1f53c6 100644
--- a/fs/lustre/ptlrpc/connection.c
+++ b/fs/lustre/ptlrpc/connection.c
@@ -119,10 +119,12 @@ struct ptlrpc_connection *
 				msleep(20);
 				goto try_again;
 			}
-			return NULL;
+			conn2 = NULL;
 		}
+		kfree(conn);
 		conn = conn2;
-		ptlrpc_connection_addref(conn);
+		if (conn)
+			ptlrpc_connection_addref(conn);
 	}
 out:
 	CDEBUG(D_INFO, "conn=%p refcount %d to %s\n",
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
