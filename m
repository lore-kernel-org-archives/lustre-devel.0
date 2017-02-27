From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:52 -0500
Subject: [lustre-devel] [PATCH 27/34] staging: lustre: lnet: change
	lnet_msg_type_t to proper enum
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_msg_type_t from typedef to proper enum.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/types.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 74118d0..6a24189 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -132,13 +132,13 @@ struct lnet_handle_wire {
 	__u64	wh_object_cookie;
 } WIRE_ATTR;
 
-typedef enum {
+enum lnet_msg_type {
 	LNET_MSG_ACK = 0,
 	LNET_MSG_PUT,
 	LNET_MSG_GET,
 	LNET_MSG_REPLY,
 	LNET_MSG_HELLO,
-} lnet_msg_type_t;
+};
 
 /*
  * The variant fields of the portals message header are aligned on an 8
@@ -182,7 +182,7 @@ struct lnet_hdr {
 	lnet_nid_t	src_nid;
 	lnet_pid_t	dest_pid;
 	lnet_pid_t	src_pid;
-	__u32		type;		/* lnet_msg_type_t */
+	__u32		type;		/* enum lnet_msg_type */
 	__u32		payload_length;	/* payload data to follow */
 	/*<------__u64 aligned------->*/
 	union {
-- 
1.8.3.1
