Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id D3EDCC19F2D
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:40:03 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4LyryC1Tgzz23LZ;
	Wed,  3 Aug 2022 18:40:03 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Lyrwd2p51z21Hc
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:41 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id E06CC100B030;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id DE0BD8BBFC; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:38:06 -0400
Message-Id: <1659577097-19253-22-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 21/32] lustre: client: able to cleanup
 devices manually
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
Cc: Mikhail Pershin <mpershin@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mikhail Pershin <mpershin@whamcloud.com>

Using 'lctl cleanup/detach' could be needed in situations
with unclean umount. Meanwhile that doesn't work now for
LMV and also could cause panic after all

Patch restores ability to cleanup/detach client devices
manually.
- debugfs and lprocfs cleanup in lmv_precleanup() are moved
  lmv_cleanup() to be not cleared too early. This prevents
  hang on 'lctl cleanup' for LMV device
- test 172 is added in sanity. It skips device cleanup during
  normal umount, keeping device alive without client mount
  then manually cleanups/detaches them
- prevent negative lov_connections in lov_disconnect() and
  handle it gracefully
- remove obd_cleanup_client_import() in mdc_precleanup(),
  it is called already inside osc_precleanup_common()

WC-bug-id: https://jira.whamcloud.com/browse/LU-15653
Lustre-commit: 210803a2475862464 ("LU-15653 client: able to cleanup devices manually")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/46859
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h |  1 +
 fs/lustre/llite/llite_lib.c     |  5 +++++
 fs/lustre/lmv/lmv_obd.c         | 14 ++++++--------
 fs/lustre/lov/lov_obd.c         |  8 +++++++-
 fs/lustre/mdc/mdc_request.c     |  7 +++----
 5 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index b6c8a72..e25d4ed 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -381,6 +381,7 @@
 #define OBD_FAIL_OBDCLASS_MODULE_LOAD			0x60a
 #define OBD_FAIL_OBD_ZERO_NLINK_RACE			0x60b
 #define OBD_FAIL_OBD_SETUP				0x60d
+#define OBD_FAIL_OBD_CLEANUP				0x60e
 
 #define OBD_FAIL_TGT_REPLY_NET				0x700
 #define OBD_FAIL_TGT_CONN_RACE				0x701
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 5b80722..d947ede 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1377,10 +1377,15 @@ void ll_put_super(struct super_block *sb)
 		client_common_put_super(sb);
 	}
 
+	/* imitate failed cleanup */
+	if (OBD_FAIL_CHECK(OBD_FAIL_OBD_CLEANUP))
+		goto skip_cleanup;
+
 	next = 0;
 	while ((obd = class_devices_in_group(&sbi->ll_sb_uuid, &next)))
 		class_manual_cleanup(obd);
 
+skip_cleanup:
 	if (test_bit(LL_SBI_VERBOSE, sbi->ll_flags))
 		LCONSOLE_WARN("Unmounted %s\n", profilenm ? profilenm : "");
 
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 3af7a53..8656d6b 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -520,7 +520,6 @@ static int lmv_disconnect(struct obd_export *exp)
 	struct obd_device *obd = class_exp2obd(exp);
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt;
-	int rc;
 
 	lmv_foreach_connected_tgt(lmv, tgt)
 		lmv_disconnect_mdc(obd, tgt);
@@ -528,11 +527,8 @@ static int lmv_disconnect(struct obd_export *exp)
 	if (lmv->lmv_tgts_kobj)
 		kobject_put(lmv->lmv_tgts_kobj);
 
-	if (!lmv->connected)
-		class_export_put(exp);
-	rc = class_disconnect(exp);
 	lmv->connected = 0;
-	return rc;
+	return class_disconnect(exp);
 }
 
 static int lmv_fid2path(struct obd_export *exp, int len, void *karg,
@@ -1147,6 +1143,11 @@ static int lmv_cleanup(struct obd_device *obd)
 	struct lu_tgt_desc *tmp;
 
 	fld_client_fini(&lmv->lmv_fld);
+	fld_client_debugfs_fini(&lmv->lmv_fld);
+
+	lprocfs_obd_cleanup(obd);
+	ldebugfs_free_md_stats(obd);
+
 	lmv_foreach_tgt_safe(lmv, tgt, tmp)
 		lmv_del_target(lmv, tgt);
 	lu_tgt_descs_fini(&lmv->lmv_mdt_descs);
@@ -3063,9 +3064,6 @@ static int lmv_unlink(struct obd_export *exp, struct md_op_data *op_data,
 static int lmv_precleanup(struct obd_device *obd)
 {
 	libcfs_kkuc_group_rem(&obd->obd_uuid, 0, KUC_GRP_HSM);
-	fld_client_debugfs_fini(&obd->u.lmv.lmv_fld);
-	lprocfs_obd_cleanup(obd);
-	ldebugfs_free_md_stats(obd);
 	return 0;
 }
 
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 61159fd..161226f 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -313,8 +313,14 @@ static int lov_disconnect(struct obd_export *exp)
 		goto out;
 
 	/* Only disconnect the underlying layers on the final disconnect. */
+	if (lov->lov_connects == 0) {
+		CWARN("%s: was disconnected already #%d\n",
+		      obd->obd_name, lov->lov_connects);
+		return 0;
+	}
+
 	lov->lov_connects--;
-	if (lov->lov_connects != 0) {
+	if (lov->lov_connects > 0) {
 		/* why should there be more than 1 connect? */
 		CWARN("%s: unexpected disconnect #%d\n",
 		      obd->obd_name, lov->lov_connects);
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index bb51878..c073da2 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -2959,11 +2959,10 @@ static int mdc_precleanup(struct obd_device *obd)
 	osc_precleanup_common(obd);
 
 	mdc_changelog_cdev_finish(obd);
-
-	obd_cleanup_client_import(obd);
-	ptlrpc_lprocfs_unregister_obd(obd);
-	ldebugfs_free_md_stats(obd);
 	mdc_llog_finish(obd);
+	ldebugfs_free_md_stats(obd);
+	ptlrpc_lprocfs_unregister_obd(obd);
+
 	return 0;
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
