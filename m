Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8D110C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 28 Nov 2021 23:28:45 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1BA6B200DEA;
	Sun, 28 Nov 2021 15:28:28 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 73384200F3F
 for <lustre-devel@lists.lustre.org>; Sun, 28 Nov 2021 15:28:02 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id B0CC8264;
 Sun, 28 Nov 2021 18:27:56 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id AD60FC1ACE; Sun, 28 Nov 2021 18:27:56 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 28 Nov 2021 18:27:48 -0500
Message-Id: <1638142074-5945-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
References: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/19] lustre: quota: optimize capability
 check for root squash
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

From: Sebastien Buisson <sbuisson@ddn.com>

On client side, checking for owner/group quota can be directly
bypassed if this is for root and there is no root squash.

Fixes: cd633cfc96 ("lustre: quota: nodemap squashed root cannot bypass quota")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15141
Lustre-commit: f5fd5a363cc48e38c ("LU-15141 quota: optimize capability check for root squash")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/45322
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_cache.c | 23 ++++++++---------------
 1 file changed, 8 insertions(+), 15 deletions(-)

diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 1211438..7b7b49f 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2385,7 +2385,12 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 	}
 
 	/* check if the file's owner/group is over quota */
-	if (!io->ci_noquota) {
+	/* do not check for root without root squash, because in this case
+	 * we should bypass quota
+	 */
+	if ((!oio->oi_cap_sys_resource ||
+	     cli->cl_root_squash) &&
+	    !io->ci_noquota) {
 		struct cl_object *obj;
 		struct cl_attr *attr;
 		unsigned int qid[MAXQUOTAS];
@@ -2400,20 +2405,8 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 		qid[USRQUOTA] = attr->cat_uid;
 		qid[GRPQUOTA] = attr->cat_gid;
 		qid[PRJQUOTA] = attr->cat_projid;
-		/*
-		 * if EDQUOT returned for root, we double check
-		 * if root squash enabled or not updated from server side.
-		 * without root squash, we should bypass quota for root.
-		 */
-		if (rc == 0 && osc_quota_chkdq(cli, qid) == -EDQUOT) {
-			if (oio->oi_cap_sys_resource &&
-			    !cli->cl_root_squash) {
-				io->ci_noquota = 1;
-				rc = 0;
-			} else {
-				rc = -EDQUOT;
-			}
-		}
+		if (rc == 0 && osc_quota_chkdq(cli, qid) == -EDQUOT)
+			rc = -EDQUOT;
 		if (rc)
 			return rc;
 	}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
