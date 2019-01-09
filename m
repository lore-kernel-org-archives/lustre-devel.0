From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:03 +1100
Subject: [lustre-devel] [PATCH 29/29] lustre: centralize handling of
 PTLRPCD_SET
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504291.26726.3018163382085938859.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Various places test if a given rqset is PTLRPCD_SET
and call either ptlrpcd_add_req() or ptlrpc_set_add_req()
depending on the result.

This can be unified by putting the test of PTLRPCD_SET in
ptlrpc_set_add_req(), and always calling that function.

This results in the being only one place that tests PTLRPCD_SET.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |    1 +
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    2 -
 drivers/staging/lustre/lustre/osc/osc_request.c    |   27 ++++----------------
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    5 ++++
 4 files changed, 11 insertions(+), 24 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 6d328b48a96b..e665f70e54a8 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -1832,6 +1832,7 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set);
 int ptlrpc_set_wait(struct ptlrpc_request_set *);
 void ptlrpc_set_destroy(struct ptlrpc_request_set *);
 void ptlrpc_set_add_req(struct ptlrpc_request_set *, struct ptlrpc_request *);
+#define PTLRPCD_SET ((struct ptlrpc_request_set*)1)
 
 void ptlrpc_free_rq_pool(struct ptlrpc_request_pool *pool);
 int ptlrpc_add_rqs_to_pool(struct ptlrpc_request_pool *pool, int num_rq);
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 586f0dfe3790..c61ef894177b 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -99,8 +99,6 @@ void osc_update_next_shrink(struct client_obd *cli);
  */
 #include <cl_object.h>
 
-extern struct ptlrpc_request_set *PTLRPCD_SET;
-
 typedef int (*osc_enqueue_upcall_f)(void *cookie, struct lustre_handle *lockh,
 				    int rc);
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index c2239c99a7b2..87cc8c72f6e6 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -266,10 +266,7 @@ int osc_setattr_async(struct obd_export *exp, struct obdo *oa,
 		sa->sa_upcall = upcall;
 		sa->sa_cookie = cookie;
 
-		if (rqset == PTLRPCD_SET)
-			ptlrpcd_add_req(req);
-		else
-			ptlrpc_set_add_req(rqset, req);
+		ptlrpc_set_add_req(rqset, req);
 	}
 
 	return 0;
@@ -354,10 +351,7 @@ int osc_ladvise_base(struct obd_export *exp, struct obdo *oa,
 	la->la_upcall = upcall;
 	la->la_cookie = cookie;
 
-	if (rqset == PTLRPCD_SET)
-		ptlrpcd_add_req(req);
-	else
-		ptlrpc_set_add_req(rqset, req);
+	ptlrpc_set_add_req(rqset, req);
 
 	return 0;
 }
@@ -450,10 +444,7 @@ int osc_punch_base(struct obd_export *exp, struct obdo *oa,
 	sa->sa_oa = oa;
 	sa->sa_upcall = upcall;
 	sa->sa_cookie = cookie;
-	if (rqset == PTLRPCD_SET)
-		ptlrpcd_add_req(req);
-	else
-		ptlrpc_set_add_req(rqset, req);
+	ptlrpc_set_add_req(rqset, req);
 
 	return 0;
 }
@@ -533,10 +524,7 @@ int osc_sync_base(struct osc_object *obj, struct obdo *oa,
 	fa->fa_upcall = upcall;
 	fa->fa_cookie = cookie;
 
-	if (rqset == PTLRPCD_SET)
-		ptlrpcd_add_req(req);
-	else
-		ptlrpc_set_add_req(rqset, req);
+	ptlrpc_set_add_req(rqset, req);
 
 	return 0;
 }
@@ -2148,8 +2136,6 @@ static int osc_enqueue_interpret(const struct lu_env *env,
 	return rc;
 }
 
-struct ptlrpc_request_set *PTLRPCD_SET = (void *)1;
-
 /* When enqueuing asynchronously, locks are not ordered, we can obtain a lock
  * from the 2nd OSC before a lock from the 1st one. This does not deadlock with
  * other synchronous requests, however keeping some locks and trying to obtain
@@ -2291,10 +2277,7 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 
 			req->rq_interpret_reply =
 				(ptlrpc_interpterer_t)osc_enqueue_interpret;
-			if (rqset == PTLRPCD_SET)
-				ptlrpcd_add_req(req);
-			else
-				ptlrpc_set_add_req(rqset, req);
+			ptlrpc_set_add_req(rqset, req);
 		} else if (intent) {
 			ptlrpc_req_finished(req);
 		}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index f90a3eef5daf..110bb5d8f767 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -1048,6 +1048,11 @@ EXPORT_SYMBOL(ptlrpc_set_destroy);
 void ptlrpc_set_add_req(struct ptlrpc_request_set *set,
 			struct ptlrpc_request *req)
 {
+	if (set == PTLRPCD_SET) {
+		ptlrpcd_add_req(req);
+		return;
+	}
+
 	LASSERT(list_empty(&req->rq_set_chain));
 
 	/* The set takes over the caller's request reference */
