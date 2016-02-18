From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Date: Thu, 18 Feb 2016 20:55:39 +0530
Subject: [lustre-devel] [PATCH] staging: lusture: obdclass: Remove
	unnecessary NULL check
Message-ID: <20160218152539.GA28252@Karyakshetra>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dmitry Eremin <dmiter4ever@gmail.com>, Bhumika Goyal <bhumirks@gmail.com>, Julia Lawall <Julia.Lawall@lip6.fr>, Cihangir Akturk <cakturk@gmail.com>, Joe Perches <joe@perches.com>
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

NULL check before the  debugfs_remove_recursive function is not needed.

This was detected using scripts/coccinelle/free/ifnullfree.cocci

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
---
 drivers/staging/lustre/lustre/obdclass/linux/linux-module.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 1913f3e..2045621 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -454,8 +454,7 @@ out:

 int class_procfs_clean(void)
 {
-	if (debugfs_lustre_root != NULL)
-		debugfs_remove_recursive(debugfs_lustre_root);
+	debugfs_remove_recursive(debugfs_lustre_root);

 	debugfs_lustre_root = NULL;

--
2.1.4
