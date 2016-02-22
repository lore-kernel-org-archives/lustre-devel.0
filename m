From: James Simmons <jsimmons@infradead.org>
Date: Mon, 22 Feb 2016 17:29:13 -0500
Subject: [lustre-devel] [PATCH 12/24] staging: lustre: reject invalid net
	configuration for lnet
In-Reply-To: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
References: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456180165-1105-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>

From: Amir Shehata <amir.shehata@intel.com>

Currently if there exists a route that goes over a
remote net and then this net is added dynamically as
a local net, then traffic stops because the code in
lnet_send() determines that the destination nid
can be reached from another local_ni, but the src_nid
is still stuck on the earlier NI, because the src_nid
is stored in the ptlrpc layer and is not updated
when a local NI is configured.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5874
Reviewed-on: http://review.whamcloud.com/12912
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 9497ce1..62a9e45 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1756,6 +1756,7 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, char *nets,
 	lnet_handle_md_t md_handle;
 	struct lnet_ni *ni;
 	struct list_head net_head;
+	lnet_remotenet_t *rnet;
 	int rc;
 
 	INIT_LIST_HEAD(&net_head);
@@ -1772,12 +1773,27 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, char *nets,
 		goto failed0;
 	}
 
+	ni = list_entry(net_head.next, struct lnet_ni, ni_list);
+
+	lnet_net_lock(LNET_LOCK_EX);
+	rnet = lnet_find_net_locked(LNET_NIDNET(ni->ni_nid));
+	lnet_net_unlock(LNET_LOCK_EX);
+	/*
+	 * make sure that the net added doesn't invalidate the current
+	 * configuration LNet is keeping
+	 */
+	if (rnet) {
+		CERROR("Adding net %s will invalidate routing configuration\n",
+		       nets);
+		rc = -EUSERS;
+		goto failed0;
+	}
+
 	rc = lnet_ping_info_setup(&pinfo, &md_handle, 1 + lnet_get_ni_count(),
 				  false);
 	if (rc)
 		goto failed0;
 
-	ni = list_entry(net_head.next, struct lnet_ni, ni_list);
 	list_del_init(&ni->ni_list);
 
 	rc = lnet_startup_lndni(ni, peer_timeout, peer_cr,
-- 
1.7.1
