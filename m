Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B0444C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:33:03 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CE0C221FC02;
	Sun, 20 Mar 2022 06:32:10 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8DF3221F3E8
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:18 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 601A9EF8;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 5D34AAB; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:47 -0400
Message-Id: <1647783064-20688-34-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 33/50] lustre: hsm: update size upon
 completion of data version
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

From: Qian Yingjin <qian@ddn.com>

We found a HSM retore followed by a HSM release will set the
file size with 0 wrongly during the tests.
The reason is that the file size and blocks information is
incorrect obtained via @ll_merger_attr().
The data version operation will flush dirty pages from all
clients, the size and blocks information returns from the Lustre
OST is correct.
In this patch, we update the size and block attributes for a file
upon the completion of the data version operation accordingly.
By this way, HSM release will set the size and blocks information
correctly after data version ioctl operation.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15381
Lustre-commit: dd3b5601ec6905b00 ("LU-15381 hsm: update size upon completion of data version")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/45935
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Artem Blagodarenko <artem.blagodarenko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c                  |  5 +++--
 fs/lustre/osc/osc_io.c                  | 30 +++++++++++++++++++++++++-----
 include/uapi/linux/lustre/lustre_user.h |  1 +
 3 files changed, 29 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 6b95133..373efdd 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -2771,8 +2771,8 @@ int ll_hsm_release(struct inode *inode)
 	struct lu_env *env;
 	struct obd_client_handle *och = NULL;
 	u64 data_version = 0;
-	int rc;
 	u16 refcheck;
+	int rc;
 
 	CDEBUG(D_INODE, "%s: Releasing file " DFID ".\n",
 	       ll_i2sbi(inode)->ll_fsname,
@@ -2785,7 +2785,8 @@ int ll_hsm_release(struct inode *inode)
 	}
 
 	/* Grab latest data_version and [am]time values */
-	rc = ll_data_version(inode, &data_version, LL_DV_WR_FLUSH);
+	rc = ll_data_version(inode, &data_version,
+			     LL_DV_WR_FLUSH | LL_DV_SZ_UPDATE);
 	if (rc != 0)
 		goto out;
 
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index b84022b..db91bf2 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -833,7 +833,11 @@ static void osc_io_data_version_end(const struct lu_env *env,
 {
 	struct cl_data_version_io *dv = &slice->cis_io->u.ci_data_version;
 	struct osc_io *oio = cl2osc_io(env, slice);
+	struct cl_object *obj = slice->cis_obj;
 	struct osc_async_cbargs *cbargs = &oio->oi_cbarg;
+	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
+	struct obdo *oa = &oio->oi_oa;
+	unsigned int cl_valid = 0;
 
 	wait_for_completion(&cbargs->opc_sync);
 
@@ -841,14 +845,30 @@ static void osc_io_data_version_end(const struct lu_env *env,
 		slice->cis_io->ci_result = cbargs->opc_rc;
 	} else {
 		slice->cis_io->ci_result = 0;
-		if (!(oio->oi_oa.o_valid &
+		if (!(oa->o_valid &
 		      (OBD_MD_LAYOUT_VERSION | OBD_MD_FLDATAVERSION)))
 			slice->cis_io->ci_result = -ENOTSUPP;
 
-		if (oio->oi_oa.o_valid & OBD_MD_LAYOUT_VERSION)
-			dv->dv_layout_version = oio->oi_oa.o_layout_version;
-		if (oio->oi_oa.o_valid & OBD_MD_FLDATAVERSION)
-			dv->dv_data_version = oio->oi_oa.o_data_version;
+		if (oa->o_valid & OBD_MD_LAYOUT_VERSION)
+			dv->dv_layout_version = oa->o_layout_version;
+		if (oa->o_valid & OBD_MD_FLDATAVERSION)
+			dv->dv_data_version = oa->o_data_version;
+
+		if (dv->dv_flags & LL_DV_SZ_UPDATE) {
+			if (oa->o_valid & OBD_MD_FLSIZE) {
+				attr->cat_size = oa->o_size;
+				cl_valid |= CAT_SIZE;
+			}
+
+			if (oa->o_valid & OBD_MD_FLBLOCKS) {
+				attr->cat_blocks = oa->o_blocks;
+				cl_valid |= CAT_BLOCKS;
+			}
+
+			cl_object_attr_lock(obj);
+			cl_object_attr_update(env, obj, attr, cl_valid);
+			cl_object_attr_unlock(obj);
+		}
 	}
 }
 
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 3b53a5b..2fdd7df 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -1848,6 +1848,7 @@ struct ioc_data_version {
 enum ioc_data_version_flags {
 	LL_DV_RD_FLUSH	= (1 << 0), /* Flush dirty pages from clients */
 	LL_DV_WR_FLUSH	= (1 << 1), /* Flush all caching pages from clients */
+	LL_DV_SZ_UPDATE	= (1 << 2), /* Update the file size on the client */
 };
 
 #ifndef offsetof
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
