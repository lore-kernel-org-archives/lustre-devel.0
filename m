From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:18 -0500
Subject: [lustre-devel] [PATCH v2 35/84] staging/lustre: Remove index file
	transfer structures
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-36-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

struct idx_info, struct lu_idxpage, lustre_swab_idx_info,
request formats and related defines are all unused and could
only happen for between-servers communications, so remove them
from the client code.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      | 86 --------------------
 .../lustre/lustre/include/lustre_req_layout.h      |  2 -
 drivers/staging/lustre/lustre/ptlrpc/layout.c      | 21 -----
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    | 14 ----
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 95 ----------------------
 5 files changed, 218 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 7b5c132..c272c18 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -3168,92 +3168,6 @@ void dump_ioo(struct obd_ioobj *nb);
 void dump_ost_body(struct ost_body *ob);
 void dump_rcs(__u32 *rc);
 
-#define IDX_INFO_MAGIC 0x3D37CC37
-
-/* Index file transfer through the network. The server serializes the index into
- * a byte stream which is sent to the client via a bulk transfer */
-struct idx_info {
-	__u32		ii_magic;
-
-	/* reply: see idx_info_flags below */
-	__u32		ii_flags;
-
-	/* request & reply: number of lu_idxpage (to be) transferred */
-	__u16		ii_count;
-	__u16		ii_pad0;
-
-	/* request: requested attributes passed down to the iterator API */
-	__u32		ii_attrs;
-
-	/* request & reply: index file identifier (FID) */
-	struct lu_fid	ii_fid;
-
-	/* reply: version of the index file before starting to walk the index.
-	 * Please note that the version can be modified at any time during the
-	 * transfer */
-	__u64		ii_version;
-
-	/* request: hash to start with:
-	 * reply: hash of the first entry of the first lu_idxpage and hash
-	 *	of the entry to read next if any */
-	__u64		ii_hash_start;
-	__u64		ii_hash_end;
-
-	/* reply: size of keys in lu_idxpages, minimal one if II_FL_VARKEY is
-	 * set */
-	__u16		ii_keysize;
-
-	/* reply: size of records in lu_idxpages, minimal one if II_FL_VARREC
-	 * is set */
-	__u16		ii_recsize;
-
-	__u32		ii_pad1;
-	__u64		ii_pad2;
-	__u64		ii_pad3;
-};
-
-void lustre_swab_idx_info(struct idx_info *ii);
-
-#define II_END_OFF	MDS_DIR_END_OFF /* all entries have been read */
-
-/* List of flags used in idx_info::ii_flags */
-enum idx_info_flags {
-	II_FL_NOHASH	= 1 << 0, /* client doesn't care about hash value */
-	II_FL_VARKEY	= 1 << 1, /* keys can be of variable size */
-	II_FL_VARREC	= 1 << 2, /* records can be of variable size */
-	II_FL_NONUNQ	= 1 << 3, /* index supports non-unique keys */
-};
-
-#define LIP_MAGIC 0x8A6D6B6C
-
-/* 4KB (= LU_PAGE_SIZE) container gathering key/record pairs */
-struct lu_idxpage {
-	/* 16-byte header */
-	__u32	lip_magic;
-	__u16	lip_flags;
-	__u16	lip_nr;   /* number of entries in the container */
-	__u64	lip_pad0; /* additional padding for future use */
-
-	/* key/record pairs are stored in the remaining 4080 bytes.
-	 * depending upon the flags in idx_info::ii_flags, each key/record
-	 * pair might be preceded by:
-	 * - a hash value
-	 * - the key size (II_FL_VARKEY is set)
-	 * - the record size (II_FL_VARREC is set)
-	 *
-	 * For the time being, we only support fixed-size key & record. */
-	char	lip_entries[0];
-};
-
-#define LIP_HDR_SIZE (offsetof(struct lu_idxpage, lip_entries))
-
-/* Gather all possible type associated with a 4KB container */
-union lu_page {
-	struct lu_dirpage	lp_dir; /* for MDS_READPAGE */
-	struct lu_idxpage	lp_idx; /* for OBD_IDX_READ */
-	char			lp_array[LU_PAGE_SIZE];
-};
-
 /* security opcodes */
 enum sec_cmd {
 	SEC_CTX_INIT	    = 801,
diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index fdcdd7a..b5128e4 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -130,7 +130,6 @@ void req_layout_fini(void);
 extern struct req_format RQF_OBD_PING;
 extern struct req_format RQF_OBD_SET_INFO;
 extern struct req_format RQF_SEC_CTX;
-extern struct req_format RQF_OBD_IDX_READ;
 /* MGS req_format */
 extern struct req_format RQF_MGS_TARGET_REG;
 extern struct req_format RQF_MGS_SET_INFO;
@@ -249,7 +248,6 @@ extern struct req_msg_field RMF_SETINFO_KEY;
 extern struct req_msg_field RMF_GETINFO_VAL;
 extern struct req_msg_field RMF_GETINFO_VALLEN;
 extern struct req_msg_field RMF_GETINFO_KEY;
-extern struct req_msg_field RMF_IDX_INFO;
 extern struct req_msg_field RMF_CLOSE_DATA;
 
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 715088f..0e60264 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -522,16 +522,6 @@ static const struct req_msg_field *llog_origin_handle_next_block_server[] = {
 	&RMF_EADATA
 };
 
-static const struct req_msg_field *obd_idx_read_client[] = {
-	&RMF_PTLRPC_BODY,
-	&RMF_IDX_INFO
-};
-
-static const struct req_msg_field *obd_idx_read_server[] = {
-	&RMF_PTLRPC_BODY,
-	&RMF_IDX_INFO
-};
-
 static const struct req_msg_field *ost_body_only[] = {
 	&RMF_PTLRPC_BODY,
 	&RMF_OST_BODY
@@ -647,7 +637,6 @@ static const struct req_msg_field *mdt_hsm_request[] = {
 static struct req_format *req_formats[] = {
 	&RQF_OBD_PING,
 	&RQF_OBD_SET_INFO,
-	&RQF_OBD_IDX_READ,
 	&RQF_SEC_CTX,
 	&RQF_MGS_TARGET_REG,
 	&RQF_MGS_SET_INFO,
@@ -1068,10 +1057,6 @@ struct req_msg_field RMF_FIEMAP_VAL =
 	DEFINE_MSGF("fiemap", 0, -1, lustre_swab_fiemap, NULL);
 EXPORT_SYMBOL(RMF_FIEMAP_VAL);
 
-struct req_msg_field RMF_IDX_INFO =
-	DEFINE_MSGF("idx_info", 0, sizeof(struct idx_info),
-		    lustre_swab_idx_info, NULL);
-EXPORT_SYMBOL(RMF_IDX_INFO);
 struct req_msg_field RMF_HSM_USER_STATE =
 	DEFINE_MSGF("hsm_user_state", 0, sizeof(struct hsm_user_state),
 		    lustre_swab_hsm_user_state, NULL);
@@ -1150,12 +1135,6 @@ struct req_format RQF_OBD_SET_INFO =
 	DEFINE_REQ_FMT0("OBD_SET_INFO", obd_set_info_client, empty);
 EXPORT_SYMBOL(RQF_OBD_SET_INFO);
 
-/* Read index file through the network */
-struct req_format RQF_OBD_IDX_READ =
-	DEFINE_REQ_FMT0("OBD_IDX_READ",
-			obd_idx_read_client, obd_idx_read_server);
-EXPORT_SYMBOL(RQF_OBD_IDX_READ);
-
 struct req_format RQF_SEC_CTX =
 	DEFINE_REQ_FMT0("SEC_CTX", empty, empty);
 EXPORT_SYMBOL(RQF_SEC_CTX);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index d6f0e6d..88bad09 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1846,20 +1846,6 @@ void lustre_swab_fiemap(struct ll_user_fiemap *fiemap)
 }
 EXPORT_SYMBOL(lustre_swab_fiemap);
 
-void lustre_swab_idx_info(struct idx_info *ii)
-{
-	__swab32s(&ii->ii_magic);
-	__swab32s(&ii->ii_flags);
-	__swab16s(&ii->ii_count);
-	__swab32s(&ii->ii_attrs);
-	lustre_swab_lu_fid(&ii->ii_fid);
-	__swab64s(&ii->ii_version);
-	__swab64s(&ii->ii_hash_start);
-	__swab64s(&ii->ii_hash_end);
-	__swab16s(&ii->ii_keysize);
-	__swab16s(&ii->ii_recsize);
-}
-
 void lustre_swab_mdt_rec_reint (struct mdt_rec_reint *rr)
 {
 	__swab32s(&rr->rr_opcode);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 249f9b3..3ffd2d9 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -555,9 +555,6 @@ void lustre_assert_wire_constants(void)
 		 (long long)LDF_COLLIDE);
 	LASSERTF(LU_PAGE_SIZE == 4096, "found %lld\n",
 		 (long long)LU_PAGE_SIZE);
-	/* Checks for union lu_page */
-	LASSERTF((int)sizeof(union lu_page) == 4096, "found %lld\n",
-		 (long long)(int)sizeof(union lu_page));
 
 	/* Checks for struct lustre_handle */
 	LASSERTF((int)sizeof(struct lustre_handle) == 8, "found %lld\n",
@@ -1605,98 +1602,6 @@ void lustre_assert_wire_constants(void)
 	LASSERTF(Q_FINVALIDATE == 0x800104, "found 0x%.8x\n",
 		Q_FINVALIDATE);
 
-	/* Checks for struct idx_info */
-	LASSERTF((int)sizeof(struct idx_info) == 80, "found %lld\n",
-		 (long long)(int)sizeof(struct idx_info));
-	LASSERTF((int)offsetof(struct idx_info, ii_magic) == 0, "found %lld\n",
-		 (long long)(int)offsetof(struct idx_info, ii_magic));
-	LASSERTF((int)sizeof(((struct idx_info *)0)->ii_magic) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct idx_info *)0)->ii_magic));
-	LASSERTF((int)offsetof(struct idx_info, ii_flags) == 4, "found %lld\n",
-		 (long long)(int)offsetof(struct idx_info, ii_flags));
-	LASSERTF((int)sizeof(((struct idx_info *)0)->ii_flags) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct idx_info *)0)->ii_flags));
-	LASSERTF((int)offsetof(struct idx_info, ii_count) == 8, "found %lld\n",
-		 (long long)(int)offsetof(struct idx_info, ii_count));
-	LASSERTF((int)sizeof(((struct idx_info *)0)->ii_count) == 2, "found %lld\n",
-		 (long long)(int)sizeof(((struct idx_info *)0)->ii_count));
-	LASSERTF((int)offsetof(struct idx_info, ii_pad0) == 10, "found %lld\n",
-		 (long long)(int)offsetof(struct idx_info, ii_pad0));
-	LASSERTF((int)sizeof(((struct idx_info *)0)->ii_pad0) == 2, "found %lld\n",
-		 (long long)(int)sizeof(((struct idx_info *)0)->ii_pad0));
-	LASSERTF((int)offsetof(struct idx_info, ii_attrs) == 12, "found %lld\n",
-		 (long long)(int)offsetof(struct idx_info, ii_attrs));
-	LASSERTF((int)sizeof(((struct idx_info *)0)->ii_attrs) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct idx_info *)0)->ii_attrs));
-	LASSERTF((int)offsetof(struct idx_info, ii_fid) == 16, "found %lld\n",
-		 (long long)(int)offsetof(struct idx_info, ii_fid));
-	LASSERTF((int)sizeof(((struct idx_info *)0)->ii_fid) == 16, "found %lld\n",
-		 (long long)(int)sizeof(((struct idx_info *)0)->ii_fid));
-	LASSERTF((int)offsetof(struct idx_info, ii_version) == 32, "found %lld\n",
-		 (long long)(int)offsetof(struct idx_info, ii_version));
-	LASSERTF((int)sizeof(((struct idx_info *)0)->ii_version) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct idx_info *)0)->ii_version));
-	LASSERTF((int)offsetof(struct idx_info, ii_hash_start) == 40, "found %lld\n",
-		 (long long)(int)offsetof(struct idx_info, ii_hash_start));
-	LASSERTF((int)sizeof(((struct idx_info *)0)->ii_hash_start) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct idx_info *)0)->ii_hash_start));
-	LASSERTF((int)offsetof(struct idx_info, ii_hash_end) == 48, "found %lld\n",
-		 (long long)(int)offsetof(struct idx_info, ii_hash_end));
-	LASSERTF((int)sizeof(((struct idx_info *)0)->ii_hash_end) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct idx_info *)0)->ii_hash_end));
-	LASSERTF((int)offsetof(struct idx_info, ii_keysize) == 56, "found %lld\n",
-		 (long long)(int)offsetof(struct idx_info, ii_keysize));
-	LASSERTF((int)sizeof(((struct idx_info *)0)->ii_keysize) == 2, "found %lld\n",
-		 (long long)(int)sizeof(((struct idx_info *)0)->ii_keysize));
-	LASSERTF((int)offsetof(struct idx_info, ii_recsize) == 58, "found %lld\n",
-		 (long long)(int)offsetof(struct idx_info, ii_recsize));
-	LASSERTF((int)sizeof(((struct idx_info *)0)->ii_recsize) == 2, "found %lld\n",
-		 (long long)(int)sizeof(((struct idx_info *)0)->ii_recsize));
-	LASSERTF((int)offsetof(struct idx_info, ii_pad1) == 60, "found %lld\n",
-		 (long long)(int)offsetof(struct idx_info, ii_pad1));
-	LASSERTF((int)sizeof(((struct idx_info *)0)->ii_pad1) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct idx_info *)0)->ii_pad1));
-	LASSERTF((int)offsetof(struct idx_info, ii_pad2) == 64, "found %lld\n",
-		 (long long)(int)offsetof(struct idx_info, ii_pad2));
-	LASSERTF((int)sizeof(((struct idx_info *)0)->ii_pad2) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct idx_info *)0)->ii_pad2));
-	LASSERTF((int)offsetof(struct idx_info, ii_pad3) == 72, "found %lld\n",
-		 (long long)(int)offsetof(struct idx_info, ii_pad3));
-	LASSERTF((int)sizeof(((struct idx_info *)0)->ii_pad3) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct idx_info *)0)->ii_pad3));
-	CLASSERT(IDX_INFO_MAGIC == 0x3D37CC37);
-
-	/* Checks for struct lu_idxpage */
-	LASSERTF((int)sizeof(struct lu_idxpage) == 16, "found %lld\n",
-		 (long long)(int)sizeof(struct lu_idxpage));
-	LASSERTF((int)offsetof(struct lu_idxpage, lip_magic) == 0, "found %lld\n",
-		 (long long)(int)offsetof(struct lu_idxpage, lip_magic));
-	LASSERTF((int)sizeof(((struct lu_idxpage *)0)->lip_magic) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct lu_idxpage *)0)->lip_magic));
-	LASSERTF((int)offsetof(struct lu_idxpage, lip_flags) == 4, "found %lld\n",
-		 (long long)(int)offsetof(struct lu_idxpage, lip_flags));
-	LASSERTF((int)sizeof(((struct lu_idxpage *)0)->lip_flags) == 2, "found %lld\n",
-		 (long long)(int)sizeof(((struct lu_idxpage *)0)->lip_flags));
-	LASSERTF((int)offsetof(struct lu_idxpage, lip_nr) == 6, "found %lld\n",
-		 (long long)(int)offsetof(struct lu_idxpage, lip_nr));
-	LASSERTF((int)sizeof(((struct lu_idxpage *)0)->lip_nr) == 2, "found %lld\n",
-		 (long long)(int)sizeof(((struct lu_idxpage *)0)->lip_nr));
-	LASSERTF((int)offsetof(struct lu_idxpage, lip_pad0) == 8, "found %lld\n",
-		 (long long)(int)offsetof(struct lu_idxpage, lip_pad0));
-	LASSERTF((int)sizeof(((struct lu_idxpage *)0)->lip_pad0) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct lu_idxpage *)0)->lip_pad0));
-	CLASSERT(LIP_MAGIC == 0x8A6D6B6C);
-	LASSERTF(LIP_HDR_SIZE == 16, "found %lld\n",
-		 (long long)LIP_HDR_SIZE);
-	LASSERTF(II_FL_NOHASH == 1, "found %lld\n",
-		 (long long)II_FL_NOHASH);
-	LASSERTF(II_FL_VARKEY == 2, "found %lld\n",
-		 (long long)II_FL_VARKEY);
-	LASSERTF(II_FL_VARREC == 4, "found %lld\n",
-		 (long long)II_FL_VARREC);
-	LASSERTF(II_FL_NONUNQ == 8, "found %lld\n",
-		 (long long)II_FL_NONUNQ);
-
 	/* Checks for struct niobuf_remote */
 	LASSERTF((int)sizeof(struct niobuf_remote) == 16, "found %lld\n",
 		 (long long)(int)sizeof(struct niobuf_remote));
-- 
2.1.0
