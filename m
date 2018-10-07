From: NeilBrown <neilb@suse.com>
Date: Mon, 08 Oct 2018 10:19:37 +1100
Subject: [lustre-devel] [PATCH 06/24] lustre: lnet: add sanity checks on
 ping-related constants
In-Reply-To: <153895417139.16383.3791701638653772865.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
Message-ID: <153895437778.16383.4176394927995685300.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Olaf Weber <olaf@sgi.com>

Add sanity checks for LNet ping related data structures and
constants to wirecheck.c, and update the generated code in
lnet_assert_wire_constants().

In order for the structures and macros to be visible to
wirecheck.c, which is a userspace program, they were moved
from kernel-only lnet/lib-types.h to lnet/types.h

WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
Signed-off-by: Olaf Weber <olaf@sgi.com>
Reviewed-on: https://review.whamcloud.com/25776
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Tested-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  |   30 ----------------
 .../lustre/include/uapi/linux/lnet/lnet-types.h    |   30 ++++++++++++++++
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   38 ++++++++++++++++++++
 3 files changed, 68 insertions(+), 30 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index f4467a3bbfd1..f28fa5342914 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -378,36 +378,6 @@ struct lnet_ni {
 
 #define LNET_PROTO_PING_MATCHBITS	0x8000000000000000LL
 
-/*
- * NB: value of these features equal to LNET_PROTO_PING_VERSION_x
- * of old LNet, so there shouldn't be any compatibility issue
- */
-#define LNET_PING_FEAT_INVAL		(0)		/* no feature */
-#define LNET_PING_FEAT_BASE		BIT(0)	/* just a ping */
-#define LNET_PING_FEAT_NI_STATUS	BIT(1)	/* return NI status */
-#define LNET_PING_FEAT_RTE_DISABLED	BIT(2)	/* Routing enabled */
-#define LNET_PING_FEAT_MULTI_RAIL	BIT(3)	/* Multi-Rail aware */
-#define LNET_PING_FEAT_DISCOVERY	BIT(4)	/* Supports Discovery */
-
-/*
- * All ping feature bits fit to hit the wire.
- * In lnet_assert_wire_constants() this is compared against its open-coded
- * value, and in lnet_ping_target_update() it is used to verify that no
- * unknown bits have been set.
- * New feature bits can be added, just be aware that this does change the
- * over-the-wire protocol.
- */
-#define LNET_PING_FEAT_BITS		(LNET_PING_FEAT_BASE | \
-					 LNET_PING_FEAT_NI_STATUS | \
-					 LNET_PING_FEAT_RTE_DISABLED | \
-					 LNET_PING_FEAT_MULTI_RAIL | \
-					 LNET_PING_FEAT_DISCOVERY)
-
-#define LNET_PING_INFO_SIZE(NNIDS) \
-	offsetof(struct lnet_ping_info, pi_ni[NNIDS])
-#define LNET_PING_INFO_LONI(PINFO)	((PINFO)->pi_ni[0].ns_nid)
-#define LNET_PING_INFO_SEQNO(PINFO)	((PINFO)->pi_ni[0].ns_status)
-
 /*
  * Descriptor of a ping info buffer: keep a separate indicator of the
  * size and a reference count. The type is used both as a source and
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
index 6ee60d07ff84..e0e4fd259795 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
@@ -190,6 +190,31 @@ struct lnet_hdr {
 	} msg;
 } __packed;
 
+/*
+ * NB: value of these features equal to LNET_PROTO_PING_VERSION_x
+ * of old LNet, so there shouldn't be any compatibility issue
+ */
+#define LNET_PING_FEAT_INVAL		(0)		/* no feature */
+#define LNET_PING_FEAT_BASE		(1 << 0)	/* just a ping */
+#define LNET_PING_FEAT_NI_STATUS	(1 << 1)	/* return NI status */
+#define LNET_PING_FEAT_RTE_DISABLED	(1 << 2)	/* Routing enabled */
+#define LNET_PING_FEAT_MULTI_RAIL	(1 << 3)	/* Multi-Rail aware */
+#define LNET_PING_FEAT_DISCOVERY	(1 << 4)	/* Supports Discovery */
+
+/*
+ * All ping feature bits fit to hit the wire.
+ * In lnet_assert_wire_constants() this is compared against its open-coded
+ * value, and in lnet_ping_target_update() it is used to verify that no
+ * unknown bits have been set.
+ * New feature bits can be added, just be aware that this does change the
+ * over-the-wire protocol.
+ */
+#define LNET_PING_FEAT_BITS		(LNET_PING_FEAT_BASE | \
+					 LNET_PING_FEAT_NI_STATUS | \
+					 LNET_PING_FEAT_RTE_DISABLED | \
+					 LNET_PING_FEAT_MULTI_RAIL | \
+					 LNET_PING_FEAT_DISCOVERY)
+
 /*
  * A HELLO message contains a magic number and protocol version
  * code in the header's dest_nid, the peer's NID in the src_nid, and
@@ -246,6 +271,11 @@ struct lnet_ping_info {
 	struct lnet_ni_status	pi_ni[0];
 } __packed;
 
+#define LNET_PING_INFO_SIZE(NNIDS) \
+	offsetof(struct lnet_ping_info, pi_ni[NNIDS])
+#define LNET_PING_INFO_LONI(PINFO)	((PINFO)->pi_ni[0].ns_nid)
+#define LNET_PING_INFO_SEQNO(PINFO)	((PINFO)->pi_ni[0].ns_status)
+
 struct lnet_counters {
 	__u32	msgs_alloc;
 	__u32	msgs_max;
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 68af723bc6a1..d81501f4c282 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -313,6 +313,44 @@ static void lnet_assert_wire_constants(void)
 	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.hello.incarnation) != 8);
 	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.hello.type) != 40);
 	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.hello.type) != 4);
+
+	/* Checks for struct lnet_ni_status and related constants */
+	BUILD_BUG_ON(LNET_NI_STATUS_INVALID != 0x00000000);
+	BUILD_BUG_ON(LNET_NI_STATUS_UP != 0x15aac0de);
+	BUILD_BUG_ON(LNET_NI_STATUS_DOWN != 0xdeadface);
+
+	/* Checks for struct lnet_ni_status */
+	BUILD_BUG_ON((int)sizeof(struct lnet_ni_status) != 16);
+	BUILD_BUG_ON((int)offsetof(struct lnet_ni_status, ns_nid) != 0);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_ni_status *)0)->ns_nid) != 8);
+	BUILD_BUG_ON((int)offsetof(struct lnet_ni_status, ns_status) != 8);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_ni_status *)0)->ns_status) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_ni_status, ns_unused) != 12);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_ni_status *)0)->ns_unused) != 4);
+
+	/* Checks for struct lnet_ping_info and related constants */
+	BUILD_BUG_ON(LNET_PROTO_PING_MAGIC != 0x70696E67);
+	BUILD_BUG_ON(LNET_PING_FEAT_INVAL != 0);
+	BUILD_BUG_ON(LNET_PING_FEAT_BASE != 1);
+	BUILD_BUG_ON(LNET_PING_FEAT_NI_STATUS != 2);
+	BUILD_BUG_ON(LNET_PING_FEAT_RTE_DISABLED != 4);
+	BUILD_BUG_ON(LNET_PING_FEAT_MULTI_RAIL != 8);
+	BUILD_BUG_ON(LNET_PING_FEAT_DISCOVERY != 16);
+	BUILD_BUG_ON(LNET_PING_FEAT_BITS != 31);
+
+	/* Checks for struct lnet_ping_info */
+	BUILD_BUG_ON((int)sizeof(struct lnet_ping_info) != 16);
+	BUILD_BUG_ON((int)offsetof(struct lnet_ping_info, pi_magic) != 0);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_ping_info *)0)->pi_magic) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_ping_info, pi_features) != 4);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_ping_info *)0)->pi_features)
+		     != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_ping_info, pi_pid) != 8);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_ping_info *)0)->pi_pid) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_ping_info, pi_nnis) != 12);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_ping_info *)0)->pi_nnis) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_ping_info, pi_ni) != 16);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_ping_info *)0)->pi_ni) != 0);
 }
 
 static struct lnet_lnd *
