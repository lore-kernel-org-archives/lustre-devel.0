From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:05:58 -0400
Subject: [lustre-devel] [PATCH 19/42] lnet: Support checking for MD leaks.
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

Since we dropped the refcounting on LNetEQ we no longer get
confirmation that all MDs for a given handler a gone by the
time they should be.

So add lnet_assert_handler_unused() which searches the per-cpt
containers and ensures there are no MDs for a given handler, and call
that are the same place that we used to call LNetEQFree().

WC-bug-id: https://jira.whamcloud.com/browse/LU-13005
Lustre-commit: b7278ecc699b5 ("LU-13005 lnet: Support checking for MD leaks.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/38059
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/events.c |  1 +
 include/linux/lnet/api.h  |  2 ++
 net/lnet/lnet/api-ni.c    |  3 +++
 net/lnet/lnet/lib-md.c    | 19 +++++++++++++++++++
 net/lnet/lnet/peer.c      |  1 +
 net/lnet/selftest/rpc.c   |  1 +
 6 files changed, 27 insertions(+)

diff --git a/fs/lustre/ptlrpc/events.c b/fs/lustre/ptlrpc/events.c
index eef40b3..0943612 100644
--- a/fs/lustre/ptlrpc/events.c
+++ b/fs/lustre/ptlrpc/events.c
@@ -517,6 +517,7 @@ static void ptlrpc_ni_fini(void)
 	percpu_ref_kill(&ptlrpc_pending);
 	wait_for_completion(&ptlrpc_done);
 
+	lnet_assert_handler_unused(ptlrpc_handler);
 	LNetNIFini();
 }
 
diff --git a/include/linux/lnet/api.h b/include/linux/lnet/api.h
index 95805de..064c92e 100644
--- a/include/linux/lnet/api.h
+++ b/include/linux/lnet/api.h
@@ -126,6 +126,8 @@ int LNetMDBind(const struct lnet_md *md_in,
 	       struct lnet_handle_md *md_handle_out);
 
 int LNetMDUnlink(struct lnet_handle_md md_in);
+
+void lnet_assert_handler_unused(lnet_handler_t handler);
 /** @} lnet_md */
 
 /** \defgroup lnet_data Data movement operations
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index c90ab2e..0f325ec 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1231,6 +1231,7 @@ struct list_head **
 		the_lnet.ln_mt_zombie_rstqs = NULL;
 	}
 
+	lnet_assert_handler_unused(the_lnet.ln_mt_handler);
 	the_lnet.ln_mt_handler = NULL;
 
 	lnet_portals_destroy();
@@ -1795,6 +1796,7 @@ struct lnet_ping_buffer *
 	lnet_ping_md_unlink(the_lnet.ln_ping_target,
 			    &the_lnet.ln_ping_target_md);
 
+	lnet_assert_handler_unused(the_lnet.ln_ping_target_handler);
 	lnet_ping_target_destroy();
 }
 
@@ -1969,6 +1971,7 @@ static void lnet_push_target_fini(void)
 	the_lnet.ln_push_target_nnis = 0;
 
 	LNetClearLazyPortal(LNET_RESERVED_PORTAL);
+	lnet_assert_handler_unused(the_lnet.ln_push_target_handler);
 	the_lnet.ln_push_target_handler = NULL;
 }
 
diff --git a/net/lnet/lnet/lib-md.c b/net/lnet/lnet/lib-md.c
index e2c3e90..203c794 100644
--- a/net/lnet/lnet/lib-md.c
+++ b/net/lnet/lnet/lib-md.c
@@ -262,6 +262,25 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 	list_add(&md->md_list, &container->rec_active);
 }
 
+void lnet_assert_handler_unused(lnet_handler_t handler)
+{
+	struct lnet_res_container *container;
+	int cpt;
+
+	if (!handler)
+		return;
+
+	cfs_percpt_for_each(container, cpt, the_lnet.ln_md_containers) {
+		struct lnet_libmd *md;
+
+		lnet_res_lock(cpt);
+		list_for_each_entry(md, &container->rec_active, md_list)
+			LASSERT(md->md_handler != handler);
+		lnet_res_unlock(cpt);
+	}
+}
+EXPORT_SYMBOL(lnet_assert_handler_unused);
+
 /* must be called with lnet_res_lock held */
 void
 lnet_md_deconstruct(struct lnet_libmd *lmd, struct lnet_event *ev)
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 5ca6f68..3889310 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -3473,6 +3473,7 @@ static int lnet_peer_discovery(void *arg)
 	}
 	lnet_net_unlock(LNET_LOCK_EX);
 
+	lnet_assert_handler_unused(the_lnet.ln_dc_handler);
 	the_lnet.ln_dc_handler = NULL;
 
 	the_lnet.ln_dc_state = LNET_DC_STATE_SHUTDOWN;
diff --git a/net/lnet/selftest/rpc.c b/net/lnet/selftest/rpc.c
index a72e485..d012930 100644
--- a/net/lnet/selftest/rpc.c
+++ b/net/lnet/selftest/rpc.c
@@ -1672,6 +1672,7 @@ struct srpc_client_rpc *
 		rc = LNetClearLazyPortal(SRPC_FRAMEWORK_REQUEST_PORTAL);
 		rc = LNetClearLazyPortal(SRPC_REQUEST_PORTAL);
 		LASSERT(!rc);
+		lnet_assert_handler_unused(srpc_data.rpc_lnet_handler);
 		/* fall through */
 	case SRPC_STATE_NI_INIT:
 		LNetNIFini();
-- 
1.8.3.1
