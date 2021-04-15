Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97777C433B4
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:03 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 23BB7610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23BB7610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6CAC232F564;
	Wed, 14 Apr 2021 21:02:58 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1DF6132F3FA
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:49 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 5F9A5100F33A;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 5AA6191884; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:01 -0400
Message-Id: <1618459361-17909-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 09/49] lustre: llite: update and fix module
 loading bug in mounting code
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

If a MSG was not up and you attempted to mount a client it would
fail as expected. The issue was when you attempted to unload
the lustre module that it would oops. Remove the module_put()
that was causing this problem. Update the llite module code to
sync us with the OpenSFS tree.

Fixes: a989830c88 ("lustre: llite: move client mounting from obdclass to llite")
WC-bug-id: https://jira.whamcloud.com/browse/LU-12514
Lustre-commit: 53fa81765750e38f ("LU-12514 llite: move client mounting from obdclass to llite")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/37693
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/include/lustre_disk.h |  5 ++--
 fs/lustre/llite/llite_lib.c     |  5 ----
 fs/lustre/llite/super25.c       | 60 ++++++++++++++++++++++-------------------
 fs/lustre/obdclass/class_obd.c  | 15 +++++------
 4 files changed, 42 insertions(+), 43 deletions(-)

diff --git a/fs/lustre/include/lustre_disk.h b/fs/lustre/include/lustre_disk.h
index b6b693f..a54b5fd 100644
--- a/fs/lustre/include/lustre_disk.h
+++ b/fs/lustre/include/lustre_disk.h
@@ -150,12 +150,13 @@ struct lustre_sb_info {
 int lustre_start_mgc(struct super_block *sb);
 int lustre_common_put_super(struct super_block *sb);
 
-int mgc_fsname2resid(char *fsname, struct ldlm_res_id *res_id, int type);
-
 struct lustre_sb_info *lustre_init_lsi(struct super_block *sb);
 int lustre_put_lsi(struct super_block *sb);
 int lmd_parse(char *options, struct lustre_mount_data *lmd);
 
+/* mgc_request.c */
+int mgc_fsname2resid(char *fsname, struct ldlm_res_id *res_id, int type);
+
 /** @} disk */
 
 #endif /* _LUSTRE_DISK_H */
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index ca6e736..e7c1b73 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1052,8 +1052,6 @@ int ll_fill_super(struct super_block *sb)
 
 	CDEBUG(D_VFSTRACE, "VFS Op: sb %p\n", sb);
 
-	try_module_get(THIS_MODULE);
-
 	cfg = kzalloc(sizeof(*cfg), GFP_NOFS);
 	if (!cfg) {
 		err = -ENOMEM;
@@ -1252,9 +1250,6 @@ void ll_put_super(struct super_block *sb)
 	ll_common_put_super(sb);
 
 	cl_env_cache_purge(~0);
-
-	module_put(THIS_MODULE);
-
 } /* client_put_super */
 
 struct inode *ll_inode_from_resource_lock(struct ldlm_lock *lock)
diff --git a/fs/lustre/llite/super25.c b/fs/lustre/llite/super25.c
index e3194a5..1b074a6 100644
--- a/fs/lustre/llite/super25.c
+++ b/fs/lustre/llite/super25.c
@@ -32,6 +32,7 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LLITE
+
 #define D_MOUNT (D_SUPER | D_CONFIG/*|D_WARNING */)
 
 #include <linux/module.h>
@@ -95,11 +96,12 @@ static int ll_drop_inode(struct inode *inode)
 	.show_options		= ll_show_options,
 };
 
-/** This is the entry point for the mount call into Lustre.
+/**
+ * This is the entry point for the mount call into Lustre.
  * This is called when a server or client is mounted,
  * and this is where we start setting things up.
  *
- * @data:	Mount options (e.g. -o flock,abort_recov)
+ * @lmd2data	Mount options (e.g. -o flock,abort_recov)
  */
 static int lustre_fill_super(struct super_block *sb, void *lmd2_data,
 			     int silent)
@@ -132,30 +134,30 @@ static int lustre_fill_super(struct super_block *sb, void *lmd2_data,
 		goto out_put_lsi;
 	}
 
-	if (lmd_is_client(lmd)) {
-		CDEBUG(D_MOUNT, "Mounting client %s\n", lmd->lmd_profile);
-
-		rc = ptlrpc_inc_ref();
-		if (rc)
-			goto out_put_lsi;
-		rc = lustre_start_mgc(sb);
-		if (rc) {
-			/* This will put_lsi and ptlrpc_dec_ref */
-			ll_common_put_super(sb);
-			goto out;
-		}
-		/* Connect and start */
-		rc = ll_fill_super(sb);
-		/*
-		 * c_f_s will call ll_common_put_super on failure, otherwise
-		 * c_f_s will have taken another reference to the module
-		 */
-	} else {
-		CERROR("This is client-side-only module, cannot handle server mount.\n");
-		rc = -EINVAL;
+	if (!lmd_is_client(lmd)) {
+		rc = -ENODEV;
+		CERROR("%s: This is client-side-only module, cannot handle server mount: rc = %d\n",
+		       lmd->lmd_profile, rc);
+		goto out_put_lsi;
 	}
 
-	/* If error happens in fill_super() call, @lsi will be killed there.
+	CDEBUG(D_MOUNT, "Mounting client %s\n", lmd->lmd_profile);
+	rc = ptlrpc_inc_ref();
+	if (rc)
+		goto out_put_lsi;
+
+	rc = lustre_start_mgc(sb);
+	if (rc) {
+		/* This will put_lsi and ptlrpc_dec_ref */
+		ll_common_put_super(sb);
+		goto out;
+	}
+	/* Connect and start */
+	rc = ll_fill_super(sb);
+	/* ll_file_super will call lustre_common_put_super on failure,
+	 * which takes care of the module reference.
+	 *
+	 * If error happens in fill_super() call, @lsi will be killed there.
 	 * This is why we do not put it here.
 	 */
 	goto out;
@@ -163,10 +165,10 @@ static int lustre_fill_super(struct super_block *sb, void *lmd2_data,
 	lustre_put_lsi(sb);
 out:
 	if (rc) {
-		CERROR("Unable to mount %s (%d)\n",
-		       s2lsi(sb) ? lmd->lmd_dev : "", rc);
+		CERROR("llite: Unable to mount %s: rc = %d\n",
+		       s2lsi(sb) ? lmd->lmd_dev : "<unknown>", rc);
 	} else {
-		CDEBUG(D_SUPER, "Mount %s complete\n",
+		CDEBUG(D_SUPER, "%s: Mount complete\n",
 		       lmd->lmd_dev);
 	}
 	lockdep_on();
@@ -268,10 +270,12 @@ static int __init lustre_init(void)
 
 	rc = register_filesystem(&lustre_fs_type);
 	if (rc)
-		goto out_inode_fini_env;
+		goto out_xattr;
 
 	return 0;
 
+out_xattr:
+	ll_xattr_fini();
 out_inode_fini_env:
 	cl_env_put(cl_inode_fini_env, &cl_inode_fini_refcheck);
 out_vvp:
diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index 76664bf..38b8967 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -719,12 +719,14 @@ static int __init obdclass_init(void)
 	/* simulate a late OOM situation now to require all
 	 * alloc'ed/initialized resources to be freed
 	 */
-	if (!OBD_FAIL_CHECK(OBD_FAIL_OBDCLASS_MODULE_LOAD))
-		return 0;
-
-	/* force error to ensure module will be unloaded/cleaned */
-	err = -ENOMEM;
+	if (OBD_FAIL_CHECK(OBD_FAIL_OBDCLASS_MODULE_LOAD)) {
+		/* force error to ensure module will be unloaded/cleaned */
+		err = -ENOMEM;
+		goto cleanup_all;
+	}
+	return 0;
 
+cleanup_all:
 	llog_info_fini();
 
 cleanup_cl_global:
@@ -748,9 +750,6 @@ static int __init obdclass_init(void)
 cleanup_zombie_impexp:
 	obd_zombie_impexp_stop();
 
-	if (err)
-		return err;
-
 	return err;
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
