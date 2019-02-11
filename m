From: NeilBrown <neilb@suse.com>
Date: Mon, 11 Feb 2019 16:09:58 +1100
Subject: [lustre-devel] [PATCH] lustre: don't manage module refs in
 obd_class_open/close.
In-Reply-To: <87tvhagbpl.fsf@notabene.neil.brown.name>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781334.10620.18347323437724979128.stgit@noble.brown>
 <alpine.LFD.2.21.1902110421020.5690@casper.infradead.org>
 <87tvhagbpl.fsf@notabene.neil.brown.name>
Message-ID: <87r2cegbbt.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Core Linux code for managed char-devs ensures that the relevant
module is held active which a char-dev is open - see cdev_get()
and cdev_put().
So there is no need for lustre/obd_class to manage the module
ref count as well.

As this is all that obd_class_open and obd_class_close do, those
functions can be removed.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/obdclass/class_obd.c | 18 +-----------------
 1 file changed, 1 insertion(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 84c077ec0116..b8fc74044fe3 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -544,20 +544,6 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 	return err;
 } /* class_handle_ioctl */
 
-/*  opening /dev/obd */
-static int obd_class_open(struct inode *inode, struct file *file)
-{
-	try_module_get(THIS_MODULE);
-	return 0;
-}
-
-/*  closing /dev/obd */
-static int obd_class_release(struct inode *inode, struct file *file)
-{
-	module_put(THIS_MODULE);
-	return 0;
-}
-
 /* to control /dev/obd */
 static long obd_class_ioctl(struct file *filp, unsigned int cmd,
 			    unsigned long arg)
@@ -575,9 +561,7 @@ static long obd_class_ioctl(struct file *filp, unsigned int cmd,
 /* declare character device */
 static const struct file_operations obd_psdev_fops = {
 	.owner		= THIS_MODULE,
-	.unlocked_ioctl	= obd_class_ioctl,	/* unlocked_ioctl */
-	.open		= obd_class_open,	/* open */
-	.release	= obd_class_release,	/* release */
+	.unlocked_ioctl	= obd_class_ioctl,
 };
 
 /* modules setup */
-- 
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190211/14de1c7b/attachment.sig>
