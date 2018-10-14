From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 15:00:42 -0400
Subject: [lustre-devel] [PATCH 3/7] lustre: quota: add project id support
In-Reply-To: <1539543646-29717-1-git-send-email-jsimmons@infradead.org>
References: <1539543646-29717-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543646-29717-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@whamcloud.com>

This patch is infrastructure change for Lustre project quota,
project ID is considered as file attribute like UID/GID,
MDS will return back project id to client upon open/getattr.

Signed-off-by: Wang Shilong <wshilong@ddn.com>
Signed-off-by: Oleg Drokin <green@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-4017
Reviewed-on: https://review.whamcloud.com/25812
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/uapi/linux/lustre/lustre_idl.h     |  9 ++++++---
 drivers/staging/lustre/lustre/include/obd.h           |  1 +
 drivers/staging/lustre/lustre/llite/llite_internal.h  |  2 ++
 drivers/staging/lustre/lustre/llite/llite_lib.c       |  2 ++
 drivers/staging/lustre/lustre/llite/vvp_object.c      |  4 +++-
 drivers/staging/lustre/lustre/obdclass/obdo.c         |  7 +++++++
 drivers/staging/lustre/lustre/ptlrpc/pack_generic.c   |  8 +++++++-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c       | 19 +++++++++++++------
 8 files changed, 41 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index 1220acd..a8ffde2 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -1133,6 +1133,7 @@ static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 							    */
 
 #define OBD_MD_DEFAULT_MEA	(0x0040000000000000ULL) /* default MEA */
+#define OBD_MD_FLPROJID		(0x0100000000000000ULL) /* project ID */
 
 #define OBD_MD_FLALLQUOTA (OBD_MD_FLUSRQUOTA | \
 			   OBD_MD_FLGRPQUOTA | \
@@ -1142,7 +1143,8 @@ static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 			  OBD_MD_FLCTIME | OBD_MD_FLSIZE  | OBD_MD_FLBLKSZ | \
 			  OBD_MD_FLMODE  | OBD_MD_FLTYPE  | OBD_MD_FLUID   | \
 			  OBD_MD_FLGID   | OBD_MD_FLFLAGS | OBD_MD_FLNLINK | \
-			  OBD_MD_FLGENER | OBD_MD_FLRDEV  | OBD_MD_FLGROUP)
+			  OBD_MD_FLGENER | OBD_MD_FLRDEV  | OBD_MD_FLGROUP | \
+			  OBD_MD_FLPROJID)
 
 #define OBD_MD_FLXATTRALL (OBD_MD_FLXATTR | OBD_MD_FLXATTRLS)
 
@@ -1515,7 +1517,7 @@ struct mdt_body {
 	__u32	mbo_unused3;	/* was max_cookiesize until 2.8 */
 	__u32	mbo_uid_h;	/* high 32-bits of uid, for FUID */
 	__u32	mbo_gid_h;	/* high 32-bits of gid, for FUID */
-	__u32	mbo_padding_5;	/* also fix lustre_swab_mdt_body */
+	__u32	mbo_projid;	/* also fix lustre_swab_mdt_body */
 	__u64	mbo_padding_6;
 	__u64	mbo_padding_7;
 	__u64	mbo_padding_8;
@@ -2615,7 +2617,8 @@ struct obdo {
 					 * brw: grant space consumed on
 					 * the client for the write
 					 */
-	__u64		o_padding_4;
+	__u32		o_projid;
+	__u32		o_padding_4;	/* also fix lustre_swab_obdo() */
 	__u64		o_padding_5;
 	__u64		o_padding_6;
 };
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index cf3dbd6..81b4750 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -1028,6 +1028,7 @@ static inline struct md_open_data *obd_mod_alloc(void)
 
 void obdo_from_inode(struct obdo *dst, struct inode *src, u32 valid);
 void obdo_set_parent_fid(struct obdo *dst, const struct lu_fid *parent);
+void obdo_set_o_projid(struct obdo *dst, u32 projid);
 
 /* return 1 if client should be resend request */
 static inline int client_should_resend(int resend, struct client_obd *cli)
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 359bd53..ba9ba49 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -237,6 +237,8 @@ struct ll_inode_info {
 	__u32				lli_layout_gen;
 	spinlock_t			lli_layout_lock;
 
+	u32				lli_projid;	/* project id */
+
 	struct rw_semaphore		lli_xattrs_list_rwsem;
 	struct mutex			lli_xattrs_enq_lock;
 	struct list_head		lli_xattrs;/* ll_xattr_entry->xe_list */
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index fae7e50..7320dc8 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1859,6 +1859,8 @@ int ll_update_inode(struct inode *inode, struct lustre_md *md)
 		inode->i_uid = make_kuid(&init_user_ns, body->mbo_uid);
 	if (body->mbo_valid & OBD_MD_FLGID)
 		inode->i_gid = make_kgid(&init_user_ns, body->mbo_gid);
+	if (body->mbo_valid & OBD_MD_FLPROJID)
+		lli->lli_projid = body->mbo_projid;
 	if (body->mbo_valid & OBD_MD_FLFLAGS)
 		inode->i_flags = ll_ext_to_inode_flags(body->mbo_flags);
 	if (body->mbo_valid & OBD_MD_FLNLINK)
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index 301a90d..c1f8b50 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -193,9 +193,11 @@ static void vvp_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 	oa = attr->cra_oa;
 	inode = vvp_object_inode(obj);
 
-	if (attr->cra_type == CRT_WRITE)
+	if (attr->cra_type == CRT_WRITE) {
 		valid_flags |= OBD_MD_FLMTIME | OBD_MD_FLCTIME |
 			       OBD_MD_FLUID | OBD_MD_FLGID;
+		obdo_set_o_projid(oa, ll_i2info(inode)->lli_projid);
+	}
 	obdo_from_inode(oa, inode, valid_flags & attr->cra_flags);
 	obdo_set_parent_fid(oa, &ll_i2info(inode)->lli_fid);
 	if (OBD_FAIL_CHECK(OBD_FAIL_LFSCK_INVALID_PFID))
diff --git a/drivers/staging/lustre/lustre/obdclass/obdo.c b/drivers/staging/lustre/lustre/obdclass/obdo.c
index 8013c1e..7c65d0d 100644
--- a/drivers/staging/lustre/lustre/obdclass/obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/obdo.c
@@ -52,6 +52,13 @@ void obdo_set_parent_fid(struct obdo *dst, const struct lu_fid *parent)
 }
 EXPORT_SYMBOL(obdo_set_parent_fid);
 
+void obdo_set_o_projid(struct obdo *dst, u32 projid)
+{
+	dst->o_projid = projid;
+	dst->o_valid |= OBD_MD_FLPROJID;
+}
+EXPORT_SYMBOL(obdo_set_o_projid);
+
 /* WARNING: the file systems must take care not to tinker with
  * attributes they don't manage (such as blocks).
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 96d0377..951bb92 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1614,6 +1614,7 @@ static void lustre_swab_obdo(struct obdo *o)
 	__swab32s(&o->o_uid_h);
 	__swab32s(&o->o_gid_h);
 	__swab64s(&o->o_data_version);
+	__swab32s(&o->o_projid);
 	BUILD_BUG_ON(offsetof(typeof(*o), o_padding_4) == 0);
 	BUILD_BUG_ON(offsetof(typeof(*o), o_padding_5) == 0);
 	BUILD_BUG_ON(offsetof(typeof(*o), o_padding_6) == 0);
@@ -1747,7 +1748,12 @@ void lustre_swab_mdt_body(struct mdt_body *b)
 	BUILD_BUG_ON(!offsetof(typeof(*b), mbo_unused3));
 	__swab32s(&b->mbo_uid_h);
 	__swab32s(&b->mbo_gid_h);
-	BUILD_BUG_ON(offsetof(typeof(*b), mbo_padding_5) == 0);
+	__swab32s(&b->mbo_projid);
+	BUILD_BUG_ON(offsetof(typeof(*b), mbo_padding_6) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*b), mbo_padding_7) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*b), mbo_padding_8) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*b), mbo_padding_9) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*b), mbo_padding_10) == 0);
 }
 
 void lustre_swab_mdt_ioepoch(struct mdt_ioepoch *b)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 09aef9a..b4774d6 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -1228,9 +1228,13 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct obdo, o_data_version));
 	LASSERTF((int)sizeof(((struct obdo *)0)->o_data_version) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct obdo *)0)->o_data_version));
-	LASSERTF((int)offsetof(struct obdo, o_padding_4) == 184, "found %lld\n",
+	LASSERTF((int)offsetof(struct obdo, o_projid) == 184, "found %lld\n",
+		 (long long)(int)offsetof(struct obdo, o_projid));
+	LASSERTF((int)sizeof(((struct obdo *)0)->o_projid) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct obdo *)0)->o_projid));
+	LASSERTF((int)offsetof(struct obdo, o_padding_4) == 188, "found %lld\n",
 		 (long long)(int)offsetof(struct obdo, o_padding_4));
-	LASSERTF((int)sizeof(((struct obdo *)0)->o_padding_4) == 8, "found %lld\n",
+	LASSERTF((int)sizeof(((struct obdo *)0)->o_padding_4) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct obdo *)0)->o_padding_4));
 	LASSERTF((int)offsetof(struct obdo, o_padding_5) == 192, "found %lld\n",
 		 (long long)(int)offsetof(struct obdo, o_padding_5));
@@ -1324,6 +1328,9 @@ void lustre_assert_wire_constants(void)
 		 OBD_MD_FLGETATTRLOCK);
 	LASSERTF(OBD_MD_FLDATAVERSION == (0x0010000000000000ULL), "found 0x%.16llxULL\n",
 		 OBD_MD_FLDATAVERSION);
+	LASSERTF(OBD_MD_FLPROJID == (0x0100000000000000ULL), "found 0x%.16llxULL\n",
+		 OBD_MD_FLPROJID);
+
 	BUILD_BUG_ON(OBD_FL_INLINEDATA != 0x00000001);
 	BUILD_BUG_ON(OBD_FL_OBDMDEXISTS != 0x00000002);
 	BUILD_BUG_ON(OBD_FL_DELORPHAN != 0x00000004);
@@ -1869,10 +1876,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct mdt_body, mbo_gid_h));
 	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_gid_h) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_gid_h));
-	LASSERTF((int)offsetof(struct mdt_body, mbo_padding_5) == 172, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_body, mbo_padding_5));
-	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_padding_5) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_padding_5));
+	LASSERTF((int)offsetof(struct mdt_body, mbo_projid) == 172, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_body, mbo_projid));
+	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_projid) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_projid));
 	LASSERTF((int)offsetof(struct mdt_body, mbo_padding_6) == 176, "found %lld\n",
 		 (long long)(int)offsetof(struct mdt_body, mbo_padding_6));
 	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_padding_6) == 8, "found %lld\n",
-- 
1.8.3.1
