From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:23 -0500
Subject: [lustre-devel] [PATCH 095/622] lnet: print recovery queues content
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-96-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Add commands to lnetctl to print recovery queues content from
user space.

Associated code to handle the IOCTL added in LNet module.

for local NIs:
lnetctl debug recovery --local

for peer NIs:
lnetctl debug recovery --peer

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: 826ea19c077b ("LU-9120 lnet: print recovery queues content")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32950
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lnet/libcfs_ioctl.h |  3 +-
 include/uapi/linux/lnet/lnet-dlc.h     |  8 +++++
 net/lnet/lnet/api-ni.c                 | 53 ++++++++++++++++++++++++++++++++++
 3 files changed, 63 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/lnet/libcfs_ioctl.h b/include/uapi/linux/lnet/libcfs_ioctl.h
index 683d508..dfb73f7 100644
--- a/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -150,6 +150,7 @@ struct libcfs_debug_ioctl_data {
 #define IOC_LIBCFS_GET_LOCAL_NI_MSG_STATS  _IOWR(IOC_LIBCFS_TYPE, 101, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_SET_HEALHV		_IOWR(IOC_LIBCFS_TYPE, 102, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_GET_LOCAL_HSTATS	_IOWR(IOC_LIBCFS_TYPE, 103, IOCTL_CONFIG_SIZE)
-#define IOC_LIBCFS_MAX_NR		103
+#define IOC_LIBCFS_GET_RECOVERY_QUEUE	_IOWR(IOC_LIBCFS_TYPE, 104, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_MAX_NR		104
 
 #endif /* __LIBCFS_IOCTL_H__ */
diff --git a/include/uapi/linux/lnet/lnet-dlc.h b/include/uapi/linux/lnet/lnet-dlc.h
index 8e9850c..87f7680 100644
--- a/include/uapi/linux/lnet/lnet-dlc.h
+++ b/include/uapi/linux/lnet/lnet-dlc.h
@@ -35,6 +35,7 @@
 #define MAX_NUM_SHOW_ENTRIES	32
 #define LNET_MAX_STR_LEN	128
 #define LNET_MAX_SHOW_NUM_CPT	128
+#define LNET_MAX_SHOW_NUM_NID	128
 #define LNET_UNDEFINED_HOPS	((__u32)(-1))
 
 /*
@@ -263,6 +264,13 @@ struct lnet_ioctl_reset_health_cfg {
 	lnet_nid_t rh_nid;
 };
 
+struct lnet_ioctl_recovery_list {
+	struct libcfs_ioctl_hdr rlst_hdr;
+	enum lnet_health_type rlst_type;
+	int rlst_num_nids;
+	lnet_nid_t rlst_nid_array[LNET_MAX_SHOW_NUM_NID];
+};
+
 struct lnet_ioctl_set_value {
 	struct libcfs_ioctl_hdr sv_hdr;
 	__u32 sv_value;
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index d58006d..07bc29f 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -3232,6 +3232,44 @@ u32 lnet_get_dlc_seq_locked(void)
 	return rc;
 }
 
+static int
+lnet_get_local_ni_recovery_list(struct lnet_ioctl_recovery_list *list)
+{
+	struct lnet_ni *ni;
+	int i = 0;
+
+	lnet_net_lock(LNET_LOCK_EX);
+	list_for_each_entry(ni, &the_lnet.ln_mt_localNIRecovq, ni_recovery) {
+		list->rlst_nid_array[i] = ni->ni_nid;
+		i++;
+		if (i >= LNET_MAX_SHOW_NUM_NID)
+			break;
+	}
+	lnet_net_unlock(LNET_LOCK_EX);
+	list->rlst_num_nids = i;
+
+	return 0;
+}
+
+static int
+lnet_get_peer_ni_recovery_list(struct lnet_ioctl_recovery_list *list)
+{
+	struct lnet_peer_ni *lpni;
+	int i = 0;
+
+	lnet_net_lock(LNET_LOCK_EX);
+	list_for_each_entry(lpni, &the_lnet.ln_mt_peerNIRecovq, lpni_recovery) {
+		list->rlst_nid_array[i] = lpni->lpni_nid;
+		i++;
+		if (i >= LNET_MAX_SHOW_NUM_NID)
+			break;
+	}
+	lnet_net_unlock(LNET_LOCK_EX);
+	list->rlst_num_nids = i;
+
+	return 0;
+}
+
 /**
  * LNet ioctl handler.
  *
@@ -3452,6 +3490,21 @@ u32 lnet_get_dlc_seq_locked(void)
 		return rc;
 	}
 
+	case IOC_LIBCFS_GET_RECOVERY_QUEUE: {
+		struct lnet_ioctl_recovery_list *list = arg;
+
+		if (list->rlst_hdr.ioc_len < sizeof(*list))
+			return -EINVAL;
+
+		mutex_lock(&the_lnet.ln_api_mutex);
+		if (list->rlst_type == LNET_HEALTH_TYPE_LOCAL_NI)
+			rc = lnet_get_local_ni_recovery_list(list);
+		else
+			rc = lnet_get_peer_ni_recovery_list(list);
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return rc;
+	}
+
 	case IOC_LIBCFS_ADD_PEER_NI: {
 		struct lnet_ioctl_peer_cfg *cfg = arg;
 
-- 
1.8.3.1
