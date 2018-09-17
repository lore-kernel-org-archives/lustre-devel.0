From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:32 -0400
Subject: [lustre-devel] [PATCH 22/30] lustre: osc: update timestamps on
 write only
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Niu Yawei <yawei.niu@intel.com>

In osc_io_submit(), we should only update timestamps on write.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9470
Reviewed-on: https://review.whamcloud.com/27348
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_io.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 628743b..e7151ed 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -212,7 +212,7 @@ static int osc_io_submit(const struct lu_env *env,
 		result = osc_queue_sync_pages(env, osc, &list, cmd, brw_flags);
 
 	/* Update c/mtime for sync write. LU-7310 */
-	if (qout->pl_nr > 0 && !result) {
+	if (crt == CRT_WRITE && qout->pl_nr > 0 && !result) {
 		struct cl_attr *attr = &osc_env_info(env)->oti_attr;
 		struct cl_object *obj = ios->cis_obj;
 
-- 
1.8.3.1
