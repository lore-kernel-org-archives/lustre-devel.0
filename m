From: James Simmons <jsimmons@infradead.org>
Date: Mon, 19 Dec 2016 12:06:47 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: headers: potential UAPI
	headers
Message-ID: <1482167207-22800-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Not for landing. This is the purposed UAPI headers
with the removal of unlikely and debugging macros.
This is just for feedback to see if this is acceptable
for the upstream client.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_fid.h      | 353 +++++++++++++++++++++
 .../lustre/lustre/include/lustre/lustre_ostid.h    | 233 ++++++++++++++
 2 files changed, 586 insertions(+)
 create mode 100644 drivers/staging/lustre/lustre/include/lustre/lustre_fid.h
 create mode 100644 drivers/staging/lustre/lustre/include/lustre/lustre_ostid.h

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre/lustre_fid.h
new file mode 100644
index 0000000..cb6afa5
--- /dev/null
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_fid.h
@@ -0,0 +1,353 @@
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
+ * Copyright 2016 Cray Inc, all rights reserved.
+ * Author: Ben Evans.
+ *
+ * all fid manipulation functions go here
+ *
+ * FIDS are globally unique within a Lustre filessytem, and are made up
+ * of three parts: sequence, Object ID, and version.
+ *
+ */
+#ifndef _LUSTRE_LUSTRE_FID_H_
+#define _LUSTRE_LUSTRE_FID_H_
+
+#include <lustre/lustre_idl.h>
+
+/** returns fid object sequence */
+static inline __u64 fid_seq(const struct lu_fid *fid)
+{
+	return fid->f_seq;
+}
+
+/** returns fid object id */
+static inline __u32 fid_oid(const struct lu_fid *fid)
+{
+	return fid->f_oid;
+}
+
+/** returns fid object version */
+static inline __u32 fid_ver(const struct lu_fid *fid)
+{
+	return fid->f_ver;
+}
+
+static inline void fid_zero(struct lu_fid *fid)
+{
+	memset(fid, 0, sizeof(*fid));
+}
+
+static inline __u64 fid_ver_oid(const struct lu_fid *fid)
+{
+	return (__u64)fid_ver(fid) << 32 | fid_oid(fid);
+}
+
+static inline bool fid_seq_is_mdt0(__u64 seq)
+{
+	return seq == FID_SEQ_OST_MDT0;
+}
+
+static inline bool fid_seq_is_mdt(__u64 seq)
+{
+	return seq == FID_SEQ_OST_MDT0 || seq >= FID_SEQ_NORMAL;
+};
+
+static inline bool fid_seq_is_echo(__u64 seq)
+{
+	return seq == FID_SEQ_ECHO;
+}
+
+static inline bool fid_is_echo(const struct lu_fid *fid)
+{
+	return fid_seq_is_echo(fid_seq(fid));
+}
+
+static inline bool fid_seq_is_llog(__u64 seq)
+{
+	return seq == FID_SEQ_LLOG;
+}
+
+static inline bool fid_is_llog(const struct lu_fid *fid)
+{
+	/* file with OID == 0 is not llog but contains last oid */
+	return fid_seq_is_llog(fid_seq(fid)) && fid_oid(fid) > 0;
+}
+
+static inline bool fid_seq_is_rsvd(__u64 seq)
+{
+	return seq > FID_SEQ_OST_MDT0 && seq <= FID_SEQ_RSVD;
+};
+
+static inline bool fid_seq_is_special(__u64 seq)
+{
+	return seq == FID_SEQ_SPECIAL;
+};
+
+static inline bool fid_seq_is_local_file(__u64 seq)
+{
+	return seq == FID_SEQ_LOCAL_FILE ||
+	       seq == FID_SEQ_LOCAL_NAME;
+};
+
+static inline bool fid_seq_is_root(__u64 seq)
+{
+	return seq == FID_SEQ_ROOT;
+}
+
+static inline bool fid_seq_is_dot(__u64 seq)
+{
+	return seq == FID_SEQ_DOT_LUSTRE;
+}
+
+static inline bool fid_seq_is_default(__u64 seq)
+{
+	return seq == FID_SEQ_LOV_DEFAULT;
+}
+
+static inline bool fid_is_mdt0(const struct lu_fid *fid)
+{
+	return fid_seq_is_mdt0(fid_seq(fid));
+}
+
+static inline void lu_root_fid(struct lu_fid *fid)
+{
+	fid->f_seq = FID_SEQ_ROOT;
+	fid->f_oid = FID_OID_ROOT;
+	fid->f_ver = 0;
+}
+
+static inline void lu_echo_root_fid(struct lu_fid *fid)
+{
+	fid->f_seq = FID_SEQ_ROOT;
+	fid->f_oid = FID_OID_ECHO_ROOT;
+	fid->f_ver = 0;
+}
+
+static inline void lu_update_log_fid(struct lu_fid *fid, __u32 index)
+{
+	fid->f_seq = FID_SEQ_UPDATE_LOG;
+	fid->f_oid = index;
+	fid->f_ver = 0;
+}
+
+static inline void lu_update_log_dir_fid(struct lu_fid *fid, __u32 index)
+{
+	fid->f_seq = FID_SEQ_UPDATE_LOG_DIR;
+	fid->f_oid = index;
+	fid->f_ver = 0;
+}
+
+/**
+ * Check if a fid is igif or not.
+ * \param fid the fid to be tested.
+ * \return true if the fid is an igif; otherwise false.
+ */
+static inline bool fid_seq_is_igif(__u64 seq)
+{
+	return seq >= FID_SEQ_IGIF && seq <= FID_SEQ_IGIF_MAX;
+}
+
+static inline bool fid_is_igif(const struct lu_fid *fid)
+{
+	return fid_seq_is_igif(fid_seq(fid));
+}
+
+/**
+ * Check if a fid is idif or not.
+ * \param fid the fid to be tested.
+ * \return true if the fid is an idif; otherwise false.
+ */
+static inline bool fid_seq_is_idif(__u64 seq)
+{
+	return seq >= FID_SEQ_IDIF && seq <= FID_SEQ_IDIF_MAX;
+}
+
+static inline bool fid_is_idif(const struct lu_fid *fid)
+{
+	return fid_seq_is_idif(fid_seq(fid));
+}
+
+static inline bool fid_is_local_file(const struct lu_fid *fid)
+{
+	return fid_seq_is_local_file(fid_seq(fid));
+}
+
+static inline bool fid_seq_is_norm(__u64 seq)
+{
+	return (seq >= FID_SEQ_NORMAL);
+}
+
+static inline bool fid_is_norm(const struct lu_fid *fid)
+{
+	return fid_seq_is_norm(fid_seq(fid));
+}
+
+static inline int fid_is_layout_rbtree(const struct lu_fid *fid)
+{
+	return fid_seq(fid) == FID_SEQ_LAYOUT_RBTREE;
+}
+
+static inline bool fid_seq_is_update_log(__u64 seq)
+{
+	return seq == FID_SEQ_UPDATE_LOG;
+}
+
+static inline bool fid_is_update_log(const struct lu_fid *fid)
+{
+	return fid_seq_is_update_log(fid_seq(fid));
+}
+
+static inline bool fid_seq_is_update_log_dir(__u64 seq)
+{
+	return seq == FID_SEQ_UPDATE_LOG_DIR;
+}
+
+static inline bool fid_is_update_log_dir(const struct lu_fid *fid)
+{
+	return fid_seq_is_update_log_dir(fid_seq(fid));
+}
+
+/* convert an OST objid into an IDIF FID SEQ number */
+static inline __u64 fid_idif_seq(__u64 id, __u32 ost_idx)
+{
+	return FID_SEQ_IDIF | (ost_idx << 16) | ((id >> 32) & 0xffff);
+}
+
+/* convert a packed IDIF FID into an OST objid */
+static inline __u64 fid_idif_id(__u64 seq, __u32 oid, __u32 ver)
+{
+	return ((__u64)ver << 48) | ((seq & 0xffff) << 32) | oid;
+}
+
+static inline __u32 idif_ost_idx(__u64 seq)
+{
+	return (seq >> 16) & 0xffff;
+}
+
+/* extract ost index from IDIF FID */
+static inline __u32 fid_idif_ost_idx(const struct lu_fid *fid)
+{
+	return idif_ost_idx(fid_seq(fid));
+}
+
+/* Check whether the fid is for LAST_ID */
+static inline bool fid_is_last_id(const struct lu_fid *fid)
+{
+	return !fid_oid(fid) && fid_seq(fid) != FID_SEQ_UPDATE_LOG &&
+	       fid_seq(fid) != FID_SEQ_UPDATE_LOG_DIR;
+}
+
+/**
+ * Get inode number from an igif.
+ * \param fid an igif to get inode number from.
+ * \return inode number for the igif.
+ */
+static inline ino_t lu_igif_ino(const struct lu_fid *fid)
+{
+	return fid_seq(fid);
+}
+
+/**
+ * Get inode generation from an igif.
+ * \param fid an igif to get inode generation from.
+ * \return inode generation for the igif.
+ */
+static inline __u32 lu_igif_gen(const struct lu_fid *fid)
+{
+	return fid_oid(fid);
+}
+
+/**
+ * Build igif from the inode number/generation.
+ */
+static inline void lu_igif_build(struct lu_fid *fid, __u32 ino, __u32 gen)
+{
+	fid->f_seq = ino;
+	fid->f_oid = gen;
+	fid->f_ver = 0;
+}
+
+/*
+ * Fids are transmitted across network (in the sender byte-ordering),
+ * and stored on disk in big-endian order.
+ */
+static inline void fid_cpu_to_le(struct lu_fid *dst, const struct lu_fid *src)
+{
+	dst->f_seq = __cpu_to_le64(fid_seq(src));
+	dst->f_oid = __cpu_to_le32(fid_oid(src));
+	dst->f_ver = __cpu_to_le32(fid_ver(src));
+}
+
+static inline void fid_le_to_cpu(struct lu_fid *dst, const struct lu_fid *src)
+{
+	dst->f_seq = __le64_to_cpu(fid_seq(src));
+	dst->f_oid = __le32_to_cpu(fid_oid(src));
+	dst->f_ver = __le32_to_cpu(fid_ver(src));
+}
+
+static inline void fid_cpu_to_be(struct lu_fid *dst, const struct lu_fid *src)
+{
+	dst->f_seq = __cpu_to_be64(fid_seq(src));
+	dst->f_oid = __cpu_to_be32(fid_oid(src));
+	dst->f_ver = __cpu_to_be32(fid_ver(src));
+}
+
+static inline void fid_be_to_cpu(struct lu_fid *dst, const struct lu_fid *src)
+{
+	dst->f_seq = __be64_to_cpu(fid_seq(src));
+	dst->f_oid = __be32_to_cpu(fid_oid(src));
+	dst->f_ver = __be32_to_cpu(fid_ver(src));
+}
+
+static inline bool fid_is_sane(const struct lu_fid *fid)
+{
+	return fid && ((fid_seq(fid) >= FID_SEQ_START && !fid_ver(fid)) ||
+			fid_is_igif(fid) || fid_is_idif(fid) ||
+			fid_seq_is_rsvd(fid_seq(fid)));
+}
+
+static inline bool lu_fid_eq(const struct lu_fid *f0, const struct lu_fid *f1)
+{
+	return !memcmp(f0, f1, sizeof(*f0));
+}
+
+static inline int lu_fid_cmp(const struct lu_fid *f0,
+			     const struct lu_fid *f1)
+{
+	if (fid_seq(f0) != fid_seq(f1))
+		return fid_seq(f0) > fid_seq(f1) ? 1 : -1;
+
+	if (fid_oid(f0) != fid_oid(f1))
+		return fid_oid(f0) > fid_oid(f1) ? 1 : -1;
+
+	if (fid_ver(f0) != fid_ver(f1))
+		return fid_ver(f0) > fid_ver(f1) ? 1 : -1;
+
+	return 0;
+}
+#endif
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_ostid.h b/drivers/staging/lustre/lustre/include/lustre/lustre_ostid.h
new file mode 100644
index 0000000..140efb1
--- /dev/null
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_ostid.h
@@ -0,0 +1,233 @@
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
+ * Define ost_id  associated functions
+ */
+
+#ifndef _LUSTRE_OSTID_H_
+#define _LUSTRE_OSTID_H_
+
+#include <lustre/lustre_fid.h>
+#include <lustre/lustre_idl.h>
+
+static inline __u64 lmm_oi_id(const struct ost_id *oi)
+{
+	return oi->oi.oi_id;
+}
+
+static inline __u64 lmm_oi_seq(const struct ost_id *oi)
+{
+	return oi->oi.oi_seq;
+}
+
+static inline void lmm_oi_set_seq(struct ost_id *oi, __u64 seq)
+{
+	oi->oi.oi_seq = seq;
+}
+
+static inline void lmm_oi_set_id(struct ost_id *oi, __u64 oid)
+{
+	oi->oi.oi_id = oid;
+}
+
+static inline void lmm_oi_le_to_cpu(struct ost_id *dst_oi,
+				    const struct ost_id *src_oi)
+{
+	dst_oi->oi.oi_id = __le64_to_cpu(src_oi->oi.oi_id);
+	dst_oi->oi.oi_seq = __le64_to_cpu(src_oi->oi.oi_seq);
+}
+
+static inline void lmm_oi_cpu_to_le(struct ost_id *dst_oi,
+				    const struct ost_id *src_oi)
+{
+	dst_oi->oi.oi_id = __cpu_to_le64(src_oi->oi.oi_id);
+	dst_oi->oi.oi_seq = __cpu_to_le64(src_oi->oi.oi_seq);
+}
+
+/* extract OST sequence (group) from a wire ost_id (id/seq) pair */
+static inline __u64 ostid_seq(const struct ost_id *ostid)
+{
+	if (fid_seq_is_mdt0(ostid->oi.oi_seq))
+		return FID_SEQ_OST_MDT0;
+
+	if (fid_seq_is_default(ostid->oi.oi_seq))
+		return FID_SEQ_LOV_DEFAULT;
+
+	if (fid_is_idif(&ostid->oi_fid))
+		return FID_SEQ_OST_MDT0;
+
+	return fid_seq(&ostid->oi_fid);
+}
+
+/* extract OST objid from a wire ost_id (id/seq) pair */
+static inline __u64 ostid_id(const struct ost_id *ostid)
+{
+	if (fid_seq_is_mdt0(ostid->oi.oi_seq))
+		return ostid->oi.oi_id & IDIF_OID_MASK;
+
+	if (fid_seq_is_default(ostid->oi.oi_seq))
+		return ostid->oi.oi_id;
+
+	if (fid_is_idif(&ostid->oi_fid))
+		return fid_idif_id(fid_seq(&ostid->oi_fid),
+				   fid_oid(&ostid->oi_fid), 0);
+
+	return fid_oid(&ostid->oi_fid);
+}
+
+static inline void ostid_set_seq(struct ost_id *oi, __u64 seq)
+{
+	if (fid_seq_is_mdt0(seq) || fid_seq_is_default(seq)) {
+		oi->oi.oi_seq = seq;
+	} else {
+		oi->oi_fid.f_seq = seq;
+		/*
+		 * Note: if f_oid + f_ver is zero, we need init it
+		 * to be 1, otherwise, ostid_seq will treat this
+		 * as old ostid (oi_seq == 0)
+		 */
+		if (!oi->oi_fid.f_oid && !oi->oi_fid.f_ver)
+			oi->oi_fid.f_oid = LUSTRE_FID_INIT_OID;
+	}
+}
+
+static inline void ostid_set_seq_mdt0(struct ost_id *oi)
+{
+	ostid_set_seq(oi, FID_SEQ_OST_MDT0);
+}
+
+static inline void ostid_set_seq_echo(struct ost_id *oi)
+{
+	ostid_set_seq(oi, FID_SEQ_ECHO);
+}
+
+static inline void ostid_set_seq_llog(struct ost_id *oi)
+{
+	ostid_set_seq(oi, FID_SEQ_LLOG);
+}
+
+/**
+ * Note: we need check oi_seq to decide where to set oi_id,
+ * so oi_seq should always be set ahead of oi_id.
+ */
+static inline int ostid_set_id(struct ost_id *oi, __u64 oid)
+{
+	if (fid_seq_is_mdt0(oi->oi.oi_seq)) {
+		if (oid >= IDIF_MAX_OID)
+			return -EINVAL;
+		oi->oi.oi_id = oid;
+	} else if (fid_is_idif(&oi->oi_fid)) {
+		if (oid >= IDIF_MAX_OID)
+			return -EINVAL;
+		oi->oi_fid.f_seq = fid_idif_seq(oid,
+						fid_idif_ost_idx(&oi->oi_fid));
+		oi->oi_fid.f_oid = oid;
+		oi->oi_fid.f_ver = oid >> 48;
+	} else {
+		if (oid > OBIF_MAX_OID)
+			return -EINVAL;
+		oi->oi_fid.f_oid = oid;
+	}
+	return 0;
+}
+
+static inline void ostid_cpu_to_le(const struct ost_id *src_oi,
+				   struct ost_id *dst_oi)
+{
+	if (fid_seq_is_mdt0(src_oi->oi.oi_seq)) {
+		dst_oi->oi.oi_id = __cpu_to_le64(src_oi->oi.oi_id);
+		dst_oi->oi.oi_seq = __cpu_to_le64(src_oi->oi.oi_seq);
+	} else {
+		fid_cpu_to_le(&dst_oi->oi_fid, &src_oi->oi_fid);
+	}
+}
+
+static inline void ostid_le_to_cpu(const struct ost_id *src_oi,
+				   struct ost_id *dst_oi)
+{
+	if (fid_seq_is_mdt0(src_oi->oi.oi_seq)) {
+		dst_oi->oi.oi_id = __le64_to_cpu(src_oi->oi.oi_id);
+		dst_oi->oi.oi_seq = __le64_to_cpu(src_oi->oi.oi_seq);
+	} else {
+		fid_le_to_cpu(&dst_oi->oi_fid, &src_oi->oi_fid);
+	}
+}
+
+/* pack any OST FID into an ostid (id/seq) for the wire/disk */
+static inline int fid_to_ostid(const struct lu_fid *fid, struct ost_id *ostid)
+{
+	int rc = 0;
+
+	if (fid_seq_is_igif(fid->f_seq))
+		return -EBADF;
+
+	if (fid_is_idif(fid)) {
+		ostid_set_seq_mdt0(ostid);
+		rc = ostid_set_id(ostid, fid_idif_id(fid_seq(fid),
+				  fid_oid(fid), fid_ver(fid)));
+	} else {
+		ostid->oi_fid = *fid;
+	}
+
+	return rc;
+}
+
+/**
+ * Sigh, because pre-2.4 uses
+ * struct lov_mds_md_v1 {
+ *	........
+ *	__u64 lmm_object_id;
+ *	__u64 lmm_object_seq;
+ *      ......
+ *      }
+ * to identify the LOV(MDT) object, and lmm_object_seq will
+ * be normal_fid, which make it hard to combine these conversion
+ * to ostid_to FID. so we will do lmm_oi/fid conversion separately
+ *
+ * We can tell the lmm_oi by this way,
+ * 1.8: lmm_object_id = {inode}, lmm_object_gr = 0
+ * 2.1: lmm_object_id = {oid < 128k}, lmm_object_seq = FID_SEQ_NORMAL
+ * 2.4: lmm_oi.f_seq = FID_SEQ_NORMAL, lmm_oi.f_oid = {oid < 128k},
+ *      lmm_oi.f_ver = 0
+ *
+ * But currently lmm_oi/lsm_oi does not have any "real" usages,
+ * except for printing some information, and the user can always
+ * get the real FID from LMA, besides this multiple case check might
+ * make swab more complicate. So we will keep using id/seq for lmm_oi.
+ */
+
+static inline void fid_to_lmm_oi(const struct lu_fid *fid,
+				 struct ost_id *oi)
+{
+	oi->oi.oi_id = fid_oid(fid);
+	oi->oi.oi_seq = fid_seq(fid);
+}
+
+#endif
-- 
1.8.3.1
