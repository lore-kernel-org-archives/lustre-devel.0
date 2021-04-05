Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D352C433B4
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:29 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BB9CB61396
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB9CB61396
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C3A79328A6C;
	Mon,  5 Apr 2021 00:52:01 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8CD5121FB55
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:25 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id F3001E2E;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id EF6D990AA9; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:56 -0400
Message-Id: <1617583870-32029-28-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 27/41] lustre: change EWOULDBLOCK to EAGAIN
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

From: "John L. Hammond" <jhammond@whamcloud.com>

On linux, EWOULDBLOCK has always been defined as an alias for
EAGAIN. In the interest of readability we should not use two names for
the same thing. So change the remaining uses of EWOULDBLOCK to EAGAIN.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14047
Lustre-commit: a7f48e6c15e28617 ("LU-14047 lustre: change EWOULDBLOCK to EAGAIN")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40307
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/fld/fld_request.c   | 2 +-
 fs/lustre/include/cl_object.h | 2 +-
 fs/lustre/llite/glimpse.c     | 2 +-
 fs/lustre/llite/vvp_page.c    | 2 +-
 fs/lustre/obdclass/cl_io.c    | 2 +-
 fs/lustre/osc/osc_io.c        | 2 +-
 fs/lustre/osc/osc_lock.c      | 2 +-
 fs/lustre/osc/osc_request.c   | 2 +-
 fs/lustre/ptlrpc/client.c     | 2 +-
 fs/lustre/ptlrpc/errno.c      | 4 ++--
 fs/lustre/ptlrpc/sec.c        | 2 +-
 11 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/lustre/fld/fld_request.c b/fs/lustre/fld/fld_request.c
index 52c148a..2e8d0b8 100644
--- a/fs/lustre/fld/fld_request.c
+++ b/fs/lustre/fld/fld_request.c
@@ -364,7 +364,7 @@ int fld_client_rpc(struct obd_export *exp,
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_FLD_QUERY_REQ && req->rq_no_delay)) {
 		/* the same error returned by ptlrpc_import_delay_req */
-		rc = -EWOULDBLOCK;
+		rc = -EAGAIN;
 		req->rq_status = rc;
 	} else {
 		obd_get_request_slot(&exp->exp_obd->u.cli);
diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 2d08ddd..b36942a 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1637,7 +1637,7 @@ struct cl_io_operations {
 enum cl_enq_flags {
 	/**
 	 * instruct server to not block, if conflicting lock is found. Instead
-	 * -EWOULDBLOCK is returned immediately.
+	 * -EAGAIN is returned immediately.
 	 */
 	CEF_NONBLOCK		= 0x00000001,
 	/**
diff --git a/fs/lustre/llite/glimpse.c b/fs/lustre/llite/glimpse.c
index 3441904..3d23612 100644
--- a/fs/lustre/llite/glimpse.c
+++ b/fs/lustre/llite/glimpse.c
@@ -207,7 +207,7 @@ int __cl_glimpse_size(struct inode *inode, int agl)
 		} else if (result == 0) {
 			result = cl_glimpse_lock(env, io, inode, io->ci_obj,
 						 agl);
-			if (!agl && result == -EWOULDBLOCK)
+			if (!agl && result == -EAGAIN)
 				io->ci_need_restart = 1;
 		}
 
diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
index 0403f00..b0a119e 100644
--- a/fs/lustre/llite/vvp_page.c
+++ b/fs/lustre/llite/vvp_page.c
@@ -272,7 +272,7 @@ static void vvp_page_completion_read(const struct lu_env *env,
 			cl_page_export(env, page, 1);
 	} else if (vpg->vpg_defer_uptodate) {
 		vpg->vpg_defer_uptodate = 0;
-		if (ioret == -EWOULDBLOCK) {
+		if (ioret == -EAGAIN) {
 			/* mirror read failed, it needs to destroy the page
 			 * because subpage would be from wrong osc when trying
 			 * to read from a new mirror
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index cc5a503..138ff27 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -749,7 +749,7 @@ int cl_io_loop(const struct lu_env *env, struct cl_io *io)
 	if (rc && !result)
 		result = rc;
 
-	if (result == -EWOULDBLOCK && io->ci_ndelay) {
+	if (result == -EAGAIN && io->ci_ndelay) {
 		io->ci_need_restart = 1;
 		result = 0;
 	}
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 9ec2734..b965608 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -406,7 +406,7 @@ int osc_io_iter_init(const struct lu_env *env, const struct cl_io_slice *ios)
 	 */
 	if (ios->cis_io->ci_type == CIT_READ && ios->cis_io->ci_ndelay &&
 	    !ios->cis_io->ci_tried_all_mirrors && osc_import_not_healthy(imp)) {
-		rc = -EWOULDBLOCK;
+		rc = -EAGAIN;
 	} else if (likely(!imp->imp_invalid)) {
 		atomic_inc(&osc->oo_nr_ios);
 		oio->oi_is_active = 1;
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index 536142f2..6ff3fb6 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -306,7 +306,7 @@ static int osc_lock_upcall(void *cookie, struct lustre_handle *lockh,
 		/* Hide the error. */
 		rc = 0;
 	} else if (rc < 0 && oscl->ols_flags & LDLM_FL_NDELAY) {
-		rc = -EWOULDBLOCK;
+		rc = -EAGAIN;
 	}
 
 	if (oscl->ols_owner)
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index be722c9..066ecdb 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -2430,7 +2430,7 @@ static int brw_interpret(const struct lu_env *env,
 	list_for_each_entry_safe(ext, tmp, &aa->aa_exts, oe_link) {
 		list_del_init(&ext->oe_link);
 		osc_extent_finish(env, ext, 1,
-				  rc && req->rq_no_delay ? -EWOULDBLOCK : rc);
+				  rc && req->rq_no_delay ? -EAGAIN : rc);
 	}
 	LASSERT(list_empty(&aa->aa_exts));
 	LASSERT(list_empty(&aa->aa_oaps));
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index cec4da99..20c00ad 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -1236,7 +1236,7 @@ static int ptlrpc_import_delay_req(struct obd_import *imp,
 		} else if (req->rq_no_delay &&
 			   imp->imp_generation != imp->imp_initiated_at) {
 			/* ignore nodelay for requests initiating connections */
-			*status = -EWOULDBLOCK;
+			*status = -EAGAIN;
 		} else if (req->rq_allow_replay &&
 			  (imp->imp_state == LUSTRE_IMP_REPLAY ||
 			   imp->imp_state == LUSTRE_IMP_REPLAY_LOCKS ||
diff --git a/fs/lustre/ptlrpc/errno.c b/fs/lustre/ptlrpc/errno.c
index 2975010..415967e 100644
--- a/fs/lustre/ptlrpc/errno.c
+++ b/fs/lustre/ptlrpc/errno.c
@@ -36,8 +36,8 @@
  * The two translation tables below must define a one-to-one mapping between
  * host and network errnos.
  *
- * EWOULDBLOCK is equal to EAGAIN on all architectures except for parisc, which
- * appears irrelevant.  Thus, existing references to EWOULDBLOCK are fine.
+ * EAGAIN is equal to EAGAIN on all architectures except for parisc, which
+ * appears irrelevant.  Thus, existing references to EAGAIN are fine.
  *
  * EDEADLOCK is equal to EDEADLK on x86 but not on sparc, at least.  A sparc
  * host has no context-free way to determine if a LUSTRE_EDEADLK represents an
diff --git a/fs/lustre/ptlrpc/sec.c b/fs/lustre/ptlrpc/sec.c
index 1822dbd..ea1dafe 100644
--- a/fs/lustre/ptlrpc/sec.c
+++ b/fs/lustre/ptlrpc/sec.c
@@ -720,7 +720,7 @@ int sptlrpc_req_refresh_ctx(struct ptlrpc_request *req, long timeout)
 	spin_unlock(&ctx->cc_lock);
 
 	if (timeout == 0)
-		return -EWOULDBLOCK;
+		return -EAGAIN;
 
 	/* Clear any flags that may be present from previous sends */
 	LASSERT(req->rq_receiving_reply == 0);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
