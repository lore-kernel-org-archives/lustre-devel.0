From: NeilBrown <neilb@suse.com>
Date: Mon, 23 Jul 2018 16:23:04 +1000
Subject: [lustre-devel] [PATCH 3/9] lustre: move server_name2index to
 obd_config.c
In-Reply-To: <153232696720.26222.9658151633697867322.stgit@noble>
References: <153232696720.26222.9658151633697867322.stgit@noble>
Message-ID: <153232698486.26222.18197471449250973608.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This is preparation for moving filesystem mounting
into llite/.
server_name2index belongs in obdclass, but the rest
of obd_mount.c fits better in llite.  So move
it and server_name2fsname() across to obd_config.c,
and expect it for later using by llite.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/obd_class.h  |    2 
 .../staging/lustre/lustre/obdclass/obd_config.c    |   86 ++++++++++++++++++++
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   84 --------------------
 3 files changed, 88 insertions(+), 84 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index adfe2abdf7bc..ef8c46cb9bee 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -134,6 +134,8 @@ int class_config_llog_handler(const struct lu_env *env,
 			      struct llog_handle *handle,
 			      struct llog_rec_hdr *rec, void *data);
 int class_add_uuid(const char *uuid, __u64 nid);
+int server_name2index(const char *svname, __u32 *idx,
+		      const char **endptr);
 
 /* obdecho */
 void lprocfs_echo_init_vars(struct lprocfs_static_vars *lvars);
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index cfcd17e679dd..382522fa1993 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -46,6 +46,7 @@
 #include <lustre_log.h>
 #include <uapi/linux/lustre/lustre_param.h>
 #include <obd_class.h>
+#include <lustre_disk.h>
 
 #include "llog_internal.h"
 
@@ -1172,6 +1173,91 @@ int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
 }
 EXPORT_SYMBOL(class_process_proc_param);
 
+/*** SERVER NAME ***
+ * <FSNAME><SEPARATOR><TYPE><INDEX>
+ * FSNAME is between 1 and 8 characters (inclusive).
+ *	Excluded characters are '/' and ':'
+ * SEPARATOR is either ':' or '-'
+ * TYPE: "OST", "MDT", etc.
+ * INDEX: Hex representation of the index
+ */
+
+/** Get the fsname ("lustre") from the server name ("lustre-OST003F").
+ * @param [in] svname server name including type and index
+ * @param [out] fsname Buffer to copy filesystem name prefix into.
+ *  Must have at least 'strlen(fsname) + 1' chars.
+ * @param [out] endptr if endptr isn't NULL it is set to end of fsname
+ * rc < 0  on error
+ */
+static int server_name2fsname(const char *svname, char *fsname,
+			      const char **endptr)
+{
+	const char *dash;
+
+	dash = svname + strnlen(svname, 8); /* max fsname length is 8 */
+	for (; dash > svname && *dash != '-' && *dash != ':'; dash--)
+		;
+	if (dash == svname)
+		return -EINVAL;
+
+	if (fsname) {
+		strncpy(fsname, svname, dash - svname);
+		fsname[dash - svname] = '\0';
+	}
+
+	if (endptr)
+		*endptr = dash;
+
+	return 0;
+}
+
+/* Get the index from the obd name.
+ *  rc = server type, or
+ * rc < 0  on error
+ * if endptr isn't NULL it is set to end of name
+ */
+int server_name2index(const char *svname, __u32 *idx,
+		      const char **endptr)
+{
+	unsigned long index;
+	int rc;
+	const char *dash;
+
+	/* We use server_name2fsname() just for parsing */
+	rc = server_name2fsname(svname, NULL, &dash);
+	if (rc != 0)
+		return rc;
+
+	dash++;
+
+	if (strncmp(dash, "MDT", 3) == 0)
+		rc = LDD_F_SV_TYPE_MDT;
+	else if (strncmp(dash, "OST", 3) == 0)
+		rc = LDD_F_SV_TYPE_OST;
+	else
+		return -EINVAL;
+
+	dash += 3;
+
+	if (strncmp(dash, "all", 3) == 0) {
+		if (endptr)
+			*endptr = dash + 3;
+		return rc | LDD_F_SV_ALL;
+	}
+
+	index = simple_strtoul(dash, (char **)endptr, 16);
+	if (idx)
+		*idx = index;
+
+	/* Account for -mdc after index that is possible when specifying mdt */
+	if (endptr && strncmp(LUSTRE_MDC_NAME, *endptr + 1,
+			      sizeof(LUSTRE_MDC_NAME) - 1) == 0)
+		*endptr += sizeof(LUSTRE_MDC_NAME);
+
+	return rc;
+}
+EXPORT_SYMBOL(server_name2index);
+
 /** Parse a configuration llog, doing various manipulations on them
  * for various reasons, (modifications for compatibility, skip obsolete
  * records, change uuids, etc), then class_process_config() resulting
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 1a668874a165..3420e87ad0cd 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -579,90 +579,6 @@ static int lustre_put_lsi(struct super_block *sb)
 	return 0;
 }
 
-/*** SERVER NAME ***
- * <FSNAME><SEPARATOR><TYPE><INDEX>
- * FSNAME is between 1 and 8 characters (inclusive).
- *	Excluded characters are '/' and ':'
- * SEPARATOR is either ':' or '-'
- * TYPE: "OST", "MDT", etc.
- * INDEX: Hex representation of the index
- */
-
-/** Get the fsname ("lustre") from the server name ("lustre-OST003F").
- * @param [in] svname server name including type and index
- * @param [out] fsname Buffer to copy filesystem name prefix into.
- *  Must have at least 'strlen(fsname) + 1' chars.
- * @param [out] endptr if endptr isn't NULL it is set to end of fsname
- * rc < 0  on error
- */
-static int server_name2fsname(const char *svname, char *fsname,
-			      const char **endptr)
-{
-	const char *dash;
-
-	dash = svname + strnlen(svname, 8); /* max fsname length is 8 */
-	for (; dash > svname && *dash != '-' && *dash != ':'; dash--)
-		;
-	if (dash == svname)
-		return -EINVAL;
-
-	if (fsname) {
-		strncpy(fsname, svname, dash - svname);
-		fsname[dash - svname] = '\0';
-	}
-
-	if (endptr)
-		*endptr = dash;
-
-	return 0;
-}
-
-/* Get the index from the obd name.
- *  rc = server type, or
- * rc < 0  on error
- * if endptr isn't NULL it is set to end of name
- */
-static int server_name2index(const char *svname, __u32 *idx,
-			     const char **endptr)
-{
-	unsigned long index;
-	int rc;
-	const char *dash;
-
-	/* We use server_name2fsname() just for parsing */
-	rc = server_name2fsname(svname, NULL, &dash);
-	if (rc != 0)
-		return rc;
-
-	dash++;
-
-	if (strncmp(dash, "MDT", 3) == 0)
-		rc = LDD_F_SV_TYPE_MDT;
-	else if (strncmp(dash, "OST", 3) == 0)
-		rc = LDD_F_SV_TYPE_OST;
-	else
-		return -EINVAL;
-
-	dash += 3;
-
-	if (strncmp(dash, "all", 3) == 0) {
-		if (endptr)
-			*endptr = dash + 3;
-		return rc | LDD_F_SV_ALL;
-	}
-
-	index = simple_strtoul(dash, (char **)endptr, 16);
-	if (idx)
-		*idx = index;
-
-	/* Account for -mdc after index that is possible when specifying mdt */
-	if (endptr && strncmp(LUSTRE_MDC_NAME, *endptr + 1,
-			      sizeof(LUSTRE_MDC_NAME) - 1) == 0)
-		*endptr += sizeof(LUSTRE_MDC_NAME);
-
-	return rc;
-}
-
 /*************** mount common between server and client ***************/
 
 /* Common umount */
