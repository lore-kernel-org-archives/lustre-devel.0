From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:17 -0400
Subject: [lustre-devel] [PATCH 38/42] lnet: deadlock on LNet shutdown
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-39-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Serguei Smirnov <ssmirnov@whamcloud.com>

Release ln_api_mutex during LNet shutdown while waiting
for zombie LNI to allow other threads to read the LNet
state updated by the shutdown and fall through, avoiding
the deadlock

WC-bug-id: https://jira.whamcloud.com/browse/LU-12233
Lustre-commit: e0c445648a38fb ("LU-12233 lnet: deadlock on LNet shutdown")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39933
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index f678ae2..03473bf 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -2036,13 +2036,21 @@ static void lnet_push_target_fini(void)
 		}
 
 		if (!list_empty(&ni->ni_netlist)) {
+			/* Unlock mutex while waiting to allow other
+			 * threads to read the LNet state and fall through
+			 * to avoid deadlock
+			 */
 			lnet_net_unlock(LNET_LOCK_EX);
+			mutex_unlock(&the_lnet.ln_api_mutex);
+
 			++i;
 			if ((i & (-i)) == i) {
 				CDEBUG(D_WARNING, "Waiting for zombie LNI %s\n",
 				       libcfs_nid2str(ni->ni_nid));
 			}
 			schedule_timeout_uninterruptible(HZ);
+
+			mutex_lock(&the_lnet.ln_api_mutex);
 			lnet_net_lock(LNET_LOCK_EX);
 			continue;
 		}
-- 
1.8.3.1
