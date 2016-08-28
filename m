From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun, 28 Aug 2016 23:16:07 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: constify
	lmv_proc_target_fops structure
Message-ID: <1472418967-4966-1-git-send-email-Julia.Lawall@lip6.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: kernel-janitors@vger.kernel.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

lmv_proc_target_fops, of type struct file_operations, is never modified, so
declare it as const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/staging/lustre/lustre/lmv/lmv_internal.h |    2 +-
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index 3ce17da..c4961d9 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -164,6 +164,6 @@ struct lmv_tgt_desc
 /* lproc_lmv.c */
 void lprocfs_lmv_init_vars(struct lprocfs_static_vars *lvars);
 
-extern struct file_operations lmv_proc_target_fops;
+extern const struct file_operations lmv_proc_target_fops;
 
 #endif
diff --git a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
index c29c361..d2316c0 100644
--- a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
+++ b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
@@ -202,7 +202,7 @@ static struct lprocfs_vars lprocfs_lmv_obd_vars[] = {
 	{ NULL }
 };
 
-struct file_operations lmv_proc_target_fops = {
+const struct file_operations lmv_proc_target_fops = {
 	.owner		= THIS_MODULE,
 	.open		 = lmv_target_seq_open,
 	.read		 = seq_read,
