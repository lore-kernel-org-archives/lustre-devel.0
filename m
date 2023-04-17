Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 64261C77B77
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 13:58:44 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T3H4t6sz21KC;
	Mon, 17 Apr 2023 06:50:51 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0T0j3rSYz215c
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:48:37 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 88AE2100848F;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 87177372; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:47:09 -0400
Message-Id: <1681739243-29375-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/27] lnet: libcfs: cleanup console messages
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andreas Dilger <adilger@whamcloud.com>

Change early libcfs cfs_cpu_init() messages from CERROR() to
pr_err() to avoid circular dependencies on libcfs setup before
printing an error message to the console during module init.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16639
Lustre-commit: 8f40a3d7110da1af8e ("LU-16639 misc: cleanup concole messages")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50283
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Feng Lei <flei@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/libcfs_cpu.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/lnet/libcfs/libcfs_cpu.c b/net/lnet/libcfs/libcfs_cpu.c
index dca92cd..a5bf4f6 100644
--- a/net/lnet/libcfs/libcfs_cpu.c
+++ b/net/lnet/libcfs/libcfs_cpu.c
@@ -1177,27 +1177,27 @@ int cfs_cpu_init(void)
 	if (*cpu_pattern) {
 		cfs_cpt_tab = cfs_cpt_table_create_pattern(cpu_pattern);
 		if (IS_ERR(cfs_cpt_tab)) {
-			CERROR("Failed to create cptab from pattern '%s'\n",
-			       cpu_pattern);
 			ret = PTR_ERR(cfs_cpt_tab);
+			pr_err("libcfs: failed to create cptab from pattern '%s': rc = %d\n",
+			       cpu_pattern, ret);
 			goto failed_alloc_table;
 		}
 
 	} else {
 		cfs_cpt_tab = cfs_cpt_table_create(cpu_npartitions);
 		if (IS_ERR(cfs_cpt_tab)) {
-			CERROR("Failed to create cptab with npartitions %d\n",
-			       cpu_npartitions);
 			ret = PTR_ERR(cfs_cpt_tab);
+			pr_err("libcfs: failed to create cptab with npartitions=%d: rc = %d\n",
+			       cpu_npartitions, ret);
 			goto failed_alloc_table;
 		}
 	}
 
 	put_online_cpus();
 
-	LCONSOLE(0, "HW NUMA nodes: %d, HW CPU cores: %d, npartitions: %d\n",
-		 num_online_nodes(), num_online_cpus(),
-		 cfs_cpt_number(cfs_cpt_tab));
+	pr_notice("libcfs: HW NUMA nodes: %d, HW CPU cores: %d, npartitions: %d\n",
+		  num_online_nodes(), num_online_cpus(),
+		  cfs_cpt_number(cfs_cpt_tab));
 	return 0;
 
 failed_alloc_table:
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
