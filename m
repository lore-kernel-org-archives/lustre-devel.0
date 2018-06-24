From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:53:47 -0400
Subject: [lustre-devel] [PATCH 3/8] staging: lustre: ksocklnd: use
 ktime_get_real_ns for ksnn_incarnation
In-Reply-To: <1529877232-15582-1-git-send-email-jsimmons@infradead.org>
References: <1529877232-15582-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529877232-15582-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The value generated for ksnn_incarnation is used as a unique identifier.
Their exist a small chance that two nodes could end up with the same
value but if we use ktime_get_real_ns() instead the change is even less
so.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9019
Reviewed-on: https://review.whamcloud.com/25690
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index f01b34a..694f1d0 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -2369,15 +2369,6 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	module_put(THIS_MODULE);
 }
 
-static __u64
-ksocknal_new_incarnation(void)
-{
-	/* The incarnation number is the time this module loaded and it
-	 * identifies this particular instance of the socknal.
-	 */
-	return ktime_get_ns();
-}
-
 static int
 ksocknal_base_startup(void)
 {
@@ -2810,7 +2801,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		goto fail_0;
 
 	spin_lock_init(&net->ksnn_lock);
-	net->ksnn_incarnation = ksocknal_new_incarnation();
+	net->ksnn_incarnation = ktime_get_real_ns();
 	ni->ni_data = net;
 	ni->ni_peertimeout    = *ksocknal_tunables.ksnd_peertimeout;
 	ni->ni_maxtxcredits   = *ksocknal_tunables.ksnd_credits;
-- 
1.8.3.1
