Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 99511C433F5
	for <lustre-devel@archiver.kernel.org>; Tue, 19 Apr 2022 00:31:13 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4FC4E42737B;
	Mon, 18 Apr 2022 17:31:11 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1D5A0425525
 for <lustre-devel@lists.lustre.org>; Mon, 18 Apr 2022 17:31:08 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 2CEC510058E3;
 Mon, 18 Apr 2022 20:31:06 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 21382DA287; Mon, 18 Apr 2022 20:31:06 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 18 Apr 2022 20:31:00 -0400
Message-Id: <1650328264-8763-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1650328264-8763-1-git-send-email-jsimmons@infradead.org>
References: <1650328264-8763-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 3/7] lustre: lov: remove lo_trunc_stripeno
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

From: "John L. Hammond" <jhammond@whamcloud.com>

Remove the lo_trunc_stripeno member of struct lov_layout_raid0 and add
an lis_trunc_stripe_index array to struct lov_io. This makes the
truncate stripe index information belong to the IO and not to the
concurrently accessed object. This is needed because we do not have
locking that protects it from its initialization in lov_io_iter_init()
to its use in lov_lock_sub_init(). Also remove the unused
lo_write_lock member of struct lov_object.

Fixes: d83ed47d35 ("lustre: lov: correctly set OST obj size")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15702
Lustre-commit: 42a6d1fdb6818f1b3 ("LU-15702 lov: remove lo_trunc_stripeno")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/46940
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_cl_internal.h | 17 +++++++----------
 fs/lustre/lov/lov_io.c          | 40 ++++++++++++++++++++++++++++------------
 fs/lustre/lov/lov_lock.c        | 35 +++++++++++++++++++----------------
 fs/lustre/lov/lov_object.c      |  2 --
 4 files changed, 54 insertions(+), 40 deletions(-)

diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index 42fd10a..6b96543 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -175,11 +175,6 @@ struct lov_comp_layout_entry_ops {
 struct lov_layout_raid0 {
 	unsigned int		lo_nr;
 	/**
-	 * record the stripe no before the truncate size, used for setting OST
-	 * object size for truncate. LU-14128.
-	 */
-	int			lo_trunc_stripeno;
-	/**
 	 * When this is true, lov_object::lo_attr contains
 	 * valid up to date attributes for a top-level
 	 * object. This field is reset to 0 when attributes of
@@ -325,11 +320,6 @@ struct lov_object {
 			 */
 			int		lo_preferred_mirror;
 			/**
-			 * For FLR: the lock to protect access to
-			 * lo_preferred_mirror.
-			 */
-			spinlock_t	lo_write_lock;
-			/**
 			 * For FLR: Number of (valid) mirrors.
 			 */
 			unsigned int	lo_mirror_count;
@@ -562,6 +552,13 @@ struct lov_io {
 	loff_t			lis_io_endpos;
 
 	/**
+	 * Record the stripe index before the truncate size, used for setting
+	 * OST object size for truncate. LU-14128. lis_trunc_stripe_index[i]
+	 * refers to lov_object.u.composite.lo_entries[i].
+	 */
+	int *lis_trunc_stripe_index;
+
+	/**
 	 * starting position within a file, for the current io loop iteration
 	 * (stripe), used by ci_io_loop().
 	 */
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 904bafd..38dacd35 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -782,6 +782,7 @@ static int lov_io_iter_init(const struct lu_env *env,
 {
 	struct lov_io *lio = cl2lov_io(env, ios);
 	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
+	bool is_trunc = cl_io_is_trunc(ios->cis_io);
 	struct lov_io_sub *sub;
 	struct lu_extent ext;
 	int rc = 0;
@@ -790,6 +791,16 @@ static int lov_io_iter_init(const struct lu_env *env,
 	ext.e_start = lio->lis_pos;
 	ext.e_end = lio->lis_endpos;
 
+	if (is_trunc) {
+		int count = lio->lis_object->u.composite.lo_entry_count;
+
+		lio->lis_trunc_stripe_index = kcalloc(count,
+						      sizeof(lio->lis_trunc_stripe_index[0]),
+						      GFP_NOFS);
+		if (!lio->lis_trunc_stripe_index)
+			return -ENOMEM;
+	}
+
 	lov_foreach_io_layout(index, lio, &ext) {
 		struct lov_layout_entry *le = lov_entry(lio->lis_object, index);
 		struct lov_layout_raid0 *r0 = &le->lle_raid0;
@@ -798,7 +809,8 @@ static int lov_io_iter_init(const struct lu_env *env,
 		u64 start;
 		u64 end;
 
-		r0->lo_trunc_stripeno = -1;
+		if (is_trunc)
+			lio->lis_trunc_stripe_index[index] = -1;
 
 		CDEBUG(D_VFSTRACE, "component[%d] flags %#x\n",
 		       index, lsm->lsm_entries[index]->lsme_flags);
@@ -832,8 +844,7 @@ static int lov_io_iter_init(const struct lu_env *env,
 				continue;
 			}
 
-			if (cl_io_is_trunc(ios->cis_io) &&
-			    !tested_trunc_stripe) {
+			if (is_trunc && !tested_trunc_stripe) {
 				int prev;
 				u64 tr_start;
 
@@ -848,20 +859,22 @@ static int lov_io_iter_init(const struct lu_env *env,
 				if (ext.e_start <
 				    lsm->lsm_entries[index]->lsme_extent.e_start) {
 					/* need previous stripe involvement */
-					r0->lo_trunc_stripeno = prev;
+					lio->lis_trunc_stripe_index[index] = prev;
 				} else {
 					tr_start = ext.e_start;
 					tr_start = lov_do_div64(tr_start,
 								stripe_width(lsm, index));
 					/* tr_start %= stripe_swidth */
-					if (tr_start == stripe * lsm->lsm_entries[index]->lsme_stripe_size)
-						r0->lo_trunc_stripeno = prev;
+					if (tr_start ==
+					    stripe * lsm->lsm_entries[index]->lsme_stripe_size)
+						lio->lis_trunc_stripe_index[index] = prev;
 				}
 			}
 
 			/* if the last stripe is the trunc stripeno */
-			if (r0->lo_trunc_stripeno == stripe)
-				r0->lo_trunc_stripeno = -1;
+			if (is_trunc &&
+			    lio->lis_trunc_stripe_index[index] == stripe)
+				lio->lis_trunc_stripe_index[index] = -1;
 
 			sub = lov_sub_get(env, lio,
 					  lov_comp_index(index, stripe));
@@ -875,10 +888,10 @@ static int lov_io_iter_init(const struct lu_env *env,
 		if (rc != 0)
 			break;
 
-		if (r0->lo_trunc_stripeno != -1) {
-			stripe = r0->lo_trunc_stripeno;
+		if (is_trunc && lio->lis_trunc_stripe_index[index] != -1) {
+			stripe = lio->lis_trunc_stripe_index[index];
 			if (unlikely(!r0->lo_sub[stripe])) {
-				r0->lo_trunc_stripeno = -1;
+				lio->lis_trunc_stripe_index[index] = -1;
 				continue;
 			}
 			sub = lov_sub_get(env, lio,
@@ -892,7 +905,7 @@ static int lov_io_iter_init(const struct lu_env *env,
 			 * read get wrong kms.
 			 */
 			if (!list_empty(&sub->sub_linkage)) {
-				r0->lo_trunc_stripeno = -1;
+				lio->lis_trunc_stripe_index[index] = -1;
 				continue;
 			}
 
@@ -1091,6 +1104,9 @@ static void lov_io_iter_fini(const struct lu_env *env,
 	struct lov_io *lio = cl2lov_io(env, ios);
 	int rc;
 
+	kfree(lio->lis_trunc_stripe_index);
+	lio->lis_trunc_stripe_index = NULL;
+
 	rc = lov_io_call(env, lio, lov_io_iter_fini_wrapper);
 	LASSERT(rc == 0);
 	while (!list_empty(&lio->lis_active))
diff --git a/fs/lustre/lov/lov_lock.c b/fs/lustre/lov/lov_lock.c
index d137614..313c09a 100644
--- a/fs/lustre/lov/lov_lock.c
+++ b/fs/lustre/lov/lov_lock.c
@@ -115,6 +115,8 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 					  struct cl_lock *lock)
 {
 	struct lov_object *lov = cl2lov(obj);
+	struct lov_io *lio = lov_env_io(env);
+	bool is_trunc = cl_io_is_trunc(io);
 	struct lov_lock *lovlck;
 	struct lu_extent ext;
 	int result = 0;
@@ -124,6 +126,8 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 	u64 start;
 	u64 end;
 
+	LASSERT(ergo(is_trunc, lio->lis_trunc_stripe_index != NULL));
+
 	ext.e_start = cl_offset(obj, lock->cll_descr.cld_start);
 	if (lock->cll_descr.cld_end == CL_PAGE_EOF)
 		ext.e_end = OBD_OBJECT_EOF;
@@ -131,16 +135,16 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 		ext.e_end = cl_offset(obj, lock->cll_descr.cld_end + 1);
 
 	nr = 0;
-	lov_foreach_io_layout(index, lov_env_io(env), &ext) {
+	lov_foreach_io_layout(index, lio, &ext) {
 		struct lov_layout_raid0 *r0 = lov_r0(lov, index);
 
 		for (i = 0; i < r0->lo_nr; i++) {
 			if (likely(r0->lo_sub[i])) { /* spare layout */
-				if (lov_stripe_intersects(lov->lo_lsm, index, i,
-							  &ext, &start, &end))
-					nr++;
-				else if (cl_io_is_trunc(io) &&
-					 r0->lo_trunc_stripeno == i)
+				if (lov_stripe_intersects(lov->lo_lsm, index,
+							  i, &ext, &start,
+							  &end) ||
+				    (is_trunc &&
+				     i == lio->lis_trunc_stripe_index[index]))
 					nr++;
 			}
 		}
@@ -162,24 +166,23 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 		struct lov_layout_raid0 *r0 = lov_r0(lov, index);
 
 		for (i = 0; i < r0->lo_nr; ++i) {
-			struct lov_lock_sub *lls = &lovlck->lls_sub[nr];
-			struct cl_lock_descr *descr = &lls->sub_lock.cll_descr;
-			bool intersect = false;
+			struct lov_lock_sub *lls;
+			struct cl_lock_descr *descr;
 
 			if (unlikely(!r0->lo_sub[i]))
 				continue;
 
-			intersect = lov_stripe_intersects(lov->lo_lsm, index, i,
-							  &ext, &start, &end);
-			if (intersect)
-				goto init_sublock;
-
-			if (cl_io_is_trunc(io) && i == r0->lo_trunc_stripeno)
+			if (lov_stripe_intersects(lov->lo_lsm, index, i, &ext,
+						  &start, &end) ||
+			    (is_trunc &&
+			     i == lio->lis_trunc_stripe_index[index]))
 				goto init_sublock;
 
 			continue;
-
 init_sublock:
+			LASSERT(nr < lovlck->lls_nr);
+			lls = &lovlck->lls_sub[nr];
+			descr = &lls->sub_lock.cll_descr;
 			LASSERT(!descr->cld_obj);
 			descr->cld_obj = lovsub2cl(r0->lo_sub[i]);
 			descr->cld_start = cl_index(descr->cld_obj, start);
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index ff0f7fa..d9eaf15 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -214,7 +214,6 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 
 	spin_lock_init(&r0->lo_sub_lock);
 	r0->lo_nr = lse->lsme_stripe_count;
-	r0->lo_trunc_stripeno = -1;
 
 	flags = memalloc_nofs_save();
 	r0->lo_sub = kvmalloc_array(r0->lo_nr, sizeof(r0->lo_sub[0]),
@@ -641,7 +640,6 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 
 	entry_count = lsm->lsm_entry_count;
 
-	spin_lock_init(&comp->lo_write_lock);
 	comp->lo_flags = lsm->lsm_flags;
 	comp->lo_mirror_count = lsm->lsm_mirror_count + 1;
 	comp->lo_entry_count = lsm->lsm_entry_count;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
