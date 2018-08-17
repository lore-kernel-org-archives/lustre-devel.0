From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:13 -0400
Subject: [lustre-devel] [PATCH 10/38] lustre: llite: use C99 for struct
 lprocfs_llite_obd_vars
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Remove mntpt_path and filegroups since they don't even exit.
Migrate the rest to C99 structure initialization.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-3319
Reviewed-on: http://review.whamcloud.com/7290
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/lproc_llite.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 5530156..0dc4d00 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -1086,17 +1086,20 @@ static ssize_t ll_nosquash_nids_seq_write(struct file *file,
 LPROC_SEQ_FOPS(ll_nosquash_nids);
 
 static struct lprocfs_vars lprocfs_llite_obd_vars[] = {
-	/* { "mntpt_path",   ll_rd_path,	     0, 0 }, */
-	{ "site",	  &ll_site_stats_fops,    NULL, 0 },
-	/* { "filegroups",   lprocfs_rd_filegroups,  0, 0 }, */
-	{ "max_cached_mb",    &ll_max_cached_mb_fops, NULL },
-	{ "statahead_stats",  &ll_statahead_stats_fops, NULL, 0 },
-	{ "unstable_stats",   &ll_unstable_stats_fops, NULL },
-	{ "sbi_flags",	      &ll_sbi_flags_fops, NULL, 0 },
-	{ .name =       "root_squash",
+	{ .name	=	"site",
+	  .fops	=	&ll_site_stats_fops			},
+	{ .name	=	"max_cached_mb",
+	  .fops	=	&ll_max_cached_mb_fops			},
+	{ .name	=	"statahead_stats",
+	  .fops	=	&ll_statahead_stats_fops		},
+	{ .name	=	"unstable_stats",
+	  .fops	=	&ll_unstable_stats_fops			},
+	{ .name	=	"sbi_flags",
+	  .fops	=	&ll_sbi_flags_fops			},
+	{ .name =	"root_squash",
 	  .fops =       &ll_root_squash_fops			},
-	{ .name =		"nosquash_nids",
-	  .fops =		&ll_nosquash_nids_fops		},
+	{ .name =	"nosquash_nids",
+	  .fops =	&ll_nosquash_nids_fops			},
 	{ NULL }
 };
 
-- 
1.8.3.1
