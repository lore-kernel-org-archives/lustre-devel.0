From: NeilBrown <neilb@suse.com>
Date: Wed, 04 Jul 2018 14:43:50 +1000
Subject: [lustre-devel] [PATCH 04/11] lustre: fix alignment in lustre_idl.h
In-Reply-To: <153067941050.30111.13691201276059352926.stgit@noble>
References: <153067941050.30111.13691201276059352926.stgit@noble>
Message-ID: <153067943069.30111.15939411313283828400.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lots of fields are aligned inconsistently
with various space and/or tabs.

This patch tries to make it all more consistent.
No code is changed (though some parentheses are added
for improved alignment).

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/uapi/linux/lustre/lustre_idl.h  | 1079 ++++++++++----------
 1 file changed, 540 insertions(+), 539 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index 458a8090d9b9..c9b32ef21b16 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -88,39 +88,39 @@
  */
 #define LUSTRE_MDT_MAXNAMELEN	80
 
-#define CONNMGR_REQUEST_PORTAL	  1
-#define CONNMGR_REPLY_PORTAL	    2
-/*#define OSC_REQUEST_PORTAL	    3 */
-#define OSC_REPLY_PORTAL		4
-/*#define OSC_BULK_PORTAL	       5 */
-#define OST_IO_PORTAL		   6
-#define OST_CREATE_PORTAL	       7
-#define OST_BULK_PORTAL		 8
-/*#define MDC_REQUEST_PORTAL	    9 */
-#define MDC_REPLY_PORTAL	       10
-/*#define MDC_BULK_PORTAL	      11 */
-#define MDS_REQUEST_PORTAL	     12
-/*#define MDS_REPLY_PORTAL	     13 */
+#define CONNMGR_REQUEST_PORTAL	1
+#define CONNMGR_REPLY_PORTAL	2
+/*#define OSC_REQUEST_PORTAL	3 */
+#define OSC_REPLY_PORTAL	4
+/*#define OSC_BULK_PORTAL	5 */
+#define OST_IO_PORTAL		6
+#define OST_CREATE_PORTAL	7
+#define OST_BULK_PORTAL		8
+/*#define MDC_REQUEST_PORTAL	9 */
+#define MDC_REPLY_PORTAL	10
+/*#define MDC_BULK_PORTAL	11 */
+#define MDS_REQUEST_PORTAL	12
+/*#define MDS_REPLY_PORTAL	13 */
 #define MDS_BULK_PORTAL		14
-#define LDLM_CB_REQUEST_PORTAL	 15
-#define LDLM_CB_REPLY_PORTAL	   16
-#define LDLM_CANCEL_REQUEST_PORTAL     17
-#define LDLM_CANCEL_REPLY_PORTAL       18
-/*#define PTLBD_REQUEST_PORTAL	   19 */
-/*#define PTLBD_REPLY_PORTAL	     20 */
-/*#define PTLBD_BULK_PORTAL	      21 */
-#define MDS_SETATTR_PORTAL	     22
-#define MDS_READPAGE_PORTAL	    23
-#define OUT_PORTAL		    24
-
-#define MGC_REPLY_PORTAL	       25
-#define MGS_REQUEST_PORTAL	     26
-#define MGS_REPLY_PORTAL	       27
-#define OST_REQUEST_PORTAL	     28
-#define FLD_REQUEST_PORTAL	     29
-#define SEQ_METADATA_PORTAL	    30
+#define LDLM_CB_REQUEST_PORTAL	15
+#define LDLM_CB_REPLY_PORTAL	16
+#define LDLM_CANCEL_REQUEST_PORTAL 17
+#define LDLM_CANCEL_REPLY_PORTAL   18
+/*#define PTLBD_REQUEST_PORTAL	19 */
+/*#define PTLBD_REPLY_PORTAL	20 */
+/*#define PTLBD_BULK_PORTAL	21 */
+#define MDS_SETATTR_PORTAL	22
+#define MDS_READPAGE_PORTAL	23
+#define OUT_PORTAL		24
+
+#define MGC_REPLY_PORTAL	25
+#define MGS_REQUEST_PORTAL	26
+#define MGS_REPLY_PORTAL	27
+#define OST_REQUEST_PORTAL	28
+#define FLD_REQUEST_PORTAL	29
+#define SEQ_METADATA_PORTAL	30
 #define SEQ_DATA_PORTAL		31
-#define SEQ_CONTROLLER_PORTAL	  32
+#define SEQ_CONTROLLER_PORTAL	32
 #define MGS_BULK_PORTAL		33
 
 /* Portal 63 is reserved for the Cray Inc DVS - nic at cray.com, roe at cray.com,
@@ -128,13 +128,13 @@
  */
 
 /* packet types */
-#define PTL_RPC_MSG_REQUEST 4711
-#define PTL_RPC_MSG_ERR     4712
-#define PTL_RPC_MSG_REPLY   4713
+#define PTL_RPC_MSG_REQUEST	4711
+#define PTL_RPC_MSG_ERR		4712
+#define PTL_RPC_MSG_REPLY	4713
 
 /* DON'T use swabbed values of MAGIC as magic! */
-#define LUSTRE_MSG_MAGIC_V2 0x0BD00BD3
-#define LUSTRE_MSG_MAGIC_V2_SWABBED 0xD30BD00B
+#define LUSTRE_MSG_MAGIC_V2		0x0BD00BD3
+#define LUSTRE_MSG_MAGIC_V2_SWABBED	0xD30BD00B
 
 #define LUSTRE_MSG_MAGIC LUSTRE_MSG_MAGIC_V2
 
@@ -264,23 +264,23 @@ enum fid_seq {
 	FID_SEQ_LOV_DEFAULT	= 0xffffffffffffffffULL
 };
 
-#define OBIF_OID_MAX_BITS	   32
-#define OBIF_MAX_OID		(1ULL << OBIF_OID_MAX_BITS)
-#define OBIF_OID_MASK	       ((1ULL << OBIF_OID_MAX_BITS) - 1)
-#define IDIF_OID_MAX_BITS	   48
-#define IDIF_MAX_OID		(1ULL << IDIF_OID_MAX_BITS)
-#define IDIF_OID_MASK	       ((1ULL << IDIF_OID_MAX_BITS) - 1)
+#define OBIF_OID_MAX_BITS	32
+#define OBIF_MAX_OID		((1ULL << OBIF_OID_MAX_BITS))
+#define OBIF_OID_MASK		((1ULL << OBIF_OID_MAX_BITS) - 1)
+#define IDIF_OID_MAX_BITS	48
+#define IDIF_MAX_OID		((1ULL << IDIF_OID_MAX_BITS))
+#define IDIF_OID_MASK		((1ULL << IDIF_OID_MAX_BITS) - 1)
 
 /** OID for FID_SEQ_SPECIAL */
 enum special_oid {
 	/* Big Filesystem Lock to serialize rename operations */
-	FID_OID_SPECIAL_BFL     = 1UL,
+	FID_OID_SPECIAL_BFL	= 1UL,
 };
 
 /** OID for FID_SEQ_DOT_LUSTRE */
 enum dot_lustre_oid {
-	FID_OID_DOT_LUSTRE  = 1UL,
-	FID_OID_DOT_LUSTRE_OBF = 2UL,
+	FID_OID_DOT_LUSTRE	= 1UL,
+	FID_OID_DOT_LUSTRE_OBF	= 2UL,
 };
 
 /** OID for FID_SEQ_ROOT */
@@ -312,22 +312,22 @@ enum lu_dirent_attrs {
  */
 struct lu_dirent {
 	/** valid if LUDA_FID is set. */
-	struct lu_fid lde_fid;
+	struct lu_fid	lde_fid;
 	/** a unique entry identifier: a hash or an offset. */
-	__u64	 lde_hash;
+	__u64		lde_hash;
 	/** total record length, including all attributes. */
-	__u16	 lde_reclen;
+	__u16		lde_reclen;
 	/** name length */
-	__u16	 lde_namelen;
+	__u16		lde_namelen;
 	/** optional variable size attributes following this entry.
 	 *  taken from enum lu_dirent_attrs.
 	 */
-	__u32	 lde_attrs;
+	__u32		lde_attrs;
 	/** name is followed by the attributes indicated in ->ldp_attrs, in
 	 *  their natural order. After the last attribute, padding bytes are
 	 *  added to make ->lde_reclen a multiple of 8.
 	 */
-	char	  lde_name[0];
+	char		lde_name[0];
 };
 
 /*
@@ -370,10 +370,10 @@ struct luda_type {
 #endif
 
 struct lu_dirpage {
-	__le64	    ldp_hash_start;
-	__le64	    ldp_hash_end;
-	__le32	    ldp_flags;
-	__le32	    ldp_pad0;
+	__le64		ldp_hash_start;
+	__le64		ldp_hash_end;
+	__le32		ldp_flags;
+	__le32		ldp_pad0;
 	struct lu_dirent ldp_entries[0];
 };
 
@@ -551,59 +551,59 @@ struct ptlrpc_body_v2 {
 
 /* message body offset for lustre_msg_v2 */
 /* ptlrpc body offset in all request/reply messages */
-#define MSG_PTLRPC_BODY_OFF	     0
+#define MSG_PTLRPC_BODY_OFF		0
 
 /* normal request/reply message record offset */
-#define REQ_REC_OFF		     1
-#define REPLY_REC_OFF		   1
+#define REQ_REC_OFF			1
+#define REPLY_REC_OFF			1
 
 /* ldlm request message body offset */
-#define DLM_LOCKREQ_OFF		 1 /* lockreq offset */
-#define DLM_REQ_REC_OFF		 2 /* normal dlm request record offset */
+#define DLM_LOCKREQ_OFF			1 /* lockreq offset */
+#define DLM_REQ_REC_OFF			2 /* normal dlm request record offset */
 
 /* ldlm intent lock message body offset */
-#define DLM_INTENT_IT_OFF	       2 /* intent lock it offset */
-#define DLM_INTENT_REC_OFF	      3 /* intent lock record offset */
+#define DLM_INTENT_IT_OFF		2 /* intent lock it offset */
+#define DLM_INTENT_REC_OFF		3 /* intent lock record offset */
 
 /* ldlm reply message body offset */
-#define DLM_LOCKREPLY_OFF	       1 /* lockrep offset */
-#define DLM_REPLY_REC_OFF	       2 /* reply record offset */
+#define DLM_LOCKREPLY_OFF		1 /* lockrep offset */
+#define DLM_REPLY_REC_OFF		2 /* reply record offset */
 
 /** only use in req->rq_{req,rep}_swab_mask */
-#define MSG_PTLRPC_HEADER_OFF	   31
+#define MSG_PTLRPC_HEADER_OFF		31
 
 /* Flags that are operation-specific go in the top 16 bits. */
-#define MSG_OP_FLAG_MASK   0xffff0000
-#define MSG_OP_FLAG_SHIFT  16
+#define MSG_OP_FLAG_MASK		0xffff0000
+#define MSG_OP_FLAG_SHIFT		16
 
 /* Flags that apply to all requests are in the bottom 16 bits */
-#define MSG_GEN_FLAG_MASK     0x0000ffff
-#define MSG_LAST_REPLAY	   0x0001
+#define MSG_GEN_FLAG_MASK	0x0000ffff
+#define MSG_LAST_REPLAY		0x0001
 #define MSG_RESENT		0x0002
 #define MSG_REPLAY		0x0004
-/* #define MSG_AT_SUPPORT	 0x0008
+/* #define MSG_AT_SUPPORT	0x0008
  * This was used in early prototypes of adaptive timeouts, and while there
  * shouldn't be any users of that code there also isn't a need for using this
  * bits. Defer usage until at least 1.10 to avoid potential conflict.
  */
-#define MSG_DELAY_REPLAY	  0x0010
+#define MSG_DELAY_REPLAY	0x0010
 #define MSG_VERSION_REPLAY	0x0020
-#define MSG_REQ_REPLAY_DONE       0x0040
-#define MSG_LOCK_REPLAY_DONE      0x0080
+#define MSG_REQ_REPLAY_DONE	0x0040
+#define MSG_LOCK_REPLAY_DONE	0x0080
 
 /*
  * Flags for all connect opcodes (MDS_CONNECT, OST_CONNECT)
  */
 
-#define MSG_CONNECT_RECOVERING  0x00000001
-#define MSG_CONNECT_RECONNECT   0x00000002
-#define MSG_CONNECT_REPLAYABLE  0x00000004
+#define MSG_CONNECT_RECOVERING	0x00000001
+#define MSG_CONNECT_RECONNECT	0x00000002
+#define MSG_CONNECT_REPLAYABLE	0x00000004
 /*#define MSG_CONNECT_PEER	0x8 */
-#define MSG_CONNECT_LIBCLIENT   0x00000010
-#define MSG_CONNECT_INITIAL     0x00000020
-#define MSG_CONNECT_ASYNC       0x00000040
-#define MSG_CONNECT_NEXT_VER    0x00000080 /* use next version of lustre_msg */
-#define MSG_CONNECT_TRANSNO     0x00000100 /* report transno */
+#define MSG_CONNECT_LIBCLIENT	0x00000010
+#define MSG_CONNECT_INITIAL	0x00000020
+#define MSG_CONNECT_ASYNC	0x00000040
+#define MSG_CONNECT_NEXT_VER	0x00000080 /* use next version of lustre_msg */
+#define MSG_CONNECT_TRANSNO	0x00000100 /* report transno */
 
 /* Connect flags */
 #define OBD_CONNECT_RDONLY		  0x1ULL /*client has read-only access*/
@@ -715,7 +715,7 @@ struct ptlrpc_body_v2 {
  * between 2.2 and 2.3 x86/ppc nodes, and can be removed when interop for
  * 2.2 clients/servers is no longer needed.  LU-1252/LU-1644.
  */
-#define OBD_CONNECT_MNE_SWAB		 OBD_CONNECT_MDS_MDS
+#define OBD_CONNECT_MNE_SWAB		OBD_CONNECT_MDS_MDS
 
 #define OCD_HAS_FLAG(ocd, flg)  \
 	(!!((ocd)->ocd_connect_flags & OBD_CONNECT_##flg))
@@ -730,30 +730,30 @@ struct ptlrpc_body_v2 {
  * almost certainly will, then perhaps we stick a union in here.
  */
 struct obd_connect_data {
-	__u64 ocd_connect_flags; /* OBD_CONNECT_* per above */
-	__u32 ocd_version;	 /* lustre release version number */
-	__u32 ocd_grant;	 /* initial cache grant amount (bytes) */
-	__u32 ocd_index;	 /* LOV index to connect to */
-	__u32 ocd_brw_size;	 /* Maximum BRW size in bytes */
-	__u64 ocd_ibits_known;   /* inode bits this client understands */
-	__u8  ocd_grant_blkbits; /* log2 of the backend filesystem blocksize */
-	__u8  ocd_grant_inobits; /* log2 of the per-inode space consumption */
-	__u16 ocd_grant_tax_kb;  /* extent grant overhead, in 1K blocks */
-	__u32 ocd_grant_max_blks;/* maximum number of blocks per extent */
-	__u64 ocd_transno;       /* first transno from client to be replayed */
-	__u32 ocd_group;	 /* MDS group on OST */
-	__u32 ocd_cksum_types;   /* supported checksum algorithms */
-	__u32 ocd_max_easize;    /* How big LOV EA can be on MDS */
-	__u32 ocd_instance;      /* instance # of this target */
-	__u64 ocd_maxbytes;      /* Maximum stripe size in bytes */
+	__u64 ocd_connect_flags;	/* OBD_CONNECT_* per above */
+	__u32 ocd_version;		/* lustre release version number */
+	__u32 ocd_grant;		/* initial cache grant amount (bytes) */
+	__u32 ocd_index;		/* LOV index to connect to */
+	__u32 ocd_brw_size;		/* Maximum BRW size in bytes */
+	__u64 ocd_ibits_known;		/* inode bits this client understands */
+	__u8  ocd_grant_blkbits;	/* log2 of the backend filesystem blocksize */
+	__u8  ocd_grant_inobits;	/* log2 of the per-inode space consumption */
+	__u16 ocd_grant_tax_kb;		/* extent grant overhead, in 1K blocks */
+	__u32 ocd_grant_max_blks;	/* maximum number of blocks per extent */
+	__u64 ocd_transno;		/* first transno from client to be replayed */
+	__u32 ocd_group;		/* MDS group on OST */
+	__u32 ocd_cksum_types;		/* supported checksum algorithms */
+	__u32 ocd_max_easize;		/* How big LOV EA can be on MDS */
+	__u32 ocd_instance;		/* instance # of this target */
+	__u64 ocd_maxbytes;		/* Maximum stripe size in bytes */
 	/* Fields after ocd_maxbytes are only accessible by the receiver
 	 * if the corresponding flag in ocd_connect_flags is set. Accessing
 	 * any field after ocd_maxbytes on the receiver without a valid flag
 	 * may result in out-of-bound memory access and kernel oops.
 	 */
-	__u16 ocd_maxmodrpcs;	/* Maximum modify RPCs in parallel */
-	__u16 padding0;		/* added 2.1.0. also fix lustre_swab_connect */
-	__u32 padding1;		/* added 2.1.0. also fix lustre_swab_connect */
+	__u16 ocd_maxmodrpcs;		/* Maximum modify RPCs in parallel */
+	__u16 padding0;			/* added 2.1.0. also fix lustre_swab_connect */
+	__u32 padding1;			/* added 2.1.0. also fix lustre_swab_connect */
 	__u64 ocd_connect_flags2;
 	__u64 padding3;	  /* added 2.1.0. also fix lustre_swab_connect */
 	__u64 padding4;	  /* added 2.1.0. also fix lustre_swab_connect */
@@ -816,7 +816,7 @@ enum ost_cmd {
 	OST_QUOTACHECK = 18, /* not used since 2.4 */
 	OST_QUOTACTL   = 19,
 	OST_QUOTA_ADJUST_QUNIT = 20, /* not used since 2.4 */
-	OST_LADVISE		= 21,
+	OST_LADVISE    = 21,
 	OST_LAST_OPC /* must be < 33 to avoid MDS_GETATTR */
 };
 #define OST_FIRST_OPC  OST_REPLY
@@ -825,7 +825,7 @@ enum obdo_flags {
 	OBD_FL_INLINEDATA   = 0x00000001,
 	OBD_FL_OBDMDEXISTS  = 0x00000002,
 	OBD_FL_DELORPHAN    = 0x00000004, /* if set in o_flags delete orphans */
-	OBD_FL_NORPC	    = 0x00000008, /* set in o_flags do in OSC not OST */
+	OBD_FL_NORPC        = 0x00000008, /* set in o_flags do in OSC not OST */
 	OBD_FL_IDONLY       = 0x00000010, /* set in o_flags only adjust obj id*/
 	OBD_FL_RECREATE_OBJS = 0x00000020, /* recreate missing obj */
 	OBD_FL_DEBUG_CHECK  = 0x00000040, /* echo client/server debug check */
@@ -839,14 +839,14 @@ enum obdo_flags {
 	OBD_FL_CKSUM_RSVD2  = 0x00008000, /* for future cksum types */
 	OBD_FL_CKSUM_RSVD3  = 0x00010000, /* for future cksum types */
 	OBD_FL_SHRINK_GRANT = 0x00020000, /* object shrink the grant */
-	OBD_FL_MMAP	    = 0x00040000, /* object is mmapped on the client.
+	OBD_FL_MMAP         = 0x00040000, /* object is mmapped on the client.
 					   * XXX: obsoleted - reserved for old
 					   * clients prior than 2.2
 					   */
 	OBD_FL_RECOV_RESEND = 0x00080000, /* recoverable resent */
 	OBD_FL_NOSPC_BLK    = 0x00100000, /* no more block space on OST */
-	OBD_FL_FLUSH	    = 0x00200000, /* flush pages on the OST */
-	OBD_FL_SHORT_IO	    = 0x00400000, /* short io request */
+	OBD_FL_FLUSH        = 0x00200000, /* flush pages on the OST */
+	OBD_FL_SHORT_IO     = 0x00400000, /* short io request */
 
 	/* Note that while these checksum values are currently separate bits,
 	 * in 2.x we can actually allow all values from 1-31 if we wanted.
@@ -888,28 +888,28 @@ enum obdo_flags {
  * hints), so MDT replaces magic with appropriate one and now LOD can
  * easily understand what's inside -bzzz
  */
-#define LOV_MAGIC_V1_DEF  0x0CD10BD0
-#define LOV_MAGIC_V3_DEF  0x0CD30BD0
+#define LOV_MAGIC_V1_DEF	0x0CD10BD0
+#define LOV_MAGIC_V3_DEF	0x0CD30BD0
 
 #define lov_pattern(pattern)		(pattern & ~LOV_PATTERN_F_MASK)
 #define lov_pattern_flags(pattern)	(pattern & LOV_PATTERN_F_MASK)
 
 #define lov_ost_data lov_ost_data_v1
-struct lov_ost_data_v1 {	  /* per-stripe data structure (little-endian)*/
-	struct ost_id l_ost_oi;	  /* OST object ID */
-	__u32 l_ost_gen;	  /* generation of this l_ost_idx */
-	__u32 l_ost_idx;	  /* OST index in LOV (lov_tgt_desc->tgts) */
+struct lov_ost_data_v1 {	/* per-stripe data structure (little-endian)*/
+	struct ost_id l_ost_oi;	/* OST object ID */
+	__u32 l_ost_gen;	/* generation of this l_ost_idx */
+	__u32 l_ost_idx;	/* OST index in LOV (lov_tgt_desc->tgts) */
 };
 
 #define lov_mds_md lov_mds_md_v1
-struct lov_mds_md_v1 {	    /* LOV EA mds/wire data (little-endian) */
-	__u32 lmm_magic;	  /* magic number = LOV_MAGIC_V1 */
-	__u32 lmm_pattern;	/* LOV_PATTERN_RAID0, LOV_PATTERN_RAID1 */
-	struct ost_id	lmm_oi;	  /* LOV object ID */
-	__u32 lmm_stripe_size;    /* size of stripe in bytes */
+struct lov_mds_md_v1 {		/* LOV EA mds/wire data (little-endian) */
+	__u32		lmm_magic;	/* magic number = LOV_MAGIC_V1 */
+	__u32		lmm_pattern;	/* LOV_PATTERN_RAID0, LOV_PATTERN_RAID1 */
+	struct ost_id	lmm_oi;		/* LOV object ID */
+	__u32		lmm_stripe_size;/* size of stripe in bytes */
 	/* lmm_stripe_count used to be __u32 */
-	__u16 lmm_stripe_count;   /* num stripes in use for this object */
-	__u16 lmm_layout_gen;     /* layout generation number */
+	__u16		lmm_stripe_count;/* num stripes in use for this object */
+	__u16		lmm_layout_gen;	/* layout generation number */
 	struct lov_ost_data_v1 lmm_objects[0]; /* per-stripe data */
 };
 
@@ -918,32 +918,32 @@ struct lov_mds_md_v1 {	    /* LOV EA mds/wire data (little-endian) */
 #define MIN_MD_SIZE							\
 	(sizeof(struct lov_mds_md) + 1 * sizeof(struct lov_ost_data))
 
-#define XATTR_NAME_ACL_ACCESS   "system.posix_acl_access"
-#define XATTR_NAME_ACL_DEFAULT  "system.posix_acl_default"
-#define XATTR_USER_PREFIX       "user."
-#define XATTR_TRUSTED_PREFIX    "trusted."
-#define XATTR_SECURITY_PREFIX   "security."
-#define XATTR_LUSTRE_PREFIX     "lustre."
+#define XATTR_NAME_ACL_ACCESS	"system.posix_acl_access"
+#define XATTR_NAME_ACL_DEFAULT	"system.posix_acl_default"
+#define XATTR_USER_PREFIX	"user."
+#define XATTR_TRUSTED_PREFIX	"trusted."
+#define XATTR_SECURITY_PREFIX	"security."
+#define XATTR_LUSTRE_PREFIX	"lustre."
 
-#define XATTR_NAME_LOV	  "trusted.lov"
-#define XATTR_NAME_LMA	  "trusted.lma"
-#define XATTR_NAME_LMV	  "trusted.lmv"
+#define XATTR_NAME_LOV		"trusted.lov"
+#define XATTR_NAME_LMA		"trusted.lma"
+#define XATTR_NAME_LMV		"trusted.lmv"
 #define XATTR_NAME_DEFAULT_LMV	"trusted.dmv"
-#define XATTR_NAME_LINK	 "trusted.link"
-#define XATTR_NAME_FID	  "trusted.fid"
-#define XATTR_NAME_VERSION      "trusted.version"
+#define XATTR_NAME_LINK		"trusted.link"
+#define XATTR_NAME_FID		"trusted.fid"
+#define XATTR_NAME_VERSION	"trusted.version"
 #define XATTR_NAME_SOM		"trusted.som"
 #define XATTR_NAME_HSM		"trusted.hsm"
 #define XATTR_NAME_LFSCK_NAMESPACE "trusted.lfsck_namespace"
 
-struct lov_mds_md_v3 {	    /* LOV EA mds/wire data (little-endian) */
-	__u32 lmm_magic;	  /* magic number = LOV_MAGIC_V3 */
+struct lov_mds_md_v3 {		/* LOV EA mds/wire data (little-endian) */
+	__u32 lmm_magic;	/* magic number = LOV_MAGIC_V3 */
 	__u32 lmm_pattern;	/* LOV_PATTERN_RAID0, LOV_PATTERN_RAID1 */
-	struct ost_id	lmm_oi;	  /* LOV object ID */
-	__u32 lmm_stripe_size;    /* size of stripe in bytes */
+	struct ost_id	lmm_oi;	/* LOV object ID */
+	__u32 lmm_stripe_size;	/* size of stripe in bytes */
 	/* lmm_stripe_count used to be __u32 */
-	__u16 lmm_stripe_count;   /* num stripes in use for this object */
-	__u16 lmm_layout_gen;     /* layout generation number */
+	__u16 lmm_stripe_count;	/* num stripes in use for this object */
+	__u16 lmm_layout_gen;	/* layout generation number */
 	char  lmm_pool_name[LOV_MAXPOOLNAME + 1]; /* must be 32bit aligned */
 	struct lov_ost_data_v1 lmm_objects[0]; /* per-stripe data */
 };
@@ -983,72 +983,71 @@ lov_mds_md_max_stripe_count(size_t buf_size, __u32 lmm_magic)
 	}
 }
 
-#define OBD_MD_FLID	   (0x00000001ULL) /* object ID */
-#define OBD_MD_FLATIME     (0x00000002ULL) /* access time */
-#define OBD_MD_FLMTIME     (0x00000004ULL) /* data modification time */
-#define OBD_MD_FLCTIME     (0x00000008ULL) /* change time */
-#define OBD_MD_FLSIZE      (0x00000010ULL) /* size */
-#define OBD_MD_FLBLOCKS    (0x00000020ULL) /* allocated blocks count */
-#define OBD_MD_FLBLKSZ     (0x00000040ULL) /* block size */
-#define OBD_MD_FLMODE      (0x00000080ULL) /* access bits (mode & ~S_IFMT) */
-#define OBD_MD_FLTYPE      (0x00000100ULL) /* object type (mode & S_IFMT) */
-#define OBD_MD_FLUID       (0x00000200ULL) /* user ID */
-#define OBD_MD_FLGID       (0x00000400ULL) /* group ID */
-#define OBD_MD_FLFLAGS     (0x00000800ULL) /* flags word */
-#define OBD_MD_FLNLINK     (0x00002000ULL) /* link count */
-#define OBD_MD_FLGENER     (0x00004000ULL) /* generation number */
-/*#define OBD_MD_FLINLINE    (0x00008000ULL)  inline data. used until 1.6.5 */
-#define OBD_MD_FLRDEV      (0x00010000ULL) /* device number */
-#define OBD_MD_FLEASIZE    (0x00020000ULL) /* extended attribute data */
-#define OBD_MD_LINKNAME    (0x00040000ULL) /* symbolic link target */
-#define OBD_MD_FLHANDLE    (0x00080000ULL) /* file/lock handle */
-#define OBD_MD_FLCKSUM     (0x00100000ULL) /* bulk data checksum */
-#define OBD_MD_FLQOS       (0x00200000ULL) /* quality of service stats */
-/*#define OBD_MD_FLOSCOPQ    (0x00400000ULL) osc opaque data, never used */
-/*	OBD_MD_FLCOOKIE    (0x00800000ULL) obsolete in 2.8 */
-#define OBD_MD_FLGROUP     (0x01000000ULL) /* group */
-#define OBD_MD_FLFID       (0x02000000ULL) /* ->ost write inline fid */
-#define OBD_MD_FLEPOCH     (0x04000000ULL) /* ->ost write with ioepoch */
-					   /* ->mds if epoch opens or closes
-					    */
-#define OBD_MD_FLGRANT     (0x08000000ULL) /* ost preallocation space grant */
-#define OBD_MD_FLDIREA     (0x10000000ULL) /* dir's extended attribute data */
-#define OBD_MD_FLUSRQUOTA  (0x20000000ULL) /* over quota flags sent from ost */
-#define OBD_MD_FLGRPQUOTA  (0x40000000ULL) /* over quota flags sent from ost */
-#define OBD_MD_FLMODEASIZE (0x80000000ULL) /* EA size will be changed */
-
-#define OBD_MD_MDS	   (0x0000000100000000ULL) /* where an inode lives on */
-#define OBD_MD_REINT       (0x0000000200000000ULL) /* reintegrate oa */
-#define OBD_MD_MEA	   (0x0000000400000000ULL) /* CMD split EA  */
-#define OBD_MD_TSTATE      (0x0000000800000000ULL) /* transient state field */
-
-#define OBD_MD_FLXATTR       (0x0000001000000000ULL) /* xattr */
-#define OBD_MD_FLXATTRLS     (0x0000002000000000ULL) /* xattr list */
-#define OBD_MD_FLXATTRRM     (0x0000004000000000ULL) /* xattr remove */
-#define OBD_MD_FLACL	     (0x0000008000000000ULL) /* ACL */
-/*	OBD_MD_FLRMTPERM     (0x0000010000000000ULL) remote perm, obsolete */
-#define OBD_MD_FLMDSCAPA     (0x0000020000000000ULL) /* MDS capability */
-#define OBD_MD_FLOSSCAPA     (0x0000040000000000ULL) /* OSS capability */
-#define OBD_MD_FLCKSPLIT     (0x0000080000000000ULL) /* Check split on server */
-#define OBD_MD_FLCROSSREF    (0x0000100000000000ULL) /* Cross-ref case */
-#define OBD_MD_FLGETATTRLOCK (0x0000200000000000ULL) /* Get IOEpoch attributes
-						      * under lock; for xattr
-						      * requests means the
-						      * client holds the lock
-						      */
-#define OBD_MD_FLOBJCOUNT    (0x0000400000000000ULL) /* for multiple destroy */
-
-/*	OBD_MD_FLRMTLSETFACL (0x0001000000000000ULL) lfs lsetfacl, obsolete */
-/*	OBD_MD_FLRMTLGETFACL (0x0002000000000000ULL) lfs lgetfacl, obsolete */
-/*	OBD_MD_FLRMTRSETFACL (0x0004000000000000ULL) lfs rsetfacl, obsolete */
-/*	OBD_MD_FLRMTRGETFACL (0x0008000000000000ULL) lfs rgetfacl, obsolete */
-
-#define OBD_MD_FLDATAVERSION (0x0010000000000000ULL) /* iversion sum */
+#define OBD_MD_FLID		(0x00000001ULL) /* object ID */
+#define OBD_MD_FLATIME		(0x00000002ULL) /* access time */
+#define OBD_MD_FLMTIME		(0x00000004ULL) /* data modification time */
+#define OBD_MD_FLCTIME		(0x00000008ULL) /* change time */
+#define OBD_MD_FLSIZE		(0x00000010ULL) /* size */
+#define OBD_MD_FLBLOCKS		(0x00000020ULL) /* allocated blocks count */
+#define OBD_MD_FLBLKSZ		(0x00000040ULL) /* block size */
+#define OBD_MD_FLMODE		(0x00000080ULL) /* access bits (mode & ~S_IFMT) */
+#define OBD_MD_FLTYPE		(0x00000100ULL) /* object type (mode & S_IFMT) */
+#define OBD_MD_FLUID		(0x00000200ULL) /* user ID */
+#define OBD_MD_FLGID		(0x00000400ULL) /* group ID */
+#define OBD_MD_FLFLAGS		(0x00000800ULL) /* flags word */
+#define OBD_MD_FLNLINK		(0x00002000ULL) /* link count */
+#define OBD_MD_FLGENER		(0x00004000ULL) /* generation number */
+/*#define OBD_MD_FLINLINE	(0x00008000ULL)  inline data. used until 1.6.5 */
+#define OBD_MD_FLRDEV		(0x00010000ULL) /* device number */
+#define OBD_MD_FLEASIZE		(0x00020000ULL) /* extended attribute data */
+#define OBD_MD_LINKNAME		(0x00040000ULL) /* symbolic link target */
+#define OBD_MD_FLHANDLE		(0x00080000ULL) /* file/lock handle */
+#define OBD_MD_FLCKSUM		(0x00100000ULL) /* bulk data checksum */
+#define OBD_MD_FLQOS		(0x00200000ULL) /* quality of service stats */
+/*#define OBD_MD_FLOSCOPQ	(0x00400000ULL) osc opaque data, never used */
+/*	OBD_MD_FLCOOKIE		(0x00800000ULL) obsolete in 2.8 */
+#define OBD_MD_FLGROUP		(0x01000000ULL) /* group */
+#define OBD_MD_FLFID		(0x02000000ULL) /* ->ost write inline fid */
+#define OBD_MD_FLEPOCH		(0x04000000ULL) /* ->ost write with ioepoch */
+						/* ->mds if epoch opens or closes */
+#define OBD_MD_FLGRANT		(0x08000000ULL) /* ost preallocation space grant */
+#define OBD_MD_FLDIREA		(0x10000000ULL) /* dir's extended attribute data */
+#define OBD_MD_FLUSRQUOTA	(0x20000000ULL) /* over quota flags sent from ost */
+#define OBD_MD_FLGRPQUOTA	(0x40000000ULL) /* over quota flags sent from ost */
+#define OBD_MD_FLMODEASIZE	(0x80000000ULL) /* EA size will be changed */
+
+#define OBD_MD_MDS		(0x0000000100000000ULL) /* where an inode lives on */
+#define OBD_MD_REINT		(0x0000000200000000ULL) /* reintegrate oa */
+#define OBD_MD_MEA		(0x0000000400000000ULL) /* CMD split EA  */
+#define OBD_MD_TSTATE		(0x0000000800000000ULL) /* transient state field */
+
+#define OBD_MD_FLXATTR		(0x0000001000000000ULL) /* xattr */
+#define OBD_MD_FLXATTRLS	(0x0000002000000000ULL) /* xattr list */
+#define OBD_MD_FLXATTRRM	(0x0000004000000000ULL) /* xattr remove */
+#define OBD_MD_FLACL		(0x0000008000000000ULL) /* ACL */
+/*	OBD_MD_FLRMTPERM	(0x0000010000000000ULL) remote perm, obsolete */
+#define OBD_MD_FLMDSCAPA	(0x0000020000000000ULL) /* MDS capability */
+#define OBD_MD_FLOSSCAPA	(0x0000040000000000ULL) /* OSS capability */
+#define OBD_MD_FLCKSPLIT	(0x0000080000000000ULL) /* Check split on server */
+#define OBD_MD_FLCROSSREF	(0x0000100000000000ULL) /* Cross-ref case */
+#define OBD_MD_FLGETATTRLOCK	(0x0000200000000000ULL) /* Get IOEpoch attributes
+							 * under lock; for xattr
+							 * requests means the
+							 * client holds the lock
+							 */
+#define OBD_MD_FLOBJCOUNT	(0x0000400000000000ULL) /* for multiple destroy */
+
+/*	OBD_MD_FLRMTLSETFACL	(0x0001000000000000ULL) lfs lsetfacl, obsolete */
+/*	OBD_MD_FLRMTLGETFACL	(0x0002000000000000ULL) lfs lgetfacl, obsolete */
+/*	OBD_MD_FLRMTRSETFACL	(0x0004000000000000ULL) lfs rsetfacl, obsolete */
+/*	OBD_MD_FLRMTRGETFACL	(0x0008000000000000ULL) lfs rgetfacl, obsolete */
+
+#define OBD_MD_FLDATAVERSION	(0x0010000000000000ULL) /* iversion sum */
 #define OBD_MD_CLOSE_INTENT_EXECED (0x0020000000000000ULL) /* close intent
 							    * executed
 							    */
 
-#define OBD_MD_DEFAULT_MEA   (0x0040000000000000ULL) /* default MEA */
+#define OBD_MD_DEFAULT_MEA	(0x0040000000000000ULL) /* default MEA */
 
 #define OBD_MD_FLGETATTR (OBD_MD_FLID    | OBD_MD_FLATIME | OBD_MD_FLMTIME | \
 			  OBD_MD_FLCTIME | OBD_MD_FLSIZE  | OBD_MD_FLBLKSZ | \
@@ -1085,7 +1084,7 @@ struct hsm_state_set {
 				      * the grant.
 				      */
 #define OBD_BRW_CHECK		0x10
-#define OBD_BRW_FROM_GRANT      0x20 /* the osc manages this under llite */
+#define OBD_BRW_FROM_GRANT	0x20 /* the osc manages this under llite */
 #define OBD_BRW_GRANTED		0x40 /* the ost manages this */
 #define OBD_BRW_NOCACHE		0x80 /* this page is a part of non-cached IO */
 #define OBD_BRW_NOQUOTA	       0x100
@@ -1280,41 +1279,43 @@ enum mds_cmd {
  */
 
 enum mdt_reint_cmd {
-	REINT_SETATTR  = 1,
-	REINT_CREATE   = 2,
-	REINT_LINK     = 3,
-	REINT_UNLINK   = 4,
-	REINT_RENAME   = 5,
-	REINT_OPEN     = 6,
-	REINT_SETXATTR = 7,
-	REINT_RMENTRY  = 8,
-	REINT_MIGRATE  = 9,
+	REINT_SETATTR	= 1,
+	REINT_CREATE	= 2,
+	REINT_LINK	= 3,
+	REINT_UNLINK	= 4,
+	REINT_RENAME	= 5,
+	REINT_OPEN	= 6,
+	REINT_SETXATTR	= 7,
+	REINT_RMENTRY	= 8,
+	REINT_MIGRATE	= 9,
 	REINT_MAX
 };
 
 /* the disposition of the intent outlines what was executed */
-#define DISP_IT_EXECD	0x00000001
-#define DISP_LOOKUP_EXECD    0x00000002
-#define DISP_LOOKUP_NEG      0x00000004
-#define DISP_LOOKUP_POS      0x00000008
-#define DISP_OPEN_CREATE     0x00000010
-#define DISP_OPEN_OPEN       0x00000020
-#define DISP_ENQ_COMPLETE    0x00400000		/* obsolete and unused */
-#define DISP_ENQ_OPEN_REF    0x00800000
-#define DISP_ENQ_CREATE_REF  0x01000000
-#define DISP_OPEN_LOCK       0x02000000
-#define DISP_OPEN_LEASE      0x04000000
-#define DISP_OPEN_STRIPE     0x08000000
+#define DISP_IT_EXECD		0x00000001
+#define DISP_LOOKUP_EXECD	0x00000002
+#define DISP_LOOKUP_NEG		0x00000004
+#define DISP_LOOKUP_POS		0x00000008
+#define DISP_OPEN_CREATE	0x00000010
+#define DISP_OPEN_OPEN		0x00000020
+#define DISP_ENQ_COMPLETE	0x00400000		/* obsolete and unused */
+#define DISP_ENQ_OPEN_REF	0x00800000
+#define DISP_ENQ_CREATE_REF	0x01000000
+#define DISP_OPEN_LOCK		0x02000000
+#define DISP_OPEN_LEASE		0x04000000
+#define DISP_OPEN_STRIPE	0x08000000
 #define DISP_OPEN_DENY		0x10000000
 
 /* INODE LOCK PARTS */
-#define MDS_INODELOCK_LOOKUP 0x000001	/* For namespace, dentry etc, and also
-					 * was used to protect permission (mode,
-					 * owner, group etc) before 2.4.
-					 */
-#define MDS_INODELOCK_UPDATE 0x000002	/* size, links, timestamps */
-#define MDS_INODELOCK_OPEN   0x000004	/* For opened files */
-#define MDS_INODELOCK_LAYOUT 0x000008	/* for layout */
+#define MDS_INODELOCK_LOOKUP	0x000001	/*
+						 * For namespace, dentry etc, and
+						 * also was used to protect
+						 * permission (mode, owner, group
+						 * etc) before 2.4.
+						 */
+#define MDS_INODELOCK_UPDATE	0x000002	/* size, links, timestamps */
+#define MDS_INODELOCK_OPEN	0x000004	/* For opened files */
+#define MDS_INODELOCK_LAYOUT	0x000008	/* for layout */
 
 /* The PERM bit is added int 2.4, and it is used to protect permission(mode,
  * owner, group, acl etc), so to separate the permission from LOOKUP lock.
@@ -1326,8 +1327,8 @@ enum mdt_reint_cmd {
  * grant UPDATE_LOCK|PERM_LOCK, and the remote MDT, where the name entry is,
  * will grant LOOKUP_LOCK.
  */
-#define MDS_INODELOCK_PERM   0x000010
-#define MDS_INODELOCK_XATTR  0x000020	/* extended attributes */
+#define MDS_INODELOCK_PERM	0x000010
+#define MDS_INODELOCK_XATTR	0x000020	/* extended attributes */
 
 #define MDS_INODELOCK_MAXSHIFT 5
 /* This FULL lock is useful to take on unlink sort of operations */
@@ -1352,13 +1353,13 @@ enum {
 /* these should be identical to their EXT4_*_FL counterparts, they are
  * redefined here only to avoid dragging in fs/ext4/ext4.h
  */
-#define LUSTRE_SYNC_FL	 0x00000008 /* Synchronous updates */
-#define LUSTRE_IMMUTABLE_FL    0x00000010 /* Immutable file */
-#define LUSTRE_APPEND_FL       0x00000020 /* writes to file may only append */
+#define LUSTRE_SYNC_FL		0x00000008 /* Synchronous updates */
+#define LUSTRE_IMMUTABLE_FL	0x00000010 /* Immutable file */
+#define LUSTRE_APPEND_FL	0x00000020 /* writes to file may only append */
 #define LUSTRE_NODUMP_FL	0x00000040 /* do not dump file */
-#define LUSTRE_NOATIME_FL      0x00000080 /* do not update atime */
+#define LUSTRE_NOATIME_FL	0x00000080 /* do not update atime */
 #define LUSTRE_INDEX_FL		0x00001000 /* hash-indexed directory */
-#define LUSTRE_DIRSYNC_FL      0x00010000 /* dirsync behaviour (dir only) */
+#define LUSTRE_DIRSYNC_FL	0x00010000 /* dirsync behaviour (dir only) */
 #define LUSTRE_TOPDIR_FL	0x00020000 /* Top of directory hierarchies*/
 #define LUSTRE_DIRECTIO_FL	0x00100000 /* Use direct i/o */
 #define LUSTRE_INLINE_DATA_FL	0x10000000 /* Inode has inline data. */
@@ -1442,37 +1443,37 @@ struct mdt_ioepoch {
 
 /* permissions for md_perm.mp_perm */
 enum {
-	CFS_SETUID_PERM = 0x01,
-	CFS_SETGID_PERM = 0x02,
-	CFS_SETGRP_PERM = 0x04,
+	CFS_SETUID_PERM =	0x01,
+	CFS_SETGID_PERM =	0x02,
+	CFS_SETGRP_PERM =	0x04,
 };
 
 struct mdt_rec_setattr {
-	__u32	   sa_opcode;
-	__u32	   sa_cap;
-	__u32	   sa_fsuid;
-	__u32	   sa_fsuid_h;
-	__u32	   sa_fsgid;
-	__u32	   sa_fsgid_h;
-	__u32	   sa_suppgid;
-	__u32	   sa_suppgid_h;
-	__u32	   sa_padding_1;
-	__u32	   sa_padding_1_h;
-	struct lu_fid   sa_fid;
-	__u64	   sa_valid;
-	__u32	   sa_uid;
-	__u32	   sa_gid;
-	__u64	   sa_size;
-	__u64	   sa_blocks;
-	__s64	   sa_mtime;
-	__s64	   sa_atime;
-	__s64	   sa_ctime;
-	__u32	   sa_attr_flags;
-	__u32	   sa_mode;
-	__u32	   sa_bias;      /* some operation flags */
-	__u32	   sa_padding_3;
-	__u32	   sa_padding_4;
-	__u32	   sa_padding_5;
+	__u32		sa_opcode;
+	__u32		sa_cap;
+	__u32		sa_fsuid;
+	__u32		sa_fsuid_h;
+	__u32		sa_fsgid;
+	__u32		sa_fsgid_h;
+	__u32		sa_suppgid;
+	__u32		sa_suppgid_h;
+	__u32		sa_padding_1;
+	__u32		sa_padding_1_h;
+	struct lu_fid	sa_fid;
+	__u64		sa_valid;
+	__u32		sa_uid;
+	__u32		sa_gid;
+	__u64		sa_size;
+	__u64		sa_blocks;
+	__s64		sa_mtime;
+	__s64		sa_atime;
+	__s64		sa_ctime;
+	__u32		sa_attr_flags;
+	__u32		sa_mode;
+	__u32		sa_bias;      /* some operation flags */
+	__u32		sa_padding_3;
+	__u32		sa_padding_4;
+	__u32		sa_padding_5;
 };
 
 /*
@@ -1481,40 +1482,40 @@ struct mdt_rec_setattr {
  * since the client and MDS may run different kernels (see bug 13828)
  * Therefore, we should only use MDS_ATTR_* attributes for sa_valid.
  */
-#define MDS_ATTR_MODE	       0x1ULL /* = 1 */
-#define MDS_ATTR_UID	       0x2ULL /* = 2 */
-#define MDS_ATTR_GID	       0x4ULL /* = 4 */
-#define MDS_ATTR_SIZE	       0x8ULL /* = 8 */
-#define MDS_ATTR_ATIME	      0x10ULL /* = 16 */
-#define MDS_ATTR_MTIME	      0x20ULL /* = 32 */
-#define MDS_ATTR_CTIME	      0x40ULL /* = 64 */
-#define MDS_ATTR_ATIME_SET    0x80ULL /* = 128 */
-#define MDS_ATTR_MTIME_SET   0x100ULL /* = 256 */
-#define MDS_ATTR_FORCE       0x200ULL /* = 512, Not a change, but a change it */
-#define MDS_ATTR_ATTR_FLAG   0x400ULL /* = 1024 */
-#define MDS_ATTR_KILL_SUID   0x800ULL /* = 2048 */
-#define MDS_ATTR_KILL_SGID  0x1000ULL /* = 4096 */
-#define MDS_ATTR_CTIME_SET  0x2000ULL /* = 8192 */
-#define MDS_ATTR_FROM_OPEN  0x4000ULL /* = 16384, called from open path,
-				       * ie O_TRUNC
-				       */
-#define MDS_ATTR_BLOCKS     0x8000ULL /* = 32768 */
+#define MDS_ATTR_MODE		   0x1ULL /* = 1 */
+#define MDS_ATTR_UID		   0x2ULL /* = 2 */
+#define MDS_ATTR_GID		   0x4ULL /* = 4 */
+#define MDS_ATTR_SIZE		   0x8ULL /* = 8 */
+#define MDS_ATTR_ATIME		  0x10ULL /* = 16 */
+#define MDS_ATTR_MTIME		  0x20ULL /* = 32 */
+#define MDS_ATTR_CTIME		  0x40ULL /* = 64 */
+#define MDS_ATTR_ATIME_SET	  0x80ULL /* = 128 */
+#define MDS_ATTR_MTIME_SET	 0x100ULL /* = 256 */
+#define MDS_ATTR_FORCE		 0x200ULL /* = 512, Not a change, but a change it */
+#define MDS_ATTR_ATTR_FLAG	 0x400ULL /* = 1024 */
+#define MDS_ATTR_KILL_SUID	 0x800ULL /* = 2048 */
+#define MDS_ATTR_KILL_SGID	0x1000ULL /* = 4096 */
+#define MDS_ATTR_CTIME_SET	0x2000ULL /* = 8192 */
+#define MDS_ATTR_FROM_OPEN	0x4000ULL /* = 16384, called from open path,
+					   * ie O_TRUNC
+					   */
+#define MDS_ATTR_BLOCKS		0x8000ULL /* = 32768 */
 
-#define MDS_FMODE_CLOSED	 00000000
-#define MDS_FMODE_EXEC	   00000004
+#define MDS_FMODE_CLOSED	00000000
+#define MDS_FMODE_EXEC		00000004
 /*	MDS_FMODE_EPOCH		01000000 obsolete since 2.8.0 */
 /*	MDS_FMODE_TRUNC		02000000 obsolete since 2.8.0 */
 /*	MDS_FMODE_SOM		04000000 obsolete since 2.8.0 */
 
-#define MDS_OPEN_CREATED	 00000010
-#define MDS_OPEN_CROSS	   00000020
+#define MDS_OPEN_CREATED	00000010
+#define MDS_OPEN_CROSS		00000020
 
-#define MDS_OPEN_CREAT	   00000100
-#define MDS_OPEN_EXCL	    00000200
-#define MDS_OPEN_TRUNC	   00001000
-#define MDS_OPEN_APPEND	  00002000
-#define MDS_OPEN_SYNC	    00010000
-#define MDS_OPEN_DIRECTORY       00200000
+#define MDS_OPEN_CREAT		00000100
+#define MDS_OPEN_EXCL		00000200
+#define MDS_OPEN_TRUNC		00001000
+#define MDS_OPEN_APPEND		00002000
+#define MDS_OPEN_SYNC		00010000
+#define MDS_OPEN_DIRECTORY	00200000
 
 #define MDS_OPEN_BY_FID		040000000 /* open_by_fid for known object */
 #define MDS_OPEN_DELAY_CREATE  0100000000 /* delay initial object create */
@@ -1567,143 +1568,143 @@ enum mds_op_bias {
 
 /* instance of mdt_reint_rec */
 struct mdt_rec_create {
-	__u32	   cr_opcode;
-	__u32	   cr_cap;
-	__u32	   cr_fsuid;
-	__u32	   cr_fsuid_h;
-	__u32	   cr_fsgid;
-	__u32	   cr_fsgid_h;
-	__u32	   cr_suppgid1;
-	__u32	   cr_suppgid1_h;
-	__u32	   cr_suppgid2;
-	__u32	   cr_suppgid2_h;
+	__u32		cr_opcode;
+	__u32		cr_cap;
+	__u32		cr_fsuid;
+	__u32		cr_fsuid_h;
+	__u32		cr_fsgid;
+	__u32		cr_fsgid_h;
+	__u32		cr_suppgid1;
+	__u32		cr_suppgid1_h;
+	__u32		cr_suppgid2;
+	__u32		cr_suppgid2_h;
 	struct lu_fid   cr_fid1;
 	struct lu_fid   cr_fid2;
 	struct lustre_handle cr_old_handle; /* handle in case of open replay */
-	__s64	   cr_time;
-	__u64	   cr_rdev;
-	__u64	   cr_ioepoch;
-	__u64	   cr_padding_1;   /* rr_blocks */
-	__u32	   cr_mode;
-	__u32	   cr_bias;
+	__s64		cr_time;
+	__u64		cr_rdev;
+	__u64		cr_ioepoch;
+	__u64		cr_padding_1;   /* rr_blocks */
+	__u32		cr_mode;
+	__u32		cr_bias;
 	/* use of helpers set/get_mrc_cr_flags() is needed to access
 	 * 64 bits cr_flags [cr_flags_l, cr_flags_h], this is done to
 	 * extend cr_flags size without breaking 1.8 compat
 	 */
-	__u32	   cr_flags_l;     /* for use with open, low  32 bits  */
-	__u32	   cr_flags_h;     /* for use with open, high 32 bits */
-	__u32	   cr_umask;       /* umask for create */
-	__u32	   cr_padding_4;   /* rr_padding_4 */
+	__u32		cr_flags_l;     /* for use with open, low  32 bits  */
+	__u32		cr_flags_h;     /* for use with open, high 32 bits */
+	__u32		cr_umask;       /* umask for create */
+	__u32		cr_padding_4;   /* rr_padding_4 */
 };
 
 /* instance of mdt_reint_rec */
 struct mdt_rec_link {
-	__u32	   lk_opcode;
-	__u32	   lk_cap;
-	__u32	   lk_fsuid;
-	__u32	   lk_fsuid_h;
-	__u32	   lk_fsgid;
-	__u32	   lk_fsgid_h;
-	__u32	   lk_suppgid1;
-	__u32	   lk_suppgid1_h;
-	__u32	   lk_suppgid2;
-	__u32	   lk_suppgid2_h;
+	__u32		lk_opcode;
+	__u32		lk_cap;
+	__u32		lk_fsuid;
+	__u32		lk_fsuid_h;
+	__u32		lk_fsgid;
+	__u32		lk_fsgid_h;
+	__u32		lk_suppgid1;
+	__u32		lk_suppgid1_h;
+	__u32		lk_suppgid2;
+	__u32		lk_suppgid2_h;
 	struct lu_fid   lk_fid1;
 	struct lu_fid   lk_fid2;
-	__s64	   lk_time;
-	__u64	   lk_padding_1;   /* rr_atime */
-	__u64	   lk_padding_2;   /* rr_ctime */
-	__u64	   lk_padding_3;   /* rr_size */
-	__u64	   lk_padding_4;   /* rr_blocks */
-	__u32	   lk_bias;
-	__u32	   lk_padding_5;   /* rr_mode */
-	__u32	   lk_padding_6;   /* rr_flags */
-	__u32	   lk_padding_7;   /* rr_padding_2 */
-	__u32	   lk_padding_8;   /* rr_padding_3 */
-	__u32	   lk_padding_9;   /* rr_padding_4 */
+	__s64		lk_time;
+	__u64		lk_padding_1;   /* rr_atime */
+	__u64		lk_padding_2;   /* rr_ctime */
+	__u64		lk_padding_3;   /* rr_size */
+	__u64		lk_padding_4;   /* rr_blocks */
+	__u32		lk_bias;
+	__u32		lk_padding_5;   /* rr_mode */
+	__u32		lk_padding_6;   /* rr_flags */
+	__u32		lk_padding_7;   /* rr_padding_2 */
+	__u32		lk_padding_8;   /* rr_padding_3 */
+	__u32		lk_padding_9;   /* rr_padding_4 */
 };
 
 /* instance of mdt_reint_rec */
 struct mdt_rec_unlink {
-	__u32	   ul_opcode;
-	__u32	   ul_cap;
-	__u32	   ul_fsuid;
-	__u32	   ul_fsuid_h;
-	__u32	   ul_fsgid;
-	__u32	   ul_fsgid_h;
-	__u32	   ul_suppgid1;
-	__u32	   ul_suppgid1_h;
-	__u32	   ul_suppgid2;
-	__u32	   ul_suppgid2_h;
+	__u32		ul_opcode;
+	__u32		ul_cap;
+	__u32		ul_fsuid;
+	__u32		ul_fsuid_h;
+	__u32		ul_fsgid;
+	__u32		ul_fsgid_h;
+	__u32		ul_suppgid1;
+	__u32		ul_suppgid1_h;
+	__u32		ul_suppgid2;
+	__u32		ul_suppgid2_h;
 	struct lu_fid   ul_fid1;
 	struct lu_fid   ul_fid2;
-	__s64	   ul_time;
-	__u64	   ul_padding_2;   /* rr_atime */
-	__u64	   ul_padding_3;   /* rr_ctime */
-	__u64	   ul_padding_4;   /* rr_size */
-	__u64	   ul_padding_5;   /* rr_blocks */
-	__u32	   ul_bias;
-	__u32	   ul_mode;
-	__u32	   ul_padding_6;   /* rr_flags */
-	__u32	   ul_padding_7;   /* rr_padding_2 */
-	__u32	   ul_padding_8;   /* rr_padding_3 */
-	__u32	   ul_padding_9;   /* rr_padding_4 */
+	__s64		ul_time;
+	__u64		ul_padding_2;   /* rr_atime */
+	__u64		ul_padding_3;   /* rr_ctime */
+	__u64		ul_padding_4;   /* rr_size */
+	__u64		ul_padding_5;   /* rr_blocks */
+	__u32		ul_bias;
+	__u32		ul_mode;
+	__u32		ul_padding_6;   /* rr_flags */
+	__u32		ul_padding_7;   /* rr_padding_2 */
+	__u32		ul_padding_8;   /* rr_padding_3 */
+	__u32		ul_padding_9;   /* rr_padding_4 */
 };
 
 /* instance of mdt_reint_rec */
 struct mdt_rec_rename {
-	__u32	   rn_opcode;
-	__u32	   rn_cap;
-	__u32	   rn_fsuid;
-	__u32	   rn_fsuid_h;
-	__u32	   rn_fsgid;
-	__u32	   rn_fsgid_h;
-	__u32	   rn_suppgid1;
-	__u32	   rn_suppgid1_h;
-	__u32	   rn_suppgid2;
-	__u32	   rn_suppgid2_h;
+	__u32		rn_opcode;
+	__u32		rn_cap;
+	__u32		rn_fsuid;
+	__u32		rn_fsuid_h;
+	__u32		rn_fsgid;
+	__u32		rn_fsgid_h;
+	__u32		rn_suppgid1;
+	__u32		rn_suppgid1_h;
+	__u32		rn_suppgid2;
+	__u32		rn_suppgid2_h;
 	struct lu_fid   rn_fid1;
 	struct lu_fid   rn_fid2;
-	__s64	   rn_time;
-	__u64	   rn_padding_1;   /* rr_atime */
-	__u64	   rn_padding_2;   /* rr_ctime */
-	__u64	   rn_padding_3;   /* rr_size */
-	__u64	   rn_padding_4;   /* rr_blocks */
-	__u32	   rn_bias;	/* some operation flags */
-	__u32	   rn_mode;	/* cross-ref rename has mode */
-	__u32	   rn_padding_5;   /* rr_flags */
-	__u32	   rn_padding_6;   /* rr_padding_2 */
-	__u32	   rn_padding_7;   /* rr_padding_3 */
-	__u32	   rn_padding_8;   /* rr_padding_4 */
+	__s64		rn_time;
+	__u64		rn_padding_1;   /* rr_atime */
+	__u64		rn_padding_2;   /* rr_ctime */
+	__u64		rn_padding_3;   /* rr_size */
+	__u64		rn_padding_4;   /* rr_blocks */
+	__u32		rn_bias;	/* some operation flags */
+	__u32		rn_mode;	/* cross-ref rename has mode */
+	__u32		rn_padding_5;   /* rr_flags */
+	__u32		rn_padding_6;   /* rr_padding_2 */
+	__u32		rn_padding_7;   /* rr_padding_3 */
+	__u32		rn_padding_8;   /* rr_padding_4 */
 };
 
 /* instance of mdt_reint_rec */
 struct mdt_rec_setxattr {
-	__u32	   sx_opcode;
-	__u32	   sx_cap;
-	__u32	   sx_fsuid;
-	__u32	   sx_fsuid_h;
-	__u32	   sx_fsgid;
-	__u32	   sx_fsgid_h;
-	__u32	   sx_suppgid1;
-	__u32	   sx_suppgid1_h;
-	__u32	   sx_suppgid2;
-	__u32	   sx_suppgid2_h;
+	__u32		sx_opcode;
+	__u32		sx_cap;
+	__u32		sx_fsuid;
+	__u32		sx_fsuid_h;
+	__u32		sx_fsgid;
+	__u32		sx_fsgid_h;
+	__u32		sx_suppgid1;
+	__u32		sx_suppgid1_h;
+	__u32		sx_suppgid2;
+	__u32		sx_suppgid2_h;
 	struct lu_fid   sx_fid;
-	__u64	   sx_padding_1;   /* These three are rr_fid2 */
-	__u32	   sx_padding_2;
-	__u32	   sx_padding_3;
-	__u64	   sx_valid;
-	__s64	   sx_time;
-	__u64	   sx_padding_5;   /* rr_ctime */
-	__u64	   sx_padding_6;   /* rr_size */
-	__u64	   sx_padding_7;   /* rr_blocks */
-	__u32	   sx_size;
-	__u32	   sx_flags;
-	__u32	   sx_padding_8;   /* rr_flags */
-	__u32	   sx_padding_9;   /* rr_padding_2 */
-	__u32	   sx_padding_10;  /* rr_padding_3 */
-	__u32	   sx_padding_11;  /* rr_padding_4 */
+	__u64		sx_padding_1;   /* These three are rr_fid2 */
+	__u32		sx_padding_2;
+	__u32		sx_padding_3;
+	__u64		sx_valid;
+	__s64		sx_time;
+	__u64		sx_padding_5;   /* rr_ctime */
+	__u64		sx_padding_6;   /* rr_size */
+	__u64		sx_padding_7;   /* rr_blocks */
+	__u32		sx_size;
+	__u32		sx_flags;
+	__u32		sx_padding_8;   /* rr_flags */
+	__u32		sx_padding_9;   /* rr_padding_2 */
+	__u32		sx_padding_10;  /* rr_padding_3 */
+	__u32		sx_padding_11;  /* rr_padding_4 */
 };
 
 /*
@@ -1715,29 +1716,29 @@ struct mdt_rec_setxattr {
  * rr_padding_x fields, then update lustre_swab_mdt_rec_reint() also.
  */
 struct mdt_rec_reint {
-	__u32	   rr_opcode;
-	__u32	   rr_cap;
-	__u32	   rr_fsuid;
-	__u32	   rr_fsuid_h;
-	__u32	   rr_fsgid;
-	__u32	   rr_fsgid_h;
-	__u32	   rr_suppgid1;
-	__u32	   rr_suppgid1_h;
-	__u32	   rr_suppgid2;
-	__u32	   rr_suppgid2_h;
+	__u32		rr_opcode;
+	__u32		rr_cap;
+	__u32		rr_fsuid;
+	__u32		rr_fsuid_h;
+	__u32		rr_fsgid;
+	__u32		rr_fsgid_h;
+	__u32		rr_suppgid1;
+	__u32		rr_suppgid1_h;
+	__u32		rr_suppgid2;
+	__u32		rr_suppgid2_h;
 	struct lu_fid   rr_fid1;
 	struct lu_fid   rr_fid2;
-	__s64	   rr_mtime;
-	__s64	   rr_atime;
-	__s64	   rr_ctime;
-	__u64	   rr_size;
-	__u64	   rr_blocks;
-	__u32	   rr_bias;
-	__u32	   rr_mode;
-	__u32	   rr_flags;
-	__u32	   rr_flags_h;
-	__u32	   rr_umask;
-	__u32	   rr_padding_4; /* also fix lustre_swab_mdt_rec_reint */
+	__s64		rr_mtime;
+	__s64		rr_atime;
+	__s64		rr_ctime;
+	__u64		rr_size;
+	__u64		rr_blocks;
+	__u32		rr_bias;
+	__u32		rr_mode;
+	__u32		rr_flags;
+	__u32		rr_flags_h;
+	__u32		rr_umask;
+	__u32		rr_padding_4; /* also fix lustre_swab_mdt_rec_reint */
 };
 
 /* lmv structures */
@@ -1749,7 +1750,7 @@ struct lmv_desc {
 	__u64 ld_default_hash_size;
 	__u64 ld_padding_1;		/* also fix lustre_swab_lmv_desc */
 	__u32 ld_padding_2;		/* also fix lustre_swab_lmv_desc */
-	__u32 ld_qos_maxage;	       /* in second */
+	__u32 ld_qos_maxage;		    /* in second */
 	__u32 ld_padding_3;		/* also fix lustre_swab_lmv_desc */
 	__u32 ld_padding_4;		/* also fix lustre_swab_lmv_desc */
 	struct obd_uuid ld_uuid;
@@ -1866,9 +1867,9 @@ enum fld_rpc_opc {
 };
 
 enum seq_rpc_opc {
-	SEQ_QUERY		       = 700,
+	SEQ_QUERY			    = 700,
 	SEQ_LAST_OPC,
-	SEQ_FIRST_OPC		   = SEQ_QUERY
+	SEQ_FIRST_OPC			= SEQ_QUERY
 };
 
 enum seq_op {
@@ -2075,7 +2076,7 @@ enum mgs_cmd {
 #define KEY_SET_INFO "set_info"
 
 struct mgs_send_param {
-	char	     mgs_param[MGS_PARAM_MAXLEN];
+	char		  mgs_param[MGS_PARAM_MAXLEN];
 };
 
 /* We pass this info to the MGS so it can write config logs */
@@ -2083,64 +2084,64 @@ struct mgs_send_param {
 #define MTI_PARAM_MAXLEN 4096
 #define MTI_NIDS_MAX     32
 struct mgs_target_info {
-	__u32	    mti_lustre_ver;
-	__u32	    mti_stripe_index;
-	__u32	    mti_config_ver;
-	__u32	    mti_flags;
-	__u32	    mti_nid_count;
-	__u32	    mti_instance; /* Running instance of target */
-	char	     mti_fsname[MTI_NAME_MAXLEN];
-	char	     mti_svname[MTI_NAME_MAXLEN];
-	char	     mti_uuid[sizeof(struct obd_uuid)];
-	__u64	    mti_nids[MTI_NIDS_MAX];     /* host nids (lnet_nid_t)*/
-	char	     mti_params[MTI_PARAM_MAXLEN];
+	__u32		mti_lustre_ver;
+	__u32		mti_stripe_index;
+	__u32		mti_config_ver;
+	__u32		mti_flags;
+	__u32		mti_nid_count;
+	__u32		mti_instance; /* Running instance of target */
+	char		mti_fsname[MTI_NAME_MAXLEN];
+	char		mti_svname[MTI_NAME_MAXLEN];
+	char		mti_uuid[sizeof(struct obd_uuid)];
+	__u64		mti_nids[MTI_NIDS_MAX];     /* host nids (lnet_nid_t)*/
+	char		mti_params[MTI_PARAM_MAXLEN];
 };
 
 struct mgs_nidtbl_entry {
-	__u64	   mne_version;    /* table version of this entry */
-	__u32	   mne_instance;   /* target instance # */
-	__u32	   mne_index;      /* target index */
-	__u32	   mne_length;     /* length of this entry - by bytes */
-	__u8	    mne_type;       /* target type LDD_F_SV_TYPE_OST/MDT */
-	__u8	    mne_nid_type;   /* type of nid(mbz). for ipv6. */
-	__u8	    mne_nid_size;   /* size of each NID, by bytes */
-	__u8	    mne_nid_count;  /* # of NIDs in buffer */
+	__u64		mne_version;    /* table version of this entry */
+	__u32		mne_instance;   /* target instance # */
+	__u32		mne_index;      /* target index */
+	__u32		mne_length;     /* length of this entry - by bytes */
+	__u8		mne_type;       /* target type LDD_F_SV_TYPE_OST/MDT */
+	__u8		mne_nid_type;   /* type of nid(mbz). for ipv6. */
+	__u8		mne_nid_size;   /* size of each NID, by bytes */
+	__u8		mne_nid_count;  /* # of NIDs in buffer */
 	union {
 		lnet_nid_t nids[0];     /* variable size buffer for NIDs. */
 	} u;
 };
 
 struct mgs_config_body {
-	char     mcb_name[MTI_NAME_MAXLEN]; /* logname */
-	__u64    mcb_offset;    /* next index of config log to request */
-	__u16    mcb_type;      /* type of log: CONFIG_T_[CONFIG|RECOVER] */
-	__u8     mcb_reserved;
-	__u8     mcb_bits;      /* bits unit size of config log */
-	__u32    mcb_units;     /* # of units for bulk transfer */
+	char		mcb_name[MTI_NAME_MAXLEN]; /* logname */
+	__u64		mcb_offset;    /* next index of config log to request */
+	__u16		mcb_type;      /* type of log: CONFIG_T_[CONFIG|RECOVER] */
+	__u8		mcb_reserved;
+	__u8		mcb_bits;      /* bits unit size of config log */
+	__u32		mcb_units;     /* # of units for bulk transfer */
 };
 
 struct mgs_config_res {
-	__u64    mcr_offset;    /* index of last config log */
-	__u64    mcr_size;      /* size of the log */
+	__u64		mcr_offset;    /* index of last config log */
+	__u64		mcr_size;      /* size of the log */
 };
 
 /* Config marker flags (in config log) */
-#define CM_START       0x01
-#define CM_END	 0x02
-#define CM_SKIP	0x04
-#define CM_UPGRADE146  0x08
-#define CM_EXCLUDE     0x10
+#define CM_START	0x01
+#define CM_END		0x02
+#define CM_SKIP		0x04
+#define CM_UPGRADE146	0x08
+#define CM_EXCLUDE	0x10
 #define CM_START_SKIP (CM_START | CM_SKIP)
 
 struct cfg_marker {
-	__u32	     cm_step;       /* aka config version */
-	__u32	     cm_flags;
-	__u32	     cm_vers;       /* lustre release version number */
-	__u32	     cm_padding;    /* 64 bit align */
-	__s64	     cm_createtime; /*when this record was first created */
-	__s64	     cm_canceltime; /*when this record is no longer valid*/
-	char	      cm_tgtname[MTI_NAME_MAXLEN];
-	char	      cm_comment[MTI_NAME_MAXLEN];
+	__u32		cm_step;       /* aka config version */
+	__u32		cm_flags;
+	__u32		cm_vers;       /* lustre release version number */
+	__u32		cm_padding;    /* 64 bit align */
+	__s64		cm_createtime; /*when this record was first created */
+	__s64		cm_canceltime; /*when this record is no longer valid*/
+	char		cm_tgtname[MTI_NAME_MAXLEN];
+	char		cm_comment[MTI_NAME_MAXLEN];
 };
 
 /*
@@ -2183,16 +2184,16 @@ enum llog_ctxt_id {
 /** Identifier for a single log object */
 struct llog_logid {
 	struct ost_id		lgl_oi;
-	__u32		   lgl_ogen;
+	__u32			lgl_ogen;
 } __packed;
 
 /** Records written to the CATALOGS list */
 #define CATLIST "CATALOGS"
 struct llog_catid {
-	struct llog_logid       lci_logid;
-	__u32		   lci_padding1;
-	__u32		   lci_padding2;
-	__u32		   lci_padding3;
+	struct llog_logid	lci_logid;
+	__u32			lci_padding1;
+	__u32			lci_padding2;
+	__u32			lci_padding3;
 } __packed;
 
 /* Log data record types - there is no specific reason that these need to
@@ -2274,7 +2275,7 @@ struct llog_unlink64_rec {
 	__u32			lur_padding1;
 	__u64			lur_padding2;
 	__u64			lur_padding3;
-	struct llog_rec_tail    lur_tail;
+	struct llog_rec_tail	lur_tail;
 } __packed;
 
 struct llog_setattr64_rec {
@@ -2285,7 +2286,7 @@ struct llog_setattr64_rec {
 	__u32			lsr_gid;
 	__u32			lsr_gid_h;
 	__u64			lsr_valid;
-	struct llog_rec_tail    lsr_tail;
+	struct llog_rec_tail	lsr_tail;
 } __packed;
 
 struct llog_size_change_rec {
@@ -2314,11 +2315,11 @@ struct llog_changelog_rec {
 } __packed;
 
 struct llog_changelog_user_rec {
-	struct llog_rec_hdr   cur_hdr;
-	__u32		 cur_id;
-	__u32		 cur_padding;
-	__u64		 cur_endrec;
-	struct llog_rec_tail  cur_tail;
+	struct llog_rec_hdr	cur_hdr;
+	__u32			cur_id;
+	__u32			cur_padding;
+	__u64			cur_endrec;
+	struct llog_rec_tail	cur_tail;
 } __packed;
 
 enum agent_req_status {
@@ -2382,7 +2383,7 @@ enum llog_flag {
 	LLOG_F_ZAP_WHEN_EMPTY	= 0x1,
 	LLOG_F_IS_CAT		= 0x2,
 	LLOG_F_IS_PLAIN		= 0x4,
-	LLOG_F_EXT_JOBID        = 0x8,
+	LLOG_F_EXT_JOBID	= 0x8,
 	LLOG_F_IS_FIXSIZE	= 0x10,
 
 	/*
@@ -2404,16 +2405,16 @@ enum llog_flag {
 
 /* flags for the logs */
 struct llog_log_hdr {
-	struct llog_rec_hdr     llh_hdr;
-	__s64		   llh_timestamp;
-	__u32		   llh_count;
-	__u32		   llh_bitmap_offset;
-	__u32		   llh_size;
-	__u32		   llh_flags;
-	__u32		   llh_cat_idx;
+	struct llog_rec_hdr	llh_hdr;
+	__s64			llh_timestamp;
+	__u32			llh_count;
+	__u32			llh_bitmap_offset;
+	__u32			llh_size;
+	__u32			llh_flags;
+	__u32			llh_cat_idx;
 	/* for a catalog the first plain slot is next to it */
-	struct obd_uuid	 llh_tgtuuid;
-	__u32		   llh_reserved[LLOG_HEADER_SIZE / sizeof(__u32) - 23];
+	struct obd_uuid		llh_tgtuuid;
+	__u32			llh_reserved[LLOG_HEADER_SIZE / sizeof(__u32) - 23];
 	/* These fields must always be at the end of the llog_log_hdr.
 	 * Note: llh_bitmap size is variable because llog chunk size could be
 	 * bigger than LLOG_MIN_CHUNK_SIZE, i.e. sizeof(llog_log_hdr) > 8192
@@ -2423,8 +2424,8 @@ struct llog_log_hdr {
 	 * (see llog_client.c), it will be kept in its original way to avoid
 	 * compatibility issue.
 	 */
-	__u32		   llh_bitmap[LLOG_BITMAP_BYTES / sizeof(__u32)];
-	struct llog_rec_tail    llh_tail;
+	__u32			llh_bitmap[LLOG_BITMAP_BYTES / sizeof(__u32)];
+	struct llog_rec_tail	llh_tail;
 } __packed;
 
 #undef LLOG_HEADER_SIZE
@@ -2443,25 +2444,25 @@ struct llog_log_hdr {
  * therein
  */
 struct llog_cookie {
-	struct llog_logid       lgc_lgl;
-	__u32		   lgc_subsys;
-	__u32		   lgc_index;
-	__u32		   lgc_padding;
+	struct llog_logid	lgc_lgl;
+	__u32			lgc_subsys;
+	__u32			lgc_index;
+	__u32			lgc_padding;
 } __packed;
 
 /** llog protocol */
 enum llogd_rpc_ops {
-	LLOG_ORIGIN_HANDLE_CREATE       = 501,
-	LLOG_ORIGIN_HANDLE_NEXT_BLOCK   = 502,
-	LLOG_ORIGIN_HANDLE_READ_HEADER  = 503,
-	LLOG_ORIGIN_HANDLE_WRITE_REC    = 504,
+	LLOG_ORIGIN_HANDLE_CREATE	= 501,
+	LLOG_ORIGIN_HANDLE_NEXT_BLOCK	= 502,
+	LLOG_ORIGIN_HANDLE_READ_HEADER	= 503,
+	LLOG_ORIGIN_HANDLE_WRITE_REC	= 504,
 	LLOG_ORIGIN_HANDLE_CLOSE	= 505,
 	LLOG_ORIGIN_CONNECT		= 506,
 	LLOG_CATINFO			= 507,  /* deprecated */
-	LLOG_ORIGIN_HANDLE_PREV_BLOCK   = 508,
-	LLOG_ORIGIN_HANDLE_DESTROY      = 509,  /* for destroy llog object*/
+	LLOG_ORIGIN_HANDLE_PREV_BLOCK	= 508,
+	LLOG_ORIGIN_HANDLE_DESTROY	= 509,  /* for destroy llog object*/
 	LLOG_LAST_OPC,
-	LLOG_FIRST_OPC		  = LLOG_ORIGIN_HANDLE_CREATE
+	LLOG_FIRST_OPC			= LLOG_ORIGIN_HANDLE_CREATE
 };
 
 struct llogd_body {
@@ -2475,9 +2476,9 @@ struct llogd_body {
 } __packed;
 
 struct llogd_conn_body {
-	struct llog_gen	 lgdc_gen;
-	struct llog_logid       lgdc_logid;
-	__u32		   lgdc_ctxt_idx;
+	struct llog_gen		lgdc_gen;
+	struct llog_logid	lgdc_logid;
+	__u32			lgdc_ctxt_idx;
 } __packed;
 
 /* Note: 64-bit types are 64-bit aligned in structure */
@@ -2485,16 +2486,16 @@ struct obdo {
 	__u64		o_valid;	/* hot fields in this obdo */
 	struct ost_id	o_oi;
 	__u64		o_parent_seq;
-	__u64		o_size;	 /* o_size-o_blocks == ost_lvb */
+	__u64		o_size;		/* o_size-o_blocks == ost_lvb */
 	__s64		o_mtime;
 	__s64		o_atime;
 	__s64		o_ctime;
-	__u64		o_blocks;       /* brw: cli sent cached bytes */
+	__u64		o_blocks;	/* brw: cli sent cached bytes */
 	__u64		o_grant;
 
 	/* 32-bit fields start here: keep an even number of them via padding */
-	__u32		o_blksize;      /* optimal IO blocksize */
-	__u32		o_mode;	 /* brw: cli sent cache remain */
+	__u32		o_blksize;	/* optimal IO blocksize */
+	__u32		o_mode;		/* brw: cli sent cache remain */
 	__u32		o_uid;
 	__u32		o_gid;
 	__u32		o_flags;
@@ -2502,25 +2503,25 @@ struct obdo {
 	__u32		o_parent_oid;
 	__u32		o_misc;		/* brw: o_dropped */
 
-	__u64		   o_ioepoch;      /* epoch in ost writes */
-	__u32		   o_stripe_idx;   /* holds stripe idx */
-	__u32		   o_parent_ver;
+	__u64		o_ioepoch;      /* epoch in ost writes */
+	__u32		o_stripe_idx;   /* holds stripe idx */
+	__u32		o_parent_ver;
 	struct lustre_handle    o_handle;  /* brw: lock handle to prolong locks
 					    */
 	struct llog_cookie      o_lcookie; /* destroy: unlink cookie from MDS,
 					    * obsolete in 2.8, reused in OSP
 					    */
-	__u32			o_uid_h;
-	__u32			o_gid_h;
+	__u32		o_uid_h;
+	__u32		o_gid_h;
 
-	__u64			o_data_version; /* getattr: sum of iversion for
-						 * each stripe.
-						 * brw: grant space consumed on
-						 * the client for the write
-						 */
-	__u64			o_padding_4;
-	__u64			o_padding_5;
-	__u64			o_padding_6;
+	__u64		o_data_version; /* getattr: sum of iversion for
+					 * each stripe.
+					 * brw: grant space consumed on
+					 * the client for the write
+					 */
+	__u64		o_padding_4;
+	__u64		o_padding_5;
+	__u64		o_padding_6;
 };
 
 #define o_dirty   o_blocks
@@ -2543,11 +2544,11 @@ struct ll_fiemap_info_key {
 
 /* security opcodes */
 enum sec_cmd {
-	SEC_CTX_INIT	    = 801,
-	SEC_CTX_INIT_CONT       = 802,
-	SEC_CTX_FINI	    = 803,
+	SEC_CTX_INIT		= 801,
+	SEC_CTX_INIT_CONT	= 802,
+	SEC_CTX_FINI		= 803,
 	SEC_LAST_OPC,
-	SEC_FIRST_OPC	   = SEC_CTX_INIT
+	SEC_FIRST_OPC		= SEC_CTX_INIT
 };
 
 /*
@@ -2560,16 +2561,16 @@ enum sec_cmd {
  * because the offset info is used in find_capa()
  */
 struct lustre_capa {
-	struct lu_fid   lc_fid;	 /** fid */
-	__u64	   lc_opc;	 /** operations allowed */
-	__u64	   lc_uid;	 /** file owner */
-	__u64	   lc_gid;	 /** file group */
-	__u32	   lc_flags;       /** HMAC algorithm & flags */
-	__u32	   lc_keyid;       /** key# used for the capability */
-	__u32	   lc_timeout;     /** capa timeout value (sec) */
+	struct lu_fid	lc_fid;		/** fid */
+	__u64		lc_opc;		/** operations allowed */
+	__u64		lc_uid;		/** file owner */
+	__u64		lc_gid;		/** file group */
+	__u32		lc_flags;	/** HMAC algorithm & flags */
+	__u32		lc_keyid;	/** key# used for the capability */
+	__u32		lc_timeout;	/** capa timeout value (sec) */
 /* FIXME: y2038 time_t overflow: */
-	__u32	   lc_expiry;      /** expiry time (sec) */
-	__u8	    lc_hmac[CAPA_HMAC_MAX_LEN];   /** HMAC */
+	__u32		lc_expiry;	/** expiry time (sec) */
+	__u8		lc_hmac[CAPA_HMAC_MAX_LEN];   /** HMAC */
 } __packed;
 
 /** lustre_capa::lc_opc */
@@ -2619,17 +2620,17 @@ struct link_ea_header {
  */
 struct link_ea_entry {
 	/** __u16 stored big-endian, unaligned */
-	unsigned char      lee_reclen[2];
-	unsigned char      lee_parent_fid[sizeof(struct lu_fid)];
-	char	       lee_name[0];
+	unsigned char	lee_reclen[2];
+	unsigned char	lee_parent_fid[sizeof(struct lu_fid)];
+	char		lee_name[0];
 } __packed;
 
 /** fid2path request/reply structure */
 struct getinfo_fid2path {
-	struct lu_fid   gf_fid;
-	__u64	   gf_recno;
-	__u32	   gf_linkno;
-	__u32	   gf_pathlen;
+	struct lu_fid	gf_fid;
+	__u64		gf_recno;
+	__u32		gf_linkno;
+	__u32		gf_pathlen;
 	union {
 		char		gf_path[0];
 		struct lu_fid	gf_root_fid[0];
@@ -2684,7 +2685,7 @@ struct hsm_progress_kernel {
  * fid1 and fid2 are in mdt_body
  */
 struct mdc_swap_layouts {
-	__u64	   msl_flags;
+	__u64			msl_flags;
 } __packed;
 
 struct close_data {
