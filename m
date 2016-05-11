From: Muhammad Falak R Wani <falakreyaz@gmail.com>
Date: Wed, 11 May 2016 20:53:31 +0530
Subject: [lustre-devel] [PATCH] staging: lustre: use setup_timer().
Message-ID: <1462980251-6608-1-git-send-email-falakreyaz@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Use setup_timer() for initializing the timer, instead of structure
assignments.
This is the preferred/standard way.

Signed-off-by: Muhammad Falak R Wani <falakreyaz@gmail.com>
---
 drivers/staging/lustre/lnet/lnet/net_fault.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
index 7d76f28..e4aceb7 100644
--- a/drivers/staging/lustre/lnet/lnet/net_fault.c
+++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
@@ -760,9 +760,7 @@ lnet_delay_rule_add(struct lnet_fault_attr *attr)
 		wait_event(delay_dd.dd_ctl_waitq, delay_dd.dd_running);
 	}
 
-	init_timer(&rule->dl_timer);
-	rule->dl_timer.function = delay_timer_cb;
-	rule->dl_timer.data = (unsigned long)rule;
+	setup_timer(&rule->dl_timer, delay_timer_cb, (unsigned long)rule);
 
 	spin_lock_init(&rule->dl_lock);
 	INIT_LIST_HEAD(&rule->dl_msg_list);
-- 
1.9.1
