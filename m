From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:58:17 -0400
Subject: [lustre-devel] [PATCH 27/28] lustre: llite: control concurrent
 statahead instances
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Fan Yong <fan.yong@intel.com>

It is found that if there are too many concurrent statahead
instances, then related statahead RPCs may accumulate on the
client import (for MDT) RPC lists
(imp_sending_list/imp_delayed_list/imp_unreplied_lis), as to
seriously affect the efficiency of spin_lock under the case
of MDT overloaded or in recovery. Be as the temporarily solution,
restrict the concurrent statahead instances.

If want to support more concurrent statahead instances, please
consider to decentralize the RPC lists attached on related import.

Signed-off-by: Fan Yong <fan.yong@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-11079
Reviewed-on: https://review.whamcloud.com/32690
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/llite/llite_internal.h   | 13 +++++++-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  1 +
 drivers/staging/lustre/lustre/llite/lproc_llite.c  | 37 ++++++++++++++++++++++
 drivers/staging/lustre/lustre/llite/statahead.c    | 24 ++++++++++----
 4 files changed, 68 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index ad380f1..359bd53 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -504,6 +504,9 @@ struct ll_sb_info {
 	int		       ll_rw_stats_on;
 
 	/* metadata stat-ahead */
+	unsigned int		ll_sa_running_max; /* max concurrent
+						    * statahead instances
+						    */
 	unsigned int	      ll_sa_max;     /* max statahead RPCs */
 	atomic_t		  ll_sa_total;   /* statahead thread started
 						  * count
@@ -1063,7 +1066,15 @@ enum ras_update_flags {
 /* statahead.c */
 #define LL_SA_RPC_MIN	   2
 #define LL_SA_RPC_DEF	   32
-#define LL_SA_RPC_MAX	   8192
+#define LL_SA_RPC_MAX		512
+
+/* XXX: If want to support more concurrent statahead instances,
+ *	please consider to decentralize the RPC lists attached
+ *	on related import, such as imp_{sending,delayed}_list.
+ *	LU-11079
+ */
+#define LL_SA_RUNNING_MAX	256
+#define LL_SA_RUNNING_DEF	16
 
 #define LL_SA_CACHE_BIT	 5
 #define LL_SA_CACHE_SIZE	(1 << LL_SA_CACHE_BIT)
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index a5e65db..fae7e50 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -116,6 +116,7 @@ static struct ll_sb_info *ll_init_sbi(void)
 	}
 
 	/* metadata statahead is enabled by default */
+	sbi->ll_sa_running_max = LL_SA_RUNNING_DEF;
 	sbi->ll_sa_max = LL_SA_RPC_DEF;
 	atomic_set(&sbi->ll_sa_total, 0);
 	atomic_set(&sbi->ll_sa_wrong, 0);
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index d8ef090..10dc7a8 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -714,6 +714,42 @@ static ssize_t stats_track_gid_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(stats_track_gid);
 
+static ssize_t statahead_running_max_show(struct kobject *kobj,
+					  struct attribute *attr,
+					  char *buf)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+
+	return snprintf(buf, 16, "%u\n", sbi->ll_sa_running_max);
+}
+
+static ssize_t statahead_running_max_store(struct kobject *kobj,
+					   struct attribute *attr,
+					   const char *buffer,
+					   size_t count)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+	unsigned long val;
+	int rc;
+
+	rc = kstrtoul(buffer, 0, &val);
+	if (rc)
+		return rc;
+
+	if (val <= LL_SA_RUNNING_MAX) {
+		sbi->ll_sa_running_max = val;
+		return count;
+	}
+
+	CERROR("Bad statahead_running_max value %lu. Valid values are in the range [0, %d]\n",
+	       val, LL_SA_RUNNING_MAX);
+
+	return -ERANGE;
+}
+LUSTRE_RW_ATTR(statahead_running_max);
+
 static ssize_t statahead_max_show(struct kobject *kobj,
 				  struct attribute *attr,
 				  char *buf)
@@ -1171,6 +1207,7 @@ static ssize_t ll_nosquash_nids_seq_write(struct file *file,
 	&lustre_attr_stats_track_pid.attr,
 	&lustre_attr_stats_track_ppid.attr,
 	&lustre_attr_stats_track_gid.attr,
+	&lustre_attr_statahead_running_max.attr,
 	&lustre_attr_statahead_max.attr,
 	&lustre_attr_statahead_agl.attr,
 	&lustre_attr_lazystatfs.attr,
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 8f3ff7f..336f1cf 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -1472,23 +1472,34 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 	struct ll_statahead_info *sai = NULL;
 	struct task_struct *task;
 	struct dentry *parent = dentry->d_parent;
-	int rc;
+	struct ll_sb_info *sbi = ll_i2sbi(parent->d_inode);
+	int first = LS_FIRST_DE;
+	int rc = 0;
 
 	/* I am the "lli_opendir_pid" owner, only me can set "lli_sai". */
-	rc = is_first_dirent(dir, dentry);
-	if (rc == LS_NOT_FIRST_DE) {
+	first = is_first_dirent(dir, dentry);
+	if (first == LS_NOT_FIRST_DE) {
 		/* It is not "ls -{a}l" operation, no need statahead for it. */
 		rc = -EFAULT;
 		goto out;
 	}
 
+	if (unlikely(atomic_inc_return(&sbi->ll_sa_running) >
+				       sbi->ll_sa_running_max)) {
+		CDEBUG(D_READA,
+		       "Too many concurrent statahead instances, avoid new statahead instance temporarily.\n");
+		rc = -EMFILE;
+		goto out;
+	}
+
+
 	sai = ll_sai_alloc(parent);
 	if (!sai) {
 		rc = -ENOMEM;
 		goto out;
 	}
 
-	sai->sai_ls_all = (rc == LS_FIRST_DOT_DE);
+	sai->sai_ls_all = (first == LS_FIRST_DOT_DE);
 	/*
 	 * if current lli_opendir_key was deauthorized, or dir re-opened by
 	 * another process, don't start statahead, otherwise the newly spawned
@@ -1504,8 +1515,6 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 	lli->lli_sai = sai;
 	spin_unlock(&lli->lli_sa_lock);
 
-	atomic_inc(&ll_i2sbi(parent->d_inode)->ll_sa_running);
-
 	CDEBUG(D_READA, "start statahead thread: [pid %d] [parent %pd]\n",
 	       current->pid, parent);
 
@@ -1545,6 +1554,9 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 	spin_unlock(&lli->lli_sa_lock);
 	if (sai)
 		ll_sai_free(sai);
+	if (first != LS_NOT_FIRST_DE)
+		atomic_dec(&sbi->ll_sa_running);
+
 	return rc;
 }
 
-- 
1.8.3.1
