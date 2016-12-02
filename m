From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 14:40:49 -0500
Subject: [lustre-devel] [PATCH 5/6] staging: lustre: headers: Move functions
	out of lustre_idl.h
In-Reply-To: <1480707650-24089-1-git-send-email-jsimmons@infradead.org>
References: <1480707650-24089-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480707650-24089-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Ben Evans <bevans@cray.com>, James Simmons <jsimmons@infradead.org>

From: Ben Evans <bevans@cray.com>

Migrate functions set/get_mrc_cr_flags, ldlm_res_eq
ldlm_extent_overlap, ldlm_extent_contain,
ldlm_request_bufsize, and alll the PTLRPC dump_*
functions out of lustre_idl.h which is a UAPI header
to the places in the kernel code they are actually used.
Delete unused lmv_mds_md_stripe_count and
agent_req_in_final_state.

Signed-off-by: Ben Evans <bevans@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: http://review.whamcloud.com/21484
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |   73 --------------------
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   13 ++++
 .../staging/lustre/lustre/include/lustre_swab.h    |    6 ++
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |    6 ++
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   27 +++++++
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |    6 ++
 6 files changed, 58 insertions(+), 73 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 52bef77..b0fef6d 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2126,17 +2126,6 @@ struct mdt_rec_create {
 	__u32	   cr_padding_4;   /* rr_padding_4 */
 };
 
-static inline void set_mrc_cr_flags(struct mdt_rec_create *mrc, __u64 flags)
-{
-	mrc->cr_flags_l = (__u32)(flags & 0xFFFFFFFFUll);
-	mrc->cr_flags_h = (__u32)(flags >> 32);
-}
-
-static inline __u64 get_mrc_cr_flags(struct mdt_rec_create *mrc)
-{
-	return ((__u64)(mrc->cr_flags_l) | ((__u64)mrc->cr_flags_h << 32));
-}
-
 /* instance of mdt_reint_rec */
 struct mdt_rec_link {
 	__u32	   lk_opcode;
@@ -2399,25 +2388,6 @@ static inline int lmv_mds_md_stripe_count_get(const union lmv_mds_md *lmm)
 	}
 }
 
-static inline int lmv_mds_md_stripe_count_set(union lmv_mds_md *lmm,
-					      unsigned int stripe_count)
-{
-	int rc = 0;
-
-	switch (le32_to_cpu(lmm->lmv_magic)) {
-	case LMV_MAGIC_V1:
-		lmm->lmv_md_v1.lmv_stripe_count = cpu_to_le32(stripe_count);
-		break;
-	case LMV_USER_MAGIC:
-		lmm->lmv_user_md.lum_stripe_count = cpu_to_le32(stripe_count);
-		break;
-	default:
-		rc = -EINVAL;
-		break;
-	}
-	return rc;
-}
-
 enum fld_rpc_opc {
 	FLD_QUERY	= 900,
 	FLD_READ	= 901,
@@ -2498,12 +2468,6 @@ struct ldlm_res_id {
 #define PLDLMRES(res)	(res)->lr_name.name[0], (res)->lr_name.name[1], \
 			(res)->lr_name.name[2], (res)->lr_name.name[3]
 
-static inline bool ldlm_res_eq(const struct ldlm_res_id *res0,
-			       const struct ldlm_res_id *res1)
-{
-	return !memcmp(res0, res1, sizeof(*res0));
-}
-
 /* lock types */
 enum ldlm_mode {
 	LCK_MINMODE = 0,
@@ -2536,19 +2500,6 @@ struct ldlm_extent {
 	__u64 gid;
 };
 
-static inline int ldlm_extent_overlap(const struct ldlm_extent *ex1,
-				      const struct ldlm_extent *ex2)
-{
-	return (ex1->start <= ex2->end) && (ex2->start <= ex1->end);
-}
-
-/* check if @ex1 contains @ex2 */
-static inline int ldlm_extent_contain(const struct ldlm_extent *ex1,
-				      const struct ldlm_extent *ex2)
-{
-	return (ex1->start <= ex2->start) && (ex1->end >= ex2->end);
-}
-
 struct ldlm_inodebits {
 	__u64 bits;
 };
@@ -2623,18 +2574,6 @@ struct ldlm_request {
 	struct lustre_handle lock_handle[LDLM_LOCKREQ_HANDLES];
 };
 
-/* If LDLM_ENQUEUE, 1 slot is already occupied, 1 is available.
- * Otherwise, 2 are available.
- */
-#define ldlm_request_bufsize(count, type)				\
-({								      \
-	int _avail = LDLM_LOCKREQ_HANDLES;			      \
-	_avail -= (type == LDLM_ENQUEUE ? LDLM_ENQUEUE_CANCEL_OFF : 0); \
-	sizeof(struct ldlm_request) +				   \
-	(count > _avail ? count - _avail : 0) *			 \
-	sizeof(struct lustre_handle);				   \
-})
-
 struct ldlm_reply {
 	__u32 lock_flags;
 	__u32 lock_padding;     /* also fix lustre_swab_ldlm_reply */
@@ -2938,12 +2877,6 @@ enum agent_req_status {
 	}
 }
 
-static inline bool agent_req_in_final_state(enum agent_req_status ars)
-{
-	return ((ars == ARS_SUCCEED) || (ars == ARS_FAILED) ||
-		(ars == ARS_CANCELED));
-}
-
 struct llog_agent_req_rec {
 	struct llog_rec_hdr	arr_hdr;	/**< record header */
 	__u32			arr_status;	/**< status of the request */
@@ -3138,12 +3071,6 @@ struct ll_fiemap_info_key {
 	struct fiemap	lfik_fiemap;
 };
 
-/* Functions for dumping PTLRPC fields */
-void dump_rniobuf(struct niobuf_remote *rnb);
-void dump_ioo(struct obd_ioobj *nb);
-void dump_ost_body(struct ost_body *ob);
-void dump_rcs(__u32 *rc);
-
 /* security opcodes */
 enum sec_cmd {
 	SEC_CTX_INIT	    = 801,
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index b7e61d0..0d7eb80 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -1339,5 +1339,18 @@ int ldlm_pool_init(struct ldlm_pool *pl, struct ldlm_namespace *ns,
 void ldlm_pool_del(struct ldlm_pool *pl, struct ldlm_lock *lock);
 /** @} */
 
+static inline int ldlm_extent_overlap(const struct ldlm_extent *ex1,
+				      const struct ldlm_extent *ex2)
+{
+	return ex1->start <= ex2->end && ex2->start <= ex1->end;
+}
+
+/* check if @ex1 contains @ex2 */
+static inline int ldlm_extent_contain(const struct ldlm_extent *ex1,
+				      const struct ldlm_extent *ex2)
+{
+	return ex1->start <= ex2->start && ex1->end >= ex2->end;
+}
+
 #endif
 /** @} LDLM */
diff --git a/drivers/staging/lustre/lustre/include/lustre_swab.h b/drivers/staging/lustre/lustre/include/lustre_swab.h
index 26d01c2..5c1bdc0 100644
--- a/drivers/staging/lustre/lustre/include/lustre_swab.h
+++ b/drivers/staging/lustre/lustre/include/lustre_swab.h
@@ -99,4 +99,10 @@ void lustre_swab_lov_user_md_objects(struct lov_user_ost_data *lod,
 void lustre_swab_close_data(struct close_data *data);
 void lustre_swab_lmv_user_md(struct lmv_user_md *lum);
 
+/* Functions for dumping PTLRPC fields */
+void dump_rniobuf(struct niobuf_remote *rnb);
+void dump_ioo(struct obd_ioobj *nb);
+void dump_ost_body(struct ost_body *ob);
+void dump_rcs(__u32 *rc);
+
 #endif
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 5c02501..d3a9609 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -334,3 +334,9 @@ void ldlm_flock_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
 				     union ldlm_policy_data *lpolicy);
 void ldlm_flock_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
 				     union ldlm_wire_policy_data *wpolicy);
+
+static inline bool ldlm_res_eq(const struct ldlm_res_id *res0,
+			       const struct ldlm_res_id *res1)
+{
+	return memcmp(res0, res1, sizeof(*res0)) == 0;
+}
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index c1f8693..cd6614b 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -83,6 +83,33 @@ struct ldlm_async_args {
 	struct lustre_handle lock_handle;
 };
 
+/**
+ * ldlm_request_bufsize
+ *
+ * @count:	number of ldlm handles
+ * @type:	ldlm opcode
+ *
+ * If opcode=LDLM_ENQUEUE, 1 slot is already occupied,
+ * LDLM_LOCKREQ_HANDLE -1 slots are available.
+ * Otherwise, LDLM_LOCKREQ_HANDLE slots are available.
+ *
+ * Return:	size of the request buffer
+ */
+int ldlm_request_bufsize(int count, int type)
+{
+	int avail = LDLM_LOCKREQ_HANDLES;
+
+	if (type == LDLM_ENQUEUE)
+		avail -= LDLM_ENQUEUE_CANCEL_OFF;
+
+	if (count > avail)
+		avail = (count - avail) * sizeof(struct lustre_handle);
+	else
+		avail = 0;
+
+	return sizeof(struct ldlm_request) + avail;
+}
+
 static int ldlm_expired_completion_wait(void *data)
 {
 	struct lock_wait_data *lwd = data;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index c1990f0..3b2ebbd 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -35,6 +35,12 @@
 #include "../include/lustre/lustre_idl.h"
 #include "mdc_internal.h"
 
+static void set_mrc_cr_flags(struct mdt_rec_create *mrc, u64 flags)
+{
+	mrc->cr_flags_l = (u32)(flags & 0xFFFFFFFFUll);
+	mrc->cr_flags_h = (u32)(flags >> 32);
+}
+
 static void __mdc_pack_body(struct mdt_body *b, __u32 suppgid)
 {
 	b->mbo_suppgid = suppgid;
-- 
1.7.1
