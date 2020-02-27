From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:03 -0500
Subject: [lustre-devel] [PATCH 015/622] lustre: obdclass: allow specifying
 complex jobids
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Allow specifying a format string for the jobid_name variable to create
a jobid for processes on the client.  The jobid_name is used when
jobid_var=nodelocal, if jobid_name contains "%j", or as a fallback if
getting the specified jobid_var from the environment fails.

The jobid_node string allows the following escape sequences:

    %e = executable name
    %g = group ID
    %h = hostname (system utsname)
    %j = jobid from jobid_var environment variable
    %p = process ID
    %u = user ID

Any unknown escape sequences are dropped. Other arbitrary characters
pass through unmodified, up to the maximum jobid string size of 32,
though whitespace within the jobid is not copied.

This allows, for example, specifying an arbitrary prefix, such as the
cluster name, in addition to the traditional "procname.uid" format,
to distinguish between jobs running on clients in different clusters:

    lctl set_param jobid_var=nodelocal jobid_name=cluster2.%e.%u
or
    lctl set_param jobid_var=SLURM_JOB_ID jobid_name=cluster2.%j.%e

To use an environment-specified JobID, if available, but fall back to
a static string for all processes that do not have a valid JobID:

    lctl set_param jobid_var=SLURM_JOB_ID jobid_name=unknown

Implementation notes:

The LUSTRE_JOBID_SIZE includes a trailing NUL, so don't use
"LUSTRE_JOBID_SIZE + 1" anywhere, as that is misleading.

Rename the "obd_jobid_node" variable to "obd_jobid_name" to match
the sysfs "jobid_name" parameter name to avoid confusion.

Rename "struct jobid_to_pid_map" to "jobid_pid_map" since this is
not actually mapping from a jobid *to* a PID, but the reverse.
Save jobid length, and reorder fields to avoid holes in structure.

Consolidate PID->jobid cache handling in jobid_get_from_cache(),
which only does environment lookups and caches the results.
The fallback to using obd_jobid_name is handled by the caller.

Rename check_job_name() to jobid_name_is_valid(), since that makes
it clear to the reader a "true" return is a valid name.

In jobid_cache_init() there is no benefit for locking the jobid_hash
creation, since the spinlock is just initialized in this function,
so multiple callers of this function would already be broken.

Pass the buffer size from the callers (who know the buffer size) to
lustre_get_jobid() instead of assuming it is LUSTRE_JOBID_SIZE.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10698
Lustre-commit: 6488c0ec57de ("LU-10698 obdclass: allow specifying complex jobids")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/31691
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <green@whamclould.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h          |  4 +-
 fs/lustre/llite/llite_internal.h       |  4 +-
 fs/lustre/llite/llite_lib.c            |  2 +-
 fs/lustre/llite/vvp_io.c               |  2 +-
 fs/lustre/llite/vvp_object.c           |  3 +-
 fs/lustre/obdclass/jobid.c             | 95 +++++++++++++++++++++++++++++++---
 fs/lustre/obdclass/obd_sysfs.c         | 10 ++--
 fs/lustre/ptlrpc/pack_generic.c        |  4 +-
 include/uapi/linux/lustre/lustre_idl.h |  2 +-
 9 files changed, 105 insertions(+), 21 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 9e07853..146c37e 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -54,7 +54,7 @@
 /* OBD Operations Declarations */
 struct obd_device *class_exp2obd(struct obd_export *exp);
 int class_handle_ioctl(unsigned int cmd, unsigned long arg);
-int lustre_get_jobid(char *jobid);
+int lustre_get_jobid(char *jobid, size_t len);
 
 struct lu_device_type;
 
@@ -1672,7 +1672,7 @@ static inline void class_uuid_unparse(class_uuid_t uu, struct obd_uuid *out)
 int class_check_uuid(struct obd_uuid *uuid, u64 nid);
 
 /* class_obd.c */
-extern char obd_jobid_node[];
+extern char obd_jobid_name[];
 int class_procfs_init(void);
 int class_procfs_clean(void);
 
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index fbe93a4..d0a703d 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -195,11 +195,11 @@ struct ll_inode_info {
 			int				lli_async_rc;
 
 			/*
-			 * whenever a process try to read/write the file, the
+			 * Whenever a process try to read/write the file, the
 			 * jobid of the process will be saved here, and it'll
 			 * be packed into the write PRC when flush later.
 			 *
-			 * so the read/write statistics for jobid will not be
+			 * So the read/write statistics for jobid will not be
 			 * accurate if the file is shared by different jobs.
 			 */
 			char				lli_jobid[LUSTRE_JOBID_SIZE];
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 12aafe0..7580d57 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -937,7 +937,7 @@ void ll_lli_init(struct ll_inode_info *lli)
 		lli->lli_async_rc = 0;
 	}
 	mutex_init(&lli->lli_layout_mutex);
-	memset(lli->lli_jobid, 0, LUSTRE_JOBID_SIZE);
+	memset(lli->lli_jobid, 0, sizeof(lli->lli_jobid));
 }
 
 int ll_fill_super(struct super_block *sb)
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 37bf942..85bb3e0 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -1419,7 +1419,7 @@ int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 		 * it's not accurate if the file is shared by different
 		 * jobs.
 		 */
-		lustre_get_jobid(lli->lli_jobid);
+		lustre_get_jobid(lli->lli_jobid, sizeof(lli->lli_jobid));
 	} else if (io->ci_type == CIT_SETATTR) {
 		if (!cl_io_is_trunc(io))
 			io->ci_lockreq = CILR_MANDATORY;
diff --git a/fs/lustre/llite/vvp_object.c b/fs/lustre/llite/vvp_object.c
index c750a80..24cde0d 100644
--- a/fs/lustre/llite/vvp_object.c
+++ b/fs/lustre/llite/vvp_object.c
@@ -212,7 +212,8 @@ static void vvp_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 	obdo_set_parent_fid(oa, &ll_i2info(inode)->lli_fid);
 	if (OBD_FAIL_CHECK(OBD_FAIL_LFSCK_INVALID_PFID))
 		oa->o_parent_oid++;
-	memcpy(attr->cra_jobid, ll_i2info(inode)->lli_jobid, LUSTRE_JOBID_SIZE);
+	memcpy(attr->cra_jobid, ll_i2info(inode)->lli_jobid,
+	       sizeof(attr->cra_jobid));
 }
 
 static const struct cl_object_operations vvp_ops = {
diff --git a/fs/lustre/obdclass/jobid.c b/fs/lustre/obdclass/jobid.c
index 3655a2e..8bad859 100644
--- a/fs/lustre/obdclass/jobid.c
+++ b/fs/lustre/obdclass/jobid.c
@@ -32,17 +32,19 @@
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
+#include <linux/ctype.h>
 #include <linux/user_namespace.h>
 #ifdef HAVE_UIDGID_HEADER
 #include <linux/uidgid.h>
 #endif
+#include <linux/utsname.h>
 
 #include <obd_support.h>
 #include <obd_class.h>
 #include <lustre_net.h>
 
 char obd_jobid_var[JOBSTATS_JOBID_VAR_MAX_LEN + 1] = JOBSTATS_DISABLE;
-char obd_jobid_node[LUSTRE_JOBID_SIZE + 1];
+char obd_jobid_name[LUSTRE_JOBID_SIZE] = "%e.%u";
 
 /* Get jobid of current process from stored variable or calculate
  * it from pid and user_id.
@@ -52,9 +54,89 @@
  * This is now deprecated.
  */
 
-int lustre_get_jobid(char *jobid)
+/*
+ * jobid_interpret_string()
+ *
+ * Interpret the jobfmt string to expand specified fields, like coredumps do:
+ *   %e = executable
+ *   %g = gid
+ *   %h = hostname
+ *   %j = jobid from environment
+ *   %p = pid
+ *   %u = uid
+ *
+ * Unknown escape strings are dropped.  Other characters are copied through,
+ * excluding whitespace (to avoid making jobid parsing difficult).
+ *
+ * Return: -EOVERFLOW if the expanded string does not fit within @joblen
+ *         0 for success
+ */
+static int jobid_interpret_string(const char *jobfmt, char *jobid,
+				  ssize_t joblen)
+{
+	char c;
+
+	while ((c = *jobfmt++) && joblen > 1) {
+		char f;
+		int l;
+
+		if (isspace(c)) /* Don't allow embedded spaces */
+			continue;
+
+		if (c != '%') {
+			*jobid = c;
+			joblen--;
+			jobid++;
+			continue;
+		}
+
+		switch ((f = *jobfmt++)) {
+		case 'e': /* executable name */
+			l = snprintf(jobid, joblen, "%s", current->comm);
+			break;
+		case 'g': /* group ID */
+			l = snprintf(jobid, joblen, "%u",
+				     from_kgid(&init_user_ns, current_fsgid()));
+			break;
+		case 'h': /* hostname */
+			l = snprintf(jobid, joblen, "%s",
+				     init_utsname()->nodename);
+			break;
+		case 'j': /* jobid requested by process
+			   * - currently not supported
+			   */
+			l = snprintf(jobid, joblen, "%s", "jobid");
+			break;
+		case 'p': /* process ID */
+			l = snprintf(jobid, joblen, "%u", current->pid);
+			break;
+		case 'u': /* user ID */
+			l = snprintf(jobid, joblen, "%u",
+				     from_kuid(&init_user_ns, current_fsuid()));
+			break;
+		case '\0': /* '%' at end of format string */
+			l = 0;
+			goto out;
+		default: /* drop unknown %x format strings */
+			l = 0;
+			break;
+		}
+		jobid += l;
+		joblen -= l;
+	}
+	/*
+	 * This points at the end of the buffer, so long as jobid is always
+	 * incremented the same amount as joblen is decremented.
+	 */
+out:
+	jobid[joblen - 1] = '\0';
+
+	return joblen < 0 ? -EOVERFLOW : 0;
+}
+
+int lustre_get_jobid(char *jobid, size_t joblen)
 {
-	char tmp_jobid[LUSTRE_JOBID_SIZE] = { 0 };
+	char tmp_jobid[LUSTRE_JOBID_SIZE] = "";
 
 	/* Jobstats isn't enabled */
 	if (strcmp(obd_jobid_var, JOBSTATS_DISABLE) == 0)
@@ -70,10 +152,11 @@ int lustre_get_jobid(char *jobid)
 
 	/* Whole node dedicated to single job */
 	if (strcmp(obd_jobid_var, JOBSTATS_NODELOCAL) == 0) {
-		strcpy(tmp_jobid, obd_jobid_node);
-		goto out_cache_jobid;
+		int rc2 = jobid_interpret_string(obd_jobid_name,
+						 tmp_jobid, joblen);
+		if (!rc2)
+			goto out_cache_jobid;
 	}
-
 	return -ENOENT;
 
 out_cache_jobid:
diff --git a/fs/lustre/obdclass/obd_sysfs.c b/fs/lustre/obdclass/obd_sysfs.c
index bac8e7c5..cd2917e 100644
--- a/fs/lustre/obdclass/obd_sysfs.c
+++ b/fs/lustre/obdclass/obd_sysfs.c
@@ -233,7 +233,7 @@ static ssize_t jobid_var_store(struct kobject *kobj, struct attribute *attr,
 static ssize_t jobid_name_show(struct kobject *kobj, struct attribute *attr,
 			       char *buf)
 {
-	return snprintf(buf, PAGE_SIZE, "%s\n", obd_jobid_node);
+	return snprintf(buf, PAGE_SIZE, "%s\n", obd_jobid_name);
 }
 
 static ssize_t jobid_name_store(struct kobject *kobj, struct attribute *attr,
@@ -243,13 +243,13 @@ static ssize_t jobid_name_store(struct kobject *kobj, struct attribute *attr,
 	if (!count || count > LUSTRE_JOBID_SIZE)
 		return -EINVAL;
 
-	memcpy(obd_jobid_node, buffer, count);
+	memcpy(obd_jobid_name, buffer, count);
 
-	obd_jobid_node[count] = 0;
+	obd_jobid_name[count] = 0;
 
 	/* Trim the trailing '\n' if any */
-	if (obd_jobid_node[count - 1] == '\n')
-		obd_jobid_node[count - 1] = 0;
+	if (obd_jobid_name[count - 1] == '\n')
+		obd_jobid_name[count - 1] = 0;
 
 	return count;
 }
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index b6a4fd8..bc5e513 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -1406,9 +1406,9 @@ void lustre_msg_set_jobid(struct lustre_msg *msg, char *jobid)
 		LASSERTF(pb, "invalid msg %p: no ptlrpc body!\n", msg);
 
 		if (jobid)
-			memcpy(pb->pb_jobid, jobid, LUSTRE_JOBID_SIZE);
+			memcpy(pb->pb_jobid, jobid, sizeof(pb->pb_jobid));
 		else if (pb->pb_jobid[0] == '\0')
-			lustre_get_jobid(pb->pb_jobid);
+			lustre_get_jobid(pb->pb_jobid, sizeof(pb->pb_jobid));
 		return;
 	}
 	default:
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 401f7ef..4e1605a2 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -635,7 +635,7 @@ struct ptlrpc_body_v3 {
 	__u64 pb_padding64_0;
 	__u64 pb_padding64_1;
 	__u64 pb_padding64_2;
-	char  pb_jobid[LUSTRE_JOBID_SIZE]; /* req: ASCII MPI jobid from env */
+	char  pb_jobid[LUSTRE_JOBID_SIZE]; /* req: ASCII jobid from env + NUL */
 };
 
 #define ptlrpc_body	ptlrpc_body_v3
-- 
1.8.3.1
