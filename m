From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:36 -0500
Subject: [lustre-devel] [PATCH 11/34] staging: lustre: lnet: change
	lnet_test_peer_t to proper structure
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_test_peer_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lib-types.h |  4 ++--
 drivers/staging/lustre/lnet/lnet/lib-move.c           | 12 ++++++------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 6dd7edd..59d7143 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -164,12 +164,12 @@ struct lnet_libmd {
 #define LNET_MD_FLAG_AUTO_UNLINK	(1 << 1)
 #define LNET_MD_FLAG_ABORTED		(1 << 2)
 
-typedef struct {
+struct lnet_test_peer {
 	/* info about peers we are trying to fail */
 	struct list_head	tp_list;	/* ln_test_peers */
 	lnet_nid_t		tp_nid;		/* matching nid */
 	unsigned int		tp_threshold;	/* # failures to simulate */
-} lnet_test_peer_t;
+};
 
 #define LNET_COOKIE_TYPE_MD	1
 #define LNET_COOKIE_TYPE_ME	2
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index a55b58e..f919732 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -47,8 +47,8 @@
 int
 lnet_fail_nid(lnet_nid_t nid, unsigned int threshold)
 {
-	lnet_test_peer_t *tp;
-	lnet_test_peer_t *temp;
+	struct lnet_test_peer *tp;
+	struct lnet_test_peer *temp;
 	struct list_head *el;
 	struct list_head *next;
 	struct list_head cull;
@@ -75,7 +75,7 @@
 	lnet_net_lock(0);
 
 	list_for_each_safe(el, next, &the_lnet.ln_test_peers) {
-		tp = list_entry(el, lnet_test_peer_t, tp_list);
+		tp = list_entry(el, struct lnet_test_peer, tp_list);
 
 		if (!tp->tp_threshold ||    /* needs culling anyway */
 		    nid == LNET_NID_ANY ||       /* removing all entries */
@@ -97,8 +97,8 @@
 static int
 fail_peer(lnet_nid_t nid, int outgoing)
 {
-	lnet_test_peer_t *tp;
-	lnet_test_peer_t *temp;
+	struct lnet_test_peer *tp;
+	struct lnet_test_peer *temp;
 	struct list_head *el;
 	struct list_head *next;
 	struct list_head cull;
@@ -110,7 +110,7 @@
 	lnet_net_lock(0);
 
 	list_for_each_safe(el, next, &the_lnet.ln_test_peers) {
-		tp = list_entry(el, lnet_test_peer_t, tp_list);
+		tp = list_entry(el, struct lnet_test_peer, tp_list);
 
 		if (!tp->tp_threshold) {
 			/* zombie entry */
-- 
1.8.3.1
