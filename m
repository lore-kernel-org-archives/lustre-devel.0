From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:55 -0500
Subject: [lustre-devel] [PATCH 127/622] lustre: idl: remove obsolete RPC
 flags
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-128-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Remove RPC flags that are no longer in use:
- OBD_MD_FLQOS          has never been used in master branch
- OBD_MD_FLEPOCH        unused since v2_7_50_0-38-gd5d5b349f2
- OBD_MD_REINT          unused since before 1.6
- OBD_MD_FLMDSCAPA      unused since v2_7_55_0-15-g353ef58b1d
- OBD_MD_FLOSSCAPA      unused since v2_7_55_0-15-g353ef58b1d

Rename OBD_MD_FLGENER to OBD_MD_FLPARENT to more accurately describe
that this flag is only used to mark the parent FID in the OST obdo.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11397
Lustre-commit: f63366a3c285 ("LU-11397 idl: remove obsolete RPC flags")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33202
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/obdo.c              |  2 +-
 fs/lustre/ptlrpc/layout.c              |  6 ++----
 fs/lustre/ptlrpc/pack_generic.c        |  5 +----
 fs/lustre/ptlrpc/wiretest.c            | 14 ++------------
 include/uapi/linux/lustre/lustre_idl.h | 18 ++++++++----------
 5 files changed, 14 insertions(+), 31 deletions(-)

diff --git a/fs/lustre/obdclass/obdo.c b/fs/lustre/obdclass/obdo.c
index e5475f1..8fd2922 100644
--- a/fs/lustre/obdclass/obdo.c
+++ b/fs/lustre/obdclass/obdo.c
@@ -48,7 +48,7 @@ void obdo_set_parent_fid(struct obdo *dst, const struct lu_fid *parent)
 	dst->o_parent_oid = fid_oid(parent);
 	dst->o_parent_seq = fid_seq(parent);
 	dst->o_parent_ver = fid_ver(parent);
-	dst->o_valid |= OBD_MD_FLGENER | OBD_MD_FLFID;
+	dst->o_valid |= OBD_MD_FLPARENT | OBD_MD_FLFID;
 }
 EXPORT_SYMBOL(obdo_set_parent_fid);
 
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 225a73e..efbff69 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -1022,13 +1022,11 @@ struct req_msg_field RMF_LOGCOOKIES =
 EXPORT_SYMBOL(RMF_LOGCOOKIES);
 
 struct req_msg_field RMF_CAPA1 =
-	DEFINE_MSGF("capa", 0, sizeof(struct lustre_capa),
-		    lustre_swab_lustre_capa, NULL);
+	DEFINE_MSGF("capa", 0, 0, NULL, NULL);
 EXPORT_SYMBOL(RMF_CAPA1);
 
 struct req_msg_field RMF_CAPA2 =
-	DEFINE_MSGF("capa", 0, sizeof(struct lustre_capa),
-		    lustre_swab_lustre_capa, NULL);
+	DEFINE_MSGF("capa", 0, 0, NULL, NULL);
 EXPORT_SYMBOL(RMF_CAPA2);
 
 struct req_msg_field RMF_LAYOUT_INTENT =
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 653a8d7..6da9aca 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -2242,12 +2242,9 @@ static void dump_obdo(struct obdo *oa)
 	else if (valid & OBD_MD_FLCKSUM)
 		CDEBUG(D_RPCTRACE, "obdo: o_checksum (o_nlink) = %u\n",
 		       oa->o_nlink);
-	if (valid & OBD_MD_FLGENER)
+	if (valid & OBD_MD_FLPARENT)
 		CDEBUG(D_RPCTRACE, "obdo: o_parent_oid = %x\n",
 		       oa->o_parent_oid);
-	if (valid & OBD_MD_FLEPOCH)
-		CDEBUG(D_RPCTRACE, "obdo: o_ioepoch = %lld\n",
-		       oa->o_ioepoch);
 	if (valid & OBD_MD_FLFID) {
 		CDEBUG(D_RPCTRACE, "obdo: o_stripe_idx = %u\n",
 		       oa->o_stripe_idx);
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 845aff4..42af0b8 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1335,8 +1335,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_MD_FLFLAGS);
 	LASSERTF(OBD_MD_FLNLINK == (0x00002000ULL), "found 0x%.16llxULL\n",
 		 OBD_MD_FLNLINK);
-	LASSERTF(OBD_MD_FLGENER == (0x00004000ULL), "found 0x%.16llxULL\n",
-		 OBD_MD_FLGENER);
+	LASSERTF(OBD_MD_FLPARENT == (0x00004000ULL), "found 0x%.16llxULL\n",
+		 OBD_MD_FLPARENT);
 	LASSERTF(OBD_MD_FLRDEV == (0x00010000ULL), "found 0x%.16llxULL\n",
 		 OBD_MD_FLRDEV);
 	LASSERTF(OBD_MD_FLEASIZE == (0x00020000ULL), "found 0x%.16llxULL\n",
@@ -1347,14 +1347,10 @@ void lustre_assert_wire_constants(void)
 		 OBD_MD_FLHANDLE);
 	LASSERTF(OBD_MD_FLCKSUM == (0x00100000ULL), "found 0x%.16llxULL\n",
 		 OBD_MD_FLCKSUM);
-	LASSERTF(OBD_MD_FLQOS == (0x00200000ULL), "found 0x%.16llxULL\n",
-		 OBD_MD_FLQOS);
 	LASSERTF(OBD_MD_FLGROUP == (0x01000000ULL), "found 0x%.16llxULL\n",
 		 OBD_MD_FLGROUP);
 	LASSERTF(OBD_MD_FLFID == (0x02000000ULL), "found 0x%.16llxULL\n",
 		 OBD_MD_FLFID);
-	LASSERTF(OBD_MD_FLEPOCH == (0x04000000ULL), "found 0x%.16llxULL\n",
-		 OBD_MD_FLEPOCH);
 	LASSERTF(OBD_MD_FLGRANT == (0x08000000ULL), "found 0x%.16llxULL\n",
 		 OBD_MD_FLGRANT);
 	LASSERTF(OBD_MD_FLDIREA == (0x10000000ULL), "found 0x%.16llxULL\n",
@@ -1367,8 +1363,6 @@ void lustre_assert_wire_constants(void)
 		 OBD_MD_FLMODEASIZE);
 	LASSERTF(OBD_MD_MDS == (0x0000000100000000ULL), "found 0x%.16llxULL\n",
 		 OBD_MD_MDS);
-	LASSERTF(OBD_MD_REINT == (0x0000000200000000ULL), "found 0x%.16llxULL\n",
-		 OBD_MD_REINT);
 	LASSERTF(OBD_MD_MEA == (0x0000000400000000ULL), "found 0x%.16llxULL\n",
 		 OBD_MD_MEA);
 	LASSERTF(OBD_MD_TSTATE == (0x0000000800000000ULL),
@@ -1381,10 +1375,6 @@ void lustre_assert_wire_constants(void)
 		 OBD_MD_FLXATTRRM);
 	LASSERTF(OBD_MD_FLACL == (0x0000008000000000ULL), "found 0x%.16llxULL\n",
 		 OBD_MD_FLACL);
-	LASSERTF(OBD_MD_FLMDSCAPA == (0x0000020000000000ULL), "found 0x%.16llxULL\n",
-		 OBD_MD_FLMDSCAPA);
-	LASSERTF(OBD_MD_FLOSSCAPA == (0x0000040000000000ULL), "found 0x%.16llxULL\n",
-		 OBD_MD_FLOSSCAPA);
 	LASSERTF(OBD_MD_FLCROSSREF == (0x0000100000000000ULL), "found 0x%.16llxULL\n",
 		 OBD_MD_FLCROSSREF);
 	LASSERTF(OBD_MD_FLGETATTRLOCK == (0x0000200000000000ULL), "found 0x%.16llxULL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 39f2d3b..8002e046 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1137,21 +1137,19 @@ static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 #define OBD_MD_FLFLAGS		(0x00000800ULL) /* flags word */
 #define OBD_MD_DOM_SIZE		(0x00001000ULL) /* Data-on-MDT component size */
 #define OBD_MD_FLNLINK		(0x00002000ULL) /* link count */
-#define OBD_MD_FLGENER		(0x00004000ULL) /* generation number */
-#define OBD_MD_LAYOUT_VERSION	(0x00008000ULL) /* layout version for
-						 * OST objects
-						 */
+#define OBD_MD_FLPARENT		(0x00004000ULL) /* parent FID */
+#define OBD_MD_LAYOUT_VERSION	(0x00008000ULL) /* OST object layout version */
 #define OBD_MD_FLRDEV		(0x00010000ULL) /* device number */
 #define OBD_MD_FLEASIZE		(0x00020000ULL) /* extended attribute data */
 #define OBD_MD_LINKNAME		(0x00040000ULL) /* symbolic link target */
 #define OBD_MD_FLHANDLE		(0x00080000ULL) /* file/lock handle */
 #define OBD_MD_FLCKSUM		(0x00100000ULL) /* bulk data checksum */
-#define OBD_MD_FLQOS		(0x00200000ULL) /* quality of service stats */
+/*	OBD_MD_FLQOS		(0x00200000ULL) has never been used */
 #define OBD_MD_FLPRJQUOTA	(0x00400000ULL)	/* over quota flags sent from ost */
 /*	OBD_MD_FLCOOKIE		(0x00800000ULL) obsolete in 2.8 */
 #define OBD_MD_FLGROUP		(0x01000000ULL) /* group */
 #define OBD_MD_FLFID		(0x02000000ULL) /* ->ost write inline fid */
-#define OBD_MD_FLEPOCH		(0x04000000ULL) /* ->ost write with ioepoch */
+/*	OBD_MD_FLEPOCH		(0x04000000ULL) obsolete 2.7.50 */
 						/* ->mds if epoch opens or closes */
 #define OBD_MD_FLGRANT		(0x08000000ULL) /* ost preallocation space grant */
 #define OBD_MD_FLDIREA		(0x10000000ULL) /* dir's extended attribute data */
@@ -1160,7 +1158,7 @@ static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 #define OBD_MD_FLMODEASIZE	(0x80000000ULL) /* EA size will be changed */
 
 #define OBD_MD_MDS		(0x0000000100000000ULL) /* where an inode lives on */
-#define OBD_MD_REINT		(0x0000000200000000ULL) /* reintegrate oa */
+/*	OBD_MD_REINT		(0x0000000200000000ULL) obsolete 1.8 */
 #define OBD_MD_MEA		(0x0000000400000000ULL) /* CMD split EA  */
 #define OBD_MD_TSTATE		(0x0000000800000000ULL) /* transient state field */
 
@@ -1169,8 +1167,8 @@ static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 #define OBD_MD_FLXATTRRM	(0x0000004000000000ULL) /* xattr remove */
 #define OBD_MD_FLACL		(0x0000008000000000ULL) /* ACL */
 #define OBD_MD_FLAGSTATFS	(0x0000010000000000ULL) /* aggregated statfs */
-#define OBD_MD_FLMDSCAPA	(0x0000020000000000ULL) /* MDS capability */
-#define OBD_MD_FLOSSCAPA	(0x0000040000000000ULL) /* OSS capability */
+/*	OBD_MD_FLMDSCAPA	(0x0000020000000000ULL) obsolete 2.7.54 */
+/*	OBD_MD_FLOSSCAPA	(0x0000040000000000ULL) obsolete 2.7.54 */
 /*	OBD_MD_FLCKSPLIT	(0x0000080000000000ULL) obsolete 2.3.58*/
 #define OBD_MD_FLCROSSREF	(0x0000100000000000ULL) /* Cross-ref case */
 #define OBD_MD_FLGETATTRLOCK	(0x0000200000000000ULL) /* Get IOEpoch attributes
@@ -1202,7 +1200,7 @@ static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 			  OBD_MD_FLCTIME | OBD_MD_FLSIZE  | OBD_MD_FLBLKSZ | \
 			  OBD_MD_FLMODE  | OBD_MD_FLTYPE  | OBD_MD_FLUID   | \
 			  OBD_MD_FLGID   | OBD_MD_FLFLAGS | OBD_MD_FLNLINK | \
-			  OBD_MD_FLGENER | OBD_MD_FLRDEV  | OBD_MD_FLGROUP | \
+			  OBD_MD_FLPARENT | OBD_MD_FLRDEV  | OBD_MD_FLGROUP | \
 			  OBD_MD_FLPROJID)
 
 #define OBD_MD_FLXATTRALL (OBD_MD_FLXATTR | OBD_MD_FLXATTRLS)
-- 
1.8.3.1
