From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:13 -0400
Subject: [lustre-devel] [PATCH 03/32] staging/lustre: Remove ununused
	ll_ra_read_get()
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-4-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Also ll_ra_read_get_locked that was only used by it.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/llite/llite_internal.h   |  1 -
 drivers/staging/lustre/lustre/llite/rw.c           | 24 ----------------------
 2 files changed, 25 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 59fdbed..d6bdfed 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -657,7 +657,6 @@ static inline int ll_need_32bit_api(struct ll_sb_info *sbi)
 
 void ll_ra_read_in(struct file *f, struct ll_ra_read *rar);
 void ll_ra_read_ex(struct file *f, struct ll_ra_read *rar);
-struct ll_ra_read *ll_ra_read_get(struct file *f);
 
 /* llite/lproc_llite.c */
 int ldebugfs_register_mountpoint(struct dentry *parent,
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 8c1bfd2..71be194 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -417,30 +417,6 @@ void ll_ra_read_ex(struct file *f, struct ll_ra_read *rar)
 	spin_unlock(&ras->ras_lock);
 }
 
-static struct ll_ra_read *ll_ra_read_get_locked(struct ll_readahead_state *ras)
-{
-	struct ll_ra_read *scan;
-
-	list_for_each_entry(scan, &ras->ras_read_beads, lrr_linkage) {
-		if (scan->lrr_reader == current)
-			return scan;
-	}
-	return NULL;
-}
-
-struct ll_ra_read *ll_ra_read_get(struct file *f)
-{
-	struct ll_readahead_state *ras;
-	struct ll_ra_read	 *bead;
-
-	ras = ll_ras_get(f);
-
-	spin_lock(&ras->ras_lock);
-	bead = ll_ra_read_get_locked(ras);
-	spin_unlock(&ras->ras_lock);
-	return bead;
-}
-
 static int cl_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 			      struct cl_page_list *queue, struct cl_page *page,
 			      struct page *vmpage)
-- 
2.1.0
