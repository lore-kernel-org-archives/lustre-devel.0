From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:16 -0400
Subject: [lustre-devel] [PATCH 20/41] staging: lustre: remove Size on MDS
	support
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Remove unused definitions related to Size on MDS support from
lustre/include/lustre/lustre_idl.h. Remove unused code from several
places in lustre/.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6047
Reviewed-on: http://review.whamcloud.com/13443
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |   41 ++++-----------
 .../lustre/lustre/include/lustre_req_layout.h      |    1 -
 drivers/staging/lustre/lustre/include/obd.h        |    8 +++
 .../staging/lustre/lustre/include/obd_support.h    |    4 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |    7 ++-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    4 +-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |    6 --
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    7 ++-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |   58 ++++++--------------
 9 files changed, 46 insertions(+), 90 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 4f6eeec..17feb71 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -310,7 +310,7 @@ static inline int range_compare_loc(const struct lu_seq_range *r1,
  */
 enum lma_compat {
 	LMAC_HSM	= 0x00000001,
-	LMAC_SOM	= 0x00000002,
+/*	LMAC_SOM	= 0x00000002, obsolete since 2.8.0 */
 	LMAC_NOT_IN_OI	= 0x00000004, /* the object does NOT need OI mapping */
 	LMAC_FID_ON_OST = 0x00000008, /* For OST-object, its OI mapping is
 				       * under /O/<seq>/d<x>.
@@ -1923,7 +1923,7 @@ enum mds_cmd {
 	MDS_PIN			= 42, /* obsolete, never used in a release */
 	MDS_UNPIN		= 43, /* obsolete, never used in a release */
 	MDS_SYNC		= 44,
-	MDS_DONE_WRITING	= 45,
+	MDS_DONE_WRITING	= 45, /* obsolete since 2.8.0 */
 	MDS_SET_INFO		= 46,
 	MDS_QUOTACHECK		= 47,
 	MDS_QUOTACTL		= 48,
@@ -2021,24 +2021,6 @@ enum {
 #define MDS_STATUS_CONN 1
 #define MDS_STATUS_LOV 2
 
-/* mdt_thread_info.mti_flags. */
-enum md_op_flags {
-	/* The flag indicates Size-on-MDS attributes are changed. */
-	MF_SOM_CHANGE	   = (1 << 0),
-	/* Flags indicates an epoch opens or closes. */
-	MF_EPOCH_OPEN	   = (1 << 1),
-	MF_EPOCH_CLOSE	  = (1 << 2),
-	MF_MDC_CANCEL_FID1      = (1 << 3),
-	MF_MDC_CANCEL_FID2      = (1 << 4),
-	MF_MDC_CANCEL_FID3      = (1 << 5),
-	MF_MDC_CANCEL_FID4      = (1 << 6),
-	/* There is a pending attribute update. */
-	MF_SOM_AU	       = (1 << 7),
-	/* Cancel OST locks while getattr OST attributes. */
-	MF_GETATTR_LOCK	 = (1 << 8),
-	MF_GET_MDT_IDX	  = (1 << 9),
-};
-
 #define LUSTRE_BFLAG_UNCOMMITTED_WRITES   0x1
 
 /* these should be identical to their EXT4_*_FL counterparts, they are
@@ -2123,10 +2105,10 @@ struct mdt_body {
 void lustre_swab_mdt_body(struct mdt_body *b);
 
 struct mdt_ioepoch {
-	struct lustre_handle handle;
-	__u64  ioepoch;
-	__u32  flags;
-	__u32  padding;
+	struct lustre_handle mio_handle;
+	__u64 mio_unused1; /* was ioepoch */
+	__u32 mio_unused2; /* was flags */
+	__u32 mio_padding;
 };
 
 void lustre_swab_mdt_ioepoch(struct mdt_ioepoch *b);
@@ -2195,12 +2177,9 @@ void lustre_swab_mdt_rec_setattr(struct mdt_rec_setattr *sa);
 
 #define MDS_FMODE_CLOSED	 00000000
 #define MDS_FMODE_EXEC	   00000004
-/* IO Epoch is opened on a closed file. */
-#define MDS_FMODE_EPOCH	  01000000
-/* IO Epoch is opened on a file truncate. */
-#define MDS_FMODE_TRUNC	  02000000
-/* Size-on-MDS Attribute Update is pending. */
-#define MDS_FMODE_SOM	    04000000
+/*	MDS_FMODE_EPOCH		01000000 obsolete since 2.8.0 */
+/*	MDS_FMODE_TRUNC		02000000 obsolete since 2.8.0 */
+/*	MDS_FMODE_SOM		04000000 obsolete since 2.8.0 */
 
 #define MDS_OPEN_CREATED	 00000010
 #define MDS_OPEN_CROSS	   00000020
@@ -2246,7 +2225,7 @@ enum mds_op_bias {
 	MDS_CROSS_REF		= 1 << 1,
 	MDS_VTX_BYPASS		= 1 << 2,
 	MDS_PERM_BYPASS		= 1 << 3,
-	MDS_SOM			= 1 << 4,
+/*	MDS_SOM			= 1 << 4, obsolete since 2.8.0 */
 	MDS_QUOTA_IGNORE	= 1 << 5,
 	MDS_CLOSE_CLEANUP	= 1 << 6,
 	MDS_KEEP_ORPHAN		= 1 << 7,
diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index a13558e..dd8717e 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -154,7 +154,6 @@ extern struct req_format RQF_MDS_DISCONNECT;
 extern struct req_format RQF_MDS_GET_INFO;
 extern struct req_format RQF_MDS_READPAGE;
 extern struct req_format RQF_MDS_WRITEPAGE;
-extern struct req_format RQF_MDS_DONE_WRITING;
 extern struct req_format RQF_MDS_REINT;
 extern struct req_format RQF_MDS_REINT_CREATE;
 extern struct req_format RQF_MDS_REINT_CREATE_ACL;
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index fe05cc6..5c31376 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -755,6 +755,14 @@ static inline int it_to_lock_mode(struct lookup_intent *it)
 	return -EINVAL;
 }
 
+enum md_op_flags {
+	MF_MDC_CANCEL_FID1	= BIT(0),
+	MF_MDC_CANCEL_FID2      = BIT(1),
+	MF_MDC_CANCEL_FID3      = BIT(2),
+	MF_MDC_CANCEL_FID4      = BIT(3),
+	MF_GET_MDT_IDX          = BIT(4),
+};
+
 enum md_cli_flags {
 	CLI_SET_MEA	= BIT(0),
 	CLI_RM_ENTRY	= BIT(1),
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index b346a7f..9d2d6f8 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -172,8 +172,8 @@ extern char obd_jobid_var[];
 #define OBD_FAIL_MDS_ALL_REQUEST_NET     0x123
 #define OBD_FAIL_MDS_SYNC_NET	    0x124
 #define OBD_FAIL_MDS_SYNC_PACK	   0x125
-#define OBD_FAIL_MDS_DONE_WRITING_NET    0x126
-#define OBD_FAIL_MDS_DONE_WRITING_PACK   0x127
+/*	OBD_FAIL_MDS_DONE_WRITING_NET	0x126 obsolete since 2.8.0 */
+/*	OBD_FAIL_MDS_DONE_WRITING_PACK	0x127 obsolete since 2.8.0 */
 #define OBD_FAIL_MDS_ALLOC_OBDO	  0x128
 #define OBD_FAIL_MDS_PAUSE_OPEN	  0x129
 #define OBD_FAIL_MDS_STATFS_LCW_SLEEP    0x12a
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index 709440b..1925072 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -301,9 +301,10 @@ static void mdc_setattr_pack_rec(struct mdt_rec_setattr *rec,
 static void mdc_ioepoch_pack(struct mdt_ioepoch *epoch,
 			     struct md_op_data *op_data)
 {
-	memcpy(&epoch->handle, &op_data->op_handle, sizeof(epoch->handle));
-	epoch->ioepoch = 0;
-	epoch->flags = 0;
+	epoch->mio_handle = op_data->op_handle;
+	epoch->mio_unused1 = 0;
+	epoch->mio_unused2 = 0;
+	epoch->mio_padding = 0;
 }
 
 void mdc_setattr_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 3ef1bae..d996326 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -567,9 +567,9 @@ void mdc_replay_open(struct ptlrpc_request *req)
 		LASSERT(epoch);
 
 		if (och)
-			LASSERT(!memcmp(&old, &epoch->handle, sizeof(old)));
+			LASSERT(!memcmp(&old, &epoch->mio_handle, sizeof(old)));
 		DEBUG_REQ(D_HA, close_req, "updating close body with new fh");
-		epoch->handle = body->mbo_handle;
+		epoch->mio_handle = body->mbo_handle;
 	}
 }
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 4ea8454..358c124 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -669,7 +669,6 @@ static struct req_format *req_formats[] = {
 	&RQF_MDS_RELEASE_CLOSE,
 	&RQF_MDS_READPAGE,
 	&RQF_MDS_WRITEPAGE,
-	&RQF_MDS_DONE_WRITING,
 	&RQF_MDS_REINT,
 	&RQF_MDS_REINT_CREATE,
 	&RQF_MDS_REINT_CREATE_ACL,
@@ -1386,11 +1385,6 @@ struct req_format RQF_MDS_RELEASE_CLOSE =
 			mdt_release_close_client, mds_last_unlink_server);
 EXPORT_SYMBOL(RQF_MDS_RELEASE_CLOSE);
 
-struct req_format RQF_MDS_DONE_WRITING =
-	DEFINE_REQ_FMT0("MDS_DONE_WRITING",
-			mdt_close_client, mdt_body_only);
-EXPORT_SYMBOL(RQF_MDS_DONE_WRITING);
-
 struct req_format RQF_MDS_READPAGE =
 	DEFINE_REQ_FMT0("MDS_READPAGE",
 			mdt_body_capa, mdt_body_only);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 3055649..bca781a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1715,9 +1715,10 @@ void lustre_swab_mdt_body(struct mdt_body *b)
 void lustre_swab_mdt_ioepoch(struct mdt_ioepoch *b)
 {
 	/* handle is opaque */
-	 __swab64s(&b->ioepoch);
-	 __swab32s(&b->flags);
-	 CLASSERT(offsetof(typeof(*b), padding) != 0);
+	/* mio_handle is opaque */
+	CLASSERT(offsetof(typeof(*b), mio_unused1));
+	CLASSERT(offsetof(typeof(*b), mio_unused2));
+	CLASSERT(offsetof(typeof(*b), mio_padding));
 }
 
 void lustre_swab_mgs_target_info(struct mgs_target_info *mti)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index d5af8cd..391e83e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -220,24 +220,6 @@ void lustre_assert_wire_constants(void)
 		 (long long)MDS_STATUS_LOV);
 	LASSERTF(LUSTRE_BFLAG_UNCOMMITTED_WRITES == 1, "found %lld\n",
 		 (long long)LUSTRE_BFLAG_UNCOMMITTED_WRITES);
-	LASSERTF(MF_SOM_CHANGE == 0x00000001UL, "found 0x%.8xUL\n",
-		 (unsigned)MF_SOM_CHANGE);
-	LASSERTF(MF_EPOCH_OPEN == 0x00000002UL, "found 0x%.8xUL\n",
-		 (unsigned)MF_EPOCH_OPEN);
-	LASSERTF(MF_EPOCH_CLOSE == 0x00000004UL, "found 0x%.8xUL\n",
-		 (unsigned)MF_EPOCH_CLOSE);
-	LASSERTF(MF_MDC_CANCEL_FID1 == 0x00000008UL, "found 0x%.8xUL\n",
-		 (unsigned)MF_MDC_CANCEL_FID1);
-	LASSERTF(MF_MDC_CANCEL_FID2 == 0x00000010UL, "found 0x%.8xUL\n",
-		 (unsigned)MF_MDC_CANCEL_FID2);
-	LASSERTF(MF_MDC_CANCEL_FID3 == 0x00000020UL, "found 0x%.8xUL\n",
-		 (unsigned)MF_MDC_CANCEL_FID3);
-	LASSERTF(MF_MDC_CANCEL_FID4 == 0x00000040UL, "found 0x%.8xUL\n",
-		 (unsigned)MF_MDC_CANCEL_FID4);
-	LASSERTF(MF_SOM_AU == 0x00000080UL, "found 0x%.8xUL\n",
-		 (unsigned)MF_SOM_AU);
-	LASSERTF(MF_GETATTR_LOCK == 0x00000100UL, "found 0x%.8xUL\n",
-		 (unsigned)MF_GETATTR_LOCK);
 	LASSERTF(MDS_ATTR_MODE == 0x0000000000000001ULL, "found 0x%.16llxULL\n",
 		 (long long)MDS_ATTR_MODE);
 	LASSERTF(MDS_ATTR_UID == 0x0000000000000002ULL, "found 0x%.16llxULL\n",
@@ -423,8 +405,6 @@ void lustre_assert_wire_constants(void)
 		 (unsigned)LMAI_RELEASED);
 	LASSERTF(LMAC_HSM == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned)LMAC_HSM);
-	LASSERTF(LMAC_SOM == 0x00000002UL, "found 0x%.8xUL\n",
-		 (unsigned)LMAC_SOM);
 	LASSERTF(LMAC_NOT_IN_OI == 0x00000004UL, "found 0x%.8xUL\n",
 		 (unsigned)LMAC_NOT_IN_OI);
 	LASSERTF(LMAC_FID_ON_OST == 0x00000008UL, "found 0x%.8xUL\n",
@@ -1883,12 +1863,6 @@ void lustre_assert_wire_constants(void)
 		 MDS_FMODE_CLOSED);
 	LASSERTF(MDS_FMODE_EXEC == 000000000004UL, "found 0%.11oUL\n",
 		 MDS_FMODE_EXEC);
-	LASSERTF(MDS_FMODE_EPOCH == 000001000000UL, "found 0%.11oUL\n",
-		 MDS_FMODE_EPOCH);
-	LASSERTF(MDS_FMODE_TRUNC == 000002000000UL, "found 0%.11oUL\n",
-		 MDS_FMODE_TRUNC);
-	LASSERTF(MDS_FMODE_SOM == 000004000000UL, "found 0%.11oUL\n",
-		 MDS_FMODE_SOM);
 	LASSERTF(MDS_OPEN_CREATED == 000000000010UL, "found 0%.11oUL\n",
 		 MDS_OPEN_CREATED);
 	LASSERTF(MDS_OPEN_CROSS == 000000000020UL, "found 0%.11oUL\n",
@@ -1947,22 +1921,22 @@ void lustre_assert_wire_constants(void)
 	/* Checks for struct mdt_ioepoch */
 	LASSERTF((int)sizeof(struct mdt_ioepoch) == 24, "found %lld\n",
 		 (long long)(int)sizeof(struct mdt_ioepoch));
-	LASSERTF((int)offsetof(struct mdt_ioepoch, handle) == 0, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_ioepoch, handle));
-	LASSERTF((int)sizeof(((struct mdt_ioepoch *)0)->handle) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_ioepoch *)0)->handle));
-	LASSERTF((int)offsetof(struct mdt_ioepoch, ioepoch) == 8, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_ioepoch, ioepoch));
-	LASSERTF((int)sizeof(((struct mdt_ioepoch *)0)->ioepoch) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_ioepoch *)0)->ioepoch));
-	LASSERTF((int)offsetof(struct mdt_ioepoch, flags) == 16, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_ioepoch, flags));
-	LASSERTF((int)sizeof(((struct mdt_ioepoch *)0)->flags) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_ioepoch *)0)->flags));
-	LASSERTF((int)offsetof(struct mdt_ioepoch, padding) == 20, "found %lld\n",
-		 (long long)(int)offsetof(struct mdt_ioepoch, padding));
-	LASSERTF((int)sizeof(((struct mdt_ioepoch *)0)->padding) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct mdt_ioepoch *)0)->padding));
+	LASSERTF((int)offsetof(struct mdt_ioepoch, mio_handle) == 0, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_ioepoch, mio_handle));
+	LASSERTF((int)sizeof(((struct mdt_ioepoch *)0)->mio_handle) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_ioepoch *)0)->mio_handle));
+	LASSERTF((int)offsetof(struct mdt_ioepoch, mio_unused1) == 8, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_ioepoch, mio_unused1));
+	LASSERTF((int)sizeof(((struct mdt_ioepoch *)0)->mio_unused1) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_ioepoch *)0)->mio_unused1));
+	LASSERTF((int)offsetof(struct mdt_ioepoch, mio_unused2) == 16, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_ioepoch, mio_unused2));
+	LASSERTF((int)sizeof(((struct mdt_ioepoch *)0)->mio_unused2) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_ioepoch *)0)->mio_unused2));
+	LASSERTF((int)offsetof(struct mdt_ioepoch, mio_padding) == 20, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_ioepoch, mio_padding));
+	LASSERTF((int)sizeof(((struct mdt_ioepoch *)0)->mio_padding) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_ioepoch *)0)->mio_padding));
 
 	/* Checks for struct mdt_rec_setattr */
 	LASSERTF((int)sizeof(struct mdt_rec_setattr) == 136, "found %lld\n",
-- 
1.7.1
