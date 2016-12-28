From: Tabrez khan <khan.tabrez21@gmail.com>
Date: Wed, 28 Dec 2016 19:40:09 +0530
Subject: [lustre-devel] [PATCH] staging : lustre : Remove braces from
	single-line body.
Message-ID: <1482934209-10857-1-git-send-email-khan.tabrez21@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org
Cc: gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Remove unnecessary braces from single-line if statement.
This warning is found using checkpatch.pl.

Signed-off-by: Tabrez khan <khan.tabrez21@gmail.com>
---
 drivers/staging/lustre/lustre/ptlrpc/import.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 477d832..b55680b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -1392,9 +1392,9 @@ int ptlrpc_import_recovery_state_machine(struct obd_import *imp)
 	}
 
 	if (imp->imp_state == LUSTRE_IMP_REPLAY_WAIT) {
-		if (atomic_read(&imp->imp_replay_inflight) == 0) {
+		if (atomic_read(&imp->imp_replay_inflight) == 0)
 			IMPORT_SET_STATE(imp, LUSTRE_IMP_RECOVER);
-		}
+
 	}
 
 	if (imp->imp_state == LUSTRE_IMP_RECOVER) {
-- 
2.7.4
