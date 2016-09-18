From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:46 -0400
Subject: [lustre-devel] [PATCH 047/124] staging: lustre: llite: enforce pool
	name length limit
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-48-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Li Xi <lixi@ddn.com>, James Simmons <jsimmons@infradead.org>

From: Li Xi <lixi@ddn.com>

The pool related codes have some inconsistency about the length
of pool name. Creating and setting a pool name of length 16
to a directory will succeed. However, creating a file under
that directory will fail.

This patch disables any pool name which is longer or equal to
16. And it changes LOV_MAXPOOLNAME from 16 to 15 which might
cause some invalid LLOG records of OST pools with 16 byte names.
It is not a problem since invalid LLOG records are just ignored.
And OST pools with 16 byte names won't work well anyway on the
old versions. There will be problem of inconsistency if part of
the servers have this patch and part of the servers don't. But
it would be safe to assume that this is not a normal
configuration.

Signed-off-by: Li Xi <lixi@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5054
Reviewed-on: http://review.whamcloud.com/10306
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    4 ++--
 .../lustre/lustre/include/lustre/lustre_user.h     |    8 ++++----
 drivers/staging/lustre/lustre/include/lustre_lmv.h |    2 +-
 drivers/staging/lustre/lustre/include/obd.h        |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |    2 +-
 5 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 6ff6615..56b5129 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1620,7 +1620,7 @@ struct lov_mds_md_v3 {	    /* LOV EA mds/wire data (little-endian) */
 	/* lmm_stripe_count used to be __u32 */
 	__u16 lmm_stripe_count;   /* num stripes in use for this object */
 	__u16 lmm_layout_gen;     /* layout generation number */
-	char  lmm_pool_name[LOV_MAXPOOLNAME]; /* must be 32bit aligned */
+	char  lmm_pool_name[LOV_MAXPOOLNAME + 1]; /* must be 32bit aligned */
 	struct lov_ost_data_v1 lmm_objects[0]; /* per-stripe data */
 };
 
@@ -2498,7 +2498,7 @@ struct lmv_mds_md_v1 {
 	__u32 lmv_padding1;
 	__u64 lmv_padding2;
 	__u64 lmv_padding3;
-	char lmv_pool_name[LOV_MAXPOOLNAME];	/* pool name */
+	char lmv_pool_name[LOV_MAXPOOLNAME + 1];/* pool name */
 	struct lu_fid lmv_stripe_fids[0];	/* FIDs for each stripe */
 };
 
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 5e907af..79cd876 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -295,8 +295,8 @@ enum ll_lease_type {
 #define LOV_PATTERN_F_HOLE	0x40000000 /* there is hole in LOV EA */
 #define LOV_PATTERN_F_RELEASED	0x80000000 /* HSM released file */
 
-#define LOV_MAXPOOLNAME 16
-#define LOV_POOLNAMEF "%.16s"
+#define LOV_MAXPOOLNAME 15
+#define LOV_POOLNAMEF "%.15s"
 
 #define LOV_MIN_STRIPE_BITS 16   /* maximum PAGE_SIZE (ia64), power of 2 */
 #define LOV_MIN_STRIPE_SIZE (1 << LOV_MIN_STRIPE_BITS)
@@ -354,7 +354,7 @@ struct lov_user_md_v3 {	   /* LOV EA user data (host-endian) */
 					   * used when reading
 					   */
 	};
-	char  lmm_pool_name[LOV_MAXPOOLNAME]; /* pool name */
+	char  lmm_pool_name[LOV_MAXPOOLNAME + 1];   /* pool name */
 	struct lov_user_ost_data_v1 lmm_objects[0]; /* per-stripe data */
 } __packed;
 
@@ -414,7 +414,7 @@ struct lmv_user_md_v1 {
 	__u32	lum_padding1;
 	__u32	lum_padding2;
 	__u32	lum_padding3;
-	char	lum_pool_name[LOV_MAXPOOLNAME];
+	char	lum_pool_name[LOV_MAXPOOLNAME + 1];
 	struct	lmv_user_mds_data  lum_objects[0];
 } __packed;
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_lmv.h b/drivers/staging/lustre/lustre/include/lustre_lmv.h
index 5a2fc30..388161e 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lmv.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lmv.h
@@ -48,7 +48,7 @@ struct lmv_stripe_md {
 	__u32	lsm_md_layout_version;
 	__u32	lsm_md_default_count;
 	__u32	lsm_md_default_index;
-	char	lsm_md_pool_name[LOV_MAXPOOLNAME];
+	char	lsm_md_pool_name[LOV_MAXPOOLNAME + 1];
 	struct lmv_oinfo lsm_md_oinfo[0];
 };
 
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index b84600a..1c884c0 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -99,7 +99,7 @@ struct lov_stripe_md {
 		__u32 lw_pattern;	  /* striping pattern (RAID0, RAID1) */
 		__u16 lw_stripe_count;  /* number of objects being striped over */
 		__u16 lw_layout_gen;       /* generation of the layout */
-		char  lw_pool_name[LOV_MAXPOOLNAME]; /* pool name */
+		char  lw_pool_name[LOV_MAXPOOLNAME + 1]; /* pool name */
 	} lsm_wire;
 
 	struct lov_oinfo *lsm_oinfo[0];
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 2390255..b33fd7b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -1383,7 +1383,7 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct lov_mds_md_v3, lmm_layout_gen));
 	LASSERTF((int)sizeof(((struct lov_mds_md_v3 *)0)->lmm_layout_gen) == 2, "found %lld\n",
 		 (long long)(int)sizeof(((struct lov_mds_md_v3 *)0)->lmm_layout_gen));
-	CLASSERT(LOV_MAXPOOLNAME == 16);
+	CLASSERT(LOV_MAXPOOLNAME == 15);
 	LASSERTF((int)offsetof(struct lov_mds_md_v3, lmm_pool_name[16]) == 48, "found %lld\n",
 		 (long long)(int)offsetof(struct lov_mds_md_v3, lmm_pool_name[16]));
 	LASSERTF((int)sizeof(((struct lov_mds_md_v3 *)0)->lmm_pool_name[16]) == 1, "found %lld\n",
-- 
1.7.1
