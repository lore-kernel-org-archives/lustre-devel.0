From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:25:59 -0400
Subject: [lustre-devel] [PATCH 05/64 v2] staging: lustre: uapi: move lu_fid,
	ost_id funcs out of lustre_idl.h
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Ben Evans <bevans@cray.com>, James Simmons <uja.ornl@yahoo.com>, James Simmons <jsimmons@infradead.org>

From: Ben Evans <bevans@cray.com>

Move lu_fid functions into lustre/lustre_fid.h
Move ost_id functions into lustre/lustre_ostid.h
Fix indenting, include new headers as needed.

Several inline functions in the header lustre_ostid.h
are using debug macros instead of returning proper errors.
Remove the debug macros and properly handle the returned
error codes. Place both UAPI headers lustre_fid.h and
lustre_ostid.h into the uapi directory.

Signed-off-by: Ben Evans <bevans@cray.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/22712
Reviewed-on: https://review.whamcloud.com/24569
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/uapi/linux/lustre/lustre_fid.h  | 293 +++++++++++
 .../include/uapi/linux/lustre/lustre_ostid.h       | 237 +++++++++
 .../lustre/lustre/include/lustre/lustre_idl.h      | 541 +--------------------
 drivers/staging/lustre/lustre/include/lustre_fid.h |  49 +-
 drivers/staging/lustre/lustre/include/lustre_fld.h |   1 +
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   2 +
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   2 +
 7 files changed, 587 insertions(+), 538 deletions(-)
 create mode 100644 drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h
 create mode 100644 drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h
new file mode 100644
index 0000000..9adc106
--- /dev/null
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h
@@ -0,0 +1,293 @@
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
+#ifndef _UAPI_LUSTRE_FID_H_
+#define _UAPI_LUSTRE_FID_H_
+
+#include "../../../../lustre/include/lustre/lustre_idl.h"
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
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h
new file mode 100644
index 0000000..fe7c59f
--- /dev/null
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h
@@ -0,0 +1,237 @@
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
+#ifndef _UAPI_LUSTRE_OSTID_H_
+#define _UAPI_LUSTRE_OSTID_H_
+
+#include <linux/errno.h>
+#include "lustre_fid.h"
+#include "../../../../lustre/include/lustre/lustre_idl.h"
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
+/**
+ * Unpack an OST object id/seq (group) into a FID.  This is needed for
+ * converting all obdo, lmm, lsm, etc. 64-bit id/seq pairs into proper
+ * FIDs.  Note that if an id/seq is already in FID/IDIF format it will
+ * be passed through unchanged.  Only legacy OST objects in "group 0"
+ * will be mapped into the IDIF namespace so that they can fit into the
+ * struct lu_fid fields without loss.
+ */
+static inline int ostid_to_fid(struct lu_fid *fid, const struct ost_id *ostid,
+			       __u32 ost_idx)
+{
+	__u64 seq = ostid_seq(ostid);
+
+	if (ost_idx > 0xffff)
+		return -EBADF;
+
+	if (fid_seq_is_mdt0(seq)) {
+		__u64 oid = ostid_id(ostid);
+
+		/* This is a "legacy" (old 1.x/2.early) OST object in "group 0"
+		 * that we map into the IDIF namespace.  It allows up to 2^48
+		 * objects per OST, as this is the object namespace that has
+		 * been in production for years.  This can handle create rates
+		 * of 1M objects/s/OST for 9 years, or combinations thereof.
+		 */
+		if (oid >= IDIF_MAX_OID)
+			return -EBADF;
+
+		fid->f_seq = fid_idif_seq(oid, ost_idx);
+		/* truncate to 32 bits by assignment */
+		fid->f_oid = oid;
+		/* in theory, not currently used */
+		fid->f_ver = oid >> 48;
+	} else if (!fid_seq_is_default(seq)) {
+		/* This is either an IDIF object, which identifies objects
+		 * across all OSTs, or a regular FID.  The IDIF namespace
+		 * maps legacy OST objects into the FID namespace.  In both
+		 * cases, we just pass the FID through, no conversion needed.
+		 */
+		if (ostid->oi_fid.f_ver)
+			return -EBADF;
+
+		*fid = ostid->oi_fid;
+	}
+
+	return 0;
+}
+#endif /* _UAPI_LUSTRE_OSTID_H_ */
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index d70495d..fab624e 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -74,7 +74,6 @@
 
 /* Defn's shared with user-space. */
 #include "lustre_user.h"
-#include "lustre_errno.h"
 #include "../lustre_ver.h"
 
 /*
@@ -217,34 +216,6 @@ enum {
 	LUSTRE_FID_INIT_OID  = 1UL
 };
 
-/** returns fid object sequence */
-static inline __u64 fid_seq(const struct lu_fid *fid)
-{
-	return fid->f_seq;
-}
-
-/** returns fid object id */
-static inline __u32 fid_oid(const struct lu_fid *fid)
-{
-	return fid->f_oid;
-}
-
-/** returns fid object version */
-static inline __u32 fid_ver(const struct lu_fid *fid)
-{
-	return fid->f_ver;
-}
-
-static inline void fid_zero(struct lu_fid *fid)
-{
-	memset(fid, 0, sizeof(*fid));
-}
-
-static inline __u64 fid_ver_oid(const struct lu_fid *fid)
-{
-	return ((__u64)fid_ver(fid) << 32 | fid_oid(fid));
-}
-
 /* copytool uses a 32b bitmask field to encode archive-Ids during register
  * with MDT thru kuc.
  * archive num = 0 => all
@@ -313,451 +284,12 @@ enum dot_lustre_oid {
 	FID_OID_DOT_LUSTRE_OBF = 2UL,
 };
 
-static inline bool fid_seq_is_mdt0(__u64 seq)
-{
-	return (seq == FID_SEQ_OST_MDT0);
-}
-
-static inline bool fid_seq_is_mdt(__u64 seq)
-{
-	return seq == FID_SEQ_OST_MDT0 || seq >= FID_SEQ_NORMAL;
+/** OID for FID_SEQ_ROOT */
+enum root_oid {
+	FID_OID_ROOT		= 1UL,
+	FID_OID_ECHO_ROOT	= 2UL,
 };
 
-static inline bool fid_seq_is_echo(__u64 seq)
-{
-	return (seq == FID_SEQ_ECHO);
-}
-
-static inline bool fid_is_echo(const struct lu_fid *fid)
-{
-	return fid_seq_is_echo(fid_seq(fid));
-}
-
-static inline bool fid_seq_is_llog(__u64 seq)
-{
-	return (seq == FID_SEQ_LLOG);
-}
-
-static inline bool fid_is_llog(const struct lu_fid *fid)
-{
-	/* file with OID == 0 is not llog but contains last oid */
-	return fid_seq_is_llog(fid_seq(fid)) && fid_oid(fid) > 0;
-}
-
-static inline bool fid_seq_is_rsvd(__u64 seq)
-{
-	return (seq > FID_SEQ_OST_MDT0 && seq <= FID_SEQ_RSVD);
-};
-
-static inline bool fid_seq_is_special(__u64 seq)
-{
-	return seq == FID_SEQ_SPECIAL;
-};
-
-static inline bool fid_seq_is_local_file(__u64 seq)
-{
-	return seq == FID_SEQ_LOCAL_FILE ||
-	       seq == FID_SEQ_LOCAL_NAME;
-};
-
-static inline bool fid_seq_is_root(__u64 seq)
-{
-	return seq == FID_SEQ_ROOT;
-}
-
-static inline bool fid_seq_is_dot(__u64 seq)
-{
-	return seq == FID_SEQ_DOT_LUSTRE;
-}
-
-static inline bool fid_seq_is_default(__u64 seq)
-{
-	return seq == FID_SEQ_LOV_DEFAULT;
-}
-
-static inline bool fid_is_mdt0(const struct lu_fid *fid)
-{
-	return fid_seq_is_mdt0(fid_seq(fid));
-}
-
-static inline void lu_root_fid(struct lu_fid *fid)
-{
-	fid->f_seq = FID_SEQ_ROOT;
-	fid->f_oid = 1;
-	fid->f_ver = 0;
-}
-
-/**
- * Check if a fid is igif or not.
- * \param fid the fid to be tested.
- * \return true if the fid is a igif; otherwise false.
- */
-static inline bool fid_seq_is_igif(__u64 seq)
-{
-	return seq >= FID_SEQ_IGIF && seq <= FID_SEQ_IGIF_MAX;
-}
-
-static inline bool fid_is_igif(const struct lu_fid *fid)
-{
-	return fid_seq_is_igif(fid_seq(fid));
-}
-
-/**
- * Check if a fid is idif or not.
- * \param fid the fid to be tested.
- * \return true if the fid is a idif; otherwise false.
- */
-static inline bool fid_seq_is_idif(__u64 seq)
-{
-	return seq >= FID_SEQ_IDIF && seq <= FID_SEQ_IDIF_MAX;
-}
-
-static inline bool fid_is_idif(const struct lu_fid *fid)
-{
-	return fid_seq_is_idif(fid_seq(fid));
-}
-
-static inline bool fid_is_local_file(const struct lu_fid *fid)
-{
-	return fid_seq_is_local_file(fid_seq(fid));
-}
-
-static inline bool fid_seq_is_norm(__u64 seq)
-{
-	return (seq >= FID_SEQ_NORMAL);
-}
-
-static inline bool fid_is_norm(const struct lu_fid *fid)
-{
-	return fid_seq_is_norm(fid_seq(fid));
-}
-
-/* convert an OST objid into an IDIF FID SEQ number */
-static inline __u64 fid_idif_seq(__u64 id, __u32 ost_idx)
-{
-	return FID_SEQ_IDIF | (ost_idx << 16) | ((id >> 32) & 0xffff);
-}
-
-/* convert a packed IDIF FID into an OST objid */
-static inline __u64 fid_idif_id(__u64 seq, __u32 oid, __u32 ver)
-{
-	return ((__u64)ver << 48) | ((seq & 0xffff) << 32) | oid;
-}
-
-/* extract ost index from IDIF FID */
-static inline __u32 fid_idif_ost_idx(const struct lu_fid *fid)
-{
-	return (fid_seq(fid) >> 16) & 0xffff;
-}
-
-/* extract OST sequence (group) from a wire ost_id (id/seq) pair */
-static inline __u64 ostid_seq(const struct ost_id *ostid)
-{
-	if (fid_seq_is_mdt0(ostid->oi.oi_seq))
-		return FID_SEQ_OST_MDT0;
-
-	if (unlikely(fid_seq_is_default(ostid->oi.oi_seq)))
-		return FID_SEQ_LOV_DEFAULT;
-
-	if (fid_is_idif(&ostid->oi_fid))
-		return FID_SEQ_OST_MDT0;
-
-	return fid_seq(&ostid->oi_fid);
-}
-
-/* extract OST objid from a wire ost_id (id/seq) pair */
-static inline __u64 ostid_id(const struct ost_id *ostid)
-{
-	if (fid_seq_is_mdt0(ostid->oi.oi_seq))
-		return ostid->oi.oi_id & IDIF_OID_MASK;
-
-	if (unlikely(fid_seq_is_default(ostid->oi.oi_seq)))
-		return ostid->oi.oi_id;
-
-	if (fid_is_idif(&ostid->oi_fid))
-		return fid_idif_id(fid_seq(&ostid->oi_fid),
-				   fid_oid(&ostid->oi_fid), 0);
-
-	return fid_oid(&ostid->oi_fid);
-}
-
-static inline void ostid_set_seq(struct ost_id *oi, __u64 seq)
-{
-	if (fid_seq_is_mdt0(seq) || fid_seq_is_default(seq)) {
-		oi->oi.oi_seq = seq;
-	} else {
-		oi->oi_fid.f_seq = seq;
-		/* Note: if f_oid + f_ver is zero, we need init it
-		 * to be 1, otherwise, ostid_seq will treat this
-		 * as old ostid (oi_seq == 0)
-		 */
-		if (oi->oi_fid.f_oid == 0 && oi->oi_fid.f_ver == 0)
-			oi->oi_fid.f_oid = LUSTRE_FID_INIT_OID;
-	}
-}
-
-static inline void ostid_set_seq_mdt0(struct ost_id *oi)
-{
-	ostid_set_seq(oi, FID_SEQ_OST_MDT0);
-}
-
-static inline void ostid_set_seq_echo(struct ost_id *oi)
-{
-	ostid_set_seq(oi, FID_SEQ_ECHO);
-}
-
-static inline void ostid_set_seq_llog(struct ost_id *oi)
-{
-	ostid_set_seq(oi, FID_SEQ_LLOG);
-}
-
-/**
- * Note: we need check oi_seq to decide where to set oi_id,
- * so oi_seq should always be set ahead of oi_id.
- */
-static inline int ostid_set_id(struct ost_id *oi, __u64 oid)
-{
-	if (fid_seq_is_mdt0(oi->oi.oi_seq)) {
-		if (oid >= IDIF_MAX_OID)
-			return -E2BIG;
-		oi->oi.oi_id = oid;
-	} else if (fid_is_idif(&oi->oi_fid)) {
-		if (oid >= IDIF_MAX_OID)
-			return -E2BIG;
-		oi->oi_fid.f_seq = fid_idif_seq(oid,
-						fid_idif_ost_idx(&oi->oi_fid));
-		oi->oi_fid.f_oid = oid;
-		oi->oi_fid.f_ver = oid >> 48;
-	} else {
-		if (oid >= OBIF_MAX_OID)
-			return -E2BIG;
-		oi->oi_fid.f_oid = oid;
-	}
-	return 0;
-}
-
-static inline int fid_set_id(struct lu_fid *fid, __u64 oid)
-{
-	if (unlikely(fid_seq_is_igif(fid->f_seq))) {
-		CERROR("bad IGIF, " DFID "\n", PFID(fid));
-		return -EBADF;
-	}
-
-	if (fid_is_idif(fid)) {
-		if (oid >= IDIF_MAX_OID) {
-			CERROR("Too large OID %#llx to set IDIF " DFID "\n",
-			       (unsigned long long)oid, PFID(fid));
-			return -EBADF;
-		}
-		fid->f_seq = fid_idif_seq(oid, fid_idif_ost_idx(fid));
-		fid->f_oid = oid;
-		fid->f_ver = oid >> 48;
-	} else {
-		if (oid >= OBIF_MAX_OID) {
-			CERROR("Too large OID %#llx to set REG " DFID "\n",
-			       (unsigned long long)oid, PFID(fid));
-			return -EBADF;
-		}
-		fid->f_oid = oid;
-	}
-	return 0;
-}
-
-/**
- * Unpack an OST object id/seq (group) into a FID.  This is needed for
- * converting all obdo, lmm, lsm, etc. 64-bit id/seq pairs into proper
- * FIDs.  Note that if an id/seq is already in FID/IDIF format it will
- * be passed through unchanged.  Only legacy OST objects in "group 0"
- * will be mapped into the IDIF namespace so that they can fit into the
- * struct lu_fid fields without loss.  For reference see:
- * http://wiki.old.lustre.org/index.php/Architecture_-_Interoperability_fids_zfs
- */
-static inline int ostid_to_fid(struct lu_fid *fid, struct ost_id *ostid,
-			       __u32 ost_idx)
-{
-	__u64 seq = ostid_seq(ostid);
-
-	if (ost_idx > 0xffff) {
-		CERROR("bad ost_idx, " DOSTID " ost_idx:%u\n", POSTID(ostid),
-		       ost_idx);
-		return -EBADF;
-	}
-
-	if (fid_seq_is_mdt0(seq)) {
-		__u64 oid = ostid_id(ostid);
-
-		/* This is a "legacy" (old 1.x/2.early) OST object in "group 0"
-		 * that we map into the IDIF namespace.  It allows up to 2^48
-		 * objects per OST, as this is the object namespace that has
-		 * been in production for years.  This can handle create rates
-		 * of 1M objects/s/OST for 9 years, or combinations thereof.
-		 */
-		if (oid >= IDIF_MAX_OID) {
-			CERROR("bad MDT0 id, " DOSTID " ost_idx:%u\n",
-			       POSTID(ostid), ost_idx);
-			return -EBADF;
-		}
-		fid->f_seq = fid_idif_seq(oid, ost_idx);
-		/* truncate to 32 bits by assignment */
-		fid->f_oid = oid;
-		/* in theory, not currently used */
-		fid->f_ver = oid >> 48;
-	} else if (likely(!fid_seq_is_default(seq))) {
-	       /* This is either an IDIF object, which identifies objects across
-		* all OSTs, or a regular FID.  The IDIF namespace maps legacy
-		* OST objects into the FID namespace.  In both cases, we just
-		* pass the FID through, no conversion needed.
-		*/
-		if (ostid->oi_fid.f_ver != 0) {
-			CERROR("bad MDT0 id, " DOSTID " ost_idx:%u\n",
-			       POSTID(ostid), ost_idx);
-			return -EBADF;
-		}
-		*fid = ostid->oi_fid;
-	}
-
-	return 0;
-}
-
-/* pack any OST FID into an ostid (id/seq) for the wire/disk */
-static inline int fid_to_ostid(const struct lu_fid *fid, struct ost_id *ostid)
-{
-	if (unlikely(fid_seq_is_igif(fid->f_seq))) {
-		CERROR("bad IGIF, " DFID "\n", PFID(fid));
-		return -EBADF;
-	}
-
-	if (fid_is_idif(fid)) {
-		ostid_set_seq_mdt0(ostid);
-		ostid_set_id(ostid, fid_idif_id(fid_seq(fid), fid_oid(fid),
-						fid_ver(fid)));
-	} else {
-		ostid->oi_fid = *fid;
-	}
-
-	return 0;
-}
-
-/* Check whether the fid is for LAST_ID */
-static inline bool fid_is_last_id(const struct lu_fid *fid)
-{
-	return (fid_oid(fid) == 0);
-}
-
-/**
- * Get inode number from a igif.
- * \param fid a igif to get inode number from.
- * \return inode number for the igif.
- */
-static inline ino_t lu_igif_ino(const struct lu_fid *fid)
-{
-	return fid_seq(fid);
-}
-
-/**
- * Get inode generation from a igif.
- * \param fid a igif to get inode generation from.
- * \return inode generation for the igif.
- */
-static inline __u32 lu_igif_gen(const struct lu_fid *fid)
-{
-	return fid_oid(fid);
-}
-
-/**
- * Build igif from the inode number/generation.
- */
-static inline void lu_igif_build(struct lu_fid *fid, __u32 ino, __u32 gen)
-{
-	fid->f_seq = ino;
-	fid->f_oid = gen;
-	fid->f_ver = 0;
-}
-
-/*
- * Fids are transmitted across network (in the sender byte-ordering),
- * and stored on disk in big-endian order.
- */
-static inline void fid_cpu_to_le(struct lu_fid *dst, const struct lu_fid *src)
-{
-	dst->f_seq = cpu_to_le64(fid_seq(src));
-	dst->f_oid = cpu_to_le32(fid_oid(src));
-	dst->f_ver = cpu_to_le32(fid_ver(src));
-}
-
-static inline void fid_le_to_cpu(struct lu_fid *dst, const struct lu_fid *src)
-{
-	dst->f_seq = le64_to_cpu(fid_seq(src));
-	dst->f_oid = le32_to_cpu(fid_oid(src));
-	dst->f_ver = le32_to_cpu(fid_ver(src));
-}
-
-static inline void fid_cpu_to_be(struct lu_fid *dst, const struct lu_fid *src)
-{
-	dst->f_seq = cpu_to_be64(fid_seq(src));
-	dst->f_oid = cpu_to_be32(fid_oid(src));
-	dst->f_ver = cpu_to_be32(fid_ver(src));
-}
-
-static inline void fid_be_to_cpu(struct lu_fid *dst, const struct lu_fid *src)
-{
-	dst->f_seq = be64_to_cpu(fid_seq(src));
-	dst->f_oid = be32_to_cpu(fid_oid(src));
-	dst->f_ver = be32_to_cpu(fid_ver(src));
-}
-
-static inline bool fid_is_sane(const struct lu_fid *fid)
-{
-	return fid &&
-	       ((fid_seq(fid) >= FID_SEQ_START && fid_ver(fid) == 0) ||
-		fid_is_igif(fid) || fid_is_idif(fid) ||
-		fid_seq_is_rsvd(fid_seq(fid)));
-}
-
-static inline bool lu_fid_eq(const struct lu_fid *f0, const struct lu_fid *f1)
-{
-	return memcmp(f0, f1, sizeof(*f0)) == 0;
-}
-
-#define __diff_normalize(val0, val1)			    \
-({							      \
-	typeof(val0) __val0 = (val0);			   \
-	typeof(val1) __val1 = (val1);			   \
-								\
-	(__val0 == __val1 ? 0 : __val0 > __val1 ? 1 : -1);     \
-})
-
-static inline int lu_fid_cmp(const struct lu_fid *f0,
-			     const struct lu_fid *f1)
-{
-	return
-		__diff_normalize(fid_seq(f0), fid_seq(f1)) ?:
-		__diff_normalize(fid_oid(f0), fid_oid(f1)) ?:
-		__diff_normalize(fid_ver(f0), fid_ver(f1));
-}
-
-static inline void ostid_cpu_to_le(const struct ost_id *src_oi,
-				   struct ost_id *dst_oi)
-{
-	if (fid_seq_is_mdt0(ostid_seq(src_oi))) {
-		dst_oi->oi.oi_id = cpu_to_le64(src_oi->oi.oi_id);
-		dst_oi->oi.oi_seq = cpu_to_le64(src_oi->oi.oi_seq);
-	} else {
-		fid_cpu_to_le(&dst_oi->oi_fid, &src_oi->oi_fid);
-	}
-}
-
-static inline void ostid_le_to_cpu(const struct ost_id *src_oi,
-				   struct ost_id *dst_oi)
-{
-	if (fid_seq_is_mdt0(ostid_seq(src_oi))) {
-		dst_oi->oi.oi_id = le64_to_cpu(src_oi->oi.oi_id);
-		dst_oi->oi.oi_seq = le64_to_cpu(src_oi->oi.oi_seq);
-	} else {
-		fid_le_to_cpu(&dst_oi->oi_fid, &src_oi->oi_fid);
-	}
-}
-
 /** @} lu_fid */
 
 /** \defgroup lu_dir lu_dir
@@ -1377,71 +909,6 @@ struct lov_mds_md_v1 {	    /* LOV EA mds/wire data (little-endian) */
 	struct lov_ost_data_v1 lmm_objects[0]; /* per-stripe data */
 };
 
-/**
- * Sigh, because pre-2.4 uses
- * struct lov_mds_md_v1 {
- *	........
- *	__u64 lmm_object_id;
- *	__u64 lmm_object_seq;
- *      ......
- *      }
- * to identify the LOV(MDT) object, and lmm_object_seq will
- * be normal_fid, which make it hard to combine these conversion
- * to ostid_to FID. so we will do lmm_oi/fid conversion separately
- *
- * We can tell the lmm_oi by this way,
- * 1.8: lmm_object_id = {inode}, lmm_object_gr = 0
- * 2.1: lmm_object_id = {oid < 128k}, lmm_object_seq = FID_SEQ_NORMAL
- * 2.4: lmm_oi.f_seq = FID_SEQ_NORMAL, lmm_oi.f_oid = {oid < 128k},
- *      lmm_oi.f_ver = 0
- *
- * But currently lmm_oi/lsm_oi does not have any "real" usages,
- * except for printing some information, and the user can always
- * get the real FID from LMA, besides this multiple case check might
- * make swab more complicate. So we will keep using id/seq for lmm_oi.
- */
-
-static inline void fid_to_lmm_oi(const struct lu_fid *fid,
-				 struct ost_id *oi)
-{
-	oi->oi.oi_id = fid_oid(fid);
-	oi->oi.oi_seq = fid_seq(fid);
-}
-
-static inline void lmm_oi_set_seq(struct ost_id *oi, __u64 seq)
-{
-	oi->oi.oi_seq = seq;
-}
-
-static inline void lmm_oi_set_id(struct ost_id *oi, __u64 oid)
-{
-	oi->oi.oi_id = oid;
-}
-
-static inline __u64 lmm_oi_id(const struct ost_id *oi)
-{
-	return oi->oi.oi_id;
-}
-
-static inline __u64 lmm_oi_seq(const struct ost_id *oi)
-{
-	return oi->oi.oi_seq;
-}
-
-static inline void lmm_oi_le_to_cpu(struct ost_id *dst_oi,
-				    const struct ost_id *src_oi)
-{
-	dst_oi->oi.oi_id = le64_to_cpu(src_oi->oi.oi_id);
-	dst_oi->oi.oi_seq = le64_to_cpu(src_oi->oi.oi_seq);
-}
-
-static inline void lmm_oi_cpu_to_le(struct ost_id *dst_oi,
-				    const struct ost_id *src_oi)
-{
-	dst_oi->oi.oi_id = cpu_to_le64(src_oi->oi.oi_id);
-	dst_oi->oi.oi_seq = cpu_to_le64(src_oi->oi.oi_seq);
-}
-
 #define MAX_MD_SIZE							\
 	(sizeof(struct lov_mds_md) + 4 * sizeof(struct lov_ost_data))
 #define MIN_MD_SIZE							\
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index 0446bec..7c51642 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -149,8 +149,9 @@
  */
 
 #include "../../include/linux/libcfs/libcfs.h"
+#include "../../include/uapi/linux/lustre/lustre_fid.h"
 #include "lustre/lustre_idl.h"
-#include "seq_range.h"
+#include "../../include/uapi/linux/lustre/lustre_ostid.h"
 
 struct lu_env;
 struct lu_site;
@@ -494,6 +495,52 @@ static inline int ostid_res_name_eq(const struct ost_id *oi,
 	}
 }
 
+/**
+ * Note: we need check oi_seq to decide where to set oi_id,
+ * so oi_seq should always be set ahead of oi_id.
+ */
+static inline int ostid_set_id(struct ost_id *oi, __u64 oid)
+{
+	if (fid_seq_is_mdt0(oi->oi.oi_seq)) {
+		if (oid >= IDIF_MAX_OID)
+			return -E2BIG;
+		oi->oi.oi_id = oid;
+	} else if (fid_is_idif(&oi->oi_fid)) {
+		if (oid >= IDIF_MAX_OID)
+			return -E2BIG;
+		oi->oi_fid.f_seq = fid_idif_seq(oid,
+						fid_idif_ost_idx(&oi->oi_fid));
+		oi->oi_fid.f_oid = oid;
+		oi->oi_fid.f_ver = oid >> 48;
+	} else {
+		if (oid >= OBIF_MAX_OID)
+			return -E2BIG;
+		oi->oi_fid.f_oid = oid;
+	}
+	return 0;
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
+		u64 objid = fid_idif_id(fid_seq(fid), fid_oid(fid),
+					fid_ver(fid));
+
+		ostid_set_seq_mdt0(ostid);
+		rc = ostid_set_id(ostid, objid);
+	} else {
+		ostid->oi_fid = *fid;
+	}
+
+	return rc;
+}
+
 /* The same as osc_build_res_name() */
 static inline void ost_fid_build_resid(const struct lu_fid *fid,
 				       struct ldlm_res_id *resname)
diff --git a/drivers/staging/lustre/lustre/include/lustre_fld.h b/drivers/staging/lustre/lustre/include/lustre_fld.h
index 6ef1b03..f3c61d1 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fld.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fld.h
@@ -40,6 +40,7 @@
 
 #include "lustre/lustre_idl.h"
 #include "../../include/linux/libcfs/libcfs.h"
+#include "seq_range.h"
 
 struct lu_client_fld;
 struct lu_server_fld;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 2e3db5e..b8002e9 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -57,6 +57,8 @@
 
 #define DEBUG_SUBSYSTEM S_LDLM
 
+#include "../include/lustre/lustre_errno.h"
+
 #include "../include/lustre_dlm.h"
 #include "../include/obd_class.h"
 #include "../include/obd.h"
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 1a3fa1b..dc775bb 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -38,6 +38,8 @@
 # include <linux/init.h>
 # include <linux/utsname.h>
 
+#include "../include/lustre/lustre_errno.h"
+
 #include "../include/cl_object.h"
 #include "../include/llog_swab.h"
 #include "../include/lprocfs_status.h"
-- 
1.8.3.1
