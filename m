Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6F00C433B4
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:25 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 967336138E
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 967336138E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0FEEF32C4FF;
	Mon,  5 Apr 2021 00:51:59 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4175621FB3A
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:25 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id EFD6DB84;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id EAC5390AAE; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:55 -0400
Message-Id: <1617583870-32029-27-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 26/41] lustre: lov: grant deadlock if same
 OSC in two components
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
Cc: Andriy Skulysh <c17819@cray.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andriy Skulysh <c17819@cray.com>

The same osc can be involved in several components but osc layer
leaves active last used extent, so an RPC can't be sent if grants
are required from the same OST for another component.

Add cl_io_extent_release() to release active extent before
switching to the next component.

Cray-bug-id: LUS-8038
WC-bug-id: https://jira.whamcloud.com/browse/LU-13100
Lustre-commit: 2070e9bcc0c1bd2 ("LU-13100 lov: grant deadlock if same OSC in two components")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Vitaly Fertman <c17818@cray.com>
Reviewed-by: Alexander Zarochentsev <c17826@cray.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-on: https://review.whamcloud.com/37095
Reviewed-by: Andrew Perepechko <andrew.perepechko@hpe.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h  |  6 ++++++
 fs/lustre/include/lustre_osc.h |  2 ++
 fs/lustre/lov/lov_io.c         |  4 ++++
 fs/lustre/mdc/mdc_dev.c        |  1 +
 fs/lustre/obdclass/cl_io.c     | 12 ++++++++++++
 fs/lustre/osc/osc_io.c         | 15 ++++++++++++++-
 6 files changed, 39 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 739fe5b..2d08ddd 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1611,6 +1611,11 @@ struct cl_io_operations {
 				 struct cl_page_list *queue, int from, int to,
 				 cl_commit_cbt cb);
 	/**
+	 * Release active extent.
+	 */
+	void  (*cio_extent_release)(const struct lu_env *env,
+				    const struct cl_io_slice *slice);
+	/**
 	 * Decide maximum read ahead extent
 	 *
 	 * \pre io->ci_type == CIT_READ
@@ -2439,6 +2444,7 @@ int cl_io_submit_sync(const struct lu_env *env, struct cl_io *io,
 int cl_io_commit_async(const struct lu_env *env, struct cl_io *io,
 		       struct cl_page_list *queue, int from, int to,
 		       cl_commit_cbt cb);
+void cl_io_extent_release(const struct lu_env *env, struct cl_io *io);
 int cl_io_read_ahead(const struct lu_env *env, struct cl_io *io,
 		     pgoff_t start, struct cl_read_ahead *ra);
 
diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index e32723c..4575956 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -689,6 +689,8 @@ int osc_io_commit_async(const struct lu_env *env,
 			const struct cl_io_slice *ios,
 			struct cl_page_list *qin, int from, int to,
 			cl_commit_cbt cb);
+void osc_io_extent_release(const struct lu_env *env,
+			   const struct cl_io_slice *ios);
 int osc_io_iter_init(const struct lu_env *env, const struct cl_io_slice *ios);
 void osc_io_iter_fini(const struct lu_env *env,
 		      const struct cl_io_slice *ios);
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 2297e53..a8bba1c 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -1318,6 +1318,10 @@ static int lov_io_commit_async(const struct lu_env *env,
 			break;
 
 		from = 0;
+
+		if (lov_comp_entry(index) !=
+		    lov_comp_entry(page->cp_lov_index))
+			cl_io_extent_release(sub->sub_env, &sub->sub_io);
 	}
 
 	/* for error case, add the page back into the qin list */
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index e86e69d..68088ef 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -1325,6 +1325,7 @@ static void mdc_io_data_version_end(const struct lu_env *env,
 	.cio_read_ahead		= mdc_io_read_ahead,
 	.cio_submit		= osc_io_submit,
 	.cio_commit_async	= osc_io_commit_async,
+	.cio_extent_release	= osc_io_extent_release,
 };
 
 int mdc_io_init(const struct lu_env *env, struct cl_object *obj,
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index c57a3766..cc5a503 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -597,6 +597,18 @@ int cl_io_commit_async(const struct lu_env *env, struct cl_io *io,
 }
 EXPORT_SYMBOL(cl_io_commit_async);
 
+void cl_io_extent_release(const struct lu_env *env, struct cl_io *io)
+{
+	const struct cl_io_slice *scan;
+
+	list_for_each_entry(scan, &io->ci_layers, cis_linkage) {
+		if (!scan->cis_iop->cio_extent_release)
+			continue;
+		scan->cis_iop->cio_extent_release(env, scan);
+	}
+}
+EXPORT_SYMBOL(cl_io_extent_release);
+
 /**
  * Submits a list of pages for immediate io.
  *
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index ce0f7ec..9ec2734 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -373,6 +373,18 @@ int osc_io_commit_async(const struct lu_env *env,
 }
 EXPORT_SYMBOL(osc_io_commit_async);
 
+void osc_io_extent_release(const struct lu_env *env,
+			   const struct cl_io_slice *ios)
+{
+	struct osc_io *oio = cl2osc_io(env, ios);
+
+	if (oio->oi_active) {
+		osc_extent_release(env, oio->oi_active);
+		oio->oi_active = NULL;
+	}
+}
+EXPORT_SYMBOL(osc_io_extent_release);
+
 static bool osc_import_not_healthy(struct obd_import *imp)
 {
 	return imp->imp_invalid || imp->imp_deactive ||
@@ -1218,7 +1230,8 @@ void osc_io_lseek_end(const struct lu_env *env,
 	},
 	.cio_read_ahead			= osc_io_read_ahead,
 	.cio_submit			= osc_io_submit,
-	.cio_commit_async		= osc_io_commit_async
+	.cio_commit_async		= osc_io_commit_async,
+	.cio_extent_release		= osc_io_extent_release
 };
 
 /*****************************************************************************
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
