From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:13 -0500
Subject: [lustre-devel] [PATCH 09/26] lustre: cleanup white spaces in fid
 and fld layer
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The lustre code is very messy and difficult to read. Remove excess
white space and properly align data structures so they are easy on
the eyes.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/fid/fid_request.c  | 10 +++++-----
 drivers/staging/lustre/lustre/fid/lproc_fid.c    |  2 +-
 drivers/staging/lustre/lustre/fld/fld_cache.c    | 14 +++++++-------
 drivers/staging/lustre/lustre/fld/fld_internal.h | 24 ++++++++++++------------
 drivers/staging/lustre/lustre/fld/fld_request.c  |  8 ++++----
 5 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index 3f79f22..45dd275 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -55,12 +55,12 @@ static int seq_client_rpc(struct lu_client_seq *seq,
 			  struct lu_seq_range *output, u32 opc,
 			  const char *opcname)
 {
-	struct obd_export     *exp = seq->lcs_exp;
+	struct obd_export *exp = seq->lcs_exp;
 	struct ptlrpc_request *req;
-	struct lu_seq_range   *out, *in;
-	u32                 *op;
-	unsigned int           debug_mask;
-	int                    rc;
+	struct lu_seq_range *out, *in;
+	u32 *op;
+	unsigned int debug_mask;
+	int rc;
 
 	LASSERT(exp && !IS_ERR(exp));
 	req = ptlrpc_request_alloc_pack(class_exp2cliimp(exp), &RQF_SEQ_QUERY,
diff --git a/drivers/staging/lustre/lustre/fid/lproc_fid.c b/drivers/staging/lustre/lustre/fid/lproc_fid.c
index d583778..d7d23b4 100644
--- a/drivers/staging/lustre/lustre/fid/lproc_fid.c
+++ b/drivers/staging/lustre/lustre/fid/lproc_fid.c
@@ -143,7 +143,7 @@
 			     size_t count, loff_t *off)
 {
 	struct lu_client_seq *seq;
-	u64  max;
+	u64 max;
 	int rc, val;
 
 	seq = ((struct seq_file *)file->private_data)->private;
diff --git a/drivers/staging/lustre/lustre/fld/fld_cache.c b/drivers/staging/lustre/lustre/fld/fld_cache.c
index 749d33b..b4baa53 100644
--- a/drivers/staging/lustre/lustre/fld/fld_cache.c
+++ b/drivers/staging/lustre/lustre/fld/fld_cache.c
@@ -255,8 +255,8 @@ static void fld_cache_punch_hole(struct fld_cache *cache,
 				 struct fld_cache_entry *f_new)
 {
 	const struct lu_seq_range *range = &f_new->fce_range;
-	const u64 new_start  = range->lsr_start;
-	const u64 new_end  = range->lsr_end;
+	const u64 new_start = range->lsr_start;
+	const u64 new_end = range->lsr_end;
 	struct fld_cache_entry *fldt;
 
 	fldt = kzalloc(sizeof(*fldt), GFP_ATOMIC);
@@ -294,8 +294,8 @@ static void fld_cache_overlap_handle(struct fld_cache *cache,
 				     struct fld_cache_entry *f_new)
 {
 	const struct lu_seq_range *range = &f_new->fce_range;
-	const u64 new_start  = range->lsr_start;
-	const u64 new_end  = range->lsr_end;
+	const u64 new_start = range->lsr_start;
+	const u64 new_end = range->lsr_end;
 	const u32 mdt = range->lsr_index;
 
 	/* this is overlap case, these case are checking overlapping with
@@ -381,8 +381,8 @@ static int fld_cache_insert_nolock(struct fld_cache *cache,
 	struct fld_cache_entry *n;
 	struct list_head *head;
 	struct list_head *prev = NULL;
-	const u64 new_start  = f_new->fce_range.lsr_start;
-	const u64 new_end  = f_new->fce_range.lsr_end;
+	const u64 new_start = f_new->fce_range.lsr_start;
+	const u64 new_end = f_new->fce_range.lsr_end;
 	u32 new_flags  = f_new->fce_range.lsr_flags;
 
 	/*
@@ -425,7 +425,7 @@ static int fld_cache_insert_nolock(struct fld_cache *cache,
 int fld_cache_insert(struct fld_cache *cache,
 		     const struct lu_seq_range *range)
 {
-	struct fld_cache_entry	*flde;
+	struct fld_cache_entry *flde;
 	int rc;
 
 	flde = fld_cache_entry_create(range);
diff --git a/drivers/staging/lustre/lustre/fld/fld_internal.h b/drivers/staging/lustre/lustre/fld/fld_internal.h
index 66a0fb6..76666a4 100644
--- a/drivers/staging/lustre/lustre/fld/fld_internal.h
+++ b/drivers/staging/lustre/lustre/fld/fld_internal.h
@@ -75,10 +75,10 @@ struct lu_fld_hash {
 };
 
 struct fld_cache_entry {
-	struct list_head	       fce_lru;
-	struct list_head	       fce_list;
+	struct list_head	fce_lru;
+	struct list_head	fce_list;
 	/** fld cache entries are sorted on range->lsr_start field. */
-	struct lu_seq_range      fce_range;
+	struct lu_seq_range	fce_range;
 };
 
 struct fld_cache {
@@ -86,29 +86,29 @@ struct fld_cache {
 	 * Cache guard, protects fci_hash mostly because others immutable after
 	 * init is finished.
 	 */
-	rwlock_t		 fci_lock;
+	rwlock_t		fci_lock;
 
 	/** Cache shrink threshold */
-	int		      fci_threshold;
+	int			fci_threshold;
 
 	/** Preferred number of cached entries */
-	int		      fci_cache_size;
+	int			fci_cache_size;
 
 	/** Current number of cached entries. Protected by \a fci_lock */
-	int		      fci_cache_count;
+	int			fci_cache_count;
 
 	/** LRU list fld entries. */
-	struct list_head	       fci_lru;
+	struct list_head	fci_lru;
 
 	/** sorted fld entries. */
-	struct list_head	       fci_entries_head;
+	struct list_head	fci_entries_head;
 
 	/** Cache statistics. */
-	struct fld_stats	 fci_stat;
+	struct fld_stats	fci_stat;
 
 	/** Cache name used for debug and messages. */
-	char		     fci_name[LUSTRE_MDT_MAXNAMELEN];
-	unsigned int		 fci_no_shrink:1;
+	char			fci_name[LUSTRE_MDT_MAXNAMELEN];
+	unsigned int		fci_no_shrink:1;
 };
 
 enum {
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index 8a915b9..248fffa 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -307,10 +307,10 @@ int fld_client_rpc(struct obd_export *exp,
 		   struct ptlrpc_request **reqp)
 {
 	struct ptlrpc_request *req = NULL;
-	struct lu_seq_range   *prange;
-	u32		 *op;
-	int		    rc = 0;
-	struct obd_import     *imp;
+	struct lu_seq_range *prange;
+	u32 *op;
+	int rc = 0;
+	struct obd_import *imp;
 
 	LASSERT(exp);
 
-- 
1.8.3.1
