Return-Path: <SRS0=JyPa=L7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29D2AC07E9C
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:11:34 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id CB1E961C48
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:11:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB1E961C48
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 007962FA8B4;
	Wed,  7 Jul 2021 12:11:28 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id DE07021F888
 for <lustre-devel@lists.lustre.org>; Wed,  7 Jul 2021 12:11:19 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 3691E10090E2;
 Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 30BF69D8B2; Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  7 Jul 2021 15:11:02 -0400
Message-Id: <1625685076-1964-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
References: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/15] lustre: osc: Notify server if cache
 discard takes a long time
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

From: Oleg Drokin <green@whamcloud.com>

Discarding a large number of pages from a mapping under a
single lock can take a really long time (750GB is over 170s).
Since there is no stream of RPCs sent to the server as with
read or write to prolong the DLM lock timeout, the server
may evict the client as it does not see progress is being made.

As such send periodic "empty" RPCs to the server to show the
client is still alive and working on the pages under the lock.

For compatibility reasons the RPC is formed as a one-byte
OST_READ request with a special flag set to avoid doing
actual IO, but older servers actually do the one-byte read

WC-bug-id: https://jira.whamcloud.com/browse/LU-14711
Lustre-commit: 564070343ac4ccf4 ("LU-14711 osc: Notify server if cache discard takes a long time")
Signed-off-by: Oleg Drokin <green@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/43857
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Patrick Farrell <farr0186@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h |  3 +++
 fs/lustre/osc/osc_cache.c     | 11 +++++++++
 fs/lustre/osc/osc_internal.h  |  1 +
 fs/lustre/osc/osc_request.c   | 54 +++++++++++++++++++++++++++++++++----------
 4 files changed, 57 insertions(+), 12 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index c615091..1495949 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1919,6 +1919,9 @@ struct cl_io {
 			loff_t			ls_result;
 			int			ls_whence;
 		} ci_lseek;
+		struct cl_misc_io {
+			time64_t		lm_next_rpc_time;
+		} ci_misc;
 	} u;
 	struct cl_2queue	ci_queue;
 	size_t			ci_nob;
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 8dd12b1..321e9d9 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -3186,6 +3186,15 @@ bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 
 		if (!res)
 			break;
+
+		if (io->ci_type == CIT_MISC &&
+		    io->u.ci_misc.lm_next_rpc_time &&
+		    ktime_get_seconds() > io->u.ci_misc.lm_next_rpc_time) {
+			osc_send_empty_rpc(osc, idx << PAGE_SHIFT);
+			io->u.ci_misc.lm_next_rpc_time = ktime_get_seconds() +
+							 5 * obd_timeout / 16;
+		}
+
 		if (need_resched())
 			cond_resched();
 
@@ -3320,6 +3329,8 @@ int osc_lock_discard_pages(const struct lu_env *env, struct osc_object *osc,
 
 	io->ci_obj = cl_object_top(osc2cl(osc));
 	io->ci_ignore_layout = 1;
+	io->u.ci_misc.lm_next_rpc_time = ktime_get_seconds() +
+					 5 * obd_timeout / 16;
 	result = cl_io_init(env, io, CIT_MISC, io->ci_obj);
 	if (result != 0)
 		goto out;
diff --git a/fs/lustre/osc/osc_internal.h b/fs/lustre/osc/osc_internal.h
index 3b65f2d..d174691 100644
--- a/fs/lustre/osc/osc_internal.h
+++ b/fs/lustre/osc/osc_internal.h
@@ -87,6 +87,7 @@ int osc_ladvise_base(struct obd_export *exp, struct obdo *oa,
 int osc_process_config_base(struct obd_device *obd, struct lustre_cfg *cfg);
 int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		  struct list_head *ext_list, int cmd);
+void osc_send_empty_rpc(struct osc_object *osc, pgoff_t start);
 unsigned long osc_lru_reserve(struct client_obd *cli, unsigned long npages);
 void osc_lru_unreserve(struct client_obd *cli, unsigned long npages);
 
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 0d590ed..2b2ee83 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1399,21 +1399,23 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	struct brw_page *pg_prev;
 	void *short_io_buf;
 	const char *obd_name = cli->cl_import->imp_obd->obd_name;
-	struct inode *inode;
+	struct inode *inode = NULL;
 	bool directio = false;
 
-	inode = page2inode(pga[0]->pg);
-	if (!inode) {
-		/* Try to get reference to inode from cl_page if we are
-		 * dealing with direct IO, as handled pages are not
-		 * actual page cache pages.
-		 */
-		struct osc_async_page *oap = brw_page2oap(pga[0]);
-		struct cl_page *clpage = oap2cl_page(oap);
+	if (pga[0]->pg) {
+		inode = page2inode(pga[0]->pg);
+		if (!inode) {
+			/* Try to get reference to inode from cl_page if we are
+			 * dealing with direct IO, as handled pages are not
+			 * actual page cache pages.
+			 */
+			struct osc_async_page *oap = brw_page2oap(pga[0]);
+			struct cl_page *clpage = oap2cl_page(oap);
 
-		inode = clpage->cp_inode;
-		if (inode)
-			directio = true;
+			inode = clpage->cp_inode;
+			if (inode)
+				directio = true;
+		}
 	}
 	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_BRW_PREP_REQ))
 		return -ENOMEM; /* Recoverable */
@@ -2666,6 +2668,34 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	return rc;
 }
 
+/* This is to refresh our lock in face of no RPCs. */
+void osc_send_empty_rpc(struct osc_object *osc, pgoff_t start)
+{
+	struct ptlrpc_request *req;
+	struct obdo oa;
+	struct brw_page bpg = { .off = start, .count = 1};
+	struct brw_page *pga = &bpg;
+	int rc;
+
+	memset(&oa, 0, sizeof(oa));
+	oa.o_oi = osc->oo_oinfo->loi_oi;
+	oa.o_valid = OBD_MD_FLID | OBD_MD_FLGROUP | OBD_MD_FLFLAGS;
+	/* For updated servers - don't do a read */
+	oa.o_flags = OBD_FL_NORPC;
+
+	rc = osc_brw_prep_request(OBD_BRW_READ, osc_cli(osc), &oa, 1, &pga,
+				  &req, 0);
+
+	/* If we succeeded we ship it off, if not there's no point in doing
+	 * anything. Also no resends.
+	 * No interpret callback, no commit callback.
+	 */
+	if (!rc) {
+		req->rq_no_resend = 1;
+		ptlrpcd_add_req(req);
+	}
+}
+
 static int osc_set_lock_data(struct ldlm_lock *lock, void *data)
 {
 	int set = 0;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
