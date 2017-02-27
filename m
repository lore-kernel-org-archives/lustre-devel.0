From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:29 -0500
Subject: [lustre-devel] [PATCH 04/34] staging: lustre: lnet: change
	lnet_handle_me_t to proper struct
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_handle_me_t from a typedef of another typedef into
a proper stand alone structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/api.h      | 10 +++++-----
 drivers/staging/lustre/include/linux/lnet/lib-lnet.h |  4 ++--
 drivers/staging/lustre/include/linux/lnet/types.h    |  6 ++++--
 drivers/staging/lustre/lnet/lnet/api-ni.c            |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-md.c            |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-me.c            |  8 ++++----
 drivers/staging/lustre/lnet/selftest/rpc.c           |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c        |  6 +++---
 8 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
index 32c3f56..af756e8 100644
--- a/drivers/staging/lustre/include/linux/lnet/api.h
+++ b/drivers/staging/lustre/include/linux/lnet/api.h
@@ -99,17 +99,17 @@ int LNetMEAttach(unsigned int      portal,
 		 __u64		   ignore_bits_in,
 		 lnet_unlink_t     unlink_in,
 		 lnet_ins_pos_t    pos_in,
-		 lnet_handle_me_t *handle_out);
+		 struct lnet_handle_me *handle_out);
 
-int LNetMEInsert(lnet_handle_me_t  current_in,
+int LNetMEInsert(struct lnet_handle_me current_in,
 		 lnet_process_id_t match_id_in,
 		 __u64		   match_bits_in,
 		 __u64		   ignore_bits_in,
 		 lnet_unlink_t     unlink_in,
 		 lnet_ins_pos_t    position_in,
-		 lnet_handle_me_t *handle_out);
+		 struct lnet_handle_me *handle_out);
 
-int LNetMEUnlink(lnet_handle_me_t current_in);
+int LNetMEUnlink(struct lnet_handle_me current_in);
 /** @} lnet_me */
 
 /** \defgroup lnet_md Memory descriptors
@@ -125,7 +125,7 @@ int LNetMEInsert(lnet_handle_me_t  current_in,
  * associated with a MD: LNetMDUnlink().
  * @{
  */
-int LNetMDAttach(lnet_handle_me_t  current_in,
+int LNetMDAttach(struct lnet_handle_me current_in,
 		 lnet_md_t	   md_in,
 		 lnet_unlink_t     unlink_in,
 		 struct lnet_handle_md *md_handle_out);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 344a8a5..bd8d117 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -342,13 +342,13 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 }
 
 static inline void
-lnet_me2handle(lnet_handle_me_t *handle, lnet_me_t *me)
+lnet_me2handle(struct lnet_handle_me *handle, lnet_me_t *me)
 {
 	handle->cookie = me->me_lh.lh_cookie;
 }
 
 static inline lnet_me_t *
-lnet_handle2me(lnet_handle_me_t *handle)
+lnet_handle2me(struct lnet_handle_me *handle)
 {
 	/* ALWAYS called with resource lock held */
 	lnet_libhandle_t *lh;
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 8dcf3f9..513ad6f 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -284,8 +284,6 @@ struct lnet_ping_info {
 	__u64	 cookie;
 } lnet_handle_any_t;
 
-typedef lnet_handle_any_t lnet_handle_me_t;
-
 #define LNET_WIRE_HANDLE_COOKIE_NONE   (-1)
 
 /**
@@ -360,6 +358,10 @@ static inline int LNetMDHandleIsInvalid(struct lnet_handle_md h)
 	return (LNET_WIRE_HANDLE_COOKIE_NONE == h.cookie);
 }
 
+struct lnet_handle_me {
+	u64	cookie;
+};
+
 /**
  * Global process ID.
  */
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index c9d754d..a650fe0 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -901,7 +901,7 @@ static void lnet_assert_wire_constants(void)
 		     int ni_count, bool set_eq)
 {
 	lnet_process_id_t id = {LNET_NID_ANY, LNET_PID_ANY};
-	lnet_handle_me_t me_handle;
+	struct lnet_handle_me me_handle;
 	lnet_md_t md = { NULL };
 	int rc, rc2;
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index f155839..4f2700e 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -267,7 +267,7 @@
  * a MD.
  */
 int
-LNetMDAttach(lnet_handle_me_t meh, lnet_md_t umd,
+LNetMDAttach(struct lnet_handle_me meh, lnet_md_t umd,
 	     lnet_unlink_t unlink, struct lnet_handle_md *handle)
 {
 	LIST_HEAD(matches);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-me.c b/drivers/staging/lustre/lnet/lnet/lib-me.c
index eb796a8..0ea64f6 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-me.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-me.c
@@ -73,7 +73,7 @@
 	     lnet_process_id_t match_id,
 	     __u64 match_bits, __u64 ignore_bits,
 	     lnet_unlink_t unlink, lnet_ins_pos_t pos,
-	     lnet_handle_me_t *handle)
+	     struct lnet_handle_me *handle)
 {
 	struct lnet_match_table *mtable;
 	struct lnet_me *me;
@@ -140,11 +140,11 @@
  * \retval -ENOENT If \a current_meh does not point to a valid match entry.
  */
 int
-LNetMEInsert(lnet_handle_me_t current_meh,
+LNetMEInsert(struct lnet_handle_me current_meh,
 	     lnet_process_id_t match_id,
 	     __u64 match_bits, __u64 ignore_bits,
 	     lnet_unlink_t unlink, lnet_ins_pos_t pos,
-	     lnet_handle_me_t *handle)
+	     struct lnet_handle_me *handle)
 {
 	struct lnet_me *current_me;
 	struct lnet_me *new_me;
@@ -220,7 +220,7 @@
  * \see LNetMDUnlink() for the discussion on delivering unlink event.
  */
 int
-LNetMEUnlink(lnet_handle_me_t meh)
+LNetMEUnlink(struct lnet_handle_me meh)
 {
 	lnet_me_t *me;
 	lnet_libmd_t *md;
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index af99962..9a0b06f 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -360,7 +360,7 @@ struct srpc_bulk *
 {
 	int rc;
 	lnet_md_t md;
-	lnet_handle_me_t meh;
+	struct lnet_handle_me meh;
 
 	rc = LNetMEAttach(portal, peer, matchbits, 0, LNET_UNLINK,
 			  local ? LNET_INS_LOCAL : LNET_INS_AFTER, &meh);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index 64b8ce0..bb6d76a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -115,7 +115,7 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 	int posted_md;
 	int total_md;
 	u64 mbits;
-	lnet_handle_me_t me_h;
+	struct lnet_handle_me me_h;
 	lnet_md_t md;
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_BULK_GET_NET))
@@ -472,7 +472,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	int rc2;
 	int mpflag = 0;
 	struct ptlrpc_connection *connection;
-	lnet_handle_me_t reply_me_h;
+	struct lnet_handle_me reply_me_h;
 	lnet_md_t reply_md;
 	struct obd_import *imp = request->rq_import;
 	struct obd_device *obd = imp->imp_obd;
@@ -722,7 +722,7 @@ int ptlrpc_register_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
 	static lnet_process_id_t match_id = {LNET_NID_ANY, LNET_PID_ANY};
 	int rc;
 	lnet_md_t md;
-	lnet_handle_me_t me_h;
+	struct lnet_handle_me me_h;
 
 	CDEBUG(D_NET, "LNetMEAttach: portal %d\n",
 	       service->srv_req_portal);
-- 
1.8.3.1
