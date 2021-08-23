Return-Path: <SRS0=6+cL=NO=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAB13C4338F
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:27:57 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id EA47161360
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:27:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org EA47161360
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5CF2D21CAFC;
	Sun, 22 Aug 2021 19:27:54 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1940F21CAB1
 for <lustre-devel@lists.lustre.org>; Sun, 22 Aug 2021 19:27:51 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 224A0100BAF7;
 Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 126E0B6C8C; Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 22 Aug 2021 22:27:34 -0400
Message-Id: <1629685666-4533-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
References: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/15] lustre: mdt: implement fallocate in
 MDC/MDT
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
Cc: Mikhail Pershin <mpershin@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mikhail Pershin <mpershin@whamcloud.com>

- add CLIO fallocate() handling in MDC
- implement FALLOCATE RPC handling at MDT side
- update test group 150 in sanity to work with
  sanity-dom.sh test

WC-bug-id: https://jira.whamcloud.com/browse/LU-14382
Lustre-commit: 163870abfb7c3fe3 ("LU-14382 mdt: implement fallocate in MDC/MDT")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41418
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h |  4 ++++
 fs/lustre/mdc/mdc_dev.c        | 29 ++++++++++++++++++++---------
 fs/lustre/osc/osc_io.c         |  5 +++--
 fs/lustre/osc/osc_request.c    |  3 ++-
 4 files changed, 29 insertions(+), 12 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 8a62eb2..09868ea 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -678,6 +678,8 @@ int osc_reconnect(const struct lu_env *env, struct obd_export *exp,
 int osc_disconnect(struct obd_export *exp);
 int osc_punch_send(struct obd_export *exp, struct obdo *oa,
 		   obd_enqueue_update_f upcall, void *cookie);
+int osc_fallocate_base(struct obd_export *exp, struct obdo *oa,
+		       obd_enqueue_update_f upcall, void *cookie, int mode);
 
 /* osc_io.c */
 int osc_io_submit(const struct lu_env *env, const struct cl_io_slice *ios,
@@ -712,6 +714,8 @@ void osc_io_lseek_end(const struct lu_env *env,
 		      const struct cl_io_slice *slice);
 int osc_io_lru_reserve(const struct lu_env *env, const struct cl_io_slice *ios,
 		       loff_t pos, size_t count);
+int osc_punch_start(const struct lu_env *env, struct cl_io *io,
+		    struct cl_object *obj);
 
 /* osc_lock.c */
 void osc_lock_to_lockless(const struct lu_env *env, struct osc_lock *ols,
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index ce4148d..4777b47 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -35,6 +35,7 @@
 
 #include <obd_class.h>
 #include <lustre_osc.h>
+#include <linux/falloc.h>
 #include <uapi/linux/lustre/lustre_param.h>
 
 #include "mdc_internal.h"
@@ -1035,11 +1036,13 @@ static int mdc_io_setattr_start(const struct lu_env *env,
 					      &oio->oi_trunc);
 		if (rc < 0)
 			return rc;
+	} else if (cl_io_is_fallocate(io) &&
+		   io->u.ci_setattr.sa_falloc_mode & FALLOC_FL_PUNCH_HOLE) {
+		rc = osc_punch_start(env, io, obj);
+		if (rc < 0)
+			return rc;
 	}
 
-	if (cl_io_is_fallocate(io))
-		return -EOPNOTSUPP;
-
 	if (oio->oi_lockless == 0) {
 		cl_object_attr_lock(obj);
 		rc = cl_object_attr_get(env, obj, attr);
@@ -1070,7 +1073,7 @@ static int mdc_io_setattr_start(const struct lu_env *env,
 			return rc;
 	}
 
-	if (!(ia_valid & ATTR_SIZE))
+	if (!(ia_valid & ATTR_SIZE) && !cl_io_is_fallocate(io))
 		return 0;
 
 	memset(oa, 0, sizeof(*oa));
@@ -1078,12 +1081,10 @@ static int mdc_io_setattr_start(const struct lu_env *env,
 	oa->o_mtime = attr->cat_mtime;
 	oa->o_atime = attr->cat_atime;
 	oa->o_ctime = attr->cat_ctime;
-
-	oa->o_size = size;
-	oa->o_blocks = OBD_OBJECT_EOF;
 	oa->o_valid = OBD_MD_FLID | OBD_MD_FLGROUP | OBD_MD_FLATIME |
 		      OBD_MD_FLCTIME | OBD_MD_FLMTIME | OBD_MD_FLSIZE |
 		      OBD_MD_FLBLOCKS;
+
 	if (oio->oi_lockless) {
 		oa->o_flags = OBD_FL_SRVLOCK;
 		oa->o_valid |= OBD_MD_FLFLAGS;
@@ -1095,9 +1096,19 @@ static int mdc_io_setattr_start(const struct lu_env *env,
 	}
 
 	init_completion(&cbargs->opc_sync);
+	if (cl_io_is_fallocate(io)) {
+		int falloc_mode = io->u.ci_setattr.sa_falloc_mode;
 
-	rc = osc_punch_send(osc_export(cl2osc(obj)), oa,
-			    mdc_async_upcall, cbargs);
+		oa->o_size = io->u.ci_setattr.sa_falloc_offset;
+		oa->o_blocks = io->u.ci_setattr.sa_falloc_end;
+		rc = osc_fallocate_base(osc_export(cl2osc(obj)), oa,
+					mdc_async_upcall, cbargs, falloc_mode);
+	} else {
+		oa->o_size = size;
+		oa->o_blocks = OBD_OBJECT_EOF;
+		rc = osc_punch_send(osc_export(cl2osc(obj)), oa,
+				    mdc_async_upcall, cbargs);
+	}
 	cbargs->opc_rpc_sent = rc == 0;
 	return rc;
 }
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 047ae00..d828ae0 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -548,8 +548,8 @@ static void osc_trunc_check(const struct lu_env *env, struct cl_io *io,
  * if server doesn't support fallocate punch, we also need these data to be
  * flushed first to prevent re-ordering with the punch
  */
-static int osc_punch_start(const struct lu_env *env, struct cl_io *io,
-			   struct cl_object *obj)
+int osc_punch_start(const struct lu_env *env, struct cl_io *io,
+		    struct cl_object *obj)
 {
 	struct osc_object *osc = cl2osc(obj);
 	pgoff_t pg_start = cl_index(obj, io->u.ci_setattr.sa_falloc_offset);
@@ -564,6 +564,7 @@ static int osc_punch_start(const struct lu_env *env, struct cl_io *io,
 			     osc);
 	return 0;
 }
+EXPORT_SYMBOL(osc_punch_start);
 
 static int osc_io_setattr_start(const struct lu_env *env,
 				const struct cl_io_slice *slice)
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 2b2ee83..2ac0300 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -472,7 +472,7 @@ int osc_fallocate_base(struct obd_export *exp, struct obdo *oa,
 
 	ptlrpc_request_set_replen(req);
 
-	req->rq_interpret_reply = (ptlrpc_interpterer_t)osc_setattr_interpret;
+	req->rq_interpret_reply = osc_setattr_interpret;
 	BUILD_BUG_ON(sizeof(*sa) > sizeof(req->rq_async_args));
 	sa = ptlrpc_req_async_args(sa, req);
 	sa->sa_oa = oa;
@@ -482,6 +482,7 @@ int osc_fallocate_base(struct obd_export *exp, struct obdo *oa,
 	ptlrpcd_add_req(req);
 	return 0;
 }
+EXPORT_SYMBOL(osc_fallocate_base);
 
 static int osc_sync_interpret(const struct lu_env *env,
 			      struct ptlrpc_request *req,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
