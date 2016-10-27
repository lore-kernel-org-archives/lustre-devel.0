From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:12:01 -0400
Subject: [lustre-devel] [PATCH 27/29] staging: lustre: headers: Create
	single .h for lu_seq_range
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Ben Evans <bevans@cray.com>, James Simmons <jsimmons@infradead.org>

From: Ben Evans <bevans@cray.com>

Put lu_seq_range related functions into a single .h.
Include directly from files which use it, and remove
definitions from lustre_idl.h.

Signed-off-by: Ben Evans <bevans@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: http://review.whamcloud.com/15952
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/fid/fid_request.c    |   14 +-
 drivers/staging/lustre/lustre/fid/lproc_fid.c      |    2 +-
 drivers/staging/lustre/lustre/fld/fld_cache.c      |    6 +-
 .../lustre/lustre/include/lustre/lustre_idl.h      |  108 -----------
 drivers/staging/lustre/lustre/include/lustre_fid.h |    1 +
 drivers/staging/lustre/lustre/include/seq_range.h  |  199 ++++++++++++++++++++
 6 files changed, 211 insertions(+), 119 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/include/seq_range.h

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index dfef3ca..999f250 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -74,7 +74,7 @@ static int seq_client_rpc(struct lu_client_seq *seq,
 
 	/* Zero out input range, this is not recovery yet. */
 	in = req_capsule_client_get(&req->rq_pill, &RMF_SEQ_RANGE);
-	range_init(in);
+	lu_seq_range_init(in);
 
 	ptlrpc_request_set_replen(req);
 
@@ -119,14 +119,14 @@ static int seq_client_rpc(struct lu_client_seq *seq,
 	out = req_capsule_server_get(&req->rq_pill, &RMF_SEQ_RANGE);
 	*output = *out;
 
-	if (!range_is_sane(output)) {
+	if (!lu_seq_range_is_sane(output)) {
 		CERROR("%s: Invalid range received from server: "
 		       DRANGE "\n", seq->lcs_name, PRANGE(output));
 		rc = -EINVAL;
 		goto out_req;
 	}
 
-	if (range_is_exhausted(output)) {
+	if (lu_seq_range_is_exhausted(output)) {
 		CERROR("%s: Range received from server is exhausted: "
 		       DRANGE "]\n", seq->lcs_name, PRANGE(output));
 		rc = -EINVAL;
@@ -166,9 +166,9 @@ static int seq_client_alloc_seq(const struct lu_env *env,
 {
 	int rc;
 
-	LASSERT(range_is_sane(&seq->lcs_space));
+	LASSERT(lu_seq_range_is_sane(&seq->lcs_space));
 
-	if (range_is_exhausted(&seq->lcs_space)) {
+	if (lu_seq_range_is_exhausted(&seq->lcs_space)) {
 		rc = seq_client_alloc_meta(env, seq);
 		if (rc) {
 			CERROR("%s: Can't allocate new meta-sequence, rc %d\n",
@@ -181,7 +181,7 @@ static int seq_client_alloc_seq(const struct lu_env *env,
 		rc = 0;
 	}
 
-	LASSERT(!range_is_exhausted(&seq->lcs_space));
+	LASSERT(!lu_seq_range_is_exhausted(&seq->lcs_space));
 	*seqnr = seq->lcs_space.lsr_start;
 	seq->lcs_space.lsr_start += 1;
 
@@ -316,7 +316,7 @@ void seq_client_flush(struct lu_client_seq *seq)
 
 	seq->lcs_space.lsr_index = -1;
 
-	range_init(&seq->lcs_space);
+	lu_seq_range_init(&seq->lcs_space);
 	mutex_unlock(&seq->lcs_mutex);
 }
 EXPORT_SYMBOL(seq_client_flush);
diff --git a/drivers/staging/lustre/lustre/fid/lproc_fid.c b/drivers/staging/lustre/lustre/fid/lproc_fid.c
index 3ed32d7..97d4849 100644
--- a/drivers/staging/lustre/lustre/fid/lproc_fid.c
+++ b/drivers/staging/lustre/lustre/fid/lproc_fid.c
@@ -83,7 +83,7 @@
 		    (unsigned long long *)&tmp.lsr_end);
 	if (rc != 2)
 		return -EINVAL;
-	if (!range_is_sane(&tmp) || range_is_zero(&tmp) ||
+	if (!lu_seq_range_is_sane(&tmp) || lu_seq_range_is_zero(&tmp) ||
 	    tmp.lsr_start < range->lsr_start || tmp.lsr_end > range->lsr_end)
 		return -EINVAL;
 	*range = tmp;
diff --git a/drivers/staging/lustre/lustre/fld/fld_cache.c b/drivers/staging/lustre/lustre/fld/fld_cache.c
index 0100a93..11f6974 100644
--- a/drivers/staging/lustre/lustre/fld/fld_cache.c
+++ b/drivers/staging/lustre/lustre/fld/fld_cache.c
@@ -143,7 +143,7 @@ static void fld_fix_new_list(struct fld_cache *cache)
 		c_range = &f_curr->fce_range;
 		n_range = &f_next->fce_range;
 
-		LASSERT(range_is_sane(c_range));
+		LASSERT(lu_seq_range_is_sane(c_range));
 		if (&f_next->fce_list == head)
 			break;
 
@@ -358,7 +358,7 @@ struct fld_cache_entry
 {
 	struct fld_cache_entry *f_new;
 
-	LASSERT(range_is_sane(range));
+	LASSERT(lu_seq_range_is_sane(range));
 
 	f_new = kzalloc(sizeof(*f_new), GFP_NOFS);
 	if (!f_new)
@@ -503,7 +503,7 @@ int fld_cache_lookup(struct fld_cache *cache,
 		}
 
 		prev = flde;
-		if (range_within(&flde->fce_range, seq)) {
+		if (lu_seq_range_within(&flde->fce_range, seq)) {
 			*range = flde->fce_range;
 
 			cache->fci_stat.fst_cache++;
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index e542ce6..6896c37 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -192,113 +192,6 @@ struct lu_seq_range_array {
 
 #define LU_SEQ_RANGE_MASK	0x3
 
-static inline unsigned fld_range_type(const struct lu_seq_range *range)
-{
-	return range->lsr_flags & LU_SEQ_RANGE_MASK;
-}
-
-static inline bool fld_range_is_ost(const struct lu_seq_range *range)
-{
-	return fld_range_type(range) == LU_SEQ_RANGE_OST;
-}
-
-static inline bool fld_range_is_mdt(const struct lu_seq_range *range)
-{
-	return fld_range_type(range) == LU_SEQ_RANGE_MDT;
-}
-
-/**
- * This all range is only being used when fld client sends fld query request,
- * but it does not know whether the seq is MDT or OST, so it will send req
- * with ALL type, which means either seq type gotten from lookup can be
- * expected.
- */
-static inline unsigned fld_range_is_any(const struct lu_seq_range *range)
-{
-	return fld_range_type(range) == LU_SEQ_RANGE_ANY;
-}
-
-static inline void fld_range_set_type(struct lu_seq_range *range,
-				      unsigned flags)
-{
-	range->lsr_flags |= flags;
-}
-
-static inline void fld_range_set_mdt(struct lu_seq_range *range)
-{
-	fld_range_set_type(range, LU_SEQ_RANGE_MDT);
-}
-
-static inline void fld_range_set_ost(struct lu_seq_range *range)
-{
-	fld_range_set_type(range, LU_SEQ_RANGE_OST);
-}
-
-static inline void fld_range_set_any(struct lu_seq_range *range)
-{
-	fld_range_set_type(range, LU_SEQ_RANGE_ANY);
-}
-
-/**
- * returns  width of given range \a r
- */
-
-static inline __u64 range_space(const struct lu_seq_range *range)
-{
-	return range->lsr_end - range->lsr_start;
-}
-
-/**
- * initialize range to zero
- */
-
-static inline void range_init(struct lu_seq_range *range)
-{
-	memset(range, 0, sizeof(*range));
-}
-
-/**
- * check if given seq id \a s is within given range \a r
- */
-
-static inline bool range_within(const struct lu_seq_range *range,
-				__u64 s)
-{
-	return s >= range->lsr_start && s < range->lsr_end;
-}
-
-static inline bool range_is_sane(const struct lu_seq_range *range)
-{
-	return (range->lsr_end >= range->lsr_start);
-}
-
-static inline bool range_is_zero(const struct lu_seq_range *range)
-{
-	return (range->lsr_start == 0 && range->lsr_end == 0);
-}
-
-static inline bool range_is_exhausted(const struct lu_seq_range *range)
-
-{
-	return range_space(range) == 0;
-}
-
-/* return 0 if two range have the same location */
-static inline int range_compare_loc(const struct lu_seq_range *r1,
-				    const struct lu_seq_range *r2)
-{
-	return r1->lsr_index != r2->lsr_index ||
-	       r1->lsr_flags != r2->lsr_flags;
-}
-
-#define DRANGE "[%#16.16Lx-%#16.16Lx):%x:%s"
-
-#define PRANGE(range)		\
-	(range)->lsr_start,	\
-	(range)->lsr_end,	\
-	(range)->lsr_index,	\
-	fld_range_is_mdt(range) ? "mdt" : "ost"
-
 /** \defgroup lu_fid lu_fid
  * @{
  */
@@ -848,7 +741,6 @@ static inline bool fid_is_sane(const struct lu_fid *fid)
 }
 
 void lustre_swab_lu_fid(struct lu_fid *fid);
-void lustre_swab_lu_seq_range(struct lu_seq_range *range);
 
 static inline bool lu_fid_eq(const struct lu_fid *f0, const struct lu_fid *f1)
 {
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index 3167806..b5a1aad 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -150,6 +150,7 @@
 
 #include "../../include/linux/libcfs/libcfs.h"
 #include "lustre/lustre_idl.h"
+#include "seq_range.h"
 
 struct lu_env;
 struct lu_site;
diff --git a/drivers/staging/lustre/lustre/include/seq_range.h b/drivers/staging/lustre/lustre/include/seq_range.h
new file mode 100644
index 0000000..30c4dd6
--- /dev/null
+++ b/drivers/staging/lustre/lustre/include/seq_range.h
@@ -0,0 +1,199 @@
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
+ * Define lu_seq_range  associated functions
+ */
+
+#ifndef _SEQ_RANGE_H_
+#define _SEQ_RANGE_H_
+
+#include "lustre/lustre_idl.h"
+
+/**
+ * computes the sequence range type \a range
+ */
+
+static inline unsigned int fld_range_type(const struct lu_seq_range *range)
+{
+	return range->lsr_flags & LU_SEQ_RANGE_MASK;
+}
+
+/**
+ *  Is this sequence range an OST? \a range
+ */
+
+static inline bool fld_range_is_ost(const struct lu_seq_range *range)
+{
+	return fld_range_type(range) == LU_SEQ_RANGE_OST;
+}
+
+/**
+ *  Is this sequence range an MDT? \a range
+ */
+
+static inline bool fld_range_is_mdt(const struct lu_seq_range *range)
+{
+	return fld_range_type(range) == LU_SEQ_RANGE_MDT;
+}
+
+/**
+ * ANY range is only used when the fld client sends a fld query request,
+ * but it does not know whether the seq is an MDT or OST, so it will send the
+ * request with ANY type, which means any seq type from the lookup can be
+ * expected. /a range
+ */
+static inline unsigned int fld_range_is_any(const struct lu_seq_range *range)
+{
+	return fld_range_type(range) == LU_SEQ_RANGE_ANY;
+}
+
+/**
+ * Apply flags to range \a range \a flags
+ */
+
+static inline void fld_range_set_type(struct lu_seq_range *range,
+				      unsigned int flags)
+{
+	range->lsr_flags |= flags;
+}
+
+/**
+ * Add MDT to range type \a range
+ */
+
+static inline void fld_range_set_mdt(struct lu_seq_range *range)
+{
+	fld_range_set_type(range, LU_SEQ_RANGE_MDT);
+}
+
+/**
+ * Add OST to range type \a range
+ */
+
+static inline void fld_range_set_ost(struct lu_seq_range *range)
+{
+	fld_range_set_type(range, LU_SEQ_RANGE_OST);
+}
+
+/**
+ * Add ANY to range type \a range
+ */
+
+static inline void fld_range_set_any(struct lu_seq_range *range)
+{
+	fld_range_set_type(range, LU_SEQ_RANGE_ANY);
+}
+
+/**
+ * computes width of given sequence range \a range
+ */
+
+static inline u64 lu_seq_range_space(const struct lu_seq_range *range)
+{
+	return range->lsr_end - range->lsr_start;
+}
+
+/**
+ * initialize range to zero \a range
+ */
+
+static inline void lu_seq_range_init(struct lu_seq_range *range)
+{
+	memset(range, 0, sizeof(*range));
+}
+
+/**
+ * check if given seq id \a s is within given range \a range
+ */
+
+static inline bool lu_seq_range_within(const struct lu_seq_range *range,
+				       u64 seq)
+{
+	return seq >= range->lsr_start && seq < range->lsr_end;
+}
+
+/**
+ * Is the range sane?  Is the end after the beginning? \a range
+ */
+
+static inline bool lu_seq_range_is_sane(const struct lu_seq_range *range)
+{
+	return range->lsr_end >= range->lsr_start;
+}
+
+/**
+ * Is the range 0? \a range
+ */
+
+static inline bool lu_seq_range_is_zero(const struct lu_seq_range *range)
+{
+	return range->lsr_start == 0 && range->lsr_end == 0;
+}
+
+/**
+ * Is the range out of space? \a range
+ */
+
+static inline bool lu_seq_range_is_exhausted(const struct lu_seq_range *range)
+{
+	return lu_seq_range_space(range) == 0;
+}
+
+/**
+ * return 0 if two ranges have the same location, nonzero if they are
+ * different \a r1 \a r2
+ */
+
+static inline int lu_seq_range_compare_loc(const struct lu_seq_range *r1,
+					   const struct lu_seq_range *r2)
+{
+	return r1->lsr_index != r2->lsr_index ||
+		r1->lsr_flags != r2->lsr_flags;
+}
+
+#if !defined(__REQ_LAYOUT_USER__)
+/**
+ * byte swap range structure \a range
+ */
+
+void lustre_swab_lu_seq_range(struct lu_seq_range *range);
+#endif
+/**
+ * printf string and argument list for sequence range
+ */
+#define DRANGE "[%#16.16llx-%#16.16llx]:%x:%s"
+
+#define PRANGE(range)		\
+	(range)->lsr_start,	\
+	(range)->lsr_end,	\
+	(range)->lsr_index,	\
+	fld_range_is_mdt(range) ? "mdt" : "ost"
+
+#endif
-- 
1.7.1
