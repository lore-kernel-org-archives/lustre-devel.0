Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 7C071C77B61
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:25:00 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWJr1w5Zz1y7v;
	Sun,  9 Apr 2023 05:15:24 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWH36btRz1y7D
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:13:51 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id D815E1008273;
 Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id CF84E2B8; Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:12:46 -0400
Message-Id: <1681042400-15491-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/40] lustre: quota: enforce project quota
 for root
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

Patch adds an option to enforce project quotas for root.
It is disabled by default, to enable set
osd-ldiskfs.*.quota_slave.root_prj_enable to 1
at each target where you need this option.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16415
Lustre-commit: f147655c33ea61450 ("LU-16415 quota: enforce project quota for root")
Signed-off-by: Sergey Cheremencev <scherementsev@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49460
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h                | 8 ++++----
 fs/lustre/osc/osc_cache.c              | 2 +-
 fs/lustre/osc/osc_quota.c              | 1 +
 include/uapi/linux/lustre/lustre_idl.h | 2 ++
 4 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index a980bf0..54bef2e 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -208,8 +208,10 @@ struct client_obd {
 	unsigned int		 cl_checksum:1,	/* 0 = disabled, 1 = enabled */
 				 cl_checksum_dump:1, /* same */
 				 cl_ocd_grant_param:1,
-				 cl_lsom_update:1; /* send LSOM updates */
-	/* supported checksum types that are worked out at connect time */
+				 cl_lsom_update:1, /* send LSOM updates */
+				 cl_root_squash:1, /* if root squash enabled*/
+				 /* check prj quota for root */
+				 cl_root_prjquota:1;
 	enum lustre_sec_part     cl_sp_me;
 	enum lustre_sec_part     cl_sp_to;
 	struct sptlrpc_flavor    cl_flvr_mgc;   /* fixed flavor of mgc->mgs */
@@ -233,8 +235,6 @@ struct client_obd {
 	struct list_head	cl_grant_chain;
 	time64_t		cl_grant_shrink_interval; /* seconds */
 
-	int			cl_root_squash; /* if root squash enabled*/
-
 	/* A chunk is an optimal size used by osc_extent to determine
 	 * the extent size. A chunk is max(PAGE_SIZE, OST block size)
 	 */
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index b339aef..dddf98f 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2366,7 +2366,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 	 * we should bypass quota
 	 */
 	if ((!oio->oi_cap_sys_resource ||
-	     cli->cl_root_squash) &&
+	     cli->cl_root_squash || cli->cl_root_prjquota) &&
 	    !io->ci_noquota) {
 		struct cl_object *obj;
 		struct cl_attr *attr;
diff --git a/fs/lustre/osc/osc_quota.c b/fs/lustre/osc/osc_quota.c
index 708ad3c..c48a89f3 100644
--- a/fs/lustre/osc/osc_quota.c
+++ b/fs/lustre/osc/osc_quota.c
@@ -120,6 +120,7 @@ int osc_quota_setdq(struct client_obd *cli, u64 xid, const unsigned int qid[],
 
 	mutex_lock(&cli->cl_quota_mutex);
 	cli->cl_root_squash = !!(flags & OBD_FL_ROOT_SQUASH);
+	cli->cl_root_prjquota = !!(flags & OBD_FL_ROOT_PRJQUOTA);
 	/* still mark the quots is running out for the old request, because it
 	 * could be processed after the new request at OST, the side effect is
 	 * the following request will be processed synchronously, but it will
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 99735fc..b4185a7 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -961,6 +961,7 @@ enum obdo_flags {
 	OBD_FL_FLUSH		= 0x00200000, /* flush pages on the OST */
 	OBD_FL_SHORT_IO		= 0x00400000, /* short io request */
 	OBD_FL_ROOT_SQUASH	= 0x00800000, /* root squash */
+	OBD_FL_ROOT_PRJQUOTA	= 0x01000000, /* check prj quota for root */
 	/* OBD_FL_LOCAL_MASK = 0xF0000000, was local-only flags until 2.10 */
 
 	/*
@@ -1250,6 +1251,7 @@ struct hsm_state_set {
 				      * it to sync quickly
 				      */
 #define OBD_BRW_OVER_PRJQUOTA 0x8000 /* Running out of project quota */
+#define OBD_BRW_ROOT_PRJQUOTA 0x10000 /* check project quota for root */
 #define OBD_BRW_RDMA_ONLY    0x20000 /* RPC contains RDMA-only pages*/
 #define OBD_BRW_SYS_RESOURCE 0x40000 /* page has CAP_SYS_RESOURCE */
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
