Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id DC93AC77B61
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:43:26 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWWK2CKZz22bh;
	Sun,  9 Apr 2023 05:24:29 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWVw4NSSz2161
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:24:08 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 6E3B51008493;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 6CB5C2B3; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:13:17 -0400
Message-Id: <1681042400-15491-38-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 37/40] lustre: tgt: add qos debug
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
Cc: Sergey Cheremencev <scherementsev@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Sergey Cheremencev <scherementsev@ddn.com>

Add several debug lines for QOS allocator.
Patch also changes S_CLASS subsystem to S_LOV in
lu_tgt_desc_tgt.c thus it can be enabled to capture
only QOS debugging.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16501
Lustre-commit: 5fe45f0ff98064561 ("LU-16501 tgt: add qos debug")
Signed-off-by: Sergey Cheremencev <scherementsev@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49977
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lu_tgt_descs.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/obdclass/lu_tgt_descs.c b/fs/lustre/obdclass/lu_tgt_descs.c
index 35e7c7c..d573c12 100644
--- a/fs/lustre/obdclass/lu_tgt_descs.c
+++ b/fs/lustre/obdclass/lu_tgt_descs.c
@@ -31,7 +31,7 @@
  *
  */
 
-#define DEBUG_SUBSYSTEM S_CLASS
+#define DEBUG_SUBSYSTEM S_LOV
 
 #include <linux/module.h>
 #include <linux/list.h>
@@ -219,6 +219,8 @@ void lu_tgt_qos_weight_calc(struct lu_tgt_desc *tgt, bool is_mdt)
 	else
 		ltq->ltq_avail = tgt_statfs_bavail(tgt) >> 8;
 	penalty = ltq->ltq_penalty + ltq->ltq_svr->lsq_penalty;
+	CDEBUG(D_OTHER, "ltq_penalty: %llu lsq_penalty: %llu tgt_bavail: %llu\n",
+		  ltq->ltq_penalty, ltq->ltq_svr->lsq_penalty, ltq->ltq_avail);
 	if (ltq->ltq_avail < penalty)
 		ltq->ltq_weight = 0;
 	else
@@ -623,8 +625,15 @@ int ltd_qos_update(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt,
 	/* Set max penalties for this tgt and server */
 	ltq->ltq_penalty += ltq->ltq_penalty_per_obj *
 			    ltd->ltd_lov_desc.ld_active_tgt_count;
+	CDEBUG(D_OTHER, "ltq_penalty: %llu per_obj: %llu tgt_count: %d\n",
+	       ltq->ltq_penalty, ltq->ltq_penalty_per_obj,
+	       ltd->ltd_lov_desc.ld_active_tgt_count);
 	svr->lsq_penalty += svr->lsq_penalty_per_obj *
 			    qos->lq_active_svr_count;
+	CDEBUG(D_OTHER, "lsq_penalty: %llu per_obj: %llu srv_count: %d\n",
+	       svr->lsq_penalty, svr->lsq_penalty_per_obj,
+	       qos->lq_active_svr_count);
+
 
 	/* Decrease all MDS penalties */
 	list_for_each_entry(svr, &qos->lq_svr_list, lsq_svr_list) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
