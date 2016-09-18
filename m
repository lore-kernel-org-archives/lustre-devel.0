From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:27 -0400
Subject: [lustre-devel] [PATCH 028/124] staging: lustre: ldlm: resend AST
	callbacks
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Vitaly Fertman <vitaly_fertman@xyratex.com>, James Simmons <jsimmons@infradead.org>

From: Vitaly Fertman <vitaly_fertman@xyratex.com>

While clients will resend client->server RPCs, servers would not
resend server->client RPCs such as LDLM callbacks (blocking
or completion callbacks/ASTs).  This could result in clients being
evicted from the server if blocking callbacks were dropped by the
network (a failed router or lossy network) and the client did not
cancel the requested lock in time.
In order to fix this problem, this patch adds the ability to resend
LDLM callbacks from the server and give the client a chance to
respond within the timeout period before it is evicted:

 - resend BL AST within lock callback timeout period;
 - still do not resend CANCEL_ON_BLOCK;
 - regular resend for CP AST without BL AST embedded;
 - prolong lock callback timeout on resend;

some fixes:
 - recovery-small test_10 to actually evict the client
   with dropped BL AST;
 - ETIMEDOUT to be returned if send limit is expired;

Signed-off-by: Vitaly Fertman <vitaly_fertman@xyratex.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5520
Reviewed-by: Alexey Lyashkov <Alexey_Lyashkov@xyratex.com>
Reviewed-by: Andriy Skulysh <Andriy_Skulysh@xyratex.com>
Xyratex-bug-id: MRP-417
Reviewed-on: http://review.whamcloud.com/9335
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Johann Lombardi <johann.lombardi@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_reint.c |    9 +++------
 drivers/staging/lustre/lustre/ptlrpc/client.c |    4 ++--
 2 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index c018e3b..af5c92c 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -113,8 +113,7 @@ int mdc_setattr(struct obd_export *exp, struct md_op_data *op_data,
 	if (op_data->op_attr.ia_valid & (ATTR_MODE | ATTR_UID | ATTR_GID))
 		bits |= MDS_INODELOCK_LOOKUP;
 	if ((op_data->op_flags & MF_MDC_CANCEL_FID1) &&
-	    (fid_is_sane(&op_data->op_fid1)) &&
-	    !OBD_FAIL_CHECK(OBD_FAIL_LDLM_BL_CALLBACK_NET))
+	    (fid_is_sane(&op_data->op_fid1)))
 		count = mdc_resource_get_unused(exp, &op_data->op_fid1,
 						&cancels, LCK_EX, bits);
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
@@ -305,14 +304,12 @@ int mdc_unlink(struct obd_export *exp, struct md_op_data *op_data,
 	LASSERT(!req);
 
 	if ((op_data->op_flags & MF_MDC_CANCEL_FID1) &&
-	    (fid_is_sane(&op_data->op_fid1)) &&
-	    !OBD_FAIL_CHECK(OBD_FAIL_LDLM_BL_CALLBACK_NET))
+	    (fid_is_sane(&op_data->op_fid1)))
 		count = mdc_resource_get_unused(exp, &op_data->op_fid1,
 						&cancels, LCK_EX,
 						MDS_INODELOCK_UPDATE);
 	if ((op_data->op_flags & MF_MDC_CANCEL_FID3) &&
-	    (fid_is_sane(&op_data->op_fid3)) &&
-	    !OBD_FAIL_CHECK(OBD_FAIL_LDLM_BL_CALLBACK_NET))
+	    (fid_is_sane(&op_data->op_fid3)))
 		count += mdc_resource_get_unused(exp, &op_data->op_fid3,
 						 &cancels, LCK_EX,
 						 MDS_INODELOCK_FULL);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index bae91bd..bea1c16 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -1037,8 +1037,8 @@ static int ptlrpc_import_delay_req(struct obd_import *imp,
 		*status = -EIO;
 	} else if (ptlrpc_send_limit_expired(req)) {
 		/* probably doesn't need to be a D_ERROR after initial testing */
-		DEBUG_REQ(D_ERROR, req, "send limit expired ");
-		*status = -EIO;
+		DEBUG_REQ(D_HA, req, "send limit expired ");
+		*status = -ETIMEDOUT;
 	} else if (req->rq_send_state == LUSTRE_IMP_CONNECTING &&
 		   imp->imp_state == LUSTRE_IMP_CONNECTING) {
 		/* allow CONNECT even if import is invalid */
-- 
1.7.1
