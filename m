From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:28 -0400
Subject: [lustre-devel] [PATCH 089/124] staging: lustre: obd: change
	brw_page->count to unsigned
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-90-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Pages count is unsigned. So, change the type accordant usage.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5577
Reviewed-on: http://review.whamcloud.com/12378
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h        |    2 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   10 ++++++----
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |    2 +-
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index cd7f552..d1c4ccc 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -176,7 +176,7 @@ struct obd_type {
 struct brw_page {
 	u64 off;
 	struct page *pg;
-	int count;
+	unsigned int count;
 	u32 flag;
 };
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index fb18dd1..31deab0 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1099,7 +1099,7 @@ static int osc_extent_make_ready(const struct lu_env *env,
 	struct osc_async_page *oap;
 	struct osc_async_page *last = NULL;
 	struct osc_object *obj = ext->oe_obj;
-	int page_count = 0;
+	unsigned int page_count = 0;
 	int rc;
 
 	/* we're going to grab page lock, so object lock must not be taken. */
@@ -1140,9 +1140,11 @@ static int osc_extent_make_ready(const struct lu_env *env,
 	 * the size of file.
 	 */
 	if (!(last->oap_async_flags & ASYNC_COUNT_STABLE)) {
-		last->oap_count = osc_refresh_count(env, last, OBD_BRW_WRITE);
-		LASSERT(last->oap_count > 0);
-		LASSERT(last->oap_page_off + last->oap_count <= PAGE_SIZE);
+		int last_oap_count = osc_refresh_count(env, last, OBD_BRW_WRITE);
+
+		LASSERT(last_oap_count > 0);
+		LASSERT(last->oap_page_off + last_oap_count <= PAGE_SIZE);
+		last->oap_count = last_oap_count;
 		spin_lock(&last->oap_lock);
 		last->oap_async_flags |= ASYNC_COUNT_STABLE;
 		spin_unlock(&last->oap_lock);
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index d41680b..3068113 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -64,7 +64,7 @@ struct osc_io {
 	/** true if this io is lockless. */
 	unsigned int		oi_lockless;
 	/** how many LRU pages are reserved for this IO */
-	int oi_lru_reserved;
+	unsigned long		oi_lru_reserved;
 
 	/** active extents, we know how many bytes is going to be written,
 	 * so having an active extent will prevent it from being fragmented
-- 
1.7.1
