From: James Simmons <jsimmons@infradead.org>
Date: Fri,  6 May 2016 21:30:27 -0400
Subject: [lustre-devel] [PATCH 06/10] staging: lustre: o2iblnd: use data in
	lnet_ni_t instead of kiblnd_tunables
In-Reply-To: <1462584631-5388-1-git-send-email-jsimmons@infradead.org>
References: <1462584631-5388-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462584631-5388-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>, James Simmons <uja.ornl@yahoo.com>, James Simmons <jsimmons@infradead.org>

From: Amir Shehata <amir.shehata@intel.com>

Currently the ko2iblnd creates a kib_tunable_t stucture
to allow the ko2iblnd driver to access the module parameters
throught the code. Some of those data fields also exist
in lnet_ni_t. Migrate to using the lnet_ni_t data fields
instead of kib_tunable_t.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7101
Reviewed-on: http://review.whamcloud.com/16367
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    8 +--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    6 +--
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |   54 +++++++++++--------
 3 files changed, 34 insertions(+), 34 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index a06689b..84a15d4 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -336,7 +336,7 @@ int kiblnd_create_peer(lnet_ni_t *ni, kib_peer_t **peerp, lnet_nid_t nid)
 	peer->ibp_error = 0;
 	peer->ibp_last_alive = 0;
 	peer->ibp_max_frags = kiblnd_cfg_rdma_frags(peer->ibp_ni);
-	peer->ibp_queue_depth = *kiblnd_tunables.kib_peertxcredits;
+	peer->ibp_queue_depth = ni->ni_peertxcredits;
 	atomic_set(&peer->ibp_refcount, 1);  /* 1 ref for caller */
 
 	INIT_LIST_HEAD(&peer->ibp_list);     /* not in the peer table yet */
@@ -2921,13 +2921,9 @@ static int kiblnd_startup(lnet_ni_t *ni)
 	net->ibn_incarnation = tv.tv_sec * USEC_PER_SEC +
 			       tv.tv_nsec / NSEC_PER_USEC;
 
-	rc = kiblnd_tunables_setup();
+	rc = kiblnd_tunables_setup(ni);
 	if (rc)
 		goto net_failed;
-	ni->ni_peertimeout    = *kiblnd_tunables.kib_peertimeout;
-	ni->ni_maxtxcredits   = *kiblnd_tunables.kib_credits;
-	ni->ni_peertxcredits  = *kiblnd_tunables.kib_peertxcredits;
-	ni->ni_peerrtrcredits = *kiblnd_tunables.kib_peerrtrcredits;
 
 	if (ni->ni_interfaces[0]) {
 		/* Use the IPoIB interface specified in 'networks=' */
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 80e11bc..fffae0c 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -87,11 +87,7 @@ typedef struct {
 	int *kib_timeout;                /* comms timeout (seconds) */
 	int *kib_keepalive;              /* keepalive timeout (seconds) */
 	int *kib_ntx;                    /* # tx descs */
-	int *kib_credits;                /* # concurrent sends */
-	int *kib_peertxcredits;          /* # concurrent sends to 1 peer */
-	int *kib_peerrtrcredits;         /* # per-peer router buffer credits */
 	int *kib_peercredits_hiw;        /* # when eagerly to return credits */
-	int *kib_peertimeout;            /* seconds to consider peer dead */
 	char **kib_default_ipif;         /* default IPoIB interface */
 	int *kib_retry_count;
 	int *kib_rnr_retry_count;
@@ -994,7 +990,7 @@ int  kiblnd_fmr_pool_map(kib_fmr_poolset_t *fps, kib_tx_t *tx,
 			 kib_fmr_t *fmr);
 void kiblnd_fmr_pool_unmap(kib_fmr_t *fmr, int status);
 
-int kiblnd_tunables_setup(void);
+int kiblnd_tunables_setup(struct lnet_ni *ni);
 void kiblnd_tunables_init(void);
 void kiblnd_tunables_fini(void);
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index cc1469d..e50a9cf 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -152,11 +152,7 @@ kib_tunables_t kiblnd_tunables = {
 	.kib_timeout           = &timeout,
 	.kib_keepalive         = &keepalive,
 	.kib_ntx               = &ntx,
-	.kib_credits           = &credits,
-	.kib_peertxcredits     = &peer_credits,
 	.kib_peercredits_hiw   = &peer_credits_hiw,
-	.kib_peerrtrcredits    = &peer_buffer_credits,
-	.kib_peertimeout       = &peer_timeout,
 	.kib_default_ipif      = &ipif_name,
 	.kib_retry_count       = &retry_count,
 	.kib_rnr_retry_count   = &rnr_retry_count,
@@ -184,7 +180,7 @@ int kiblnd_msg_queue_size(int version, lnet_ni_t *ni)
 		return peer_credits;
 }
 
-int kiblnd_tunables_setup(void)
+int kiblnd_tunables_setup(struct lnet_ni *ni)
 {
 	if (kiblnd_translate_mtu(*kiblnd_tunables.kib_ib_mtu) < 0) {
 		CERROR("Invalid ib_mtu %d, expected 256/512/1024/2048/4096\n",
@@ -192,20 +188,32 @@ int kiblnd_tunables_setup(void)
 		return -EINVAL;
 	}
 
-	if (*kiblnd_tunables.kib_peertxcredits < IBLND_CREDITS_DEFAULT)
-		*kiblnd_tunables.kib_peertxcredits = IBLND_CREDITS_DEFAULT;
+	if (!ni->ni_peertimeout)
+		ni->ni_peertimeout = peer_timeout;
 
-	if (*kiblnd_tunables.kib_peertxcredits > IBLND_CREDITS_MAX)
-		*kiblnd_tunables.kib_peertxcredits = IBLND_CREDITS_MAX;
+	if (!ni->ni_maxtxcredits)
+		ni->ni_maxtxcredits = credits;
 
-	if (*kiblnd_tunables.kib_peertxcredits > *kiblnd_tunables.kib_credits)
-		*kiblnd_tunables.kib_peertxcredits = *kiblnd_tunables.kib_credits;
+	if (!ni->ni_peertxcredits)
+		ni->ni_peertxcredits = peer_credits;
 
-	if (*kiblnd_tunables.kib_peercredits_hiw < *kiblnd_tunables.kib_peertxcredits / 2)
-		*kiblnd_tunables.kib_peercredits_hiw = *kiblnd_tunables.kib_peertxcredits / 2;
+	if (!ni->ni_peerrtrcredits)
+		ni->ni_peerrtrcredits = peer_buffer_credits;
 
-	if (*kiblnd_tunables.kib_peercredits_hiw >= *kiblnd_tunables.kib_peertxcredits)
-		*kiblnd_tunables.kib_peercredits_hiw = *kiblnd_tunables.kib_peertxcredits - 1;
+	if (ni->ni_peertxcredits < IBLND_CREDITS_DEFAULT)
+		ni->ni_peertxcredits = IBLND_CREDITS_DEFAULT;
+
+	if (ni->ni_peertxcredits > IBLND_CREDITS_MAX)
+		ni->ni_peertxcredits = IBLND_CREDITS_MAX;
+
+	if (ni->ni_peertxcredits > credits)
+		ni->ni_peertxcredits = credits;
+
+	if (*kiblnd_tunables.kib_peercredits_hiw < ni->ni_peertxcredits / 2)
+		*kiblnd_tunables.kib_peercredits_hiw = ni->ni_peertxcredits / 2;
+
+	if (*kiblnd_tunables.kib_peercredits_hiw >= ni->ni_peertxcredits)
+		*kiblnd_tunables.kib_peercredits_hiw = ni->ni_peertxcredits - 1;
 
 	if (*kiblnd_tunables.kib_map_on_demand < 0 ||
 	    *kiblnd_tunables.kib_map_on_demand > IBLND_MAX_RDMA_FRAGS)
@@ -217,20 +225,20 @@ int kiblnd_tunables_setup(void)
 	if (!*kiblnd_tunables.kib_concurrent_sends) {
 		if (*kiblnd_tunables.kib_map_on_demand > 0 &&
 		    *kiblnd_tunables.kib_map_on_demand <= IBLND_MAX_RDMA_FRAGS / 8)
-			*kiblnd_tunables.kib_concurrent_sends = (*kiblnd_tunables.kib_peertxcredits) * 2;
+			*kiblnd_tunables.kib_concurrent_sends = ni->ni_peertxcredits * 2;
 		else
-			*kiblnd_tunables.kib_concurrent_sends = (*kiblnd_tunables.kib_peertxcredits);
+			*kiblnd_tunables.kib_concurrent_sends = ni->ni_peertxcredits;
 	}
 
-	if (*kiblnd_tunables.kib_concurrent_sends > *kiblnd_tunables.kib_peertxcredits * 2)
-		*kiblnd_tunables.kib_concurrent_sends = *kiblnd_tunables.kib_peertxcredits * 2;
+	if (*kiblnd_tunables.kib_concurrent_sends > ni->ni_peertxcredits * 2)
+		*kiblnd_tunables.kib_concurrent_sends = ni->ni_peertxcredits * 2;
 
-	if (*kiblnd_tunables.kib_concurrent_sends < *kiblnd_tunables.kib_peertxcredits / 2)
-		*kiblnd_tunables.kib_concurrent_sends = *kiblnd_tunables.kib_peertxcredits / 2;
+	if (*kiblnd_tunables.kib_concurrent_sends < ni->ni_peertxcredits / 2)
+		*kiblnd_tunables.kib_concurrent_sends = ni->ni_peertxcredits / 2;
 
-	if (*kiblnd_tunables.kib_concurrent_sends < *kiblnd_tunables.kib_peertxcredits) {
+	if (*kiblnd_tunables.kib_concurrent_sends < ni->ni_peertxcredits) {
 		CWARN("Concurrent sends %d is lower than message queue size: %d, performance may drop slightly.\n",
-		      *kiblnd_tunables.kib_concurrent_sends, *kiblnd_tunables.kib_peertxcredits);
+		      *kiblnd_tunables.kib_concurrent_sends, ni->ni_peertxcredits);
 	}
 
 	return 0;
-- 
1.7.1
