From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:08 -0500
Subject: [lustre-devel] [PATCH 40/60] staging: ptlrpc: leaked rs on
	difficult reply
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-41-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Niu Yawei <yawei.niu@intel.com>

reply_out_callback() should call ptlrpc_schedule_difficult_reply()
to finalize the rs if it's already not on uncommitted list, otherwise,
the rs and the export held by rs could be leaked:

- target_send_reply() sends a difficult reply before the transaction
  committed, the reply is linked to scp_rep_active;

- export gets disconnected by umount or whatever reason,
  server_disconnect_export() is called to complete all outstanding
  replies, which will calls into ptlrpc_handle_rs() to dispose of
  the rs, so the rs is removed from the uncommitted list and
  LNetMDUnlink() is called to unlink the reply buffer and generate
  an unlink event;

- reply_out_callback() is called to process above unlink event,
  ptlrpc_schedule_difficult_reply() is supposed to be called to
  dispose of the rs finally. However, it could be skipped because of
  following flawed code snippet:

  if (!rs->rs_no_ack ||
      rs->rs_transno <= rs->rs_export->exp_obd->obd_last_committed)
        ptlrpc_schedule_difficult_reply(rs);

The intention of above code is: if rs_no_ack is true (COS enabled),
and transaction is not committed, we should rely on commit callback
to release the rs. However, it overlooked the situation that rs
could have been removed from the uncommitted list by disconnecting
export.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7903
Reviewed-on: http://review.whamcloud.com/22696
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/events.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index ae1650d..dc0fe9d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -420,7 +420,8 @@ void reply_out_callback(lnet_event_t *ev)
 		rs->rs_on_net = 0;
 		if (!rs->rs_no_ack ||
 		    rs->rs_transno <=
-		    rs->rs_export->exp_obd->obd_last_committed)
+		    rs->rs_export->exp_obd->obd_last_committed ||
+		    list_empty(&rs->rs_obd_list))
 			ptlrpc_schedule_difficult_reply(rs);
 
 		spin_unlock(&rs->rs_lock);
-- 
1.8.3.1
