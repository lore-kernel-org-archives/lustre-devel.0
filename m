From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:53:46 -0400
Subject: [lustre-devel] [PATCH 2/8] staging: lustre: o2iblnd: use
 ktime_get_real_ns for ibn_incarnation
In-Reply-To: <1529877232-15582-1-git-send-email-jsimmons@infradead.org>
References: <1529877232-15582-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529877232-15582-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Instead of getting the real time using ktime_get_real_ts64() and
turning it into usecs we can simplify the code and call
ktime_get_real_ns() instead.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9019
Reviewed-on: https://review.whamcloud.com/23267
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index f0b4eb42..5761e3d 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2822,7 +2822,6 @@ static int kiblnd_startup(struct lnet_ni *ni)
 	char *ifname;
 	struct kib_dev *ibdev = NULL;
 	struct kib_net *net;
-	struct timespec64 tv;
 	unsigned long flags;
 	int rc;
 	int newdev;
@@ -2840,9 +2839,7 @@ static int kiblnd_startup(struct lnet_ni *ni)
 	if (!net)
 		goto net_failed;
 
-	ktime_get_real_ts64(&tv);
-	net->ibn_incarnation = tv.tv_sec * USEC_PER_SEC +
-			       tv.tv_nsec / NSEC_PER_USEC;
+	net->ibn_incarnation = ktime_get_real_ns() / NSEC_PER_USEC;
 
 	rc = kiblnd_tunables_setup(ni);
 	if (rc)
-- 
1.8.3.1
