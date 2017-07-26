From: James Simmons <jsimmons@infradead.org>
Date: Wed, 26 Jul 2017 11:22:27 -0400
Subject: [lustre-devel] [PATCH 11/20] staging: lustre: lustre: fix all less
	than 0 comparison for unsigned values
In-Reply-To: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
References: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1501082556-17962-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Remove all test of less than zero for unsigned values
found with -Wtype-limits.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8843
Reviewed-on: https://review.whamcloud.com/23811
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jian Yu <jian.yu@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h | 2 +-
 drivers/staging/lustre/lustre/llite/rw.c          | 2 +-
 drivers/staging/lustre/lustre/lov/lov_object.c    | 8 ++++----
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c     | 2 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c     | 7 ++++---
 5 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 90a0c50..6887b81 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1358,7 +1358,7 @@ struct cl_2queue {
 /** IO types */
 enum cl_io_type {
 	/** read system call */
-	CIT_READ,
+	CIT_READ = 1,
 	/** write system call */
 	CIT_WRITE,
 	/** truncate, utime system calls */
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 1bac51f..166455e 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -115,7 +115,7 @@ void ll_ra_count_put(struct ll_sb_info *sbi, unsigned long len)
 
 static void ll_ra_stats_inc_sbi(struct ll_sb_info *sbi, enum ra_stat which)
 {
-	LASSERTF(which >= 0 && which < _NR_RA_STAT, "which: %u\n", which);
+	LASSERTF(which < _NR_RA_STAT, "which: %u\n", which);
 	lprocfs_counter_incr(sbi->ll_ra_stats, which);
 }
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 14f3826..4913229 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -638,7 +638,7 @@ static int lov_attr_get_raid0(const struct lu_env *env, struct cl_object *obj,
 	enum lov_layout_type		    __llt;		  \
 									\
 	__llt = __obj->lo_type;					 \
-	LASSERT(0 <= __llt && __llt < ARRAY_SIZE(lov_dispatch));	\
+	LASSERT(__llt < ARRAY_SIZE(lov_dispatch));		\
 	lov_dispatch[__llt].op(__VA_ARGS__);			    \
 })
 
@@ -697,7 +697,7 @@ static inline void lov_conf_thaw(struct lov_object *lov)
 									\
 	lov_conf_freeze(__obj);						\
 	__llt = __obj->lo_type;					 \
-	LASSERT(0 <= __llt && __llt < ARRAY_SIZE(lov_dispatch));	\
+	LASSERT(__llt < ARRAY_SIZE(lov_dispatch));	\
 	lov_dispatch[__llt].op(__VA_ARGS__);			    \
 	lov_conf_thaw(__obj);						\
 } while (0)
@@ -748,13 +748,13 @@ static int lov_layout_change(const struct lu_env *unused,
 	u16 refcheck;
 	int rc;
 
-	LASSERT(0 <= lov->lo_type && lov->lo_type < ARRAY_SIZE(lov_dispatch));
+	LASSERT(lov->lo_type < ARRAY_SIZE(lov_dispatch));
 
 	env = cl_env_get(&refcheck);
 	if (IS_ERR(env))
 		return PTR_ERR(env);
 
-	LASSERT(0 <= llt && llt < ARRAY_SIZE(lov_dispatch));
+	LASSERT(llt < ARRAY_SIZE(lov_dispatch));
 
 	CDEBUG(D_INODE, DFID " from %s to %s\n",
 	       PFID(lu_object_fid(lov2lu(lov))),
diff --git a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
index 9021c46..e40644b 100644
--- a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
+++ b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
@@ -57,7 +57,7 @@ static ssize_t active_store(struct kobject *kobj, struct attribute *attr,
 	if (rc)
 		return rc;
 
-	if (val < 0 || val > 1)
+	if (val > 1)
 		return -ERANGE;
 
 	/* opposite senses */
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 0100d27..e1207c2 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -783,6 +783,7 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 			/* pull ext's start back to cover cur */
 			ext->oe_start = cur->oe_start;
 			ext->oe_grants += chunksize;
+			LASSERT(*grants >= chunksize);
 			*grants -= chunksize;
 
 			found = osc_extent_hold(ext);
@@ -790,6 +791,7 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 			/* rear merge */
 			ext->oe_end = cur->oe_end;
 			ext->oe_grants += chunksize;
+			LASSERT(*grants >= chunksize);
 			*grants -= chunksize;
 
 			/* try to merge with the next one because we just fill
@@ -819,8 +821,8 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 		/* create a new extent */
 		EASSERT(osc_extent_is_overlapped(obj, cur) == 0, cur);
 		cur->oe_grants = chunksize + cli->cl_extent_tax;
+		LASSERT(*grants >= cur->oe_grants);
 		*grants -= cur->oe_grants;
-		LASSERT(*grants >= 0);
 
 		cur->oe_state = OES_CACHE;
 		found = osc_extent_hold(cur);
@@ -849,7 +851,6 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 
 out:
 	osc_extent_put(env, cur);
-	LASSERT(*grants >= 0);
 	return found;
 }
 
@@ -1219,8 +1220,8 @@ static int osc_extent_expand(struct osc_extent *ext, pgoff_t index,
 
 	ext->oe_end = end_index;
 	ext->oe_grants += chunksize;
+	LASSERT(*grants >= chunksize);
 	*grants -= chunksize;
-	LASSERT(*grants >= 0);
 	EASSERTF(osc_extent_is_overlapped(obj, ext) == 0, ext,
 		 "overlapped after expanding for %lu.\n", index);
 
-- 
1.8.3.1
