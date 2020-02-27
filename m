From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:57 -0500
Subject: [lustre-devel] [PATCH 129/622] lustre: llite: create checksums to
 replace checksum_pages
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-130-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Create llite.*.checksums, which matches llite.*.checksum_pages in
functionality. Now the llite layer have something that matches
osc.*.checksums. In time we can retire checksum_pages and change
it to its original purpose of enabling per-page checksums (which
was not implemented in the CLIO development).

WC-bug-id: https://jira.whamcloud.com/browse/LU-10906
Lustre-commit: 123ee3cf96dd ("LU-10906 llite: create checksums to replace checksum_pages")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/33222
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/lproc_llite.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 5ac6689..5fc7705 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -599,8 +599,8 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 
 LPROC_SEQ_FOPS(ll_max_cached_mb);
 
-static ssize_t checksum_pages_show(struct kobject *kobj, struct attribute *attr,
-				   char *buf)
+static ssize_t checksums_show(struct kobject *kobj, struct attribute *attr,
+			      char *buf)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
@@ -608,10 +608,8 @@ static ssize_t checksum_pages_show(struct kobject *kobj, struct attribute *attr,
 	return sprintf(buf, "%u\n", (sbi->ll_flags & LL_SBI_CHECKSUM) ? 1 : 0);
 }
 
-static ssize_t checksum_pages_store(struct kobject *kobj,
-				    struct attribute *attr,
-				    const char *buffer,
-				    size_t count)
+static ssize_t checksums_store(struct kobject *kobj, struct attribute *attr,
+			       const char *buffer, size_t count)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
@@ -642,7 +640,9 @@ static ssize_t checksum_pages_store(struct kobject *kobj,
 
 	return count;
 }
-LUSTRE_RW_ATTR(checksum_pages);
+LUSTRE_RW_ATTR(checksums);
+
+LUSTRE_ATTR(checksum_pages, 0644, checksums_show, checksums_store);
 
 static ssize_t ll_rd_track_id(struct kobject *kobj, char *buf,
 			      enum stats_track_type type)
@@ -1250,6 +1250,7 @@ static ssize_t ll_nosquash_nids_seq_write(struct file *file,
 	&lustre_attr_max_read_ahead_mb.attr,
 	&lustre_attr_max_read_ahead_per_file_mb.attr,
 	&lustre_attr_max_read_ahead_whole_mb.attr,
+	&lustre_attr_checksums.attr,
 	&lustre_attr_checksum_pages.attr,
 	&lustre_attr_stats_track_pid.attr,
 	&lustre_attr_stats_track_ppid.attr,
-- 
1.8.3.1
