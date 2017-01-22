From: James Simmons <jsimmons@infradead.org>
Date: Sat, 21 Jan 2017 19:40:25 -0500
Subject: [lustre-devel] [PATCH 1/8] staging: lustre: lnet: change
	lnet_handle_wire_t to proper structure
In-Reply-To: <1485045632-5886-1-git-send-email-jsimmons@infradead.org>
References: <1485045632-5886-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485045632-5886-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_handle_wire_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24566
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lib-lnet.h |  4 ++--
 drivers/staging/lustre/include/linux/lnet/types.h    | 12 ++++++------
 drivers/staging/lustre/lnet/lnet/api-ni.c            | 10 +++++-----
 drivers/staging/lustre/lnet/lnet/lib-move.c          |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-msg.c           |  2 +-
 5 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index a59c5e99c..363342f 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -78,7 +78,7 @@ static inline int lnet_is_route_alive(lnet_route_t *route)
 	return route->lr_downis == 0;
 }
 
-static inline int lnet_is_wire_handle_none(lnet_handle_wire_t *wh)
+static inline int lnet_is_wire_handle_none(struct lnet_handle_wire *wh)
 {
 	return (wh->wh_interface_cookie == LNET_WIRE_HANDLE_COOKIE_NONE &&
 		wh->wh_object_cookie == LNET_WIRE_HANDLE_COOKIE_NONE);
@@ -323,7 +323,7 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 }
 
 static inline lnet_libmd_t *
-lnet_wire_handle2md(lnet_handle_wire_t *wh)
+lnet_wire_handle2md(struct lnet_handle_wire *wh)
 {
 	/* ALWAYS called with resource lock held */
 	lnet_libhandle_t *lh;
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 8ca1e9d..1787089 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -127,10 +127,10 @@ static inline __u32 LNET_MKNET(__u32 type, __u32 num)
  * reboots).  The object cookie only matches one object on that interface
  * during that object's lifetime (i.e. no cookie re-use).
  */
-typedef struct {
+struct lnet_handle_wire {
 	__u64	wh_interface_cookie;
 	__u64	wh_object_cookie;
-} WIRE_ATTR lnet_handle_wire_t;
+} WIRE_ATTR;
 
 typedef enum {
 	LNET_MSG_ACK = 0,
@@ -147,13 +147,13 @@ static inline __u32 LNET_MKNET(__u32 type, __u32 num)
  * end.
  */
 typedef struct lnet_ack {
-	lnet_handle_wire_t	dst_wmd;
+	struct lnet_handle_wire	dst_wmd;
 	__u64			match_bits;
 	__u32			mlength;
 } WIRE_ATTR lnet_ack_t;
 
 typedef struct lnet_put {
-	lnet_handle_wire_t	ack_wmd;
+	struct lnet_handle_wire	ack_wmd;
 	__u64			match_bits;
 	__u64			hdr_data;
 	__u32			ptl_index;
@@ -161,7 +161,7 @@ static inline __u32 LNET_MKNET(__u32 type, __u32 num)
 } WIRE_ATTR lnet_put_t;
 
 typedef struct lnet_get {
-	lnet_handle_wire_t	return_wmd;
+	struct lnet_handle_wire	return_wmd;
 	__u64			match_bits;
 	__u32			ptl_index;
 	__u32			src_offset;
@@ -169,7 +169,7 @@ static inline __u32 LNET_MKNET(__u32 type, __u32 num)
 } WIRE_ATTR lnet_get_t;
 
 typedef struct lnet_reply {
-	lnet_handle_wire_t	dst_wmd;
+	struct lnet_handle_wire	dst_wmd;
 } WIRE_ATTR lnet_reply_t;
 
 typedef struct lnet_hello {
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index b2ba10d..3a7788c 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -190,11 +190,11 @@ static void lnet_assert_wire_constants(void)
 	CLASSERT(LNET_MSG_HELLO == 4);
 
 	/* Checks for struct ptl_handle_wire_t */
-	CLASSERT((int)sizeof(lnet_handle_wire_t) == 16);
-	CLASSERT((int)offsetof(lnet_handle_wire_t, wh_interface_cookie) == 0);
-	CLASSERT((int)sizeof(((lnet_handle_wire_t *)0)->wh_interface_cookie) == 8);
-	CLASSERT((int)offsetof(lnet_handle_wire_t, wh_object_cookie) == 8);
-	CLASSERT((int)sizeof(((lnet_handle_wire_t *)0)->wh_object_cookie) == 8);
+	CLASSERT((int)sizeof(struct lnet_handle_wire) == 16);
+	CLASSERT((int)offsetof(struct lnet_handle_wire, wh_interface_cookie) == 0);
+	CLASSERT((int)sizeof(((struct lnet_handle_wire *)0)->wh_interface_cookie) == 8);
+	CLASSERT((int)offsetof(struct lnet_handle_wire, wh_object_cookie) == 8);
+	CLASSERT((int)sizeof(((struct lnet_handle_wire *)0)->wh_object_cookie) == 8);
 
 	/* Checks for struct lnet_magicversion_t */
 	CLASSERT((int)sizeof(lnet_magicversion_t) == 8);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index f3dd6e4..595fde8 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1326,7 +1326,7 @@
 {
 	struct lnet_match_info info;
 	lnet_hdr_t *hdr = &msg->msg_hdr;
-	lnet_handle_wire_t reply_wmd;
+	struct lnet_handle_wire reply_wmd;
 	int rc;
 
 	/* Convert get fields to host byte order */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index 0897e58..1262616 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -361,7 +361,7 @@
 static int
 lnet_complete_msg_locked(lnet_msg_t *msg, int cpt)
 {
-	lnet_handle_wire_t ack_wmd;
+	struct lnet_handle_wire ack_wmd;
 	int rc;
 	int status = msg->msg_ev.status;
 
-- 
1.8.3.1
