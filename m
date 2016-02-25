From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:26 -0500
Subject: [lustre-devel] [PATCH v2 43/84] staging/lustre/fld: Adjust comments
	to better conform to coding style
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-44-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This patch fixes "Block comments use a trailing */ on a separate line"
warnings from checkpatch.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/fld/fld_cache.c    |  9 ++++++---
 drivers/staging/lustre/lustre/fld/fld_internal.h | 24 ++++++++----------------
 drivers/staging/lustre/lustre/fld/fld_request.c  |  9 ++++++---
 3 files changed, 20 insertions(+), 22 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fld/fld_cache.c b/drivers/staging/lustre/lustre/fld/fld_cache.c
index a7026a9..2b09b76 100644
--- a/drivers/staging/lustre/lustre/fld/fld_cache.c
+++ b/drivers/staging/lustre/lustre/fld/fld_cache.c
@@ -183,7 +183,8 @@ restart_fixup:
 			}
 
 			/* we could have overlap over next
-			 * range too. better restart. */
+			 * range too. better restart.
+			 */
 			goto restart_fixup;
 		}
 
@@ -302,7 +303,8 @@ static void fld_cache_overlap_handle(struct fld_cache *cache,
 	const u32 mdt = range->lsr_index;
 
 	/* this is overlap case, these case are checking overlapping with
-	 * prev range only. fixup will handle overlapping with next range. */
+	 * prev range only. fixup will handle overlapping with next range.
+	 */
 
 	if (f_curr->fce_range.lsr_index == mdt) {
 		f_curr->fce_range.lsr_start = min(f_curr->fce_range.lsr_start,
@@ -317,7 +319,8 @@ static void fld_cache_overlap_handle(struct fld_cache *cache,
 	} else if (new_start <= f_curr->fce_range.lsr_start &&
 			f_curr->fce_range.lsr_end <= new_end) {
 		/* case 1: new range completely overshadowed existing range.
-		 *	 e.g. whole range migrated. update fld cache entry */
+		 *	 e.g. whole range migrated. update fld cache entry
+		 */
 
 		f_curr->fce_range = *range;
 		kfree(f_new);
diff --git a/drivers/staging/lustre/lustre/fld/fld_internal.h b/drivers/staging/lustre/lustre/fld/fld_internal.h
index ee36d6b..e8a3caf 100644
--- a/drivers/staging/lustre/lustre/fld/fld_internal.h
+++ b/drivers/staging/lustre/lustre/fld/fld_internal.h
@@ -67,8 +67,7 @@ struct lu_fld_hash {
 struct fld_cache_entry {
 	struct list_head	       fce_lru;
 	struct list_head	       fce_list;
-	/**
-	 * fld cache entries are sorted on range->lsr_start field. */
+	/** fld cache entries are sorted on range->lsr_start field. */
 	struct lu_seq_range      fce_range;
 };
 
@@ -79,32 +78,25 @@ struct fld_cache {
 	 */
 	rwlock_t		 fci_lock;
 
-	/**
-	 * Cache shrink threshold */
+	/** Cache shrink threshold */
 	int		      fci_threshold;
 
-	/**
-	 * Preferred number of cached entries */
+	/** Preferred number of cached entries */
 	int		      fci_cache_size;
 
-	/**
-	 * Current number of cached entries. Protected by \a fci_lock */
+	/** Current number of cached entries. Protected by \a fci_lock */
 	int		      fci_cache_count;
 
-	/**
-	 * LRU list fld entries. */
+	/** LRU list fld entries. */
 	struct list_head	       fci_lru;
 
-	/**
-	 * sorted fld entries. */
+	/** sorted fld entries. */
 	struct list_head	       fci_entries_head;
 
-	/**
-	 * Cache statistics. */
+	/** Cache statistics. */
 	struct fld_stats	 fci_stat;
 
-	/**
-	 * Cache name used for debug and messages. */
+	/** Cache name used for debug and messages. */
 	char		     fci_name[LUSTRE_MDT_MAXNAMELEN];
 	unsigned int		 fci_no_shrink:1;
 };
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index 0f0fbe4..b50a57b 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -58,7 +58,8 @@
 #include "fld_internal.h"
 
 /* TODO: these 3 functions are copies of flow-control code from mdc_lib.c
- * It should be common thing. The same about mdc RPC lock */
+ * It should be common thing. The same about mdc RPC lock
+ */
 static int fld_req_avail(struct client_obd *cli, struct mdc_cache_waiter *mcw)
 {
 	int rc;
@@ -124,7 +125,8 @@ fld_rrb_scan(struct lu_client_fld *fld, u64 seq)
 	 * it should go to index 0 directly, instead of calculating
 	 * hash again, and also if other MDTs is not being connected,
 	 * the fld lookup requests(for seq on MDT0) should not be
-	 * blocked because of other MDTs */
+	 * blocked because of other MDTs
+	 */
 	if (fid_seq_is_norm(seq))
 		hash = fld_rrb_hash(fld, seq);
 	else
@@ -139,7 +141,8 @@ again:
 	if (hash != 0) {
 		/* It is possible the remote target(MDT) are not connected to
 		 * with client yet, so we will refer this to MDT0, which should
-		 * be connected during mount */
+		 * be connected during mount
+		 */
 		hash = 0;
 		goto again;
 	}
-- 
2.1.0
