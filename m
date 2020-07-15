From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:45:15 -0400
Subject: [lustre-devel] [PATCH 34/37] lustre: ptlrpc: fix endless loop issue
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-35-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Hongchao Zhang <hongchao@whamcloud.com>

In ptlrpc_pinger_main, if the process to ping the recoverable
clients takes too long time, it could be stuck in endless loop
because of the negative value returned by pinger_check_timeout.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13667
Lustre-commit: 6be2dbb259512 ("LU-13667 ptlrpc: fix endless loop issue")
Signed-off-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38915
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Olaf Faaland-LLNL <faaland1@llnl.gov>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/pinger.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/ptlrpc/pinger.c b/fs/lustre/ptlrpc/pinger.c
index ec4c51a..9f57c61 100644
--- a/fs/lustre/ptlrpc/pinger.c
+++ b/fs/lustre/ptlrpc/pinger.c
@@ -258,12 +258,13 @@ static void ptlrpc_pinger_process_import(struct obd_import *imp,
 
 static void ptlrpc_pinger_main(struct work_struct *ws)
 {
-	time64_t this_ping = ktime_get_seconds();
-	time64_t time_to_next_wake;
+	time64_t this_ping, time_after_ping, time_to_next_wake;
 	struct timeout_item *item;
 	struct obd_import *imp;
 
 	do {
+		this_ping = ktime_get_seconds();
+
 		mutex_lock(&pinger_mutex);
 		list_for_each_entry(item, &timeout_list, ti_chain) {
 			item->ti_cb(item, item->ti_cb_data);
@@ -277,6 +278,12 @@ static void ptlrpc_pinger_main(struct work_struct *ws)
 		}
 		mutex_unlock(&pinger_mutex);
 
+		time_after_ping = ktime_get_seconds();
+
+		if ((ktime_get_seconds() - this_ping - 3) > PING_INTERVAL)
+			CDEBUG(D_HA, "long time to ping: %lld, %lld, %lld\n",
+			       this_ping, time_after_ping, ktime_get_seconds());
+
 		/* Wait until the next ping time, or until we're stopped. */
 		time_to_next_wake = pinger_check_timeout(this_ping);
 		/* The ping sent by ptlrpc_send_rpc may get sent out
-- 
1.8.3.1
