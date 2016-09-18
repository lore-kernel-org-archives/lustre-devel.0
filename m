From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:08 -0400
Subject: [lustre-devel] [PATCH 069/124] staging: lustre: fix messages with
	missing newlines
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-70-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Restore the trailing newline in the definition of OSC_DUMP_GRANT().
Remove an unnecessary CDEBUG() from ldlm_pool_recalc().

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5551
Reviewed-on: http://review.whamcloud.com/11996
Reviewed-by: James Nunez <james.a.nunez@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c |    4 ----
 drivers/staging/lustre/lustre/osc/osc_cache.c  |    2 +-
 2 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 1147b30..44c3abf 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -385,10 +385,6 @@ static int ldlm_pool_recalc(struct ldlm_pool *pl)
 			      pl->pl_recalc_period;
 	if (recalc_interval_sec <= 0) {
 		/* Prevent too frequent recalculation. */
-		CDEBUG(D_DLMTRACE,
-		       "Negative interval(%d), too short period(%lld)",
-		       recalc_interval_sec,
-		       (s64)pl->pl_recalc_period);
 		recalc_interval_sec = 1;
 	}
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 26ad360..fb18dd1 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1385,7 +1385,7 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 	struct client_obd *__tmp = (cli);				      \
 	CDEBUG(lvl, "%s: grant { dirty: %ld/%ld dirty_pages: %ld/%lu "	      \
 	       "dropped: %ld avail: %ld, reserved: %ld, flight: %d }"	      \
-	       "lru {in list: %ld, left: %ld, waiters: %d }" fmt,	      \
+	       "lru {in list: %ld, left: %ld, waiters: %d }" fmt "\n",	      \
 	       __tmp->cl_import->imp_obd->obd_name,			      \
 	       __tmp->cl_dirty_pages, __tmp->cl_dirty_max_pages,	      \
 	       atomic_long_read(&obd_dirty_pages), obd_max_dirty_pages,	      \
-- 
1.7.1
