From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:04 -0500
Subject: [lustre-devel] [PATCH 076/622] lnet: add health value per ni
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-77-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Add a health value per local network interface. The health value
reflects the health of the NI. It is initialized to 1000. 1000 is
chosen to be able to granularly decrement the health value on error.

If the NI is absolutely not healthy that will be indicated by an
LND event, which will flag that the NI is down and should never
be used.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: d54afb86116c ("LU-9120 lnet: add health value per ni")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32761
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h | 15 +++++++++++++++
 net/lnet/lnet/api-ni.c         |  1 +
 net/lnet/lnet/lib-move.c       | 17 +++++++++++------
 3 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index e9560a9..0ed325a 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -52,6 +52,12 @@
 
 #define LNET_MAX_IOV		(LNET_MAX_PAYLOAD >> PAGE_SHIFT)
 
+/*
+ * This is the maximum health value.
+ * All local and peer NIs created have their health default to this value.
+ */
+#define LNET_MAX_HEALTH_VALUE 1000
+
 /* forward refs */
 struct lnet_libmd;
 
@@ -388,6 +394,15 @@ struct lnet_ni {
 	u32			ni_seq;
 
 	/*
+	 * health value
+	 *	initialized to LNET_MAX_HEALTH_VALUE
+	 * Value is decremented every time we fail to send a message over
+	 * this NI because of a NI specific failure.
+	 * Value is incremented if we successfully send a message.
+	 */
+	atomic_t		ni_healthv;
+
+	/*
 	 * equivalent interfaces to use
 	 * This is an array because socklnd bonding can still be configured
 	 */
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 8be3354..4e83fa8 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1817,6 +1817,7 @@ static void lnet_push_target_fini(void)
 
 	atomic_set(&ni->ni_tx_credits,
 		   lnet_ni_tq_credits(ni) * ni->ni_ncpts);
+	atomic_set(&ni->ni_healthv, LNET_MAX_HEALTH_VALUE);
 
 	CDEBUG(D_LNI, "Added LNI %s [%d/%d/%d/%d]\n",
 	       libcfs_nid2str(ni->ni_nid),
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 10aa753..ab32c6f 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1276,6 +1276,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	struct lnet_ni *ni = NULL;
 	unsigned int shortest_distance;
 	int best_credits;
+	int best_healthv;
 
 	/* If there is no peer_ni that we can send to on this network,
 	 * then there is no point in looking for a new best_ni here.
@@ -1286,20 +1287,21 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	if (!best_ni) {
 		shortest_distance = UINT_MAX;
 		best_credits = INT_MIN;
+		best_healthv = 0;
 	} else {
 		shortest_distance = cfs_cpt_distance(lnet_cpt_table(), md_cpt,
 						     best_ni->ni_dev_cpt);
 		best_credits = atomic_read(&best_ni->ni_tx_credits);
+		best_healthv = atomic_read(&best_ni->ni_healthv);
 	}
 
 	while ((ni = lnet_get_next_ni_locked(local_net, ni))) {
 		unsigned int distance;
 		int ni_credits;
-
-		if (!lnet_is_ni_healthy_locked(ni))
-			continue;
+		int ni_healthv;
 
 		ni_credits = atomic_read(&ni->ni_tx_credits);
+		ni_healthv = atomic_read(&ni->ni_healthv);
 
 		/*
 		 * calculate the distance from the CPT on which
@@ -1325,21 +1327,24 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 			distance = lnet_numa_range;
 
 		/*
-		 * Select on shorter distance, then available
+		 * Select on health, shorter distance, available
 		 * credits, then round-robin.
 		 */
-		if (distance > shortest_distance) {
+		if (ni_healthv < best_healthv) {
+			continue;
+		} else if (distance > shortest_distance) {
 			continue;
 		} else if (distance < shortest_distance) {
 			shortest_distance = distance;
 		} else if (ni_credits < best_credits) {
 			continue;
 		} else if (ni_credits == best_credits) {
-			if (best_ni && (best_ni)->ni_seq <= ni->ni_seq)
+			if (best_ni && best_ni->ni_seq <= ni->ni_seq)
 				continue;
 		}
 		best_ni = ni;
 		best_credits = ni_credits;
+		best_healthv = ni_healthv;
 	}
 
 	CDEBUG(D_NET, "selected best_ni %s\n",
-- 
1.8.3.1
