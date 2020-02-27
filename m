From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:21 -0500
Subject: [lustre-devel] [PATCH 273/622] lustre: obd: update udev event
 handling
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-274-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Add a timestamp that users have requested so it can be recorded
then a sysfs lustre file changed. Second the PARAM field only
was created with the kobject source and parent name but the
sysfs file could be deeper in the lustre sysfs tree. Add handling
for deeper sysfs tree paths.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Lustre-commit: b0d162390ad6 ("LU-8066 obd: update udev event handling")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/34624
Reviewed-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/obd_config.c | 30 ++++++++++++++++++++++--------
 1 file changed, 22 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index 4b1848f..97cb8c1 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -773,7 +773,7 @@ static int process_param2_config(struct lustre_cfg *lcfg)
 	char *param = lustre_cfg_string(lcfg, 1);
 	struct kobject *kobj = NULL;
 	const char *subsys = param;
-	char *envp[3];
+	char *envp[4];
 	char *value;
 	size_t len;
 	int rc;
@@ -802,7 +802,9 @@ static int process_param2_config(struct lustre_cfg *lcfg)
 	param = strsep(&value, "=");
 	envp[0] = kasprintf(GFP_KERNEL, "PARAM=%s", param);
 	envp[1] = kasprintf(GFP_KERNEL, "SETTING=%s", value);
-	envp[2] = NULL;
+	envp[2] = kasprintf(GFP_KERNEL, "TIME=%lld",
+			    ktime_get_real_seconds());
+	envp[3] = NULL;
 
 	rc = kobject_uevent_env(kobj, KOBJ_CHANGE, envp);
 	for (i = 0; i < ARRAY_SIZE(envp); i++)
@@ -1128,14 +1130,25 @@ ssize_t class_modify_config(struct lustre_cfg *lcfg, const char *prefix,
 		}
 
 		if (!attr) {
-			char *envp[3];
+			char *envp[4], *param, *path;
 
-			envp[0] = kasprintf(GFP_KERNEL, "PARAM=%s.%s.%.*s",
-					    kobject_name(kobj->parent),
-					    kobject_name(kobj),
-					    (int)keylen, key);
+			path = kobject_get_path(kobj, GFP_KERNEL);
+			if (!path)
+				return -EINVAL;
+
+			/* convert sysfs path to uevent format */
+			param = path;
+			while ((param = strchr(param, '/')) != NULL)
+				*param = '.';
+
+			param = strstr(path, "fs.lustre.") + 10;
+
+			envp[0] = kasprintf(GFP_KERNEL, "PARAM=%s.%.*s",
+					    param, (int)keylen, key);
 			envp[1] = kasprintf(GFP_KERNEL, "SETTING=%s", value);
-			envp[2] = NULL;
+			envp[2] = kasprintf(GFP_KERNEL, "TIME=%lld",
+					    ktime_get_real_seconds());
+			envp[3] = NULL;
 
 			if (kobject_uevent_env(kobj, KOBJ_CHANGE, envp)) {
 				CERROR("%s: failed to send uevent %s\n",
@@ -1144,6 +1157,7 @@ ssize_t class_modify_config(struct lustre_cfg *lcfg, const char *prefix,
 
 			for (i = 0; i < ARRAY_SIZE(envp); i++)
 				kfree(envp[i]);
+			kfree(path);
 		} else {
 			count += lustre_attr_store(kobj, attr, value,
 						   strlen(value));
-- 
1.8.3.1
