From: James Simmons <jsimmons@infradead.org>
Date: Sat, 21 Jan 2017 19:40:32 -0500
Subject: [lustre-devel] [PATCH 8/8] staging: lustre: lnet: change msg union
	in struct lnet_hdr to proper structure
In-Reply-To: <1485045632-5886-1-git-send-email-jsimmons@infradead.org>
References: <1485045632-5886-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485045632-5886-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Modify all the msg union fields from typedefs to
to proper structures.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24566
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/types.h | 30 +++++++++++------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 1448fa4..1c8de72 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -146,36 +146,36 @@ struct lnet_handle_wire {
  * wire structs MUST be fixed size and the smaller types are placed at the
  * end.
  */
-typedef struct lnet_ack {
+struct lnet_ack {
 	struct lnet_handle_wire	dst_wmd;
 	__u64			match_bits;
 	__u32			mlength;
-} WIRE_ATTR lnet_ack_t;
+} WIRE_ATTR;
 
-typedef struct lnet_put {
+struct lnet_put {
 	struct lnet_handle_wire	ack_wmd;
 	__u64			match_bits;
 	__u64			hdr_data;
 	__u32			ptl_index;
 	__u32			offset;
-} WIRE_ATTR lnet_put_t;
+} WIRE_ATTR;
 
-typedef struct lnet_get {
+struct lnet_get {
 	struct lnet_handle_wire	return_wmd;
 	__u64			match_bits;
 	__u32			ptl_index;
 	__u32			src_offset;
 	__u32			sink_length;
-} WIRE_ATTR lnet_get_t;
+} WIRE_ATTR;
 
-typedef struct lnet_reply {
+struct lnet_reply {
 	struct lnet_handle_wire	dst_wmd;
-} WIRE_ATTR lnet_reply_t;
+} WIRE_ATTR;
 
-typedef struct lnet_hello {
+struct lnet_hello {
 	__u64			incarnation;
 	__u32			type;
-} WIRE_ATTR lnet_hello_t;
+} WIRE_ATTR;
 
 struct lnet_hdr {
 	lnet_nid_t	dest_nid;
@@ -186,11 +186,11 @@ struct lnet_hdr {
 	__u32		payload_length;	/* payload data to follow */
 	/*<------__u64 aligned------->*/
 	union {
-		lnet_ack_t	ack;
-		lnet_put_t	put;
-		lnet_get_t	get;
-		lnet_reply_t	reply;
-		lnet_hello_t	hello;
+		struct lnet_ack		ack;
+		struct lnet_put		put;
+		struct lnet_get		get;
+		struct lnet_reply	reply;
+		struct lnet_hello	hello;
 	} msg;
 } WIRE_ATTR;
 
-- 
1.8.3.1
