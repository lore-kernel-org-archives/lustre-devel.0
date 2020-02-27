From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:35 -0500
Subject: [lustre-devel] [PATCH 467/622] lustre: llite: align field names in
 ll_sb_info
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-468-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

Align field names and most comments in
struct ll_sb_info.

Signed-off-by: NeilBrown <neilb@suse.de>
Reviewed-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h | 74 ++++++++++++++++++++--------------------
 1 file changed, 37 insertions(+), 37 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 6186720..bb5f519 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -493,26 +493,26 @@ struct ll_sb_info {
 	/* this protects pglist and ra_info.  It isn't safe to
 	 * grab from interrupt contexts
 	 */
-	spinlock_t		  ll_lock;
-	spinlock_t		  ll_pp_extent_lock; /* pp_extent entry*/
-	spinlock_t		  ll_process_lock; /* ll_rw_process_info */
-	struct obd_uuid	   ll_sb_uuid;
+	spinlock_t		ll_lock;
+	spinlock_t		ll_pp_extent_lock; /* pp_extent entry*/
+	spinlock_t		ll_process_lock; /* ll_rw_process_info */
+	struct obd_uuid		ll_sb_uuid;
 	struct obd_export	*ll_md_exp;
 	struct obd_export	*ll_dt_exp;
 	struct obd_device	*ll_md_obd;
 	struct obd_device	*ll_dt_obd;
 	struct dentry		*ll_debugfs_entry;
-	struct lu_fid	     ll_root_fid; /* root object fid */
+	struct lu_fid		ll_root_fid; /* root object fid */
 
-	int		       ll_flags;
-	unsigned int		  ll_xattr_cache_enabled:1,
+	int			ll_flags;
+	unsigned int		ll_xattr_cache_enabled:1,
 				ll_xattr_cache_set:1, /* already set to 0/1 */
-				  ll_client_common_fill_super_succeeded:1,
-				  ll_checksum_set:1;
+				ll_client_common_fill_super_succeeded:1,
+				ll_checksum_set:1;
 
-	struct lustre_client_ocd  ll_lco;
+	struct lustre_client_ocd ll_lco;
 
-	struct lprocfs_stats     *ll_stats; /* lprocfs stats counter */
+	struct lprocfs_stats	*ll_stats; /* lprocfs stats counter */
 
 	/*
 	 * Used to track "unstable" pages on a client, and maintain a
@@ -520,58 +520,58 @@ struct ll_sb_info {
 	 * any page which is sent to a server as part of a bulk request,
 	 * but is uncommitted to stable storage.
 	 */
-	struct cl_client_cache    *ll_cache;
+	struct cl_client_cache	*ll_cache;
 
-	struct lprocfs_stats     *ll_ra_stats;
+	struct lprocfs_stats	*ll_ra_stats;
 
-	struct ll_ra_info	 ll_ra_info;
-	unsigned int	      ll_namelen;
+	struct ll_ra_info	ll_ra_info;
+	unsigned int		ll_namelen;
 	const struct file_operations	*ll_fop;
 
-	struct lu_site	   *ll_site;
-	struct cl_device	 *ll_cl;
+	struct lu_site		*ll_site;
+	struct cl_device	*ll_cl;
 	/* Statistics */
 	struct ll_rw_extents_info ll_rw_extents_info;
-	int		       ll_extent_process_count;
+	int			ll_extent_process_count;
 	struct ll_rw_process_info ll_rw_process_info[LL_PROCESS_HIST_MAX];
-	unsigned int	      ll_offset_process_count;
+	unsigned int		ll_offset_process_count;
 	struct ll_rw_process_info ll_rw_offset_info[LL_OFFSET_HIST_MAX];
-	unsigned int	      ll_rw_offset_entry_count;
-	int		       ll_stats_track_id;
-	enum stats_track_type     ll_stats_track_type;
-	int		       ll_rw_stats_on;
+	unsigned int		ll_rw_offset_entry_count;
+	int			ll_stats_track_id;
+	enum stats_track_type	ll_stats_track_type;
+	int			ll_rw_stats_on;
 
 	/* metadata stat-ahead */
 	unsigned int		ll_sa_running_max; /* max concurrent
 						    * statahead instances
 						    */
-	unsigned int	      ll_sa_max;     /* max statahead RPCs */
-	atomic_t		  ll_sa_total;   /* statahead thread started
-						  * count
-						  */
-	atomic_t		  ll_sa_wrong;   /* statahead thread stopped for
-						  * low hit ratio
-						  */
+	unsigned int		ll_sa_max;	/* max statahead RPCs */
+	atomic_t		ll_sa_total;	/* statahead thread started
+						 * count
+						 */
+	atomic_t		ll_sa_wrong;	/* statahead thread stopped for
+						 * low hit ratio
+						 */
 	atomic_t		ll_sa_running;	/* running statahead thread
 						 * count
 						 */
-	atomic_t		  ll_agl_total;  /* AGL thread started count */
+	atomic_t		ll_agl_total;	/* AGL thread started count */
 
-	dev_t			  ll_sdev_orig; /* save s_dev before assign for
+	dev_t			ll_sdev_orig;	/* save s_dev before assign for
 						 * clustered nfs
 						 */
 	/* root squash */
-	struct root_squash_info	  ll_squash;
-	struct path		 ll_mnt;
+	struct root_squash_info	ll_squash;
+	struct path		ll_mnt;
 
 	/* st_blksize returned by stat(2), when non-zero */
-	unsigned int		 ll_stat_blksize;
+	unsigned int		ll_stat_blksize;
 
 	/* maximum relative age of cached statfs results */
-	unsigned int		  ll_statfs_max_age;
+	unsigned int		ll_statfs_max_age;
 
 	struct kset		ll_kset;	/* sysfs object */
-	struct completion	 ll_kobj_unregister;
+	struct completion	ll_kobj_unregister;
 
 	/* File heat */
 	unsigned int		ll_heat_decay_weight;
-- 
1.8.3.1
