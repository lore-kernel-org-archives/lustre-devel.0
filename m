From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:10 -0400
Subject: [lustre-devel] [PATCH 14/41] staging: lustre: ptlrpc: Add a tag
	field to ptlrpc messages
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Gregoire Pichon <gregoire.pichon@bull.net>, James Simmons <jsimmons@infradead.org>

From: Gregoire Pichon <gregoire.pichon@bull.net>

The new tag field is used as a virtual index for multiple modifying
RPCs management. It is set by the client and allows the target to
release in-memory reply data when the tag is reused by a new RPC.

The tag field replaces the unused last_seen field of ptlrpcd_body
structure.

Additionally, the last_xid field is used to transfer the highest XID
for which a reply has been received and does not have an unreplied
lower-numbered XID.

Signed-off-by: Gregoire Pichon <gregoire.pichon@bull.net>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5319
Reviewed-on: http://review.whamcloud.com/14095
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |   12 ++++--
 drivers/staging/lustre/lustre/include/lustre_net.h |    2 +
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   39 +++++++++++++++++++-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |   32 ++++++++++++----
 4 files changed, 72 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index b88807f..4f6eeec 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1099,8 +1099,10 @@ struct ptlrpc_body_v3 {
 	__u32 pb_version;
 	__u32 pb_opc;
 	__u32 pb_status;
-	__u64 pb_last_xid;
-	__u64 pb_last_seen;
+	__u64 pb_last_xid; /* highest replied XID without lower unreplied XID */
+	__u16 pb_tag;      /* virtual slot idx for multiple modifying RPCs */
+	__u16 pb_padding0;
+	__u32 pb_padding1;
 	__u64 pb_last_committed;
 	__u64 pb_transno;
 	__u32 pb_flags;
@@ -1125,8 +1127,10 @@ struct ptlrpc_body_v2 {
 	__u32 pb_version;
 	__u32 pb_opc;
 	__u32 pb_status;
-	__u64 pb_last_xid;
-	__u64 pb_last_seen;
+	__u64 pb_last_xid; /* highest replied XID without lower unreplied XID */
+	__u16 pb_tag;      /* virtual slot idx for multiple modifying RPCs */
+	__u16 pb_padding0;
+	__u32 pb_padding1;
 	__u64 pb_last_committed;
 	__u64 pb_transno;
 	__u32 pb_flags;
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index e9aba99..ab80330 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -2652,6 +2652,7 @@ struct lustre_handle *lustre_msg_get_handle(struct lustre_msg *msg);
 __u32 lustre_msg_get_type(struct lustre_msg *msg);
 void lustre_msg_add_version(struct lustre_msg *msg, u32 version);
 __u32 lustre_msg_get_opc(struct lustre_msg *msg);
+__u16 lustre_msg_get_tag(struct lustre_msg *msg);
 __u64 lustre_msg_get_last_committed(struct lustre_msg *msg);
 __u64 *lustre_msg_get_versions(struct lustre_msg *msg);
 __u64 lustre_msg_get_transno(struct lustre_msg *msg);
@@ -2670,6 +2671,7 @@ void lustre_msg_set_handle(struct lustre_msg *msg,
 			   struct lustre_handle *handle);
 void lustre_msg_set_type(struct lustre_msg *msg, __u32 type);
 void lustre_msg_set_opc(struct lustre_msg *msg, __u32 opc);
+void lustre_msg_set_tag(struct lustre_msg *msg, __u16 tag);
 void lustre_msg_set_versions(struct lustre_msg *msg, __u64 *versions);
 void lustre_msg_set_transno(struct lustre_msg *msg, __u64 transno);
 void lustre_msg_set_status(struct lustre_msg *msg, __u32 status);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 2dc0b79..3055649 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -942,6 +942,25 @@ __u32 lustre_msg_get_opc(struct lustre_msg *msg)
 }
 EXPORT_SYMBOL(lustre_msg_get_opc);
 
+__u16 lustre_msg_get_tag(struct lustre_msg *msg)
+{
+	switch (msg->lm_magic) {
+	case LUSTRE_MSG_MAGIC_V2: {
+		struct ptlrpc_body *pb = lustre_msg_ptlrpc_body(msg);
+
+		if (!pb) {
+			CERROR("invalid msg %p: no ptlrpc body!\n", msg);
+			return 0;
+		}
+		return pb->pb_tag;
+	}
+	default:
+		CERROR("incorrect message magic: %08x\n", msg->lm_magic);
+		return 0;
+	}
+}
+EXPORT_SYMBOL(lustre_msg_get_tag);
+
 __u64 lustre_msg_get_last_committed(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
@@ -1236,6 +1255,22 @@ void lustre_msg_set_opc(struct lustre_msg *msg, __u32 opc)
 	}
 }
 
+void lustre_msg_set_tag(struct lustre_msg *msg, __u16 tag)
+{
+	switch (msg->lm_magic) {
+	case LUSTRE_MSG_MAGIC_V2: {
+		struct ptlrpc_body *pb = lustre_msg_ptlrpc_body(msg);
+
+		LASSERTF(pb, "invalid msg %p: no ptlrpc body!\n", msg);
+		pb->pb_tag = tag;
+		return;
+	}
+	default:
+		LASSERTF(0, "incorrect message magic: %08x\n", msg->lm_magic);
+	}
+}
+EXPORT_SYMBOL(lustre_msg_set_tag);
+
 void lustre_msg_set_versions(struct lustre_msg *msg, __u64 *versions)
 {
 	switch (msg->lm_magic) {
@@ -1442,7 +1477,7 @@ void lustre_swab_ptlrpc_body(struct ptlrpc_body *b)
 	__swab32s(&b->pb_opc);
 	__swab32s(&b->pb_status);
 	__swab64s(&b->pb_last_xid);
-	__swab64s(&b->pb_last_seen);
+	__swab16s(&b->pb_tag);
 	__swab64s(&b->pb_last_committed);
 	__swab64s(&b->pb_transno);
 	__swab32s(&b->pb_flags);
@@ -1456,6 +1491,8 @@ void lustre_swab_ptlrpc_body(struct ptlrpc_body *b)
 	__swab64s(&b->pb_pre_versions[1]);
 	__swab64s(&b->pb_pre_versions[2]);
 	__swab64s(&b->pb_pre_versions[3]);
+	CLASSERT(offsetof(typeof(*b), pb_padding0) != 0);
+	CLASSERT(offsetof(typeof(*b), pb_padding1) != 0);
 	CLASSERT(offsetof(typeof(*b), pb_padding) != 0);
 	/* While we need to maintain compatibility between
 	 * clients and servers without ptlrpc_body_v2 (< 2.3)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index c299099..d5af8cd 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -635,10 +635,18 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_last_xid));
 	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_last_xid) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_last_xid));
-	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_last_seen) == 32, "found %lld\n",
-		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_last_seen));
-	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_last_seen) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_last_seen));
+	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_tag) == 32, "found %lld\n",
+		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_tag));
+	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_tag) == 2, "found %lld\n",
+		 (long long)(int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_tag));
+	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_padding0) == 34, "found %lld\n",
+		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_padding0));
+	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding0) == 2, "found %lld\n",
+		 (long long)(int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding0));
+	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_padding1) == 36, "found %lld\n",
+		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_padding1));
+	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding1) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding1));
 	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_last_committed) == 40, "found %lld\n",
 		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_last_committed));
 	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_last_committed) == 8, "found %lld\n",
@@ -713,10 +721,18 @@ void lustre_assert_wire_constants(void)
 		 (int)offsetof(struct ptlrpc_body_v3, pb_last_xid), (int)offsetof(struct ptlrpc_body_v2, pb_last_xid));
 	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_last_xid) == (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_last_xid), "%d != %d\n",
 		 (int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_last_xid), (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_last_xid));
-	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_last_seen) == (int)offsetof(struct ptlrpc_body_v2, pb_last_seen), "%d != %d\n",
-		 (int)offsetof(struct ptlrpc_body_v3, pb_last_seen), (int)offsetof(struct ptlrpc_body_v2, pb_last_seen));
-	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_last_seen) == (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_last_seen), "%d != %d\n",
-		 (int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_last_seen), (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_last_seen));
+	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_tag) == (int)offsetof(struct ptlrpc_body_v2, pb_tag), "%d != %d\n",
+		 (int)offsetof(struct ptlrpc_body_v3, pb_tag), (int)offsetof(struct ptlrpc_body_v2, pb_tag));
+	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_tag) == (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_tag), "%d != %d\n",
+		 (int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_tag), (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_tag));
+	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_padding0) == (int)offsetof(struct ptlrpc_body_v2, pb_padding0), "%d != %d\n",
+		 (int)offsetof(struct ptlrpc_body_v3, pb_padding0), (int)offsetof(struct ptlrpc_body_v2, pb_padding0));
+	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding0) == (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_padding0), "%d != %d\n",
+		 (int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding0), (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_padding0));
+	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_padding1) == (int)offsetof(struct ptlrpc_body_v2, pb_padding1), "%d != %d\n",
+		 (int)offsetof(struct ptlrpc_body_v3, pb_padding1), (int)offsetof(struct ptlrpc_body_v2, pb_padding1));
+	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding1) == (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_padding1), "%d != %d\n",
+		 (int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding1), (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_padding1));
 	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_last_committed) == (int)offsetof(struct ptlrpc_body_v2, pb_last_committed), "%d != %d\n",
 		 (int)offsetof(struct ptlrpc_body_v3, pb_last_committed), (int)offsetof(struct ptlrpc_body_v2, pb_last_committed));
 	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_last_committed) == (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_last_committed), "%d != %d\n",
-- 
1.7.1
