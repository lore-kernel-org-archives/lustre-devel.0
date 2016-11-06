From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Sun, 06 Nov 2016 17:11:20 -0000
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: obdclass: Fix error
	handling
Message-ID: <20161106171110.24881-1-christophe.jaillet@wanadoo.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, emoly.liu@intel.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org, Christophe JAILLET <christophe.jaillet@wanadoo.fr>

'lustre_cfg_new()' does not return NULL but ERR_PTR(-ENOMEM)
So IS_ERR should be used to check the return value.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/staging/lustre/lustre/obdclass/obd_config.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index bbed1b72d52e..0e922c5f8b33 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1382,8 +1382,8 @@ int class_manual_cleanup(struct obd_device *obd)
 	lustre_cfg_bufs_reset(&bufs, obd->obd_name);
 	lustre_cfg_bufs_set_string(&bufs, 1, flags);
 	lcfg = lustre_cfg_new(LCFG_CLEANUP, &bufs);
-	if (!lcfg)
-		return -ENOMEM;
+	if (IS_ERR(lcfg))
+		return PTR_ERR(lcfg);
 
 	rc = class_process_config(lcfg);
 	if (rc) {
-- 
2.9.3
