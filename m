From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:19 -0500
Subject: [lustre-devel] [PATCH 271/622] lustre: llite: improve max_readahead
 console messages
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-272-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Improve the max_readahead_mb, max_readahead_per_file_mb, and
max_read_ahead_whole_mb console error messages to print the
parameters properly in MB instead of PAGE_SIZE units, and include
the filesystem name and bad parameters in the output.

WC-bug-id: https://jira.whamcloud.com/browse/LU-1095
Lustre-commit: 48a0697d7910 ("LU-1095 llite: improve max_readahead console messages")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: http://review.whamcloud.com/12399
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Oleg Drokin green at whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/lproc_llite.c | 28 +++++++++++++++++++++-------
 1 file changed, 21 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 197c09c..cc9f80e 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -346,16 +346,19 @@ static ssize_t max_read_ahead_mb_store(struct kobject *kobj,
 					      ll_kset.kobj);
 	int rc;
 	unsigned long pages_number;
+	int pages_shift;
 
+	pages_shift = 20 - PAGE_SHIFT;
 	rc = kstrtoul(buffer, 10, &pages_number);
 	if (rc)
 		return rc;
 
-	pages_number *= 1 << (20 - PAGE_SHIFT); /* MB -> pages */
+	pages_number <<= pages_shift; /* MB -> pages */
 
 	if (pages_number > totalram_pages() / 2) {
-		CERROR("can't set file readahead more than %lu MB\n",
-		       totalram_pages() >> (20 - PAGE_SHIFT + 1)); /*1/2 of RAM*/
+		CERROR("%s: can't set max_readahead_mb=%lu > %luMB\n",
+		       sbi->ll_fsname, pages_number >> pages_shift,
+		       totalram_pages() >> (pages_shift + 1)); /*1/2 of RAM*/
 		return -ERANGE;
 	}
 
@@ -393,14 +396,20 @@ static ssize_t max_read_ahead_per_file_mb_store(struct kobject *kobj,
 					      ll_kset.kobj);
 	int rc;
 	unsigned long pages_number;
+	int pages_shift;
 
+	pages_shift = 20 - PAGE_SHIFT;
 	rc = kstrtoul(buffer, 10, &pages_number);
 	if (rc)
 		return rc;
 
+	pages_number <<= pages_shift; /* MB -> pages */
+
 	if (pages_number > sbi->ll_ra_info.ra_max_pages) {
-		CERROR("can't set file readahead more than max_read_ahead_mb %lu MB\n",
-		       sbi->ll_ra_info.ra_max_pages);
+		CERROR("%s: can't set max_readahead_per_file_mb=%lu > max_read_ahead_mb=%lu\n",
+		       sbi->ll_fsname,
+		       pages_number >> pages_shift,
+		       sbi->ll_ra_info.ra_max_pages >> pages_shift);
 		return -ERANGE;
 	}
 
@@ -438,17 +447,22 @@ static ssize_t max_read_ahead_whole_mb_store(struct kobject *kobj,
 					      ll_kset.kobj);
 	int rc;
 	unsigned long pages_number;
+	int pages_shift;
 
+	pages_shift = 20 - PAGE_SHIFT;
 	rc = kstrtoul(buffer, 10, &pages_number);
 	if (rc)
 		return rc;
+	pages_number <<= pages_shift; /* MB -> pages */
 
 	/* Cap this at the current max readahead window size, the readahead
 	 * algorithm does this anyway so it's pointless to set it larger.
 	 */
 	if (pages_number > sbi->ll_ra_info.ra_max_pages_per_file) {
-		CERROR("can't set max_read_ahead_whole_mb more than max_read_ahead_per_file_mb: %lu\n",
-		       sbi->ll_ra_info.ra_max_pages_per_file >> (20 - PAGE_SHIFT));
+		CERROR("%s: can't set max_read_ahead_whole_mb=%lu > max_read_ahead_per_file_mb=%lu\n",
+		       sbi->ll_fsname,
+		       pages_number >> pages_shift,
+		       sbi->ll_ra_info.ra_max_pages_per_file >> pages_shift);
 		return -ERANGE;
 	}
 
-- 
1.8.3.1
