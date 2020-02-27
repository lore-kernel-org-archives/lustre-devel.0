From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:16 -0500
Subject: [lustre-devel] [PATCH 028/622] lustre: idl: remove obsolete
 directory split flags
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

The directory split functionality from the old CMD (pre-DNE)
feature was never usable in production, and was removed before
the DNE 2.4 release.  Remove old flags relating to this feature.

WC-bug-id: https://jira.whamcloud.com/browse/LU-1187
Lustre-commit: 5c53c353fd82 ("LU-1187 idl: remove obsolete directory split flags")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/31700
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_lib.c                | 2 --
 fs/lustre/ptlrpc/wiretest.c            | 4 ----
 include/uapi/linux/lustre/lustre_idl.h | 4 ++--
 3 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index d4b2bb9..467503c 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -520,8 +520,6 @@ void mdc_getattr_pack(struct ptlrpc_request *req, u64 valid, u32 flags,
 						    &RMF_MDT_BODY);
 
 	b->mbo_valid = valid;
-	if (op_data->op_bias & MDS_CHECK_SPLIT)
-		b->mbo_valid |= OBD_MD_FLCKSPLIT;
 	if (op_data->op_bias & MDS_CROSS_REF)
 		b->mbo_valid |= OBD_MD_FLCROSSREF;
 	b->mbo_eadatasize = ea_size;
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 21698cc..bcd0229 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1341,8 +1341,6 @@ void lustre_assert_wire_constants(void)
 		 OBD_MD_FLMDSCAPA);
 	LASSERTF(OBD_MD_FLOSSCAPA == (0x0000040000000000ULL), "found 0x%.16llxULL\n",
 		 OBD_MD_FLOSSCAPA);
-	LASSERTF(OBD_MD_FLCKSPLIT == (0x0000080000000000ULL), "found 0x%.16llxULL\n",
-		 OBD_MD_FLCKSPLIT);
 	LASSERTF(OBD_MD_FLCROSSREF == (0x0000100000000000ULL), "found 0x%.16llxULL\n",
 		 OBD_MD_FLCROSSREF);
 	LASSERTF(OBD_MD_FLGETATTRLOCK == (0x0000200000000000ULL), "found 0x%.16llxULL\n",
@@ -1866,8 +1864,6 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct ll_fid *)0)->f_type) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct ll_fid *)0)->f_type));
 
-	LASSERTF(MDS_CHECK_SPLIT == 0x00000001UL, "found 0x%.8xUL\n",
-		(unsigned int)MDS_CHECK_SPLIT);
 	LASSERTF(MDS_CROSS_REF == 0x00000002UL, "found 0x%.8xUL\n",
 		(unsigned int)MDS_CROSS_REF);
 	LASSERTF(MDS_VTX_BYPASS == 0x00000004UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 0bce63d..589bb81 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1131,7 +1131,7 @@ static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 /*	OBD_MD_FLRMTPERM	(0x0000010000000000ULL) remote perm, obsolete */
 #define OBD_MD_FLMDSCAPA	(0x0000020000000000ULL) /* MDS capability */
 #define OBD_MD_FLOSSCAPA	(0x0000040000000000ULL) /* OSS capability */
-#define OBD_MD_FLCKSPLIT	(0x0000080000000000ULL) /* Check split on server */
+/*	OBD_MD_FLCKSPLIT	(0x0000080000000000ULL) obsolete 2.3.58*/
 #define OBD_MD_FLCROSSREF	(0x0000100000000000ULL) /* Cross-ref case */
 #define OBD_MD_FLGETATTRLOCK	(0x0000200000000000ULL) /* Get IOEpoch attributes
 							 * under lock; for xattr
@@ -1640,7 +1640,7 @@ struct mdt_rec_setattr {
 #define MDS_ATTR_PROJID		0x10000ULL /* = 65536 */
 
 enum mds_op_bias {
-	MDS_CHECK_SPLIT		= 1 << 0,
+/*	MDS_CHECK_SPLIT		= 1 << 0, obsolete before 2.3.58 */
 	MDS_CROSS_REF		= 1 << 1,
 	MDS_VTX_BYPASS		= 1 << 2,
 	MDS_PERM_BYPASS		= 1 << 3,
-- 
1.8.3.1
