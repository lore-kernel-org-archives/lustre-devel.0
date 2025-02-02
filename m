Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B5BD5C0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 20:50:04 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMCS3r8gz20tP;
	Sun, 02 Feb 2025 12:48:04 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmM9v5Gl0z1xns
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:46:43 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id A117517D1ED;
 Sun,  2 Feb 2025 15:46:41 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 9D2B3106BE17; Sun,  2 Feb 2025 15:46:41 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:02 -0500
Message-ID: <20250202204633.1148872-3-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 02/33] Revert "lustre: llite: Check vmpage in
 releasepage"
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
Cc: Andrew Perepechko <andrew.perepechko@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <pfarrell@whamcloud.com>

This reverts commit 9c78efe1a483968c6f84092cb6e59a3f64bc13d6,
because it breaks releasepage for Lustre and does not
completely fix the data consistency issue in LU-14541.

Breaking releasepage matters because it prevents direct I/O
from working if there is page cache data present, and
because it causes similar issues with GDS, which must be
able to flush page cache pages before doing I/O.

With patches:
commit e02cfe39f908 ("lustre: llite: SIGBUS is possible on a race with page reclaim")
and
commit 6af2199c4868 ("lustre: llite: Check for page deletion after fault")
LU-14541 is fully resolved, so we can revert this patch.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14541
Lustre-commit: e3cfb688ed7116a57 ("Revert "lustre: llite: Check vmpage in releasepage")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49654
Reviewed-by: Andrew Perepechko <andrew.perepechko@hpe.com>
Reviewed-by: Qian Yingjin <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h |  9 ---------
 fs/lustre/llite/rw26.c        | 19 ++++++-------------
 fs/lustre/osc/osc_page.c      |  9 ++-------
 3 files changed, 8 insertions(+), 29 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 77f00d7fc220..94e7f8060d4a 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -91,7 +91,6 @@
 #include <linux/uio.h>
 #include <lu_object.h>
 #include <linux/atomic.h>
-#include <linux/mm.h>
 #include <linux/mutex.h>
 #include <linux/radix-tree.h>
 #include <linux/spinlock.h>
@@ -989,14 +988,6 @@ static inline bool __page_in_use(const struct cl_page *page, int refc)
  */
 #define cl_page_in_use_noref(pg) __page_in_use(pg, 0)
 
-/* references: cl_page, page cache, optional + refcount for caller reference
- * (always 0 or 1 currently)
- */
-static inline int vmpage_in_use(struct page *vmpage, int refcount)
-{
-	return (page_count(vmpage) - page_mapcount(vmpage) > 2 + refcount);
-}
-
 /** @} cl_page */
 
 /** \addtogroup cl_lock cl_lock
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 6b338b20e7d5..2065e14e8469 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -109,7 +109,7 @@ static int ll_releasepage(struct page *vmpage, gfp_t gfp_mask)
 {
 	struct lu_env *env;
 	struct cl_object *obj;
-	struct cl_page *clpage;
+	struct cl_page *page;
 	struct address_space *mapping;
 	int result = 0;
 
@@ -125,23 +125,16 @@ static int ll_releasepage(struct page *vmpage, gfp_t gfp_mask)
 	if (!obj)
 		return 1;
 
-	clpage = cl_vmpage_page(vmpage, obj);
-	if (!clpage)
+	page = cl_vmpage_page(vmpage, obj);
+	if (!page)
 		return 1;
 
 	env = cl_env_percpu_get();
 	LASSERT(!IS_ERR(env));
 
-	/* we must not delete the cl_page if the vmpage is in use, otherwise we
-	 * disconnect the vmpage from Lustre while it's still alive(!), which
-	 * means we won't find it to discard on lock cancellation.
-	 *
-	 * References here are: caller + cl_page + page cache.
-	 * Any other references are potentially transient and must be ignored.
-	 */
-	if (!cl_page_in_use(clpage) && !vmpage_in_use(vmpage, 1)) {
+	if (!cl_page_in_use(page)) {
 		result = 1;
-		cl_page_delete(env, clpage);
+		cl_page_delete(env, page);
 	}
 
 	/* To use percpu env array, the call path can not be rescheduled;
@@ -158,7 +151,7 @@ static int ll_releasepage(struct page *vmpage, gfp_t gfp_mask)
 	 * that we won't get into object delete path.
 	 */
 	LASSERT(cl_object_refc(obj) > 1);
-	cl_page_put(env, clpage);
+	cl_page_put(env, page);
 
 	cl_env_percpu_put(env);
 	return result;
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index feec99fe0ca2..f700b5af7de0 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -520,13 +520,8 @@ static inline bool lru_page_busy(struct client_obd *cli, struct cl_page *page)
 	if (cli->cl_cache->ccc_unstable_check) {
 		struct page *vmpage = cl_page_vmpage(page);
 
-		/* this check is racy because the vmpage is not locked, but
-		 * that's OK - the code which does the actual page release
-		 * checks this again before releasing
-		 *
-		 * vmpage have two known users: cl_page and VM page cache
-		 */
-		if (vmpage_in_use(vmpage, 0))
+		/* vmpage have two known users: cl_page and VM page cache */
+		if (page_count(vmpage) - page_mapcount(vmpage) > 2)
 			return true;
 	}
 	return false;
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
