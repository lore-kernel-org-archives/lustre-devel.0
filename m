From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 May 2019 08:51:07 -0400
Subject: [lustre-devel] [PATCH v2 25/29] lustre: obdclass: discard
 process_quota_config
In-Reply-To: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1558356671-29599-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

This variable is never set since it exist only for the server
code, so it can be discarded. Additionally instead of using
a function pointer hook the quota layer should use
class_modify_config().

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lustre/obdclass/obd_config.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index c96cd5c..b1d0c96 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -742,11 +742,6 @@ void class_put_profile(struct lustre_profile *lprof)
 }
 EXPORT_SYMBOL(class_put_profile);
 
-/* We can't call lquota_process_config directly because
- * it lives in a module that must be loaded after this one.
- */
-static int (*quota_process_config)(struct lustre_cfg *lcfg);
-
 static int process_param2_config(struct lustre_cfg *lcfg)
 {
 	char *param = lustre_cfg_string(lcfg, 1);
@@ -922,11 +917,6 @@ int class_process_config(struct lustre_cfg *lcfg)
 
 			err = 0;
 			goto out;
-		} else if ((class_match_param(lustre_cfg_string(lcfg, 1),
-					      PARAM_QUOTA, &tmp) == 0) &&
-			   quota_process_config) {
-			err = (*quota_process_config)(lcfg);
-			goto out;
 		}
 
 		break;
-- 
1.8.3.1
