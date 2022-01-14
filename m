Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 4C75FC433EF
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:38:31 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4A8A521FF91;
	Thu, 13 Jan 2022 17:38:23 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A77BA21FFA9
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:08 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id BC88D100F326;
 Thu, 13 Jan 2022 20:38:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B53E1A8102; Thu, 13 Jan 2022 20:38:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:37:46 -0500
Message-Id: <1642124283-10148-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
References: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/24] lustre: lov: Cache stripe offset
 calculation
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
Cc: Patrick Farrell <farr0186@gmail.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <farr0186@gmail.com>

Calculating the page offset relative to the stripe (etc)
in a file is surprisingly expensive.  Because i/o has
already been split up to stripes by the cl_io code,
calculating the stripe each time is unnecessary.

We cache most of the values requiring calculation.

This improves AIO/DIO page submission significantly,
improving performance by a bit over 10%.

Also remove lpg_generation, which isn't doing anything
useful.  This suggests the possibility of removing
lov_page, but that's for another patch.

This patch reduces i/o time in ms/GiB by:
Write: 17 ms/GiB
Read: 22 ms/GiB

Totals:
Write: 119 ms/GiB
Read: 121 ms/GiB

mpirun -np 1  $IOR -w -r -t 64M -b 64G -o ./iorfile --posix.odirect

With previous patches in series:
write        7531 MiB/s
read         7179 MiB/s

Plus this patch:
write        8637 MiB/s
read         8488 MiB/s

WC-bug-id: https://jira.whamcloud.com/browse/LU-13799
Lustre-commit: 14db1faa0fbe813fe ("LU-13799 lov: Cache stripe offset calculation")
Signed-off-by: Patrick Farrell <farr0186@gmail.com>
Reviewed-on: https://review.whamcloud.com/39445
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_cl_internal.h |  9 +++++--
 fs/lustre/lov/lov_io.c          |  6 +++++
 fs/lustre/lov/lov_page.c        | 57 +++++++++++++++++++++++++++++++----------
 3 files changed, 57 insertions(+), 15 deletions(-)

diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index d48e2df3..42fd10a 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -453,8 +453,6 @@ struct lov_lock {
 
 struct lov_page {
 	struct cl_page_slice	lps_cl;
-	/* the layout gen when this page was created */
-	u32			lps_layout_gen;
 };
 
 /*
@@ -524,6 +522,7 @@ struct lov_io_sub {
 /**
  * IO state private for LOV.
  */
+#define LIS_CACHE_ENTRY_NONE	-ENOENT
 struct lov_io {
 	/** super-class */
 	struct cl_io_slice	lis_cl;
@@ -590,6 +589,12 @@ struct lov_io {
 	 * All sub-io's created in this lov_io.
 	 */
 	struct list_head	lis_subios;
+	/* Cached results from stripe & offset calculations for page init */
+	int			lis_cached_entry;
+	int			lis_cached_stripe;
+	loff_t			lis_cached_off;
+	loff_t			lis_cached_suboff;
+	struct lov_io_sub	*lis_cached_sub;
 };
 
 struct lov_session {
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 8df13ee..904bafd 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -467,6 +467,7 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 
 	io->ci_result = 0;
 	lio->lis_object = obj;
+	lio->lis_cached_entry = LIS_CACHE_ENTRY_NONE;
 
 	switch (io->ci_type) {
 	case CIT_READ:
@@ -1053,6 +1054,11 @@ static void lov_io_end(const struct lu_env *env, const struct cl_io_slice *ios)
 {
 	int rc;
 
+	/* Before ending each i/o, we must set lis_cached_entry to tell the
+	 * next i/o not to use stale cached lis information.
+	 */
+	cl2lov_io(env, ios)->lis_cached_entry = LIS_CACHE_ENTRY_NONE;
+
 	rc = lov_io_call(env, cl2lov_io(env, ios), lov_io_end_wrapper);
 	LASSERT(rc == 0);
 }
diff --git a/fs/lustre/lov/lov_page.c b/fs/lustre/lov/lov_page.c
index fdc415b..16bd7cd 100644
--- a/fs/lustre/lov/lov_page.c
+++ b/fs/lustre/lov/lov_page.c
@@ -56,8 +56,7 @@ static int lov_comp_page_print(const struct lu_env *env,
 	struct lov_page *lp = cl2lov_page(slice);
 
 	return (*printer)(env, cookie,
-			  LUSTRE_LOV_NAME "-page@%p, gen: %u\n",
-			  lp, lp->lps_layout_gen);
+			  LUSTRE_LOV_NAME"-page@%p\n", lp);
 }
 
 static const struct cl_page_operations lov_comp_page_ops = {
@@ -74,33 +73,65 @@ int lov_page_init_composite(const struct lu_env *env, struct cl_object *obj,
 	struct cl_object *o;
 	struct lov_io_sub *sub;
 	struct lov_page *lpg = cl_object_page_slice(obj, page);
+	bool stripe_cached = false;
 	u64 offset;
 	u64 suboff;
-	int stripe;
 	int entry;
+	int stripe;
 	int rc;
 
+	/* Direct i/o (CPT_TRANSIENT) is split strictly to stripes, so we can
+	 * cache the stripe information.  Buffered i/o is differently
+	 * organized, and stripe calculation isn't a significant cost for
+	 * buffered i/o, so we only cache this for direct i/o.
+	 */
+	stripe_cached = lio->lis_cached_entry != LIS_CACHE_ENTRY_NONE &&
+			page->cp_type == CPT_TRANSIENT;
+
 	offset = cl_offset(obj, index);
-	entry = lov_io_layout_at(lio, offset);
+
+	if (stripe_cached) {
+		entry = lio->lis_cached_entry;
+		stripe = lio->lis_cached_stripe;
+		/* Offset can never go backwards in an i/o, so this is valid */
+		suboff = lio->lis_cached_suboff + offset - lio->lis_cached_off;
+	} else {
+		entry = lov_io_layout_at(lio, offset);
+
+		stripe = lov_stripe_number(loo->lo_lsm, entry, offset);
+		rc = lov_stripe_offset(loo->lo_lsm, entry, offset, stripe,
+				       &suboff);
+		LASSERT(rc == 0);
+		lio->lis_cached_entry = entry;
+		lio->lis_cached_stripe = stripe;
+		lio->lis_cached_off = offset;
+		lio->lis_cached_suboff = suboff;
+	}
+
 	if (entry < 0 || !lsm_entry_inited(loo->lo_lsm, entry)) {
 		/* non-existing layout component */
 		lov_page_init_empty(env, obj, page, index);
 		return 0;
 	}
 
-	r0 = lov_r0(loo, entry);
-	stripe = lov_stripe_number(loo->lo_lsm, entry, offset);
-	LASSERT(stripe < r0->lo_nr);
-	rc = lov_stripe_offset(loo->lo_lsm, entry, offset, stripe, &suboff);
-	LASSERT(rc == 0);
+	CDEBUG(D_PAGE, "offset %llu, entry %d, stripe %d, suboff %llu\n",
+	       offset, entry, stripe, suboff);
 
 	page->cp_lov_index = lov_comp_index(entry, stripe);
-	lpg->lps_layout_gen = loo->lo_lsm->lsm_layout_gen;
 	cl_page_slice_add(page, &lpg->lps_cl, obj, &lov_comp_page_ops);
 
-	sub = lov_sub_get(env, lio, page->cp_lov_index);
-	if (IS_ERR(sub))
-		return PTR_ERR(sub);
+	if (!stripe_cached) {
+		sub = lov_sub_get(env, lio, page->cp_lov_index);
+		if (IS_ERR(sub))
+			return PTR_ERR(sub);
+	} else {
+		sub = lio->lis_cached_sub;
+	}
+
+	lio->lis_cached_sub = sub;
+
+	r0 = lov_r0(loo, entry);
+	LASSERT(stripe < r0->lo_nr);
 
 	subobj = lovsub2cl(r0->lo_sub[stripe]);
 	cl_object_for_each(o, subobj) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
