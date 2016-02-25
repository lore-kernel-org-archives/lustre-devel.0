From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:49 -0500
Subject: [lustre-devel] [PATCH v2 66/84] staging/lustre: Remove misleading
	liblustre comments.
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-67-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

These two comments certainly refer to some ifdefed code that is
no longer present, so remove them too.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/lov/lov_pool.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index 210304f..8608b09 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -152,7 +152,6 @@ struct cfs_hash_ops pool_hash_operations = {
 
 };
 
-/* ifdef needed for liblustre support */
 /*
  * pool debugfs seq_file methods
  */
@@ -432,7 +431,6 @@ int lov_pool_new(struct obd_device *obd, char *poolname)
 
 	INIT_HLIST_NODE(&new_pool->pool_hash);
 
-	/* we need this assert seq_file is not implemented for liblustre */
 	/* get ref for debugfs file */
 	lov_pool_getref(new_pool);
 	new_pool->pool_debugfs_entry = ldebugfs_add_simple(
-- 
2.1.0
