From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:56 -0500
Subject: [lustre-devel] [PATCH 31/34] staging: lustre: lnet: change
	lnet_ack_req_t to proper enum
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-32-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_ack_req_t from typedef to proper enum.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/api.h   | 2 +-
 drivers/staging/lustre/include/linux/lnet/types.h | 4 ++--
 drivers/staging/lustre/lnet/lnet/lib-move.c       | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c     | 2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
index fc42898..f4b6de2 100644
--- a/drivers/staging/lustre/include/linux/lnet/api.h
+++ b/drivers/staging/lustre/include/linux/lnet/api.h
@@ -180,7 +180,7 @@ int LNetEQPoll(struct lnet_handle_eq *eventqs_in,
  */
 int LNetPut(lnet_nid_t	      self,
 	    struct lnet_handle_md md_in,
-	    lnet_ack_req_t    ack_req_in,
+	    enum lnet_ack_req ack_req_in,
 	    struct lnet_process_id target_in,
 	    unsigned int      portal_in,
 	    __u64	      match_bits_in,
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index a621ab6..8e10ad6 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -663,12 +663,12 @@ struct lnet_event {
  * \see lnet_md::options for the discussion on LNET_MD_ACK_DISABLE by which
  * acknowledgments can be disabled for a MD.
  */
-typedef enum {
+enum lnet_ack_req {
 	/** Request an acknowledgment */
 	LNET_ACK_REQ,
 	/** Request that no acknowledgment should be generated. */
 	LNET_NOACK_REQ
-} lnet_ack_req_t;
+};
 /** @} lnet_data */
 
 /** @} lnet */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 7fdbc75..48e1f5b 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1990,7 +1990,7 @@
  * \see lnet_event::hdr_data and lnet_event_kind.
  */
 int
-LNetPut(lnet_nid_t self, struct lnet_handle_md mdh, lnet_ack_req_t ack,
+LNetPut(lnet_nid_t self, struct lnet_handle_md mdh, enum lnet_ack_req ack,
 	struct lnet_process_id target, unsigned int portal,
 	__u64 match_bits, unsigned int offset,
 	__u64 hdr_data)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index e3d2c0d..eddc192 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -44,7 +44,7 @@
  * Returns 0 on success or error code.
  */
 static int ptl_send_buf(struct lnet_handle_md *mdh, void *base, int len,
-			lnet_ack_req_t ack, struct ptlrpc_cb_id *cbid,
+			enum lnet_ack_req ack, struct ptlrpc_cb_id *cbid,
 			struct ptlrpc_connection *conn, int portal, __u64 xid,
 			unsigned int offset)
 {
-- 
1.8.3.1
