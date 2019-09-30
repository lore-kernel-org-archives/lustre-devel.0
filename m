From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:09 -0400
Subject: [lustre-devel] [PATCH 110/151] lustre: idl: add PTLRPC definitions
 to enum
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-111-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

PTLRPC definitions to enums for cleanliness, and use them:

enum lustre_msg_version for LUSTRE_*_VERSION
enum lustre_msg_magic for LUSTRE_MSG_MAGIC_*
enum lustre_msghdr for MSGHDR_*

WC-bug-id: https://jira.whamcloud.com/browse/LU-6349
Lustre-commit: 0c9bb26fc4d9 ("LU-6349 idl: add PTLRPC definitions to enum")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/30958
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Emoly Liu <emoly.liu@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_import.h      |  7 ++++--
 fs/lustre/ptlrpc/pack_generic.c        |  4 ++--
 include/uapi/linux/lustre/lustre_idl.h | 44 +++++++++++++++++++---------------
 3 files changed, 32 insertions(+), 23 deletions(-)

diff --git a/fs/lustre/include/lustre_import.h b/fs/lustre/include/lustre_import.h
index 2d8f6be..ad06f30 100644
--- a/fs/lustre/include/lustre_import.h
+++ b/fs/lustre/include/lustre_import.h
@@ -308,8 +308,11 @@ struct obd_import {
 	u64				imp_connect_flags2_orig;
 	int				imp_connect_error;
 
-	u32				imp_msg_magic;
-	u32				imp_msghdr_flags; /* adjusted based on server capability */
+	enum lustre_msg_magic		imp_msg_magic;
+					/* adjusted based on server
+					 * capability
+					 */
+	enum lustre_msghdr		imp_msghdr_flags;
 
 	struct imp_at			imp_at;	/* adaptive timeout data */
 	time64_t			imp_last_reply_time; /* for health check */
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 1ba2772..cac4b8d 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -749,7 +749,7 @@ static inline struct ptlrpc_body *lustre_msg_ptlrpc_body(struct lustre_msg *msg)
 				 sizeof(struct ptlrpc_body_v2));
 }
 
-u32 lustre_msghdr_get_flags(struct lustre_msg *msg)
+enum lustre_msghdr lustre_msghdr_get_flags(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2:
@@ -762,7 +762,7 @@ u32 lustre_msghdr_get_flags(struct lustre_msg *msg)
 }
 EXPORT_SYMBOL(lustre_msghdr_get_flags);
 
-void lustre_msghdr_set_flags(struct lustre_msg *msg, u32 flags)
+void lustre_msghdr_set_flags(struct lustre_msg *msg, enum lustre_msghdr flags)
 {
 	switch (msg->lm_magic) {
 	case LUSTRE_MSG_MAGIC_V2:
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index cd4e0e9..cf35813 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -530,18 +530,22 @@ static inline void lustre_handle_copy(struct lustre_handle *tgt,
 }
 
 /* lustre_msg struct magic.  DON'T use swabbed values of MAGIC as magic! */
-#define LUSTRE_MSG_MAGIC_V2		0x0BD00BD3
-#define LUSTRE_MSG_MAGIC_V2_SWABBED	0xD30BD00B
-#define LUSTRE_MSG_MAGIC		LUSTRE_MSG_MAGIC_V2
+enum lustre_msg_magic {
+	LUSTRE_MSG_MAGIC_V2		= 0x0BD00BD3,
+	LUSTRE_MSG_MAGIC_V2_SWABBED	= 0xD30BD00B,
+	LUSTRE_MSG_MAGIC		= LUSTRE_MSG_MAGIC_V2,
+};
 
 /* flags for lm_flags */
-#define MSGHDR_AT_SUPPORT		0x1 /* adaptive timeouts, lm_cksum valid
-					     * in early reply messages
-					     */
-#define MSGHDR_CKSUM_INCOMPAT18		0x2 /* compat for 1.8, needs to be set
-					     * well beyond 2.8.0 for
-					     * compatibility
-					     */
+enum lustre_msghdr {
+	MSGHDR_AT_SUPPORT	= 0x1,/* adaptive timeouts, lm_cksum valid
+				       * in early reply messages
+				       */
+	MSGHDR_CKSUM_INCOMPAT18	= 0x2,/* compat for 1.8, needs to be set
+				       * well beyond 2.8.0 for
+				       * compatibility
+				       */
+};
 
 #define lustre_msg lustre_msg_v2
 /* we depend on this structure to be 8-byte aligned */
@@ -552,7 +556,7 @@ struct lustre_msg_v2 {
 	__u32 lm_magic;		/* RPC version magic = LUSTRE_MSG_MAGIC_V2 */
 	__u32 lm_repsize;	/* size of preallocated reply buffer */
 	__u32 lm_cksum;		/* CRC32 of ptlrpc_body early reply messages */
-	__u32 lm_flags;		/* MSGHDR_* flags */
+	__u32 lm_flags;		/* enum lustre_msghdr MSGHDR_* flags */
 	__u32 lm_padding_2;	/* unused */
 	__u32 lm_padding_3;	/* unused */
 	__u32 lm_buflens[0];	/* length of additional buffers in bytes,
@@ -570,14 +574,16 @@ struct lustre_msg_v2 {
 #define PTL_RPC_MSG_REPLY	4713	/* normal RPC reply message */
 
 /* ptlrpc_body pb_version ((target_version << 16) | rpc_version) */
-#define PTLRPC_MSG_VERSION	0x00000003
-#define LUSTRE_VERSION_MASK	0xffff0000
-#define LUSTRE_OBD_VERSION	0x00010000
-#define LUSTRE_MDS_VERSION	0x00020000
-#define LUSTRE_OST_VERSION	0x00030000
-#define LUSTRE_DLM_VERSION	0x00040000
-#define LUSTRE_LOG_VERSION	0x00050000
-#define LUSTRE_MGS_VERSION	0x00060000
+enum lustre_msg_version {
+	PTLRPC_MSG_VERSION	= 0x00000003,
+	LUSTRE_VERSION_MASK	= 0xffff0000,
+	LUSTRE_OBD_VERSION	= 0x00010000,
+	LUSTRE_MDS_VERSION	= 0x00020000,
+	LUSTRE_OST_VERSION	= 0x00030000,
+	LUSTRE_DLM_VERSION	= 0x00040000,
+	LUSTRE_LOG_VERSION	= 0x00050000,
+	LUSTRE_MGS_VERSION	= 0x00060000,
+};
 
 /* pb_flags that apply to all request messages */
 /* #define MSG_LAST_REPLAY	0x0001 obsolete 2.0 => {REQ,LOCK}_REPLAY_DONE */
-- 
1.8.3.1
