From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:49 -0500
Subject: [lustre-devel] [PATCH 301/622] lnet: Fix NI status in debugfs for
 loopback ni
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-302-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

The loopback NI is never really "down", but since its associated
ns_status is used for other purposes that's how it is reported in
proc_lnet_nis(). There's an existing check for lolnd so just hardcode
the status as "up" there.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12302
Lustre-commit: 0c27e760c357 ("LU-12302 lnet: Fix NI status in proc for loopback ni")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/34871
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/router_proc.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index 8517411..5341599 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -723,16 +723,18 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 			if (the_lnet.ln_routing)
 				last_alive = now - ni->ni_last_alive;
 
-			/* @lo forever alive */
-			if (ni->ni_net->net_lnd->lnd_type == LOLND)
-				last_alive = 0;
-
 			lnet_ni_lock(ni);
 			LASSERT(ni->ni_status);
 			stat = (ni->ni_status->ns_status ==
 				LNET_NI_STATUS_UP) ? "up" : "down";
 			lnet_ni_unlock(ni);
 
+			/* @lo forever alive */
+			if (ni->ni_net->net_lnd->lnd_type == LOLND) {
+				last_alive = 0;
+				stat = "up";
+			}
+
 			/*
 			 * we actually output credits information for
 			 * TX queue of each partition
-- 
1.8.3.1
