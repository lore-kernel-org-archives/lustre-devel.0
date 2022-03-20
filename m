Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3738DC433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:32:02 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 45BCD21CA7C;
	Sun, 20 Mar 2022 06:31:40 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1AC4C21CBD9
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:21 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 88E1A1026;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 86647D5A47; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:57 -0400
Message-Id: <1647783064-20688-44-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 43/50] lustre: llite: clear async errors on
 write commit sync
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
Cc: Vladimir Saveliev <vlaidimir.saveliev@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Vladimir Saveliev <vlaidimir.saveliev@hpe.com>

Async errors should be cleared after vvp_io_commit_sync(). Otherwise,
that will be done in ll_flush() called from
linux/fs/open.c:filp_close() and close(2) will fail. ll_flush()
replaces any error code with EIO which is confusing.

HPE-bug-id: LUS-7529
WC-bug-id: https://jira.whamcloud.com/browse/LU-15459
Lustre-commit: 73d5ee7033d0bd7dc ("LU-15459 llite: clear async errors on write commit sync")
Signed-off-by: Vladimir Saveliev <vlaidimir.saveliev@hpe.com>
Reviewed-on: https://review.whamcloud.com/46178
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Andrew Perepechko <andrew.perepechko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/vvp_io.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 40047f8..77e54ce 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -1109,6 +1109,8 @@ int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io)
 
 	/* out of quota, try sync write */
 	if (rc == -EDQUOT && !cl_io_is_mkwrite(io)) {
+		struct ll_inode_info *lli = ll_i2info(inode);
+
 		rc = vvp_io_commit_sync(env, io, queue,
 					vio->u.readwrite.vui_from,
 					vio->u.readwrite.vui_to);
@@ -1116,6 +1118,9 @@ int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io)
 			vio->u.readwrite.vui_written += rc;
 			rc = 0;
 		}
+		if (lli->lli_clob)
+			lov_read_and_clear_async_rc(lli->lli_clob);
+		lli->lli_async_rc = 0;
 	}
 
 	/* update inode size */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
