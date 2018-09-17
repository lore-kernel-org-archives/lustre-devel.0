From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:30 -0400
Subject: [lustre-devel] [PATCH 20/30] lustre: osc: osc page lru list race
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

In osc_lru_use() the osc page's ops_lru access is not protected, which
could race with osc_lru_del() and ensuing that
client_obd::cl_lru_in_list counter decreased twice for a single page.

Signed-off-by: Bobi Jam <bobijam@hotmail.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9229
Reviewed-on: https://review.whamcloud.com/26086
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_page.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 20c553e..189e3e78 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -478,18 +478,20 @@ static void osc_lru_del(struct client_obd *cli, struct osc_page *opg)
 }
 
 /**
- * Delete page from LRUlist for redirty.
+ * Delete page from LRU list for redirty.
  */
 static void osc_lru_use(struct client_obd *cli, struct osc_page *opg)
 {
 	/* If page is being transferred for the first time,
 	 * ops_lru should be empty
 	 */
-	if (opg->ops_in_lru && !list_empty(&opg->ops_lru)) {
+	if (opg->ops_in_lru) {
 		spin_lock(&cli->cl_lru_list_lock);
-		__osc_lru_del(cli, opg);
+		if (!list_empty(&opg->ops_lru)) {
+			__osc_lru_del(cli, opg);
+			atomic_long_inc(&cli->cl_lru_busy);
+		}
 		spin_unlock(&cli->cl_lru_list_lock);
-		atomic_long_inc(&cli->cl_lru_busy);
 	}
 }
 
-- 
1.8.3.1
