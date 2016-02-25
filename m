From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:01:03 -0500
Subject: [lustre-devel] [PATCH v2 80/84] staging/lustre/lmv: Fix style vs
	open parenthesis alignment
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-81-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This mostly fixes checkpatch complaints about
"Alignment should match open parenthesis"

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/lmv/lmv_intent.c   |  2 +-
 drivers/staging/lustre/lustre/lmv/lmv_internal.h |  4 ++--
 drivers/staging/lustre/lustre/lmv/lmv_obd.c      | 28 +++++++++++-------------
 3 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 259b211..e0958ea 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -271,7 +271,7 @@ static int lmv_intent_lookup(struct obd_export *exp,
 	op_data->op_bias &= ~MDS_CROSS_REF;
 
 	rc = md_intent_lock(tgt->ltd_exp, op_data, lmm, lmmsize, it,
-			     flags, reqp, cb_blocking, extra_lock_flags);
+			    flags, reqp, cb_blocking, extra_lock_flags);
 
 	if (rc < 0 || !*reqp)
 		return rc;
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index 041d30f33..8a00871 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -78,8 +78,8 @@ static inline struct lmv_stripe_md *lmv_get_mea(struct ptlrpc_request *req)
 	if (mea->mea_count == 0)
 		return NULL;
 	if (mea->mea_magic != MEA_MAGIC_LAST_CHAR &&
-		mea->mea_magic != MEA_MAGIC_ALL_CHARS &&
-		mea->mea_magic != MEA_MAGIC_HASH_SEGMENT)
+	    mea->mea_magic != MEA_MAGIC_ALL_CHARS &&
+	    mea->mea_magic != MEA_MAGIC_HASH_SEGMENT)
 		return NULL;
 
 	return mea;
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index b5fc337..68afc29 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -339,9 +339,8 @@ static int lmv_connect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
 	}
 
 	CDEBUG(D_CONFIG, "connect to %s(%s) - %s, %s FOR %s\n",
-		mdc_obd->obd_name, mdc_obd->obd_uuid.uuid,
-		tgt->ltd_uuid.uuid, obd->obd_uuid.uuid,
-		cluuid->uuid);
+	       mdc_obd->obd_name, mdc_obd->obd_uuid.uuid,
+	       tgt->ltd_uuid.uuid, obd->obd_uuid.uuid, cluuid->uuid);
 
 	if (!mdc_obd->obd_set_up) {
 		CERROR("target %s is not set up\n", tgt->ltd_uuid.uuid);
@@ -397,8 +396,8 @@ static int lmv_connect_mdc(struct obd_device *obd, struct lmv_tgt_desc *tgt)
 			lmv->max_cookiesize, lmv->max_def_cookiesize);
 
 	CDEBUG(D_CONFIG, "Connected to %s(%s) successfully (%d)\n",
-		mdc_obd->obd_name, mdc_obd->obd_uuid.uuid,
-		atomic_read(&obd->obd_refcount));
+	       mdc_obd->obd_name, mdc_obd->obd_uuid.uuid,
+	       atomic_read(&obd->obd_refcount));
 
 	if (lmv->lmv_tgts_kobj)
 		/* Even if we failed to create the link, that's fine */
@@ -418,7 +417,7 @@ static void lmv_del_target(struct lmv_obd *lmv, int index)
 }
 
 static int lmv_add_target(struct obd_device *obd, struct obd_uuid *uuidp,
-			   __u32 index, int gen)
+			  __u32 index, int gen)
 {
 	struct lmv_obd      *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt;
@@ -776,7 +775,7 @@ static void lmv_hsm_req_build(struct lmv_obd *lmv,
 	nr_out = 0;
 	for (i = 0; i < hur_in->hur_request.hr_itemcount; i++) {
 		curr_tgt = lmv_find_target(lmv,
-					&hur_in->hur_user_item[i].hui_fid);
+					   &hur_in->hur_user_item[i].hui_fid);
 		if (obd_uuid_equals(&curr_tgt->ltd_uuid, &tgt_mds->ltd_uuid)) {
 			hur_out->hur_user_item[nr_out] =
 				hur_in->hur_user_item[i];
@@ -826,8 +825,7 @@ static int lmv_hsm_ct_register(struct lmv_obd *lmv, unsigned int cmd, int len,
 	 * except if it because of inactive target.
 	 */
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
-		err = obd_iocontrol(cmd, lmv->tgts[i]->ltd_exp,
-				   len, lk, uarg);
+		err = obd_iocontrol(cmd, lmv->tgts[i]->ltd_exp, len, lk, uarg);
 		if (err) {
 			if (lmv->tgts[i]->ltd_active) {
 				/* permanent error */
@@ -839,8 +837,8 @@ static int lmv_hsm_ct_register(struct lmv_obd *lmv, unsigned int cmd, int len,
 				/* unregister from previous MDS */
 				for (j = 0; j < i; j++)
 					obd_iocontrol(cmd,
-						  lmv->tgts[j]->ltd_exp,
-						  len, lk, uarg);
+						      lmv->tgts[j]->ltd_exp,
+						      len, lk, uarg);
 				return rc;
 			}
 			/* else: transient error.
@@ -907,8 +905,8 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 
 		/* copy UUID */
 		if (copy_to_user(data->ioc_pbuf2, obd2cli_tgt(mdc_obd),
-				     min((int) data->ioc_plen2,
-					 (int) sizeof(struct obd_uuid))))
+				 min((int)data->ioc_plen2,
+				     (int)sizeof(struct obd_uuid))))
 			return -EFAULT;
 
 		rc = obd_statfs(NULL, lmv->tgts[index]->ltd_exp, &stat_buf,
@@ -917,8 +915,8 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 		if (rc)
 			return rc;
 		if (copy_to_user(data->ioc_pbuf1, &stat_buf,
-				     min((int) data->ioc_plen1,
-					 (int) sizeof(stat_buf))))
+				 min((int)data->ioc_plen1,
+				     (int)sizeof(stat_buf))))
 			return -EFAULT;
 		break;
 	}
-- 
2.1.0
