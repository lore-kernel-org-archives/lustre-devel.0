From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:18 -0500
Subject: [lustre-devel] [PATCH 390/622] lustre: obdclass: don't send
 multiple statfs RPCs
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-391-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

If multiple threads are racing to send a non-cached OST_STATFS or
MDS_STATFS RPC, this can cause a significant RPC storm for systems
with many-core clients and many OSTs due to amplification of the
requests, and the fact that STATFS RPCs are sent asynchronously.
Some logs have shown few 96-core clients have 20k+ OST_STATFS RPCs
in flight concurrently, which can overload the network if many OSTs
are on the same OSS nodes (osc.*.max_rpcs_in_flight is per OST).

This was not previously a significant issue when core counts were
smaller on the clients, or with fewer OSTs per OSS.

If a thread can't use the cached statfs values, limit statfs to one
thread at a time, since the thread(s) would be blocked waiting for
the RPC replies anyway, which can't finish faster if many are sent.

Also add a llite.*.statfs_max_age parameter that can be tuned on
to control the maximum age (in seconds) of the statfs cache.  This
can avoid overhead for workloads that are statfs heavy, given that
the filesystem is _probably_ not running out of space this second,
and even so "statfs" does not guarantee space in parallel workloads.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12368
Lustre-commit: 1c41a6ac390b ("LU-12368 obdclass: don't send multiple statfs RPCs")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35380
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h          |  2 ++
 fs/lustre/include/obd_class.h    | 22 ++++++++++++++++++++--
 fs/lustre/llite/llite_internal.h |  3 +++
 fs/lustre/llite/llite_lib.c      |  5 +++--
 fs/lustre/llite/lproc_llite.c    | 31 +++++++++++++++++++++++++++++++
 5 files changed, 59 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index f53c303..53d078e 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -379,6 +379,8 @@ struct echo_client_obd {
 
 /* allow statfs data caching for 1 second */
 #define OBD_STATFS_CACHE_SECONDS 1
+/* arbitrary maximum. larger would be useless, allows catching bogus input */
+#define OBD_STATFS_CACHE_MAX_AGE 3600 /* seconds */
 
 #define lov_tgt_desc lu_tgt_desc
 
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 76e8201..b8afa5a 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -952,13 +952,31 @@ static inline int obd_statfs(const struct lu_env *env, struct obd_export *exp,
 	if (obd->obd_osfs_age < max_age ||
 	    ((obd->obd_osfs.os_state & OS_STATE_SUM) &&
 	     !(flags & OBD_STATFS_SUM))) {
-		rc = OBP(obd, statfs)(env, exp, osfs, max_age, flags);
+		bool update_age = false;
+		/* the RPC will block anyway, so avoid sending many at once */
+		rc = mutex_lock_interruptible(&obd->obd_dev_mutex);
+		if (rc)
+			return rc;
+		if (obd->obd_osfs_age < max_age ||
+		    ((obd->obd_osfs.os_state & OS_STATE_SUM) &&
+		     !(flags & OBD_STATFS_SUM))) {
+			rc = OBP(obd, statfs)(env, exp, osfs, max_age, flags);
+			update_age = true;
+		} else {
+			CDEBUG(D_SUPER,
+			       "%s: new %p cache blocks %llu/%llu objects %llu/%llu\n",
+			       obd->obd_name, &obd->obd_osfs,
+			       obd->obd_osfs.os_bavail, obd->obd_osfs.os_blocks,
+			       obd->obd_osfs.os_ffree, obd->obd_osfs.os_files);
+		}
 		if (rc == 0) {
 			spin_lock(&obd->obd_osfs_lock);
 			memcpy(&obd->obd_osfs, osfs, sizeof(obd->obd_osfs));
-			obd->obd_osfs_age = ktime_get_seconds();
+			if (update_age)
+				obd->obd_osfs_age = ktime_get_seconds();
 			spin_unlock(&obd->obd_osfs_lock);
 		}
+		mutex_unlock(&obd->obd_dev_mutex);
 	} else {
 		CDEBUG(D_SUPER,
 		       "%s: use %p cache blocks %llu/%llu objects %llu/%llu\n",
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 8d95694..9d60ae5 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -568,6 +568,9 @@ struct ll_sb_info {
 	/* st_blksize returned by stat(2), when non-zero */
 	unsigned int		 ll_stat_blksize;
 
+	/* maximum relative age of cached statfs results */
+	unsigned int		  ll_statfs_max_age;
+
 	struct kset		ll_kset;	/* sysfs object */
 	struct completion	 ll_kobj_unregister;
 
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 33f7fdb..cc417d6 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -87,6 +87,7 @@ static struct ll_sb_info *ll_init_sbi(void)
 	spin_lock_init(&sbi->ll_pp_extent_lock);
 	spin_lock_init(&sbi->ll_process_lock);
 	sbi->ll_rw_stats_on = 0;
+	sbi->ll_statfs_max_age = OBD_STATFS_CACHE_SECONDS;
 
 	si_meminfo(&si);
 	pages = si.totalram - si.totalhigh;
@@ -330,7 +331,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	 * available
 	 */
 	err = obd_statfs(NULL, sbi->ll_md_exp, osfs,
-			 ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS,
+			 ktime_get_seconds() - sbi->ll_statfs_max_age,
 			 OBD_STATFS_FOR_MDT0);
 	if (err)
 		goto out_md_fid;
@@ -1860,7 +1861,7 @@ int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
 	time64_t max_age;
 	int rc;
 
-	max_age = ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS;
+	max_age = ktime_get_seconds() - sbi->ll_statfs_max_age;
 
 	rc = obd_statfs(NULL, sbi->ll_md_exp, osfs, max_age, flags);
 	if (rc)
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 02403e4..4cffd36 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -882,6 +882,36 @@ static ssize_t lazystatfs_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(lazystatfs);
 
+static ssize_t statfs_max_age_show(struct kobject *kobj, struct attribute *attr,
+				   char *buf)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+
+	return snprintf(buf, PAGE_SIZE, "%u\n", sbi->ll_statfs_max_age);
+}
+
+static ssize_t statfs_max_age_store(struct kobject *kobj,
+				    struct attribute *attr, const char *buffer,
+				    size_t count)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+	unsigned int val;
+	int rc;
+
+	rc = kstrtouint(buffer, 10, &val);
+	if (rc)
+		return rc;
+	if (val > OBD_STATFS_CACHE_MAX_AGE)
+		return -EINVAL;
+
+	sbi->ll_statfs_max_age = val;
+
+	return count;
+}
+LUSTRE_RW_ATTR(statfs_max_age);
+
 static ssize_t max_easize_show(struct kobject *kobj,
 			       struct attribute *attr,
 			       char *buf)
@@ -1480,6 +1510,7 @@ struct lprocfs_vars lprocfs_llite_obd_vars[] = {
 	&lustre_attr_statahead_max.attr,
 	&lustre_attr_statahead_agl.attr,
 	&lustre_attr_lazystatfs.attr,
+	&lustre_attr_statfs_max_age.attr,
 	&lustre_attr_max_easize.attr,
 	&lustre_attr_default_easize.attr,
 	&lustre_attr_xattr_cache.attr,
-- 
1.8.3.1
