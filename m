From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:19 -0400
Subject: [lustre-devel] [PATCH 40/42] lustre: llite: increase readahead
 default values
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-41-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

It is commonly recommended to increase the readahead tunables
for clients to increase performance, since the current defaults
are too small, having been set several years ago for slower
networks and servers.

Increase the readahead defaults to better match values that are
recommended today:
- read_ahead_max_mb increased from 64MB to 1GB by default,
  or 1/32 RAM, whichever is less
- read_ahead_per_file_max_mb is increased from 64MB to 256MB,
  or 1/4 of read_ahead_max_mb, whichever is less

Modify the constant names to better match the variable and /proc
filenames.

Fix sanity test_101g to allow readahead to generate extra read
RPCs, as long as they are the expected size or larger.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11548
Lustre-commit: 4b47ec5a8e6895 ("LU-11548 llite: increase readahead default values")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33400
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h | 7 +++++--
 fs/lustre/llite/llite_lib.c      | 8 +++++---
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 7c6eddd..0bd6795 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -473,8 +473,11 @@ static inline struct pcc_inode *ll_i2pcci(struct inode *inode)
 /* default to use at least 16M for fast read if possible */
 #define RA_REMAIN_WINDOW_MIN			MiB_TO_PAGES(16UL)
 
-/* default readahead on a given system. */
-#define SBI_DEFAULT_READ_AHEAD_MAX		MiB_TO_PAGES(64UL)
+/* default read-ahead on a given client mountpoint. */
+#define SBI_DEFAULT_READ_AHEAD_MAX		MiB_TO_PAGES(1024UL)
+
+/* default read-ahead for a single file descriptor */
+#define SBI_DEFAULT_READ_AHEAD_PER_FILE_MAX	MiB_TO_PAGES(256UL)
 
 /* default read-ahead full files smaller than limit on the second read */
 #define SBI_DEFAULT_READ_AHEAD_WHOLE_MAX	MiB_TO_PAGES(2UL)
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index e732a82..8ef2437 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -123,11 +123,13 @@ static struct ll_sb_info *ll_init_sbi(void)
 		goto out_destroy_ra;
 	}
 
-	sbi->ll_ra_info.ra_max_pages_per_file = min(pages / 32,
-						    SBI_DEFAULT_READ_AHEAD_MAX);
+	sbi->ll_ra_info.ra_max_pages =
+		min(pages / 32, SBI_DEFAULT_READ_AHEAD_MAX);
+	sbi->ll_ra_info.ra_max_pages_per_file =
+		min(sbi->ll_ra_info.ra_max_pages / 4,
+		    SBI_DEFAULT_READ_AHEAD_PER_FILE_MAX);
 	sbi->ll_ra_info.ra_async_pages_per_file_threshold =
 				sbi->ll_ra_info.ra_max_pages_per_file;
-	sbi->ll_ra_info.ra_max_pages = sbi->ll_ra_info.ra_max_pages_per_file;
 	sbi->ll_ra_info.ra_max_read_ahead_whole_pages = -1;
 	atomic_set(&sbi->ll_ra_info.ra_async_inflight, 0);
 
-- 
1.8.3.1
