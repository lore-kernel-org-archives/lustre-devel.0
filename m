From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Dec 2018 11:29:51 -0500
Subject: [lustre-devel] [PATCH 17/28] lustre: pfl: enhance PFID EA for PFL
In-Reply-To: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1545064202-22483-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Fan Yong <fan.yong@intel.com>

This is a misc patch that contains some adjustments to
store more stripe information in the OST-object's PFID
EA (XATTR_NAME_FID). It is client duty to transfer the
stripe and PFL information to the OST via the write,
setattr and punch RPC. Then OST will store these
information in the PFID EA.

Signed-off-by: Fan Yong <fan.yong@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8998
Reviewed-on: https://review.whamcloud.com/24882
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/uapi/linux/lustre/lustre_idl.h  | 14 ++++--
 .../lustre/include/uapi/linux/lustre/lustre_user.h | 17 +++----
 drivers/staging/lustre/lustre/include/cl_object.h  |  1 +
 drivers/staging/lustre/lustre/lov/lov_internal.h   | 16 ++++++
 drivers/staging/lustre/lustre/lov/lov_io.c         |  2 +
 drivers/staging/lustre/lustre/lov/lovsub_object.c  |  4 ++
 drivers/staging/lustre/lustre/osc/osc_io.c         |  4 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    | 13 ++++-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 58 +++++++++++++---------
 9 files changed, 89 insertions(+), 40 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index e47eb52..f7a065e 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -1134,6 +1134,7 @@ static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 							    */
 
 #define OBD_MD_DEFAULT_MEA	(0x0040000000000000ULL) /* default MEA */
+#define OBD_MD_FLOSTLAYOUT	(0x0080000000000000ULL)	/* contain ost_layout */
 #define OBD_MD_FLPROJID		(0x0100000000000000ULL) /* project ID */
 
 #define OBD_MD_FLALLQUOTA (OBD_MD_FLUSRQUOTA | \
@@ -2625,9 +2626,16 @@ struct obdo {
 	__u32		o_parent_ver;
 	struct lustre_handle    o_handle;  /* brw: lock handle to prolong locks
 					    */
-	struct llog_cookie      o_lcookie; /* destroy: unlink cookie from MDS,
-					    * obsolete in 2.8, reused in OSP
-					    */
+	/* Originally, the field is llog_cookie for destroy with unlink cookie
+	 * from MDS, it is obsolete in 2.8. Then reuse it by client to transfer
+	 * layout and PFL information in IO, setattr RPCs. Since llog_cookie is
+	 * not used on wire any longer, remove it from the obdo, then it can be
+	 * enlarged freely in the further without affect related RPCs.
+	 *
+	 * sizeof(ost_layout) + sizeof(__u32) == sizeof(llog_cookie).
+	 */
+	struct ost_layout	o_layout;
+	__u32			o_padding_3;
 	__u32		o_uid_h;
 	__u32		o_gid_h;
 
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
index 67b2ae4..8e6d67b 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
@@ -154,16 +154,13 @@ static inline bool fid_is_zero(const struct lu_fid *fid)
 	return !fid->f_seq && !fid->f_oid;
 }
 
-struct filter_fid {
-	struct lu_fid	ff_parent;  /* ff_parent.f_ver == file stripe number */
-};
-
-/* keep this one for compatibility */
-struct filter_fid_old {
-	struct lu_fid	ff_parent;
-	__u64		ff_objid;
-	__u64		ff_seq;
-};
+struct ost_layout {
+	__u32	ol_stripe_size;
+	__u32	ol_stripe_count;
+	__u64	ol_comp_start;
+	__u64	ol_comp_end;
+	__u32	ol_comp_id;
+} __packed;
 
 /* Userspace should treat lu_fid as opaque, and only use the following methods
  * to print or parse them.  Other functions (e.g. compare, swab) could be moved
diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index a1e07f8..d0edeb7c 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1784,6 +1784,7 @@ struct cl_io {
 			unsigned int     sa_avalid;
 			unsigned int		sa_xvalid; /* OP_XVALID */
 			int		sa_stripe_index;
+			struct ost_layout	 sa_layout;
 			const struct lu_fid	*sa_parent_fid;
 		} ci_setattr;
 		struct cl_data_version_io {
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 9c0a4f7..e8102df 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -304,4 +304,20 @@ static inline struct obd_device *lov2obd(const struct lov_obd *lov)
 	return container_of_safe(lov, struct obd_device, u.lov);
 }
 
+static inline void lov_lsm2layout(struct lov_stripe_md *lsm,
+				  struct lov_stripe_md_entry *lsme,
+				  struct ost_layout *ol)
+{
+	ol->ol_stripe_size = lsme->lsme_stripe_size;
+	ol->ol_stripe_count = lsme->lsme_stripe_count;
+	if (lsm->lsm_magic == LOV_MAGIC_COMP_V1) {
+		ol->ol_comp_start = lsme->lsme_extent.e_start;
+		ol->ol_comp_end = lsme->lsme_extent.e_end;
+		ol->ol_comp_id = lsme->lsme_id;
+	} else {
+		ol->ol_comp_start = 0;
+		ol->ol_comp_end = 0;
+		ol->ol_comp_id = 0;
+	}
+}
 #endif
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index d9b2a81..70908b1 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -316,6 +316,8 @@ static void lov_io_sub_inherit(struct lov_io_sub *sub, struct lov_io *lio,
 						      stripe);
 			io->u.ci_setattr.sa_attr.lvb_size = new_size;
 		}
+		lov_lsm2layout(lsm, lsm->lsm_entries[index],
+			       &io->u.ci_setattr.sa_layout);
 		break;
 	}
 	case CIT_DATA_VERSION: {
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_object.c b/drivers/staging/lustre/lustre/lov/lovsub_object.c
index ca7c8a0..da4b7f1 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_object.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_object.c
@@ -131,6 +131,7 @@ static void lovsub_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 				struct cl_req_attr *attr)
 {
 	struct lovsub_object *subobj = cl2lovsub(obj);
+	struct lov_stripe_md *lsm = subobj->lso_super->lo_lsm;
 
 	cl_req_attr_set(env, &subobj->lso_super->lo_cl, attr);
 
@@ -139,6 +140,9 @@ static void lovsub_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 	 * unconditionally. It never changes anyway.
 	 */
 	attr->cra_oa->o_stripe_idx = lov_comp_stripe(subobj->lso_index);
+	lov_lsm2layout(lsm, lsm->lsm_entries[lov_comp_entry(subobj->lso_index)],
+		       &attr->cra_oa->o_layout);
+	attr->cra_oa->o_valid |= OBD_MD_FLOSTLAYOUT;
 }
 
 static const struct cl_object_operations lovsub_ops = {
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index dabdf6d..8cd0813 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -542,7 +542,9 @@ static int osc_io_setattr_start(const struct lu_env *env,
 		oa->o_oi = loi->loi_oi;
 		obdo_set_parent_fid(oa, io->u.ci_setattr.sa_parent_fid);
 		oa->o_stripe_idx = io->u.ci_setattr.sa_stripe_index;
-		oa->o_valid |= OBD_MD_FLID | OBD_MD_FLGROUP;
+		oa->o_layout = io->u.ci_setattr.sa_layout;
+		oa->o_valid |= OBD_MD_FLID | OBD_MD_FLGROUP |
+			       OBD_MD_FLOSTLAYOUT;
 		if (ia_avalid & ATTR_CTIME) {
 			oa->o_valid |= OBD_MD_FLCTIME;
 			oa->o_ctime = attr->cat_ctime;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 9c5be30..5fadd5e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1587,6 +1587,15 @@ void lustre_swab_connect(struct obd_connect_data *ocd)
 	BUILD_BUG_ON(offsetof(typeof(*ocd), paddingF) == 0);
 }
 
+static void lustre_swab_ost_layout(struct ost_layout *ol)
+{
+	__swab32s(&ol->ol_stripe_size);
+	__swab32s(&ol->ol_stripe_count);
+	__swab64s(&ol->ol_comp_start);
+	__swab64s(&ol->ol_comp_end);
+	__swab32s(&ol->ol_comp_id);
+}
+
 static void lustre_swab_obdo(struct obdo *o)
 {
 	__swab64s(&o->o_valid);
@@ -1609,8 +1618,8 @@ static void lustre_swab_obdo(struct obdo *o)
 	__swab64s(&o->o_ioepoch);
 	__swab32s(&o->o_stripe_idx);
 	__swab32s(&o->o_parent_ver);
-	/* o_handle is opaque */
-	/* o_lcookie is swabbed elsewhere */
+	lustre_swab_ost_layout(&o->o_layout);
+	BUILD_BUG_ON(offsetof(typeof(*o), o_padding_3) == 0);
 	__swab32s(&o->o_uid_h);
 	__swab32s(&o->o_gid_h);
 	__swab64s(&o->o_data_version);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 90e6b8c..639db24 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -1128,6 +1128,30 @@ void lustre_assert_wire_constants(void)
 	LASSERTF(OBD_CKSUM_CRC32C == 0x00000004UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32C);
 
+	/* Checks for struct ost_layout */
+	LASSERTF((int)sizeof(struct ost_layout) == 28, "found %lld\n",
+		 (long long)(int)sizeof(struct ost_layout));
+	LASSERTF((int)offsetof(struct ost_layout, ol_stripe_size) == 0, "found %lld\n",
+		 (long long)(int)offsetof(struct ost_layout, ol_stripe_size));
+	LASSERTF((int)sizeof(((struct ost_layout *)0)->ol_stripe_size) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct ost_layout *)0)->ol_stripe_size));
+	LASSERTF((int)offsetof(struct ost_layout, ol_stripe_count) == 4, "found %lld\n",
+		 (long long)(int)offsetof(struct ost_layout, ol_stripe_count));
+	LASSERTF((int)sizeof(((struct ost_layout *)0)->ol_stripe_count) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct ost_layout *)0)->ol_stripe_count));
+	LASSERTF((int)offsetof(struct ost_layout, ol_comp_start) == 8, "found %lld\n",
+		 (long long)(int)offsetof(struct ost_layout, ol_comp_start));
+	LASSERTF((int)sizeof(((struct ost_layout *)0)->ol_comp_start) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct ost_layout *)0)->ol_comp_start));
+	LASSERTF((int)offsetof(struct ost_layout, ol_comp_end) == 16, "found %lld\n",
+		 (long long)(int)offsetof(struct ost_layout, ol_comp_end));
+	LASSERTF((int)sizeof(((struct ost_layout *)0)->ol_comp_end) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct ost_layout *)0)->ol_comp_end));
+	LASSERTF((int)offsetof(struct ost_layout, ol_comp_id) == 24, "found %lld\n",
+		 (long long)(int)offsetof(struct ost_layout, ol_comp_id));
+	LASSERTF((int)sizeof(((struct ost_layout *)0)->ol_comp_id) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct ost_layout *)0)->ol_comp_id));
+
 	/* Checks for struct obdo */
 	LASSERTF((int)sizeof(struct obdo) == 208, "found %lld\n",
 		 (long long)(int)sizeof(struct obdo));
@@ -1215,10 +1239,14 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct obdo, o_handle));
 	LASSERTF((int)sizeof(((struct obdo *)0)->o_handle) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct obdo *)0)->o_handle));
-	LASSERTF((int)offsetof(struct obdo, o_lcookie) == 136, "found %lld\n",
-		 (long long)(int)offsetof(struct obdo, o_lcookie));
-	LASSERTF((int)sizeof(((struct obdo *)0)->o_lcookie) == 32, "found %lld\n",
-		 (long long)(int)sizeof(((struct obdo *)0)->o_lcookie));
+	LASSERTF((int)offsetof(struct obdo, o_layout) == 136, "found %lld\n",
+		 (long long)(int)offsetof(struct obdo, o_layout));
+	LASSERTF((int)sizeof(((struct obdo *)0)->o_layout) == 28, "found %lld\n",
+		 (long long)(int)sizeof(((struct obdo *)0)->o_layout));
+	LASSERTF((int)offsetof(struct obdo, o_padding_3) == 164, "found %lld\n",
+		 (long long)(int)offsetof(struct obdo, o_padding_3));
+	LASSERTF((int)sizeof(((struct obdo *)0)->o_padding_3) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct obdo *)0)->o_padding_3));
 	LASSERTF((int)offsetof(struct obdo, o_uid_h) == 168, "found %lld\n",
 		 (long long)(int)offsetof(struct obdo, o_uid_h));
 	LASSERTF((int)sizeof(((struct obdo *)0)->o_uid_h) == 4, "found %lld\n",
@@ -1331,6 +1359,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_MD_FLGETATTRLOCK);
 	LASSERTF(OBD_MD_FLDATAVERSION == (0x0010000000000000ULL), "found 0x%.16llxULL\n",
 		 OBD_MD_FLDATAVERSION);
+	LASSERTF(OBD_MD_FLOSTLAYOUT == (0x0080000000000000ULL), "found 0x%.16llxULL\n",
+		 OBD_MD_FLOSTLAYOUT);
 	LASSERTF(OBD_MD_FLPROJID == (0x0100000000000000ULL), "found 0x%.16llxULL\n",
 		 OBD_MD_FLPROJID);
 
@@ -3549,26 +3579,6 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct llog_log_hdr *)0)->llh_tail) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct llog_log_hdr *)0)->llh_tail));
 
-	/* Checks for struct llog_cookie */
-	LASSERTF((int)sizeof(struct llog_cookie) == 32, "found %lld\n",
-		 (long long)(int)sizeof(struct llog_cookie));
-	LASSERTF((int)offsetof(struct llog_cookie, lgc_lgl) == 0, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_cookie, lgc_lgl));
-	LASSERTF((int)sizeof(((struct llog_cookie *)0)->lgc_lgl) == 20, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_cookie *)0)->lgc_lgl));
-	LASSERTF((int)offsetof(struct llog_cookie, lgc_subsys) == 20, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_cookie, lgc_subsys));
-	LASSERTF((int)sizeof(((struct llog_cookie *)0)->lgc_subsys) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_cookie *)0)->lgc_subsys));
-	LASSERTF((int)offsetof(struct llog_cookie, lgc_index) == 24, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_cookie, lgc_index));
-	LASSERTF((int)sizeof(((struct llog_cookie *)0)->lgc_index) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_cookie *)0)->lgc_index));
-	LASSERTF((int)offsetof(struct llog_cookie, lgc_padding) == 28, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_cookie, lgc_padding));
-	LASSERTF((int)sizeof(((struct llog_cookie *)0)->lgc_padding) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_cookie *)0)->lgc_padding));
-
 	/* Checks for struct llogd_body */
 	LASSERTF((int)sizeof(struct llogd_body) == 48, "found %lld\n",
 		 (long long)(int)sizeof(struct llogd_body));
-- 
1.8.3.1
