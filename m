From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:11 -0500
Subject: [lustre-devel] [PATCH 203/622] lustre: mdc: Improve xattr buffer
 allocations
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-204-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

Many of the xattr related buffers in the mdc/mdt code are
allocated at max_easize, but they are used for normal POSIX
xattrs (primarily ACLs) and so they are guaranteed not to
exceed XATTR_SIZE_MAX.

HSM xattrs should also be less than XATTR_SIZE_MAX.

Reduce allocations to MIN(XATTR_SIZE_MAX, max_easize).

WC-bug-id: https://jira.whamcloud.com/browse/LU-11868
Lustre-commit: 4f78164f8748 ("LU-11868 mdc: Improve xattr buffer allocations")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34059
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_locks.c   |  9 ++++++---
 fs/lustre/mdc/mdc_reint.c   |  4 +++-
 fs/lustre/mdc/mdc_request.c | 14 ++++++++------
 3 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index f9d66a4..9898b6a 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -810,7 +810,9 @@ int mdc_enqueue_base(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 
 	generation = obddev->u.cli.cl_import->imp_generation;
 	if (!it || (it->it_op & (IT_OPEN | IT_CREAT)))
-		acl_bufsize = imp->imp_connect_data.ocd_max_easize;
+		acl_bufsize = min_t(u32,
+				    imp->imp_connect_data.ocd_max_easize,
+				    XATTR_SIZE_MAX);
 	else
 		acl_bufsize = LUSTRE_POSIX_ACL_MAX_SIZE_OLD;
 
@@ -936,10 +938,11 @@ int mdc_enqueue_base(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 
 	if ((int)lockrep->lock_policy_res2 == -ERANGE &&
 	    it->it_op & (IT_OPEN | IT_GETATTR | IT_LOOKUP) &&
-	    acl_bufsize != imp->imp_connect_data.ocd_max_easize) {
+	    acl_bufsize == LUSTRE_POSIX_ACL_MAX_SIZE_OLD) {
 		mdc_clear_replay_flag(req, -ERANGE);
 		ptlrpc_req_finished(req);
-		acl_bufsize = imp->imp_connect_data.ocd_max_easize;
+		acl_bufsize = min_t(u32, imp->imp_connect_data.ocd_max_easize,
+				    XATTR_SIZE_MAX);
 		goto resend;
 	}
 
diff --git a/fs/lustre/mdc/mdc_reint.c b/fs/lustre/mdc/mdc_reint.c
index 062685c..2611fc4 100644
--- a/fs/lustre/mdc/mdc_reint.c
+++ b/fs/lustre/mdc/mdc_reint.c
@@ -135,7 +135,9 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 	mdc_setattr_pack(req, op_data, ea, ealen);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER,
-			     req->rq_import->imp_connect_data.ocd_max_easize);
+			     min_t(u32,
+				   req->rq_import->imp_connect_data.ocd_max_easize,
+				   XATTR_SIZE_MAX));
 	ptlrpc_request_set_replen(req);
 
 	rc = mdc_reint(req, LUSTRE_IMP_FULL);
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index d702fd1..4711288 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -234,9 +234,10 @@ static int mdc_getattr(struct obd_export *exp, struct md_op_data *op_data,
 
 	rc = mdc_getattr_common(exp, req);
 	if (rc) {
-		if (rc == -ERANGE &&
-		    acl_bufsize != imp->imp_connect_data.ocd_max_easize) {
-			acl_bufsize = imp->imp_connect_data.ocd_max_easize;
+		if (rc == -ERANGE) {
+			acl_bufsize = min_t(u32,
+					    imp->imp_connect_data.ocd_max_easize,
+					    XATTR_SIZE_MAX);
 			mdc_reset_acl_req(req);
 			goto again;
 		}
@@ -289,9 +290,10 @@ static int mdc_getattr_name(struct obd_export *exp, struct md_op_data *op_data,
 
 	rc = mdc_getattr_common(exp, req);
 	if (rc) {
-		if (rc == -ERANGE &&
-		    acl_bufsize != imp->imp_connect_data.ocd_max_easize) {
-			acl_bufsize = imp->imp_connect_data.ocd_max_easize;
+		if (rc == -ERANGE) {
+			acl_bufsize = min_t(u32,
+					    imp->imp_connect_data.ocd_max_easize,
+					    XATTR_SIZE_MAX);
 			mdc_reset_acl_req(req);
 			goto again;
 		}
-- 
1.8.3.1
