From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 May 2018 22:17:02 -0400
Subject: [lustre-devel] [PATCH 4/5] staging: lustre: mdc: excessive memory
 consumption by the xattr cache
In-Reply-To: <1526350623-4616-1-git-send-email-jsimmons@infradead.org>
References: <1526350623-4616-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1526350623-4616-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Andrew Perepechko <c17827@cray.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Andrew Perepechko <c17827@cray.com>

The refill operation of the xattr cache does not know the
reply size in advance, so it makes a guess based on
the maxeasize value returned by the MDS.

In practice, it allocates 16 KiB for the common case and
4 MiB for the large xattr case. However, a typical reply
is just a few hundred bytes.

If we follow the conservative approach, we can prepare a
single memory page for the reply. It is large enough for
any reasonable xattr set and, at the same time, it does
not require multiple page memory reclaim, which can be
costly.

If, for a specific file, the reply is larger than a single
page, the client is prepared to handle that and will fall back
to non-cached xattr code. Indeed, if this happens often and
xattrs are often used to store large values, it makes sense to
disable the xattr cache at all since it wasn't designed for
such [mis]use.

Signed-off-by: Andrew Perepechko <c17827@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9417
Reviewed-on: https://review.whamcloud.com/26887
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_locks.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 65a5341..a8aa0fa 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -315,6 +315,10 @@ static void mdc_realloc_openmsg(struct ptlrpc_request *req,
 	return req;
 }
 
+#define GA_DEFAULT_EA_NAME_LEN	20
+#define GA_DEFAULT_EA_VAL_LEN	250
+#define GA_DEFAULT_EA_NUM	10
+
 static struct ptlrpc_request *
 mdc_intent_getxattr_pack(struct obd_export *exp,
 			 struct lookup_intent *it,
@@ -323,7 +327,6 @@ static void mdc_realloc_openmsg(struct ptlrpc_request *req,
 	struct ptlrpc_request	*req;
 	struct ldlm_intent	*lit;
 	int rc, count = 0;
-	u32 maxdata;
 	LIST_HEAD(cancels);
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
@@ -341,20 +344,20 @@ static void mdc_realloc_openmsg(struct ptlrpc_request *req,
 	lit = req_capsule_client_get(&req->rq_pill, &RMF_LDLM_INTENT);
 	lit->opc = IT_GETXATTR;
 
-	maxdata = class_exp2cliimp(exp)->imp_connect_data.ocd_max_easize;
-
 	/* pack the intended request */
-	mdc_pack_body(req, &op_data->op_fid1, op_data->op_valid, maxdata, -1,
-		      0);
+	mdc_pack_body(req, &op_data->op_fid1, op_data->op_valid,
+		      GA_DEFAULT_EA_NAME_LEN * GA_DEFAULT_EA_NUM, -1, 0);
 
-	req_capsule_set_size(&req->rq_pill, &RMF_EADATA, RCL_SERVER, maxdata);
+	req_capsule_set_size(&req->rq_pill, &RMF_EADATA, RCL_SERVER,
+			     GA_DEFAULT_EA_NAME_LEN * GA_DEFAULT_EA_NUM);
 
-	req_capsule_set_size(&req->rq_pill, &RMF_EAVALS, RCL_SERVER, maxdata);
+	req_capsule_set_size(&req->rq_pill, &RMF_EAVALS, RCL_SERVER,
+			     GA_DEFAULT_EA_NAME_LEN * GA_DEFAULT_EA_NUM);
 
-	req_capsule_set_size(&req->rq_pill, &RMF_EAVALS_LENS,
-			     RCL_SERVER, maxdata);
+	req_capsule_set_size(&req->rq_pill, &RMF_EAVALS_LENS, RCL_SERVER,
+			     sizeof(u32) * GA_DEFAULT_EA_NUM);
 
-	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, maxdata);
+	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, 0);
 
 	ptlrpc_request_set_replen(req);
 
-- 
1.8.3.1
