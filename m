From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:35:48 -0500
Subject: [lustre-devel] [PATCH 12/40] staging: lustre: Dynamic LNet
	Configuration (DLC) IOCTL changes
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

This is the fourth patch of a set of patches that enables DLC.

This patch changes the IOCTL infrastructure in preparation of
adding extra IOCTL communication between user and kernel space.
The changes include:
- adding a common header to be passed to ioctl infra functions
  instead of passing an exact structure.  This header is meant
  to be included in all structures to be passed through that
  interface.  The IOCTL handler casts this header to a particular
  type that it expects
- All sanity testing on the past in structure is performed in the
  generic ioctl infrastructure code.
- All ioctl handlers changed to take the header instead of a
  particular structure type

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2456
Change-Id: I144706a14293637cd5f381d2c020faa0e9c21f6b
Reviewed-on: http://review.whamcloud.com/8021
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |   29 +++++----
 drivers/staging/lustre/lnet/lnet/module.c          |    4 +-
 drivers/staging/lustre/lnet/selftest/conctl.c      |    9 ++-
 drivers/staging/lustre/lnet/selftest/console.c     |    2 +-
 drivers/staging/lustre/lnet/selftest/console.h     |    1 -
 .../lustre/lustre/libcfs/linux/linux-module.c      |   60 +++++++++----------
 drivers/staging/lustre/lustre/libcfs/module.c      |   50 ++++++++++++----
 7 files changed, 91 insertions(+), 64 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
index 485ab26..e14788c 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
@@ -43,9 +43,13 @@
 
 #define LIBCFS_IOCTL_VERSION 0x0001000a
 
-struct libcfs_ioctl_data {
+struct libcfs_ioctl_hdr {
 	__u32 ioc_len;
 	__u32 ioc_version;
+};
+
+struct libcfs_ioctl_data {
+	struct libcfs_ioctl_hdr ioc_hdr;
 
 	__u64 ioc_nid;
 	__u64 ioc_u64[1];
@@ -70,11 +74,6 @@ struct libcfs_ioctl_data {
 
 #define ioc_priority ioc_u32[0]
 
-struct libcfs_ioctl_hdr {
-	__u32 ioc_len;
-	__u32 ioc_version;
-};
-
 struct libcfs_debug_ioctl_data {
 	struct libcfs_ioctl_hdr hdr;
 	unsigned int subs;
@@ -84,13 +83,13 @@ struct libcfs_debug_ioctl_data {
 #define LIBCFS_IOC_INIT(data)			   \
 do {						    \
 	memset(&data, 0, sizeof(data));		 \
-	data.ioc_version = LIBCFS_IOCTL_VERSION;	\
-	data.ioc_len = sizeof(data);		    \
+	data.ioc_hdr.ioc_version = LIBCFS_IOCTL_VERSION;	\
+	data.ioc_hdr.ioc_len = sizeof(data);			\
 } while (0)
 
 struct libcfs_ioctl_handler {
 	struct list_head item;
-	int (*handle_ioctl)(unsigned int cmd, struct libcfs_ioctl_data *data);
+	int (*handle_ioctl)(unsigned int cmd, struct libcfs_ioctl_hdr *hdr);
 };
 
 #define DECLARE_IOCTL_HANDLER(ident, func)		      \
@@ -149,9 +148,9 @@ static inline int libcfs_ioctl_packlen(struct libcfs_ioctl_data *data)
 	return len;
 }
 
-static inline int libcfs_ioctl_is_invalid(struct libcfs_ioctl_data *data)
+static inline bool libcfs_ioctl_is_invalid(struct libcfs_ioctl_data *data)
 {
-	if (data->ioc_len > (1<<30)) {
+	if (data->ioc_hdr.ioc_len > (1 << 30)) {
 		CERROR("LIBCFS ioctl: ioc_len larger than 1<<30\n");
 		return 1;
 	}
@@ -187,7 +186,7 @@ static inline int libcfs_ioctl_is_invalid(struct libcfs_ioctl_data *data)
 		CERROR("LIBCFS ioctl: plen2 nonzero but no pbuf2 pointer\n");
 		return 1;
 	}
-	if ((__u32)libcfs_ioctl_packlen(data) != data->ioc_len) {
+	if ((__u32)libcfs_ioctl_packlen(data) != data->ioc_hdr.ioc_len) {
 		CERROR("LIBCFS ioctl: packlen != ioc_len\n");
 		return 1;
 	}
@@ -207,7 +206,11 @@ static inline int libcfs_ioctl_is_invalid(struct libcfs_ioctl_data *data)
 
 int libcfs_register_ioctl(struct libcfs_ioctl_handler *hand);
 int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand);
-int libcfs_ioctl_getdata(char *buf, char *end, void *arg);
+int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr *buf, __u32 buf_len,
+			 const void __user *arg);
+int libcfs_ioctl_getdata_len(const struct libcfs_ioctl_hdr __user *arg,
+			     __u32 *buf_len);
 int libcfs_ioctl_popdata(void *arg, void *buf, int size);
+int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data);
 
 #endif /* __LIBCFS_IOCTL_H__ */
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index ac2fdf0..0afdad0 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -84,7 +84,7 @@ lnet_unconfigure(void)
 }
 
 static int
-lnet_ioctl(unsigned int cmd, struct libcfs_ioctl_data *data)
+lnet_ioctl(unsigned int cmd, struct libcfs_ioctl_hdr *hdr)
 {
 	int rc;
 
@@ -101,7 +101,7 @@ lnet_ioctl(unsigned int cmd, struct libcfs_ioctl_data *data)
 		 * I'm called into it */
 		rc = LNetNIInit(LNET_PID_ANY);
 		if (rc >= 0) {
-			rc = LNetCtl(cmd, data);
+			rc = LNetCtl(cmd, hdr);
 			LNetNIFini();
 		}
 		return rc;
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 2ca7d0e..3dc8ea7 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -814,15 +814,20 @@ out:
 }
 
 int
-lstcon_ioctl_entry(unsigned int cmd, struct libcfs_ioctl_data *data)
+lstcon_ioctl_entry(unsigned int cmd, struct libcfs_ioctl_hdr *hdr)
 {
 	char   *buf;
-	int     opc = data->ioc_u32[0];
+	struct libcfs_ioctl_data *data;
+	int     opc;
 	int     rc;
 
 	if (cmd != IOC_LIBCFS_LNETST)
 		return -EINVAL;
 
+	data = container_of(hdr, struct libcfs_ioctl_data, ioc_hdr);
+
+	opc = data->ioc_u32[0];
+
 	if (data->ioc_plen1 > PAGE_CACHE_SIZE)
 		return -EINVAL;
 
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 5619fc4..898912b 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -1977,7 +1977,7 @@ static void lstcon_init_acceptor_service(void)
 	lstcon_acceptor_service.sv_wi_total = SFW_FRWK_WI_MAX;
 }
 
-extern int lstcon_ioctl_entry(unsigned int cmd, struct libcfs_ioctl_data *data);
+extern int lstcon_ioctl_entry(unsigned int cmd, struct libcfs_ioctl_hdr *hdr);
 
 static DECLARE_IOCTL_HANDLER(lstcon_ioctl_handler, lstcon_ioctl_entry);
 
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index 3f3286c..7af3540 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -184,7 +184,6 @@ lstcon_id2hash (lnet_process_id_t id, struct list_head *hash)
 }
 
 int lstcon_console_init(void);
-int lstcon_ioctl_entry(unsigned int cmd, struct libcfs_ioctl_data *data);
 int lstcon_console_fini(void);
 int lstcon_session_match(lst_sid_t sid);
 int lstcon_session_new(char *name, int key, unsigned version,
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
index 70a99cf..ef1c247 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
@@ -40,51 +40,47 @@
 
 #define LNET_MINOR 240
 
-int libcfs_ioctl_getdata(char *buf, char *end, void *arg)
+int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data)
 {
-	struct libcfs_ioctl_hdr   *hdr;
-	struct libcfs_ioctl_data  *data;
-	int orig_len;
-
-	hdr = (struct libcfs_ioctl_hdr *)buf;
-	data = (struct libcfs_ioctl_data *)buf;
-
-	if (copy_from_user(buf, arg, sizeof(*hdr)))
-		return -EFAULT;
-
-	if (hdr->ioc_version != LIBCFS_IOCTL_VERSION) {
-		CERROR("PORTALS: version mismatch kernel vs application\n");
+	if (libcfs_ioctl_is_invalid(data)) {
+		CERROR("LNET: ioctl not correctly formatted\n");
 		return -EINVAL;
 	}
 
-	if (hdr->ioc_len >= end - buf) {
-		CERROR("PORTALS: user buffer exceeds kernel buffer\n");
-		return -EINVAL;
-	}
+	if (data->ioc_inllen1 != 0)
+		data->ioc_inlbuf1 = &data->ioc_bulk[0];
 
-	if (hdr->ioc_len < sizeof(struct libcfs_ioctl_data)) {
-		CERROR("PORTALS: user buffer too small for ioctl\n");
-		return -EINVAL;
-	}
+	if (data->ioc_inllen2 != 0)
+		data->ioc_inlbuf2 = &data->ioc_bulk[0] +
+			cfs_size_round(data->ioc_inllen1);
+
+	return 0;
+}
+
+int libcfs_ioctl_getdata_len(const struct libcfs_ioctl_hdr __user *arg,
+			     __u32 *len)
+{
+	struct libcfs_ioctl_hdr hdr;
 
-	orig_len = hdr->ioc_len;
-	if (copy_from_user(buf, arg, hdr->ioc_len))
+	if (copy_from_user(&hdr, arg, sizeof(hdr)))
 		return -EFAULT;
-	if (orig_len != data->ioc_len)
-		return -EINVAL;
 
-	if (libcfs_ioctl_is_invalid(data)) {
-		CERROR("PORTALS: ioctl not correctly formatted\n");
+	if (hdr.ioc_version != LIBCFS_IOCTL_VERSION) {
+		CERROR("LNET: version mismatch expected %#x, got %#x\n",
+		       LIBCFS_IOCTL_VERSION, hdr.ioc_version);
 		return -EINVAL;
 	}
 
-	if (data->ioc_inllen1)
-		data->ioc_inlbuf1 = &data->ioc_bulk[0];
+	*len = hdr.ioc_len;
 
-	if (data->ioc_inllen2)
-		data->ioc_inlbuf2 = &data->ioc_bulk[0] +
-			cfs_size_round(data->ioc_inllen1);
+	return 0;
+}
 
+int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr *buf, __u32 buf_len,
+			  const void __user *arg)
+{
+	if (copy_from_user(buf, arg, buf_len))
+		return -EFAULT;
 	return 0;
 }
 
diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index 75247e9..5348699 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -54,6 +54,8 @@
 
 # define DEBUG_SUBSYSTEM S_LNET
 
+#define LIBCFS_MAX_IOCTL_BUF_LEN 2048
+
 #include "../../include/linux/libcfs/libcfs.h"
 #include <asm/div64.h>
 
@@ -241,11 +243,21 @@ int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand)
 }
 EXPORT_SYMBOL(libcfs_deregister_ioctl);
 
-static int libcfs_ioctl_int(struct cfs_psdev_file *pfile, unsigned long cmd,
-			    void *arg, struct libcfs_ioctl_data *data)
+static int libcfs_ioctl_handle(struct cfs_psdev_file *pfile, unsigned long cmd,
+			       void *arg, struct libcfs_ioctl_hdr *hdr)
 {
+	struct libcfs_ioctl_data *data = NULL;
 	int err = -EINVAL;
 
+	if ((cmd <= IOC_LIBCFS_LNETST) ||
+	    (cmd >= IOC_LIBCFS_REGISTER_MYNID)) {
+		data = container_of(hdr, struct libcfs_ioctl_data, ioc_hdr);
+		err = libcfs_ioctl_data_adjust(data);
+		if (err != 0) {
+			return err;
+		}
+	}
+
 	switch (cmd) {
 	case IOC_LIBCFS_CLEAR_DEBUG:
 		libcfs_debug_clear_buffer();
@@ -280,11 +292,11 @@ static int libcfs_ioctl_int(struct cfs_psdev_file *pfile, unsigned long cmd,
 		err = -EINVAL;
 		down_read(&ioctl_list_sem);
 		list_for_each_entry(hand, &ioctl_list, item) {
-			err = hand->handle_ioctl(cmd, data);
+			err = hand->handle_ioctl(cmd, hdr);
 			if (err != -EINVAL) {
 				if (err == 0)
 					err = libcfs_ioctl_popdata(arg,
-							data, sizeof(*data));
+							hdr, hdr->ioc_len);
 				break;
 			}
 		}
@@ -298,26 +310,38 @@ static int libcfs_ioctl_int(struct cfs_psdev_file *pfile, unsigned long cmd,
 
 static int libcfs_ioctl(struct cfs_psdev_file *pfile, unsigned long cmd, void *arg)
 {
-	char    *buf;
-	struct libcfs_ioctl_data *data;
+	struct libcfs_ioctl_hdr *hdr;
 	int err = 0;
+	__u32 buf_len;
+
+	err = libcfs_ioctl_getdata_len(arg, &buf_len);
+	if (err != 0)
+		return err;
+
+	/*
+	 * do a check here to restrict the size of the memory
+	 * to allocate to guard against DoS attacks.
+	 */
+	if (buf_len > LIBCFS_MAX_IOCTL_BUF_LEN) {
+		CERROR("LNET: user buffer exceeds kernel buffer\n");
+		return -EINVAL;
+	}
 
-	LIBCFS_ALLOC_GFP(buf, 1024, GFP_KERNEL);
-	if (buf == NULL)
+	LIBCFS_ALLOC_GFP(hdr, buf_len, GFP_KERNEL);
+	if (!hdr)
 		return -ENOMEM;
 
 	/* 'cmd' and permissions get checked in our arch-specific caller */
-	if (libcfs_ioctl_getdata(buf, buf + 800, arg)) {
-		CERROR("PORTALS ioctl: data error\n");
+	if (libcfs_ioctl_getdata(hdr, buf_len, arg)) {
+		CERROR("LNET ioctl: data error\n");
 		err = -EINVAL;
 		goto out;
 	}
-	data = (struct libcfs_ioctl_data *)buf;
 
-	err = libcfs_ioctl_int(pfile, cmd, arg, data);
+	err = libcfs_ioctl_handle(pfile, cmd, arg, hdr);
 
 out:
-	LIBCFS_FREE(buf, 1024);
+	LIBCFS_FREE(hdr, buf_len);
 	return err;
 }
 
-- 
1.7.1
