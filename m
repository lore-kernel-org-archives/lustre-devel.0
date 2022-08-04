Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 2E195C19F29
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:39:15 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4LyrxG5txjz233W;
	Wed,  3 Aug 2022 18:39:14 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Lyrwm0DfLz23Jh
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:48 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 07CCE100B056;
 Wed,  3 Aug 2022 21:38:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 060FB8BBFC; Wed,  3 Aug 2022 21:38:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:38:15 -0400
Message-Id: <1659577097-19253-31-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 30/32] lustre: llite: use max default EA size
 to get default LMV
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
Cc: Lai Siyao <lai.siyao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lai Siyao <lai.siyao@whamcloud.com>

Subdir mount will fetch ROOT default LMV and set it, but the default
EA size cl_default_mds_easize may not be set for MDT0 yet, because
it's updated upon getattr/enqueue, and if subdir mount is not on MDT0,
it may not be initialized yet. Use max EA size to fetch default
layout in ll_dir_get_default_layout().

Fixes: 4cee9af853 ("lustre: llite: enforce ROOT default on subdir mount")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15910
Lustre-commit: bb588480d4cdd6847 ("LU-15910 llite: use max default EA size to get default LMV")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/47937
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 26c9ec3..3384d81 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -663,17 +663,13 @@ int ll_dir_get_default_layout(struct inode *inode, void **plmm, int *plmm_size,
 	struct mdt_body *body;
 	struct lov_mds_md *lmm = NULL;
 	struct ptlrpc_request *req = NULL;
-	int rc, lmmsize;
+	int lmmsize = OBD_MAX_DEFAULT_EA_SIZE;
 	struct md_op_data *op_data;
 	struct lu_fid fid;
+	int rc;
 
-	rc = ll_get_max_mdsize(sbi, &lmmsize);
-	if (rc)
-		return rc;
-
-	op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL,
-				     0, lmmsize, LUSTRE_OPC_ANY,
-				     NULL);
+	op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, lmmsize,
+				     LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
