From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:15 -0500
Subject: [lustre-devel] [PATCH 08/22] staging: lustre: clio: revise read
	ahead algorithm
In-Reply-To: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480726409-20350-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

ras_window_len should only be updated in ras_update() by read
pattern and it can't be adjusted in ll_readahead() at all;
ras_consecutive_pages is used to detect read pattern from
mmap. It will be used to increase read ahead window length
gradually.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5505
Reviewed-on: http://review.whamcloud.com/11528
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/llite/llite_internal.h   |    5 +-
 drivers/staging/lustre/lustre/llite/rw.c           |   71 +++++++++++---------
 2 files changed, 43 insertions(+), 33 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index ae0bb09..e37ba1f 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -1005,8 +1005,11 @@ int ll_xattr_list(struct inode *inode, const char *name, int type,
  */
 int cl_sb_init(struct super_block *sb);
 int cl_sb_fini(struct super_block *sb);
-void ll_io_init(struct cl_io *io, const struct file *file, int write);
 
+enum ras_update_flags {
+	LL_RAS_HIT  = 0x1,
+	LL_RAS_MMAP = 0x2
+};
 void ll_ra_count_put(struct ll_sb_info *sbi, unsigned long len);
 void ll_ra_stats_inc(struct inode *inode, enum ra_stat which);
 
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index e34017d..e2d5e75 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -457,30 +457,25 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 
 	spin_lock(&ras->ras_lock);
 
-	/* Enlarge the RA window to encompass the full read */
-	if (vio->vui_ra_valid &&
-	    ras->ras_window_start + ras->ras_window_len <
-	    vio->vui_ra_start + vio->vui_ra_count) {
-		ras->ras_window_len = vio->vui_ra_start + vio->vui_ra_count -
-				      ras->ras_window_start;
-	}
+	/**
+	 * Note: other thread might rollback the ras_next_readahead,
+	 * if it can not get the full size of prepared pages, see the
+	 * end of this function. For stride read ahead, it needs to
+	 * make sure the offset is no less than ras_stride_offset,
+	 * so that stride read ahead can work correctly.
+	 */
+	if (stride_io_mode(ras))
+		start = max(ras->ras_next_readahead, ras->ras_stride_offset);
+	else
+		start = ras->ras_next_readahead;
 
-	/* Reserve a part of the read-ahead window that we'll be issuing */
-	if (ras->ras_window_len > 0) {
-		/*
-		 * Note: other thread might rollback the ras_next_readahead,
-		 * if it can not get the full size of prepared pages, see the
-		 * end of this function. For stride read ahead, it needs to
-		 * make sure the offset is no less than ras_stride_offset,
-		 * so that stride read ahead can work correctly.
-		 */
-		if (stride_io_mode(ras))
-			start = max(ras->ras_next_readahead,
-				    ras->ras_stride_offset);
-		else
-			start = ras->ras_next_readahead;
+	if (ras->ras_window_len > 0)
 		end = ras->ras_window_start + ras->ras_window_len - 1;
-	}
+
+	/* Enlarge the RA window to encompass the full read */
+	if (vio->vui_ra_valid &&
+	    end < vio->vui_ra_start + vio->vui_ra_count - 1)
+		end = vio->vui_ra_start + vio->vui_ra_count - 1;
 
 	if (end != 0) {
 		unsigned long rpc_boundary;
@@ -602,7 +597,7 @@ static void ras_reset(struct inode *inode, struct ll_readahead_state *ras,
 	ras->ras_consecutive_pages = 0;
 	ras->ras_window_len = 0;
 	ras_set_start(inode, ras, index);
-	ras->ras_next_readahead = max(ras->ras_window_start, index);
+	ras->ras_next_readahead = max(ras->ras_window_start, index + 1);
 
 	RAS_CDEBUG(ras);
 }
@@ -733,10 +728,11 @@ static void ras_increase_window(struct inode *inode,
 
 static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 		       struct ll_readahead_state *ras, unsigned long index,
-		       unsigned int hit)
+		       enum ras_update_flags flags)
 {
 	struct ll_ra_info *ra = &sbi->ll_ra_info;
 	int zero = 0, stride_detect = 0, ra_miss = 0;
+	bool hit = flags & LL_RAS_HIT;
 
 	spin_lock(&ras->ras_lock);
 
@@ -766,7 +762,7 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 	 * to for subsequent IO.  The mmap case does not increment
 	 * ras_requests and thus can never trigger this behavior.
 	 */
-	if (ras->ras_requests == 2 && !ras->ras_request_index) {
+	if (ras->ras_requests >= 2 && !ras->ras_request_index) {
 		__u64 kms_pages;
 
 		kms_pages = (i_size_read(inode) + PAGE_SIZE - 1) >>
@@ -778,8 +774,7 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 		if (kms_pages &&
 		    kms_pages <= ra->ra_max_read_ahead_whole_pages) {
 			ras->ras_window_start = 0;
-			ras->ras_last_readpage = 0;
-			ras->ras_next_readahead = 0;
+			ras->ras_next_readahead = index + 1;
 			ras->ras_window_len = min(ra->ra_max_pages_per_file,
 				ra->ra_max_read_ahead_whole_pages);
 			goto out_unlock;
@@ -867,8 +862,13 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 	/* Trigger RA in the mmap case where ras_consecutive_requests
 	 * is not incremented and thus can't be used to trigger RA
 	 */
-	if (!ras->ras_window_len && ras->ras_consecutive_pages == 4) {
-		ras->ras_window_len = RAS_INCREASE_STEP(inode);
+	if (ras->ras_consecutive_pages >= 4 && flags & LL_RAS_MMAP) {
+		ras_increase_window(inode, ras, ra);
+		/*
+		 * reset consecutive pages so that the readahead window can
+		 * grow gradually.
+		 */
+		ras->ras_consecutive_pages = 0;
 		goto out_unlock;
 	}
 
@@ -1101,9 +1101,16 @@ static int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 
 	vpg = cl2vvp_page(cl_object_page_slice(page->cp_obj, page));
 	if (sbi->ll_ra_info.ra_max_pages_per_file > 0 &&
-	    sbi->ll_ra_info.ra_max_pages > 0)
-		ras_update(sbi, inode, ras, vvp_index(vpg),
-			   vpg->vpg_defer_uptodate);
+	    sbi->ll_ra_info.ra_max_pages > 0) {
+		struct vvp_io *vio = vvp_env_io(env);
+		enum ras_update_flags flags = 0;
+
+		if (vpg->vpg_defer_uptodate)
+			flags |= LL_RAS_HIT;
+		if (!vio->vui_ra_valid)
+			flags |= LL_RAS_MMAP;
+		ras_update(sbi, inode, ras, vvp_index(vpg), flags);
+	}
 
 	if (vpg->vpg_defer_uptodate) {
 		vpg->vpg_ra_used = 1;
-- 
1.7.1
