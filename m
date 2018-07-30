From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Jul 2018 13:49:32 +1000
Subject: [lustre-devel] [PATCH 3/7] lustre/libfs: move debugfs registration
 from libcfs_setup back to libcfs_init
In-Reply-To: <153292249340.26496.13985174182824912332.stgit@noble>
References: <153292249340.26496.13985174182824912332.stgit@noble>
Message-ID: <153292257289.26496.3865601138425685904.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

large memory allocations should be avoided at module-init,
but registering services is appropriate.
So move the registration of debugfs files
back into libcfs_init().
Without this, /sys/kernel/debug/lnet etc are not visible
immediately that libcfs is loaded.
No debugfs file access needs anything allocated by libcfs_setup().

Fixes: 64bf0b1a079d ("staging: lustre: refactor libcfs initialization.")
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/libcfs/module.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index bfadfcfa3c44..5d2be941777e 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -719,10 +719,6 @@ int libcfs_setup(void)
 		goto err;
 	}
 
-	lnet_insert_debugfs(lnet_table);
-	if (!IS_ERR_OR_NULL(lnet_debugfs_root))
-		lnet_insert_debugfs_links(lnet_debugfs_symlinks);
-
 	CDEBUG(D_OTHER, "portals setup OK\n");
 out:
 	libcfs_active = 1;
@@ -743,6 +739,10 @@ static int libcfs_init(void)
 {
 	int rc;
 
+	lnet_insert_debugfs(lnet_table);
+	if (!IS_ERR_OR_NULL(lnet_debugfs_root))
+		lnet_insert_debugfs_links(lnet_debugfs_symlinks);
+
 	rc = misc_register(&libcfs_dev);
 	if (rc)
 		CERROR("misc_register: error %d\n", rc);
