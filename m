From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:06 -0500
Subject: [lustre-devel] [PATCH 498/622] lustre: vvp: dirty pages with pagevec
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-499-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

When doing i/o from multiple writers to a single file, the
per-file page cache lock (the mapping lock) becomes a
bottleneck.

Most current uses are single page at a time.  This converts
one prominent use, marking page as dirty, to use a pagevec.

When many threads are writing to one file, this improves
write performance by around 25%.

This requires implementing our own version of the
set_page_dirty-->__set_page_dirty_nobuffers functions.

This was modeled on upstream tip of tree:
v5.2-rc4-224-ge01e060fe0 (7/13/2019)

The relevant code is unchanged since Linux 4.17, and has
changed only minimally since before Linux 2.6.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9920
Lustre-commit: a7299cb012f8 ("LU-9920 vvp: dirty pages with pagevec")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/28711
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h   |   2 +-
 fs/lustre/include/lustre_osc.h  |   6 +--
 fs/lustre/llite/llite_lib.c     |   5 +-
 fs/lustre/llite/vvp_io.c        | 102 +++++++++++++++++++++++++++++++++++-----
 fs/lustre/mdc/mdc_request.c     |   7 +--
 fs/lustre/obdecho/echo_client.c |  11 ++++-
 fs/lustre/osc/osc_cache.c       |  13 ++++-
 fs/lustre/osc/osc_io.c          |  23 +++++++--
 fs/lustre/osc/osc_page.c        |   7 ++-
 mm/page-writeback.c             |   1 +
 10 files changed, 144 insertions(+), 33 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 4c68d7b..75ece62 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1458,7 +1458,7 @@ struct cl_io_slice {
 };
 
 typedef void (*cl_commit_cbt)(const struct lu_env *, struct cl_io *,
-			      struct cl_page *);
+			      struct pagevec *);
 
 struct cl_read_ahead {
 	/*
diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index de7ccd6..2cd23f2 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -584,9 +584,9 @@ int osc_set_async_flags(struct osc_object *obj, struct osc_page *opg,
 int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
 			struct page *page, loff_t offset);
 int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
-		       struct osc_page *ops);
-int osc_page_cache_add(const struct lu_env *env,
-		       const struct cl_page_slice *slice, struct cl_io *io);
+		       struct osc_page *ops, cl_commit_cbt cb);
+int osc_page_cache_add(const struct lu_env *env, struct osc_page *opg,
+		       struct cl_io *io, cl_commit_cbt cb);
 int osc_teardown_async_page(const struct lu_env *env, struct osc_object *obj,
 			    struct osc_page *ops);
 int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index ad7c2e2..5d74f30 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2149,6 +2149,7 @@ void ll_delete_inode(struct inode *inode)
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct address_space *mapping = &inode->i_data;
 	unsigned long nrpages;
+	unsigned long flags;
 
 	if (S_ISREG(inode->i_mode) && lli->lli_clob) {
 		/* It is last chance to write out dirty pages,
@@ -2172,9 +2173,9 @@ void ll_delete_inode(struct inode *inode)
 	 */
 	nrpages = mapping->nrpages;
 	if (nrpages) {
-		xa_lock_irq(&mapping->i_pages);
+		xa_lock_irqsave(&mapping->i_pages, flags);
 		nrpages = mapping->nrpages;
-		xa_unlock_irq(&mapping->i_pages);
+		xa_unlock_irqrestore(&mapping->i_pages, flags);
 	} /* Workaround end */
 
 	LASSERTF(nrpages == 0,
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index d0d8b1f..aa8f2e1 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -39,7 +39,8 @@
 #define DEBUG_SUBSYSTEM S_LLITE
 
 #include <obd.h>
-
+#include <linux/pagevec.h>
+#include <linux/memcontrol.h>
 #include "llite_internal.h"
 #include "vvp_internal.h"
 
@@ -860,19 +861,98 @@ static int vvp_io_commit_sync(const struct lu_env *env, struct cl_io *io,
 	return bytes > 0 ? bytes : rc;
 }
 
+/* Taken from kernel set_page_dirty, __set_page_dirty_nobuffers
+ * Last change to this area: b93b016313b3ba8003c3b8bb71f569af91f19fc7
+ *
+ * Current with Linus tip of tree (7/13/2019):
+ * v5.2-rc4-224-ge01e060fe0
+ *
+ */
+void vvp_set_pagevec_dirty(struct pagevec *pvec)
+{
+	struct page *page = pvec->pages[0];
+	struct address_space *mapping = page->mapping;
+	unsigned long flags;
+	int count = pagevec_count(pvec);
+	int dirtied = 0;
+	int i = 0;
+
+	/* From set_page_dirty */
+	for (i = 0; i < count; i++)
+		ClearPageReclaim(pvec->pages[i]);
+
+	LASSERTF(page->mapping,
+		 "mapping must be set. page %p, page->private (cl_page) %p",
+		 page, (void *) page->private);
+
+	/* Rest of code derived from __set_page_dirty_nobuffers */
+	xa_lock_irqsave(&mapping->i_pages, flags);
+
+	/* Notes on differences with __set_page_dirty_nobuffers:
+	 * 1. We don't need to call page_mapping because we know this is a page
+	 * cache page.
+	 * 2. We have the pages locked, so there is no need for the careful
+	 * mapping/mapping2 dance.
+	 * 3. No mapping is impossible. (Race w/truncate mentioned in
+	 * dirty_nobuffers should be impossible because we hold the page lock.)
+	 * 4. All mappings are the same because i/o is only to one file.
+	 * 5. We invert the lock order on lock_page_memcg(page) and the mapping
+	 * xa_lock, but this is the only function that should use that pair of
+	 * locks and it can't race because Lustre locks pages throughout i/o.
+	 */
+	for (i = 0; i < count; i++) {
+		page = pvec->pages[i];
+		lock_page_memcg(page);
+		if (TestSetPageDirty(page)) {
+			unlock_page_memcg(page);
+			continue;
+		}
+		LASSERTF(page->mapping == mapping,
+			 "all pages must have the same mapping.  page %p, mapping %p, first mapping %p\n",
+			 page, page->mapping, mapping);
+		WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
+		account_page_dirtied(page, mapping);
+		__xa_set_mark(&mapping->i_pages, page_index(page),
+			      PAGECACHE_TAG_DIRTY);
+		dirtied++;
+		unlock_page_memcg(page);
+	}
+	xa_unlock_irqrestore(&mapping->i_pages, flags);
+
+	CDEBUG(D_VFSTRACE, "mapping %p, count %d, dirtied %d\n", mapping,
+	       count, dirtied);
+
+	if (mapping->host && dirtied) {
+		/* !PageAnon && !swapper_space */
+		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
+	}
+}
+
 static void write_commit_callback(const struct lu_env *env, struct cl_io *io,
-				  struct cl_page *page)
+				  struct pagevec *pvec)
 {
-	struct page *vmpage = page->cp_vmpage;
+	struct cl_page *page;
+	struct page *vmpage;
+	int count = 0;
+	int i = 0;
 
-	SetPageUptodate(vmpage);
-	set_page_dirty(vmpage);
+	count = pagevec_count(pvec);
+	LASSERT(count > 0);
 
-	cl_page_disown(env, io, page);
+	for (i = 0; i < count; i++) {
+		vmpage = pvec->pages[i];
+		SetPageUptodate(vmpage);
+	}
+
+	vvp_set_pagevec_dirty(pvec);
 
-	/* held in ll_cl_init() */
-	lu_ref_del(&page->cp_reference, "cl_io", cl_io_top(io));
-	cl_page_put(env, page);
+	for (i = 0; i < count; i++) {
+		vmpage = pvec->pages[i];
+		page = (struct cl_page *) vmpage->private;
+		cl_page_disown(env, io, page);
+		lu_ref_del(&page->cp_reference, "cl_io", cl_io_top(io));
+		cl_page_put(env, page);
+	}
 }
 
 /* make sure the page list is contiguous */
@@ -1128,9 +1208,9 @@ static int vvp_io_kernel_fault(struct vvp_fault_io *cfio)
 }
 
 static void mkwrite_commit_callback(const struct lu_env *env, struct cl_io *io,
-				    struct cl_page *page)
+				    struct pagevec *pvec)
 {
-	set_page_dirty(page->cp_vmpage);
+	vvp_set_pagevec_dirty(pvec);
 }
 
 static int vvp_io_fault_start(const struct lu_env *env,
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 34cf177..287013f 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -1138,16 +1138,17 @@ static struct page *mdc_page_locate(struct address_space *mapping, u64 *hash,
 	 */
 	unsigned long offset = hash_x_index(*hash, hash64);
 	struct page *page;
+	unsigned long flags;
 	int found;
 
-	xa_lock_irq(&mapping->i_pages);
+	xa_lock_irqsave(&mapping->i_pages, flags);
 	found = radix_tree_gang_lookup(&mapping->i_pages,
 				       (void **)&page, offset, 1);
 	if (found > 0 && !xa_is_value(page)) {
 		struct lu_dirpage *dp;
 
 		get_page(page);
-		xa_unlock_irq(&mapping->i_pages);
+		xa_unlock_irqrestore(&mapping->i_pages, flags);
 		/*
 		 * In contrast to find_lock_page() we are sure that directory
 		 * page cannot be truncated (while DLM lock is held) and,
@@ -1197,7 +1198,7 @@ static struct page *mdc_page_locate(struct address_space *mapping, u64 *hash,
 			page = ERR_PTR(-EIO);
 		}
 	} else {
-		xa_unlock_irq(&mapping->i_pages);
+		xa_unlock_irqrestore(&mapping->i_pages, flags);
 		page = NULL;
 	}
 	return page;
diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index 172fe11..8e04636 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -998,16 +998,23 @@ static int __cl_echo_cancel(struct lu_env *env, struct echo_device *ed,
 }
 
 static void echo_commit_callback(const struct lu_env *env, struct cl_io *io,
-				 struct cl_page *page)
+				 struct pagevec *pvec)
 {
 	struct echo_thread_info *info;
 	struct cl_2queue *queue;
+	int i = 0;
 
 	info = echo_env_info(env);
 	LASSERT(io == &info->eti_io);
 
 	queue = &info->eti_queue;
-	cl_page_list_add(&queue->c2_qout, page);
+
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		struct page *vmpage = pvec->pages[i];
+		struct cl_page *page = (struct cl_page *)vmpage->private;
+
+		cl_page_list_add(&queue->c2_qout, page);
+	}
 }
 
 static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 3d47c02..dde03bd 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2303,13 +2303,14 @@ int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
 EXPORT_SYMBOL(osc_prep_async_page);
 
 int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
-		       struct osc_page *ops)
+		       struct osc_page *ops, cl_commit_cbt cb)
 {
 	struct osc_io *oio = osc_env_io(env);
 	struct osc_extent *ext = NULL;
 	struct osc_async_page *oap = &ops->ops_oap;
 	struct client_obd *cli = oap->oap_cli;
 	struct osc_object *osc = oap->oap_obj;
+	struct pagevec        *pvec = &osc_env_info(env)->oti_pagevec;
 	pgoff_t index;
 	unsigned int grants = 0, tmp;
 	int brw_flags = OBD_BRW_ASYNC;
@@ -2431,7 +2432,15 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 
 		rc = 0;
 		if (grants == 0) {
-			/* we haven't allocated grant for this page. */
+			/* We haven't allocated grant for this page, and we
+			 * must not hold a page lock while we do enter_cache,
+			 * so we must mark dirty & unlock any pages in the
+			 * write commit pagevec.
+			 */
+			if (pagevec_count(pvec)) {
+				cb(env, io, pvec);
+				pagevec_reinit(pvec);
+			}
 			rc = osc_enter_cache(env, cli, oap, tmp);
 			if (rc == 0)
 				grants = tmp;
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 8e299d4..f340266 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -40,6 +40,7 @@
 
 #include <lustre_obdo.h>
 #include <lustre_osc.h>
+#include <linux/pagevec.h>
 
 #include "osc_internal.h"
 
@@ -288,6 +289,7 @@ int osc_io_commit_async(const struct lu_env *env,
 	struct cl_page *page;
 	struct cl_page *last_page;
 	struct osc_page *opg;
+	struct pagevec  *pvec = &osc_env_info(env)->oti_pagevec;
 	int result = 0;
 
 	LASSERT(qin->pl_nr > 0);
@@ -306,6 +308,8 @@ int osc_io_commit_async(const struct lu_env *env,
 		}
 	}
 
+	pagevec_init(pvec);
+
 	while (qin->pl_nr > 0) {
 		struct osc_async_page *oap;
 
@@ -325,7 +329,7 @@ int osc_io_commit_async(const struct lu_env *env,
 
 		/* The page may be already in dirty cache. */
 		if (list_empty(&oap->oap_pending_item)) {
-			result = osc_page_cache_add(env, &opg->ops_cl, io);
+			result = osc_page_cache_add(env, opg, io, cb);
 			if (result != 0)
 				break;
 		}
@@ -335,12 +339,21 @@ int osc_io_commit_async(const struct lu_env *env,
 
 		cl_page_list_del(env, qin, page);
 
-		(*cb)(env, io, page);
-		/* Can't access page any more. Page can be in transfer and
-		 * complete at any time.
-		 */
+		/* if there are no more slots, do the callback & reinit */
+		if (pagevec_add(pvec, page->cp_vmpage) == 0) {
+			(*cb)(env, io, pvec);
+			pagevec_reinit(pvec);
+		}
 	}
 
+	/* Clean up any partially full pagevecs */
+	if (pagevec_count(pvec) != 0)
+		(*cb)(env, io, pvec);
+
+	/* Can't access these pages any more. Page can be in transfer and
+	 * complete at any time.
+	 */
+
 	/* for sync write, kernel will wait for this page to be flushed before
 	 * osc_io_end() is called, so release it earlier.
 	 * for mkwrite(), it's known there is no further pages.
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index 0910f3a..6685968 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -92,14 +92,13 @@ static void osc_page_transfer_add(const struct lu_env *env,
 	osc_lru_use(osc_cli(obj), opg);
 }
 
-int osc_page_cache_add(const struct lu_env *env,
-		       const struct cl_page_slice *slice, struct cl_io *io)
+int osc_page_cache_add(const struct lu_env *env, struct osc_page *opg,
+		       struct cl_io *io, cl_commit_cbt cb)
 {
-	struct osc_page *opg = cl2osc_page(slice);
 	int result;
 
 	osc_page_transfer_get(opg, "transfer\0cache");
-	result = osc_queue_async_io(env, io, opg);
+	result = osc_queue_async_io(env, io, opg, cb);
 	if (result != 0)
 		osc_page_transfer_put(env, opg);
 	else
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 50055d2..3b5a43d 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2433,6 +2433,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 		mem_cgroup_track_foreign_dirty(page, wb);
 	}
 }
+EXPORT_SYMBOL(account_page_dirtied);
 
 /*
  * Helper function for deaccounting dirty page without writeback.
-- 
1.8.3.1
