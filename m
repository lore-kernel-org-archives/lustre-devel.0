From: James Simmons <jsimmons@infradead.org>
Date: Sat, 13 Jun 2020 12:27:00 -0400
Subject: [lustre-devel] [PATCH 04/20] lustre: obdclass: discard
 process_quota_config
In-Reply-To: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
References: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1592065636-28333-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.de>

This variable is never set, so it can be discarded since it is
server side only.

Should the server side quota layer need configuration, it should
use class_modify_config().

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/lustre/obdclass/obd_config.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index b8973db..5495609 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -764,11 +764,6 @@ void class_del_profiles(void)
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
@@ -949,11 +944,6 @@ int class_process_config(struct lustre_cfg *lcfg)
 
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
