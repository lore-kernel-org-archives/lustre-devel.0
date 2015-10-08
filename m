From: Yazen Ghannam <yghannam@gmail.com>
Date: Thu,  8 Oct 2015 19:01:16 -0400
Subject: [lustre-devel] [PATCH] staging/lustre: Remove unused,
	commented function call
Message-ID: <1444345276-1088-1-git-send-email-yghannam@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Also fixes a coding style error.

Signed-off-by: Yazen Ghannam <yghannam@gmail.com>
---
 drivers/staging/lustre/lustre/obdclass/obd_config.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index b8ca324..f014015 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1070,8 +1070,6 @@ int class_config_llog_handler(const struct lu_env *env,
 	char *cfg_buf = (char *) (rec + 1);
 	int rc = 0;
 
-	//class_config_dump_handler(handle, rec, data);
-
 	switch (rec->lrh_type) {
 	case OBD_CFG_REC: {
 		struct lustre_cfg *lcfg, *lcfg_new;
-- 
2.1.4
