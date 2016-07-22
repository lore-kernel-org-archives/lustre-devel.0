From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:18 -0400
Subject: [lustre-devel] [PATCH 25/58] staging: lustre: lmv: remove unused
	lmv_get_mea function
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

The function lmv_get_mea() is not used so remove it.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/7043
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_internal.h |   24 ----------------------
 1 files changed, 0 insertions(+), 24 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index 471470b..ab01560 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -55,30 +55,6 @@ int __lmv_fid_alloc(struct lmv_obd *lmv, struct lu_fid *fid, u32 mds);
 int lmv_fid_alloc(struct obd_export *exp, struct lu_fid *fid,
 		  struct md_op_data *op_data);
 
-static inline struct lmv_stripe_md *lmv_get_mea(struct ptlrpc_request *req)
-{
-	struct mdt_body	 *body;
-	struct lmv_stripe_md    *mea;
-
-	LASSERT(req);
-
-	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
-
-	if (!body || !S_ISDIR(body->mode) || !body->eadatasize)
-		return NULL;
-
-	mea = req_capsule_server_sized_get(&req->rq_pill, &RMF_MDT_MD,
-					   body->eadatasize);
-	if (mea->mea_count == 0)
-		return NULL;
-	if (mea->mea_magic != MEA_MAGIC_LAST_CHAR &&
-	    mea->mea_magic != MEA_MAGIC_ALL_CHARS &&
-	    mea->mea_magic != MEA_MAGIC_HASH_SEGMENT)
-		return NULL;
-
-	return mea;
-}
-
 static inline int lmv_get_easize(struct lmv_obd *lmv)
 {
 	return sizeof(struct lmv_stripe_md) +
-- 
1.7.1
