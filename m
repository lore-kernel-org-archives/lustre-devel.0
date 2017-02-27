From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:30 -0500
Subject: [lustre-devel] [PATCH 05/34] staging: lustre: lnet: remove generic
	lnet_handle_any_t
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

With the creation of unique handlers we can remove the
barely used generic handlers.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/api.h   |  1 -
 drivers/staging/lustre/include/linux/lnet/types.h | 41 ++---------------------
 drivers/staging/lustre/lnet/lnet/api-ni.c         | 11 ------
 3 files changed, 3 insertions(+), 50 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
index af756e8..2585dbb 100644
--- a/drivers/staging/lustre/include/linux/lnet/api.h
+++ b/drivers/staging/lustre/include/linux/lnet/api.h
@@ -76,7 +76,6 @@
  */
 int LNetGetId(unsigned int index, lnet_process_id_t *id);
 int LNetDist(lnet_nid_t nid, lnet_nid_t *srcnid, __u32 *order);
-void LNetSnprintHandle(char *str, int str_len, lnet_handle_any_t handle);
 
 /** @} lnet_addr */
 
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 513ad6f..e81b079 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -272,48 +272,13 @@ struct lnet_ping_info {
 
 /**
  * Objects maintained by the LNet are accessed through handles. Handle types
- * have names of the form lnet_handle_xx_t, where xx is one of the two letter
+ * have names of the form lnet_handle_xx, where xx is one of the two letter
  * object type codes ('eq' for event queue, 'md' for memory descriptor, and
- * 'me' for match entry).
- * Each type of object is given a unique handle type to enhance type checking.
- * The type lnet_handle_any_t can be used when a generic handle is needed.
- * Every handle value can be converted into a value of type lnet_handle_any_t
- * without loss of information.
+ * 'me' for match entry). Each type of object is given a unique handle type
+ * to enhance type checking.
  */
-typedef struct {
-	__u64	 cookie;
-} lnet_handle_any_t;
-
 #define LNET_WIRE_HANDLE_COOKIE_NONE   (-1)
 
-/**
- * Invalidate handle \a h.
- */
-static inline void LNetInvalidateHandle(lnet_handle_any_t *h)
-{
-	h->cookie = LNET_WIRE_HANDLE_COOKIE_NONE;
-}
-
-/**
- * Compare handles \a h1 and \a h2.
- *
- * \return 1 if handles are equal, 0 if otherwise.
- */
-static inline int LNetHandleIsEqual(lnet_handle_any_t h1, lnet_handle_any_t h2)
-{
-	return h1.cookie == h2.cookie;
-}
-
-/**
- * Check whether handle \a h is invalid.
- *
- * \return 1 if handle is invalid, 0 if valid.
- */
-static inline int LNetHandleIsInvalid(lnet_handle_any_t h)
-{
-	return h.cookie == LNET_WIRE_HANDLE_COOKIE_NONE;
-}
-
 struct lnet_handle_eq {
 	u64	cookie;
 };
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index a650fe0..efafd42 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -2127,17 +2127,6 @@ void LNetDebugPeer(lnet_process_id_t id)
 }
 EXPORT_SYMBOL(LNetGetId);
 
-/**
- * Print a string representation of handle \a h into buffer \a str of
- * \a len bytes.
- */
-void
-LNetSnprintHandle(char *str, int len, lnet_handle_any_t h)
-{
-	snprintf(str, len, "%#llx", h.cookie);
-}
-EXPORT_SYMBOL(LNetSnprintHandle);
-
 static int lnet_ping(lnet_process_id_t id, int timeout_ms,
 		     lnet_process_id_t __user *ids, int n_ids)
 {
-- 
1.8.3.1
