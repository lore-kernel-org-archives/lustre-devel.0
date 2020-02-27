From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:37 -0500
Subject: [lustre-devel] [PATCH 409/622] lustre: obd: harden debugfs handling
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-410-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

While the seq_file private data shouldn't disappear from under
us just in case always test if the private field is set. If
not return -ENODEV for debugfs read and write operations.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Lustre-commit: 44d450890f43 ("LU-8066 obd: harden debugfs handling")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/35575
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lprocfs_status.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index 6269bd3..fdc1b19 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -519,6 +519,8 @@ void lprocfs_stats_collect(struct lprocfs_stats *stats, int idx,
 #define LPROC_SEQ_FOPS_RO_TYPE(name, type)				\
 	static int name##_##type##_seq_show(struct seq_file *m, void *v)\
 	{								\
+		if (!m->private)					\
+			return -ENODEV;					\
 		return lprocfs_rd_##type(m, m->private);		\
 	}								\
 	LPROC_SEQ_FOPS_RO(name##_##type)
@@ -526,6 +528,8 @@ void lprocfs_stats_collect(struct lprocfs_stats *stats, int idx,
 #define LPROC_SEQ_FOPS_RW_TYPE(name, type)				\
 	static int name##_##type##_seq_show(struct seq_file *m, void *v)\
 	{								\
+		if (!m->private)					\
+			return -ENODEV;					\
 		return lprocfs_rd_##type(m, m->private);		\
 	}								\
 	static ssize_t name##_##type##_seq_write(struct file *file,	\
@@ -533,6 +537,9 @@ void lprocfs_stats_collect(struct lprocfs_stats *stats, int idx,
 						loff_t *off)		\
 	{								\
 		struct seq_file *seq = file->private_data;		\
+									\
+		if (!seq->private)					\
+			return -ENODEV;					\
 		return lprocfs_wr_##type(file, buffer,			\
 					 count, seq->private);		\
 	}								\
-- 
1.8.3.1
