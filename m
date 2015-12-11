From: Jandy Gou <qingsong.gou@ck-telecom.com>
Date: Fri, 11 Dec 2015 16:08:53 +0800
Subject: [lustre-devel] [PATCH] staging: lustre: This patch fixes the
	following sparse warning:
Message-ID: <1449821333-18036-1-git-send-email-qingsong.gou@ck-telecom.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

drivers/staging/lustre/lustre/osc/osc_cache.c:622:19: warning: symbol
'osc_extent_find' was not declared. Should it be static?
drivers/staging/lustre/lustre/osc/osc_cache.c:1423:6: warning: symbol
'osc_unreserve_grant' was not declared. Should it be static?

Signed-off-by: Jandy Gou <qingsong.gou@ck-telecom.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index b1d1a87f..62cfca6 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -619,7 +619,7 @@ static inline int overlapped(struct osc_extent *ex1, struct osc_extent *ex2)
  * Find or create an extent which includes @index, core function to manage
  * extent tree.
  */
-struct osc_extent *osc_extent_find(const struct lu_env *env,
+static struct osc_extent *osc_extent_find(const struct lu_env *env,
 				   struct osc_object *obj, pgoff_t index,
 				   int *grants)
 
@@ -1420,7 +1420,7 @@ static void __osc_unreserve_grant(struct client_obd *cli,
 	}
 }
 
-void osc_unreserve_grant(struct client_obd *cli,
+static void osc_unreserve_grant(struct client_obd *cli,
 			 unsigned int reserved, unsigned int unused)
 {
 	client_obd_list_lock(&cli->cl_loi_list_lock);
-- 
1.9.1
