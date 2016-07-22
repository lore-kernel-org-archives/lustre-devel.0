From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:38 -0400
Subject: [lustre-devel] [PATCH 45/58] staging: lustre: simplify inline
	functions in lustre_fid.h
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-46-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Several inline functions return a structure that was passed in.
Their is no need for this so just make these function void.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/8641
Reviewed-by: wangdi <di.wang@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_fid.h |   16 ++++------------
 1 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index 6f7dc15..f1d5bbd 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -393,14 +393,12 @@ struct ldlm_namespace;
  * but was moved into name[1] along with the OID to avoid consuming the
  * renaming name[2,3] fields that need to be used for the quota identifier.
  */
-static inline struct ldlm_res_id *
+static inline void
 fid_build_reg_res_name(const struct lu_fid *fid, struct ldlm_res_id *res)
 {
 	memset(res, 0, sizeof(*res));
 	res->name[LUSTRE_RES_ID_SEQ_OFF] = fid_seq(fid);
 	res->name[LUSTRE_RES_ID_VER_OID_OFF] = fid_ver_oid(fid);
-
-	return res;
 }
 
 /*
@@ -416,29 +414,25 @@ static inline bool fid_res_name_eq(const struct lu_fid *fid,
 /*
  * Extract FID from LDLM resource. Reverse of fid_build_reg_res_name().
  */
-static inline struct lu_fid *
+static inline void
 fid_extract_from_res_name(struct lu_fid *fid, const struct ldlm_res_id *res)
 {
 	fid->f_seq = res->name[LUSTRE_RES_ID_SEQ_OFF];
 	fid->f_oid = (__u32)(res->name[LUSTRE_RES_ID_VER_OID_OFF]);
 	fid->f_ver = (__u32)(res->name[LUSTRE_RES_ID_VER_OID_OFF] >> 32);
 	LASSERT(fid_res_name_eq(fid, res));
-
-	return fid;
 }
 
 /*
  * Build (DLM) resource identifier from global quota FID and quota ID.
  */
-static inline struct ldlm_res_id *
+static inline void
 fid_build_quota_res_name(const struct lu_fid *glb_fid, union lquota_id *qid,
 			 struct ldlm_res_id *res)
 {
 	fid_build_reg_res_name(glb_fid, res);
 	res->name[LUSTRE_RES_ID_QUOTA_SEQ_OFF] = fid_seq(&qid->qid_fid);
 	res->name[LUSTRE_RES_ID_QUOTA_VER_OID_OFF] = fid_ver_oid(&qid->qid_fid);
-
-	return res;
 }
 
 /*
@@ -455,14 +449,12 @@ static inline void fid_extract_from_quota_res(struct lu_fid *glb_fid,
 		(__u32)(res->name[LUSTRE_RES_ID_QUOTA_VER_OID_OFF] >> 32);
 }
 
-static inline struct ldlm_res_id *
+static inline void
 fid_build_pdo_res_name(const struct lu_fid *fid, unsigned int hash,
 		       struct ldlm_res_id *res)
 {
 	fid_build_reg_res_name(fid, res);
 	res->name[LUSTRE_RES_ID_HSH_OFF] = hash;
-
-	return res;
 }
 
 /**
-- 
1.7.1
