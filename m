From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:37 -0400
Subject: [lustre-devel] [PATCH 44/58] staging: lustre: use bool for several
	function in lustre_idl.h/lustre_fid.h
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-45-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Change the return type of several predicate functions from int to bool.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/8641
Reviewed-by: wangdi <di.wang@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |   72 ++++++++++----------
 drivers/staging/lustre/lustre/include/lustre_fid.h |    4 +-
 2 files changed, 38 insertions(+), 38 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index c932e20..d3a9db9 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -196,12 +196,12 @@ static inline unsigned fld_range_type(const struct lu_seq_range *range)
 	return range->lsr_flags & LU_SEQ_RANGE_MASK;
 }
 
-static inline int fld_range_is_ost(const struct lu_seq_range *range)
+static inline bool fld_range_is_ost(const struct lu_seq_range *range)
 {
 	return fld_range_type(range) == LU_SEQ_RANGE_OST;
 }
 
-static inline int fld_range_is_mdt(const struct lu_seq_range *range)
+static inline bool fld_range_is_mdt(const struct lu_seq_range *range)
 {
 	return fld_range_type(range) == LU_SEQ_RANGE_MDT;
 }
@@ -260,23 +260,23 @@ static inline void range_init(struct lu_seq_range *range)
  * check if given seq id \a s is within given range \a r
  */
 
-static inline int range_within(const struct lu_seq_range *range,
-			       __u64 s)
+static inline bool range_within(const struct lu_seq_range *range,
+				__u64 s)
 {
 	return s >= range->lsr_start && s < range->lsr_end;
 }
 
-static inline int range_is_sane(const struct lu_seq_range *range)
+static inline bool range_is_sane(const struct lu_seq_range *range)
 {
 	return (range->lsr_end >= range->lsr_start);
 }
 
-static inline int range_is_zero(const struct lu_seq_range *range)
+static inline bool range_is_zero(const struct lu_seq_range *range)
 {
 	return (range->lsr_start == 0 && range->lsr_end == 0);
 }
 
-static inline int range_is_exhausted(const struct lu_seq_range *range)
+static inline bool range_is_exhausted(const struct lu_seq_range *range)
 
 {
 	return range_space(range) == 0;
@@ -437,69 +437,69 @@ enum dot_lustre_oid {
 	FID_OID_DOT_LUSTRE_OBF = 2UL,
 };
 
-static inline int fid_seq_is_mdt0(__u64 seq)
+static inline bool fid_seq_is_mdt0(__u64 seq)
 {
 	return (seq == FID_SEQ_OST_MDT0);
 }
 
-static inline int fid_seq_is_mdt(__u64 seq)
+static inline bool fid_seq_is_mdt(__u64 seq)
 {
 	return seq == FID_SEQ_OST_MDT0 || seq >= FID_SEQ_NORMAL;
 };
 
-static inline int fid_seq_is_echo(__u64 seq)
+static inline bool fid_seq_is_echo(__u64 seq)
 {
 	return (seq == FID_SEQ_ECHO);
 }
 
-static inline int fid_is_echo(const struct lu_fid *fid)
+static inline bool fid_is_echo(const struct lu_fid *fid)
 {
 	return fid_seq_is_echo(fid_seq(fid));
 }
 
-static inline int fid_seq_is_llog(__u64 seq)
+static inline bool fid_seq_is_llog(__u64 seq)
 {
 	return (seq == FID_SEQ_LLOG);
 }
 
-static inline int fid_is_llog(const struct lu_fid *fid)
+static inline bool fid_is_llog(const struct lu_fid *fid)
 {
 	/* file with OID == 0 is not llog but contains last oid */
 	return fid_seq_is_llog(fid_seq(fid)) && fid_oid(fid) > 0;
 }
 
-static inline int fid_seq_is_rsvd(__u64 seq)
+static inline bool fid_seq_is_rsvd(__u64 seq)
 {
 	return (seq > FID_SEQ_OST_MDT0 && seq <= FID_SEQ_RSVD);
 };
 
-static inline int fid_seq_is_special(__u64 seq)
+static inline bool fid_seq_is_special(__u64 seq)
 {
 	return seq == FID_SEQ_SPECIAL;
 };
 
-static inline int fid_seq_is_local_file(__u64 seq)
+static inline bool fid_seq_is_local_file(__u64 seq)
 {
 	return seq == FID_SEQ_LOCAL_FILE ||
 	       seq == FID_SEQ_LOCAL_NAME;
 };
 
-static inline int fid_seq_is_root(__u64 seq)
+static inline bool fid_seq_is_root(__u64 seq)
 {
 	return seq == FID_SEQ_ROOT;
 }
 
-static inline int fid_seq_is_dot(__u64 seq)
+static inline bool fid_seq_is_dot(__u64 seq)
 {
 	return seq == FID_SEQ_DOT_LUSTRE;
 }
 
-static inline int fid_seq_is_default(__u64 seq)
+static inline bool fid_seq_is_default(__u64 seq)
 {
 	return seq == FID_SEQ_LOV_DEFAULT;
 }
 
-static inline int fid_is_mdt0(const struct lu_fid *fid)
+static inline bool fid_is_mdt0(const struct lu_fid *fid)
 {
 	return fid_seq_is_mdt0(fid_seq(fid));
 }
@@ -516,12 +516,12 @@ static inline void lu_root_fid(struct lu_fid *fid)
  * \param fid the fid to be tested.
  * \return true if the fid is a igif; otherwise false.
  */
-static inline int fid_seq_is_igif(__u64 seq)
+static inline bool fid_seq_is_igif(__u64 seq)
 {
 	return seq >= FID_SEQ_IGIF && seq <= FID_SEQ_IGIF_MAX;
 }
 
-static inline int fid_is_igif(const struct lu_fid *fid)
+static inline bool fid_is_igif(const struct lu_fid *fid)
 {
 	return fid_seq_is_igif(fid_seq(fid));
 }
@@ -531,27 +531,27 @@ static inline int fid_is_igif(const struct lu_fid *fid)
  * \param fid the fid to be tested.
  * \return true if the fid is a idif; otherwise false.
  */
-static inline int fid_seq_is_idif(__u64 seq)
+static inline bool fid_seq_is_idif(__u64 seq)
 {
 	return seq >= FID_SEQ_IDIF && seq <= FID_SEQ_IDIF_MAX;
 }
 
-static inline int fid_is_idif(const struct lu_fid *fid)
+static inline bool fid_is_idif(const struct lu_fid *fid)
 {
 	return fid_seq_is_idif(fid_seq(fid));
 }
 
-static inline int fid_is_local_file(const struct lu_fid *fid)
+static inline bool fid_is_local_file(const struct lu_fid *fid)
 {
 	return fid_seq_is_local_file(fid_seq(fid));
 }
 
-static inline int fid_seq_is_norm(__u64 seq)
+static inline bool fid_seq_is_norm(__u64 seq)
 {
 	return (seq >= FID_SEQ_NORMAL);
 }
 
-static inline int fid_is_norm(const struct lu_fid *fid)
+static inline bool fid_is_norm(const struct lu_fid *fid)
 {
 	return fid_seq_is_norm(fid_seq(fid));
 }
@@ -769,7 +769,7 @@ static inline int fid_to_ostid(const struct lu_fid *fid, struct ost_id *ostid)
 }
 
 /* Check whether the fid is for LAST_ID */
-static inline int fid_is_last_id(const struct lu_fid *fid)
+static inline bool fid_is_last_id(const struct lu_fid *fid)
 {
 	return (fid_oid(fid) == 0);
 }
@@ -838,7 +838,7 @@ static inline void fid_be_to_cpu(struct lu_fid *dst, const struct lu_fid *src)
 	dst->f_ver = be32_to_cpu(fid_ver(src));
 }
 
-static inline int fid_is_sane(const struct lu_fid *fid)
+static inline bool fid_is_sane(const struct lu_fid *fid)
 {
 	return fid &&
 	       ((fid_seq(fid) >= FID_SEQ_START && fid_ver(fid) == 0) ||
@@ -846,7 +846,7 @@ static inline int fid_is_sane(const struct lu_fid *fid)
 		fid_seq_is_rsvd(fid_seq(fid)));
 }
 
-static inline int fid_is_zero(const struct lu_fid *fid)
+static inline bool fid_is_zero(const struct lu_fid *fid)
 {
 	return fid_seq(fid) == 0 && fid_oid(fid) == 0;
 }
@@ -854,7 +854,7 @@ static inline int fid_is_zero(const struct lu_fid *fid)
 void lustre_swab_lu_fid(struct lu_fid *fid);
 void lustre_swab_lu_seq_range(struct lu_seq_range *range);
 
-static inline int lu_fid_eq(const struct lu_fid *f0, const struct lu_fid *f1)
+static inline bool lu_fid_eq(const struct lu_fid *f0, const struct lu_fid *f1)
 {
 	return memcmp(f0, f1, sizeof(*f0)) == 0;
 }
@@ -1067,13 +1067,13 @@ struct lustre_handle {
 
 #define DEAD_HANDLE_MAGIC 0xdeadbeefcafebabeULL
 
-static inline int lustre_handle_is_used(const struct lustre_handle *lh)
+static inline bool lustre_handle_is_used(const struct lustre_handle *lh)
 {
 	return lh->cookie != 0ull;
 }
 
-static inline int lustre_handle_equal(const struct lustre_handle *lh1,
-				      const struct lustre_handle *lh2)
+static inline bool lustre_handle_equal(const struct lustre_handle *lh1,
+				       const struct lustre_handle *lh2)
 {
 	return lh1->cookie == lh2->cookie;
 }
@@ -2684,8 +2684,8 @@ struct ldlm_res_id {
 #define PLDLMRES(res)	(res)->lr_name.name[0], (res)->lr_name.name[1], \
 			(res)->lr_name.name[2], (res)->lr_name.name[3]
 
-static inline int ldlm_res_eq(const struct ldlm_res_id *res0,
-			      const struct ldlm_res_id *res1)
+static inline bool ldlm_res_eq(const struct ldlm_res_id *res0,
+			       const struct ldlm_res_id *res1)
 {
 	return !memcmp(res0, res1, sizeof(*res0));
 }
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index a85183b..6f7dc15 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -406,8 +406,8 @@ fid_build_reg_res_name(const struct lu_fid *fid, struct ldlm_res_id *res)
 /*
  * Return true if resource is for object identified by FID.
  */
-static inline int fid_res_name_eq(const struct lu_fid *fid,
-				  const struct ldlm_res_id *res)
+static inline bool fid_res_name_eq(const struct lu_fid *fid,
+				   const struct ldlm_res_id *res)
 {
 	return res->name[LUSTRE_RES_ID_SEQ_OFF] == fid_seq(fid) &&
 	       res->name[LUSTRE_RES_ID_VER_OID_OFF] == fid_ver_oid(fid);
-- 
1.7.1
