From: Doug Oucharek <doucharek@cray.com>
Date: Mon, 10 Sep 2018 22:49:30 +0000
Subject: [lustre-devel] [PATCH 01/34] struct lnet_ni - reformat comments.
In-Reply-To: <153628137125.8267.7825080417267355121.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137125.8267.7825080417267355121.stgit@noble>
Message-ID: <C65687E4-A05B-4CA1-A06F-2D740281ACC4@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Reviewed-by: Doug Oucharek <dougso at me.com<mailto:dougso@me.com>>

Doug

On Sep 6, 2018, at 5:49 PM, NeilBrown <neilb at suse.com<mailto:neilb@suse.com>> wrote:

This is part of

8cbb8cd3e771e7f7e0f99cafc19fad32770dc015 LU-7734 lnet: Multi-Rail
local NI split
---
.../staging/lustre/include/linux/lnet/lib-types.h  |   38 +++++++++++++++-----
1 file changed, 29 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 6d4106fd9039..078bc97a9ebf 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -263,18 +263,38 @@ struct lnet_ni {
int  ni_peerrtrcredits;
/* seconds to consider peer dead */
int  ni_peertimeout;
- int  ni_ncpts; /* number of CPTs */
- __u32 *ni_cpts; /* bond NI on some CPTs */
- lnet_nid_t  ni_nid; /* interface's NID */
- void *ni_data; /* instance-specific data */
+ /* number of CPTs */
+ int ni_ncpts;
+
+ /* bond NI on some CPTs */
+ __u32 *ni_cpts;
+
+ /* interface's NID */
+ lnet_nid_t ni_nid;
+
+ /* instance-specific data */
+ void *ni_data;
+
struct lnet_lnd *ni_lnd; /* procedural interface */
- struct lnet_tx_queue **ni_tx_queues; /* percpt TX queues */
- int **ni_refs; /* percpt reference count */
- time64_t  ni_last_alive;/* when I was last alive */
- struct lnet_ni_status *ni_status; /* my health status */
+
+ /* percpt TX queues */
+ struct lnet_tx_queue **ni_tx_queues;
+
+ /* percpt reference count */
+ int **ni_refs;
+
+ /* when I was last alive */
+ time64_t ni_last_alive;
+
+ /* my health status */
+ struct lnet_ni_status *ni_status;
+
/* per NI LND tunables */
struct lnet_ioctl_config_lnd_tunables *ni_lnd_tunables;
- /* equivalent interfaces to use */
+ /*
+ * equivalent interfaces to use
+ * This is an array because socklnd bonding can still be configured
+ */
char *ni_interfaces[LNET_MAX_INTERFACES];
/* original net namespace */
struct net *ni_net_ns;



-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180910/b1a8cc20/attachment.html>
