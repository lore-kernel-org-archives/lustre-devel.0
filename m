From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:36 -0400
Subject: [lustre-devel] [PATCH 43/58] staging: lustre: const correct
	FID/OSTID/... helpers
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-44-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Add a const qualifier wherever possible to the pointer parameters of
the inline helper functions in lustre_idl.h and lustre_fid.h.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/8641
Reviewed-by: wangdi <di.wang@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |   28 ++++++++++----------
 drivers/staging/lustre/lustre/include/lustre_fid.h |    9 +++---
 2 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 87e79b9..c932e20 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1033,7 +1033,7 @@ static inline int lu_dirent_calc_size(int namelen, __u16 attr)
 	return (size + 7) & ~7;
 }
 
-static inline int lu_dirent_size(struct lu_dirent *ent)
+static inline int lu_dirent_size(const struct lu_dirent *ent)
 {
 	if (le16_to_cpu(ent->lde_reclen) == 0) {
 		return lu_dirent_calc_size(le16_to_cpu(ent->lde_namelen),
@@ -1067,7 +1067,7 @@ struct lustre_handle {
 
 #define DEAD_HANDLE_MAGIC 0xdeadbeefcafebabeULL
 
-static inline int lustre_handle_is_used(struct lustre_handle *lh)
+static inline int lustre_handle_is_used(const struct lustre_handle *lh)
 {
 	return lh->cookie != 0ull;
 }
@@ -1079,7 +1079,7 @@ static inline int lustre_handle_equal(const struct lustre_handle *lh1,
 }
 
 static inline void lustre_handle_copy(struct lustre_handle *tgt,
-				      struct lustre_handle *src)
+				      const struct lustre_handle *src)
 {
 	tgt->cookie = src->cookie;
 }
@@ -1570,25 +1570,25 @@ static inline void lmm_oi_set_id(struct ost_id *oi, __u64 oid)
 	oi->oi.oi_id = oid;
 }
 
-static inline __u64 lmm_oi_id(struct ost_id *oi)
+static inline __u64 lmm_oi_id(const struct ost_id *oi)
 {
 	return oi->oi.oi_id;
 }
 
-static inline __u64 lmm_oi_seq(struct ost_id *oi)
+static inline __u64 lmm_oi_seq(const struct ost_id *oi)
 {
 	return oi->oi.oi_seq;
 }
 
 static inline void lmm_oi_le_to_cpu(struct ost_id *dst_oi,
-				    struct ost_id *src_oi)
+				    const struct ost_id *src_oi)
 {
 	dst_oi->oi.oi_id = le64_to_cpu(src_oi->oi.oi_id);
 	dst_oi->oi.oi_seq = le64_to_cpu(src_oi->oi.oi_seq);
 }
 
 static inline void lmm_oi_cpu_to_le(struct ost_id *dst_oi,
-				    struct ost_id *src_oi)
+				    const struct ost_id *src_oi)
 {
 	dst_oi->oi.oi_id = cpu_to_le64(src_oi->oi.oi_id);
 	dst_oi->oi.oi_seq = cpu_to_le64(src_oi->oi.oi_seq);
@@ -2724,15 +2724,15 @@ struct ldlm_extent {
 
 #define LDLM_GID_ANY ((__u64)-1)
 
-static inline int ldlm_extent_overlap(struct ldlm_extent *ex1,
-				      struct ldlm_extent *ex2)
+static inline int ldlm_extent_overlap(const struct ldlm_extent *ex1,
+				      const struct ldlm_extent *ex2)
 {
 	return (ex1->start <= ex2->end) && (ex2->start <= ex1->end);
 }
 
 /* check if @ex1 contains @ex2 */
-static inline int ldlm_extent_contain(struct ldlm_extent *ex1,
-				      struct ldlm_extent *ex2)
+static inline int ldlm_extent_contain(const struct ldlm_extent *ex1,
+				      const struct ldlm_extent *ex2)
 {
 	return (ex1->start <= ex2->start) && (ex1->end >= ex2->end);
 }
@@ -3092,7 +3092,7 @@ enum agent_req_status {
 	ARS_SUCCEED,
 };
 
-static inline char *agent_req_status2name(enum agent_req_status ars)
+static inline const char *agent_req_status2name(const enum agent_req_status ars)
 {
 	switch (ars) {
 	case ARS_WAITING:
@@ -3268,7 +3268,7 @@ struct obdo {
 #define o_cksum   o_nlink
 #define o_grant_used o_data_version
 
-static inline void lustre_set_wire_obdo(struct obd_connect_data *ocd,
+static inline void lustre_set_wire_obdo(const struct obd_connect_data *ocd,
 					struct obdo *wobdo,
 					const struct obdo *lobdo)
 {
@@ -3287,7 +3287,7 @@ static inline void lustre_set_wire_obdo(struct obd_connect_data *ocd,
 	}
 }
 
-static inline void lustre_get_wire_obdo(struct obd_connect_data *ocd,
+static inline void lustre_get_wire_obdo(const struct obd_connect_data *ocd,
 					struct obdo *lobdo,
 					const struct obdo *wobdo)
 {
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index 61f3930..a85183b 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -483,7 +483,7 @@ fid_build_pdo_res_name(const struct lu_fid *fid, unsigned int hash,
  *    res will be built from normal FID directly, i.e. res[0] = f_seq,
  *    res[1] = f_oid + f_ver.
  */
-static inline void ostid_build_res_name(struct ost_id *oi,
+static inline void ostid_build_res_name(const struct ost_id *oi,
 					struct ldlm_res_id *name)
 {
 	memset(name, 0, sizeof(*name));
@@ -498,8 +498,8 @@ static inline void ostid_build_res_name(struct ost_id *oi,
 /**
  * Return true if the resource is for the object identified by this id & group.
  */
-static inline int ostid_res_name_eq(struct ost_id *oi,
-				    struct ldlm_res_id *name)
+static inline int ostid_res_name_eq(const struct ost_id *oi,
+				    const struct ldlm_res_id *name)
 {
 	/* Note: it is just a trick here to save some effort, probably the
 	 * correct way would be turn them into the FID and compare
@@ -610,7 +610,8 @@ static inline __u32 fid_flatten32(const struct lu_fid *fid)
 	return ino ? ino : fid_oid(fid);
 }
 
-static inline int lu_fid_diff(struct lu_fid *fid1, struct lu_fid *fid2)
+static inline int lu_fid_diff(const struct lu_fid *fid1,
+			      const struct lu_fid *fid2)
 {
 	LASSERTF(fid_seq(fid1) == fid_seq(fid2), "fid1:"DFID", fid2:"DFID"\n",
 		 PFID(fid1), PFID(fid2));
-- 
1.7.1
