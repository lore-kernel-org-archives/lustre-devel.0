Return-Path: <SRS0=GtYW=HL=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFD85C433DB
	for <lustre-devel@archiver.kernel.org>; Tue,  9 Feb 2021 00:54:40 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0FFDC64E77
	for <lustre-devel@archiver.kernel.org>; Tue,  9 Feb 2021 00:54:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FFDC64E77
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 19CBD30F8DE;
	Mon,  8 Feb 2021 16:54:38 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E68BB30F758
 for <lustre-devel@lists.lustre.org>; Mon,  8 Feb 2021 16:54:30 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id EB9171006EB9;
 Mon,  8 Feb 2021 19:54:28 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E560F4CC35; Mon,  8 Feb 2021 19:54:28 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Feb 2021 19:54:20 -0500
Message-Id: <1612832067-1449-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1612832067-1449-1-git-send-email-jsimmons@infradead.org>
References: <1612832067-1449-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 2/9] lustre: flr: skip unknown FLR component
 types
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Qian Yingjin <qian@ddn.com>

Currently, in lov_init_composite() it will quit with error when
reading an unknown LOV pattern.
Since FLR will be used for upcoming new features, like PCC-RO,
an old client should be able to read the old format of the
component types, ignore and skip the new types of FLR component.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13602
Lustre-commit: 61a002cd8631ecd ("LU-13602 flr: skip unknown FLR component types")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/39513
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_cl_internal.h         |  7 +++-
 fs/lustre/lov/lov_ea.c                  | 66 +++++++++++++++++++++++++--------
 fs/lustre/lov/lov_internal.h            | 15 +++++++-
 fs/lustre/lov/lov_io.c                  | 14 ++++++-
 fs/lustre/lov/lov_object.c              | 22 ++++++++++-
 include/uapi/linux/lustre/lustre_user.h |  1 +
 6 files changed, 102 insertions(+), 23 deletions(-)

diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index f86176a..e9ef5aa 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -151,7 +151,8 @@ static inline char *llt2str(enum lov_layout_type llt)
 static inline u32 lov_entry_type(struct lov_stripe_md_entry *lsme)
 {
 	if ((lov_pattern(lsme->lsme_pattern) & LOV_PATTERN_RAID0) ||
-	    (lov_pattern(lsme->lsme_pattern) == LOV_PATTERN_MDT))
+	    (lov_pattern(lsme->lsme_pattern) == LOV_PATTERN_MDT) ||
+	    (lov_pattern(lsme->lsme_pattern) == LOV_PATTERN_FOREIGN))
 		return lov_pattern(lsme->lsme_pattern &
 				   ~LOV_PATTERN_OVERSTRIPING);
 	return 0;
@@ -239,9 +240,11 @@ struct lov_mirror_entry {
 	unsigned short	lre_mirror_id;
 	unsigned short	lre_preferred:1,
 			lre_stale:1,	/* set if any components is stale */
-			lre_valid:1;	/* set if at least one of components
+			lre_valid:1,	/* set if at least one of components
 					 * in this mirror is valid
 					 */
+			lre_foreign:1;	/* set if it is a foreign component */
+
 	unsigned short	lre_start;	/* index to lo_entries, start index of
 					 * this mirror
 					 */
diff --git a/fs/lustre/lov/lov_ea.c b/fs/lustre/lov/lov_ea.c
index 13f47ee..75a19a4 100644
--- a/fs/lustre/lov/lov_ea.c
+++ b/fs/lustre/lov/lov_ea.c
@@ -125,9 +125,22 @@ static int lsm_lmm_verify_v1v3(struct lov_mds_md *lmm, size_t lmm_size,
 
 static void lsme_free(struct lov_stripe_md_entry *lsme)
 {
-	unsigned int stripe_count = lsme->lsme_stripe_count;
+	unsigned int stripe_count;
 	unsigned int i;
 
+	if (lsme->lsme_magic == LOV_MAGIC_FOREIGN) {
+		/*
+		 * TODO: In addition to HSM foreign layout, It needs to add
+		 * support for other kinds of foreign layout types such as
+		 * DAOS, S3. When add these supports, it will use non-inline
+		 * @lov_hsm_base to store layout information, and need to
+		 * free extra allocated buffer.
+		 */
+		kvfree(lsme);
+		return;
+	}
+
+	stripe_count = lsme->lsme_stripe_count;
 	if (!lsme_inited(lsme) ||
 	    lsme->lsme_pattern & LOV_PATTERN_F_RELEASED)
 		stripe_count = 0;
@@ -183,8 +196,7 @@ void lsm_free(struct lov_stripe_md *lsm)
 	else
 		stripe_count = le16_to_cpu(lmm->lmm_stripe_count);
 
-	if (buf_size < (magic == LOV_MAGIC_V1 ? sizeof(struct lov_mds_md_v1) :
-						sizeof(struct lov_mds_md_v3))) {
+	if (buf_size < lov_mds_md_size(stripe_count, magic)) {
 		CERROR("LOV EA %s too small: %zu, need %u\n",
 		       magic == LOV_MAGIC_V1 ? "V1" : "V3", buf_size,
 		       lov_mds_md_size(stripe_count, magic == LOV_MAGIC_V1 ?
@@ -407,36 +419,58 @@ static int lsm_verify_comp_md_v1(struct lov_comp_md_v1 *lcm,
 }
 
 static struct lov_stripe_md_entry *
-lsme_unpack_comp(struct lov_obd *lov, struct lov_mds_md *lmm,
-		 size_t lmm_buf_size, bool inited, loff_t *maxbytes)
+lsme_unpack_foreign(struct lov_obd *lov, void *buf, size_t buf_size,
+		    bool inited, loff_t *maxbytes)
 {
-	unsigned int stripe_count;
-	unsigned int magic;
+	struct lov_stripe_md_entry *lsme;
+	struct lov_foreign_md *lfm = buf;
+	u32 magic;
 
-	stripe_count = le16_to_cpu(lmm->lmm_stripe_count);
-	if (stripe_count == 0 &&
-	    lov_pattern(le32_to_cpu(lmm->lmm_pattern)) != LOV_PATTERN_MDT)
+	magic = le32_to_cpu(lfm->lfm_magic);
+	if (magic != LOV_MAGIC_FOREIGN)
 		return ERR_PTR(-EINVAL);
 
-	/* un-instantiated lmm contains no ost id info, i.e. lov_ost_data_v1 */
-	if (!inited)
-		stripe_count = 0;
+	lsme = kvzalloc(sizeof(*lsme), GFP_NOFS);
+	if (!lsme)
+		return ERR_PTR(-ENOMEM);
+
+	lsme->lsme_magic = magic;
+	lsme->lsme_pattern = LOV_PATTERN_FOREIGN;
+	lsme->lsme_flags = 0;
+
+	if (maxbytes)
+		*maxbytes = MAX_LFS_FILESIZE;
+
+	return lsme;
+}
+
+static struct lov_stripe_md_entry *
+lsme_unpack_comp(struct lov_obd *lov, struct lov_mds_md *lmm,
+		 size_t lmm_buf_size, bool inited, loff_t *maxbytes)
+{
+	unsigned int magic;
 
 	magic = le32_to_cpu(lmm->lmm_magic);
-	if (magic != LOV_MAGIC_V1 && magic != LOV_MAGIC_V3)
+	if (magic != LOV_MAGIC_V1 && magic != LOV_MAGIC_V3 &&
+	    magic != LOV_MAGIC_FOREIGN)
 		return ERR_PTR(-EINVAL);
 
-	if (lmm_buf_size < lov_mds_md_size(stripe_count, magic))
+	if (magic != LOV_MAGIC_FOREIGN &&
+	    le16_to_cpu(lmm->lmm_stripe_count) == 0 &&
+	    lov_pattern(le32_to_cpu(lmm->lmm_pattern)) != LOV_PATTERN_MDT)
 		return ERR_PTR(-EINVAL);
 
 	if (magic == LOV_MAGIC_V1) {
 		return lsme_unpack(lov, lmm, lmm_buf_size, NULL,
 				   inited, lmm->lmm_objects, maxbytes);
-	} else {
+	} else if (magic == LOV_MAGIC_V3) {
 		struct lov_mds_md_v3 *lmm3 = (struct lov_mds_md_v3 *)lmm;
 
 		return lsme_unpack(lov, lmm, lmm_buf_size, lmm3->lmm_pool_name,
 				   inited, lmm3->lmm_objects, maxbytes);
+	} else { /* LOV_MAGIC_FOREIGN */
+		return lsme_unpack_foreign(lov, lmm, lmm_buf_size,
+					   inited, maxbytes);
 	}
 }
 
diff --git a/fs/lustre/lov/lov_internal.h b/fs/lustre/lov/lov_internal.h
index 5d726fd..81adce4 100644
--- a/fs/lustre/lov/lov_internal.h
+++ b/fs/lustre/lov/lov_internal.h
@@ -100,6 +100,17 @@ struct lov_stripe_md {
 
 #define lsm_foreign(lsm) (lsm->lsm_entries[0])
 
+static inline bool lsme_is_foreign(const struct lov_stripe_md_entry *lsme)
+{
+	return lsme->lsme_magic == LOV_MAGIC_FOREIGN;
+}
+
+static inline bool lsm_entry_is_foreign(const struct lov_stripe_md *lsm,
+					int index)
+{
+	return lsme_is_foreign(lsm->lsm_entries[index]);
+}
+
 static inline bool lsme_inited(const struct lov_stripe_md_entry *lsme)
 {
 	return lsme->lsme_flags & LCME_FL_INIT;
@@ -130,7 +141,8 @@ static inline size_t lov_comp_md_size(const struct lov_stripe_md *lsm)
 
 	LASSERT(lsm->lsm_magic == LOV_MAGIC_COMP_V1);
 
-	size = sizeof(struct lov_comp_md_v1);
+	size = sizeof(struct lov_comp_md_v1) +
+	       sizeof(struct lov_comp_md_entry_v1) * lsm->lsm_entry_count;
 	for (entry = 0; entry < lsm->lsm_entry_count; entry++) {
 		u16 stripe_count;
 
@@ -141,7 +153,6 @@ static inline size_t lov_comp_md_size(const struct lov_stripe_md *lsm)
 		else
 			stripe_count = 0;
 
-		size += sizeof(*lsme);
 		size += lov_mds_md_size(stripe_count,
 					lsme->lsme_magic);
 	}
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index daceab0..c9600bc 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -398,6 +398,9 @@ static int lov_io_mirror_init(struct lov_io *lio, struct lov_object *obj,
 		if (!lre->lre_valid)
 			continue;
 
+		if (lre->lre_foreign)
+			continue;
+
 		lov_foreach_mirror_layout_entry(obj, lle, lre) {
 			if (!lle->lle_valid)
 				continue;
@@ -802,6 +805,9 @@ static int lov_io_iter_init(const struct lu_env *env,
 			continue;
 		}
 
+		if (lsm_entry_is_foreign(lsm, index))
+			continue;
+
 		if (!le->lle_valid && !ios->cis_io->ci_designated_mirror) {
 			CERROR("I/O to invalid component: %d, mirror: %d\n",
 			       index, lio->lis_mirror_index);
@@ -931,6 +937,9 @@ static int lov_io_rw_iter_init(const struct lu_env *env,
 
 	lse = lov_lse(lio->lis_object, index);
 
+	if (lsme_is_foreign(lse))
+		return -EINVAL;
+
 	next = MAX_LFS_FILESIZE;
 	if (lse->lsme_stripe_count > 1) {
 		unsigned long ssize = lse->lsme_stripe_size;
@@ -1107,7 +1116,8 @@ static int lov_io_read_ahead(const struct lu_env *env,
 
 	offset = cl_offset(obj, start);
 	index = lov_io_layout_at(lio, offset);
-	if (index < 0 || !lsm_entry_inited(loo->lo_lsm, index))
+	if (index < 0 || !lsm_entry_inited(loo->lo_lsm, index) ||
+	    lsm_entry_is_foreign(loo->lo_lsm, index))
 		return -ENODATA;
 
 	/* avoid readahead to expand to stale components */
@@ -1760,6 +1770,8 @@ int lov_io_layout_at(struct lov_io *lio, u64 offset)
 	for (i = start_index; i <= end_index; i++) {
 		struct lov_layout_entry *lle = lov_entry(lov, i);
 
+		LASSERT(!lsme_is_foreign(lle->lle_lsme));
+
 		if ((offset >= lle->lle_extent->e_start &&
 		     offset < lle->lle_extent->e_end) ||
 		    (offset == OBD_OBJECT_EOF &&
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index d9729c8..5d0e257 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -681,6 +681,9 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 			}
 			lle->lle_comp_ops = &dom_ops;
 			break;
+		case LOV_PATTERN_FOREIGN:
+			lle->lle_comp_ops = NULL;
+			break;
 		default:
 			CERROR("%s: unknown composite layout entry type %i\n",
 			       lov2obd(dev->ld_lov)->obd_name,
@@ -700,6 +703,8 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 			if (mirror_id == lre->lre_mirror_id) {
 				lre->lre_valid |= lle->lle_valid;
 				lre->lre_stale |= !lle->lle_valid;
+				lre->lre_foreign |=
+					lsme_is_foreign(lle->lle_lsme);
 				lre->lre_end = i;
 				continue;
 			}
@@ -722,6 +727,7 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 					LCME_FL_PREF_RD);
 		lre->lre_valid = lle->lle_valid;
 		lre->lre_stale = !lle->lle_valid;
+		lre->lre_foreign = lsme_is_foreign(lle->lle_lsme);
 	}
 
 	/* sanity check for FLR */
@@ -746,6 +752,9 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 		if (!lsme_inited(lle->lle_lsme))
 			continue;
 
+		if (lsme_is_foreign(lle->lle_lsme))
+			continue;
+
 		result = lle->lle_comp_ops->lco_init(env, dev, lov, index,
 						     conf, lle);
 		if (result < 0)
@@ -771,6 +780,9 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 		if (lre->lre_stale)
 			continue;
 
+		if (lre->lre_foreign)
+			continue;
+
 		mirror_count++; /* valid mirror */
 
 		if (lre->lre_preferred || comp->lo_preferred_mirror < 0)
@@ -847,8 +859,12 @@ static int lov_delete_composite(const struct lu_env *env,
 
 	lov_layout_wait(env, lov);
 	if (comp->lo_entries)
-		lov_foreach_layout_entry(lov, entry)
+		lov_foreach_layout_entry(lov, entry) {
+			if (lsme_is_foreign(entry->lle_lsme))
+				continue;
+
 			lov_delete_raid0(env, lov, entry);
+		}
 
 	return 0;
 }
@@ -921,7 +937,9 @@ static int lov_print_composite(const struct lu_env *env, void *cookie,
 		     lse->lsme_id, lse->lsme_pattern, lse->lsme_layout_gen,
 		     lse->lsme_flags, lse->lsme_stripe_count,
 		     lse->lsme_stripe_size);
-		lov_print_raid0(env, cookie, p, lle);
+
+		if (!lsme_is_foreign(lse))
+			lov_print_raid0(env, cookie, p, lle);
 	}
 
 	return 0;
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 835ffce..0f195a4 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -422,6 +422,7 @@ struct ll_ioc_lease_id {
 #define LOV_PATTERN_RAID1		0x002
 #define LOV_PATTERN_MDT			0x100
 #define LOV_PATTERN_OVERSTRIPING	0x200
+#define LOV_PATTERN_FOREIGN		0x400
 
 #define LOV_PATTERN_F_MASK	0xffff0000
 #define LOV_PATTERN_F_HOLE	0x40000000 /* there is hole in LOV EA */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
