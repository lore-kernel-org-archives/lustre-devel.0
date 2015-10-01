From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:24 -0400
Subject: [lustre-devel] [PATCH 14/32] staging/lustre/ldlm: Remove unused
	ldlm_enqueue_pack()
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-15-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Not used anywhere

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |  1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 21 ---------------------
 2 files changed, 22 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index ce91ccc..72c52ef 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -1307,7 +1307,6 @@ int ldlm_prep_elc_req(struct obd_export *exp,
 		      int version, int opc, int canceloff,
 		      struct list_head *cancels, int count);
 
-struct ptlrpc_request *ldlm_enqueue_pack(struct obd_export *exp, int lvb_len);
 int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 			  ldlm_type_t type, __u8 with_policy, ldlm_mode_t mode,
 			  __u64 *flags, void *lvb, __u32 lvb_len,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 9856133..c73661c 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -742,27 +742,6 @@ int ldlm_prep_enqueue_req(struct obd_export *exp, struct ptlrpc_request *req,
 }
 EXPORT_SYMBOL(ldlm_prep_enqueue_req);
 
-struct ptlrpc_request *ldlm_enqueue_pack(struct obd_export *exp, int lvb_len)
-{
-	struct ptlrpc_request *req;
-	int rc;
-
-	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_LDLM_ENQUEUE);
-	if (req == NULL)
-		return ERR_PTR(-ENOMEM);
-
-	rc = ldlm_prep_enqueue_req(exp, req, NULL, 0);
-	if (rc) {
-		ptlrpc_request_free(req);
-		return ERR_PTR(rc);
-	}
-
-	req_capsule_set_size(&req->rq_pill, &RMF_DLM_LVB, RCL_SERVER, lvb_len);
-	ptlrpc_request_set_replen(req);
-	return req;
-}
-EXPORT_SYMBOL(ldlm_enqueue_pack);
-
 /**
  * Client-side lock enqueue.
  *
-- 
2.1.0
