From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:30 -0400
Subject: [lustre-devel] [PATCH 27/38] lustre: obd: resolve config log sysfs
 issues
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This resolves long standing issues with modifying sysfs settings
on multiple nodes simultaneously by running a single command on
the backend MGS server. Their are two ways to change the settings,
LCFG_PARAM and LCFG_SET_PARAM. For the LCFG_PARAM case we create
a new function class_modify_config() that grabs the attributes
from the passed in kobject. We can use those attributes to
modify the sysfs settings. If we can't find the attribute then
send a uevent to let userland resolve the change. For the
LCFG_SET_PARAM case we handle two class of settings. The function
class_set_global() was modifiy to handle the top lustre sysfs
files since they are not searchable with kset_find_obj.
If we can find a kobject with kset_find_obj then we can send
a uevent so userland change manage the change.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9431
Reviewed-on: https://review.whamcloud.com/30143
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/lprocfs_status.h |   5 +
 drivers/staging/lustre/lustre/include/obd_class.h  |   3 +
 .../lustre/lustre/obdclass/lprocfs_status.c        |  10 +-
 drivers/staging/lustre/lustre/obdclass/module.c    |  18 +++
 .../staging/lustre/lustre/obdclass/obd_config.c    | 172 ++++++++++++++-------
 5 files changed, 152 insertions(+), 56 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index bc7a390..c841aba 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -577,6 +577,11 @@ struct lustre_attr {
 #define LUSTRE_RO_ATTR(name) LUSTRE_ATTR(name, 0444, name##_show, NULL)
 #define LUSTRE_RW_ATTR(name) LUSTRE_ATTR(name, 0644, name##_show, name##_store)
 
+ssize_t lustre_attr_show(struct kobject *kobj, struct attribute *attr,
+			 char *buf);
+ssize_t lustre_attr_store(struct kobject *kobj, struct attribute *attr,
+			  const char *buf, size_t len);
+
 extern const struct sysfs_ops lustre_sysfs_ops;
 
 struct root_squash_info;
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 02a3f97..1925bda 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -108,6 +108,9 @@ typedef int (*llog_cb_t)(const struct lu_env *, struct llog_handle *,
 char *lustre_cfg_string(struct lustre_cfg *lcfg, u32 index);
 void print_lustre_cfg(struct lustre_cfg *lcfg);
 int class_process_config(struct lustre_cfg *lcfg);
+ssize_t class_set_global(const char *param);
+ssize_t class_modify_config(struct lustre_cfg *lcfg, const char *prefix,
+			    struct kobject *kobj);
 int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
 			     struct lustre_cfg *lcfg, void *data);
 
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 3fbf10b..84e5a8c 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -1762,21 +1762,23 @@ int lprocfs_wr_nosquash_nids(const char __user *buffer, unsigned long count,
 }
 EXPORT_SYMBOL(lprocfs_wr_nosquash_nids);
 
-static ssize_t lustre_attr_show(struct kobject *kobj,
-				struct attribute *attr, char *buf)
+ssize_t lustre_attr_show(struct kobject *kobj,
+			 struct attribute *attr, char *buf)
 {
 	struct lustre_attr *a = container_of(attr, struct lustre_attr, attr);
 
 	return a->show ? a->show(kobj, attr, buf) : 0;
 }
+EXPORT_SYMBOL_GPL(lustre_attr_show);
 
-static ssize_t lustre_attr_store(struct kobject *kobj, struct attribute *attr,
-				 const char *buf, size_t len)
+ssize_t lustre_attr_store(struct kobject *kobj, struct attribute *attr,
+			  const char *buf, size_t len)
 {
 	struct lustre_attr *a = container_of(attr, struct lustre_attr, attr);
 
 	return a->store ? a->store(kobj, attr, buf, len) : len;
 }
+EXPORT_SYMBOL_GPL(lustre_attr_store);
 
 const struct sysfs_ops lustre_sysfs_ops = {
 	.show  = lustre_attr_show,
diff --git a/drivers/staging/lustre/lustre/obdclass/module.c b/drivers/staging/lustre/lustre/obdclass/module.c
index 27b3849..eab9820 100644
--- a/drivers/staging/lustre/lustre/obdclass/module.c
+++ b/drivers/staging/lustre/lustre/obdclass/module.c
@@ -575,6 +575,24 @@ static int obd_device_list_open(struct inode *inode, struct file *file)
 	.attrs = lustre_attrs,
 };
 
+ssize_t class_set_global(const char *param)
+{
+	const char *value = strchr(param, '=') + 1;
+	size_t off = value - param - 1;
+	ssize_t count = -ENOENT;
+	int i;
+
+	for (i = 0; lustre_attrs[i]; i++) {
+		if (!strncmp(lustre_attrs[i]->name, param, off)) {
+			count = lustre_attr_store(&lustre_kset->kobj,
+						  lustre_attrs[i], value,
+						  strlen(value));
+			break;
+		}
+	}
+	return count;
+}
+
 int class_procfs_init(void)
 {
 	int rc = -ENOMEM;
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index d962f0c..823ddb0 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -814,28 +814,6 @@ void class_del_profiles(void)
 }
 EXPORT_SYMBOL(class_del_profiles);
 
-static int class_set_global(char *ptr, int val, struct lustre_cfg *lcfg)
-{
-	if (class_match_param(ptr, PARAM_AT_MIN, NULL) == 0)
-		at_min = val;
-	else if (class_match_param(ptr, PARAM_AT_MAX, NULL) == 0)
-		at_max = val;
-	else if (class_match_param(ptr, PARAM_AT_EXTRA, NULL) == 0)
-		at_extra = val;
-	else if (class_match_param(ptr, PARAM_AT_EARLY_MARGIN, NULL) == 0)
-		at_early_margin = val;
-	else if (class_match_param(ptr, PARAM_AT_HISTORY, NULL) == 0)
-		at_history = val;
-	else if (class_match_param(ptr, PARAM_JOBID_VAR, NULL) == 0)
-		strlcpy(obd_jobid_var, lustre_cfg_string(lcfg, 2),
-			JOBSTATS_JOBID_VAR_MAX_LEN + 1);
-	else
-		return -EINVAL;
-
-	CDEBUG(D_IOCTL, "global %s = %d\n", ptr, val);
-	return 0;
-}
-
 /* We can't call ll_process_config or lquota_process_config directly because
  * it lives in a module that must be loaded after this one.
  */
@@ -851,38 +829,44 @@ void lustre_register_client_process_config(int (*cpc)(struct lustre_cfg *lcfg))
 static int process_param2_config(struct lustre_cfg *lcfg)
 {
 	char *param = lustre_cfg_string(lcfg, 1);
-	char *upcall = lustre_cfg_string(lcfg, 2);
-	char *argv[] = {
-		[0] = "/usr/sbin/lctl",
-		[1] = "set_param",
-		[2] = param,
-		[3] = NULL
-	};
-	ktime_t	start;
-	ktime_t	end;
-	int		rc;
+	struct kobject *kobj = NULL;
+	const char *subsys = param;
+	char *envp[3];
+	char *value;
+	size_t len;
+	int rc;
+	int i;
 
-	/* Add upcall processing here. Now only lctl is supported */
-	if (strcmp(upcall, LCTL_UPCALL) != 0) {
-		CERROR("Unsupported upcall %s\n", upcall);
+	print_lustre_cfg(lcfg);
+
+	len = strcspn(param, ".=");
+	if (!len)
 		return -EINVAL;
-	}
 
-	start = ktime_get();
-	rc = call_usermodehelper(argv[0], argv, NULL, UMH_WAIT_PROC);
-	end = ktime_get();
+	/* If we find '=' then its the top level sysfs directory */
+	if (param[len] == '=')
+		return class_set_global(param);
 
-	if (rc < 0) {
-		CERROR(
-		       "lctl: error invoking upcall %s %s %s: rc = %d; time %ldus\n",
-		       argv[0], argv[1], argv[2], rc,
-		       (long)ktime_us_delta(end, start));
-	} else {
-		CDEBUG(D_HA, "lctl: invoked upcall %s %s %s, time %ldus\n",
-		       argv[0], argv[1], argv[2],
-		       (long)ktime_us_delta(end, start));
-		       rc = 0;
-	}
+	subsys = kstrndup(param, len, GFP_KERNEL);
+	if (!subsys)
+		return -ENOMEM;
+
+	kobj = kset_find_obj(lustre_kset, subsys);
+	kfree(subsys);
+	if (!kobj)
+		return -ENODEV;
+
+	value = param;
+	param = strsep(&value, "=");
+	envp[0] = kasprintf(GFP_KERNEL, "PARAM=%s", param);
+	envp[1] = kasprintf(GFP_KERNEL, "SETTING=%s", value);
+	envp[2] = NULL;
+
+	rc = kobject_uevent_env(kobj, KOBJ_CHANGE, envp);
+	for (i = 0; i < ARRAY_SIZE(envp); i++)
+		kfree(envp[i]);
+
+	kobject_put(kobj);
 
 	return rc;
 }
@@ -983,12 +967,12 @@ int class_process_config(struct lustre_cfg *lcfg)
 		} else if ((class_match_param(lustre_cfg_string(lcfg, 1),
 					      PARAM_SYS, &tmp) == 0)) {
 			/* Global param settings */
-			err = class_set_global(tmp, lcfg->lcfg_num, lcfg);
+			err = class_set_global(tmp);
 			/*
 			 * Client or server should not fail to mount if
 			 * it hits an unknown configuration parameter.
 			 */
-			if (err != 0)
+			if (err < 0)
 				CWARN("Ignoring unknown param %s\n", tmp);
 
 			err = 0;
@@ -1082,6 +1066,90 @@ int class_process_config(struct lustre_cfg *lcfg)
 }
 EXPORT_SYMBOL(class_process_config);
 
+ssize_t class_modify_config(struct lustre_cfg *lcfg, const char *prefix,
+			    struct kobject *kobj)
+{
+	struct kobj_type *typ;
+	ssize_t count = 0;
+	int i;
+
+	if (lcfg->lcfg_command != LCFG_PARAM) {
+		CERROR("Unknown command: %d\n", lcfg->lcfg_command);
+		return -EINVAL;
+	}
+
+	typ = get_ktype(kobj);
+	if (!typ || !typ->default_attrs)
+		return -ENODEV;
+
+	print_lustre_cfg(lcfg);
+
+	/*
+	 * e.g. tunefs.lustre --param mdt.group_upcall=foo /r/tmp/lustre-mdt
+	 * or   lctl conf_param lustre-MDT0000.mdt.group_upcall=bar
+	 * or   lctl conf_param lustre-OST0000.osc.max_dirty_mb=36
+	 */
+	for (i = 1; i < lcfg->lcfg_bufcount; i++) {
+		struct attribute *attr;
+		size_t keylen;
+		char *value;
+		char *key;
+		int j;
+
+		key = lustre_cfg_buf(lcfg, i);
+		/* Strip off prefix */
+		if (class_match_param(key, prefix, &key))
+			/* If the prefix doesn't match, return error so we
+			 * can pass it down the stack
+			 */
+			return -EINVAL;
+
+		value = strchr(key, '=');
+		if (!value || *(value + 1) == 0) {
+			CERROR("%s: can't parse param '%s' (missing '=')\n",
+			       lustre_cfg_string(lcfg, 0),
+			       lustre_cfg_string(lcfg, i));
+			/* continue parsing other params */
+			continue;
+		}
+		keylen = value - key;
+		value++;
+
+		attr = NULL;
+		for (j = 0; typ->default_attrs[j]; j++) {
+			if (!strncmp(typ->default_attrs[j]->name, key,
+				     keylen)) {
+				attr = typ->default_attrs[j];
+				break;
+			}
+		}
+
+		if (!attr) {
+			char *envp[3];
+
+			envp[0] = kasprintf(GFP_KERNEL, "PARAM=%s.%s.%.*s",
+					    kobject_name(kobj->parent),
+					    kobject_name(kobj),
+					    (int)keylen, key);
+			envp[1] = kasprintf(GFP_KERNEL, "SETTING=%s", value);
+			envp[2] = NULL;
+
+			if (kobject_uevent_env(kobj, KOBJ_CHANGE, envp)) {
+				CERROR("%s: failed to send uevent %s\n",
+				       kobject_name(kobj), key);
+			}
+
+			for (i = 0; i < ARRAY_SIZE(envp); i++)
+				kfree(envp[i]);
+		} else {
+			count += lustre_attr_store(kobj, attr, value,
+						   strlen(value));
+		}
+	}
+	return count;
+}
+EXPORT_SYMBOL(class_modify_config);
+
 int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
 			     struct lustre_cfg *lcfg, void *data)
 {
-- 
1.8.3.1
