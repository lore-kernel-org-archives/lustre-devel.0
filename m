From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:42 -0400
Subject: [lustre-devel] [PATCH 08/29] staging: lustre: clio: update file
	attributes after sync
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

This really only affects clients that are attached to lustre
server running ZFS, because zfs does not update # of blocks
until the blocks are flushed to disk.

This patch update file's blocks attribute after OST_SYNC completes.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4389
Reviewed-on: http://review.whamcloud.com/12915
Reviewed-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_internal.h |    2 +-
 drivers/staging/lustre/lustre/osc/osc_io.c       |    3 +--
 drivers/staging/lustre/lustre/osc/osc_request.c  |   21 ++++++++++++++++++++-
 3 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index dc708ea..12d3b58 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -124,7 +124,7 @@ int osc_setattr_async(struct obd_export *exp, struct obdo *oa,
 int osc_punch_base(struct obd_export *exp, struct obdo *oa,
 		   obd_enqueue_update_f upcall, void *cookie,
 		   struct ptlrpc_request_set *rqset);
-int osc_sync_base(struct obd_export *exp, struct obdo *oa,
+int osc_sync_base(struct osc_object *exp, struct obdo *oa,
 		  obd_enqueue_update_f upcall, void *cookie,
 		  struct ptlrpc_request_set *rqset);
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 8eb4275..3b82d0a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -760,8 +760,7 @@ static int osc_fsync_ost(const struct lu_env *env, struct osc_object *obj,
 
 	init_completion(&cbargs->opc_sync);
 
-	rc = osc_sync_base(osc_export(obj), oa, osc_async_upcall, cbargs,
-			   PTLRPCD_SET);
+	rc = osc_sync_base(obj, oa, osc_async_upcall, cbargs, PTLRPCD_SET);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index c570d19..091558e 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -82,6 +82,7 @@ struct osc_setattr_args {
 };
 
 struct osc_fsync_args {
+	struct osc_object	*fa_obj;
 	struct obdo		*fa_oa;
 	obd_enqueue_update_f fa_upcall;
 	void		*fa_cookie;
@@ -365,8 +366,11 @@ static int osc_sync_interpret(const struct lu_env *env,
 			      struct ptlrpc_request *req,
 			      void *arg, int rc)
 {
+	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
 	struct osc_fsync_args *fa = arg;
+	unsigned long valid = 0;
 	struct ost_body *body;
+	struct cl_object *obj;
 
 	if (rc)
 		goto out;
@@ -379,15 +383,29 @@ static int osc_sync_interpret(const struct lu_env *env,
 	}
 
 	*fa->fa_oa = body->oa;
+	obj = osc2cl(fa->fa_obj);
+
+	/* Update osc object's blocks attribute */
+	cl_object_attr_lock(obj);
+	if (body->oa.o_valid & OBD_MD_FLBLOCKS) {
+		attr->cat_blocks = body->oa.o_blocks;
+		valid |= CAT_BLOCKS;
+	}
+
+	if (valid)
+		cl_object_attr_update(env, obj, attr, valid);
+	cl_object_attr_unlock(obj);
+
 out:
 	rc = fa->fa_upcall(fa->fa_cookie, rc);
 	return rc;
 }
 
-int osc_sync_base(struct obd_export *exp, struct obdo *oa,
+int osc_sync_base(struct osc_object *obj, struct obdo *oa,
 		  obd_enqueue_update_f upcall, void *cookie,
 		  struct ptlrpc_request_set *rqset)
 {
+	struct obd_export *exp = osc_export(obj);
 	struct ptlrpc_request *req;
 	struct ost_body *body;
 	struct osc_fsync_args *fa;
@@ -414,6 +432,7 @@ int osc_sync_base(struct obd_export *exp, struct obdo *oa,
 
 	CLASSERT(sizeof(*fa) <= sizeof(req->rq_async_args));
 	fa = ptlrpc_req_async_args(req);
+	fa->fa_obj = obj;
 	fa->fa_oa = oa;
 	fa->fa_upcall = upcall;
 	fa->fa_cookie = cookie;
-- 
1.7.1
