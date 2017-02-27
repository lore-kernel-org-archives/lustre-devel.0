From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:49 -0500
Subject: [lustre-devel] [PATCH 24/34] staging: lustre: lnet: change
	lnet_md_t to proper structure
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_md_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/api.h    |  4 +--
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |  4 +--
 drivers/staging/lustre/include/linux/lnet/types.h  | 30 +++++++++++-----------
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  4 +--
 drivers/staging/lustre/lnet/lnet/lib-md.c          | 10 ++++----
 drivers/staging/lustre/lnet/lnet/router.c          |  2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |  4 +--
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |  8 +++---
 drivers/staging/lustre/lustre/ptlrpc/pers.c        |  2 +-
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |  2 +-
 10 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
index 2585dbb..8609206 100644
--- a/drivers/staging/lustre/include/linux/lnet/api.h
+++ b/drivers/staging/lustre/include/linux/lnet/api.h
@@ -125,11 +125,11 @@ int LNetMEInsert(struct lnet_handle_me current_in,
  * @{
  */
 int LNetMDAttach(struct lnet_handle_me current_in,
-		 lnet_md_t	   md_in,
+		 struct lnet_md md_in,
 		 lnet_unlink_t     unlink_in,
 		 struct lnet_handle_md *md_handle_out);
 
-int LNetMDBind(lnet_md_t	   md_in,
+int LNetMDBind(struct lnet_md md_in,
 	       lnet_unlink_t       unlink_in,
 	       struct lnet_handle_md *md_handle_out);
 
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 4a1e0a1..a6cf5be 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -194,7 +194,7 @@ static inline int lnet_md_unlinkable(struct lnet_libmd *md)
 }
 
 static inline struct lnet_libmd *
-lnet_md_alloc(lnet_md_t *umd)
+lnet_md_alloc(struct lnet_md *umd)
 {
 	struct lnet_libmd *md;
 	unsigned int size;
@@ -626,7 +626,7 @@ void lnet_copy_kiov2iter(struct iov_iter *to,
 void lnet_me_unlink(struct lnet_me *me);
 
 void lnet_md_unlink(struct lnet_libmd *md);
-void lnet_md_deconstruct(struct lnet_libmd *lmd, lnet_md_t *umd);
+void lnet_md_deconstruct(struct lnet_libmd *lmd, struct lnet_md *umd);
 
 void lnet_register_lnd(struct lnet_lnd *lnd);
 void lnet_unregister_lnd(struct lnet_lnd *lnd);
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index d2af335..bc3f3e3 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -377,7 +377,7 @@ struct lnet_handle_me {
  * Defines the visible parts of a memory descriptor. Values of this type
  * are used to initialize memory descriptors.
  */
-typedef struct {
+struct lnet_md {
 	/**
 	 * Specify the memory region associated with the memory descriptor.
 	 * If the options field has:
@@ -471,7 +471,7 @@ struct lnet_handle_me {
 	 * descriptor are not logged.
 	 */
 	struct lnet_handle_eq eq_handle;
-} lnet_md_t;
+};
 
 /*
  * Max Transfer Unit (minimum supported everywhere).
@@ -485,29 +485,29 @@ struct lnet_handle_me {
 #define LNET_MAX_IOV	256
 
 /**
- * Options for the MD structure. See lnet_md_t::options.
+ * Options for the MD structure. See lnet_md::options.
  */
 #define LNET_MD_OP_PUT		(1 << 0)
-/** See lnet_md_t::options. */
+/** See lnet_md::options. */
 #define LNET_MD_OP_GET		(1 << 1)
-/** See lnet_md_t::options. */
+/** See lnet_md::options. */
 #define LNET_MD_MANAGE_REMOTE	(1 << 2)
 /* unused			(1 << 3) */
-/** See lnet_md_t::options. */
+/** See lnet_md::options. */
 #define LNET_MD_TRUNCATE	(1 << 4)
-/** See lnet_md_t::options. */
+/** See lnet_md::options. */
 #define LNET_MD_ACK_DISABLE	(1 << 5)
-/** See lnet_md_t::options. */
+/** See lnet_md::options. */
 #define LNET_MD_IOVEC		(1 << 6)
-/** See lnet_md_t::options. */
+/** See lnet_md::options. */
 #define LNET_MD_MAX_SIZE	(1 << 7)
-/** See lnet_md_t::options. */
+/** See lnet_md::options. */
 #define LNET_MD_KIOV		(1 << 8)
 
 /* For compatibility with Cray Portals */
 #define LNET_MD_PHYS		0
 
-/** Infinite threshold on MD operations. See lnet_md_t::threshold */
+/** Infinite threshold on MD operations. See lnet_md::threshold */
 #define LNET_MD_THRESH_INF	(-1)
 
 /* NB lustre portals uses struct iovec internally! */
@@ -591,7 +591,7 @@ struct lnet_handle_me {
 	 * The length (in bytes) of the data that was manipulated by the
 	 * operation. For truncated operations, the manipulated length will be
 	 * the number of bytes specified by the MD (possibly with an offset,
-	 * see lnet_md_t). For all other operations, the manipulated length
+	 * see lnet_md). For all other operations, the manipulated length
 	 * will be the length of the requested operation, i.e. rlength.
 	 */
 	unsigned int		mlength;
@@ -605,7 +605,7 @@ struct lnet_handle_me {
 	 * been processed. In particular, the threshold field in md will
 	 * reflect the value of the threshold after the operation occurred.
 	 */
-	lnet_md_t		md;
+	struct lnet_md		md;
 	/**
 	 * 64 bits of out-of-band user data. Only valid for LNET_EVENT_PUT.
 	 * \see LNetPut
@@ -627,7 +627,7 @@ struct lnet_handle_me {
 	 * The displacement (in bytes) into the memory region that the
 	 * operation used. The offset can be determined by the operation for
 	 * a remote managed MD or by the local MD.
-	 * \see lnet_md_t::options
+	 * \see lnet_md::options
 	 */
 	unsigned int		offset;
 	/**
@@ -660,7 +660,7 @@ struct lnet_handle_me {
  * operation completes (i.e., when the data has been written to a MD of the
  * target process).
  *
- * \see lnet_md_t::options for the discussion on LNET_MD_ACK_DISABLE by which
+ * \see lnet_md::options for the discussion on LNET_MD_ACK_DISABLE by which
  * acknowledgments can be disabled for a MD.
  */
 typedef enum {
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 34b9b10..53c9427 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -903,7 +903,7 @@ struct lnet_ni  *
 {
 	lnet_process_id_t id = {LNET_NID_ANY, LNET_PID_ANY};
 	struct lnet_handle_me me_handle;
-	lnet_md_t md = { NULL };
+	struct lnet_md md = { NULL };
 	int rc, rc2;
 
 	if (set_eq) {
@@ -2134,7 +2134,7 @@ static int lnet_ping(lnet_process_id_t id, int timeout_ms,
 	struct lnet_handle_eq eqh;
 	struct lnet_handle_md mdh;
 	lnet_event_t event;
-	lnet_md_t md = { NULL };
+	struct lnet_md md = { NULL };
 	int which;
 	int unlinked = 0;
 	int replied = 0;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index bb832c5..a3f8927 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -84,7 +84,7 @@
 }
 
 static int
-lnet_md_build(struct lnet_libmd *lmd, lnet_md_t *umd, int unlink)
+lnet_md_build(struct lnet_libmd *lmd, struct lnet_md *umd, int unlink)
 {
 	int i;
 	unsigned int niov;
@@ -204,7 +204,7 @@
 
 /* must be called with lnet_res_lock held */
 void
-lnet_md_deconstruct(struct lnet_libmd *lmd, lnet_md_t *umd)
+lnet_md_deconstruct(struct lnet_libmd *lmd, struct lnet_md *umd)
 {
 	/* NB this doesn't copy out all the iov entries so when a
 	 * discontiguous MD is copied out, the target gets to know the
@@ -223,7 +223,7 @@
 }
 
 static int
-lnet_md_validate(lnet_md_t *umd)
+lnet_md_validate(struct lnet_md *umd)
 {
 	if (!umd->start && umd->length) {
 		CERROR("MD start pointer can not be NULL with length %u\n",
@@ -267,7 +267,7 @@
  * a MD.
  */
 int
-LNetMDAttach(struct lnet_handle_me meh, lnet_md_t umd,
+LNetMDAttach(struct lnet_handle_me meh, struct lnet_md umd,
 	     lnet_unlink_t unlink, struct lnet_handle_md *handle)
 {
 	LIST_HEAD(matches);
@@ -350,7 +350,7 @@
  * LNetInvalidateHandle() on it.
  */
 int
-LNetMDBind(lnet_md_t umd, lnet_unlink_t unlink,
+LNetMDBind(struct lnet_md umd, lnet_unlink_t unlink,
 	   struct lnet_handle_md *handle)
 {
 	struct lnet_libmd *md;
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index effa0fe..c9edc10 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -905,7 +905,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 {
 	struct lnet_rc_data *rcd = NULL;
 	struct lnet_ping_info *pi;
-	lnet_md_t md;
+	struct lnet_md md;
 	int rc;
 	int i;
 
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 9a0b06f..e70785c 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -359,7 +359,7 @@ struct srpc_bulk *
 		       struct lnet_handle_md *mdh, struct srpc_event *ev)
 {
 	int rc;
-	lnet_md_t md;
+	struct lnet_md md;
 	struct lnet_handle_me meh;
 
 	rc = LNetMEAttach(portal, peer, matchbits, 0, LNET_UNLINK,
@@ -398,7 +398,7 @@ struct srpc_bulk *
 		      struct lnet_handle_md *mdh, struct srpc_event *ev)
 {
 	int rc;
-	lnet_md_t md;
+	struct lnet_md md;
 
 	md.user_ptr = ev;
 	md.start = buf;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index bb6d76a..befd73c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -49,7 +49,7 @@ static int ptl_send_buf(struct lnet_handle_md *mdh, void *base, int len,
 			unsigned int offset)
 {
 	int rc;
-	lnet_md_t md;
+	struct lnet_md md;
 
 	LASSERT(portal != 0);
 	CDEBUG(D_INFO, "conn=%p id %s\n", conn, libcfs_id2str(conn->c_peer));
@@ -116,7 +116,7 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 	int total_md;
 	u64 mbits;
 	struct lnet_handle_me me_h;
-	lnet_md_t md;
+	struct lnet_md md;
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_BULK_GET_NET))
 		return 0;
@@ -473,7 +473,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	int mpflag = 0;
 	struct ptlrpc_connection *connection;
 	struct lnet_handle_me reply_me_h;
-	lnet_md_t reply_md;
+	struct lnet_md reply_md;
 	struct obd_import *imp = request->rq_import;
 	struct obd_device *obd = imp->imp_obd;
 
@@ -721,7 +721,7 @@ int ptlrpc_register_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
 	struct ptlrpc_service *service = rqbd->rqbd_svcpt->scp_service;
 	static lnet_process_id_t match_id = {LNET_NID_ANY, LNET_PID_ANY};
 	int rc;
-	lnet_md_t md;
+	struct lnet_md md;
 	struct lnet_handle_me me_h;
 
 	CDEBUG(D_NET, "LNetMEAttach: portal %d\n",
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pers.c b/drivers/staging/lustre/lustre/ptlrpc/pers.c
index 601acb8..df4994f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pers.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pers.c
@@ -40,7 +40,7 @@
 
 #include "ptlrpc_internal.h"
 
-void ptlrpc_fill_bulk_md(lnet_md_t *md, struct ptlrpc_bulk_desc *desc,
+void ptlrpc_fill_bulk_md(struct lnet_md *md, struct ptlrpc_bulk_desc *desc,
 			 int mdidx)
 {
 	int offset = mdidx * LNET_MAX_IOV;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index 8e6a805..d2707a3 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -234,7 +234,7 @@ struct ptlrpc_nrs_policy *nrs_request_policy(struct ptlrpc_nrs_request *nrq)
 int ptlrpc_expire_one_request(struct ptlrpc_request *req, int async_unlink);
 
 /* pers.c */
-void ptlrpc_fill_bulk_md(lnet_md_t *md, struct ptlrpc_bulk_desc *desc,
+void ptlrpc_fill_bulk_md(struct lnet_md *md, struct ptlrpc_bulk_desc *desc,
 			 int mdcnt);
 
 /* pack_generic.c */
-- 
1.8.3.1
