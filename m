From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:01 -0500
Subject: [lustre-devel] [PATCH 133/622] lustre: obdclass: make mod rpc slot
 wait queue FIFO
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-134-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vladimir Saveliev <c17830@cray.com>

Relatively big load may cause a process to spin for a long time
without successful grabbing a free mod rpc slot. It has been observed
a process spinning more than 100 seconds when there were 72 mdtest-s
and 8 IOR-s.

Make mod rpc slot wait queue to run FIFO so that waiting thread got
free mod rpc slot in order they entered the queue.

Cray-bug-id: LUS-6380
WC-bug-id: https://jira.whamcloud.com/browse/LU-11441
Lustre-commit: 7fa0fd415770 ("LU-11441 obdclass: make mod rpc slot wait queue FIFO")
Signed-off-by: Alexander Zarochentsev <c17826@cray.com>
Signed-off-by: Vladimir Saveliev <c17830@cray.com>
Reviewed-on: https://review.whamcloud.com/33282
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/genops.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index e5e2f73..da53572 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -1574,8 +1574,9 @@ u16 obd_get_mod_rpc_slot(struct client_obd *cli, u32 opc,
 		CDEBUG(D_RPCTRACE, "%s: sleeping for a modify RPC slot opc %u, max %hu\n",
 		       cli->cl_import->imp_obd->obd_name, opc, max);
 
-		wait_event_idle(cli->cl_mod_rpcs_waitq,
-				obd_mod_rpc_slot_avail(cli, close_req));
+		wait_event_idle_exclusive(cli->cl_mod_rpcs_waitq,
+					  obd_mod_rpc_slot_avail(cli,
+								 close_req));
 	} while (true);
 }
 EXPORT_SYMBOL(obd_get_mod_rpc_slot);
-- 
1.8.3.1
