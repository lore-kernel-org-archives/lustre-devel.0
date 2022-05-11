Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id D8971C433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 11 May 2022 19:38:55 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A682521C96F;
	Wed, 11 May 2022 12:38:53 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 152E4216163
 for <lustre-devel@lists.lustre.org>; Wed, 11 May 2022 12:38:48 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 8FA41ED5;
 Wed, 11 May 2022 15:38:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8666D58950; Wed, 11 May 2022 15:38:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>, Sebastien Buisson <sbuisson@ddn.com>
Date: Wed, 11 May 2022 15:38:41 -0400
Message-Id: <1652297923-16141-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1652297923-16141-1-git-send-email-jsimmons@infradead.org>
References: <1652297923-16141-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 3/5] lustre: sec: correctly handle page lock
 in ll_io_zero_page
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

From: Sebastien Buisson <sbuisson@ddn.com>

In ll_io_zero_page(), we need to make sure we have locked the page,
and it is up-to-date, before zeroing. So modify ll_io_read_page()
behavior to not disown the clpage for our use case. It avoids being
exposed to concurrent modifications.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15803
Lustre-commit: edcd05e5ac035dd1d ("LU-15803 sec: correctly handle page lock in ll_io_zero_page")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/47170
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c | 20 ++++++++++----------
 fs/lustre/llite/rw.c        | 11 +++++++++--
 2 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 8c0a3e0..ad77ef0 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1831,7 +1831,6 @@ int ll_io_zero_page(struct inode *inode, pgoff_t index, pgoff_t offset,
 	struct cl_2queue *queue = NULL;
 	struct cl_sync_io *anchor = NULL;
 	bool holdinglock = false;
-	bool lockedbymyself = true;
 	int rc;
 
 	env = cl_env_get(&refcheck);
@@ -1888,8 +1887,10 @@ int ll_io_zero_page(struct inode *inode, pgoff_t index, pgoff_t offset,
 	if (!PageUptodate(vmpage) && !PageDirty(vmpage) &&
 	    !PageWriteback(vmpage)) {
 		/* read page */
-		/* set PagePrivate2 to detect special case of empty page
-		 * in osc_brw_fini_request()
+		/* Set PagePrivate2 to detect special case of empty page
+		 * in osc_brw_fini_request().
+		 * It is also used to tell ll_io_read_page() that we do not
+		 * want the vmpage to be unlocked.
 		 */
 		SetPagePrivate2(vmpage);
 		rc = ll_io_read_page(env, io, clpage, NULL);
@@ -1900,17 +1901,18 @@ int ll_io_zero_page(struct inode *inode, pgoff_t index, pgoff_t offset,
 			 * file, we must not zero and write as below. Subsequent
 			 * server-side truncate will handle things correctly.
 			 */
+			cl_page_unassume(env, io, clpage);
 			rc = 0;
 			goto clpfini;
 		}
 		ClearPagePrivate2(vmpage);
 		if (rc)
 			goto clpfini;
-		lockedbymyself = trylock_page(vmpage);
-		cl_page_assume(env, io, clpage);
 	}
 
-	/* zero range in page */
+	/* Thanks to PagePrivate2 flag, ll_io_read_page() did not unlock
+	 * the vmpage, so we are good to proceed and zero range in page.
+	 */
 	zero_user(vmpage, offset, len);
 
 	if (holdinglock && clpage) {
@@ -1940,10 +1942,8 @@ int ll_io_zero_page(struct inode *inode, pgoff_t index, pgoff_t offset,
 	if (clpage)
 		cl_page_put(env, clpage);
 pagefini:
-	if (lockedbymyself) {
-		unlock_page(vmpage);
-		put_page(vmpage);
-	}
+	unlock_page(vmpage);
+	put_page(vmpage);
 rellock:
 	if (holdinglock)
 		cl_lock_release(env, lock);
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 0ddd920..bd02a28 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -1630,18 +1630,24 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 	struct vvp_io *vio = vvp_env_io(env);
 	bool mmap = !vio->vui_ra_valid;
 	struct cl_sync_io *anchor = NULL;
+	bool unlockpage = true, uptodate;
 	pgoff_t ra_start_index = 0;
 	pgoff_t io_start_index;
 	pgoff_t io_end_index;
 	int rc = 0, rc2 = 0;
 	struct vvp_page *vpg;
-	bool uptodate;
 
 	if (file) {
 		fd = file->private_data;
 		ras = &fd->fd_ras;
 	}
 
+	/* PagePrivate2 is set in ll_io_zero_page() to tell us the vmpage
+	 * must not be unlocked after processing.
+	 */
+	if (page->cp_vmpage && PagePrivate2(page->cp_vmpage))
+		unlockpage = false;
+
 	vpg = cl2vvp_page(cl_object_page_slice(page->cp_obj, page));
 	uptodate = vpg->vpg_defer_uptodate;
 
@@ -1721,7 +1727,8 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 			 */
 			cl_page_discard(env, io, page);
 		}
-		cl_page_disown(env, io, page);
+		if (unlockpage)
+			cl_page_disown(env, io, page);
 	}
 
 	/* TODO: discard all pages until page reinit route is implemented */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
