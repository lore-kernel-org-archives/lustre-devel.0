From: James Simmons <jsimmons@infradead.org>
Date: Fri, 12 Feb 2016 12:06:07 -0500
Subject: [lustre-devel] [PATCH 09/11] staging: lustre: balance braces
	properly in LNet layer
In-Reply-To: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
References: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1455296769-5481-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Dorkin <oleg.dorkin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Properly balance the braces done wrong as reported by
checkpatch.pl.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    3 ++-
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |    3 ++-
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |    3 +--
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |    4 ++--
 drivers/staging/lustre/lnet/lnet/router_proc.c     |    8 ++++----
 drivers/staging/lustre/lnet/selftest/console.c     |    6 ++----
 drivers/staging/lustre/lnet/selftest/selftest.h    |    5 ++---
 7 files changed, 15 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 14938c3..d9c7089 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -951,8 +951,9 @@ kiblnd_check_sends(kib_conn_t *conn)
 			credit = 1;
 			tx = list_entry(conn->ibc_tx_queue.next,
 					kib_tx_t, tx_list);
-		} else
+		} else {
 			break;
+		}
 
 		if (kiblnd_post_tx_locked(conn, tx, credit) != 0)
 			break;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index 37df8a9..db5662b 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -609,8 +609,9 @@ ksocknal_data_ready(struct sock *sk)
 	if (conn == NULL) {	     /* raced with ksocknal_terminate_conn */
 		LASSERT(sk->sk_data_ready != &ksocknal_data_ready);
 		sk->sk_data_ready(sk);
-	} else
+	} else {
 		ksocknal_read_callback(conn);
+	}
 
 	read_unlock(&ksocknal_data.ksnd_global_lock);
 }
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index f84d1ae..041f972 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -507,9 +507,8 @@ ksocknal_send_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello)
 	if (hello->kshm_nips == 0)
 		goto out;
 
-	for (i = 0; i < (int) hello->kshm_nips; i++) {
+	for (i = 0; i < (int) hello->kshm_nips; i++)
 		hello->kshm_ips[i] = __cpu_to_le32(hello->kshm_ips[i]);
-	}
 
 	rc = lnet_sock_write(sock, hello->kshm_ips,
 			     hello->kshm_nips * sizeof(__u32),
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index 449efc7..d7c9836 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -1139,9 +1139,9 @@ libcfs_nid2str_r(lnet_nid_t nid, char *buf, size_t buf_size)
 	}
 
 	nf = libcfs_lnd2netstrfns(lnd);
-	if (nf == NULL)
+	if (nf == NULL) {
 		snprintf(buf, buf_size, "%x@<%u:%u>", addr, lnd, nnum);
-	else {
+	} else {
 		size_t addr_len;
 
 		nf->nf_addr2str(addr, buf, buf_size);
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 4a5067c..124737e 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -262,9 +262,9 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 	if (len > *lenp) {    /* linux-supplied buffer is too small */
 		rc = -EINVAL;
 	} else if (len > 0) { /* wrote something */
-		if (copy_to_user(buffer, tmpstr, len))
+		if (copy_to_user(buffer, tmpstr, len)) {
 			rc = -EFAULT;
-		else {
+		} else {
 			off += 1;
 			*ppos = LNET_PROC_POS_MAKE(0, ver, 0, off);
 		}
@@ -399,9 +399,9 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 	if (len > *lenp) {    /* linux-supplied buffer is too small */
 		rc = -EINVAL;
 	} else if (len > 0) { /* wrote something */
-		if (copy_to_user(buffer, tmpstr, len))
+		if (copy_to_user(buffer, tmpstr, len)) {
 			rc = -EFAULT;
-		else {
+		} else {
 			off += 1;
 			*ppos = LNET_PROC_POS_MAKE(0, ver, 0, off);
 		}
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index ab0a3f7..914d842 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -254,9 +254,8 @@ lstcon_group_decref(lstcon_group_t *grp)
 
 	lstcon_group_drain(grp, 0);
 
-	for (i = 0; i < LST_NODE_HASHSIZE; i++) {
+	for (i = 0; i < LST_NODE_HASHSIZE; i++)
 		LASSERT(list_empty(&grp->grp_ndl_hash[i]));
-	}
 
 	LIBCFS_FREE(grp, offsetof(lstcon_group_t,
 				  grp_ndl_hash[LST_NODE_HASHSIZE]));
@@ -2084,9 +2083,8 @@ lstcon_console_fini(void)
 	LASSERT(list_empty(&console_session.ses_bat_list));
 	LASSERT(list_empty(&console_session.ses_trans_list));
 
-	for (i = 0; i < LST_NODE_HASHSIZE; i++) {
+	for (i = 0; i < LST_NODE_HASHSIZE; i++)
 		LASSERT(list_empty(&console_session.ses_ndl_hash[i]));
-	}
 
 	LIBCFS_FREE(console_session.ses_ndl_hash,
 		    sizeof(struct list_head) * LST_GLOBAL_HASHSIZE);
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 5c299d6..906e26a 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -508,11 +508,10 @@ srpc_destroy_client_rpc(srpc_client_rpc_t *rpc)
 	LASSERT(!srpc_event_pending(rpc));
 	LASSERT(atomic_read(&rpc->crpc_refcount) == 0);
 
-	if (rpc->crpc_fini == NULL) {
+	if (rpc->crpc_fini == NULL)
 		LIBCFS_FREE(rpc, srpc_client_rpc_size(rpc));
-	} else {
+	else
 		(*rpc->crpc_fini) (rpc);
-	}
 
 	return;
 }
-- 
1.7.1
