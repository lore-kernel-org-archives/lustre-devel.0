From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:53:49 -0400
Subject: [lustre-devel] [PATCH 5/8] staging: lustre: lnet: use
 ktime_get_real_ns for cookie creation
In-Reply-To: <1529877232-15582-1-git-send-email-jsimmons@infradead.org>
References: <1529877232-15582-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529877232-15582-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The ln_interface_cookie is used to ensure that a node can tell whether
the following sequence of events has happened:

node sends GET or PUT to peer
node is rebooted
peer sends REPLY or ACK to node

The ln_interface_cookie is set once, when LNet starts, and remains
unchanged afterwards. To avoid accidentally obtaining the same cookie
after a reboot, the code generated ths cookie using ktime_get_ns().
Once generated, the value of the cookie is not interpreted, only
compared for equality. Olaf Weber reported that due to the use of
ktime_get_ns() a small chance exist of generating a cookie of identical
value across reboots. Using ktime_get_real_ns() removes any chance of
this from happening.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-4423
Reviewed-on: https://review.whamcloud.com/24682
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 878c92c..20dce34 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -554,7 +554,7 @@ struct lnet_libhandle *
 	 * NB the interface cookie in wire handles guards against delayed
 	 * replies and ACKs appearing valid after reboot.
 	 */
-	the_lnet.ln_interface_cookie = ktime_get_ns();
+	the_lnet.ln_interface_cookie = ktime_get_real_ns();
 
 	the_lnet.ln_counters = cfs_percpt_alloc(lnet_cpt_table(),
 						sizeof(struct lnet_counters));
-- 
1.8.3.1
