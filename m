From: Tabrez khan <khan.tabrez21@gmail.com>
Date: Thu, 15 Dec 2016 02:41:24 +0530
Subject: [lustre-devel] [PATCH] staging : osc : coding style fix
Message-ID: <1481749884-25674-1-git-send-email-khan.tabrez21@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: andreas.dilger@intel.com, jsimmons@infradead.org
Cc: gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Remove unnecessary braces {} for single if statement block.
This warning is found using checkpatch.pl.

Signed-off-by: Tabrez khan <khan.tabrez21@gmail.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 4bbe219..5ded31a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1420,10 +1420,8 @@ static void osc_release_write_grant(struct client_obd *cli,
 				    struct brw_page *pga)
 {
 	assert_spin_locked(&cli->cl_loi_list_lock);
-	if (!(pga->flag & OBD_BRW_FROM_GRANT)) {
+	if (!(pga->flag & OBD_BRW_FROM_GRANT))
 		return;
-	}
-
 	pga->flag &= ~OBD_BRW_FROM_GRANT;
 	atomic_long_dec(&obd_dirty_pages);
 	cli->cl_dirty_pages--;
-- 
2.7.4
