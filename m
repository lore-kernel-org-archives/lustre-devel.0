From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:00 -0500
Subject: [lustre-devel] [PATCH 372/622] lustre: obdclass: allow per-session
 jobids.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-373-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

Lustre includes a jobid in all RPC message sent to the server.  This
is used to collected per-job statistics, where a "job" can involve
multiple processes on multiple nodes in a cluster.

Nodes in a cluster can be running processes for multiple jobs, so it
is best if different processes can have different jobids, and that
processes on different nodes can have the same job id.

The current mechanism for supporting this is to use an environment
variable which the kernel extracts from the relevant process's address
space. Some kernel developers see this to be an unacceptable design
choice, and the code is not likely to be accepted upstream.

This patch provides an alternate method, leveraging the concept of a
"session id", as set with setsid().  Each login session already gets a
unique sid which is preserved for all processes in that session unless
explicitly changed (with setsid(1)).
When a process in a session writes to
        /sys/fs/lustre/jobid_this_session
the string becomes the name for that session.
If jobid_var is set to "session", then the per-session jobid is used
for the jobid for all requests from processes in that session.

When a session ends, the jobid information will be purged within 5
minutes.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12330
Lustre-commit: a32ce8f50eca ("LU-12330 obdclass: allow per-session jobids.")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/34995
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lprocfs_status.h |   1 +
 fs/lustre/include/obd_class.h      |   4 +
 fs/lustre/obdclass/jobid.c         | 199 +++++++++++++++++++++++++++++++++++--
 fs/lustre/obdclass/obd_sysfs.c     |  48 +++++++++
 4 files changed, 246 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index 9f62d4e..6269bd3 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -360,6 +360,7 @@ enum {
 #define JOBSTATS_DISABLE		"disable"
 #define JOBSTATS_PROCNAME_UID		"procname_uid"
 #define JOBSTATS_NODELOCAL		"nodelocal"
+#define JOBSTATS_SESSION		"session"
 
 /* obd_config.c */
 void lustre_register_client_process_config(int (*cpc)(struct lustre_cfg *lcfg));
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 58c743c..76e8201 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -57,6 +57,10 @@
 struct obd_device *class_exp2obd(struct obd_export *exp);
 int class_handle_ioctl(unsigned int cmd, unsigned long arg);
 int lustre_get_jobid(char *jobid, size_t len);
+void jobid_cache_fini(void);
+int jobid_cache_init(void);
+char *jobid_current(void);
+int jobid_set_current(char *jobid);
 
 struct lu_device_type;
 
diff --git a/fs/lustre/obdclass/jobid.c b/fs/lustre/obdclass/jobid.c
index 8bad859..98b3f39 100644
--- a/fs/lustre/obdclass/jobid.c
+++ b/fs/lustre/obdclass/jobid.c
@@ -46,6 +46,151 @@
 char obd_jobid_var[JOBSTATS_JOBID_VAR_MAX_LEN + 1] = JOBSTATS_DISABLE;
 char obd_jobid_name[LUSTRE_JOBID_SIZE] = "%e.%u";
 
+/*
+ * Jobid can be set for a session (see setsid(2)) by writing to
+ * a sysfs file from any process in that session.
+ * The jobids are stored in a hash table indexed by the relevant
+ * struct pid.  We periodically look for entries where the pid has
+ * no PIDTYPE_SID tasks any more, and prune them.  This happens within
+ * 5 seconds of a jobid being added, and every 5 minutes when jobids exist,
+ * but none are added.
+ */
+#define JOBID_EXPEDITED_CLEAN	(5)
+#define JOBID_BACKGROUND_CLEAN	(5 * 60)
+
+struct session_jobid {
+	struct pid		*sj_session;
+	struct rhash_head	sj_linkage;
+	struct rcu_head		sj_rcu;
+	char			sj_jobid[1];
+};
+
+static const struct rhashtable_params jobid_params = {
+	.key_len	= sizeof(struct pid *),
+	.key_offset	= offsetof(struct session_jobid, sj_session),
+	.head_offset	= offsetof(struct session_jobid, sj_linkage),
+};
+
+static struct rhashtable session_jobids;
+
+/*
+ * jobid_current must be called with rcu_read_lock held.
+ * if it returns non-NULL, the string can only be used
+ * until rcu_read_unlock is called.
+ */
+char *jobid_current(void)
+{
+	struct pid *sid = task_session(current);
+	struct session_jobid *sj;
+
+	sj = rhashtable_lookup_fast(&session_jobids, &sid, jobid_params);
+	if (sj)
+		return sj->sj_jobid;
+	return NULL;
+}
+
+static void jobid_prune_expedite(void);
+/*
+ * jobid_set_current will try to add a new entry
+ * to the table.  If one exists with the same key, the
+ * jobid will be replaced
+ */
+int jobid_set_current(char *jobid)
+{
+	struct pid *sid;
+	struct session_jobid *sj, *origsj;
+	int ret;
+	int len = strlen(jobid);
+
+	sj = kmalloc(sizeof(*sj) + len, GFP_KERNEL);
+	if (!sj)
+		return -ENOMEM;
+	rcu_read_lock();
+	sid = task_session(current);
+	sj->sj_session = get_pid(sid);
+	strncpy(sj->sj_jobid, jobid, len+1);
+	origsj = rhashtable_lookup_get_insert_fast(&session_jobids,
+						   &sj->sj_linkage,
+						   jobid_params);
+	if (!origsj) {
+		/* successful insert */
+		rcu_read_unlock();
+		jobid_prune_expedite();
+		return 0;
+	}
+
+	if (IS_ERR(origsj)) {
+		put_pid(sj->sj_session);
+		kfree(sj);
+		rcu_read_unlock();
+		return PTR_ERR(origsj);
+	}
+	ret = rhashtable_replace_fast(&session_jobids,
+				      &origsj->sj_linkage,
+				      &sj->sj_linkage,
+				      jobid_params);
+	if (ret) {
+		put_pid(sj->sj_session);
+		kfree(sj);
+		rcu_read_unlock();
+		return ret;
+	}
+	put_pid(origsj->sj_session);
+	rcu_read_unlock();
+	kfree_rcu(origsj, sj_rcu);
+	jobid_prune_expedite();
+
+	return 0;
+}
+
+static void jobid_free(void *vsj, void *arg)
+{
+	struct session_jobid *sj = vsj;
+
+	put_pid(sj->sj_session);
+	kfree(sj);
+}
+
+static void jobid_prune(struct work_struct *work);
+static DECLARE_DELAYED_WORK(jobid_prune_work, jobid_prune);
+static int jobid_prune_expedited;
+static void jobid_prune(struct work_struct *work)
+{
+	int remaining = 0;
+	struct rhashtable_iter iter;
+	struct session_jobid *sj;
+
+	jobid_prune_expedited = 0;
+	rhashtable_walk_enter(&session_jobids, &iter);
+	rhashtable_walk_start(&iter);
+	while ((sj = rhashtable_walk_next(&iter)) != NULL) {
+		if (!hlist_empty(&sj->sj_session->tasks[PIDTYPE_SID])) {
+			remaining++;
+			continue;
+		}
+		if (rhashtable_remove_fast(&session_jobids,
+					   &sj->sj_linkage,
+					   jobid_params) == 0) {
+			put_pid(sj->sj_session);
+			kfree_rcu(sj, sj_rcu);
+		}
+	}
+	rhashtable_walk_stop(&iter);
+	rhashtable_walk_exit(&iter);
+	if (remaining)
+		schedule_delayed_work(&jobid_prune_work,
+				      JOBID_BACKGROUND_CLEAN * HZ);
+}
+
+static void jobid_prune_expedite(void)
+{
+	if (!jobid_prune_expedited) {
+		jobid_prune_expedited = 1;
+		mod_delayed_work(system_wq, &jobid_prune_work,
+				 JOBID_EXPEDITED_CLEAN * HZ);
+	}
+}
+
 /* Get jobid of current process from stored variable or calculate
  * it from pid and user_id.
  *
@@ -134,14 +279,40 @@ static int jobid_interpret_string(const char *jobfmt, char *jobid,
 	return joblen < 0 ? -EOVERFLOW : 0;
 }
 
+/**
+ * Generate the job identifier string for this process for tracking purposes.
+ *
+ * Fill in @jobid string based on the value of obd_jobid_var:
+ * JOBSTATS_DISABLE:	  none
+ * JOBSTATS_NODELOCAL:	  content of obd_jobid_name (jobid_interpret_string())
+ * JOBSTATS_PROCNAME_UID: process name/UID
+ * JOBSTATS_SESSION	  per-session value set by
+ *			  /sys/fs/lustre/jobid_this_session
+ *
+ * Return -ve error number, 0 on success.
+ */
 int lustre_get_jobid(char *jobid, size_t joblen)
 {
 	char tmp_jobid[LUSTRE_JOBID_SIZE] = "";
 
+	if (unlikely(joblen < 2)) {
+		if (joblen == 1)
+			jobid[0] = '\0';
+		return -EINVAL;
+	}
+
 	/* Jobstats isn't enabled */
 	if (strcmp(obd_jobid_var, JOBSTATS_DISABLE) == 0)
 		goto out_cache_jobid;
 
+	/* Whole node dedicated to single job */
+	if (strcmp(obd_jobid_var, JOBSTATS_NODELOCAL) == 0) {
+		int rc2 = jobid_interpret_string(obd_jobid_name,
+						 tmp_jobid, joblen);
+		if (!rc2)
+			goto out_cache_jobid;
+	}
+
 	/* Use process name + fsuid as jobid */
 	if (strcmp(obd_jobid_var, JOBSTATS_PROCNAME_UID) == 0) {
 		snprintf(tmp_jobid, LUSTRE_JOBID_SIZE, "%s.%u",
@@ -150,13 +321,17 @@ int lustre_get_jobid(char *jobid, size_t joblen)
 		goto out_cache_jobid;
 	}
 
-	/* Whole node dedicated to single job */
-	if (strcmp(obd_jobid_var, JOBSTATS_NODELOCAL) == 0) {
-		int rc2 = jobid_interpret_string(obd_jobid_name,
-						 tmp_jobid, joblen);
-		if (!rc2)
-			goto out_cache_jobid;
+	if (strcmp(obd_jobid_var, JOBSTATS_SESSION) == 0) {
+		char *jid;
+
+		rcu_read_lock();
+		jid = jobid_current();
+		if (jid)
+			strlcpy(jobid, jid, sizeof(jobid));
+		rcu_read_unlock();
+		goto out_cache_jobid;
 	}
+
 	return -ENOENT;
 
 out_cache_jobid:
@@ -167,3 +342,15 @@ int lustre_get_jobid(char *jobid, size_t joblen)
 	return 0;
 }
 EXPORT_SYMBOL(lustre_get_jobid);
+
+int jobid_cache_init(void)
+{
+	return rhashtable_init(&session_jobids, &jobid_params);
+}
+
+void jobid_cache_fini(void)
+{
+	cancel_delayed_work_sync(&jobid_prune_work);
+
+	rhashtable_free_and_destroy(&session_jobids, jobid_free, NULL);
+}
diff --git a/fs/lustre/obdclass/obd_sysfs.c b/fs/lustre/obdclass/obd_sysfs.c
index ca15936..8803d05 100644
--- a/fs/lustre/obdclass/obd_sysfs.c
+++ b/fs/lustre/obdclass/obd_sysfs.c
@@ -259,6 +259,44 @@ static ssize_t jobid_name_store(struct kobject *kobj, struct attribute *attr,
 	return count;
 }
 
+static ssize_t jobid_this_session_show(struct kobject *kobj,
+				       struct attribute *attr,
+				       char *buf)
+{
+	char *jid;
+	int ret = -ENOENT;
+
+	rcu_read_lock();
+	jid = jobid_current();
+	if (jid)
+		ret = snprintf(buf, PAGE_SIZE, "%s\n", jid);
+	rcu_read_unlock();
+	return ret;
+}
+
+static ssize_t jobid_this_session_store(struct kobject *kobj,
+					struct attribute *attr,
+					const char *buffer,
+					size_t count)
+{
+	char *jobid;
+	int len;
+	int ret;
+
+	if (!count || count > LUSTRE_JOBID_SIZE)
+		return -EINVAL;
+
+	jobid = kstrndup(buffer, count, GFP_KERNEL);
+	if (!jobid)
+		return -ENOMEM;
+	len = strcspn(jobid, "\n ");
+	jobid[len] = '\0';
+	ret = jobid_set_current(jobid);
+	kfree(jobid);
+
+	return ret ?: count;
+}
+
 /* Root for /sys/kernel/debug/lustre */
 struct dentry *debugfs_lustre_root;
 EXPORT_SYMBOL_GPL(debugfs_lustre_root);
@@ -268,6 +306,7 @@ static ssize_t jobid_name_store(struct kobject *kobj, struct attribute *attr,
 LUSTRE_RO_ATTR(health_check);
 LUSTRE_RW_ATTR(jobid_var);
 LUSTRE_RW_ATTR(jobid_name);
+LUSTRE_RW_ATTR(jobid_this_session);
 
 static struct attribute *lustre_attrs[] = {
 	&lustre_attr_version.attr,
@@ -275,6 +314,7 @@ static ssize_t jobid_name_store(struct kobject *kobj, struct attribute *attr,
 	&lustre_attr_health_check.attr,
 	&lustre_attr_jobid_name.attr,
 	&lustre_attr_jobid_var.attr,
+	&lustre_attr_jobid_this_session.attr,
 	&lustre_sattr_timeout.u.attr,
 	&lustre_attr_max_dirty_mb.attr,
 	&lustre_sattr_debug_peer_on_timeout.u.attr,
@@ -441,6 +481,12 @@ int class_procfs_init(void)
 		goto out;
 	}
 
+	rc = jobid_cache_init();
+	if (rc) {
+		kset_unregister(lustre_kset);
+		goto out;
+	}
+
 	debugfs_lustre_root = debugfs_create_dir("lustre", NULL);
 
 	debugfs_create_file("devices", 0444, debugfs_lustre_root, NULL,
@@ -458,6 +504,8 @@ int class_procfs_clean(void)
 
 	debugfs_lustre_root = NULL;
 
+	jobid_cache_fini();
+
 	sysfs_remove_group(&lustre_kset->kobj, &lustre_attr_group);
 
 	kset_unregister(lustre_kset);
-- 
1.8.3.1
