From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:14 -0400
Subject: [lustre-devel] [PATCH 075/124] staging: lustre: recovery: don't
	replay closed open
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-76-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Niu Yawei <yawei.niu@intel.com>

To avoid scanning the replay open list every time in the
ptlrpc_free_committed(), the fix of LU-2613 (4322e0f9) changed
the ptlrpc_free_committed() to skip the open list unless the
import generation is changed. That introduced a race which could
make a closed open being replayed:

1. Application calls ll_close_inode_openhandle()-> mdc_close(),
   to close file, rq_replay is cleared, but the open request is
   still on the imp_committed_list;

2. Before the md_clear_open_replay_data() is called for close,
   client start replay, and that closed open will be replayed
   mistakenly;

3. Open replay interpret callback (mdc_replay_open) could race
   with the mdc_clear_open_replay_data() at the end;

This patch fix the ptlrpc_free_committed() to make sure the
open list is scanned on recovery to prevent the closed open request
from being replayed.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5507
Reviewed-on: http://review.whamcloud.com/12667
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 27fe00d..a29ccaa 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -2455,7 +2455,8 @@ void ptlrpc_free_committed(struct obd_import *imp)
 	       imp->imp_obd->obd_name, imp->imp_peer_committed_transno,
 	       imp->imp_generation);
 
-	if (imp->imp_generation != imp->imp_last_generation_checked)
+	if (imp->imp_generation != imp->imp_last_generation_checked ||
+	    !imp->imp_last_transno_checked)
 		skip_committed_list = false;
 
 	imp->imp_last_transno_checked = imp->imp_peer_committed_transno;
@@ -2503,6 +2504,9 @@ free_req:
 		if (req->rq_import_generation < imp->imp_generation) {
 			DEBUG_REQ(D_RPCTRACE, req, "free stale open request");
 			ptlrpc_free_request(req);
+		} else if (!req->rq_replay) {
+			DEBUG_REQ(D_RPCTRACE, req, "free closed open request");
+			ptlrpc_free_request(req);
 		}
 	}
 }
-- 
1.7.1
