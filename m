From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun, 28 Aug 2016 23:38:27 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: constify
	lprocfs_generic_fops structure
Message-ID: <1472420307-21087-1-git-send-email-Julia.Lawall@lip6.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: kernel-janitors@vger.kernel.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

lprocfs_generic_fops, of type struct file_operations, is never modified, so
declare it as const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/staging/lustre/lustre/obdclass/lprocfs_status.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 3d6da74..be6b6af 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -315,7 +315,7 @@ struct dentry *ldebugfs_add_simple(struct dentry *root,
 }
 EXPORT_SYMBOL_GPL(ldebugfs_add_simple);
 
-static struct file_operations lprocfs_generic_fops = { };
+static const struct file_operations lprocfs_generic_fops = { };
 
 int ldebugfs_add_vars(struct dentry *parent,
 		      struct lprocfs_vars *list,
