From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:54 -0400
Subject: [lustre-devel] [PATCH 20/29] staging: lustre: recovery: don't skip
	open replay on reconnect
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Niu Yawei <yawei.niu@intel.com>

Once reconnect happened during replay, we'd continue the open
replay with the last failed replay, but not the next.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6802
Reviewed-on: http://review.whamcloud.com/15871
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Hongchao Zhang <hongchao.zhang@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/recover.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index aa96534..9144cd8 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -111,7 +111,9 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 			 * all of it's requests being replayed, it's safe to
 			 * use a cursor to accelerate the search
 			 */
-			imp->imp_replay_cursor = imp->imp_replay_cursor->next;
+			if (!imp->imp_resend_replay ||
+			    imp->imp_replay_cursor == &imp->imp_committed_list)
+				imp->imp_replay_cursor = imp->imp_replay_cursor->next;
 
 			while (imp->imp_replay_cursor !=
 			       &imp->imp_committed_list) {
-- 
1.7.1
