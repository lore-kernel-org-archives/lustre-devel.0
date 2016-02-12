From: James Simmons <jsimmons@infradead.org>
Date: Fri, 12 Feb 2016 12:06:04 -0500
Subject: [lustre-devel] [PATCH 06/11] staging: lustre: add missing spaces
	for LNet layer reported by checkpatch.pl
In-Reply-To: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
References: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1455296769-5481-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Dorkin <oleg.dorkin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Add missing spaces in the code reported by checkpatch.pl.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  |    2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    4 ++--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   12 ++++++------
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |    6 +++---
 .../lustre/lnet/klnds/socklnd/socklnd_modparams.c  |    2 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    2 +-
 drivers/staging/lustre/lnet/lnet/config.c          |   15 +++++++--------
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |    1 -
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |    4 ++--
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |    2 +-
 12 files changed, 26 insertions(+), 28 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 55d9d43..42f08c8 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -112,7 +112,7 @@ typedef struct lnet_libhandle {
 } lnet_libhandle_t;
 
 #define lh_entry(ptr, type, member) \
-	((type *)((char *)(ptr)-(char *)(&((type *)0)->member)))
+	((type *)((char *)(ptr) - (char *)(&((type *)0)->member)))
 
 typedef struct lnet_eq {
 	struct list_head	  eq_list;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 09eaecd..812d9b5 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1400,7 +1400,7 @@ static int kiblnd_create_fmr_pool(kib_fmr_poolset_t *fps,
 	kib_dev_t *dev = fps->fps_net->ibn_dev;
 	kib_fmr_pool_t *fpo;
 	struct ib_fmr_pool_param param = {
-		.max_pages_per_fmr = LNET_MAX_PAYLOAD/PAGE_SIZE,
+		.max_pages_per_fmr = LNET_MAX_PAYLOAD / PAGE_SIZE,
 		.page_shift        = PAGE_SHIFT,
 		.access            = (IB_ACCESS_LOCAL_WRITE |
 				      IB_ACCESS_REMOTE_WRITE),
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index dbbbf55..288f0d2 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -146,7 +146,7 @@ kiblnd_concurrent_sends_v1(void)
 #define IBLND_OOB_CAPABLE(v)       ((v) != IBLND_MSG_VERSION_1)
 #define IBLND_OOB_MSGS(v)	   (IBLND_OOB_CAPABLE(v) ? 2 : 0)
 
-#define IBLND_MSG_SIZE	      (4<<10)		 /* max size of queued messages (inc hdr) */
+#define IBLND_MSG_SIZE		(4 << 10)	 /* max size of queued messages (inc hdr) */
 #define IBLND_MAX_RDMA_FRAGS	 LNET_MAX_IOV	   /* max # of fragments supported */
 #define IBLND_CFG_RDMA_FRAGS       (*kiblnd_tunables.kib_map_on_demand != 0 ? \
 				    *kiblnd_tunables.kib_map_on_demand :      \
@@ -691,7 +691,7 @@ kiblnd_send_keepalive(kib_conn_t *conn)
 {
 	return (*kiblnd_tunables.kib_keepalive > 0) &&
 		cfs_time_after(jiffies, conn->ibc_last_send +
-			       *kiblnd_tunables.kib_keepalive*HZ);
+			       *kiblnd_tunables.kib_keepalive * HZ);
 }
 
 static inline int
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 6b5a0b3..46d1810 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1217,7 +1217,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	}
 
 	/* look for a free privileged port */
-	for (port = PROT_SOCK-1; port > 0; port--) {
+	for (port = PROT_SOCK - 1; port > 0; port--) {
 		srcaddr->sin_port = htons(port);
 		rc = rdma_resolve_addr(cmid,
 				       (struct sockaddr *)srcaddr,
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index c428684..4ab7f29 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -357,7 +357,7 @@ ksocknal_associate_route_conn_locked(ksock_route_t *route, ksock_conn_t *conn)
 			iface->ksni_nroutes++;
 	}
 
-	route->ksnr_connected |= (1<<type);
+	route->ksnr_connected |= (1 << type);
 	route->ksnr_conn_count++;
 
 	/*
@@ -839,7 +839,7 @@ ksocknal_select_ips(ksock_peer_t *peer, __u32 *peerips, int n_peerips)
 			best_iface->ksni_npeers++;
 			ip = best_iface->ksni_ipaddr;
 			peer->ksnp_passive_ips[i] = ip;
-			peer->ksnp_n_passive_ips = i+1;
+			peer->ksnp_n_passive_ips = i + 1;
 		}
 
 		/* mark the best matching peer IP used */
@@ -2047,8 +2047,8 @@ ksocknal_peer_del_interface_locked(ksock_peer_t *peer, __u32 ipaddr)
 
 	for (i = 0; i < peer->ksnp_n_passive_ips; i++)
 		if (peer->ksnp_passive_ips[i] == ipaddr) {
-			for (j = i+1; j < peer->ksnp_n_passive_ips; j++)
-				peer->ksnp_passive_ips[j-1] =
+			for (j = i + 1; j < peer->ksnp_n_passive_ips; j++)
+				peer->ksnp_passive_ips[j - 1] =
 					peer->ksnp_passive_ips[j];
 			peer->ksnp_n_passive_ips--;
 			break;
@@ -2099,8 +2099,8 @@ ksocknal_del_interface(lnet_ni_t *ni, __u32 ipaddress)
 
 		rc = 0;
 
-		for (j = i+1; j < net->ksnn_ninterfaces; j++)
-			net->ksnn_interfaces[j-1] =
+		for (j = i + 1; j < net->ksnn_ninterfaces; j++)
+			net->ksnn_interfaces[j - 1] =
 				net->ksnn_interfaces[j];
 
 		net->ksnn_ninterfaces--;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index c82ed27..31b8d46 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -1960,7 +1960,7 @@ ksocknal_connect (ksock_route_t *route)
 			 * so min_reconnectms should be good heuristic
 			 */
 			route->ksnr_retry_interval =
-				cfs_time_seconds(*ksocknal_tunables.ksnd_min_reconnectms)/1000;
+				cfs_time_seconds(*ksocknal_tunables.ksnd_min_reconnectms) / 1000;
 			route->ksnr_timeout = cfs_time_add(cfs_time_current(),
 							   route->ksnr_retry_interval);
 		}
@@ -1981,10 +1981,10 @@ ksocknal_connect (ksock_route_t *route)
 	route->ksnr_retry_interval *= 2;
 	route->ksnr_retry_interval =
 		max(route->ksnr_retry_interval,
-		    cfs_time_seconds(*ksocknal_tunables.ksnd_min_reconnectms)/1000);
+		    cfs_time_seconds(*ksocknal_tunables.ksnd_min_reconnectms) / 1000);
 	route->ksnr_retry_interval =
 		min(route->ksnr_retry_interval,
-		    cfs_time_seconds(*ksocknal_tunables.ksnd_max_reconnectms)/1000);
+		    cfs_time_seconds(*ksocknal_tunables.ksnd_max_reconnectms) / 1000);
 
 	LASSERT (route->ksnr_retry_interval != 0);
 	route->ksnr_timeout = cfs_time_add(cfs_time_current(),
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
index 374ba67..77ce597 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
@@ -74,7 +74,7 @@ static int typed_conns = 1;
 module_param(typed_conns, int, 0444);
 MODULE_PARM_DESC(typed_conns, "use different sockets for bulk");
 
-static int min_bulk = 1<<10;
+static int min_bulk = 1 << 10;
 module_param(min_bulk, int, 0644);
 MODULE_PARM_DESC(min_bulk, "smallest 'large' message");
 
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 78188a9..f7d53cd 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1394,7 +1394,7 @@ LNetCtl(unsigned int cmd, void *arg)
 		id.pid = data->ioc_u32[0];
 		rc = lnet_ping(id, data->ioc_u32[1], /* timeout */
 			       data->ioc_pbuf1,
-			       data->ioc_plen1/sizeof(lnet_process_id_t));
+			       data->ioc_plen1 / sizeof(lnet_process_id_t));
 		if (rc < 0)
 			return rc;
 		data->ioc_count = rc;
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 695db24..e30a959 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -44,8 +44,8 @@ struct lnet_text_buf {	    /* tmp struct for parsing routes */
 };
 
 static int lnet_tbnob;			/* track text buf allocation */
-#define LNET_MAX_TEXTBUF_NOB     (64<<10)	/* bound allocation */
-#define LNET_SINGLE_TEXTBUF_NOB  (4<<10)
+#define LNET_MAX_TEXTBUF_NOB     (64 << 10)	/* bound allocation */
+#define LNET_SINGLE_TEXTBUF_NOB  (4 << 10)
 
 static void
 lnet_syntax(char *name, char *str, int offset, int width)
@@ -54,9 +54,9 @@ lnet_syntax(char *name, char *str, int offset, int width)
 	static char dashes[LNET_SINGLE_TEXTBUF_NOB];
 
 	memset(dots, '.', sizeof(dots));
-	dots[sizeof(dots)-1] = 0;
+	dots[sizeof(dots) - 1] = 0;
 	memset(dashes, '-', sizeof(dashes));
-	dashes[sizeof(dashes)-1] = 0;
+	dashes[sizeof(dashes) - 1] = 0;
 
 	LCONSOLE_ERROR_MSG(0x10f, "Error parsing '%s=\"%s\"'\n", name, str);
 	LCONSOLE_ERROR_MSG(0x110, "here...........%.*s..%.*s|%.*s|\n",
@@ -492,7 +492,7 @@ lnet_expand1tb(struct list_head *list,
 
 	memcpy(ltb->ltb_text, str, len1);
 	memcpy(&ltb->ltb_text[len1], item, itemlen);
-	memcpy(&ltb->ltb_text[len1+itemlen], sep2 + 1, len2);
+	memcpy(&ltb->ltb_text[len1 + itemlen], sep2 + 1, len2);
 	ltb->ltb_text[len1 + itemlen + len2] = 0;
 
 	list_add_tail(&ltb->ltb_list, list);
@@ -542,7 +542,6 @@ lnet_str2tbs_expand(struct list_head *tbs, char *str)
 						   (int)(enditem - parsed)) != 0) {
 					goto failed;
 				}
-
 				continue;
 			}
 
@@ -605,7 +604,7 @@ lnet_parse_priority(char *str, unsigned int *priority, char **token)
 	}
 	len = strlen(sep + 1);
 
-	if ((sscanf((sep+1), "%u%n", priority, &nob) < 1) || (len != nob)) {
+	if ((sscanf((sep + 1), "%u%n", priority, &nob) < 1) || (len != nob)) {
 		/*
 		 * Update the caller's token pointer so it treats the found
 		 * priority as the token to report in the error message.
@@ -1020,7 +1019,7 @@ lnet_match_networks(char **networksp, char *ip2nets, __u32 *ipaddrs, int nip)
 		tb = list_entry(raw_entries.next, struct lnet_text_buf,
 				ltb_list);
 		strncpy(source, tb->ltb_text, sizeof(source));
-		source[sizeof(source)-1] = '\0';
+		source[sizeof(source) - 1] = '\0';
 
 		/* replace ltb_text with the network(s) add on match */
 		rc = lnet_match_network_tokens(tb->ltb_text, ipaddrs, nip);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
index e543cb4..683eb45 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
@@ -332,7 +332,6 @@ __must_hold(&the_lnet.ln_eq_wait_lock)
 
 	if (tms < 0) {
 		schedule();
-
 	} else {
 		now = jiffies;
 		schedule_timeout(msecs_to_jiffies(tms));
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 0b3ef17..f775879 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -159,7 +159,7 @@ lnet_ipif_enumerate(char ***namesp)
 	for (;;) {
 		if (nalloc * sizeof(*ifr) > PAGE_CACHE_SIZE) {
 			toobig = 1;
-			nalloc = PAGE_CACHE_SIZE/sizeof(*ifr);
+			nalloc = PAGE_CACHE_SIZE / sizeof(*ifr);
 			CWARN("Too many interfaces: only enumerating first %d\n",
 			      nalloc);
 		}
@@ -183,7 +183,7 @@ lnet_ipif_enumerate(char ***namesp)
 
 		LASSERT(rc == 0);
 
-		nfound = ifc.ifc_len/sizeof(*ifr);
+		nfound = ifc.ifc_len / sizeof(*ifr);
 		LASSERT(nfound <= nalloc);
 
 		if (nfound < nalloc || toobig)
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index 00de4fa..449efc7 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -808,7 +808,7 @@ libcfs_ip_str2addr(const char *str, int nob, __u32 *addr)
 	    n == nob &&
 	    (a & ~0xff) == 0 && (b & ~0xff) == 0 &&
 	    (c & ~0xff) == 0 && (d & ~0xff) == 0) {
-		*addr = ((a<<24)|(b<<16)|(c<<8)|d);
+		*addr = ((a << 24) | (b << 16) | (c << 8) | d);
 		return 1;
 	}
 
-- 
1.7.1
