From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:55 -0500
Subject: [lustre-devel] [PATCH 547/622] lnet: check if current->nsproxy is
 NULL before using
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-548-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sonia Sharma <sharmaso@whamcloud.com>

A crash is seen at few sites in the function
rdma_create_id(current->nsproxy->net_ns, cb, dev, ps, qpt).
The issue is identified with the first param in this
function - current->nsproxy->net_ns. There is a
possibility that this value is NULL and resulting in
"kernel NULL pointer dereference" crash.

Handle the case of NULL value gracefully by adding
a check and using init_net if current or
current->nsproxy is NULL.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11385
Lustre-commit: ef1783e282f6 ("LU-11385 lnet: check if current->nsproxy is NULL before using")
Signed-off-by: Sonia Sharma <sharmaso@whamcloud.com>
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34577
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.h | 6 +++---
 net/lnet/lnet/acceptor.c         | 7 ++++---
 net/lnet/lnet/config.c           | 9 ++++++---
 net/lnet/lnet/lib-move.c         | 4 ++--
 4 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index ac91757..2169fdd 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -108,9 +108,9 @@ struct kib_tunables {
 	 min((t)->lnd_peercredits_hiw,				\
 	     (u32)(conn)->ibc_queue_depth - 1))
 
-# define kiblnd_rdma_create_id(ns, cb, dev, ps, qpt) rdma_create_id(ns, cb, \
-								    dev, ps, \
-								    qpt)
+# define kiblnd_rdma_create_id(ns, cb, dev, ps, qpt) \
+	 rdma_create_id((ns) ? (ns) : &init_net, cb, dev, ps, qpt)
+
 /* 2 OOB shall suffice for 1 keepalive and 1 returning credits */
 #define IBLND_OOB_CAPABLE(v)	((v) != IBLND_MSG_VERSION_1)
 #define IBLND_OOB_MSGS(v)	(IBLND_OOB_CAPABLE(v) ? 2 : 0)
diff --git a/net/lnet/lnet/acceptor.c b/net/lnet/lnet/acceptor.c
index 23b5bf0..acd1d75 100644
--- a/net/lnet/lnet/acceptor.c
+++ b/net/lnet/lnet/acceptor.c
@@ -458,14 +458,15 @@
 
 	if (!lnet_count_acceptor_nets())  /* not required */
 		return 0;
-
-	lnet_acceptor_state.pta_ns = current->nsproxy->net_ns;
+	if (current->nsproxy && current->nsproxy->net_ns)
+		lnet_acceptor_state.pta_ns = current->nsproxy->net_ns;
+	else
+		lnet_acceptor_state.pta_ns = &init_net;
 	task = kthread_run(lnet_acceptor, (void *)(uintptr_t)secure,
 			   "acceptor_%03ld", secure);
 	if (IS_ERR(task)) {
 		rc2 = PTR_ERR(task);
 		CERROR("Can't start acceptor thread: %ld\n", rc2);
-
 		return -ESRCH;
 	}
 
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index 2c8edcd..f521b0b 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -464,10 +464,10 @@ struct lnet_net *
 	ni->ni_nid = LNET_MKNID(net->net_id, 0);
 
 	/* Store net namespace in which current ni is being created */
-	if (current->nsproxy->net_ns)
+	if (current->nsproxy && current->nsproxy->net_ns)
 		ni->ni_net_ns = get_net(current->nsproxy->net_ns);
 	else
-		ni->ni_net_ns = NULL;
+		ni->ni_net_ns = get_net(&init_net);
 
 	ni->ni_state = LNET_NI_STATE_INIT;
 	list_add_tail(&ni->ni_netlist, &net->net_ni_added);
@@ -1642,7 +1642,10 @@ int lnet_inet_enumerate(struct lnet_inetdev **dev_list, struct net *ns)
 	int rc;
 	int i;
 
-	nip = lnet_inet_enumerate(&ifaces, current->nsproxy->net_ns);
+	if (current->nsproxy && current->nsproxy->net_ns)
+		nip = lnet_inet_enumerate(&ifaces, current->nsproxy->net_ns);
+	else
+		nip = lnet_inet_enumerate(&ifaces, &init_net);
 	if (nip < 0) {
 		if (nip != -ENOENT) {
 			LCONSOLE_ERROR_MSG(0x117,
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index b8278ad..ca0009c 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -4826,9 +4826,9 @@ struct lnet_msg *
 			 * If not, assign order above 0xffff0000,
 			 * to make this ni not a priority.
 			 */
-			if (!net_eq(ni->ni_net_ns, current->nsproxy->net_ns))
+			if (current->nsproxy &&
+			    !net_eq(ni->ni_net_ns, current->nsproxy->net_ns))
 				order += 0xffff0000;
-
 			if (srcnidp)
 				*srcnidp = ni->ni_nid;
 			if (orderp)
-- 
1.8.3.1
