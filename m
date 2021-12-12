Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 91B37C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 12 Dec 2021 15:09:02 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3D19E21F492;
	Sun, 12 Dec 2021 07:08:22 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B7B7E21CBFF
 for <lustre-devel@lists.lustre.org>; Sun, 12 Dec 2021 07:08:07 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B7FF810084CE;
 Sun, 12 Dec 2021 10:08:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id AC45CE080D; Sun, 12 Dec 2021 10:08:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 12 Dec 2021 10:07:55 -0500
Message-Id: <1639321683-22909-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1639321683-22909-1-git-send-email-jsimmons@infradead.org>
References: <1639321683-22909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/12] lustre: obdclass: make niduuid for
 lustre_stop_mgc() static
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

The process to create a proper string for niduuid can be made
simpler and avoid a memory allocation.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9325
Lustre-commit: 85b400b67b0d8d493 ("LU-9325 obdclass: make niduuid for lustre_stop_mgc() static")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/33617
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/obdclass/obd_mount.c | 25 ++++++++-----------------
 1 file changed, 8 insertions(+), 17 deletions(-)

diff --git a/fs/lustre/obdclass/obd_mount.c b/fs/lustre/obdclass/obd_mount.c
index 19684fb..58ca72d 100644
--- a/fs/lustre/obdclass/obd_mount.c
+++ b/fs/lustre/obdclass/obd_mount.c
@@ -431,8 +431,8 @@ static int lustre_stop_mgc(struct super_block *sb)
 {
 	struct lustre_sb_info *lsi = s2lsi(sb);
 	struct obd_device *obd;
-	char *niduuid = NULL, *ptr = NULL;
-	int i, rc = 0, len = 0;
+	char niduuid[MAX_OBD_NAME + 6], *ptr = NULL;
+	int i, rc = 0;
 
 	if (!lsi)
 		return -ENOENT;
@@ -467,24 +467,17 @@ static int lustre_stop_mgc(struct super_block *sb)
 			CDEBUG(D_MOUNT, "disconnect failed %d\n", rc);
 	}
 
-	/* Save the obdname for cleaning the nid uuids, which are obdname_XX */
-	len = strlen(obd->obd_name) + 6;
-	niduuid = kzalloc(len, GFP_NOFS);
-	if (niduuid) {
-		strcpy(niduuid, obd->obd_name);
-		ptr = niduuid + strlen(niduuid);
-	}
+	/*
+	 * Cache the obdname for cleaning the nid uuids, which are
+	 * obdname_XX before calling class_manual_cleanup
+	 */
+	strcpy(niduuid, obd->obd_name);
+	ptr = niduuid + strlen(niduuid);
 
 	rc = class_manual_cleanup(obd);
 	if (rc)
 		goto out;
 
-	/* Clean the nid uuids */
-	if (!niduuid) {
-		rc = -ENOMEM;
-		goto out;
-	}
-
 	for (i = 0; i < lsi->lsi_lmd->lmd_mgs_failnodes; i++) {
 		sprintf(ptr, "_%x", i);
 		rc = do_lcfg(LUSTRE_MGC_OBDNAME, 0, LCFG_DEL_UUID,
@@ -494,8 +487,6 @@ static int lustre_stop_mgc(struct super_block *sb)
 			       niduuid, rc);
 	}
 out:
-	kfree(niduuid);
-
 	/* class_import_put will get rid of the additional connections */
 	mutex_unlock(&mgc_start_lock);
 	return rc;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
