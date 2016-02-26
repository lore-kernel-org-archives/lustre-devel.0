From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Fri, 26 Feb 2016 01:49:51 -0500
Subject: [lustre-devel] [PATCH 03/25] staging/lustre/fld: Fix style vs open
	parenthesis alignment
In-Reply-To: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
References: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456469413-931943-4-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This mostly fixes checkpatch complaints about
"Alignment should match open parenthesis"

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/fld/fld_cache.c   | 14 +++++++-------
 drivers/staging/lustre/lustre/fld/fld_request.c | 17 +++++++----------
 drivers/staging/lustre/lustre/fld/lproc_fld.c   |  3 +--
 3 files changed, 15 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fld/fld_cache.c b/drivers/staging/lustre/lustre/fld/fld_cache.c
index 2b09b76..062f388 100644
--- a/drivers/staging/lustre/lustre/fld/fld_cache.c
+++ b/drivers/staging/lustre/lustre/fld/fld_cache.c
@@ -233,7 +233,7 @@ static int fld_cache_shrink(struct fld_cache *cache)
 	}
 
 	CDEBUG(D_INFO, "%s: FLD cache - Shrunk by %d entries\n",
-			cache->fci_name, num);
+	       cache->fci_name, num);
 
 	return 0;
 }
@@ -294,8 +294,8 @@ static void fld_cache_punch_hole(struct fld_cache *cache,
  * handle range overlap in fld cache.
  */
 static void fld_cache_overlap_handle(struct fld_cache *cache,
-				struct fld_cache_entry *f_curr,
-				struct fld_cache_entry *f_new)
+				     struct fld_cache_entry *f_curr,
+				     struct fld_cache_entry *f_new)
 {
 	const struct lu_seq_range *range = &f_new->fce_range;
 	const u64 new_start  = range->lsr_start;
@@ -402,8 +402,8 @@ static int fld_cache_insert_nolock(struct fld_cache *cache,
 	list_for_each_entry_safe(f_curr, n, head, fce_list) {
 		/* add list if next is end of list */
 		if (new_end < f_curr->fce_range.lsr_start ||
-		   (new_end == f_curr->fce_range.lsr_start &&
-		    new_flags != f_curr->fce_range.lsr_flags))
+		    (new_end == f_curr->fce_range.lsr_start &&
+		     new_flags != f_curr->fce_range.lsr_flags))
 			break;
 
 		prev = &f_curr->fce_list;
@@ -460,8 +460,8 @@ struct fld_cache_entry
 	head = &cache->fci_entries_head;
 	list_for_each_entry(flde, head, fce_list) {
 		if (range->lsr_start == flde->fce_range.lsr_start ||
-		   (range->lsr_end == flde->fce_range.lsr_end &&
-		    range->lsr_flags == flde->fce_range.lsr_flags)) {
+		    (range->lsr_end == flde->fce_range.lsr_end &&
+		     range->lsr_flags == flde->fce_range.lsr_flags)) {
 			got = flde;
 			break;
 		}
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index b50a57b..19b81c9 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -148,7 +148,7 @@ again:
 	}
 
 	CERROR("%s: Can't find target by hash %d (seq %#llx). Targets (%d):\n",
-		fld->lcf_name, hash, seq, fld->lcf_count);
+	       fld->lcf_name, hash, seq, fld->lcf_count);
 
 	list_for_each_entry(target, &fld->lcf_targets, ft_chain) {
 		const char *srv_name = target->ft_srv ?
@@ -217,11 +217,11 @@ int fld_client_add_target(struct lu_client_fld *fld,
 
 	if (fld->lcf_flags != LUSTRE_FLD_INIT) {
 		CERROR("%s: Attempt to add target %s (idx %llu) on fly - skip it\n",
-			fld->lcf_name, name, tar->ft_idx);
+		       fld->lcf_name, name, tar->ft_idx);
 		return 0;
 	}
 	CDEBUG(D_INFO, "%s: Adding target %s (idx %llu)\n",
-			fld->lcf_name, name, tar->ft_idx);
+	       fld->lcf_name, name, tar->ft_idx);
 
 	target = kzalloc(sizeof(*target), GFP_NOFS);
 	if (!target)
@@ -244,8 +244,7 @@ int fld_client_add_target(struct lu_client_fld *fld,
 	target->ft_srv = tar->ft_srv;
 	target->ft_idx = tar->ft_idx;
 
-	list_add_tail(&target->ft_chain,
-			  &fld->lcf_targets);
+	list_add_tail(&target->ft_chain, &fld->lcf_targets);
 
 	fld->lcf_count++;
 	spin_unlock(&fld->lcf_lock);
@@ -260,8 +259,7 @@ int fld_client_del_target(struct lu_client_fld *fld, __u64 idx)
 	struct lu_fld_target *target, *tmp;
 
 	spin_lock(&fld->lcf_lock);
-	list_for_each_entry_safe(target, tmp,
-				     &fld->lcf_targets, ft_chain) {
+	list_for_each_entry_safe(target, tmp, &fld->lcf_targets, ft_chain) {
 		if (target->ft_idx == idx) {
 			fld->lcf_count--;
 			list_del(&target->ft_chain);
@@ -376,8 +374,7 @@ void fld_client_fini(struct lu_client_fld *fld)
 	struct lu_fld_target *target, *tmp;
 
 	spin_lock(&fld->lcf_lock);
-	list_for_each_entry_safe(target, tmp,
-				     &fld->lcf_targets, ft_chain) {
+	list_for_each_entry_safe(target, tmp, &fld->lcf_targets, ft_chain) {
 		fld->lcf_count--;
 		list_del(&target->ft_chain);
 		if (target->ft_exp)
@@ -467,7 +464,7 @@ int fld_client_lookup(struct lu_client_fld *fld, u64 seq, u32 *mds,
 	LASSERT(target);
 
 	CDEBUG(D_INFO, "%s: Lookup fld entry (seq: %#llx) on target %s (idx %llu)\n",
-			fld->lcf_name, seq, fld_target_name(target), target->ft_idx);
+	       fld->lcf_name, seq, fld_target_name(target), target->ft_idx);
 
 	res.lsr_start = seq;
 	fld_range_set_type(&res, flags);
diff --git a/drivers/staging/lustre/lustre/fld/lproc_fld.c b/drivers/staging/lustre/lustre/fld/lproc_fld.c
index da31281..ca898be 100644
--- a/drivers/staging/lustre/lustre/fld/lproc_fld.c
+++ b/drivers/staging/lustre/lustre/fld/lproc_fld.c
@@ -61,8 +61,7 @@ fld_debugfs_targets_seq_show(struct seq_file *m, void *unused)
 	struct lu_fld_target *target;
 
 	spin_lock(&fld->lcf_lock);
-	list_for_each_entry(target,
-				&fld->lcf_targets, ft_chain)
+	list_for_each_entry(target, &fld->lcf_targets, ft_chain)
 		seq_printf(m, "%s\n", fld_target_name(target));
 	spin_unlock(&fld->lcf_lock);
 
-- 
2.1.0
