From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:02:00 -0500
Subject: [lustre-devel] [PATCH 17/27] staging: lustre: make o2iblnd local
	functions static
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Frank Zago <fzago@cray.com>

From: Frank Zago <fzago@cray.com>

This fixes sparse warnings such as:
 .../o2iblnd.c:424:1: warning: symbol 'kiblnd_get_peer_info' was not declared.
                      Should it be static?

This reduces the code size by 400 bytes.

The body of "the_o2iblnd" was moved at the end of the file,
to avoid having to declare some static prototypes.

Signed-off-by: Frank Zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5396
Reviewed-on: http://review.whamcloud.com/11255
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   30 ++++++++++---------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    6 ----
 2 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 56e5784..bd3552e 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -42,15 +42,7 @@
 #include <asm/page.h>
 #include "o2iblnd.h"
 
-static lnd_t the_o2iblnd = {
-	.lnd_type     = O2IBLND,
-	.lnd_startup  = kiblnd_startup,
-	.lnd_shutdown = kiblnd_shutdown,
-	.lnd_ctl      = kiblnd_ctl,
-	.lnd_query    = kiblnd_query,
-	.lnd_send     = kiblnd_send,
-	.lnd_recv     = kiblnd_recv,
-};
+static lnd_t the_o2iblnd;
 
 kib_data_t kiblnd_data;
 
@@ -1012,7 +1004,7 @@ static int kiblnd_close_matching_conns(lnet_ni_t *ni, lnet_nid_t nid)
 	return !count ? -ENOENT : 0;
 }
 
-int kiblnd_ctl(lnet_ni_t *ni, unsigned int cmd, void *arg)
+static int kiblnd_ctl(lnet_ni_t *ni, unsigned int cmd, void *arg)
 {
 	struct libcfs_ioctl_data *data = arg;
 	int rc = -EINVAL;
@@ -1065,7 +1057,7 @@ int kiblnd_ctl(lnet_ni_t *ni, unsigned int cmd, void *arg)
 	return rc;
 }
 
-void kiblnd_query(lnet_ni_t *ni, lnet_nid_t nid, unsigned long *when)
+static void kiblnd_query(lnet_ni_t *ni, lnet_nid_t nid, unsigned long *when)
 {
 	unsigned long last_alive = 0;
 	unsigned long now = cfs_time_current();
@@ -1100,7 +1092,7 @@ void kiblnd_query(lnet_ni_t *ni, lnet_nid_t nid, unsigned long *when)
 	       last_alive ? cfs_duration_sec(now - last_alive) : -1);
 }
 
-void kiblnd_free_pages(kib_pages_t *p)
+static void kiblnd_free_pages(kib_pages_t *p)
 {
 	int npages = p->ibp_npages;
 	int i;
@@ -2491,7 +2483,7 @@ static void kiblnd_base_shutdown(void)
 	module_put(THIS_MODULE);
 }
 
-void kiblnd_shutdown(lnet_ni_t *ni)
+static void kiblnd_shutdown(lnet_ni_t *ni)
 {
 	kib_net_t *net = ni->ni_data;
 	rwlock_t *g_lock = &kiblnd_data.kib_global_lock;
@@ -2745,7 +2737,7 @@ static kib_dev_t *kiblnd_dev_search(char *ifname)
 	return alias;
 }
 
-int kiblnd_startup(lnet_ni_t *ni)
+static int kiblnd_startup(lnet_ni_t *ni)
 {
 	char *ifname;
 	kib_dev_t *ibdev = NULL;
@@ -2840,6 +2832,16 @@ net_failed:
 	return -ENETDOWN;
 }
 
+static lnd_t the_o2iblnd = {
+	.lnd_type	= O2IBLND,
+	.lnd_startup	= kiblnd_startup,
+	.lnd_shutdown	= kiblnd_shutdown,
+	.lnd_ctl	= kiblnd_ctl,
+	.lnd_query	= kiblnd_query,
+	.lnd_send	= kiblnd_send,
+	.lnd_recv	= kiblnd_recv,
+};
+
 static void __exit ko2iblnd_exit(void)
 {
 	lnet_unregister_lnd(&the_o2iblnd);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 8e79e09..4f09776 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -920,11 +920,6 @@ int  kiblnd_fmr_pool_map(kib_fmr_poolset_t *fps, __u64 *pages,
 			 int npages, __u64 iov, kib_fmr_t *fmr);
 void kiblnd_fmr_pool_unmap(kib_fmr_t *fmr, int status);
 
-int  kiblnd_startup(lnet_ni_t *ni);
-void kiblnd_shutdown(lnet_ni_t *ni);
-int  kiblnd_ctl(lnet_ni_t *ni, unsigned int cmd, void *arg);
-void kiblnd_query(struct lnet_ni *ni, lnet_nid_t nid, unsigned long *when);
-
 int  kiblnd_tunables_init(void);
 void kiblnd_tunables_fini(void);
 
@@ -934,7 +929,6 @@ int  kiblnd_thread_start(int (*fn)(void *arg), void *arg, char *name);
 int  kiblnd_failover_thread(void *arg);
 
 int  kiblnd_alloc_pages(kib_pages_t **pp, int cpt, int npages);
-void kiblnd_free_pages(kib_pages_t *p);
 
 int  kiblnd_cm_callback(struct rdma_cm_id *cmid,
 			struct rdma_cm_event *event);
-- 
1.7.1
