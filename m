From: James Simmons <jsimmons@infradead.org>
Date: Sat, 13 Jun 2020 12:27:14 -0400
Subject: [lustre-devel] [PATCH 18/20] lustre: obd: Rename OS_STATE flags to
 OS_STATFS
In-Reply-To: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
References: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1592065636-28333-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

The statfs state flags are oddly named "OS_STATE_[STATE]"
Rename them to "OS_STATFS_[STATE]" to make their role clearer
and make them easier to find.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11963
Lustre-commit: 9be2db987767a ("LU-11963 obd: Rename OS_STATE flags to OS_STATFS")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34289
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <farr0186@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h           |  4 ++--
 fs/lustre/llite/llite_lib.c             |  2 +-
 fs/lustre/lmv/lmv_obd.c                 |  2 +-
 fs/lustre/ptlrpc/wiretest.c             | 28 ++++++++++++++--------------
 include/uapi/linux/lustre/lustre_user.h | 20 ++++++++++----------
 5 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index be73a165..746782b 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -942,14 +942,14 @@ static inline int obd_statfs(const struct lu_env *env, struct obd_export *exp,
 	       obd->obd_name, obd->obd_osfs_age, max_age);
 	/* ignore cache if aggregated isn't expected */
 	if (obd->obd_osfs_age < max_age ||
-	    ((obd->obd_osfs.os_state & OS_STATE_SUM) &&
+	    ((obd->obd_osfs.os_state & OS_STATFS_SUM) &&
 	     !(flags & OBD_STATFS_SUM))) {
 		/* the RPC will block anyway, so avoid sending many at once */
 		rc = mutex_lock_interruptible(&obd->obd_dev_mutex);
 		if (rc)
 			return rc;
 		if (obd->obd_osfs_age < max_age ||
-		    ((obd->obd_osfs.os_state & OS_STATE_SUM) &&
+		    ((obd->obd_osfs.os_state & OS_STATFS_SUM) &&
 		     !(flags & OBD_STATFS_SUM))) {
 			rc = OBP(obd, statfs)(env, exp, osfs, max_age, flags);
 		} else {
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 6cd9f7e..aad19a2 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1924,7 +1924,7 @@ int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
 	       osfs->os_bavail, osfs->os_blocks, osfs->os_ffree,
 	       osfs->os_files);
 
-	if (osfs->os_state & OS_STATE_SUM)
+	if (osfs->os_state & OS_STATFS_SUM)
 		goto out;
 
 	rc = obd_statfs(NULL, sbi->ll_dt_exp, &obd_osfs, max_age, flags);
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 203a17b..c5f21cd 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1255,7 +1255,7 @@ static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
 			goto out_free_temp;
 		}
 
-		if (temp->os_state & OS_STATE_SUM ||
+		if (temp->os_state & OS_STATFS_SUM ||
 		    flags == OBD_STATFS_FOR_MDT0) {
 			/* Reset to the last aggregated values
 			 * and don't sum with non-aggrated data.
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 719d73b..74a4e940 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1851,20 +1851,20 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct obd_statfs, os_spare9));
 	LASSERTF((int)sizeof(((struct obd_statfs *)0)->os_spare9) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct obd_statfs *)0)->os_spare9));
-	LASSERTF(OS_STATE_DEGRADED == 0x00000001UL, "found %lld\n",
-		 (long long)OS_STATE_DEGRADED);
-	LASSERTF(OS_STATE_READONLY == 0x00000002UL, "found %lld\n",
-		 (long long)OS_STATE_READONLY);
-	LASSERTF(OS_STATE_NOPRECREATE == 0x00000004UL, "found %lld\n",
-		 (long long)OS_STATE_NOPRECREATE);
-	LASSERTF(OS_STATE_ENOSPC == 0x00000020UL, "found %lld\n",
-		 (long long)OS_STATE_ENOSPC);
-	LASSERTF(OS_STATE_ENOINO == 0x00000040UL, "found %lld\n",
-		 (long long)OS_STATE_ENOINO);
-	LASSERTF(OS_STATE_SUM == 0x00000100UL, "found %lld\n",
-		 (long long)OS_STATE_SUM);
-	LASSERTF(OS_STATE_NONROT == 0x00000200UL, "found %lld\n",
-		 (long long)OS_STATE_NONROT);
+	LASSERTF(OS_STATFS_DEGRADED == 0x00000001UL, "found %lld\n",
+		 (long long)OS_STATFS_DEGRADED);
+	LASSERTF(OS_STATFS_READONLY == 0x00000002UL, "found %lld\n",
+		 (long long)OS_STATFS_READONLY);
+	LASSERTF(OS_STATFS_NOPRECREATE == 0x00000004UL, "found %lld\n",
+		 (long long)OS_STATFS_NOPRECREATE);
+	LASSERTF(OS_STATFS_ENOSPC == 0x00000020UL, "found %lld\n",
+		 (long long)OS_STATFS_ENOSPC);
+	LASSERTF(OS_STATFS_ENOINO == 0x00000040UL, "found %lld\n",
+		 (long long)OS_STATFS_ENOINO);
+	LASSERTF(OS_STATFS_SUM == 0x00000100UL, "found %lld\n",
+		 (long long)OS_STATFS_SUM);
+	LASSERTF(OS_STATFS_NONROT == 0x00000200UL, "found %lld\n",
+		 (long long)OS_STATFS_NONROT);
 
 	/* Checks for struct obd_ioobj */
 	LASSERTF((int)sizeof(struct obd_ioobj) == 24, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 004d373..121c064 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -105,15 +105,15 @@
 #define LUSTRE_FIEMAP_FLAGS_COMPAT (FIEMAP_FLAG_SYNC | FIEMAP_FLAG_DEVICE_ORDER)
 
 enum obd_statfs_state {
-	OS_STATE_DEGRADED	= 0x00000001, /**< RAID degraded/rebuilding */
-	OS_STATE_READONLY	= 0x00000002, /**< filesystem is read-only */
-	OS_STATE_NOPRECREATE	= 0x00000004, /**< no object precreation */
-	OS_STATE_UNUSED1	= 0x00000008, /**< obsolete 1.6, was EROFS=30 */
-	OS_STATE_UNUSED2	= 0x00000010, /**< obsolete 1.6, was EROFS=30 */
-	OS_STATE_ENOSPC		= 0x00000020, /**< not enough free space */
-	OS_STATE_ENOINO		= 0x00000040, /**< not enough inodes */
-	OS_STATE_SUM		= 0x00000100, /**< aggregated for all tagrets */
-	OS_STATE_NONROT		= 0x00000200, /**< non-rotational device */
+	OS_STATFS_DEGRADED	= 0x00000001, /**< RAID degraded/rebuilding */
+	OS_STATFS_READONLY	= 0x00000002, /**< filesystem is read-only */
+	OS_STATFS_NOPRECREATE	= 0x00000004, /**< no object precreation */
+	OS_STATFS_UNUSED1	= 0x00000008, /**< obsolete 1.6, was EROFS=30 */
+	OS_STATFS_UNUSED2	= 0x00000010, /**< obsolete 1.6, was EROFS=30 */
+	OS_STATFS_ENOSPC	= 0x00000020, /**< not enough free space */
+	OS_STATFS_ENOINO	= 0x00000040, /**< not enough inodes */
+	OS_STATFS_SUM		= 0x00000100, /**< aggregated for all tagrets */
+	OS_STATFS_NONROT	= 0x00000200, /**< non-rotational device */
 };
 
 struct obd_statfs {
@@ -127,7 +127,7 @@ struct obd_statfs {
 	__u32	os_bsize;	/* block size in bytes for os_blocks */
 	__u32	os_namelen;	/* maximum length of filename in bytes*/
 	__u64	os_maxbytes;	/* maximum object size in bytes */
-	__u32	os_state;	/**< obd_statfs_state OS_STATE_* flag */
+	__u32	os_state;	/**< obd_statfs_state OS_STATFS_* flag */
 	__u32	os_fprecreated;	/* objs available now to the caller
 				 * used in QoS code to find preferred OSTs
 				 */
-- 
1.8.3.1
