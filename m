Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B2F7DC6FA86
	for <lustre-devel@archiver.kernel.org>; Sun, 18 Sep 2022 05:22:46 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MVbmQ2jJ2z1yBt;
	Sat, 17 Sep 2022 22:22:46 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MVbm32rYNz1yC9
 for <lustre-devel@lists.lustre.org>; Sat, 17 Sep 2022 22:22:27 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id ED15E8F0C;
 Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E9EEC27E1; Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 18 Sep 2022 01:22:02 -0400
Message-Id: <1663478534-19917-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
References: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/24] lustre: clio: remove vvp_page_print()
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: "John L. Hammond" <jhammond@whamcloud.com>

Remove vvp_page_print() by placing equivalent code in cl_page_print().

WC-bug-id: https://jira.whamcloud.com/browse/LU-10994
Lustre-commit: bf1d1b0e41ff245f5 ("LU-10994 clio: remove vvp_page_print()")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/47398
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/vvp_page.c   | 24 ------------------------
 fs/lustre/obdclass/cl_page.c | 23 +++++++++++++++++++----
 2 files changed, 19 insertions(+), 28 deletions(-)

diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
index db1cd7c1..f27bbfa 100644
--- a/fs/lustre/llite/vvp_page.c
+++ b/fs/lustre/llite/vvp_page.c
@@ -214,28 +214,6 @@ static int vvp_page_make_ready(const struct lu_env *env,
 	return result;
 }
 
-static int vvp_page_print(const struct lu_env *env,
-			  const struct cl_page_slice *slice,
-			  void *cookie, lu_printer_t printer)
-{
-	struct vvp_page *vpg = cl2vvp_page(slice);
-	struct page *vmpage = vpg->vpg_page;
-
-	(*printer)(env, cookie,
-		   LUSTRE_VVP_NAME"-page@%p vm@%p ", vpg, vmpage);
-	if (vmpage) {
-		(*printer)(env, cookie, "%lx %d:%d %lx %lu %slru",
-			   (long)vmpage->flags, page_count(vmpage),
-			   page_mapcount(vmpage), vmpage->private,
-			   vmpage->index,
-			   list_empty(&vmpage->lru) ? "not-" : "");
-	}
-
-	(*printer)(env, cookie, "\n");
-
-	return 0;
-}
-
 static int vvp_page_fail(const struct lu_env *env,
 			 const struct cl_page_slice *slice)
 {
@@ -249,7 +227,6 @@ static int vvp_page_fail(const struct lu_env *env,
 
 static const struct cl_page_operations vvp_page_ops = {
 	.cpo_discard		= vvp_page_discard,
-	.cpo_print		= vvp_page_print,
 	.io = {
 		[CRT_READ] = {
 			.cpo_prep	= vvp_page_prep_read,
@@ -265,7 +242,6 @@ static int vvp_page_fail(const struct lu_env *env,
 };
 
 static const struct cl_page_operations vvp_transient_page_ops = {
-	.cpo_print		= vvp_page_print,
 };
 
 int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index 6319c3d..6fbbfa8 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -1017,21 +1017,36 @@ void cl_page_header_print(const struct lu_env *env, void *cookie,
  * Prints human readable representation of @cl_page to the @f.
  */
 void cl_page_print(const struct lu_env *env, void *cookie,
-		   lu_printer_t printer, const struct cl_page *cl_page)
+		   lu_printer_t printer, const struct cl_page *cp)
 {
+	struct page *vmpage = cp->cp_vmpage;
 	const struct cl_page_slice *slice;
 	int result = 0;
 	int i;
 
-	cl_page_header_print(env, cookie, printer, cl_page);
-	cl_page_slice_for_each(cl_page, slice, i) {
+	cl_page_header_print(env, cookie, printer, cp);
+
+	(*printer)(env, cookie, "vmpage @%p", vmpage);
+
+	if (vmpage) {
+		(*printer)(env, cookie, " %lx %d:%d %lx %lu %slru",
+			   (long)vmpage->flags, page_count(vmpage),
+			   page_mapcount(vmpage), vmpage->private,
+			   page_index(vmpage),
+			   list_empty(&vmpage->lru) ? "not-" : "");
+	}
+
+	(*printer)(env, cookie, "\n");
+
+	cl_page_slice_for_each(cp, slice, i) {
 		if (slice->cpl_ops->cpo_print)
 			result = (*slice->cpl_ops->cpo_print)(env, slice,
 							      cookie, printer);
 		if (result != 0)
 			break;
 	}
-	(*printer)(env, cookie, "end page@%p\n", cl_page);
+
+	(*printer)(env, cookie, "end page@%p\n", cp);
 }
 EXPORT_SYMBOL(cl_page_print);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
