Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73B41C433B4
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:13 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 222976138E
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 222976138E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6CD813289C1;
	Mon,  5 Apr 2021 00:51:50 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B733221FBE8
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:26 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 1245AE3D;
 Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0F48390AA9; Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:51:00 -0400
Message-Id: <1617583870-32029-32-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 31/41] lustre: change various operations
 structs to const
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

From: Mr NeilBrown <neilb@suse.de>

Nearly all of
  struct cl_io_operations
  struct cl_lock_operations
  struct super_operations
  struct llog_operations

are now const.  The one exception is changelog_orig_logops.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: c20b866ba374ea3 ("LU-6142 lustre: change various operations structs to const")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39400
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_log.h   | 10 +++++-----
 fs/lustre/include/lustre_net.h   |  2 +-
 fs/lustre/llite/llite_internal.h |  2 +-
 fs/lustre/llite/super25.c        |  2 +-
 fs/lustre/mdc/mdc_dev.c          |  2 +-
 fs/lustre/obdclass/llog.c        |  4 ++--
 fs/lustre/obdclass/llog_obd.c    |  2 +-
 fs/lustre/ptlrpc/llog_client.c   |  2 +-
 8 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/include/lustre_log.h b/fs/lustre/include/lustre_log.h
index 6995414..24e6609 100644
--- a/fs/lustre/include/lustre_log.h
+++ b/fs/lustre/include/lustre_log.h
@@ -134,7 +134,7 @@ int llog_cat_process(const struct lu_env *env, struct llog_handle *cat_llh,
 /* llog_obd.c */
 int llog_setup(const struct lu_env *env, struct obd_device *obd,
 	       struct obd_llog_group *olg, int index,
-	       struct obd_device *disk_obd, struct llog_operations *op);
+	       struct obd_device *disk_obd, const struct llog_operations *op);
 int __llog_ctxt_put(const struct lu_env *env, struct llog_ctxt *ctxt);
 int llog_cleanup(const struct lu_env *env, struct llog_ctxt *);
 
@@ -225,7 +225,7 @@ struct llog_handle {
 	} u;
 	char			*lgh_name;
 	void			*private_data;
-	struct llog_operations	*lgh_logops;
+	const struct llog_operations	*lgh_logops;
 	refcount_t		 lgh_refcount;
 	bool			 lgh_destroyed;
 };
@@ -241,7 +241,7 @@ struct llog_ctxt {
 	struct obd_import	*loc_imp; /* to use in RPC's: can be backward
 					   * pointing import
 					   */
-	struct llog_operations  *loc_logops;
+	const struct llog_operations  *loc_logops;
 	struct llog_handle      *loc_handle;
 	struct mutex		 loc_mutex; /* protect loc_imp */
 	refcount_t		 loc_refcount;
@@ -257,7 +257,7 @@ struct llog_ctxt {
 #define LLOG_DEL_RECORD 0x0002
 
 static inline int llog_handle2ops(struct llog_handle *loghandle,
-				  struct llog_operations **lop)
+				  const struct llog_operations **lop)
 {
 	if (!loghandle || !loghandle->lgh_logops)
 		return -EINVAL;
@@ -351,7 +351,7 @@ static inline int llog_next_block(const struct lu_env *env,
 				  int next_idx, u64 *cur_offset, void *buf,
 				  int len)
 {
-	struct llog_operations *lop;
+	const struct llog_operations *lop;
 	int rc;
 
 	rc = llog_handle2ops(loghandle, &lop);
diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index f16c935..a9aa363 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -2409,7 +2409,7 @@ enum timeout_event {
 /** @} */
 
 /* ptlrpc/llog_client.c */
-extern struct llog_operations llog_client_ops;
+extern const struct llog_operations llog_client_ops;
 /** @} net */
 
 #endif
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 3bd774b..677106d 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1131,7 +1131,7 @@ int ll_revalidate_it_finish(struct ptlrpc_request *request,
 			    struct lookup_intent *it, struct inode *inode);
 
 /* llite/llite_lib.c */
-extern struct super_operations lustre_super_operations;
+extern const struct super_operations lustre_super_operations;
 
 void ll_common_put_super(struct super_block *sb);
 void ll_lli_init(struct ll_inode_info *lli);
diff --git a/fs/lustre/llite/super25.c b/fs/lustre/llite/super25.c
index d02c8cf..e3194a5 100644
--- a/fs/lustre/llite/super25.c
+++ b/fs/lustre/llite/super25.c
@@ -83,7 +83,7 @@ static int ll_drop_inode(struct inode *inode)
 }
 
 /* exported operations */
-struct super_operations lustre_super_operations = {
+const struct super_operations lustre_super_operations = {
 	.alloc_inode		= ll_alloc_inode,
 	.destroy_inode		= ll_destroy_inode,
 	.drop_inode		= ll_drop_inode,
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 68088ef..39c1213 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -1284,7 +1284,7 @@ static void mdc_io_data_version_end(const struct lu_env *env,
 	}
 }
 
-static struct cl_io_operations mdc_io_ops = {
+static const struct cl_io_operations mdc_io_ops = {
 	.op = {
 		[CIT_READ] = {
 			.cio_iter_init	= osc_io_rw_iter_init,
diff --git a/fs/lustre/obdclass/llog.c b/fs/lustre/obdclass/llog.c
index 7668d51..b431087 100644
--- a/fs/lustre/obdclass/llog.c
+++ b/fs/lustre/obdclass/llog.c
@@ -100,7 +100,7 @@ int llog_handle_put(const struct lu_env *env, struct llog_handle *loghandle)
 	int rc = 0;
 
 	if (refcount_dec_and_test(&loghandle->lgh_refcount)) {
-		struct llog_operations *lop;
+		const struct llog_operations *lop;
 
 		rc = llog_handle2ops(loghandle, &lop);
 		if (!rc) {
@@ -118,7 +118,7 @@ static int llog_read_header(const struct lu_env *env,
 			    struct llog_handle *handle,
 			    struct obd_uuid *uuid)
 {
-	struct llog_operations *lop;
+	const struct llog_operations *lop;
 	int rc;
 
 	rc = llog_handle2ops(handle, &lop);
diff --git a/fs/lustre/obdclass/llog_obd.c b/fs/lustre/obdclass/llog_obd.c
index f652eed..82f96ed 100644
--- a/fs/lustre/obdclass/llog_obd.c
+++ b/fs/lustre/obdclass/llog_obd.c
@@ -135,7 +135,7 @@ int llog_cleanup(const struct lu_env *env, struct llog_ctxt *ctxt)
 
 int llog_setup(const struct lu_env *env, struct obd_device *obd,
 	       struct obd_llog_group *olg, int index,
-	       struct obd_device *disk_obd, struct llog_operations *op)
+	       struct obd_device *disk_obd, const struct llog_operations *op)
 {
 	struct llog_ctxt *ctxt;
 	int rc = 0;
diff --git a/fs/lustre/ptlrpc/llog_client.c b/fs/lustre/ptlrpc/llog_client.c
index aeefa8f..79764cf 100644
--- a/fs/lustre/ptlrpc/llog_client.c
+++ b/fs/lustre/ptlrpc/llog_client.c
@@ -352,7 +352,7 @@ static int llog_client_close(const struct lu_env *env,
 	return 0;
 }
 
-struct llog_operations llog_client_ops = {
+const struct llog_operations llog_client_ops = {
 	.lop_next_block		= llog_client_next_block,
 	.lop_prev_block		= llog_client_prev_block,
 	.lop_read_header	= llog_client_read_header,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
