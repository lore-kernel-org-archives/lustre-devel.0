From: James Simmons <jsimmons@infradead.org>
Date: Sat, 21 Jan 2017 19:40:30 -0500
Subject: [lustre-devel] [PATCH 6/8] staging: lustre: lnet: change
	lnet_magicversion_t to proper structure
In-Reply-To: <1485045632-5886-1-git-send-email-jsimmons@infradead.org>
References: <1485045632-5886-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485045632-5886-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_magicversion_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24566
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/types.h        |  4 ++--
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c   |  4 ++--
 .../staging/lustre/lnet/klnds/socklnd/socklnd_proto.c    |  6 +++---
 drivers/staging/lustre/lnet/lnet/api-ni.c                | 16 ++++++++--------
 4 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index c14015a..a6233be 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -204,11 +204,11 @@ struct lnet_handle_wire {
  * exchange HELLO messages when a connection is first established.  Individual
  * LNDs can put whatever else they fancy in lnet_hdr_t::msg.
  */
-typedef struct {
+struct lnet_magicversion {
 	__u32	magic;		/* LNET_PROTO_TCP_MAGIC */
 	__u16	version_major;	/* increment on incompatible change */
 	__u16	version_minor;	/* increment on compatible change */
-} WIRE_ATTR lnet_magicversion_t;
+} WIRE_ATTR;
 
 /* PROTO MAGIC for LNDs */
 #define LNET_PROTO_IB_MAGIC		0x0be91b91
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 972f609..42b67b0 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -1656,9 +1656,9 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	}
 
 	if (hello->kshm_magic == le32_to_cpu(LNET_PROTO_TCP_MAGIC)) {
-		lnet_magicversion_t *hmv = (lnet_magicversion_t *)hello;
+		struct lnet_magicversion *hmv = (struct lnet_magicversion *)hello;
 
-		CLASSERT(sizeof(lnet_magicversion_t) ==
+		CLASSERT(sizeof(struct lnet_magicversion) ==
 			 offsetof(ksock_hello_msg_t, kshm_src_nid));
 
 		if (hmv->version_major == cpu_to_le16(KSOCK_PROTO_V1_MAJOR) &&
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index 8f0ff6c..420597b 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -460,11 +460,11 @@
 {
 	struct socket *sock = conn->ksnc_sock;
 	lnet_hdr_t *hdr;
-	lnet_magicversion_t *hmv;
+	struct lnet_magicversion *hmv;
 	int rc;
 	int i;
 
-	CLASSERT(sizeof(lnet_magicversion_t) == offsetof(lnet_hdr_t, src_nid));
+	CLASSERT(sizeof(struct lnet_magicversion) == offsetof(lnet_hdr_t, src_nid));
 
 	LIBCFS_ALLOC(hdr, sizeof(*hdr));
 	if (!hdr) {
@@ -472,7 +472,7 @@
 		return -ENOMEM;
 	}
 
-	hmv = (lnet_magicversion_t *)&hdr->dest_nid;
+	hmv = (struct lnet_magicversion *)&hdr->dest_nid;
 
 	/*
 	 * Re-organize V2.x message header to V1.x (lnet_hdr_t)
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 3b2488f..fd4153b 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -196,14 +196,14 @@ static void lnet_assert_wire_constants(void)
 	CLASSERT((int)offsetof(struct lnet_handle_wire, wh_object_cookie) == 8);
 	CLASSERT((int)sizeof(((struct lnet_handle_wire *)0)->wh_object_cookie) == 8);
 
-	/* Checks for struct lnet_magicversion_t */
-	CLASSERT((int)sizeof(lnet_magicversion_t) == 8);
-	CLASSERT((int)offsetof(lnet_magicversion_t, magic) == 0);
-	CLASSERT((int)sizeof(((lnet_magicversion_t *)0)->magic) == 4);
-	CLASSERT((int)offsetof(lnet_magicversion_t, version_major) == 4);
-	CLASSERT((int)sizeof(((lnet_magicversion_t *)0)->version_major) == 2);
-	CLASSERT((int)offsetof(lnet_magicversion_t, version_minor) == 6);
-	CLASSERT((int)sizeof(((lnet_magicversion_t *)0)->version_minor) == 2);
+	/* Checks for struct struct lnet_magicversion */
+	CLASSERT((int)sizeof(struct lnet_magicversion) == 8);
+	CLASSERT((int)offsetof(struct lnet_magicversion, magic) == 0);
+	CLASSERT((int)sizeof(((struct lnet_magicversion *)0)->magic) == 4);
+	CLASSERT((int)offsetof(struct lnet_magicversion, version_major) == 4);
+	CLASSERT((int)sizeof(((struct lnet_magicversion *)0)->version_major) == 2);
+	CLASSERT((int)offsetof(struct lnet_magicversion, version_minor) == 6);
+	CLASSERT((int)sizeof(((struct lnet_magicversion *)0)->version_minor) == 2);
 
 	/* Checks for struct lnet_hdr_t */
 	CLASSERT((int)sizeof(lnet_hdr_t) == 72);
-- 
1.8.3.1
