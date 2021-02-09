Return-Path: <SRS0=GtYW=HL=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A259FC433E0
	for <lustre-devel@archiver.kernel.org>; Tue,  9 Feb 2021 00:54:53 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5681061606
	for <lustre-devel@archiver.kernel.org>; Tue,  9 Feb 2021 00:54:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5681061606
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 709AA30F758;
	Mon,  8 Feb 2021 16:54:45 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8EA7F30F962
 for <lustre-devel@lists.lustre.org>; Mon,  8 Feb 2021 16:54:31 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id F00261006EBB;
 Mon,  8 Feb 2021 19:54:28 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id EB06B4CC37; Mon,  8 Feb 2021 19:54:28 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Feb 2021 19:54:22 -0500
Message-Id: <1612832067-1449-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1612832067-1449-1-git-send-email-jsimmons@infradead.org>
References: <1612832067-1449-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 4/9] lustre: osc: correctly update size/kms
 for fallocate
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

* fallocate chose oa->o_size for falloc_offset and o->o_blocks for
  falloc_end, but forgot to change attr->cat_size and attr->cat_kms
  to use sa_attr.lvb_size to update osc's lvb and kms if it expands
  the file's size.

  Other setattr IO uses @size (sa_falloc_offset in fallocate case) to
  update the lvb and kms.

* lock request extent for fallocate should be
  [sa_falloc_offset, sa_falloc_end)

* calculate sa_attr.lvb_size correctly for osc objects
  (lov_io_sub_inherit())

Fixes: d748d2ffa1bc ("lustre: fallocate: Implement fallocate preallocate operation")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14326
Lustre-commit: 43979e4e257e78d ("LU-14326 osc: correctly update size/kms for fallocate")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41272
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/vvp_io.c   |  2 +-
 fs/lustre/lov/lov_io.c     | 11 +++++------
 fs/lustre/osc/osc_cache.c  |  3 ++-
 fs/lustre/osc/osc_io.c     | 33 +++++++++++++++++----------------
 fs/lustre/osc/osc_object.c |  4 +++-
 5 files changed, 28 insertions(+), 25 deletions(-)

diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index b0b31c37..ac6aef0 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -647,7 +647,7 @@ static int vvp_io_setattr_lock(const struct lu_env *env,
 			enqflags = CEF_DISCARD_DATA;
 	} else if (cl_io_is_fallocate(io)) {
 		lock_start = io->u.ci_setattr.sa_falloc_offset;
-		lock_end = lock_start + io->u.ci_setattr.sa_attr.lvb_size;
+		lock_end = io->u.ci_setattr.sa_falloc_end;
 	} else {
 		unsigned int valid = io->u.ci_setattr.sa_avalid;
 
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index c9600bc..2297e53 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -677,17 +677,16 @@ static void lov_io_sub_inherit(struct lov_io_sub *sub, struct lov_io *lio,
 			parent->u.ci_setattr.sa_parent_fid;
 		/* For SETATTR(fallocate) pass the subtype to lower IO */
 		io->u.ci_setattr.sa_subtype = parent->u.ci_setattr.sa_subtype;
-		if (cl_io_is_trunc(io)) {
+		if (cl_io_is_fallocate(io)) {
+			io->u.ci_setattr.sa_falloc_offset = start;
+			io->u.ci_setattr.sa_falloc_end = end;
+		}
+		if (cl_io_is_trunc(io) || cl_io_is_fallocate(io)) {
 			loff_t new_size = parent->u.ci_setattr.sa_attr.lvb_size;
 
 			new_size = lov_size_to_stripe(lsm, index, new_size,
 						      stripe);
 			io->u.ci_setattr.sa_attr.lvb_size = new_size;
-		} else if (cl_io_is_fallocate(io)) {
-			io->u.ci_setattr.sa_falloc_offset = start;
-			io->u.ci_setattr.sa_falloc_end = end;
-			io->u.ci_setattr.sa_attr.lvb_size =
-				parent->u.ci_setattr.sa_attr.lvb_size;
 		}
 		lov_lsm2layout(lsm, lsm->lsm_entries[index],
 			       &io->u.ci_setattr.sa_layout);
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index d511ece..4abe8ba 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -1159,7 +1159,8 @@ static int osc_extent_make_ready(const struct lu_env *env,
 		int last_oap_count = osc_refresh_count(env, last,
 						       OBD_BRW_WRITE);
 
-		LASSERT(last_oap_count > 0);
+		LASSERTF(last_oap_count > 0,
+			 "last_oap_count %d\n", last_oap_count);
 		LASSERT(last->oap_page_off + last_oap_count <= PAGE_SIZE);
 		last->oap_count = last_oap_count;
 		spin_lock(&last->oap_lock);
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index a0537b8..ce0f7ec 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -569,8 +569,14 @@ static int osc_io_setattr_start(const struct lu_env *env,
 			unsigned int cl_valid = 0;
 
 			if (ia_avalid & ATTR_SIZE) {
-				attr->cat_size = size;
-				attr->cat_kms = size;
+				if (io_is_falloc) {
+					attr->cat_size =
+						io->u.ci_setattr.sa_attr.lvb_size;
+					attr->cat_kms = attr->cat_size;
+				} else {
+					attr->cat_size = size;
+					attr->cat_kms = size;
+				}
 				cl_valid = CAT_SIZE | CAT_KMS;
 			}
 			if (ia_avalid & ATTR_MTIME_SET) {
@@ -707,22 +713,17 @@ void osc_io_setattr_end(const struct lu_env *env,
 	}
 
 	if (cl_io_is_fallocate(io)) {
-		cl_object_attr_lock(obj);
-
-		/* update blocks */
-		if (oa->o_valid & OBD_MD_FLBLOCKS) {
-			attr->cat_blocks = oa->o_blocks;
-			cl_valid |= CAT_BLOCKS;
-		}
+		if (result == 0) {
+			cl_object_attr_lock(obj);
+			/* update blocks */
+			if (oa->o_valid & OBD_MD_FLBLOCKS) {
+				attr->cat_blocks = oa->o_blocks;
+				cl_valid |= CAT_BLOCKS;
+			}
 
-		/* update size */
-		if (oa->o_valid & OBD_MD_FLSIZE) {
-			attr->cat_size = oa->o_size;
-			cl_valid |= CAT_SIZE;
+			cl_object_attr_update(env, obj, attr, cl_valid);
+			cl_object_attr_unlock(obj);
 		}
-
-		cl_object_attr_update(env, obj, attr, cl_valid);
-		cl_object_attr_unlock(obj);
 	}
 }
 EXPORT_SYMBOL(osc_io_setattr_end);
diff --git a/fs/lustre/osc/osc_object.c b/fs/lustre/osc/osc_object.c
index 273098a..00f2800 100644
--- a/fs/lustre/osc/osc_object.c
+++ b/fs/lustre/osc/osc_object.c
@@ -218,7 +218,9 @@ static int osc_object_ast_clear(struct ldlm_lock *lock, void *data)
 			   lvb->lvb_atime, oinfo->loi_lvb.lvb_size,
 			   oinfo->loi_lvb.lvb_blocks, oinfo->loi_lvb.lvb_ctime,
 			   oinfo->loi_lvb.lvb_mtime, oinfo->loi_lvb.lvb_atime);
-		LASSERT(oinfo->loi_lvb.lvb_size >= oinfo->loi_kms);
+		LASSERTF(oinfo->loi_lvb.lvb_size >= oinfo->loi_kms,
+			 "lvb_size %#llx, loi_kms %#llx\n",
+			 oinfo->loi_lvb.lvb_size, oinfo->loi_kms);
 
 		cl_object_attr_lock(&osc->oo_cl);
 		memcpy(lvb, &oinfo->loi_lvb, sizeof(oinfo->loi_lvb));
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
