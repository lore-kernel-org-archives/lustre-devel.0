From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:09 -0400
Subject: [lustre-devel] [PATCH 06/38] lustre: llite: rename llite_sb_release
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Since we are freeing a kobject rename llite_sb_release() to
llite_kobj_release().

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/24031
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/lproc_llite.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 8af6636..90140b0 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -1128,7 +1128,7 @@ static ssize_t ll_nosquash_nids_seq_write(struct file *file,
 	NULL,
 };
 
-static void llite_sb_release(struct kobject *kobj)
+static void llite_kobj_release(struct kobject *kobj)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
@@ -1138,7 +1138,7 @@ static void llite_sb_release(struct kobject *kobj)
 static struct kobj_type llite_ktype = {
 	.default_attrs	= llite_attrs,
 	.sysfs_ops	= &lustre_sysfs_ops,
-	.release	= llite_sb_release,
+	.release	= llite_kobj_release,
 };
 
 static const struct llite_file_opcode {
-- 
1.8.3.1
