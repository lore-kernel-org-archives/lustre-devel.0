From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 14:40:45 -0500
Subject: [lustre-devel] [PATCH 1/6] staging: lustre: headers: move swab
	functions to new header files
In-Reply-To: <1480707650-24089-1-git-send-email-jsimmons@infradead.org>
References: <1480707650-24089-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480707650-24089-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Ben Evans <bevans@cray.com>, James Simmons <jsimmons@infradead.org>

From: Ben Evans <bevans@cray.com>

Create headers for pack_generic.c and llog_swab.c
Reference only where needed. This separates out
the kernel only code from lustre_idl.h that is
an UAPI header.

Signed-off-by: Ben Evans <bevans@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: http://review.whamcloud.com/16339
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/llog_swab.h  |   65 +++++++++++
 .../staging/lustre/lustre/include/lprocfs_status.h |    2 +
 .../lustre/lustre/include/lustre/lustre_idl.h      |  115 +-------------------
 .../lustre/lustre/include/lustre/lustre_user.h     |    2 -
 drivers/staging/lustre/lustre/include/lustre_sec.h |    1 +
 .../staging/lustre/lustre/include/lustre_swab.h    |  102 +++++++++++++++++
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    1 +
 drivers/staging/lustre/lustre/llite/dir.c          |    2 +
 drivers/staging/lustre/lustre/llite/file.c         |    1 +
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    1 +
 drivers/staging/lustre/lustre/lov/lov_pack.c       |    1 +
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |    4 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    2 +
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    1 +
 drivers/staging/lustre/lustre/obdclass/llog.c      |    1 +
 drivers/staging/lustre/lustre/obdclass/llog_swab.c |    1 +
 .../staging/lustre/lustre/obdclass/obd_config.c    |    1 +
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |    2 +
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    2 +
 19 files changed, 190 insertions(+), 117 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/include/llog_swab.h
 create mode 100644 drivers/staging/lustre/lustre/include/lustre_swab.h

diff --git a/drivers/staging/lustre/lustre/include/llog_swab.h b/drivers/staging/lustre/lustre/include/llog_swab.h
new file mode 100644
index 0000000..fd7ffb1
--- /dev/null
+++ b/drivers/staging/lustre/lustre/include/llog_swab.h
@@ -0,0 +1,65 @@
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2011, 2014, Intel Corporation.
+ *
+ * Copyright 2015 Cray Inc, all rights reserved.
+ * Author: Ben Evans.
+ *
+ * We assume all nodes are either little-endian or big-endian, and we
+ * always send messages in the sender's native format.  The receiver
+ * detects the message format by checking the 'magic' field of the message
+ * (see lustre_msg_swabbed() below).
+ *
+ * Each type has corresponding 'lustre_swab_xxxtypexxx()' routines
+ * are implemented in ptlrpc/pack_generic.c.  These 'swabbers' convert the
+ * type from "other" endian, in-place in the message buffer.
+ *
+ * A swabber takes a single pointer argument.  The caller must already have
+ * verified that the length of the message buffer >= sizeof (type).
+ *
+ * For variable length types, a second 'lustre_swab_v_xxxtypexxx()' routine
+ * may be defined that swabs just the variable part, after the caller has
+ * verified that the message buffer is large enough.
+ */
+
+#ifndef _LLOG_SWAB_H_
+#define _LLOG_SWAB_H_
+
+#include "lustre/lustre_idl.h"
+struct lustre_cfg;
+
+void lustre_swab_lu_fid(struct lu_fid *fid);
+void lustre_swab_ost_id(struct ost_id *oid);
+void lustre_swab_llogd_body(struct llogd_body *d);
+void lustre_swab_llog_hdr(struct llog_log_hdr *h);
+void lustre_swab_llogd_conn_body(struct llogd_conn_body *d);
+void lustre_swab_llog_rec(struct llog_rec_hdr *rec);
+void lustre_swab_lu_seq_range(struct lu_seq_range *range);
+void lustre_swab_lustre_cfg(struct lustre_cfg *lcfg);
+void lustre_swab_cfg_marker(struct cfg_marker *marker,
+			    int swab, int size);
+
+#endif
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index cc0713e..d0a32d2 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -43,6 +43,8 @@
 #include <linux/spinlock.h>
 #include <linux/types.h>
 
+#include "../../include/linux/libcfs/libcfs.h"
+#include "lustre_cfg.h"
 #include "lustre/lustre_idl.h"
 
 struct lprocfs_vars {
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index b9f333b..6831e4d 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -48,8 +48,7 @@
  * that the Lustre wire protocol is not influenced by external dependencies.
  *
  * The only other acceptable items in this file are VERY SIMPLE accessor
- * functions to avoid callers grubbing inside the structures, and the
- * prototypes of the swabber functions for each struct.  Nothing that
+ * functions to avoid callers grubbing inside the structures. Nothing that
  * depends on external functions or definitions should be in here.
  *
  * Structs must be properly aligned to put 64-bit values on an 8-byte
@@ -64,23 +63,6 @@
  * in the code to ensure that new/old clients that see this larger struct
  * do not fail, otherwise you need to implement protocol compatibility).
  *
- * We assume all nodes are either little-endian or big-endian, and we
- * always send messages in the sender's native format.  The receiver
- * detects the message format by checking the 'magic' field of the message
- * (see lustre_msg_swabbed() below).
- *
- * Each wire type has corresponding 'lustre_swab_xxxtypexxx()' routines,
- * implemented either here, inline (trivial implementations) or in
- * ptlrpc/pack_generic.c.  These 'swabbers' convert the type from "other"
- * endian, in-place in the message buffer.
- *
- * A swabber takes a single pointer argument.  The caller must already have
- * verified that the length of the message buffer >= sizeof (type).
- *
- * For variable length types, a second 'lustre_swab_v_xxxtypexxx()' routine
- * may be defined that swabs just the variable part, after the caller has
- * verified that the message buffer is large enough.
- *
  * @{
  */
 
@@ -679,8 +661,6 @@ static inline ino_t lu_igif_ino(const struct lu_fid *fid)
 	return fid_seq(fid);
 }
 
-void lustre_swab_ost_id(struct ost_id *oid);
-
 /**
  * Get inode generation from a igif.
  * \param fid a igif to get inode generation from.
@@ -741,8 +721,6 @@ static inline bool fid_is_sane(const struct lu_fid *fid)
 		fid_seq_is_rsvd(fid_seq(fid)));
 }
 
-void lustre_swab_lu_fid(struct lu_fid *fid);
-
 static inline bool lu_fid_eq(const struct lu_fid *f0, const struct lu_fid *f1)
 {
 	return memcmp(f0, f1, sizeof(*f0)) == 0;
@@ -1047,8 +1025,6 @@ struct ptlrpc_body_v2 {
 	__u64 pb_padding64_2;
 };
 
-void lustre_swab_ptlrpc_body(struct ptlrpc_body *pb);
-
 /* message body offset for lustre_msg_v2 */
 /* ptlrpc body offset in all request/reply messages */
 #define MSG_PTLRPC_BODY_OFF	     0
@@ -1275,8 +1251,6 @@ struct obd_connect_data {
  * reserve the flag for future use.
  */
 
-void lustre_swab_connect(struct obd_connect_data *ocd);
-
 /*
  * Supported checksum algorithms. Up to 32 checksum types are supported.
  * (32-bit mask stored in obd_connect_data::ocd_cksum_types)
@@ -1475,8 +1449,6 @@ static inline void lmm_oi_cpu_to_le(struct ost_id *dst_oi,
 	dst_oi->oi.oi_seq = cpu_to_le64(src_oi->oi.oi_seq);
 }
 
-/* extern void lustre_swab_lov_mds_md(struct lov_mds_md *llm); */
-
 #define MAX_MD_SIZE							\
 	(sizeof(struct lov_mds_md) + 4 * sizeof(struct lov_ost_data))
 #define MIN_MD_SIZE							\
@@ -1639,11 +1611,6 @@ struct hsm_state_set {
 	__u64	hss_clearmask;
 };
 
-void lustre_swab_hsm_user_state(struct hsm_user_state *hus);
-void lustre_swab_hsm_state_set(struct hsm_state_set *hss);
-
-void lustre_swab_obd_statfs(struct obd_statfs *os);
-
 /* ost_body.data values for OST_BRW */
 
 #define OBD_BRW_READ		0x01
@@ -1689,8 +1656,6 @@ struct obd_ioobj {
 #define ioobj_max_brw_set(ioo, num)					\
 do { (ioo)->ioo_max_brw = ((num) - 1) << IOOBJ_MAX_BRW_BITS; } while (0)
 
-void lustre_swab_obd_ioobj(struct obd_ioobj *ioo);
-
 /* multiple of 8 bytes => can array */
 struct niobuf_remote {
 	__u64	rnb_offset;
@@ -1698,8 +1663,6 @@ struct niobuf_remote {
 	__u32	rnb_flags;
 };
 
-void lustre_swab_niobuf_remote(struct niobuf_remote *nbr);
-
 /* lock value block communicated between the filter and llite */
 
 /* OST_LVB_ERR_INIT is needed because the return code in rc is
@@ -1721,8 +1684,6 @@ struct ost_lvb_v1 {
 	__u64		lvb_blocks;
 };
 
-void lustre_swab_ost_lvb_v1(struct ost_lvb_v1 *lvb);
-
 struct ost_lvb {
 	__u64		lvb_size;
 	__s64		lvb_mtime;
@@ -1735,8 +1696,6 @@ struct ost_lvb {
 	__u32		lvb_padding;
 };
 
-void lustre_swab_ost_lvb(struct ost_lvb *lvb);
-
 /*
  *   lquota data structures
  */
@@ -1763,8 +1722,6 @@ struct obd_quotactl {
 	struct obd_dqblk	qc_dqblk;
 };
 
-void lustre_swab_obd_quotactl(struct obd_quotactl *q);
-
 #define Q_COPY(out, in, member) (out)->member = (in)->member
 
 #define QCTL_COPY(out, in)		\
@@ -1802,8 +1759,6 @@ struct lquota_lvb {
 	__u64	lvb_pad1;
 };
 
-void lustre_swab_lquota_lvb(struct lquota_lvb *lvb);
-
 /* op codes */
 enum quota_cmd {
 	QUOTA_DQACQ	= 601,
@@ -1869,8 +1824,6 @@ enum mdt_reint_cmd {
 	REINT_MAX
 };
 
-void lustre_swab_generic_32s(__u32 *val);
-
 /* the disposition of the intent outlines what was executed */
 #define DISP_IT_EXECD	0x00000001
 #define DISP_LOOKUP_EXECD    0x00000002
@@ -2012,8 +1965,6 @@ struct mdt_body {
 	__u64	mbo_padding_10;
 }; /* 216 */
 
-void lustre_swab_mdt_body(struct mdt_body *b);
-
 struct mdt_ioepoch {
 	struct lustre_handle mio_handle;
 	__u64 mio_unused1; /* was ioepoch */
@@ -2021,8 +1972,6 @@ struct mdt_ioepoch {
 	__u32 mio_padding;
 };
 
-void lustre_swab_mdt_ioepoch(struct mdt_ioepoch *b);
-
 /* permissions for md_perm.mp_perm */
 enum {
 	CFS_SETUID_PERM = 0x01,
@@ -2058,8 +2007,6 @@ struct mdt_rec_setattr {
 	__u32	   sa_padding_5;
 };
 
-void lustre_swab_mdt_rec_setattr(struct mdt_rec_setattr *sa);
-
 /*
  * Attribute flags used in mdt_rec_setattr::sa_valid.
  * The kernel's #defines for ATTR_* should not be used over the network
@@ -2334,8 +2281,6 @@ struct mdt_rec_reint {
 	__u32	   rr_padding_4; /* also fix lustre_swab_mdt_rec_reint */
 };
 
-void lustre_swab_mdt_rec_reint(struct mdt_rec_reint *rr);
-
 /* lmv structures */
 struct lmv_desc {
 	__u32 ld_tgt_count;		/* how many MDS's */
@@ -2425,8 +2370,6 @@ static inline __u64 lustre_hash_fnv_1a_64(const void *buf, size_t size)
 	struct lmv_user_md	lmv_user_md;
 };
 
-void lustre_swab_lmv_mds_md(union lmv_mds_md *lmm);
-
 static inline ssize_t lmv_mds_md_size(int stripe_count, unsigned int lmm_magic)
 {
 	ssize_t len = -EINVAL;
@@ -2530,8 +2473,6 @@ struct lov_desc {
 
 #define ld_magic ld_active_tgt_count       /* for swabbing from llogs */
 
-void lustre_swab_lov_desc(struct lov_desc *ld);
-
 /*
  *   LDLM requests:
  */
@@ -2637,8 +2578,6 @@ struct ldlm_flock_wire {
 	struct ldlm_gl_lquota_desc	lquota_desc;
 };
 
-void lustre_swab_gl_desc(union ldlm_gl_desc *);
-
 enum ldlm_intent_flags {
 	IT_OPEN		= BIT(0),
 	IT_CREAT	= BIT(1),
@@ -2661,8 +2600,6 @@ struct ldlm_intent {
 	__u64 opc;
 };
 
-void lustre_swab_ldlm_intent(struct ldlm_intent *i);
-
 struct ldlm_resource_desc {
 	enum ldlm_type lr_type;
 	__u32 lr_padding;       /* also fix lustre_swab_ldlm_resource_desc */
@@ -2686,8 +2623,6 @@ struct ldlm_request {
 	struct lustre_handle lock_handle[LDLM_LOCKREQ_HANDLES];
 };
 
-void lustre_swab_ldlm_request(struct ldlm_request *rq);
-
 /* If LDLM_ENQUEUE, 1 slot is already occupied, 1 is available.
  * Otherwise, 2 are available.
  */
@@ -2709,8 +2644,6 @@ struct ldlm_reply {
 	__u64  lock_policy_res2;
 };
 
-void lustre_swab_ldlm_reply(struct ldlm_reply *r);
-
 #define ldlm_flags_to_wire(flags)    ((__u32)(flags))
 #define ldlm_flags_from_wire(flags)  ((__u64)(flags))
 
@@ -2754,8 +2687,6 @@ struct mgs_target_info {
 	char	     mti_params[MTI_PARAM_MAXLEN];
 };
 
-void lustre_swab_mgs_target_info(struct mgs_target_info *oinfo);
-
 struct mgs_nidtbl_entry {
 	__u64	   mne_version;    /* table version of this entry */
 	__u32	   mne_instance;   /* target instance # */
@@ -2770,8 +2701,6 @@ struct mgs_nidtbl_entry {
 	} u;
 };
 
-void lustre_swab_mgs_nidtbl_entry(struct mgs_nidtbl_entry *oinfo);
-
 struct mgs_config_body {
 	char     mcb_name[MTI_NAME_MAXLEN]; /* logname */
 	__u64    mcb_offset;    /* next index of config log to request */
@@ -2781,15 +2710,11 @@ struct mgs_config_body {
 	__u32    mcb_units;     /* # of units for bulk transfer */
 };
 
-void lustre_swab_mgs_config_body(struct mgs_config_body *body);
-
 struct mgs_config_res {
 	__u64    mcr_offset;    /* index of last config log */
 	__u64    mcr_size;      /* size of the log */
 };
 
-void lustre_swab_mgs_config_res(struct mgs_config_res *body);
-
 /* Config marker flags (in config log) */
 #define CM_START       0x01
 #define CM_END	 0x02
@@ -2809,8 +2734,6 @@ struct cfg_marker {
 	char	      cm_comment[MTI_NAME_MAXLEN];
 };
 
-void lustre_swab_cfg_marker(struct cfg_marker *marker, int swab, int size);
-
 /*
  * Opcodes for multiple servers.
  */
@@ -3261,25 +3184,6 @@ struct ll_fiemap_info_key {
 	struct fiemap	lfik_fiemap;
 };
 
-void lustre_swab_ost_body(struct ost_body *b);
-void lustre_swab_ost_last_id(__u64 *id);
-void lustre_swab_fiemap(struct fiemap *fiemap);
-
-void lustre_swab_lov_user_md_v1(struct lov_user_md_v1 *lum);
-void lustre_swab_lov_user_md_v3(struct lov_user_md_v3 *lum);
-void lustre_swab_lov_user_md_objects(struct lov_user_ost_data *lod,
-				     int stripe_count);
-void lustre_swab_lov_mds_md(struct lov_mds_md *lmm);
-
-/* llog_swab.c */
-void lustre_swab_llogd_body(struct llogd_body *d);
-void lustre_swab_llog_hdr(struct llog_log_hdr *h);
-void lustre_swab_llogd_conn_body(struct llogd_conn_body *d);
-void lustre_swab_llog_rec(struct llog_rec_hdr *rec);
-
-struct lustre_cfg;
-void lustre_swab_lustre_cfg(struct lustre_cfg *lcfg);
-
 /* Functions for dumping PTLRPC fields */
 void dump_rniobuf(struct niobuf_remote *rnb);
 void dump_ioo(struct obd_ioobj *nb);
@@ -3317,8 +3221,6 @@ struct lustre_capa {
 	__u8	    lc_hmac[CAPA_HMAC_MAX_LEN];   /** HMAC */
 } __packed;
 
-void lustre_swab_lustre_capa(struct lustre_capa *c);
-
 /** lustre_capa::lc_opc */
 enum {
 	CAPA_OPC_BODY_WRITE   = 1 << 0,  /**< write object data */
@@ -3381,8 +3283,6 @@ struct getinfo_fid2path {
 	char	    gf_path[0];
 } __packed;
 
-void lustre_swab_fid2path(struct getinfo_fid2path *gf);
-
 /** path2parent request/reply structures */
 struct getparent {
 	struct lu_fid	gp_fid;		/**< parent FID */
@@ -3409,8 +3309,6 @@ struct layout_intent {
 	__u64 li_end;
 };
 
-void lustre_swab_layout_intent(struct layout_intent *li);
-
 /**
  * On the wire version of hsm_progress structure.
  *
@@ -3429,13 +3327,6 @@ struct hsm_progress_kernel {
 	__u64			hpk_padding2;
 } __packed;
 
-void lustre_swab_hsm_user_state(struct hsm_user_state *hus);
-void lustre_swab_hsm_current_action(struct hsm_current_action *action);
-void lustre_swab_hsm_progress_kernel(struct hsm_progress_kernel *hpk);
-void lustre_swab_hsm_user_state(struct hsm_user_state *hus);
-void lustre_swab_hsm_user_item(struct hsm_user_item *hui);
-void lustre_swab_hsm_request(struct hsm_request *hr);
-
 /** layout swap request structure
  * fid1 and fid2 are in mdt_body
  */
@@ -3443,8 +3334,6 @@ struct mdc_swap_layouts {
 	__u64	   msl_flags;
 } __packed;
 
-void lustre_swab_swap_layouts(struct mdc_swap_layouts *msl);
-
 struct close_data {
 	struct lustre_handle	cd_handle;
 	struct lu_fid		cd_fid;
@@ -3452,7 +3341,5 @@ struct close_data {
 	__u64			cd_reserved[8];
 };
 
-void lustre_swab_close_data(struct close_data *data);
-
 #endif
 /** @} lustreidl */
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index d964841..3301ad6 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -457,8 +457,6 @@ static inline int lmv_user_md_size(int stripes, int lmm_magic)
 		      stripes * sizeof(struct lmv_user_mds_data);
 }
 
-void lustre_swab_lmv_user_md(struct lmv_user_md *lum);
-
 struct ll_recreate_obj {
 	__u64 lrc_id;
 	__u32 lrc_ost_idx;
diff --git a/drivers/staging/lustre/lustre/include/lustre_sec.h b/drivers/staging/lustre/lustre/include/lustre_sec.h
index 89658e0..03a970b 100644
--- a/drivers/staging/lustre/lustre/include/lustre_sec.h
+++ b/drivers/staging/lustre/lustre/include/lustre_sec.h
@@ -50,6 +50,7 @@
 /* Linux specific */
 struct key;
 struct seq_file;
+struct lustre_cfg;
 
 /*
  * forward declaration
diff --git a/drivers/staging/lustre/lustre/include/lustre_swab.h b/drivers/staging/lustre/lustre/include/lustre_swab.h
new file mode 100644
index 0000000..26d01c2
--- /dev/null
+++ b/drivers/staging/lustre/lustre/include/lustre_swab.h
@@ -0,0 +1,102 @@
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2011, 2014, Intel Corporation.
+ *
+ * Copyright 2015 Cray Inc, all rights reserved.
+ * Author: Ben Evans.
+ *
+ * We assume all nodes are either little-endian or big-endian, and we
+ * always send messages in the sender's native format.  The receiver
+ * detects the message format by checking the 'magic' field of the message
+ * (see lustre_msg_swabbed() below).
+ *
+ * Each wire type has corresponding 'lustre_swab_xxxtypexxx()' routines
+ * are implemented in ptlrpc/lustre_swab.c.  These 'swabbers' convert the
+ * type from "other" endian, in-place in the message buffer.
+ *
+ * A swabber takes a single pointer argument.  The caller must already have
+ * verified that the length of the message buffer >= sizeof (type).
+ *
+ * For variable length types, a second 'lustre_swab_v_xxxtypexxx()' routine
+ * may be defined that swabs just the variable part, after the caller has
+ * verified that the message buffer is large enough.
+ */
+
+#ifndef _LUSTRE_SWAB_H_
+#define _LUSTRE_SWAB_H_
+
+#include "lustre/lustre_idl.h"
+
+void lustre_swab_ptlrpc_body(struct ptlrpc_body *pb);
+void lustre_swab_connect(struct obd_connect_data *ocd);
+void lustre_swab_hsm_user_state(struct hsm_user_state *hus);
+void lustre_swab_hsm_state_set(struct hsm_state_set *hss);
+void lustre_swab_obd_statfs(struct obd_statfs *os);
+void lustre_swab_obd_ioobj(struct obd_ioobj *ioo);
+void lustre_swab_niobuf_remote(struct niobuf_remote *nbr);
+void lustre_swab_ost_lvb_v1(struct ost_lvb_v1 *lvb);
+void lustre_swab_ost_lvb(struct ost_lvb *lvb);
+void lustre_swab_obd_quotactl(struct obd_quotactl *q);
+void lustre_swab_lquota_lvb(struct lquota_lvb *lvb);
+void lustre_swab_generic_32s(__u32 *val);
+void lustre_swab_mdt_body(struct mdt_body *b);
+void lustre_swab_mdt_ioepoch(struct mdt_ioepoch *b);
+void lustre_swab_mdt_rec_setattr(struct mdt_rec_setattr *sa);
+void lustre_swab_mdt_rec_reint(struct mdt_rec_reint *rr);
+void lustre_swab_lmv_desc(struct lmv_desc *ld);
+void lustre_swab_lmv_mds_md(union lmv_mds_md *lmm);
+void lustre_swab_lov_desc(struct lov_desc *ld);
+void lustre_swab_gl_desc(union ldlm_gl_desc *desc);
+void lustre_swab_ldlm_intent(struct ldlm_intent *i);
+void lustre_swab_ldlm_request(struct ldlm_request *rq);
+void lustre_swab_ldlm_reply(struct ldlm_reply *r);
+void lustre_swab_mgs_target_info(struct mgs_target_info *oinfo);
+void lustre_swab_mgs_nidtbl_entry(struct mgs_nidtbl_entry *oinfo);
+void lustre_swab_mgs_config_body(struct mgs_config_body *body);
+void lustre_swab_mgs_config_res(struct mgs_config_res *body);
+void lustre_swab_ost_body(struct ost_body *b);
+void lustre_swab_ost_last_id(__u64 *id);
+void lustre_swab_fiemap(struct fiemap *fiemap);
+void lustre_swab_lov_user_md_v1(struct lov_user_md_v1 *lum);
+void lustre_swab_lov_user_md_v3(struct lov_user_md_v3 *lum);
+void lustre_swab_lov_user_md_objects(struct lov_user_ost_data *lod,
+				     int stripe_count);
+void lustre_swab_lov_mds_md(struct lov_mds_md *lmm);
+void lustre_swab_lustre_capa(struct lustre_capa *c);
+void lustre_swab_lustre_capa_key(struct lustre_capa_key *k);
+void lustre_swab_fid2path(struct getinfo_fid2path *gf);
+void lustre_swab_layout_intent(struct layout_intent *li);
+void lustre_swab_hsm_user_state(struct hsm_user_state *hus);
+void lustre_swab_hsm_current_action(struct hsm_current_action *action);
+void lustre_swab_hsm_progress_kernel(struct hsm_progress_kernel *hpk);
+void lustre_swab_hsm_user_state(struct hsm_user_state *hus);
+void lustre_swab_hsm_user_item(struct hsm_user_item *hui);
+void lustre_swab_hsm_request(struct hsm_request *hr);
+void lustre_swab_swap_layouts(struct mdc_swap_layouts *msl);
+void lustre_swab_close_data(struct close_data *data);
+void lustre_swab_lmv_user_md(struct lmv_user_md *lum);
+
+#endif
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index d03e6d4..a4a291a 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -39,6 +39,7 @@
 
 #include "../../include/linux/libcfs/libcfs.h"
 #include "../include/lustre_intent.h"
+#include "../include/lustre_swab.h"
 #include "../include/obd_class.h"
 #include "ldlm_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index ce05493..fc29178 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -51,6 +51,8 @@
 #include "../include/lustre_dlm.h"
 #include "../include/lustre_fid.h"
 #include "../include/lustre_kernelcomm.h"
+#include "../include/lustre_swab.h"
+
 #include "llite_internal.h"
 
 /*
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 6c2abb3..6f9b3cb 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -44,6 +44,7 @@
 #include <linux/mount.h>
 #include "../include/lustre/ll_fiemap.h"
 #include "../include/lustre/lustre_ioctl.h"
+#include "../include/lustre_swab.h"
 
 #include "../include/cl_object.h"
 #include "llite_internal.h"
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 5bae584..b236e93 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -48,6 +48,7 @@
 #include "../include/lustre_dlm.h"
 #include "../include/lustre_mds.h"
 #include "../include/obd_class.h"
+#include "../include/lustre_swab.h"
 #include "../include/lprocfs_status.h"
 #include "../include/lustre_param.h"
 #include "../include/cl_object.h"
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 9ba87d2..561b246 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -39,6 +39,7 @@
 #define DEBUG_SUBSYSTEM S_LOV
 
 #include "../include/lustre_net.h"
+#include "../include/lustre_swab.h"
 #include "../include/obd.h"
 #include "../include/obd_class.h"
 #include "../include/obd_support.h"
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 6494c5b..54ebb99 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -38,10 +38,12 @@
 #include "../include/obd.h"
 #include "../include/obd_class.h"
 #include "../include/lustre_dlm.h"
-#include "../include/lustre_fid.h"	/* fid_res_name_eq() */
+#include "../include/lustre_fid.h"
 #include "../include/lustre_mdc.h"
 #include "../include/lustre_net.h"
 #include "../include/lustre_req_layout.h"
+#include "../include/lustre_swab.h"
+
 #include "mdc_internal.h"
 
 struct mdc_getattr_args {
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index f9755dd..087c2cf 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -38,6 +38,7 @@
 # include <linux/init.h>
 # include <linux/utsname.h>
 
+#include "../include/llog_swab.h"
 #include "../include/lustre_acl.h"
 #include "../include/lustre/lustre_ioctl.h"
 #include "../include/obd_class.h"
@@ -47,6 +48,7 @@
 #include "../include/lustre_param.h"
 #include "../include/lustre_log.h"
 #include "../include/lustre_kernelcomm.h"
+#include "../include/lustre_swab.h"
 
 #include "mdc_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 23600fb..b5370f6 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -43,6 +43,7 @@
 #include "../include/lprocfs_status.h"
 #include "../include/lustre_log.h"
 #include "../include/lustre_disk.h"
+#include "../include/lustre_swab.h"
 
 #include "mgc_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index ae63047..073abe3 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -43,6 +43,7 @@
 
 #define DEBUG_SUBSYSTEM S_LOG
 
+#include "../include/llog_swab.h"
 #include "../include/obd_class.h"
 #include "../include/lustre_log.h"
 #include "llog_internal.h"
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_swab.c b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
index 7869092..723c212 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_swab.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
@@ -38,6 +38,7 @@
 
 #define DEBUG_SUBSYSTEM S_LOG
 
+#include "../include/llog_swab.h"
 #include "../include/lustre_log.h"
 
 static void print_llogd_body(struct llogd_body *d)
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 9d5530c..ea68b6d 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -38,6 +38,7 @@
 #include "../include/obd_class.h"
 #include <linux/string.h>
 #include "../include/lustre/lustre_ioctl.h"
+#include "../include/llog_swab.h"
 #include "../include/lustre_log.h"
 #include "../include/lprocfs_status.h"
 #include "../include/lustre_param.h"
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 31aa58e..eba7098 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -59,10 +59,12 @@
 
 /* __REQ_LAYOUT_USER__ */
 #endif
+#include "../include/llog_swab.h"
 /* struct ptlrpc_request, lustre_msg* */
 #include "../include/lustre_req_layout.h"
 #include "../include/lustre_acl.h"
 #include "../include/lustre_debug.h"
+#include "../include/lustre_swab.h"
 
 /*
  * RQFs (see below) refer to two struct req_msg_field arrays describing the
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 17ec3b6..1178caa 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -42,9 +42,11 @@
 
 #include "../../include/linux/libcfs/libcfs.h"
 
+#include "../include/llog_swab.h"
 #include "../include/obd_support.h"
 #include "../include/obd_class.h"
 #include "../include/lustre_net.h"
+#include "../include/lustre_swab.h"
 #include "../include/obd_cksum.h"
 #include "../include/lustre/ll_fiemap.h"
 
-- 
1.7.1
