From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:35:54 -0500
Subject: [lustre-devel] [PATCH 18/40] staging: lustre: remove LUSTRE_{,
	SRV_}LNET_PID
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: John L. Hammond <john.hammond@intel.com>

Remove LUSTRE_LNET_PID (12354) and LUSTRE_SRV_LNET_PID (12345) from
the libcfs headers and replace their uses with a new macro
LNET_PID_LUSTRE (also 12345) in lnet/types.h.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/11985
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    2 --
 .../lustre/include/linux/libcfs/linux/libcfs.h     |    3 ---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    7 +++++--
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    2 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    2 +-
 drivers/staging/lustre/lnet/lnet/module.c          |    4 ++--
 drivers/staging/lustre/lnet/lnet/router.c          |    2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/events.c      |    4 ++--
 9 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 4d74e8a..1cca6c7 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -58,8 +58,6 @@ static inline int __is_po2(unsigned long long val)
 #define LERRCHKSUM(hexnum) (((hexnum) & 0xf) ^ ((hexnum) >> 4 & 0xf) ^ \
 			   ((hexnum) >> 8 & 0xf))
 
-#define LUSTRE_SRV_LNET_PID      LUSTRE_LNET_PID
-
 #include <linux/list.h>
 
 /* need both kernel and user-land acceptor */
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
index aac5900..d94b266 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
@@ -118,9 +118,6 @@ do {								    \
 #define CDEBUG_STACK() (0L)
 #endif /* __x86_64__ */
 
-/* initial pid  */
-#define LUSTRE_LNET_PID	  12345
-
 #define __current_nesting_level() (0)
 
 /**
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index ebde036..6b88902 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -1788,7 +1788,10 @@ ksocknal_query(lnet_ni_t *ni, lnet_nid_t nid, unsigned long *when)
 	unsigned long now = cfs_time_current();
 	ksock_peer_t *peer = NULL;
 	rwlock_t *glock = &ksocknal_data.ksnd_global_lock;
-	lnet_process_id_t id = {.nid = nid, .pid = LUSTRE_SRV_LNET_PID};
+	lnet_process_id_t id = {
+		.nid = nid,
+		.pid = LNET_PID_LUSTRE,
+	};
 
 	read_lock(glock);
 
@@ -2136,7 +2139,7 @@ ksocknal_ctl(lnet_ni_t *ni, unsigned int cmd, void *arg)
 
 	case IOC_LIBCFS_ADD_PEER:
 		id.nid = data->ioc_nid;
-		id.pid = LUSTRE_SRV_LNET_PID;
+		id.pid = LNET_PID_LUSTRE;
 		return ksocknal_add_peer(ni, id,
 					  data->ioc_u32[0], /* IP */
 					  data->ioc_u32[1]); /* port */
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index acc216e..949fa2f 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -2114,7 +2114,7 @@ lnet_ping(lnet_process_id_t id, int timeout_ms, lnet_process_id_t __user *ids,
 		return -EINVAL;
 
 	if (id.pid == LNET_PID_ANY)
-		id.pid = LUSTRE_SRV_LNET_PID;
+		id.pid = LNET_PID_LUSTRE;
 
 	LIBCFS_ALLOC(info, infosz);
 	if (info == NULL)
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index e1461af..b9388ed 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1388,7 +1388,7 @@ lnet_send(lnet_nid_t src_nid, lnet_msg_t *msg, lnet_nid_t rtr_nid)
 
 		msg->msg_target_is_router = 1;
 		msg->msg_target.nid = lp->lp_nid;
-		msg->msg_target.pid = LUSTRE_SRV_LNET_PID;
+		msg->msg_target.pid = LNET_PID_LUSTRE;
 	}
 
 	/* 'lp' is our best choice of peer */
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index 281315c..48eb085 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -53,7 +53,7 @@ lnet_configure(void *arg)
 	mutex_lock(&lnet_config_mutex);
 
 	if (!the_lnet.ln_niinit_self) {
-		rc = LNetNIInit(LUSTRE_SRV_LNET_PID);
+		rc = LNetNIInit(LNET_PID_LUSTRE);
 		if (rc >= 0) {
 			the_lnet.ln_niinit_self = 1;
 			rc = 0;
@@ -93,7 +93,7 @@ lnet_dyn_configure(struct libcfs_ioctl_hdr *hdr)
 
 	mutex_lock(&lnet_config_mutex);
 	if (the_lnet.ln_niinit_self)
-		rc = lnet_dyn_add_ni(LUSTRE_SRV_LNET_PID,
+		rc = lnet_dyn_add_ni(LNET_PID_LUSTRE,
 				     conf->cfg_config_u.cfg_net.net_intf,
 				     conf->cfg_config_u.cfg_net.
 					net_peer_timeout,
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 17e6795..1f5a4b1 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1009,7 +1009,7 @@ lnet_ping_router_locked(lnet_peer_t *rtr)
 		lnet_handle_md_t mdh;
 
 		id.nid = rtr->lp_nid;
-		id.pid = LUSTRE_SRV_LNET_PID;
+		id.pid = LNET_PID_LUSTRE;
 		CDEBUG(D_NET, "Check: %s\n", libcfs_id2str(id));
 
 		rtr->lp_ping_notsent   = 1;
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 86de680..2212199 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -1587,7 +1587,7 @@ srpc_startup(void)
 
 	srpc_data.rpc_state = SRPC_STATE_NONE;
 
-	rc = LNetNIInit(LUSTRE_SRV_LNET_PID);
+	rc = LNetNIInit(LNET_PID_LUSTRE);
 	if (rc < 0) {
 		CERROR("LNetNIInit() has failed: %d\n", rc);
 		return rc;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index 9c2fd34..2a0dfa5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -446,7 +446,7 @@ int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
 
 	portals_compatibility = LNetCtl(IOC_LIBCFS_PORTALS_COMPATIBILITY, NULL);
 
-	peer->pid = LUSTRE_SRV_LNET_PID;
+	peer->pid = LNET_PID_LUSTRE;
 
 	/* Choose the matching UUID that's closest */
 	while (lustre_uuid_to_peer(uuid->uuid, &dst_nid, count++) == 0) {
@@ -524,7 +524,7 @@ static lnet_pid_t ptl_get_pid(void)
 {
 	lnet_pid_t pid;
 
-	pid = LUSTRE_SRV_LNET_PID;
+	pid = LNET_PID_LUSTRE;
 	return pid;
 }
 
-- 
1.7.1
