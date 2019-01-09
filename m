From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:01 +1100
Subject: [lustre-devel] [PATCH 11/29] lustre: osc_cache: simplify
 osc_wake_cache_waiters()
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504164.26726.1429367185304894591.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

osc_wake_cache_waiters() performs a test, then possibly
calls osc_enter_cache_try() which performs the same test.
We don't benefit from this duplication except that it allows
an extra debug message.  I'm not certain that message
is worth the complexity.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |   15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 5cd3732101e7..0c78b95e45a3 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1694,20 +1694,11 @@ void osc_wake_cache_waiters(struct client_obd *cli)
 					       ocw_entry))) {
 		list_del_init(&ocw->ocw_entry);
 
-		ocw->ocw_rc = -EDQUOT;
-		/* we can't dirty more */
-		if ((cli->cl_dirty_pages > cli->cl_dirty_max_pages) ||
-		    (atomic_long_read(&obd_dirty_pages) + 1 >
-		     obd_max_dirty_pages)) {
-			CDEBUG(D_CACHE, "no dirty room: dirty: %ld osc max %ld, sys max %ld\n",
-			       cli->cl_dirty_pages, cli->cl_dirty_max_pages,
-			       obd_max_dirty_pages);
-			goto wakeup;
-		}
-
 		if (osc_enter_cache_try(cli, ocw->ocw_oap, ocw->ocw_grant, 0))
 			ocw->ocw_rc = 0;
-wakeup:
+		else
+			ocw->ocw_rc = -EDQUOT;
+
 		CDEBUG(D_CACHE, "wake up %p for oap %p, avail grant %ld, %d\n",
 		       ocw, ocw->ocw_oap, cli->cl_avail_grant, ocw->ocw_rc);
 
