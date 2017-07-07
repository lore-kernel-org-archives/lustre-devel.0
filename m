From: Craig Inches <Craig@craiginches.com>
Date: Fri, 07 Jul 2017 01:46:54 +0000 (UTC)
Subject: [lustre-devel] [PATCH 2/4] Staging: Lustre Fix up multiple Block
 Comments in lib-types.h
In-Reply-To: <cover.1499388016.git.Craig@craiginches.com>
References: <cover.1499388016.git.Craig@craiginches.com>
Message-ID: <e58fb4521c39f2858c16e20757979383a008ed0a.1499388016.git.Craig@craiginches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

This patch fixes some multiline comment blocks which didnt conform
to the style guide, found by checkpatch.

Signed-off-by: Craig Inches <Craig@craiginches.com>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  | 46 ++++++++++++++--------
 1 file changed, 30 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 321752dfe58b..ddb808ed5d0b 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -308,9 +308,11 @@ struct lnet_rc_data {
 struct lnet_peer {
 	struct list_head	 lp_hashlist;	/* chain on peer hash */
 	struct list_head	 lp_txq;	/* messages blocking for
-						   tx credits */
+						 * tx credits
+						 */
 	struct list_head	 lp_rtrq;	/* messages blocking for
-						   router credits */
+						 * router credits
+						 */
 	struct list_head	 lp_rtr_list;	/* chain on router list */
 	int			 lp_txcredits;	/* # tx credits available */
 	int			 lp_mintxcredits;  /* low water mark */
@@ -319,23 +321,31 @@ struct lnet_peer {
 	unsigned int		 lp_alive:1;	   /* alive/dead? */
 	unsigned int		 lp_notify:1;	/* notification outstanding? */
 	unsigned int		 lp_notifylnd:1;/* outstanding notification
-						   for LND? */
+						 * for LND?
+						 */
 	unsigned int		 lp_notifying:1; /* some thread is handling
-						    notification */
+						  * notification
+						  */
 	unsigned int		 lp_ping_notsent;/* SEND event outstanding
-						    from ping */
+						  * from ping
+						  */
 	int			 lp_alive_count; /* # times router went
-						    dead<->alive */
-	long			 lp_txqnob;	 /* bytes queued for sending */
+						  * dead<->alive
+						  */
+	long			 lp_txqnob;	 /* ytes queued for sending */
 	unsigned long		 lp_timestamp;	 /* time of last aliveness
-						    news */
+						  * news
+						  */
 	unsigned long		 lp_ping_timestamp;/* time of last ping
-						      attempt */
+						    * attempt
+						    */
 	unsigned long		 lp_ping_deadline; /* != 0 if ping reply
-						      expected */
+						    * expected
+						    */
 	unsigned long		 lp_last_alive;	/* when I was last alive */
 	unsigned long		 lp_last_query;	/* when lp_ni was queried
-						   last time */
+						 * last time
+						 */
 	struct lnet_ni		*lp_ni;		/* interface peer is on */
 	lnet_nid_t		 lp_nid;	/* peer's NID */
 	int			 lp_refcount;	/* # refs */
@@ -386,7 +396,8 @@ struct lnet_route {
 
 struct lnet_remotenet {
 	struct list_head	lrn_list;	/* chain on
-						   ln_remote_nets_hash */
+						 * ln_remote_nets_hash
+						 */
 	struct list_head	lrn_routes;	/* routes to me */
 	__u32			lrn_net;	/* my net number */
 };
@@ -399,14 +410,16 @@ struct lnet_remotenet {
 struct lnet_rtrbufpool {
 	struct list_head	rbp_bufs;	/* my free buffer pool */
 	struct list_head	rbp_msgs;	/* messages blocking
-						   for a buffer */
+						 * for a buffer
+						 */
 	int			rbp_npages;	/* # pages in each buffer */
 	/* requested number of buffers */
 	int			rbp_req_nbuffers;
 	/* # buffers actually allocated */
 	int			rbp_nbuffers;
-	int			rbp_credits;	/* # free buffers /
-						     blocked messages */
+	int			rbp_credits;	/* # free buffers
+						 * blocked messages
+						 */
 	int			rbp_mincredits;	/* low water mark */
 };
 
@@ -442,7 +455,8 @@ enum lnet_match_flags {
 #define LNET_PTL_LAZY		(1 << 0)
 #define LNET_PTL_MATCH_UNIQUE	(1 << 1)	/* unique match, for RDMA */
 #define LNET_PTL_MATCH_WILDCARD	(1 << 2)	/* wildcard match,
-						   request portal */
+						 * request portal
+						 */
 
 /* parameter for matching operations (GET, PUT) */
 struct lnet_match_info {
-- 
2.13.0
