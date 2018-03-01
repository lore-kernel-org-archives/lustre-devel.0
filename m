From: NeilBrown <neilb@suse.com>
Date: Fri, 02 Mar 2018 10:31:25 +1100
Subject: [lustre-devel] [PATCH 06/17] staging: lustre: get entropy from nid
 when nid set.
In-Reply-To: <151994679573.7628.1024109499321778846.stgit@noble>
References: <151994679573.7628.1024109499321778846.stgit@noble>
Message-ID: <151994708524.7628.17942703834112140684.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

When the 'lustre' module is loaded, it gets a list of
net devices and uses the node ids to  add entropy
to the prng.  This means that the network interfaces need
to be configured before the module is loaded, which prevents
the module from being compiled into a monolithic kernel.

So move this entropy addition to the moment when
the interface is imported to LNet and the node id is first known.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c     |    7 +++++++
 drivers/staging/lustre/lustre/llite/super25.c |   17 +----------------
 2 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 48d25ccadbb3..90266be0132d 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1214,6 +1214,7 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
 	struct lnet_lnd *lnd;
 	struct lnet_tx_queue *tq;
 	int i;
+	u32 seed;
 
 	lnd_type = LNET_NETTYP(LNET_NIDNET(ni->ni_nid));
 
@@ -1352,6 +1353,12 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
 		tq->tq_credits = lnet_ni_tq_credits(ni);
 	}
 
+	/* Nodes with small feet have little entropy. The NID for this
+	 * node gives the most entropy in the low bits.
+	 */
+	seed = LNET_NIDADDR(ni->ni_nid);
+	add_device_randomness(&seed, sizeof(seed));
+
 	CDEBUG(D_LNI, "Added LNI %s [%d/%d/%d/%d]\n",
 	       libcfs_nid2str(ni->ni_nid), ni->ni_peertxcredits,
 	       lnet_ni_tq_credits(ni) * LNET_CPT_NUMBER,
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 9b0bb3541a84..861e7a60f408 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -85,8 +85,7 @@ MODULE_ALIAS_FS("lustre");
 
 static int __init lustre_init(void)
 {
-	struct lnet_process_id lnet_id;
-	int i, rc;
+	int rc;
 
 	BUILD_BUG_ON(sizeof(LUSTRE_VOLATILE_HDR) !=
 		     LUSTRE_VOLATILE_HDR_LEN + 1);
@@ -125,20 +124,6 @@ static int __init lustre_init(void)
 		goto out_debugfs;
 	}
 
-	/* Nodes with small feet have little entropy. The NID for this
-	 * node gives the most entropy in the low bits
-	 */
-	for (i = 0;; i++) {
-		u32 seed;
-
-		if (LNetGetId(i, &lnet_id) == -ENOENT)
-			break;
-		if (LNET_NETTYP(LNET_NIDNET(lnet_id.nid)) != LOLND) {
-			 seed = LNET_NIDADDR(lnet_id.nid);
-			 add_device_randomness(&seed, sizeof(seed));
-		}
-	}
-
 	rc = vvp_global_init();
 	if (rc != 0)
 		goto out_sysfs;
