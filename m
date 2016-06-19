From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 18 Jun 2016 23:53:12 -0400
Subject: [lustre-devel] [PATCH 3/4] staging/lustre: Remove unnecessary space
	after a cast
In-Reply-To: <1466308393-1183295-1-git-send-email-green@linuxhacker.ru>
References: <1466308393-1183295-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466308393-1183295-4-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>, Emoly Liu <emoly.liu@intel.com>

This patch fixes all checkpatch occurences of
"CHECK: No space is necessary after a cast"
in Lustre code.

Signed-off-by: Emoly Liu <emoly.liu@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/include/linux/lnet/lib-dlc.h       |  2 +-
 drivers/staging/lustre/include/linux/lnet/types.h         |  4 ++--
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h       |  2 +-
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c    |  2 +-
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c       |  4 ++--
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c    |  4 ++--
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c |  6 +++---
 drivers/staging/lustre/lnet/lnet/api-ni.c                 |  2 +-
 drivers/staging/lustre/lnet/lnet/module.c                 |  2 +-
 drivers/staging/lustre/lustre/include/lustre_sec.h        |  6 +++---
 drivers/staging/lustre/lustre/llite/file.c                |  2 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c             |  2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c           |  4 ++--
 drivers/staging/lustre/lustre/mgc/mgc_request.c           |  4 ++--
 drivers/staging/lustre/lustre/obdclass/cl_object.c        |  6 +++---
 drivers/staging/lustre/lustre/obdclass/obd_config.c       |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/nrs.c                |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c                |  4 ++--
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c           |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c         |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_null.c           |  4 ++--
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c          | 10 +++++-----
 22 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-dlc.h b/drivers/staging/lustre/include/linux/lnet/lib-dlc.h
index 6ce9acc..dfff170 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-dlc.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-dlc.h
@@ -35,7 +35,7 @@
 #define MAX_NUM_SHOW_ENTRIES	32
 #define LNET_MAX_STR_LEN	128
 #define LNET_MAX_SHOW_NUM_CPT	128
-#define LNET_UNDEFINED_HOPS	((__u32) -1)
+#define LNET_UNDEFINED_HOPS	((__u32)(-1))
 
 struct lnet_ioctl_config_lnd_cmn_tunables {
 	__u32 lct_version;
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 1c679cb..e098b6c 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -68,9 +68,9 @@ typedef __u64 lnet_nid_t;
 typedef __u32 lnet_pid_t;
 
 /** wildcard NID that matches any end-point address */
-#define LNET_NID_ANY	((lnet_nid_t) -1)
+#define LNET_NID_ANY	((lnet_nid_t)(-1))
 /** wildcard PID that matches any lnet_pid_t */
-#define LNET_PID_ANY	((lnet_pid_t) -1)
+#define LNET_PID_ANY	((lnet_pid_t)(-1))
 
 #define LNET_PID_RESERVED 0xf0000000 /* reserved bits in PID */
 #define LNET_PID_USERFLAG 0x80000000 /* set in userspace peers */
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index b66ab79..078a0c3 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -98,7 +98,7 @@ extern struct kib_tunables  kiblnd_tunables;
 #define IBLND_CREDIT_HIGHWATER_V1 7 /* V1 only : when eagerly to return credits */
 
 #define IBLND_CREDITS_DEFAULT     8 /* default # of peer credits */
-#define IBLND_CREDITS_MAX	  ((typeof(((struct kib_msg *) 0)->ibm_credits)) - 1)  /* Max # of peer credits */
+#define IBLND_CREDITS_MAX	  ((typeof(((struct kib_msg *)0)->ibm_credits)) - 1)  /* Max # of peer credits */
 
 /* when eagerly to return credits */
 #define IBLND_CREDITS_HIGHWATER(t, v)	((v) == IBLND_MSG_VERSION_1 ? \
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index adc346a..e32e43b 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1103,7 +1103,7 @@ kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 
 		wrknob = min(min(kiblnd_rd_frag_size(srcrd, srcidx),
 				 kiblnd_rd_frag_size(dstrd, dstidx)),
-			     (__u32) resid);
+			     (__u32)resid);
 
 		sge = &tx->tx_sge[tx->tx_nwrq];
 		sge->addr   = kiblnd_rd_frag_addr(srcrd, srcidx);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index d4e7dae..07ec540 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -475,7 +475,7 @@ ksocknal_add_peer(lnet_ni_t *ni, lnet_process_id_t id, __u32 ipaddr, int port)
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
 	/* always called with a ref on ni, so shutdown can't have started */
-	LASSERT(!((struct ksock_net *) ni->ni_data)->ksnn_shutdown);
+	LASSERT(!((struct ksock_net *)ni->ni_data)->ksnn_shutdown);
 
 	peer2 = ksocknal_find_peer_locked(ni, id);
 	if (peer2) {
@@ -1146,7 +1146,7 @@ ksocknal_create_conn(lnet_ni_t *ni, struct ksock_route *route,
 		write_lock_bh(global_lock);
 
 		/* called with a ref on ni, so shutdown can't have started */
-		LASSERT(!((struct ksock_net *) ni->ni_data)->ksnn_shutdown);
+		LASSERT(!((struct ksock_net *)ni->ni_data)->ksnn_shutdown);
 
 		peer2 = ksocknal_find_peer_locked(ni, peerid);
 		if (!peer2) {
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index e63d29b..303576d 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -126,7 +126,7 @@ ksocknal_send_iov(struct ksock_conn *conn, struct ksock_tx *tx)
 	do {
 		LASSERT(tx->tx_niov > 0);
 
-		if (nob < (int) iov->iov_len) {
+		if (nob < (int)iov->iov_len) {
 			iov->iov_base = (void *)((char *)iov->iov_base + nob);
 			iov->iov_len -= nob;
 			return rc;
@@ -326,7 +326,7 @@ ksocknal_recv_kiov(struct ksock_conn *conn)
 	do {
 		LASSERT(conn->ksnc_rx_nkiov > 0);
 
-		if (nob < (int) kiov->kiov_len) {
+		if (nob < (int)kiov->kiov_len) {
 			kiov->kiov_offset += nob;
 			kiov->kiov_len -= nob;
 			return -EAGAIN;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index e1bf910..82e174f 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -503,7 +503,7 @@ ksocknal_send_hello_v1(struct ksock_conn *conn, ksock_hello_msg_t *hello)
 	if (!hello->kshm_nips)
 		goto out;
 
-	for (i = 0; i < (int) hello->kshm_nips; i++)
+	for (i = 0; i < (int)hello->kshm_nips; i++)
 		hello->kshm_ips[i] = __cpu_to_le32(hello->kshm_ips[i]);
 
 	rc = lnet_sock_write(sock, hello->kshm_ips,
@@ -622,7 +622,7 @@ ksocknal_recv_hello_v1(struct ksock_conn *conn, ksock_hello_msg_t *hello,
 		goto out;
 	}
 
-	for (i = 0; i < (int) hello->kshm_nips; i++) {
+	for (i = 0; i < (int)hello->kshm_nips; i++) {
 		hello->kshm_ips[i] = __le32_to_cpu(hello->kshm_ips[i]);
 
 		if (!hello->kshm_ips[i]) {
@@ -690,7 +690,7 @@ ksocknal_recv_hello_v2(struct ksock_conn *conn, ksock_hello_msg_t *hello, int ti
 		return rc;
 	}
 
-	for (i = 0; i < (int) hello->kshm_nips; i++) {
+	for (i = 0; i < (int)hello->kshm_nips; i++) {
 		if (conn->ksnc_flip)
 			__swab32s(&hello->kshm_ips[i]);
 
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 48327ca..346db89 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1673,7 +1673,7 @@ lnet_fill_ni_info(struct lnet_ni *ni, struct lnet_ioctl_config_data *config)
 	if (!ni || !config)
 		return;
 
-	net_config = (struct lnet_ioctl_net_config *) config->cfg_bulk;
+	net_config = (struct lnet_ioctl_net_config *)config->cfg_bulk;
 	if (!net_config)
 		return;
 
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index 58cf246..4ffbd3e 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -196,7 +196,7 @@ static int __init lnet_init(void)
 		 * Have to schedule a separate thread to avoid deadlocking
 		 * in modload
 		 */
-		(void) kthread_run(lnet_configure, NULL, "lnet_initd");
+		(void)kthread_run(lnet_configure, NULL, "lnet_initd");
 	}
 
 	return 0;
diff --git a/drivers/staging/lustre/lustre/include/lustre_sec.h b/drivers/staging/lustre/lustre/include/lustre_sec.h
index ed4b4c7..90c1834 100644
--- a/drivers/staging/lustre/lustre/include/lustre_sec.h
+++ b/drivers/staging/lustre/lustre/include/lustre_sec.h
@@ -217,13 +217,13 @@ enum sptlrpc_bulk_service {
 
 #define SPTLRPC_FLVR_DEFAULT	    SPTLRPC_FLVR_NULL
 
-#define SPTLRPC_FLVR_INVALID	    ((__u32) 0xFFFFFFFF)
-#define SPTLRPC_FLVR_ANY		((__u32) 0xFFF00000)
+#define SPTLRPC_FLVR_INVALID	    ((__u32)0xFFFFFFFF)
+#define SPTLRPC_FLVR_ANY		((__u32)0xFFF00000)
 
 /**
  * extract the useful part from wire flavor
  */
-#define WIRE_FLVR(wflvr)		(((__u32) (wflvr)) & 0x000FFFFF)
+#define WIRE_FLVR(wflvr)		(((__u32)(wflvr)) & 0x000FFFFF)
 
 /** @} flavor */
 
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 4602596..b0c4548 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1413,7 +1413,7 @@ out_unlock:
 out:
 	return rc;
 out_req_free:
-	ptlrpc_req_finished((struct ptlrpc_request *) oit.d.lustre.it_data);
+	ptlrpc_req_finished((struct ptlrpc_request *)oit.d.lustre.it_data);
 	goto out;
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 6c09fb2..e623216 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -560,7 +560,7 @@ static int vvp_pgcache_show(struct seq_file *f, void *v)
 
 	env = cl_env_get(&refcheck);
 	if (!IS_ERR(env)) {
-		pos = *(loff_t *) v;
+		pos = *(loff_t *)v;
 		vvp_pgcache_id_unpack(pos, &id);
 		sbi = f->private;
 		clob = vvp_pgcache_obj(env, &sbi->ll_cl->cd_lu_dev, &id);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 12cb238..f371e1d 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1803,7 +1803,7 @@ static int mdc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	case IOC_OBD_STATFS: {
 		struct obd_statfs stat_buf = {0};
 
-		if (*((__u32 *) data->ioc_inlbuf2) != 0) {
+		if (*((__u32 *)data->ioc_inlbuf2) != 0) {
 			rc = -ENODEV;
 			goto out;
 		}
@@ -1997,7 +1997,7 @@ static int mdc_hsm_copytool_send(int len, void *val)
 
 	if (len < sizeof(*lh) + sizeof(*hal)) {
 		CERROR("Short HSM message %d < %d\n", len,
-		       (int) (sizeof(*lh) + sizeof(*hal)));
+		       (int)(sizeof(*lh) + sizeof(*hal)));
 		return -EPROTO;
 	}
 	if (lh->kuc_magic == __swab16(KUC_MAGIC)) {
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 69f5337..fbbf276 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1030,7 +1030,7 @@ static int mgc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 		rc = sptlrpc_parse_flavor(val, &flvr);
 		if (rc) {
 			CERROR("invalid sptlrpc flavor %s to MGS\n",
-			       (char *) val);
+			       (char *)val);
 			return rc;
 		}
 
@@ -1046,7 +1046,7 @@ static int mgc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 			sptlrpc_flavor2name(&cli->cl_flvr_mgc,
 					    str, sizeof(str));
 			LCONSOLE_ERROR("asking sptlrpc flavor %s to MGS but currently %s is in use\n",
-				       (char *) val, str);
+				       (char *)val, str);
 			rc = -EPERM;
 		}
 		return rc;
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 615158a..91a5806 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -573,7 +573,7 @@ static inline struct cl_env *cl_env_fetch(void)
 {
 	struct cl_env *cle;
 
-	cle = cfs_hash_lookup(cl_env_hash, (void *) (long) current->pid);
+	cle = cfs_hash_lookup(cl_env_hash, (void *)(long)current->pid);
 	LASSERT(ergo(cle, cle->ce_magic == &cl_env_init0));
 	return cle;
 }
@@ -584,7 +584,7 @@ static inline void cl_env_attach(struct cl_env *cle)
 		int rc;
 
 		LASSERT(!cle->ce_owner);
-		cle->ce_owner = (void *) (long) current->pid;
+		cle->ce_owner = (void *)(long)current->pid;
 		rc = cfs_hash_add_unique(cl_env_hash, cle->ce_owner,
 					 &cle->ce_node);
 		LASSERT(rc == 0);
@@ -595,7 +595,7 @@ static inline void cl_env_do_detach(struct cl_env *cle)
 {
 	void *cookie;
 
-	LASSERT(cle->ce_owner == (void *) (long) current->pid);
+	LASSERT(cle->ce_owner == (void *)(long)current->pid);
 	cookie = cfs_hash_del(cl_env_hash, cle->ce_owner,
 			      &cle->ce_node);
 	LASSERT(cookie == cle);
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index f1c41a1..0eab123 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1073,7 +1073,7 @@ int class_config_llog_handler(const struct lu_env *env,
 {
 	struct config_llog_instance *clli = data;
 	int cfg_len = rec->lrh_len;
-	char *cfg_buf = (char *) (rec + 1);
+	char *cfg_buf = (char *)(rec + 1);
 	int rc = 0;
 
 	switch (rec->lrh_type) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
index c444f51..d88faf6 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
@@ -769,7 +769,7 @@ static int nrs_policy_register(struct ptlrpc_nrs *nrs,
 	spin_unlock(&nrs->nrs_lock);
 
 	if (rc != 0)
-		(void) nrs_policy_unregister(nrs, policy->pol_desc->pd_name);
+		(void)nrs_policy_unregister(nrs, policy->pol_desc->pd_name);
 
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 7ab3ae9..f3b4773 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -1100,7 +1100,7 @@ int sptlrpc_cli_unwrap_early_reply(struct ptlrpc_request *req,
 	early_req->rq_flvr = req->rq_flvr;
 	early_req->rq_repbuf = early_buf;
 	early_req->rq_repbuf_len = early_bufsz;
-	early_req->rq_repdata = (struct lustre_msg *) early_buf;
+	early_req->rq_repdata = (struct lustre_msg *)early_buf;
 	early_req->rq_repdata_len = early_size;
 	early_req->rq_early = 1;
 	early_req->rq_reqmsg = req->rq_reqmsg;
@@ -1552,7 +1552,7 @@ void _sptlrpc_enlarge_msg_inplace(struct lustre_msg *msg,
 	/* move from segment + 1 to end segment */
 	LASSERT(msg->lm_magic == LUSTRE_MSG_MAGIC_V2);
 	oldmsg_size = lustre_msg_size_v2(msg->lm_bufcount, msg->lm_buflens);
-	movesize = oldmsg_size - ((unsigned long) src - (unsigned long) msg);
+	movesize = oldmsg_size - ((unsigned long)src - (unsigned long)msg);
 	LASSERT(movesize >= 0);
 
 	if (movesize)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index b3e3ed9..5f4d797 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -269,7 +269,7 @@ static unsigned long enc_pools_shrink_scan(struct shrinker *s,
 static inline
 int npages_to_npools(unsigned long npages)
 {
-	return (int) ((npages + PAGES_PER_POOL - 1) / PAGES_PER_POOL);
+	return (int)((npages + PAGES_PER_POOL - 1) / PAGES_PER_POOL);
 }
 
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
index 303bf96..1238c87 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
@@ -644,7 +644,7 @@ static int logname2fsname(const char *logname, char *buf, int buflen)
 		return -EINVAL;
 	}
 
-	len = min((int) (ptr - logname), buflen - 1);
+	len = min((int)(ptr - logname), buflen - 1);
 
 	memcpy(buf, logname, len);
 	buf[len] = '\0';
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
index 3306233..70a61e1 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
@@ -56,7 +56,7 @@ static struct ptlrpc_svc_ctx    null_svc_ctx;
 static inline
 void null_encode_sec_part(struct lustre_msg *msg, enum lustre_sec_part sp)
 {
-	msg->lm_secflvr |= (((__u32) sp) & 0xFF) << 24;
+	msg->lm_secflvr |= (((__u32)sp) & 0xFF) << 24;
 }
 
 static inline
@@ -326,7 +326,7 @@ int null_alloc_rs(struct ptlrpc_request *req, int msgsize)
 	rs->rs_svc_ctx = req->rq_svc_ctx;
 	atomic_inc(&req->rq_svc_ctx->sc_refcount);
 
-	rs->rs_repbuf = (struct lustre_msg *) (rs + 1);
+	rs->rs_repbuf = (struct lustre_msg *)(rs + 1);
 	rs->rs_repbuf_len = rs_size - sizeof(*rs);
 	rs->rs_msg = rs->rs_repbuf;
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
index ea79b15..5c4590b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
@@ -294,7 +294,7 @@ int plain_cli_wrap_bulk(struct ptlrpc_cli_ctx *ctx,
 	LASSERT(req->rq_reqbuf->lm_bufcount == PLAIN_PACK_SEGMENTS);
 
 	bsd = lustre_msg_buf(req->rq_reqbuf, PLAIN_PACK_BULK_OFF, 0);
-	token = (struct plain_bulk_token *) bsd->bsd_data;
+	token = (struct plain_bulk_token *)bsd->bsd_data;
 
 	bsd->bsd_version = 0;
 	bsd->bsd_flags = 0;
@@ -339,7 +339,7 @@ int plain_cli_unwrap_bulk(struct ptlrpc_cli_ctx *ctx,
 	LASSERT(req->rq_repdata->lm_bufcount == PLAIN_PACK_SEGMENTS);
 
 	bsdv = lustre_msg_buf(req->rq_repdata, PLAIN_PACK_BULK_OFF, 0);
-	tokenv = (struct plain_bulk_token *) bsdv->bsd_data;
+	tokenv = (struct plain_bulk_token *)bsdv->bsd_data;
 
 	if (req->rq_bulk_write) {
 		if (bsdv->bsd_flags & BSD_FL_ERR)
@@ -811,7 +811,7 @@ int plain_alloc_rs(struct ptlrpc_request *req, int msgsize)
 
 	rs->rs_svc_ctx = req->rq_svc_ctx;
 	atomic_inc(&req->rq_svc_ctx->sc_refcount);
-	rs->rs_repbuf = (struct lustre_msg *) (rs + 1);
+	rs->rs_repbuf = (struct lustre_msg *)(rs + 1);
 	rs->rs_repbuf_len = rs_size - sizeof(*rs);
 
 	lustre_init_msg_v2(rs->rs_repbuf, PLAIN_PACK_SEGMENTS, buflens, NULL);
@@ -891,7 +891,7 @@ int plain_svc_unwrap_bulk(struct ptlrpc_request *req,
 	LASSERT(req->rq_pack_bulk);
 
 	bsdr = lustre_msg_buf(req->rq_reqbuf, PLAIN_PACK_BULK_OFF, 0);
-	tokenr = (struct plain_bulk_token *) bsdr->bsd_data;
+	tokenr = (struct plain_bulk_token *)bsdr->bsd_data;
 	bsdv = lustre_msg_buf(rs->rs_repbuf, PLAIN_PACK_BULK_OFF, 0);
 
 	bsdv->bsd_version = 0;
@@ -926,7 +926,7 @@ int plain_svc_wrap_bulk(struct ptlrpc_request *req,
 
 	bsdr = lustre_msg_buf(req->rq_reqbuf, PLAIN_PACK_BULK_OFF, 0);
 	bsdv = lustre_msg_buf(rs->rs_repbuf, PLAIN_PACK_BULK_OFF, 0);
-	tokenv = (struct plain_bulk_token *) bsdv->bsd_data;
+	tokenv = (struct plain_bulk_token *)bsdv->bsd_data;
 
 	bsdv->bsd_version = 0;
 	bsdv->bsd_type = SPTLRPC_BULK_DEFAULT;
-- 
2.7.4
