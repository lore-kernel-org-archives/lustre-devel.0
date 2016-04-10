From: James Simmons <jsimmons@infradead.org>
Date: Sun, 10 Apr 2016 09:13:24 -0400
Subject: [lustre-devel] [PATCH 01/17] staging: lustre: osc: fix race issues
	thanks to oap_lock
In-Reply-To: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
References: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1460294020-2111-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Sebastien Buisson <sbuisson@ddn.com>, James Simmons <jsimmons@infradead.org>

From: Sebastien Buisson <sbuisson@ddn.com>

Fix 'data race condition' defects found by Coverity version 6.5.0:

Data race condition (MISSING_LOCK)

Accessing variable without holding lock. Elsewhere,
this variable is accessed with lock held.

This patch is dedicated to code fragments involving oap_lock.

Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2744
Reviewed-on: http://review.whamcloud.com/6572
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |    8 ++++++++
 drivers/staging/lustre/lustre/osc/osc_io.c    |    2 ++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 956d57b..846be76 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1147,7 +1147,9 @@ static int osc_extent_make_ready(const struct lu_env *env,
 		last->oap_count = osc_refresh_count(env, last, OBD_BRW_WRITE);
 		LASSERT(last->oap_count > 0);
 		LASSERT(last->oap_page_off + last->oap_count <= PAGE_CACHE_SIZE);
+		spin_lock(&last->oap_lock);
 		last->oap_async_flags |= ASYNC_COUNT_STABLE;
+		spin_unlock(&last->oap_lock);
 	}
 
 	/* for the rest of pages, we don't need to call osf_refresh_count()
@@ -1156,7 +1158,9 @@ static int osc_extent_make_ready(const struct lu_env *env,
 	list_for_each_entry(oap, &ext->oe_pages, oap_pending_item) {
 		if (!(oap->oap_async_flags & ASYNC_COUNT_STABLE)) {
 			oap->oap_count = PAGE_CACHE_SIZE - oap->oap_page_off;
+			spin_lock(&last->oap_lock);
 			oap->oap_async_flags |= ASYNC_COUNT_STABLE;
+			spin_unlock(&last->oap_lock);
 		}
 	}
 
@@ -2350,6 +2354,10 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 	oap->oap_cmd = cmd;
 	oap->oap_page_off = ops->ops_from;
 	oap->oap_count = ops->ops_to - ops->ops_from;
+	/*
+	 * No need to hold a lock here,
+	 * since this page is not in any list yet.
+	 */
 	oap->oap_async_flags = 0;
 	oap->oap_brw_flags = brw_flags;
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index cf7743d..0f50465 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -168,8 +168,10 @@ static int osc_io_submit(const struct lu_env *env,
 		}
 
 		cl_page_list_move(qout, qin, page);
+		spin_lock(&oap->oap_lock);
 		oap->oap_async_flags = ASYNC_URGENT|ASYNC_READY;
 		oap->oap_async_flags |= ASYNC_COUNT_STABLE;
+		spin_unlock(&oap->oap_lock);
 
 		osc_page_submit(env, opg, crt, brw_flags);
 		list_add_tail(&oap->oap_pending_item, &list);
-- 
1.7.1
