From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun, 28 Aug 2016 23:45:11 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: obdclass: constify
	obd_psdev_fops structure
Message-ID: <1472420711-28987-1-git-send-email-Julia.Lawall@lip6.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: kernel-janitors@vger.kernel.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

obd_psdev_fops, of type struct file_operations, is never modified, so
declare it as const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/staging/lustre/lustre/obdclass/linux/linux-module.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 27a72d8..2b691d8 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -192,7 +192,7 @@ static long obd_class_ioctl(struct file *filp, unsigned int cmd,
 }
 
 /* declare character device */
-static struct file_operations obd_psdev_fops = {
+static const struct file_operations obd_psdev_fops = {
 	.owner	  = THIS_MODULE,
 	.unlocked_ioctl = obd_class_ioctl, /* unlocked_ioctl */
 	.open	   = obd_class_open,      /* open */
