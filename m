From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:23 -0500
Subject: [lustre-devel] [PATCH 215/622] lustre: osc: reduce atomic ops in
 osc_enter_cache_try
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-216-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Li Dongyang <dongyangli@ddn.com>

We can reduce the number of atomic ops performed on
obd_dirty_pages for the common case.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11775
Lustre-commit: 8b364fbd6bd9 ("LU-11775 osc: reduce atomic ops in osc_enter_cache_try")
Signed-off-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/33859
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_cache.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index a18e791..bdaf65f 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -1423,7 +1423,6 @@ static void osc_consume_write_grant(struct client_obd *cli,
 {
 	assert_spin_locked(&cli->cl_loi_list_lock);
 	LASSERT(!(pga->flag & OBD_BRW_FROM_GRANT));
-	atomic_long_inc(&obd_dirty_pages);
 	cli->cl_dirty_pages++;
 	pga->flag |= OBD_BRW_FROM_GRANT;
 	CDEBUG(D_CACHE, "using %lu grant credits for brw %p page %p\n",
@@ -1560,13 +1559,18 @@ static bool osc_enter_cache_try(struct client_obd *cli,
 	if (osc_reserve_grant(cli, bytes) < 0)
 		return rc;
 
-	if (cli->cl_dirty_pages < cli->cl_dirty_max_pages &&
-	    atomic_long_read(&obd_dirty_pages) + 1 <= obd_max_dirty_pages) {
-		osc_consume_write_grant(cli, &oap->oap_brw_page);
-		rc = true;
-	} else {
-		__osc_unreserve_grant(cli, bytes, bytes);
+	if (cli->cl_dirty_pages < cli->cl_dirty_max_pages) {
+		if (atomic_long_add_return(1, &obd_dirty_pages) <=
+		    obd_max_dirty_pages) {
+			osc_consume_write_grant(cli, &oap->oap_brw_page);
+			rc = true;
+			goto out;
+		} else
+			atomic_long_dec(&obd_dirty_pages);
 	}
+	__osc_unreserve_grant(cli, bytes, bytes);
+
+out:
 	return rc;
 }
 
-- 
1.8.3.1
