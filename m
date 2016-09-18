From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:33 -0400
Subject: [lustre-devel] [PATCH 094/124] staging: lustre: lov: flatten struct
	lov_stripe_md
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-95-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Flatten out the lsm_wire struct from the middle of struct
lov_stripe_md and remove the member name macros.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5814
Reviewed-on: http://review.whamcloud.com/12581
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h        |   30 +++++--------------
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |    4 +-
 2 files changed, 10 insertions(+), 24 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index d1c4ccc..8e426b8 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -88,31 +88,17 @@ struct lov_stripe_md {
 	/* maximum possible file size, might change as OSTs status changes,
 	 * e.g. disconnected, deactivated
 	 */
-	__u64	    lsm_maxbytes;
-	struct {
-		/* Public members. */
-		struct ost_id lw_object_oi; /* lov object id/seq */
-
-		/* LOV-private members start here -- only for use in lov/. */
-		__u32 lw_magic;
-		__u32 lw_stripe_size;      /* size of the stripe */
-		__u32 lw_pattern;	  /* striping pattern (RAID0, RAID1) */
-		__u16 lw_stripe_count;  /* number of objects being striped over */
-		__u16 lw_layout_gen;       /* generation of the layout */
-		char  lw_pool_name[LOV_MAXPOOLNAME + 1]; /* pool name */
-	} lsm_wire;
-
+	__u64		lsm_maxbytes;
+	struct ost_id	lsm_oi;
+	__u32		lsm_magic;
+	__u32		lsm_stripe_size;
+	__u32		lsm_pattern;	/* striping pattern (RAID0, RAID1) */
+	__u16		lsm_stripe_count;
+	__u16		lsm_layout_gen;
+	char		lsm_pool_name[LOV_MAXPOOLNAME + 1];
 	struct lov_oinfo *lsm_oinfo[0];
 };
 
-#define lsm_oi		 lsm_wire.lw_object_oi
-#define lsm_magic	lsm_wire.lw_magic
-#define lsm_layout_gen   lsm_wire.lw_layout_gen
-#define lsm_stripe_size  lsm_wire.lw_stripe_size
-#define lsm_pattern      lsm_wire.lw_pattern
-#define lsm_stripe_count lsm_wire.lw_stripe_count
-#define lsm_pool_name    lsm_wire.lw_pool_name
-
 static inline bool lsm_is_released(struct lov_stripe_md *lsm)
 {
 	return !!(lsm->lsm_pattern & LOV_PATTERN_F_RELEASED);
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index ec40cf2..4d2b7d3 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -744,8 +744,8 @@ static inline struct lov_thread_info *lov_env_info(const struct lu_env *env)
 static inline struct lov_layout_raid0 *lov_r0(struct lov_object *lov)
 {
 	LASSERT(lov->lo_type == LLT_RAID0);
-	LASSERT(lov->lo_lsm->lsm_wire.lw_magic == LOV_MAGIC ||
-		lov->lo_lsm->lsm_wire.lw_magic == LOV_MAGIC_V3);
+	LASSERT(lov->lo_lsm->lsm_magic == LOV_MAGIC ||
+		lov->lo_lsm->lsm_magic == LOV_MAGIC_V3);
 	return &lov->u.raid0;
 }
 
-- 
1.7.1
