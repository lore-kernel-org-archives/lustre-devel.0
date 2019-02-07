From: NeilBrown <neilb@suse.com>
Date: Thu, 07 Feb 2019 11:03:33 +1100
Subject: [lustre-devel] [PATCH 17/21] lustre: obdclass: result of
 try_module_get() should not be ignored.
In-Reply-To: <154949776249.10620.1215070753973826063.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
Message-ID: <154949781334.10620.18347323437724979128.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

If try_module_get() fails, the open must fail.

In practice this should be impossible, but it is
best to make the code look right.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 48d1dabafa65..982d47b6f50e 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -548,8 +548,7 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 /*  opening /dev/obd */
 static int obd_class_open(struct inode *inode, struct file *file)
 {
-	try_module_get(THIS_MODULE);
-	return 0;
+	return try_module_get(THIS_MODULE) ? 0 : -ENODEV;
 }
 
 /*  closing /dev/obd */
