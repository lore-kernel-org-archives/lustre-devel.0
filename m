From: Mario Bambagini <mario.bambagini@gmail.com>
Date: Thu,  2 Mar 2017 00:57:09 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: fix sparse warning about
	different address spaces
Message-ID: <1488412629-20859-1-git-send-email-mario.bambagini@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com
Cc: andreas.dilger@intel.com, gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Mario Bambagini <mario.bambagini@gmail.com>

fixed the following sparse warning by adding proper cast:
drivers/staging//lustre/lustre/obdclass/obd_config.c:1055:74: warning: incorrect type in argument 2 (different address spaces)
drivers/staging//lustre/lustre/obdclass/obd_config.c:1055:74:    expected char const [noderef] <asn:1>*<noident>
drivers/staging//lustre/lustre/obdclass/obd_config.c:1055:74:    got char *[assigned] sval

Signed-off-by: Mario Bambagini <mario.bambagini@gmail.com>
---
 drivers/staging/lustre/lustre/obdclass/obd_config.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 9ca84c7..8fce88f 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1052,7 +1052,8 @@ int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
 
 					oldfs = get_fs();
 					set_fs(KERNEL_DS);
-					rc = var->fops->write(&fakefile, sval,
+					rc = var->fops->write(&fakefile,
+						(const char __user *)sval,
 								vallen, NULL);
 					set_fs(oldfs);
 				}
-- 
2.1.4
