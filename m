From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:55 -0500
Subject: [lustre-devel] [PATCH 067/622] lustre: obd: keep dirty_max_pages a
 round number of MB
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-68-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

In client_adjust_max_dirty() ensure that the dirty pages limit is
always divisible by 256 so that it may faithfully be represented in MB
as is the case when the max_dirty_mb parameters are used.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11157
Lustre-commit: d3f88d376c49 ("LU-11157 obd: keep dirty_max_pages a round number of MB")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32831
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index d2bd234..5656eb0 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -1106,7 +1106,7 @@ static inline int cli_brw_size(struct obd_device *obd)
 }
 
 /*
- * when RPC size or the max RPCs in flight is increased, the max dirty pages
+ * When RPC size or the max RPCs in flight is increased, the max dirty pages
  * of the client should be increased accordingly to avoid sending fragmented
  * RPCs over the network when the client runs out of the maximum dirty space
  * when so many RPCs are being generated.
@@ -1114,10 +1114,10 @@ static inline int cli_brw_size(struct obd_device *obd)
 static inline void client_adjust_max_dirty(struct client_obd *cli)
 {
 	/* initializing */
-	if (cli->cl_dirty_max_pages <= 0)
+	if (cli->cl_dirty_max_pages <= 0) {
 		cli->cl_dirty_max_pages =
 			(OSC_MAX_DIRTY_DEFAULT * 1024 * 1024) >> PAGE_SHIFT;
-	else {
+	} else {
 		unsigned long dirty_max = cli->cl_max_rpcs_in_flight *
 					  cli->cl_max_pages_per_rpc;
 
@@ -1127,6 +1127,13 @@ static inline void client_adjust_max_dirty(struct client_obd *cli)
 
 	if (cli->cl_dirty_max_pages > totalram_pages() / 8)
 		cli->cl_dirty_max_pages = totalram_pages() / 8;
+
+	/* This value is exported to userspace through the max_dirty_mb
+	 * parameter.  So we round up the number of pages to make it a round
+	 * number of MBs.
+	 */
+	cli->cl_dirty_max_pages = round_up(cli->cl_dirty_max_pages,
+					   1 << (20 - PAGE_SHIFT));
 }
 
 #endif /* __OBD_H */
-- 
1.8.3.1
