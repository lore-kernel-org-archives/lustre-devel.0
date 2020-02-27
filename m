From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:55 -0500
Subject: [lustre-devel] [PATCH 487/622] lustre: import: Fix missing
 spin_unlock()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-488-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

A recent patch moved the spin_unlock() down into
each branch of an 'if', but missed the final 'else'.
Add the spin_unlock in the else.

Fixes: 428ed8100580 ("lustre: import: fix race between imp_state & imp_invalid")
WC-bug-id: https://jira.whamcloud.com/browse/LU-11542
Lustre-commit: 3dbdd38a6adc ("LU-11542 import: Fix missing spin_unlock()")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35999
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/pinger.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/lustre/ptlrpc/pinger.c b/fs/lustre/ptlrpc/pinger.c
index a812942..f584fc6 100644
--- a/fs/lustre/ptlrpc/pinger.c
+++ b/fs/lustre/ptlrpc/pinger.c
@@ -242,6 +242,8 @@ static void ptlrpc_pinger_process_import(struct obd_import *imp,
 	} else if ((imp->imp_pingable && !suppress) || force_next || force) {
 		spin_unlock(&imp->imp_lock);
 		ptlrpc_ping(imp);
+	} else {
+		spin_unlock(&imp->imp_lock);
 	}
 }
 
-- 
1.8.3.1
