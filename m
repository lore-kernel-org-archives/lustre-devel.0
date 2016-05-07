From: James Simmons <jsimmons@infradead.org>
Date: Fri,  6 May 2016 21:30:26 -0400
Subject: [lustre-devel] [PATCH 05/10] staging: lustre: o2iblnd: create
	default o2iblnd tunable settings
In-Reply-To: <1462584631-5388-1-git-send-email-jsimmons@infradead.org>
References: <1462584631-5388-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462584631-5388-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>, James Simmons <uja.ornl@yahoo.com>, James Simmons <jsimmons@infradead.org>

From: Amir Shehata <amir.shehata@intel.com>

Create and set the default o2iblnd tunables when the ko2iblnd
module loads. Move kiblnd_tunables_setup() to when the NI
iterface is initialized.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7101
Reviewed-on: http://review.whamcloud.com/16367
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    9 ++++-----
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    3 ++-
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |   16 ++++++++++++++--
 3 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index a2e188e..a06689b 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2921,6 +2921,9 @@ static int kiblnd_startup(lnet_ni_t *ni)
 	net->ibn_incarnation = tv.tv_sec * USEC_PER_SEC +
 			       tv.tv_nsec / NSEC_PER_USEC;
 
+	rc = kiblnd_tunables_setup();
+	if (rc)
+		goto net_failed;
 	ni->ni_peertimeout    = *kiblnd_tunables.kib_peertimeout;
 	ni->ni_maxtxcredits   = *kiblnd_tunables.kib_credits;
 	ni->ni_peertxcredits  = *kiblnd_tunables.kib_peertxcredits;
@@ -3006,8 +3009,6 @@ static void __exit ko2iblnd_exit(void)
 
 static int __init ko2iblnd_init(void)
 {
-	int rc;
-
 	CLASSERT(sizeof(kib_msg_t) <= IBLND_MSG_SIZE);
 	CLASSERT(offsetof(kib_msg_t,
 			  ibm_u.get.ibgm_rd.rd_frags[IBLND_MAX_RDMA_FRAGS])
@@ -3016,9 +3017,7 @@ static int __init ko2iblnd_init(void)
 			  ibm_u.putack.ibpam_rd.rd_frags[IBLND_MAX_RDMA_FRAGS])
 			  <= IBLND_MSG_SIZE);
 
-	rc = kiblnd_tunables_init();
-	if (rc)
-		return rc;
+	kiblnd_tunables_init();
 
 	lnet_register_lnd(&the_o2iblnd);
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index fab0ef9..80e11bc 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -994,7 +994,8 @@ int  kiblnd_fmr_pool_map(kib_fmr_poolset_t *fps, kib_tx_t *tx,
 			 kib_fmr_t *fmr);
 void kiblnd_fmr_pool_unmap(kib_fmr_t *fmr, int status);
 
-int  kiblnd_tunables_init(void);
+int kiblnd_tunables_setup(void);
+void kiblnd_tunables_init(void);
 void kiblnd_tunables_fini(void);
 
 int  kiblnd_connd(void *arg);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index a6415fc..cc1469d 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -171,6 +171,8 @@ kib_tunables_t kiblnd_tunables = {
 	.kib_nscheds           = &nscheds
 };
 
+static struct lnet_ioctl_config_o2iblnd_tunables default_tunables;
+
 /* # messages/RDMAs in-flight */
 int kiblnd_msg_queue_size(int version, lnet_ni_t *ni)
 {
@@ -182,8 +184,7 @@ int kiblnd_msg_queue_size(int version, lnet_ni_t *ni)
 		return peer_credits;
 }
 
-int
-kiblnd_tunables_init(void)
+int kiblnd_tunables_setup(void)
 {
 	if (kiblnd_translate_mtu(*kiblnd_tunables.kib_ib_mtu) < 0) {
 		CERROR("Invalid ib_mtu %d, expected 256/512/1024/2048/4096\n",
@@ -234,3 +235,14 @@ kiblnd_tunables_init(void)
 
 	return 0;
 }
+
+void kiblnd_tunables_init(void)
+{
+	default_tunables.lnd_version = 0;
+	default_tunables.lnd_peercredits_hiw = peer_credits_hiw,
+	default_tunables.lnd_map_on_demand = map_on_demand;
+	default_tunables.lnd_concurrent_sends = concurrent_sends;
+	default_tunables.lnd_fmr_pool_size = fmr_pool_size;
+	default_tunables.lnd_fmr_flush_trigger = fmr_flush_trigger;
+	default_tunables.lnd_fmr_cache = fmr_cache;
+}
-- 
1.7.1
