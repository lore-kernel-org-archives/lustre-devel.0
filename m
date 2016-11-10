From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:57 -0500
Subject: [lustre-devel] [PATCH 27/35] staging: lustre: ptlrpc: reset
	imp_replay_cursor
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Hongchao Zhang <hongchao.zhang@intel.com>, James Simmons <jsimmons@infradead.org>

From: Hongchao Zhang <hongchao.zhang@intel.com>

At client side, the replay cursor using to speed up the lookup
of committed open requests in its obd_import should be resetted
for normal connection (not reconnection) during recovery.

Signed-off-by: Hongchao Zhang <hongchao.zhang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6802
Reviewed-on: http://review.whamcloud.com/17351
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/import.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 05fd92d..babb80d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -1130,6 +1130,7 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 		imp->imp_remote_handle =
 				*lustre_msg_get_handle(request->rq_repmsg);
 		imp->imp_last_replay_transno = 0;
+		imp->imp_replay_cursor = &imp->imp_committed_list;
 		IMPORT_SET_STATE(imp, LUSTRE_IMP_REPLAY);
 	} else {
 		DEBUG_REQ(D_HA, request, "%s: evicting (reconnect/recover flags not set: %x)",
-- 
1.7.1
