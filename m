From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:39 -0500
Subject: [lustre-devel] [PATCH 591/622] lustre: uapi: properly pack data
 structures
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-592-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Linux UAPI headers use the gcc attributre __packed__ to ensure
that the data structures are the exact same size on all platforms.
This comes at the cost of potential misaligned accesses to these
data structures which at best cost performance and at worst cause
a bus error on some platforms. To detect potential misaligned
access starting with gcc version 9 a new compile flags was
introduced which is now impacting builds with Lustre.

Examining the build failures shows most of the problems are due to
packed data structures in the Lustre UAPI header containing
unpacked data structure fields. Packing those missed structures
resolved many of the build issues. The second problem is that the
lustre utilities tend to cast some of its UAPI data structure.
A good example is struct lov_user_md being cast to
struct lov_user_md_v3. To ensure this is properly handled with
packed data structures we need to use the __may_alias__ compiler
attribute. The one exception is struct statx which is defined out
side of Lustre and its unpacked. This requires extra special
handling in user land code due to the described issues in this
comment.

The Lustre UAPI headers currently used __packed to avoid
checkpatch errors due to Lustre being in the staging tree.
Now that the Lustre UAPI headers are in the proper place
update the UAPI headers to use __attribute__((packed)) over
__packed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12822
Lustre-commit: 4751e4a95197 ("LU-12822 uapi: properly pack data structures")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/36798
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 include/uapi/linux/lustre/lustre_idl.h  | 54 ++++++++++++++++-----------------
 include/uapi/linux/lustre/lustre_user.h | 42 ++++++++++++-------------
 2 files changed, 48 insertions(+), 48 deletions(-)

diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index a69d49a..19ac0cb 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2426,7 +2426,7 @@ enum llog_ctxt_id {
 struct llog_logid {
 	struct ost_id		lgl_oi;
 	__u32			lgl_ogen;
-} __packed;
+} __attribute__((packed));
 
 /** Records written to the CATALOGS list */
 #define CATLIST "CATALOGS"
@@ -2435,7 +2435,7 @@ struct llog_catid {
 	__u32			lci_padding1;
 	__u32			lci_padding2;
 	__u32			lci_padding3;
-} __packed;
+} __attribute__((packed));
 
 /* Log data record types - there is no specific reason that these need to
  * be related to the RPC opcodes, but no reason not to (may be handy later?)
@@ -2477,12 +2477,12 @@ struct llog_rec_hdr {
 	__u32	lrh_index;
 	__u32	lrh_type;
 	__u32	lrh_id;
-};
+} __attribute__((packed));
 
 struct llog_rec_tail {
 	__u32	lrt_len;
 	__u32	lrt_index;
-};
+} __attribute__((packed));
 
 /* Where data follow just after header */
 #define REC_DATA(ptr)						\
@@ -2499,7 +2499,7 @@ struct llog_logid_rec {
 	__u64			lid_padding2;
 	__u64			lid_padding3;
 	struct llog_rec_tail	lid_tail;
-} __packed;
+} __attribute__((packed));
 
 struct llog_unlink_rec {
 	struct llog_rec_hdr	lur_hdr;
@@ -2507,7 +2507,7 @@ struct llog_unlink_rec {
 	__u32			lur_oseq;
 	__u32			lur_count;
 	struct llog_rec_tail	lur_tail;
-} __packed;
+} __attribute__((packed));
 
 struct llog_unlink64_rec {
 	struct llog_rec_hdr	lur_hdr;
@@ -2517,7 +2517,7 @@ struct llog_unlink64_rec {
 	__u64			lur_padding2;
 	__u64			lur_padding3;
 	struct llog_rec_tail	lur_tail;
-} __packed;
+} __attribute__((packed));
 
 struct llog_setattr64_rec {
 	struct llog_rec_hdr	lsr_hdr;
@@ -2528,7 +2528,7 @@ struct llog_setattr64_rec {
 	__u32			lsr_gid_h;
 	__u64			lsr_valid;
 	struct llog_rec_tail	lsr_tail;
-} __packed;
+} __attribute__((packed));
 
 struct llog_size_change_rec {
 	struct llog_rec_hdr	lsc_hdr;
@@ -2538,7 +2538,7 @@ struct llog_size_change_rec {
 	__u64			lsc_padding2;
 	__u64			lsc_padding3;
 	struct llog_rec_tail	lsc_tail;
-} __packed;
+} __attribute__((packed));
 
 /* changelog llog name, needed by client replicators */
 #define CHANGELOG_CATALOG "changelog_catalog"
@@ -2546,14 +2546,14 @@ struct llog_size_change_rec {
 struct changelog_setinfo {
 	__u64 cs_recno;
 	__u32 cs_id;
-} __packed;
+} __attribute__((packed));
 
 /** changelog record */
 struct llog_changelog_rec {
 	struct llog_rec_hdr	cr_hdr;
 	struct changelog_rec	cr;		/**< Variable length field */
 	struct llog_rec_tail	cr_do_not_use;	/**< for_sizezof_only */
-} __packed;
+} __attribute__((packed));
 
 struct llog_changelog_user_rec {
 	struct llog_rec_hdr	cur_hdr;
@@ -2561,7 +2561,7 @@ struct llog_changelog_user_rec {
 	__u32			cur_padding;
 	__u64			cur_endrec;
 	struct llog_rec_tail	cur_tail;
-} __packed;
+} __attribute__((packed));
 
 enum agent_req_status {
 	ARS_WAITING,
@@ -2602,13 +2602,13 @@ struct llog_agent_req_rec {
 	__u64			arr_req_change;	/**< req. status change time */
 	struct hsm_action_item	arr_hai;	/**< req. to the agent */
 	struct llog_rec_tail	arr_tail;   /**< record tail for_sizezof_only */
-} __packed;
+} __attribute__((packed));
 
 /* Old llog gen for compatibility */
 struct llog_gen {
 	__u64 mnt_cnt;
 	__u64 conn_cnt;
-} __packed;
+} __attribute__((packed));
 
 struct llog_gen_rec {
 	struct llog_rec_hdr	lgr_hdr;
@@ -2679,7 +2679,7 @@ struct llog_log_hdr {
 	 */
 	__u32			llh_bitmap[LLOG_BITMAP_BYTES / sizeof(__u32)];
 	struct llog_rec_tail	llh_tail;
-} __packed;
+} __attribute__((packed));
 
 #undef LLOG_HEADER_SIZE
 #undef LLOG_BITMAP_BYTES
@@ -2701,7 +2701,7 @@ struct llog_cookie {
 	__u32			lgc_subsys;
 	__u32			lgc_index;
 	__u32			lgc_padding;
-} __packed;
+} __attribute__((packed));
 
 /** llog protocol */
 enum llogd_rpc_ops {
@@ -2726,13 +2726,13 @@ struct llogd_body {
 	__u32 lgd_saved_index;
 	__u32 lgd_len;
 	__u64 lgd_cur_offset;
-} __packed;
+} __attribute__((packed));
 
 struct llogd_conn_body {
 	struct llog_gen		lgdc_gen;
 	struct llog_logid	lgdc_logid;
 	__u32			lgdc_ctxt_idx;
-} __packed;
+} __attribute__((packed));
 
 /* Note: 64-bit types are 64-bit aligned in structure */
 struct obdo {
@@ -2832,7 +2832,7 @@ struct lustre_capa {
 /* FIXME: y2038 time_t overflow: */
 	__u32		lc_expiry;	/** expiry time (sec) */
 	__u8		lc_hmac[CAPA_HMAC_MAX_LEN];   /** HMAC */
-} __packed;
+} __attribute__((packed));
 
 /** lustre_capa::lc_opc */
 enum {
@@ -2864,7 +2864,7 @@ struct lustre_capa_key {
 	__u32	lk_keyid;			/**< key# */
 	__u32	lk_padding;
 	__u8	lk_key[CAPA_HMAC_KEY_MAX_LEN];	/**< key */
-} __packed;
+} __attribute__((packed));
 
 /** The link ea holds 1 @link_ea_entry for each hardlink */
 #define LINK_EA_MAGIC 0x11EAF1DFUL
@@ -2884,7 +2884,7 @@ struct link_ea_entry {
 	unsigned char	lee_reclen[2];
 	unsigned char	lee_parent_fid[sizeof(struct lu_fid)];
 	char		lee_name[0];
-} __packed;
+} __attribute__((packed));
 
 /** fid2path request/reply structure */
 struct getinfo_fid2path {
@@ -2896,7 +2896,7 @@ struct getinfo_fid2path {
 		char		gf_path[0];
 		struct lu_fid	gf_root_fid[0];
 	};
-} __packed;
+} __attribute__((packed));
 
 /** path2parent request/reply structures */
 struct getparent {
@@ -2904,7 +2904,7 @@ struct getparent {
 	__u32		gp_linkno;	/**< hardlink number */
 	__u32		gp_name_size;	/**< size of the name field */
 	char		gp_name[0];	/**< zero-terminated link name */
-} __packed;
+} __attribute__((packed));
 
 enum layout_intent_opc {
 	LAYOUT_INTENT_ACCESS	= 0,	/** generic access */
@@ -2921,7 +2921,7 @@ struct layout_intent {
 	__u32 li_opc;	/* intent operation for enqueue, read, write etc */
 	__u32 li_flags;
 	struct lu_extent li_extent;
-} __packed;
+} __attribute__((packed));
 
 /**
  * On the wire version of hsm_progress structure.
@@ -2939,20 +2939,20 @@ struct hsm_progress_kernel {
 	/* Additional fields */
 	__u64			hpk_data_version;
 	__u64			hpk_padding2;
-} __packed;
+} __attribute__((packed));
 
 /** layout swap request structure
  * fid1 and fid2 are in mdt_body
  */
 struct mdc_swap_layouts {
 	__u64			msl_flags;
-} __packed;
+} __attribute__((packed));
 
 #define INLINE_RESYNC_ARRAY_SIZE	15
 struct close_data_resync_done {
 	__u32	resync_count;
 	__u32	resync_ids_inline[INLINE_RESYNC_ARRAY_SIZE];
-};
+} __attribute__((packed));
 
 struct close_data {
 	struct lustre_handle	cd_handle;
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 08589e6..5c21f34 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -157,7 +157,7 @@ struct lu_fid {
 	 * used.
 	 **/
 	__u32 f_ver;
-};
+} __attribute__((packed));
 
 static inline bool fid_is_zero(const struct lu_fid *fid)
 {
@@ -176,7 +176,7 @@ struct ost_layout {
 	__u64	ol_comp_start;
 	__u64	ol_comp_end;
 	__u32	ol_comp_id;
-} __packed;
+} __attribute__((packed));
 
 /* Userspace should treat lu_fid as opaque, and only use the following methods
  * to print or parse them.  Other functions (e.g. compare, swab) could be moved
@@ -245,7 +245,7 @@ struct ost_id {
 		} oi;
 		struct lu_fid oi_fid;
 	};
-};
+} __attribute__((packed));
 
 #define DOSTID "%#llx:%llu"
 #define POSTID(oi) ostid_seq(oi), ostid_id(oi)
@@ -462,7 +462,7 @@ struct lov_user_ost_data_v1 {	/* per-stripe data structure */
 	struct ost_id l_ost_oi;	/* OST object ID */
 	__u32 l_ost_gen;	/* generation of this OST index */
 	__u32 l_ost_idx;	/* OST index in LOV */
-} __packed;
+} __attribute__((packed));
 
 #define lov_user_md lov_user_md_v1
 struct lov_user_md_v1 {		/* LOV EA user data (host-endian) */
@@ -480,7 +480,7 @@ struct lov_user_md_v1 {		/* LOV EA user data (host-endian) */
 						 */
 	};
 	struct lov_user_ost_data_v1 lmm_objects[0]; /* per-stripe data */
-} __attribute__((packed,  __may_alias__));
+} __attribute__((packed, __may_alias__));
 
 struct lov_user_md_v3 {		/* LOV EA user data (host-endian) */
 	__u32 lmm_magic;	/* magic number = LOV_USER_MAGIC_V3 */
@@ -498,7 +498,7 @@ struct lov_user_md_v3 {		/* LOV EA user data (host-endian) */
 	};
 	char  lmm_pool_name[LOV_MAXPOOLNAME + 1];   /* pool name */
 	struct lov_user_ost_data_v1 lmm_objects[0]; /* per-stripe data */
-} __packed;
+} __attribute__((packed, __may_alias__));
 
 struct lov_foreign_md {
 	__u32 lfm_magic;	/* magic number = LOV_MAGIC_FOREIGN */
@@ -506,7 +506,7 @@ struct lov_foreign_md {
 	__u32 lfm_type;		/* type, see LU_FOREIGN_TYPE_ */
 	__u32 lfm_flags;	/* flags, type specific */
 	char lfm_value[];
-};
+} __attribute__((packed));
 
 #define foreign_size(lfm) (((struct lov_foreign_md *)lfm)->lfm_length + \
 			   offsetof(struct lov_foreign_md, lfm_value))
@@ -518,7 +518,7 @@ struct lov_foreign_md {
 struct lu_extent {
 	__u64	e_start;
 	__u64	e_end;
-};
+} __attribute__((packed));
 
 #define DEXT "[%#llx, %#llx)"
 #define PEXT(ext) (unsigned long long)(ext)->e_start, (unsigned long long)(ext)->e_end
@@ -583,7 +583,7 @@ struct lov_comp_md_entry_v1 {
 	__u32			lcme_layout_gen;
 	__u64			lcme_timestamp;	/* snapshot time if applicable*/
 	__u32			lcme_padding_1;
-} __packed;
+} __attribute__((packed));
 
 #define SEQ_ID_MAX		0x0000FFFF
 #define SEQ_ID_MASK		SEQ_ID_MAX
@@ -626,7 +626,7 @@ struct lov_comp_md_v1 {
 	__u16	lcm_padding1[3];
 	__u64	lcm_padding2;
 	struct lov_comp_md_entry_v1 lcm_entries[0];
-} __packed;
+} __attribute__((packed));
 
 static inline __u32 lov_user_md_size(__u16 stripes, __u32 lmm_magic)
 {
@@ -649,7 +649,7 @@ static inline __u32 lov_user_md_size(__u16 stripes, __u32 lmm_magic)
 struct lov_user_mds_data_v1 {
 	lstat_t lmd_st;			/* MDS stat struct */
 	struct lov_user_md_v1 lmd_lmm;	/* LOV EA V1 user data */
-} __packed;
+} __attribute__((packed));
 
 struct lov_user_mds_data_v2 {
 	struct lu_fid lmd_fid;		/* Lustre FID */
@@ -663,14 +663,14 @@ struct lov_user_mds_data_v2 {
 struct lov_user_mds_data_v3 {
 	lstat_t lmd_st;			/* MDS stat struct */
 	struct lov_user_md_v3 lmd_lmm;	/* LOV EA V3 user data */
-} __packed;
+} __attribute__((packed));
 #endif
 
 struct lmv_user_mds_data {
 	struct lu_fid	lum_fid;
 	__u32		lum_padding;
 	__u32		lum_mds;
-};
+} __attribute__((packed, __may_alias__));
 
 enum lmv_hash_type {
 	LMV_HASH_TYPE_UNKNOWN	= 0,	/* 0 is reserved for testing purpose */
@@ -743,7 +743,7 @@ struct lmv_user_md_v1 {
 	__u32	lum_padding3;
 	char	lum_pool_name[LOV_MAXPOOLNAME + 1];
 	struct lmv_user_mds_data  lum_objects[0];
-} __packed;
+} __attribute__((packed));
 
 static inline __u32 lmv_foreign_to_md_stripes(__u32 size)
 {
@@ -1315,8 +1315,8 @@ struct changelog_rec {
 		struct lu_fid    cr_tfid;	/**< target fid */
 		__u32	 cr_markerflags; /**< CL_MARK flags */
 	};
-	struct lu_fid	    cr_pfid;	/**< parent fid */
-} __packed;
+	struct lu_fid	 cr_pfid;		/**< parent fid */
+} __attribute__((packed));
 
 /* Changelog extension for RENAME. */
 struct changelog_ext_rename {
@@ -1758,7 +1758,7 @@ enum hsm_states {
 struct hsm_extent {
 	__u64 offset;
 	__u64 length;
-} __packed;
+} __attribute__((packed));
 
 /**
  * Current HSM states of a Lustre file.
@@ -1842,7 +1842,7 @@ struct hsm_request {
 struct hsm_user_item {
 	struct lu_fid	hui_fid;
 	struct hsm_extent hui_extent;
-} __packed;
+} __attribute__((packed));
 
 struct hsm_user_request {
 	struct hsm_request	hur_request;
@@ -1850,7 +1850,7 @@ struct hsm_user_request {
 	/* extra data blob@end of struct (after all
 	 * hur_user_items), only use helpers to access it
 	 */
-} __packed;
+} __attribute__((packed));
 
 /** Return pointer to data field in a hsm user request */
 static inline void *hur_data(struct hsm_user_request *hur)
@@ -1916,7 +1916,7 @@ struct hsm_action_item {
 	__u64		hai_cookie;  /* action cookie from coordinator */
 	__u64		hai_gid;     /* grouplock id */
 	char		hai_data[0]; /* variable length */
-} __packed;
+} __attribute__((packed));
 
 /*
  * helper function which print in hexa the first bytes of
@@ -1960,7 +1960,7 @@ struct hsm_action_list {
 	/* struct hsm_action_item[hal_count] follows, aligned on 8-byte
 	 * boundaries. See hai_first
 	 */
-} __packed;
+} __attribute__((packed));
 
 /* Return pointer to first hai in action list */
 static inline struct hsm_action_item *hai_first(struct hsm_action_list *hal)
-- 
1.8.3.1
