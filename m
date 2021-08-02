Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B52FC432BE
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:52:03 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 25B0A61050
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:52:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 25B0A61050
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 24F76352DDB;
	Mon,  2 Aug 2021 12:51:45 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4D764352B86
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:50:58 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 6DB64100804E;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 6C530C2F46; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:33 -0400
Message-Id: <1627933851-7603-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
References: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/25] lustre: llite: Adjust dio refcounting
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

We get a page reference in cl_page_find, then immediately
add another for cl_page_list_add and remove the first
reference.  This is pretty silly, since the life cycle is
the same on these.

This improves DIO/AIO page submission by around 2%.

This patch reduces i/o time in ms/GiB by:
Write: 2 ms/GiB
Read: 2 ms/GiB

Totals:
Write: 170 ms/GiB
Read: 162 ms/GiB

mpirun -np 1  $IOR -w -r -t 64M -b 64G -o ./iorfile --posix.odirect

With previous pa5ches in series:
write        5955 MiB/s
read         6218 MiB/s

Plus this patch:
write        6028 MiB/s
read         6305 MiB/s

WC-bug-id: https://jira.whamcloud.com/browse/LU-13799
Lustre-commit: 1e4d10af3909452b ("LU-13799 llite: Adjust dio refcounting")
Signed-off-by: Patrick Farrell <farr0186@gmail.com>
Reviewed-on: https://review.whamcloud.com/39447
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h   | 18 ++++++++++--------
 fs/lustre/llite/llite_lib.c     |  2 +-
 fs/lustre/llite/rw.c            |  4 ++--
 fs/lustre/llite/rw26.c          |  9 +++++----
 fs/lustre/llite/vvp_io.c        |  4 ++--
 fs/lustre/llite/vvp_page.c      | 11 +++++++----
 fs/lustre/obdclass/cl_io.c      |  8 +++++---
 fs/lustre/obdecho/echo_client.c |  4 ++--
 8 files changed, 34 insertions(+), 26 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 0f785e5..d068454 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -2548,14 +2548,16 @@ static inline struct cl_page *cl_page_list_first(struct cl_page_list *plist)
 	list_for_each_entry_safe((page), (temp), &(list)->pl_pages, cp_batch)
 
 void cl_page_list_init(struct cl_page_list *plist);
-void cl_page_list_add(struct cl_page_list *plist, struct cl_page *page);
+void cl_page_list_add(struct cl_page_list *plist, struct cl_page *page,
+		      bool get_ref);
 void cl_page_list_move(struct cl_page_list *dst, struct cl_page_list *src,
 		       struct cl_page *page);
 void cl_page_list_move_head(struct cl_page_list *dst, struct cl_page_list *src,
 			    struct cl_page *page);
-void cl_page_list_splice(struct cl_page_list *list, struct cl_page_list *head);
-void cl_page_list_del(const struct lu_env *env, struct cl_page_list *plist,
-		      struct cl_page *page);
+void cl_page_list_splice(struct cl_page_list *list,
+			 struct cl_page_list *head);
+void cl_page_list_del(const struct lu_env *env,
+		      struct cl_page_list *plist, struct cl_page *page);
 void cl_page_list_disown(const struct lu_env *env,
 			 struct cl_io *io, struct cl_page_list *plist);
 void cl_page_list_discard(const struct lu_env *env,
@@ -2563,10 +2565,10 @@ void cl_page_list_discard(const struct lu_env *env,
 void cl_page_list_fini(const struct lu_env *env, struct cl_page_list *plist);
 
 void cl_2queue_init(struct cl_2queue *queue);
-void cl_2queue_disown(const struct lu_env *env,
-		      struct cl_io *io, struct cl_2queue *queue);
-void cl_2queue_discard(const struct lu_env *env,
-		       struct cl_io *io, struct cl_2queue *queue);
+void cl_2queue_disown(const struct lu_env *env, struct cl_io *io,
+		      struct cl_2queue *queue);
+void cl_2queue_discard(const struct lu_env *env, struct cl_io *io,
+		       struct cl_2queue *queue);
 void cl_2queue_fini(const struct lu_env *env, struct cl_2queue *queue);
 void cl_2queue_init_page(struct cl_2queue *queue, struct cl_page *page);
 
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 5610523..7b8f1b5 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1884,7 +1884,7 @@ int ll_io_zero_page(struct inode *inode, pgoff_t index, pgoff_t offset,
 		anchor = &vvp_env_info(env)->vti_anchor;
 		cl_sync_io_init(anchor, 1);
 		clpage->cp_sync_io = anchor;
-		cl_page_list_add(&queue->c2_qin, clpage);
+		cl_page_list_add(&queue->c2_qin, clpage, true);
 		rc = cl_io_submit_rw(env, io, CRT_WRITE, queue);
 		if (rc)
 			goto queuefini1;
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 4de77f6..48984aa 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -249,7 +249,7 @@ static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 			vpg->vpg_defer_uptodate = 1;
 			vpg->vpg_ra_used = 0;
 		}
-		cl_page_list_add(queue, page);
+		cl_page_list_add(queue, page, true);
 	} else {
 		/* skip completed pages */
 		cl_page_unassume(env, io, page);
@@ -1657,7 +1657,7 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 		cl_sync_io_init(anchor, 1);
 		page->cp_sync_io = anchor;
 
-		cl_page_list_add(&queue->c2_qin, page);
+		cl_page_list_add(&queue->c2_qin, page, true);
 	}
 
 	io_start_index = cl_index(io->ci_obj, io->u.ci_rw.crw_pos);
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 0d72c3e..e5d80cb 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -264,7 +264,10 @@ struct ll_dio_pages {
 			 */
 			page->cp_inode = inode;
 		}
-		cl_page_list_add(&queue->c2_qin, page);
+		/* We keep the refcount from cl_page_find, so we don't need
+		 * another one here
+		 */
+		cl_page_list_add(&queue->c2_qin, page, false);
 		/*
 		 * Set page clip to tell transfer formation engine
 		 * that page has to be sent even if it is beyond KMS.
@@ -273,8 +276,6 @@ struct ll_dio_pages {
 			cl_page_clip(env, page, 0, size);
 		++io_pages;
 
-		/* drop the reference count for cl_page_find */
-		cl_page_put(env, page);
 		offset += page_size;
 		size -= page_size;
 	}
@@ -731,7 +732,7 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
 		lcc->lcc_page = NULL; /* page will be queued */
 
 		/* Add it into write queue */
-		cl_page_list_add(plist, page);
+		cl_page_list_add(plist, page, true);
 		if (plist->pl_nr == 1) /* first page */
 			vio->u.readwrite.vui_from = from;
 		else
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 0e54f46..a117800 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -1444,7 +1444,7 @@ static int vvp_io_fault_start(const struct lu_env *env,
 			cl_page_assume(env, io, page);
 
 			cl_page_list_init(plist);
-			cl_page_list_add(plist, page);
+			cl_page_list_add(plist, page, true);
 
 			/* size fixup */
 			if (last_index == vvp_index(vpg))
@@ -1466,7 +1466,7 @@ static int vvp_io_fault_start(const struct lu_env *env,
 				if (result >= 0) {
 					io->ci_noquota = 1;
 					cl_page_own(env, io, page);
-					cl_page_list_add(plist, page);
+					cl_page_list_add(plist, page, true);
 					lu_ref_add(&page->cp_reference,
 						   "cl_io", io);
 					result = cl_io_commit_async(env, io,
diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
index 9e14898..60a28d6 100644
--- a/fs/lustre/llite/vvp_page.c
+++ b/fs/lustre/llite/vvp_page.c
@@ -459,16 +459,19 @@ int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 	vpg->vpg_page = vmpage;
 	get_page(vmpage);
 
-	if (page->cp_type == CPT_CACHEABLE) {
+	if (page->cp_type == CPT_TRANSIENT) {
+		/* DIO pages are referenced by userspace, we don't need to take
+		 * a reference on them. (contrast with get_page() call above)
+		 */
+		cl_page_slice_add(page, &vpg->vpg_cl, obj,
+				  &vvp_transient_page_ops);
+	} else {
 		/* in cache, decref in vvp_page_delete */
 		refcount_inc(&page->cp_ref);
 		SetPagePrivate(vmpage);
 		vmpage->private = (unsigned long)page;
 		cl_page_slice_add(page, &vpg->vpg_cl, obj,
 				  &vvp_page_ops);
-	} else {
-		cl_page_slice_add(page, &vpg->vpg_cl, obj,
-				  &vvp_transient_page_ops);
 	}
 	return 0;
 }
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index b5e7744b..9a0373f 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -825,7 +825,8 @@ void cl_page_list_init(struct cl_page_list *plist)
 /**
  * Adds a page to a page list.
  */
-void cl_page_list_add(struct cl_page_list *plist, struct cl_page *page)
+void cl_page_list_add(struct cl_page_list *plist, struct cl_page *page,
+		      bool get_ref)
 {
 	/* it would be better to check that page is owned by "current" io, but
 	 * it is not passed here.
@@ -836,7 +837,8 @@ void cl_page_list_add(struct cl_page_list *plist, struct cl_page *page)
 	list_add_tail(&page->cp_batch, &plist->pl_pages);
 	++plist->pl_nr;
 	lu_ref_add_at(&page->cp_reference, &page->cp_queue_ref, "queue", plist);
-	cl_page_get(page);
+	if (get_ref)
+		cl_page_get(page);
 }
 EXPORT_SYMBOL(cl_page_list_add);
 
@@ -1019,7 +1021,7 @@ void cl_2queue_init_page(struct cl_2queue *queue, struct cl_page *page)
 	/*
 	 * Add a page to the incoming page list of 2-queue.
 	 */
-	cl_page_list_add(&queue->c2_qin, page);
+	cl_page_list_add(&queue->c2_qin, page, true);
 }
 EXPORT_SYMBOL(cl_2queue_init_page);
 
diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index c3a12ce..4cc046a 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -1021,7 +1021,7 @@ static void echo_commit_callback(const struct lu_env *env, struct cl_io *io,
 		struct page *vmpage = pvec->pages[i];
 		struct cl_page *page = (struct cl_page *)vmpage->private;
 
-		cl_page_list_add(&queue->c2_qout, page);
+		cl_page_list_add(&queue->c2_qout, page, true);
 	}
 }
 
@@ -1085,7 +1085,7 @@ static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
 		/*
 		 * Add a page to the incoming page list of 2-queue.
 		 */
-		cl_page_list_add(&queue->c2_qin, clp);
+		cl_page_list_add(&queue->c2_qin, clp, true);
 
 		/* drop the reference count for cl_page_find, so that the page
 		 * will be freed in cl_2queue_fini.
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
