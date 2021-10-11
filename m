Return-Path: <SRS0=0agL=O7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3C73C433F5
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:34 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BF6E860EB6
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org BF6E860EB6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id DB119380CA7;
	Mon, 11 Oct 2021 10:41:19 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0FFC921FDCE
 for <lustre-devel@lists.lustre.org>; Mon, 11 Oct 2021 10:40:57 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id C387C468;
 Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C1A71A56A1; Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 11 Oct 2021 13:40:42 -0400
Message-Id: <1633974049-26490-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
References: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/20] lustre: quota: fix quota with root
 squash enabled
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
Cc: Wang Shilong <wangshilong1991@gmail.com>, Wang Shilong <wshilong@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Wang Shilong <wshilong@ddn.com>

This patch tries to fix several problems:

1. OSD will ignore quota if IO comes from client
   cache or root, however since following change:

   LU-12687 osc: consume grants for direct I/O

   DIO now consumes grant too, following check for
   sync IO is wrong now:

   (lnb[i].lnb_flags & (OBD_BRW_FROM_GRANT | OBD_BRW_SYNC))
           == OBD_BRW_FROM_GRANT)

   This was originally added to support 1.8 client, it is
   going to be 2.15 now, so let's remove this broken check.

2. Server side will clear OBD_BRW_NOQUOTA if root squash
   is enabled, this will revert fixes from:

   "LU-13228 clio: mmap write when overquota"

   We need to separate @ci_noquota and @oi_cap_sys_resource cases,
   introduce a new flag OBD_BRW_SYS_RESOURCE, and extend test_75
   to cover this case.

3. LU-14739 missed case that DoM quota should be considered
   as well.

4. If EDQUOT is returned for root, we check the new root squash
   flag OBD_FL_ROOT_SQUASH from server side. If this flag is not set,
   we bypass quota for root, otherwise all root writes become sync
   writes.

5. Fix a leftover problem with LU-9671 for DOM

Fixes: cd633cfc960b63 ("lustre: quota: nodemap squashed root cannot bypass quota")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14739
Lustre-commit: bbfdc7c1670c9274 ("LU-14739 quota: fix quota with root squash enabled")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Signed-off-by: Wang Shilong <wangshilong1991@gmail.com>
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/44347
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h                |  2 ++
 fs/lustre/osc/osc_cache.c              | 23 ++++++++++++++++++++---
 fs/lustre/osc/osc_page.c               |  4 ++--
 fs/lustre/osc/osc_quota.c              |  1 +
 fs/lustre/osc/osc_request.c            |  4 +++-
 fs/lustre/ptlrpc/wiretest.c            |  2 ++
 include/uapi/linux/lustre/lustre_idl.h |  4 +++-
 7 files changed, 33 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 7642973..b3ad511 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -233,6 +233,8 @@ struct client_obd {
 	struct list_head	cl_grant_chain;
 	time64_t		cl_grant_shrink_interval; /* seconds */
 
+	int			cl_root_squash; /* if root squash enabled*/
+
 	/* A chunk is an optimal size used by osc_extent to determine
 	 * the extent size. A chunk is max(PAGE_SIZE, OST block size)
 	 */
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 69cf9ba..1211438 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2374,11 +2374,16 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 
 	/* Set the OBD_BRW_SRVLOCK before the page is queued. */
 	brw_flags |= ops->ops_srvlock ? OBD_BRW_SRVLOCK : 0;
-	if (oio->oi_cap_sys_resource || io->ci_noquota) {
+	if (io->ci_noquota) {
 		brw_flags |= OBD_BRW_NOQUOTA;
 		cmd |= OBD_BRW_NOQUOTA;
 	}
 
+	if (oio->oi_cap_sys_resource) {
+		brw_flags |= OBD_BRW_SYS_RESOURCE;
+		cmd |= OBD_BRW_SYS_RESOURCE;
+	}
+
 	/* check if the file's owner/group is over quota */
 	if (!io->ci_noquota) {
 		struct cl_object *obj;
@@ -2395,8 +2400,20 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 		qid[USRQUOTA] = attr->cat_uid;
 		qid[GRPQUOTA] = attr->cat_gid;
 		qid[PRJQUOTA] = attr->cat_projid;
-		if (rc == 0)
-			rc = osc_quota_chkdq(cli, qid);
+		/*
+		 * if EDQUOT returned for root, we double check
+		 * if root squash enabled or not updated from server side.
+		 * without root squash, we should bypass quota for root.
+		 */
+		if (rc == 0 && osc_quota_chkdq(cli, qid) == -EDQUOT) {
+			if (oio->oi_cap_sys_resource &&
+			    !cli->cl_root_squash) {
+				io->ci_noquota = 1;
+				rc = 0;
+			} else {
+				rc = -EDQUOT;
+			}
+		}
 		if (rc)
 			return rc;
 	}
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index 8aa21ee..d471df2 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -314,8 +314,8 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 	oap->oap_brw_flags = OBD_BRW_SYNC | brw_flags;
 
 	if (oio->oi_cap_sys_resource) {
-		oap->oap_brw_flags |= OBD_BRW_NOQUOTA;
-		oap->oap_cmd |= OBD_BRW_NOQUOTA;
+		oap->oap_brw_flags |= OBD_BRW_SYS_RESOURCE;
+		oap->oap_cmd |= OBD_BRW_SYS_RESOURCE;
 	}
 
 	opg->ops_submit_time = submit_time;
diff --git a/fs/lustre/osc/osc_quota.c b/fs/lustre/osc/osc_quota.c
index 8ff803c..708ad3c 100644
--- a/fs/lustre/osc/osc_quota.c
+++ b/fs/lustre/osc/osc_quota.c
@@ -119,6 +119,7 @@ int osc_quota_setdq(struct client_obd *cli, u64 xid, const unsigned int qid[],
 		return 0;
 
 	mutex_lock(&cli->cl_quota_mutex);
+	cli->cl_root_squash = !!(flags & OBD_FL_ROOT_SQUASH);
 	/* still mark the quots is running out for the old request, because it
 	 * could be processed after the new request at OST, the side effect is
 	 * the following request will be processed synchronously, but it will
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index e5b7453..22b7e5e 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1167,7 +1167,8 @@ static inline int can_merge_pages(struct brw_page *p1, struct brw_page *p2)
 	if (p1->flag != p2->flag) {
 		unsigned int mask = ~(OBD_BRW_FROM_GRANT | OBD_BRW_NOCACHE |
 				      OBD_BRW_SYNC | OBD_BRW_ASYNC |
-				      OBD_BRW_NOQUOTA | OBD_BRW_SOFT_SYNC);
+				      OBD_BRW_NOQUOTA | OBD_BRW_SOFT_SYNC |
+				      OBD_BRW_SYS_RESOURCE);
 
 		/* warn if we try to combine flags that we don't know to be
 		 * safe to combine
@@ -3548,6 +3549,7 @@ int osc_setup_common(struct obd_device *obd, struct lustre_cfg *lcfg)
 		goto out_ptlrpcd_work;
 
 	cli->cl_grant_shrink_interval = GRANT_SHRINK_INTERVAL;
+	cli->cl_root_squash = 0;
 	osc_update_next_shrink(cli);
 
 	return 0;
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index bf09341..a381af4 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -2058,6 +2058,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_BRW_OVER_PRJQUOTA);
 	LASSERTF(OBD_BRW_RDMA_ONLY == 0x20000, "found 0x%.8x\n",
 		 OBD_BRW_RDMA_ONLY);
+	LASSERTF(OBD_BRW_SYS_RESOURCE == 0x40000, "found 0x%.8x\n",
+		 OBD_BRW_SYS_RESOURCE);
 
 	/* Checks for struct ost_body */
 	LASSERTF((int)sizeof(struct ost_body) == 208, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 7d92264..ec25140 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -977,6 +977,7 @@ enum obdo_flags {
 	OBD_FL_NOSPC_BLK	= 0x00100000, /* no more block space on OST */
 	OBD_FL_FLUSH		= 0x00200000, /* flush pages on the OST */
 	OBD_FL_SHORT_IO		= 0x00400000, /* short io request */
+	OBD_FL_ROOT_SQUASH	= 0x00800000, /* root squash */
 	/* OBD_FL_LOCAL_MASK = 0xF0000000, was local-only flags until 2.10 */
 
 	/*
@@ -1249,7 +1250,7 @@ struct hsm_state_set {
 #define OBD_BRW_FROM_GRANT	0x20 /* the osc manages this under llite */
 #define OBD_BRW_GRANTED		0x40 /* the ost manages this */
 #define OBD_BRW_NOCACHE		0x80 /* this page is a part of non-cached IO */
-#define OBD_BRW_NOQUOTA	       0x100
+#define OBD_BRW_NOQUOTA	       0x100 /* do not enforce quota */
 #define OBD_BRW_SRVLOCK	       0x200 /* Client holds no lock over this page */
 #define OBD_BRW_ASYNC	       0x400 /* Server may delay commit to disk */
 #define OBD_BRW_MEMALLOC       0x800 /* Client runs in the "kswapd" context */
@@ -1262,6 +1263,7 @@ struct hsm_state_set {
 				      */
 #define OBD_BRW_OVER_PRJQUOTA 0x8000 /* Running out of project quota */
 #define OBD_BRW_RDMA_ONLY    0x20000 /* RPC contains RDMA-only pages*/
+#define OBD_BRW_SYS_RESOURCE 0x40000 /* page has CAP_SYS_RESOURCE */
 
 #define OBD_MAX_GRANT 0x7fffffffUL /* Max grant allowed to one client: 2 GiB */
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
