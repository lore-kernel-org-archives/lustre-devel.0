From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:37 -0500
Subject: [lustre-devel] [PATCH 05/45] staging/lustre/lov: Get rid of /proc
	references in comments
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-6-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Now that the sysfs conversion is complete, also convert all the
remaining comments

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/lov/lov_pool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index 3ee1d40..470708c 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -154,7 +154,7 @@ struct cfs_hash_ops pool_hash_operations = {
 
 /* ifdef needed for liblustre support */
 /*
- * pool /proc seq_file methods
+ * pool debugfs seq_file methods
  */
 /*
  * iterator is used to go through the target pool entries
@@ -429,7 +429,7 @@ int lov_pool_new(struct obd_device *obd, char *poolname)
 	INIT_HLIST_NODE(&new_pool->pool_hash);
 
 	/* we need this assert seq_file is not implemented for liblustre */
-	/* get ref for /proc file */
+	/* get ref for debugfs file */
 	lov_pool_getref(new_pool);
 	new_pool->pool_debugfs_entry = ldebugfs_add_simple(
 						lov->lov_pool_debugfs_entry,
-- 
2.1.0
