From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:09 -0500
Subject: [lustre-devel] [PATCH 501/622] lnet: o2ib: Record rc in debug log
 on startup failure
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-502-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

Since kiblnd_startup() return -ENETDOWN on failure, let's record the
rc value for the failure case in the debug log.

Cray-bug-id: LUS-7935
WC-bug-id: https://jira.whamcloud.com/browse/LU-12824
Lustre-commit: 99f85541a685 ("LU-12824 o2ib: Record rc in debug log on startup failure")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/36325
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index d4d5d4f..d162b0a7 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2848,10 +2848,10 @@ static int kiblnd_dev_start_threads(struct kib_dev *dev, u32 *cpts, int ncpts)
 
 static int kiblnd_startup(struct lnet_ni *ni)
 {
-	char *ifname;
+	char *ifname = NULL;
 	struct lnet_inetdev *ifaces = NULL;
 	struct kib_dev *ibdev = NULL;
-	struct kib_net *net;
+	struct kib_net *net = NULL;
 	unsigned long flags;
 	int rc;
 	int i;
@@ -2866,8 +2866,10 @@ static int kiblnd_startup(struct lnet_ni *ni)
 
 	net = kzalloc(sizeof(*net), GFP_NOFS);
 	ni->ni_data = net;
-	if (!net)
+	if (!net) {
+		rc = -ENOMEM;
 		goto net_failed;
+	}
 
 	net->ibn_incarnation = ktime_get_real_ns() / NSEC_PER_USEC;
 
@@ -2884,6 +2886,7 @@ static int kiblnd_startup(struct lnet_ni *ni)
 
 		if (ni->ni_interfaces[1]) {
 			CERROR("ko2iblnd: Multiple interfaces not supported\n");
+			rc = -EINVAL;
 			goto failed;
 		}
 
@@ -2894,6 +2897,7 @@ static int kiblnd_startup(struct lnet_ni *ni)
 
 	if (strlen(ifname) >= sizeof(ibdev->ibd_ifname)) {
 		CERROR("IPoIB interface name too long: %s\n", ifname);
+		rc = -E2BIG;
 		goto failed;
 	}
 
@@ -2968,7 +2972,9 @@ static int kiblnd_startup(struct lnet_ni *ni)
 net_failed:
 	kiblnd_shutdown(ni);
 
-	CDEBUG(D_NET, "%s failed\n", __func__);
+	CDEBUG(D_NET, "Configuration of device %s failed: rc = %d\n",
+	       ifname ? ifname : "", rc);
+
 	return -ENETDOWN;
 }
 
-- 
1.8.3.1
