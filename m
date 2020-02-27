From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:01 -0500
Subject: [lustre-devel] [PATCH 253/622] lustre: ptlrpc: Fix style issues for
 sec_bulk.c
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-254-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Arshad Hussain <arshad.super@gmail.com>

This patch fixes issues reported by checkpatch
for file fs/lustre/ptlrpc/sec_bulk.c

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: a294ea9a0e04 ("LU-6142 ptlrpc: Fix style issues for sec_bulk.c")
Signed-off-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-on: https://review.whamcloud.com/34548
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/sec_bulk.c | 71 ++++++++++++++++++++-------------------------
 1 file changed, 32 insertions(+), 39 deletions(-)

diff --git a/fs/lustre/ptlrpc/sec_bulk.c b/fs/lustre/ptlrpc/sec_bulk.c
index e170da1..d36230b 100644
--- a/fs/lustre/ptlrpc/sec_bulk.c
+++ b/fs/lustre/ptlrpc/sec_bulk.c
@@ -50,9 +50,9 @@
 
 #include "ptlrpc_internal.h"
 
-/****************************************
- * bulk encryption page pools	   *
- ****************************************/
+/*
+ * bulk encryption page pools
+ */
 
 #define POINTERS_PER_PAGE	(PAGE_SIZE / sizeof(void *))
 #define PAGES_PER_POOL		(POINTERS_PER_PAGE)
@@ -63,19 +63,16 @@
 #define CACHE_QUIESCENT_PERIOD  (20)
 
 static struct ptlrpc_enc_page_pool {
-	/*
-	 * constants
-	 */
-	unsigned long		epp_max_pages;	/* maximum pages can hold, const */
-	unsigned int		epp_max_pools;	/* number of pools, const */
+	unsigned long epp_max_pages;	/* maximum pages can hold, const */
+	unsigned int epp_max_pools;	/* number of pools, const */
 
 	/*
 	 * wait queue in case of not enough free pages.
 	 */
-	wait_queue_head_t	epp_waitq;	/* waiting threads */
-	unsigned int		epp_waitqlen;	/* wait queue length */
-	unsigned long		epp_pages_short; /* # of pages wanted of in-q users */
-	unsigned int		epp_growing:1;	/* during adding pages */
+	wait_queue_head_t epp_waitq;	/* waiting threads */
+	unsigned int epp_waitqlen;	/* wait queue length */
+	unsigned long epp_pages_short;	/* # of pages wanted of in-q users */
+	unsigned int epp_growing:1;	/* during adding pages */
 
 	/*
 	 * indicating how idle the pools are, from 0 to MAX_IDLE_IDX
@@ -84,36 +81,32 @@
 	 * is idled for a while but the idle_idx might still be low if no
 	 * activities happened in the pools.
 	 */
-	unsigned long		epp_idle_idx;
+	unsigned long epp_idle_idx;
 
 	/* last shrink time due to mem tight */
-	time64_t		epp_last_shrink;
-	time64_t		epp_last_access;
-
-	/*
-	 * in-pool pages bookkeeping
-	 */
-	spinlock_t		epp_lock;	 /* protect following fields */
-	unsigned long		epp_total_pages; /* total pages in pools */
-	unsigned long		epp_free_pages;	 /* current pages available */
-
-	/*
-	 * statistics
-	 */
-	unsigned long		epp_st_max_pages;	/* # of pages ever reached */
-	unsigned int		epp_st_grows;		/* # of grows */
-	unsigned int		epp_st_grow_fails;	/* # of add pages failures */
-	unsigned int		epp_st_shrinks;		/* # of shrinks */
-	unsigned long		epp_st_access;		/* # of access */
-	unsigned long		epp_st_missings;	/* # of cache missing */
-	unsigned long		epp_st_lowfree;		/* lowest free pages reached */
-	unsigned int		epp_st_max_wqlen;	/* highest waitqueue length */
-	ktime_t			epp_st_max_wait;	/* in nanoseconds */
-	unsigned long		epp_st_outofmem;	/* # of out of mem requests */
+	time64_t epp_last_shrink;
+	time64_t epp_last_access;
+
+	/* in-pool pages bookkeeping */
+	spinlock_t epp_lock;			/* protect following fields */
+	unsigned long epp_total_pages;		/* total pages in pools */
+	unsigned long epp_free_pages;		/* current pages available */
+
+	/* statistics */
+	unsigned long epp_st_max_pages;		/* # of pages ever reached */
+	unsigned int epp_st_grows;		/* # of grows */
+	unsigned int epp_st_grow_fails;		/* # of add pages failures */
+	unsigned int epp_st_shrinks;		/* # of shrinks */
+	unsigned long epp_st_access;		/* # of access */
+	unsigned long epp_st_missings;		/* # of cache missing */
+	unsigned long epp_st_lowfree;		/* lowest free pages reached */
+	unsigned int epp_st_max_wqlen;		/* highest waitqueue length */
+	ktime_t epp_st_max_wait;		/* in nanoseconds */
+	unsigned long epp_st_outofmem;		/* # of out of mem requests */
 	/*
-	 * pointers to pools
+	 * pointers to pools, may be vmalloc'd
 	 */
-	struct page		***epp_pools;
+	struct page ***epp_pools;
 } page_pools;
 
 /*
@@ -185,7 +178,7 @@ static void enc_pools_release_free_pages(long npages)
 
 	/* max pool index after the release */
 	p_idx_max1 = page_pools.epp_total_pages == 0 ? -1 :
-		     ((page_pools.epp_total_pages - 1) / PAGES_PER_POOL);
+		((page_pools.epp_total_pages - 1) / PAGES_PER_POOL);
 
 	p_idx = page_pools.epp_free_pages / PAGES_PER_POOL;
 	g_idx = page_pools.epp_free_pages % PAGES_PER_POOL;
-- 
1.8.3.1
