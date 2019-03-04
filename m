From: NeilBrown <neilb@suse.com>
Date: Mon, 04 Mar 2019 17:31:38 +1100
Subject: [lustre-devel] [PATCH 22/28] lustre: obdclass: discard
 process_quota_config
In-Reply-To: <155168107971.31333.14345309795939467246.stgit@noble.brown>
References: <155168107971.31333.14345309795939467246.stgit@noble.brown>
Message-ID: <155168109887.31333.2224023992695541576.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This variable is never set, so it can be discarded.

If there is, later, a need for config messages to be handled by
different modules, it would be best to use a notifier chain.
This ensures race-free registration and deregistration.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/obdclass/obd_config.c    |   10 ----------
 1 file changed, 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 7b10206d6e52..ccc0748f63a6 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -761,11 +761,6 @@ void class_del_profiles(void)
 }
 EXPORT_SYMBOL(class_del_profiles);
 
-/* We can't call lquota_process_config directly because
- * it lives in a module that must be loaded after this one.
- */
-static int (*quota_process_config)(struct lustre_cfg *lcfg);
-
 static int process_param2_config(struct lustre_cfg *lcfg)
 {
 	char *param = lustre_cfg_string(lcfg, 1);
@@ -941,11 +936,6 @@ int class_process_config(struct lustre_cfg *lcfg)
 
 			err = 0;
 			goto out;
-		} else if ((class_match_param(lustre_cfg_string(lcfg, 1),
-					      PARAM_QUOTA, &tmp) == 0) &&
-			   quota_process_config) {
-			err = (*quota_process_config)(lcfg);
-			goto out;
 		}
 
 		break;
