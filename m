Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 53E1CC6FA8B
	for <lustre-devel@archiver.kernel.org>; Sun, 18 Sep 2022 05:22:40 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MVbmF2scXz1y6q;
	Sat, 17 Sep 2022 22:22:37 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MVblz6J6rz1y7H
 for <lustre-devel@lists.lustre.org>; Sat, 17 Sep 2022 22:22:23 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id E0ED08F07;
 Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id DCDFEE8BA9; Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 18 Sep 2022 01:21:58 -0400
Message-Id: <1663478534-19917-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
References: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/24] lustre: llite: don't use a kms if it
 invalid.
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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
Cc: Alexey Lyashkov <alexey.lyashkov@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alexey Lyashkov <alexey.lyashkov@hpe.com>

Lockless DIO don't update a KMS as other IO type does,
it caused a situation when next read don't known a real file size
to be read. Lets avoid using an invalid KMS.

Fixes: bf18998820 ("lustre: clio: turn on lockless for some kind of IO")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15829
Lustre-commit: dc907414db16d99e7 ("LU-15829 llite: don't use a kms if it invalid.")
Signed-off-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-on: https://review.whamcloud.com/47395
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h |  2 ++
 fs/lustre/llite/vvp_io.c      |  2 +-
 fs/lustre/lov/lov_internal.h  |  2 +-
 fs/lustre/lov/lov_merge.c     | 46 ++++++++++++++++++++++++-------------------
 fs/lustre/lov/lov_object.c    | 23 +++-------------------
 5 files changed, 33 insertions(+), 42 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 3253f1c..492c704 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -138,6 +138,8 @@ struct cl_device {
 struct cl_attr {
 	/** Object size, in bytes */
 	loff_t		cat_size;
+
+	unsigned int cat_kms_valid:1;
 	/**
 	 * Known minimal size, in bytes.
 	 *
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 75c5224..6fd2e2dd 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -151,7 +151,7 @@ static int vvp_prep_size(const struct lu_env *env, struct cl_object *obj,
 	result = cl_object_attr_get(env, obj, attr);
 	if (result == 0) {
 		kms = attr->cat_kms;
-		if (pos > kms) {
+		if (pos > kms || !attr->cat_kms_valid) {
 			/*
 			 * A glimpse is necessary to determine whether we
 			 * return a short read (B) or some zeroes at the end
diff --git a/fs/lustre/lov/lov_internal.h b/fs/lustre/lov/lov_internal.h
index 8c0b6fa..cd6bc7a 100644
--- a/fs/lustre/lov/lov_internal.h
+++ b/fs/lustre/lov/lov_internal.h
@@ -271,7 +271,7 @@ struct lov_request_set {
 
 /* lov_merge.c */
 int lov_merge_lvb_kms(struct lov_stripe_md *lsm, int index,
-		      struct ost_lvb *lvb, u64 *kms_place);
+		      struct cl_attr *attr);
 
 /* lov_offset.c */
 u64 stripe_width(struct lov_stripe_md *lsm, unsigned int index);
diff --git a/fs/lustre/lov/lov_merge.c b/fs/lustre/lov/lov_merge.c
index 8800c5f..5cc5928 100644
--- a/fs/lustre/lov/lov_merge.c
+++ b/fs/lustre/lov/lov_merge.c
@@ -32,6 +32,7 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
+#include <cl_object.h>
 #include <obd_class.h>
 #include "lov_internal.h"
 
@@ -41,26 +42,24 @@
  * uptodate time on the local client.
  */
 int lov_merge_lvb_kms(struct lov_stripe_md *lsm, int index,
-		      struct ost_lvb *lvb, u64 *kms_place)
+		      struct cl_attr *attr)
 {
 	struct lov_stripe_md_entry *lse = lsm->lsm_entries[index];
 	u64 size = 0;
 	u64 kms = 0;
 	u64 blocks = 0;
-	s64 current_mtime = lvb->lvb_mtime;
-	s64 current_atime = lvb->lvb_atime;
-	s64 current_ctime = lvb->lvb_ctime;
+	/* XXX: timestamps can be negative by sanity:test_39m,
+	 * how can it be?
+	 */
+	s64 current_mtime = LLONG_MIN;
+	s64 current_atime = LLONG_MIN;
+	s64 current_ctime = LLONG_MIN;
 	int i;
 	int rc = 0;
 
 	assert_spin_locked(&lsm->lsm_lock);
 	LASSERT(lsm->lsm_lock_owner == current->pid);
 
-	CDEBUG(D_INODE,
-	       "MDT ID " DOSTID " initial value: s=%llu m=%llu a=%llu c=%llu b=%llu\n",
-	       POSTID(&lsm->lsm_oi), lvb->lvb_size, lvb->lvb_mtime,
-	       lvb->lvb_atime, lvb->lvb_ctime, lvb->lvb_blocks);
-
 	for (i = 0; i < lse->lsme_stripe_count; i++) {
 		struct lov_oinfo *loi = lse->lsme_oinfo[i];
 		u64 lov_size, tmpsize;
@@ -70,7 +69,12 @@ int lov_merge_lvb_kms(struct lov_stripe_md *lsm, int index,
 			continue;
 		}
 
-		tmpsize = loi->loi_kms;
+		if (loi->loi_kms_valid) {
+			attr->cat_kms_valid = 1;
+			tmpsize = loi->loi_kms;
+		} else {
+			tmpsize = 0;
+		}
 		lov_size = lov_stripe_size(lsm, index, tmpsize, i);
 		if (lov_size > kms)
 			kms = lov_size;
@@ -91,18 +95,20 @@ int lov_merge_lvb_kms(struct lov_stripe_md *lsm, int index,
 			current_ctime = loi->loi_lvb.lvb_ctime;
 
 		CDEBUG(D_INODE,
-		       "MDT ID " DOSTID " on OST[%u]: s=%llu m=%llu a=%llu c=%llu b=%llu\n",
+		       "MDT ID " DOSTID " on OST[%u]: s=%llu (%d) m=%llu a=%llu c=%llu b=%llu\n",
 		       POSTID(&lsm->lsm_oi), loi->loi_ost_idx,
-		       loi->loi_lvb.lvb_size, loi->loi_lvb.lvb_mtime,
-		       loi->loi_lvb.lvb_atime, loi->loi_lvb.lvb_ctime,
-		       loi->loi_lvb.lvb_blocks);
+		       loi->loi_lvb.lvb_size, loi->loi_kms_valid,
+		       loi->loi_lvb.lvb_mtime, loi->loi_lvb.lvb_atime,
+		       loi->loi_lvb.lvb_ctime, loi->loi_lvb.lvb_blocks);
 	}
 
-	*kms_place = kms;
-	lvb->lvb_size = size;
-	lvb->lvb_blocks = blocks;
-	lvb->lvb_mtime = current_mtime;
-	lvb->lvb_atime = current_atime;
-	lvb->lvb_ctime = current_ctime;
+	if (!rc) {
+		attr->cat_kms = kms;
+		attr->cat_size = size;
+		attr->cat_mtime = current_mtime;
+		attr->cat_atime = current_atime;
+		attr->cat_ctime = current_ctime;
+		attr->cat_blocks = blocks;
+	}
 	return rc;
 }
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 3934a98..064764c 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -373,9 +373,7 @@ static int lov_attr_get_raid0(const struct lu_env *env, struct lov_object *lov,
 {
 	struct lov_layout_raid0 *r0 = &lle->lle_raid0;
 	struct lov_stripe_md *lsm = lov->lo_lsm;
-	struct ost_lvb *lvb = &lov_env_info(env)->lti_lvb;
 	struct cl_attr *attr = &r0->lo_attr;
-	u64 kms = 0;
 	int result = 0;
 
 	if (r0->lo_attr_valid) {
@@ -383,21 +381,6 @@ static int lov_attr_get_raid0(const struct lu_env *env, struct lov_object *lov,
 		return 0;
 	}
 
-	memset(lvb, 0, sizeof(*lvb));
-
-	/* XXX: timestamps can be negative by sanity:test_39m,
-	 * how can it be?
-	 */
-	lvb->lvb_atime = LLONG_MIN;
-	lvb->lvb_ctime = LLONG_MIN;
-	lvb->lvb_mtime = LLONG_MIN;
-
-	/*
-	 * XXX that should be replaced with a loop over sub-objects,
-	 * doing cl_object_attr_get() on them. But for now, let's
-	 * reuse old lov code.
-	 */
-
 	/*
 	 * XXX take lsm spin-lock to keep lov_merge_lvb_kms()
 	 * happy. It's not needed, because new code uses
@@ -405,11 +388,9 @@ static int lov_attr_get_raid0(const struct lu_env *env, struct lov_object *lov,
 	 * sub-object attributes.
 	 */
 	lov_stripe_lock(lsm);
-	result = lov_merge_lvb_kms(lsm, index, lvb, &kms);
+	result = lov_merge_lvb_kms(lsm, index, attr);
 	lov_stripe_unlock(lsm);
 	if (result == 0) {
-		cl_lvb2attr(attr, lvb);
-		attr->cat_kms = kms;
 		r0->lo_attr_valid = 1;
 		*lov_attr = attr;
 	}
@@ -1042,6 +1023,8 @@ static int lov_attr_get_composite(const struct lu_env *env,
 		       lov_attr->cat_ctime, lov_attr->cat_blocks);
 
 		/* merge results */
+		if (lov_attr->cat_kms_valid)
+			attr->cat_kms_valid = 1;
 		attr->cat_blocks += lov_attr->cat_blocks;
 		if (attr->cat_size < lov_attr->cat_size)
 			attr->cat_size = lov_attr->cat_size;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
