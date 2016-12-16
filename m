From: Tabrez khan <khan.tabrez21@gmail.com>
Date: Fri, 16 Dec 2016 23:29:35 +0530
Subject: [lustre-devel] [PATCH] staging : lustre : Remove braces from
	single-line body.
Message-ID: <1481911175-19592-1-git-send-email-khan.tabrez21@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, jsimmons@infradead.org, andreas.dilger@intel.com
Cc: gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Remove unnecessary braces {} from single line if statement.
This warning is found using checkpatch.pl.

Signed-off-by: Tabrez khan <khan.tabrez21@gmail.com>
---
 drivers/staging/lustre/lustre/ptlrpc/import.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index a23d0a0..477d832 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -1134,9 +1134,9 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 	}
 
 	/* Sanity checks for a reconnected import. */
-	if (!(imp->imp_replayable) != !(msg_flags & MSG_CONNECT_REPLAYABLE)) {
+	if (!(imp->imp_replayable) != !(msg_flags & MSG_CONNECT_REPLAYABLE))
 		CERROR("imp_replayable flag does not match server after reconnect. We should LBUG right here.\n");
-	}
+
 
 	if (lustre_msg_get_last_committed(request->rq_repmsg) > 0 &&
 	    lustre_msg_get_last_committed(request->rq_repmsg) <
-- 
2.7.4
