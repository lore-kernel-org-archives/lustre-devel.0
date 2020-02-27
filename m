From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:04 -0500
Subject: [lustre-devel] [PATCH 196/622] lustre: sptlrpc: split
 sptlrpc_process_config()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-197-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Make sptlrpc_process_config() more than a single line wapper
exporting function. Instead migrate the lcfg parsing out of
__sptlrpc_process_config() so that we can use this function
for both LCFG_PARAM and LCFG_SET_PARAM handling.

The first field parsed from struct lustre_cfg *lcfg is the
target. This can be "_mgs", file system name, or an obd target
i.e fsname-MDT0000. We can move to extracting the file system
name out of the target string using server_name2fsname().

WC-bug-id: https://jira.whamcloud.com/browse/LU-10937
Lustre-commit: 0ff7d548eb7b ("LU-10937 sptlrpc: split sptlrpc_process_config()")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/33760
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_disk.h |  1 +
 fs/lustre/obdclass/obd_mount.c  |  5 ++-
 fs/lustre/ptlrpc/sec_config.c   | 85 +++++++++++++++++++++++++----------------
 3 files changed, 57 insertions(+), 34 deletions(-)

diff --git a/fs/lustre/include/lustre_disk.h b/fs/lustre/include/lustre_disk.h
index 92618e8..b6b693f 100644
--- a/fs/lustre/include/lustre_disk.h
+++ b/fs/lustre/include/lustre_disk.h
@@ -145,6 +145,7 @@ struct lustre_sb_info {
 /****************** prototypes *********************/
 
 /* obd_mount.c */
+int server_name2fsname(const char *svname, char *fsname, const char **endptr);
 
 int lustre_start_mgc(struct super_block *sb);
 int lustre_common_put_super(struct super_block *sb);
diff --git a/fs/lustre/obdclass/obd_mount.c b/fs/lustre/obdclass/obd_mount.c
index d143112..6c68bc7 100644
--- a/fs/lustre/obdclass/obd_mount.c
+++ b/fs/lustre/obdclass/obd_mount.c
@@ -597,8 +597,8 @@ int lustre_put_lsi(struct super_block *sb)
  *
  * Returns:	rc < 0  on error
  */
-static int server_name2fsname(const char *svname, char *fsname,
-			      const char **endptr)
+int server_name2fsname(const char *svname, char *fsname,
+		       const char **endptr)
 {
 	const char *dash;
 
@@ -618,6 +618,7 @@ static int server_name2fsname(const char *svname, char *fsname,
 
 	return 0;
 }
+EXPORT_SYMBOL(server_name2fsname);
 
 /* Get the index from the obd name.
  *  rc = server type, or
diff --git a/fs/lustre/ptlrpc/sec_config.c b/fs/lustre/ptlrpc/sec_config.c
index 135ce99..e4b1a075 100644
--- a/fs/lustre/ptlrpc/sec_config.c
+++ b/fs/lustre/ptlrpc/sec_config.c
@@ -41,6 +41,7 @@
 #include <obd_class.h>
 #include <obd_support.h>
 #include <lustre_import.h>
+#include <lustre_disk.h>
 #include <uapi/linux/lustre/lustre_param.h>
 #include <lustre_sec.h>
 
@@ -577,14 +578,45 @@ static int sptlrpc_conf_merge_rule(struct sptlrpc_conf *conf,
  * find one through the target name in the record inside conf_lock;
  * otherwise means caller already hold conf_lock.
  */
-static int __sptlrpc_process_config(struct lustre_cfg *lcfg,
+static int __sptlrpc_process_config(char *target, const char *fsname,
+				    struct sptlrpc_rule *rule,
 				    struct sptlrpc_conf *conf)
 {
-	char *target, *param;
+	int rc;
+
+	if (!conf) {
+		if (!fsname)
+			return -ENODEV;
+
+		mutex_lock(&sptlrpc_conf_lock);
+		conf = sptlrpc_conf_get(fsname, 0);
+		if (!conf) {
+			CERROR("can't find conf\n");
+			rc = -ENOMEM;
+		} else {
+			rc = sptlrpc_conf_merge_rule(conf, target, rule);
+		}
+		mutex_unlock(&sptlrpc_conf_lock);
+	} else {
+		LASSERT(mutex_is_locked(&sptlrpc_conf_lock));
+		rc = sptlrpc_conf_merge_rule(conf, target, rule);
+	}
+
+	if (!rc)
+		conf->sc_modified++;
+
+	return rc;
+}
+
+int sptlrpc_process_config(struct lustre_cfg *lcfg)
+{
 	char fsname[MTI_NAME_MAXLEN];
 	struct sptlrpc_rule rule;
+	char *target, *param;
 	int rc;
 
+	print_lustre_cfg(lcfg);
+
 	target = lustre_cfg_string(lcfg, 1);
 	if (!target) {
 		CERROR("missing target name\n");
@@ -597,45 +629,34 @@ static int __sptlrpc_process_config(struct lustre_cfg *lcfg,
 		return -EINVAL;
 	}
 
-	CDEBUG(D_SEC, "processing rule: %s.%s\n", target, param);
-
 	/* parse rule to make sure the format is correct */
-	if (strncmp(param, PARAM_SRPC_FLVR, sizeof(PARAM_SRPC_FLVR) - 1) != 0) {
+	if (strncmp(param, PARAM_SRPC_FLVR,
+		    sizeof(PARAM_SRPC_FLVR) - 1) != 0) {
 		CERROR("Invalid sptlrpc parameter: %s\n", param);
 		return -EINVAL;
 	}
 	param += sizeof(PARAM_SRPC_FLVR) - 1;
 
-	rc = sptlrpc_parse_rule(param, &rule);
-	if (rc)
-		return -EINVAL;
-
-	if (!conf) {
-		target2fsname(target, fsname, sizeof(fsname));
-
-		mutex_lock(&sptlrpc_conf_lock);
-		conf = sptlrpc_conf_get(fsname, 0);
-		if (!conf) {
-			CERROR("can't find conf\n");
-			rc = -ENOMEM;
-		} else {
-			rc = sptlrpc_conf_merge_rule(conf, target, &rule);
-		}
-		mutex_unlock(&sptlrpc_conf_lock);
-	} else {
-		LASSERT(mutex_is_locked(&sptlrpc_conf_lock));
-		rc = sptlrpc_conf_merge_rule(conf, target, &rule);
-	}
+	CDEBUG(D_SEC, "processing rule: %s.%s\n", target, param);
 
-	if (rc == 0)
-		conf->sc_modified++;
+	/*
+	 * Three types of targets exist for sptlrpc using conf_param
+	 * 1.	'_mgs' which targets mgc srpc settings. Treat it as
+	 *	as a special file system name.
+	 * 2.	target is a device which can be fsname-MDTXXXX or
+	 *	fsname-OSTXXXX. This can be verified by the function
+	 *	server_name2fsname.
+	 * 3.	If both above conditions are not meet then the target
+	 *	is a actual filesystem.
+	 */
+	if (server_name2fsname(target, fsname, NULL))
+		strlcpy(fsname, target, sizeof(target));
 
-	return rc;
-}
+	rc = sptlrpc_parse_rule(param, &rule);
+	if (rc)
+		return rc;
 
-int sptlrpc_process_config(struct lustre_cfg *lcfg)
-{
-	return __sptlrpc_process_config(lcfg, NULL);
+	return __sptlrpc_process_config(target, fsname, &rule, NULL);
 }
 EXPORT_SYMBOL(sptlrpc_process_config);
 
-- 
1.8.3.1
