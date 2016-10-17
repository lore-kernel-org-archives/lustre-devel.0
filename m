From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Mon, 17 Oct 2016 19:17:44 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: remove unused identifier
	OBD_INIT_CHECK
Message-ID: <20161017171744.GA13506@waves>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org, linux-kernel@vger.kernel.org

OBD_INIT_CHECK was previously used by a conditional group. This is
no longer the case so it can be removed.

Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
---
 drivers/staging/lustre/lustre/obdclass/class_obd.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index d9d2a19..2b21675 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -398,7 +398,6 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 	return err;
 } /* class_handle_ioctl */
 
-#define OBD_INIT_CHECK
 static int obd_init_checks(void)
 {
 	__u64 u64val, div64val;
-- 
2.5.0


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
