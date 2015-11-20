From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:36:09 -0500
Subject: [lustre-devel] [PATCH 33/40] staging: lustre: remove messages from
	lazy portal on NI shutdown
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-34-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

When shutting down an NI in a busy system, some messages received
on this NI, might be on the lazy portal.  They would have grabbed
a ref count on the NI.  Therefore NI will not be removed until
messages are processed.

In order to avoid this scenario, when an NI is shutdown go through
all messages queued on the lazy portal and drop messages for the
NI being shutdown

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6040
Reviewed-on: http://review.whamcloud.com/13836
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    1 +
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    6 ++
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |   54 +++++++++++++-------
 3 files changed, 43 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 00ef4d0..6dce2c9 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -480,6 +480,7 @@ int lnet_dyn_add_ni(lnet_pid_t requested_pid, char *nets,
 		    __s32 peer_timeout, __s32 peer_cr, __s32 peer_buf_cr,
 		    __s32 credits);
 int lnet_dyn_del_ni(__u32 net);
+int lnet_clear_lazy_portal(struct lnet_ni *ni, int portal, char *reason);
 
 int lnet_islocalnid(lnet_nid_t nid);
 int lnet_islocalnet(__u32 net);
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index e78b079..34f8c1b 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1190,10 +1190,16 @@ lnet_shutdown_lndnis(void)
 static void
 lnet_shutdown_lndni(struct lnet_ni *ni)
 {
+	int i;
+
 	lnet_net_lock(LNET_LOCK_EX);
 	lnet_ni_unlink_locked(ni);
 	lnet_net_unlock(LNET_LOCK_EX);
 
+	/* clear messages for this NI on the lazy portal */
+	for (i = 0; i < the_lnet.ln_nportals; i++)
+		lnet_clear_lazy_portal(ni, i, "Shutting down NI");
+
 	/* Do peer table cleanup for this ni */
 	lnet_peer_tables_cleanup(ni);
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index b4f573a..93bc3dc 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -886,17 +886,8 @@ LNetSetLazyPortal(int portal)
 }
 EXPORT_SYMBOL(LNetSetLazyPortal);
 
-/**
- * Turn off the lazy portal attribute. Delayed requests on the portal,
- * if any, will be all dropped when this function returns.
- *
- * \param portal Index of the portal to disable the lazy attribute on.
- *
- * \retval 0       On success.
- * \retval -EINVAL If \a portal is not a valid index.
- */
 int
-LNetClearLazyPortal(int portal)
+lnet_clear_lazy_portal(struct lnet_ni *ni, int portal, char *reason)
 {
 	struct lnet_portal *ptl;
 	LIST_HEAD(zombies);
@@ -915,21 +906,48 @@ LNetClearLazyPortal(int portal)
 		return 0;
 	}
 
-	if (the_lnet.ln_shutdown)
-		CWARN("Active lazy portal %d on exit\n", portal);
-	else
-		CDEBUG(D_NET, "clearing portal %d lazy\n", portal);
+	if (ni) {
+		struct lnet_msg *msg, *tmp;
 
-	/* grab all the blocked messages atomically */
-	list_splice_init(&ptl->ptl_msg_delayed, &zombies);
+		/* grab all messages which are on the NI passed in */
+		list_for_each_entry_safe(msg, tmp, &ptl->ptl_msg_delayed,
+					 msg_list) {
+			if (msg->msg_rxpeer->lp_ni == ni)
+				list_move(&msg->msg_list, &zombies);
+		}
+	} else {
+		if (the_lnet.ln_shutdown)
+			CWARN("Active lazy portal %d on exit\n", portal);
+		else
+			CDEBUG(D_NET, "clearing portal %d lazy\n", portal);
+
+		/* grab all the blocked messages atomically */
+		list_splice_init(&ptl->ptl_msg_delayed, &zombies);
 
-	lnet_ptl_unsetopt(ptl, LNET_PTL_LAZY);
+		lnet_ptl_unsetopt(ptl, LNET_PTL_LAZY);
+	}
 
 	lnet_ptl_unlock(ptl);
 	lnet_res_unlock(LNET_LOCK_EX);
 
-	lnet_drop_delayed_msg_list(&zombies, "Clearing lazy portal attr");
+	lnet_drop_delayed_msg_list(&zombies, reason);
 
 	return 0;
 }
+
+/**
+ * Turn off the lazy portal attribute. Delayed requests on the portal,
+ * if any, will be all dropped when this function returns.
+ *
+ * \param portal Index of the portal to disable the lazy attribute on.
+ *
+ * \retval 0       On success.
+ * \retval -EINVAL If \a portal is not a valid index.
+ */
+int
+LNetClearLazyPortal(int portal)
+{
+	return lnet_clear_lazy_portal(NULL, portal,
+				      "Clearing lazy portal attr");
+}
 EXPORT_SYMBOL(LNetClearLazyPortal);
-- 
1.7.1
