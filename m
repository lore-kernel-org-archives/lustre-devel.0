From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:56 -0500
Subject: [lustre-devel] [PATCH 488/622] lnet: o2iblnd: Make credits hiw
 connection aware
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-489-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

The IBLND_CREDITS_HIGHWATER mark check currently looks only
at the global peer credits tunable, ignoring the connection
specific queue depth when determining the threshold at
which to send a NOOP message to return credits.

This is incorrect because while connection queue depth
defaults to the same as peer credits, it can be less than
that global value for specific connections.

So we must check for this case when setting the threshold.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12569
Lustre-commit: 1b87e8f61781 ("LU-12569 o2iblnd: Make credits hiw connection aware")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35578
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.h | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 2f2337a..bc79874 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -102,9 +102,11 @@ struct kib_tunables {
 #define IBLND_CREDITS_MAX	  ((typeof(((struct kib_msg *)0)->ibm_credits)) - 1)
 
 /* when eagerly to return credits */
-#define IBLND_CREDITS_HIGHWATER(t, v)	((v) == IBLND_MSG_VERSION_1 ? \
-					IBLND_CREDIT_HIGHWATER_V1 : \
-					t->lnd_peercredits_hiw)
+#define IBLND_CREDITS_HIGHWATER(t, conn)			\
+	(((conn)->ibc_version) == IBLND_MSG_VERSION_1 ?		\
+	 IBLND_CREDIT_HIGHWATER_V1 :				\
+	 min((t)->lnd_peercredits_hiw,				\
+	     (u32)(conn)->ibc_queue_depth - 1))
 
 # define kiblnd_rdma_create_id(ns, cb, dev, ps, qpt) rdma_create_id(ns, cb, \
 								    dev, ps, \
@@ -791,7 +793,7 @@ struct kib_peer_ni {
 	tunables = &ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib;
 
 	if (conn->ibc_outstanding_credits <
-	    IBLND_CREDITS_HIGHWATER(tunables, conn->ibc_version) &&
+	    IBLND_CREDITS_HIGHWATER(tunables, conn) &&
 	    !kiblnd_send_keepalive(conn))
 		return 0; /* No need to send NOOP */
 
-- 
1.8.3.1
