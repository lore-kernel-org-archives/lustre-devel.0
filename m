Return-Path: <SRS0=6+cL=NO=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 247FDC4338F
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:07 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C3D3D611F2
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org C3D3D611F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7452D21CBEC;
	Sun, 22 Aug 2021 19:28:00 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E335921CAB2
 for <lustre-devel@lists.lustre.org>; Sun, 22 Aug 2021 19:27:52 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 30B1B100BAFF;
 Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1F9F9B6C94; Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 22 Aug 2021 22:27:38 -0400
Message-Id: <1629685666-4533-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
References: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/15] lustre: osc: Support RDMA only pages
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
Cc: Amir Shehata <ashehata@whamcloud.com>, Wang Shilong <wshilong@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Amir Shehata <ashehata@whamcloud.com>

Some memory architectures and CPU-offload cards with
on-board memory do not map data pages into the CPU
address space. Allow RDMA of data directly into those
pages without accessing contents.

Therefore, made changes to prevent doing checksum on
these type of pages.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14798
Lustre-commit: 29eabeb34c5ba2cffd ("LU-14798 lustre: Support RDMA only pages")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Lustre-change: https://review.whamcloud.com/37454
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Whamcloud-bug-id: EX-773
Reviewed-on: https://review.whamcloud.com/44111
Reviewed-by: Wang Shilong <wangshilong1991@gmail.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h |  6 ++++--
 fs/lustre/osc/osc_io.c         |  2 ++
 fs/lustre/osc/osc_request.c    | 15 +++++++++++----
 3 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 09868ea..cdc9aae 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -956,8 +956,10 @@ struct osc_extent {
 				oe_ndelay:1,
 	/* direct IO pages */
 				oe_dio:1,
-	/* this extent consists of RDMA only pages */
-				oe_is_rdma_only;
+	/* this extent consists of pages that are not directly accessible
+	 *  from the CPU
+	 */
+				oe_is_rdma_only:1;
 	/* how many grants allocated for this extent.
 	 *  Grant allocated for this extent. There is no grant allocated
 	 *  for reading extents and sync write extents.
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index d828ae0..b867985 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -153,6 +153,8 @@ int osc_io_submit(const struct lu_env *env, const struct cl_io_slice *ios,
 	page = cl_page_list_first(qin);
 	if (page->cp_type == CPT_TRANSIENT)
 		brw_flags |= OBD_BRW_NOCACHE;
+	if (lnet_is_rdma_only_page(page->cp_vmpage))
+		brw_flags |= OBD_BRW_RDMA_ONLY;
 
 	/*
 	 * NOTE: here @page is a top-level page. This is done to avoid
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 2ac0300..db73fce 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1402,6 +1402,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	const char *obd_name = cli->cl_import->imp_obd->obd_name;
 	struct inode *inode = NULL;
 	bool directio = false;
+	bool enable_checksum = true;
 
 	if (pga[0]->pg) {
 		inode = page2inode(pga[0]->pg);
@@ -1545,6 +1546,11 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 		}
 	}
 
+	if (lnet_is_rdma_only_page(pga[0]->pg)) {
+		enable_checksum = false;
+		short_io_size = 0;
+	}
+
 	/* Check if read/write is small enough to be a short io. */
 	if (short_io_size > cli->cl_max_short_io_bytes || niocount > 1 ||
 	    !imp_connect_shortio(cli->cl_import))
@@ -1700,10 +1706,12 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	if (osc_should_shrink_grant(cli))
 		osc_shrink_grant_local(cli, &body->oa);
 
+	if (!cli->cl_checksum || sptlrpc_flavor_has_bulk(&req->rq_flvr))
+		enable_checksum = false;
+
 	/* size[REQ_REC_OFF] still sizeof (*body) */
 	if (opc == OST_WRITE) {
-		if (cli->cl_checksum &&
-		    !sptlrpc_flavor_has_bulk(&req->rq_flvr)) {
+		if (enable_checksum) {
 			/* store cl_cksum_type in a local variable since
 			 * it can be changed via lprocfs
 			 */
@@ -1743,8 +1751,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 		req_capsule_set_size(pill, &RMF_RCS, RCL_SERVER,
 				     sizeof(u32) * niocount);
 	} else {
-		if (cli->cl_checksum &&
-		    !sptlrpc_flavor_has_bulk(&req->rq_flvr)) {
+		if (enable_checksum) {
 			if ((body->oa.o_valid & OBD_MD_FLFLAGS) == 0)
 				body->oa.o_flags = 0;
 			body->oa.o_flags |= obd_cksum_type_pack(obd_name,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
