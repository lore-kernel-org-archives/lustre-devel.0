Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AFC9C433DB
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:15 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A998523A5A
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A998523A5A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 86FF221FE70;
	Thu, 21 Jan 2021 09:17:47 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 617C721FCAD
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:16 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 91D151008496;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 909EF1B49B; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:17:01 -0500
Message-Id: <1611249422-556-39-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 38/39] lustre: lov: correctly set OST obj size
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

From: Bobi Jam <bobijam@whamcloud.com>

When extends a PFL file to a size locating at a boundary of a stripe
in a component, the truncate won't set the size of the OST object
in the prior stripe.

This patch record the prior stripe in
lov_layout_raid0::lo_trunc_stripeno and add the stripe in the
truncate IO and enqueue the lock covering it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14128
Lustre-commit: 98015004516cad ("LU-14128 lov: correctly set OST obj size")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40581
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_cl_internal.h |  5 +++
 fs/lustre/lov/lov_internal.h    |  1 +
 fs/lustre/lov/lov_io.c          | 97 +++++++++++++++++++++++++++++++++++------
 fs/lustre/lov/lov_lock.c        | 31 +++++++++----
 fs/lustre/lov/lov_object.c      |  1 +
 fs/lustre/lov/lov_offset.c      |  2 +-
 6 files changed, 114 insertions(+), 23 deletions(-)

diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index 7128224..f86176a 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -176,6 +176,11 @@ struct lov_comp_layout_entry_ops {
 struct lov_layout_raid0 {
 	unsigned int		lo_nr;
 	/**
+	 * record the stripe no before the truncate size, used for setting OST
+	 * object size for truncate. LU-14128.
+	 */
+	int			lo_trunc_stripeno;
+	/**
 	 * When this is true, lov_object::lo_attr contains
 	 * valid up to date attributes for a top-level
 	 * object. This field is reset to 0 when attributes of
diff --git a/fs/lustre/lov/lov_internal.h b/fs/lustre/lov/lov_internal.h
index 202e4b5..5d726fd 100644
--- a/fs/lustre/lov/lov_internal.h
+++ b/fs/lustre/lov/lov_internal.h
@@ -264,6 +264,7 @@ int lov_merge_lvb_kms(struct lov_stripe_md *lsm, int index,
 		      struct ost_lvb *lvb, u64 *kms_place);
 
 /* lov_offset.c */
+u64 stripe_width(struct lov_stripe_md *lsm, unsigned int index);
 u64 lov_stripe_size(struct lov_stripe_md *lsm, int index, u64 ost_size,
 		    int stripeno);
 int lov_stripe_offset(struct lov_stripe_md *lsm, int index, u64 lov_off,
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index d4a0c9d..daceab0 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -752,6 +752,24 @@ static u64 lov_offset_mod(u64 val, int delta)
 	return val;
 }
 
+static int lov_io_add_sub(const struct lu_env *env, struct lov_io *lio,
+			  struct lov_io_sub *sub, u64 start, u64 end)
+{
+	int rc;
+
+	end = lov_offset_mod(end, 1);
+	lov_io_sub_inherit(sub, lio, start, end);
+	rc = cl_io_iter_init(sub->sub_env, &sub->sub_io);
+	if (rc != 0) {
+		cl_io_iter_fini(sub->sub_env, &sub->sub_io);
+		return rc;
+	}
+
+	list_add_tail(&sub->sub_linkage, &lio->lis_active);
+
+	return rc;
+}
+
 static int lov_io_iter_init(const struct lu_env *env,
 			    const struct cl_io_slice *ios)
 {
@@ -768,10 +786,13 @@ static int lov_io_iter_init(const struct lu_env *env,
 	lov_foreach_io_layout(index, lio, &ext) {
 		struct lov_layout_entry *le = lov_entry(lio->lis_object, index);
 		struct lov_layout_raid0 *r0 = &le->lle_raid0;
+		bool tested_trunc_stripe = false;
 		int stripe;
 		u64 start;
 		u64 end;
 
+		r0->lo_trunc_stripeno = -1;
+
 		CDEBUG(D_VFSTRACE, "component[%d] flags %#x\n",
 		       index, lsm->lsm_entries[index]->lsme_flags);
 		if (!lsm_entry_inited(lsm, index)) {
@@ -801,28 +822,76 @@ static int lov_io_iter_init(const struct lu_env *env,
 				continue;
 			}
 
-			end = lov_offset_mod(end, 1);
+			if (cl_io_is_trunc(ios->cis_io) &&
+			    !tested_trunc_stripe) {
+				int prev;
+				u64 tr_start;
+
+				prev = (stripe == 0) ? r0->lo_nr - 1 :
+						       stripe - 1;
+				/**
+				 * Only involving previous stripe if the
+				 * truncate in this component is at the
+				 * beginning of this stripe.
+				 */
+				tested_trunc_stripe = true;
+				if (ext.e_start <
+				    lsm->lsm_entries[index]->lsme_extent.e_start) {
+					/* need previous stripe involvement */
+					r0->lo_trunc_stripeno = prev;
+				} else {
+					tr_start = ext.e_start;
+					tr_start = lov_do_div64(tr_start,
+								stripe_width(lsm, index));
+					/* tr_start %= stripe_swidth */
+					if (tr_start == stripe * lsm->lsm_entries[index]->lsme_stripe_size)
+						r0->lo_trunc_stripeno = prev;
+				}
+			}
+
+			/* if the last stripe is the trunc stripeno */
+			if (r0->lo_trunc_stripeno == stripe)
+				r0->lo_trunc_stripeno = -1;
+
 			sub = lov_sub_get(env, lio,
 					  lov_comp_index(index, stripe));
-			if (IS_ERR(sub)) {
-				rc = PTR_ERR(sub);
-				break;
-			}
+			if (IS_ERR(sub))
+				return PTR_ERR(sub);
 
-			lov_io_sub_inherit(sub, lio, start, end);
-			rc = cl_io_iter_init(sub->sub_env, &sub->sub_io);
-			if (rc) {
-				cl_io_iter_fini(sub->sub_env, &sub->sub_io);
+			rc = lov_io_add_sub(env, lio, sub, start, end);
+			if (rc)
 				break;
+		}
+		if (rc != 0)
+			break;
+
+		if (r0->lo_trunc_stripeno != -1) {
+			stripe = r0->lo_trunc_stripeno;
+			if (unlikely(!r0->lo_sub[stripe])) {
+				r0->lo_trunc_stripeno = -1;
+				continue;
 			}
+			sub = lov_sub_get(env, lio,
+					  lov_comp_index(index, stripe));
+			if (IS_ERR(sub))
+				return PTR_ERR(sub);
 
-			CDEBUG(D_VFSTRACE, "shrink: %d [%llu, %llu)\n",
-			       stripe, start, end);
+			/**
+			 * the prev sub could be used by another truncate, we'd
+			 * skip it. LU-14128 happends when expand truncate +
+			 * read get wrong kms.
+			 */
+			if (!list_empty(&sub->sub_linkage)) {
+				r0->lo_trunc_stripeno = -1;
+				continue;
+			}
 
-			list_add_tail(&sub->sub_linkage, &lio->lis_active);
+			(void)lov_stripe_intersects(lsm, index, stripe, &ext,
+						    &start, &end);
+			rc = lov_io_add_sub(env, lio, sub, start, end);
+			if (rc != 0)
+				break;
 		}
-		if (rc)
-			break;
 	}
 	return rc;
 }
diff --git a/fs/lustre/lov/lov_lock.c b/fs/lustre/lov/lov_lock.c
index 7dae13f..c79f728 100644
--- a/fs/lustre/lov/lov_lock.c
+++ b/fs/lustre/lov/lov_lock.c
@@ -111,6 +111,7 @@ static int lov_sublock_init(const struct lu_env *env,
  * through already created sub-locks (possibly shared with other top-locks).
  */
 static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
+					  const struct cl_io *io,
 					  const struct cl_object *obj,
 					  struct cl_lock *lock)
 {
@@ -135,10 +136,14 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 		struct lov_layout_raid0 *r0 = lov_r0(lov, index);
 
 		for (i = 0; i < r0->lo_nr; i++) {
-			if (likely(r0->lo_sub[i]) && /* spare layout */
-			    lov_stripe_intersects(lov->lo_lsm, index, i,
-						  &ext, &start, &end))
-				nr++;
+			if (likely(r0->lo_sub[i])) { /* spare layout */
+				if (lov_stripe_intersects(lov->lo_lsm, index, i,
+							  &ext, &start, &end))
+					nr++;
+				else if (cl_io_is_trunc(io) &&
+					 r0->lo_trunc_stripeno == i)
+					nr++;
+			}
 		}
 	}
 	/**
@@ -160,12 +165,22 @@ static struct lov_lock *lov_lock_sub_init(const struct lu_env *env,
 		for (i = 0; i < r0->lo_nr; ++i) {
 			struct lov_lock_sub *lls = &lovlck->lls_sub[nr];
 			struct cl_lock_descr *descr = &lls->sub_lock.cll_descr;
+			bool intersect = false;
 
-			if (unlikely(!r0->lo_sub[i]) ||
-			    !lov_stripe_intersects(lov->lo_lsm, index, i,
-						   &ext, &start, &end))
+			if (unlikely(!r0->lo_sub[i]))
 				continue;
 
+			intersect = lov_stripe_intersects(lov->lo_lsm, index, i,
+							  &ext, &start, &end);
+			if (intersect)
+				goto init_sublock;
+
+			if (cl_io_is_trunc(io) && i == r0->lo_trunc_stripeno)
+				goto init_sublock;
+
+			continue;
+
+init_sublock:
 			LASSERT(!descr->cld_obj);
 			descr->cld_obj = lovsub2cl(r0->lo_sub[i]);
 			descr->cld_start = cl_index(descr->cld_obj, start);
@@ -308,7 +323,7 @@ int lov_lock_init_composite(const struct lu_env *env, struct cl_object *obj,
 	struct lov_lock *lck;
 	int result = 0;
 
-	lck = lov_lock_sub_init(env, obj, lock);
+	lck = lov_lock_sub_init(env, io, obj, lock);
 	if (!IS_ERR(lck))
 		cl_lock_slice_add(lock, &lck->lls_cl, obj, &lov_lock_ops);
 	else
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 3fcd342..d9729c8 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -215,6 +215,7 @@ static int lov_init_raid0(const struct lu_env *env, struct lov_device *dev,
 
 	spin_lock_init(&r0->lo_sub_lock);
 	r0->lo_nr = lse->lsme_stripe_count;
+	r0->lo_trunc_stripeno = -1;
 
 	flags = memalloc_nofs_save();
 	r0->lo_sub = kvmalloc_array(r0->lo_nr, sizeof(r0->lo_sub[0]),
diff --git a/fs/lustre/lov/lov_offset.c b/fs/lustre/lov/lov_offset.c
index ca763af..2493331 100644
--- a/fs/lustre/lov/lov_offset.c
+++ b/fs/lustre/lov/lov_offset.c
@@ -37,7 +37,7 @@
 
 #include "lov_internal.h"
 
-static u64 stripe_width(struct lov_stripe_md *lsm, unsigned int index)
+u64 stripe_width(struct lov_stripe_md *lsm, unsigned int index)
 {
 	struct lov_stripe_md_entry *entry = lsm->lsm_entries[index];
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
