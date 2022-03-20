Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B5283C433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:32:29 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0B45921CABF;
	Sun, 20 Mar 2022 06:31:55 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C311F21F157
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:17 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 541E0EF5;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 50D24D5A47; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:44 -0400
Message-Id: <1647783064-20688-31-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 30/50] lustre: llite: Do not get/put DIO pages
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

From: Patrick Farrell <pfarrell@whamcloud.com>

We've already told the kernel we're working with these pages
using the get/put_user_pages functions, and userspace must
hold references on them throughout the i/o anyway.

So getting/putting these vmpages is unnecessary.  This
saves around 7% of the time in DIO page submission, netting
about that much of a performance improvement.

This patch reduces i/o time in ms/GiB by:
Write: 22 ms/GiB
Read: 19 ms/GiB

Totals:
Write: 135 ms/GiB
Read: 143 ms/GiB

mpirun -np 1  $IOR -w -r -t 64M -b 64G -o ./iorfile --posix.odirect

With previous patches in series:
write           6470 MiB/s
read            6354 MiB/s

Plus this patch:
write           7531 MiB/s
read            7179 MiB/s

WC-bug-id: https://jira.whamcloud.com/browse/LU-13799
Lustre-commit: 881b4c722296ff7ac ("LU-13799 llite: Do not get/put DIO pages")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39438
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/vvp_page.c | 34 ++++++++--------------------------
 1 file changed, 8 insertions(+), 26 deletions(-)

diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
index 60a28d6..ae51ba0 100644
--- a/fs/lustre/llite/vvp_page.c
+++ b/fs/lustre/llite/vvp_page.c
@@ -52,20 +52,6 @@
  * Page operations.
  *
  */
-
-static void vvp_page_fini_common(struct vvp_page *vpg, struct pagevec *pvec)
-{
-	struct page *vmpage = vpg->vpg_page;
-
-	LASSERT(vmpage);
-	if (pvec) {
-		if (!pagevec_add(pvec, vmpage))
-			pagevec_release(pvec);
-	} else {
-		put_page(vmpage);
-	}
-}
-
 static void vvp_page_fini(const struct lu_env *env,
 			  struct cl_page_slice *slice,
 			  struct pagevec *pvec)
@@ -78,7 +64,13 @@ static void vvp_page_fini(const struct lu_env *env,
 	 * VPG_FREEING state.
 	 */
 	LASSERT((struct cl_page *)vmpage->private != slice->cpl_page);
-	vvp_page_fini_common(vpg, pvec);
+	LASSERT(vmpage);
+	if (pvec) {
+		if (!pagevec_add(pvec, vmpage))
+			pagevec_release(pvec);
+	} else {
+		put_page(vmpage);
+	}
 }
 
 static int vvp_page_own(const struct lu_env *env,
@@ -432,18 +424,8 @@ static int vvp_transient_page_is_vmlocked(const struct lu_env *env,
 	return -EBUSY;
 }
 
-static void vvp_transient_page_fini(const struct lu_env *env,
-				    struct cl_page_slice *slice,
-				    struct pagevec *pvec)
-{
-	struct vvp_page *vpg = cl2vvp_page(slice);
-
-	vvp_page_fini_common(vpg, pvec);
-}
-
 static const struct cl_page_operations vvp_transient_page_ops = {
 	.cpo_discard		= vvp_transient_page_discard,
-	.cpo_fini		= vvp_transient_page_fini,
 	.cpo_is_vmlocked	= vvp_transient_page_is_vmlocked,
 	.cpo_print		= vvp_page_print,
 };
@@ -457,7 +439,6 @@ int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
 	vpg->vpg_page = vmpage;
-	get_page(vmpage);
 
 	if (page->cp_type == CPT_TRANSIENT) {
 		/* DIO pages are referenced by userspace, we don't need to take
@@ -466,6 +447,7 @@ int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 		cl_page_slice_add(page, &vpg->vpg_cl, obj,
 				  &vvp_transient_page_ops);
 	} else {
+		get_page(vmpage);
 		/* in cache, decref in vvp_page_delete */
 		refcount_inc(&page->cp_ref);
 		SetPagePrivate(vmpage);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
