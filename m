From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:13 -0500
Subject: [lustre-devel] [PATCH 445/622] lustre: ptlrpc: check lm_bufcount
 and lm_buflen
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-446-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Emoly Liu <emoly@whamcloud.com>

Check lm_bufcount to be used by lustre_msg_hdr_size_v2() and
validate individual and total buffer lengths in
lustre_unpack_msg_v2() in case of any out-of-bound read.

Reported-by: Alibaba Cloud <yunye.ry@alibaba-inc.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-12590
Lustre-commit: 268edb13d769 ("LU-12590 ptlrpc: check lm_bufcount and lm_buflen")
Signed-off-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35783
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Yunye Ry <yunye.ry@alibaba-inc.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h  | 40 ++++++++++++++++++++++++++++++++++++++++
 fs/lustre/ptlrpc/pack_generic.c | 29 +++++++++++++++++++++++------
 2 files changed, 63 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index d03e8c6..caf766d 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -238,6 +238,34 @@
  *
  */
 
+/**
+ * This is the size of a maximum REINT_SETXATTR request:
+ *
+ *   lustre_msg		 56 (32 + 4 x 5 + 4)
+ *   ptlrpc_body	184
+ *   mdt_rec_setxattr	136
+ *   lustre_capa	120
+ *   name		256 (XATTR_NAME_MAX)
+ *   value	      65536 (XATTR_SIZE_MAX)
+ */
+#define MDS_EA_MAXREQSIZE	66288
+
+/**
+ * These are the maximum request and reply sizes (rounded up to 1 KB
+ * boundaries) for the "regular" MDS_REQUEST_PORTAL and MDS_REPLY_PORTAL.
+ */
+#define MDS_REG_MAXREQSIZE	(((max(MDS_EA_MAXREQSIZE, \
+				       MDS_LOV_MAXREQSIZE) + 1023) >> 10) << 10)
+#define MDS_REG_MAXREPSIZE	MDS_REG_MAXREQSIZE
+
+/**
+ * The update request includes all of updates from the create, which might
+ * include linkea (4K maxim), together with other updates, we set it to 1000K:
+ * lustre_msg + ptlrpc_body + OUT_UPDATE_BUFFER_SIZE_MAX
+ */
+#define OUT_MAXREQSIZE	(1000 * 1024)
+#define OUT_MAXREPSIZE	MDS_MAXREPSIZE
+
  /*
   * LDLM threads constants:
   *
@@ -291,6 +319,12 @@
 				 (DT_MAX_BRW_PAGES - 1)))
 
 /**
+ * MDS incoming request with LOV EA
+ * 24 = sizeof(struct lov_ost_data), i.e: replay of opencreate
+ */
+#define MDS_LOV_MAXREQSIZE	max(MDS_MAXREQSIZE, \
+				    362 + LOV_MAX_STRIPE_COUNT * 24)
+/**
  * FIEMAP request can be 4K+ for now
  */
 #define OST_MAXREQSIZE		(16UL * 1024UL)
@@ -2017,6 +2051,12 @@ struct ptlrpc_service *ptlrpc_register_service(struct ptlrpc_service_conf *conf,
  *
  * @{
  */
+#define PTLRPC_MAX_BUFCOUNT \
+	(sizeof(((struct ptlrpc_request *)0)->rq_req_swab_mask) * 8)
+#define MD_MAX_BUFLEN		(MDS_REG_MAXREQSIZE > OUT_MAXREQSIZE ? \
+				 MDS_REG_MAXREQSIZE : OUT_MAXREQSIZE)
+#define PTLRPC_MAX_BUFLEN	(OST_IO_MAXREQSIZE > MD_MAX_BUFLEN ? \
+				 OST_IO_MAXREQSIZE : MD_MAX_BUFLEN)
 bool ptlrpc_buf_need_swab(struct ptlrpc_request *req, const int inout,
 			  u32 index);
 void ptlrpc_buf_set_swabbed(struct ptlrpc_request *req, const int inout,
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index e63720b..4a0856a 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -60,6 +60,8 @@ static inline u32 lustre_msg_hdr_size_v2(u32 count)
 
 u32 lustre_msg_hdr_size(u32 magic, u32 count)
 {
+	LASSERT(count > 0);
+
 	switch (magic) {
 	case LUSTRE_MSG_MAGIC_V2:
 		return lustre_msg_hdr_size_v2(count);
@@ -102,6 +104,7 @@ u32 lustre_msg_size_v2(int count, u32 *lengths)
 	u32 size;
 	int i;
 
+	LASSERT(count > 0);
 	size = lustre_msg_hdr_size_v2(count);
 	for (i = 0; i < count; i++)
 		size += cfs_size_round(lengths[i]);
@@ -159,6 +162,8 @@ void lustre_init_msg_v2(struct lustre_msg_v2 *msg, int count, u32 *lens,
 	char *ptr;
 	int i;
 
+	LASSERT(count > 0);
+
 	msg->lm_bufcount = count;
 	/* XXX: lm_secflvr uninitialized here */
 	msg->lm_magic = LUSTRE_MSG_MAGIC_V2;
@@ -291,6 +296,7 @@ int lustre_pack_reply_v2(struct ptlrpc_request *req, int count,
 	int msg_len, rc;
 
 	LASSERT(!req->rq_reply_state);
+	LASSERT(count > 0);
 
 	if ((flags & LPRFL_EARLY_REPLY) == 0) {
 		spin_lock(&req->rq_lock);
@@ -366,6 +372,9 @@ void *lustre_msg_buf_v2(struct lustre_msg_v2 *m, u32 n, u32 min_size)
 {
 	u32 i, offset, buflen, bufcount;
 
+	LASSERT(m);
+	LASSERT(m->lm_bufcount > 0);
+
 	bufcount = m->lm_bufcount;
 	if (unlikely(n >= bufcount)) {
 		CDEBUG(D_INFO, "msg %p buffer[%d] not present (count %d)\n",
@@ -479,7 +488,7 @@ void lustre_free_reply_state(struct ptlrpc_reply_state *rs)
 
 static int lustre_unpack_msg_v2(struct lustre_msg_v2 *m, int len)
 {
-	int swabbed, required_len, i;
+	int swabbed, required_len, i, buflen;
 
 	/* Now we know the sender speaks my language. */
 	required_len = lustre_msg_hdr_size_v2(0);
@@ -502,6 +511,10 @@ static int lustre_unpack_msg_v2(struct lustre_msg_v2 *m, int len)
 		BUILD_BUG_ON(offsetof(typeof(*m), lm_padding_3) == 0);
 	}
 
+	if (m->lm_bufcount == 0 || m->lm_bufcount > PTLRPC_MAX_BUFCOUNT) {
+		CERROR("message bufcount %d is not valid\n", m->lm_bufcount);
+		return -EINVAL;
+	}
 	required_len = lustre_msg_hdr_size_v2(m->lm_bufcount);
 	if (len < required_len) {
 		/* didn't receive all the buffer lengths */
@@ -513,12 +526,16 @@ static int lustre_unpack_msg_v2(struct lustre_msg_v2 *m, int len)
 	for (i = 0; i < m->lm_bufcount; i++) {
 		if (swabbed)
 			__swab32s(&m->lm_buflens[i]);
-		required_len += cfs_size_round(m->lm_buflens[i]);
+		buflen = cfs_size_round(m->lm_buflens[i]);
+		if (buflen < 0 || buflen > PTLRPC_MAX_BUFLEN) {
+			CERROR("buffer %d length %d is not valid\n", i, buflen);
+			return -EINVAL;
+		}
+		required_len += buflen;
 	}
-
-	if (len < required_len) {
-		CERROR("len: %d, required_len %d\n", len, required_len);
-		CERROR("bufcount: %d\n", m->lm_bufcount);
+	if (len < required_len || required_len > PTLRPC_MAX_BUFLEN) {
+		CERROR("len: %d, required_len %d, bufcount: %d\n",
+		       len, required_len, m->lm_bufcount);
 		for (i = 0; i < m->lm_bufcount; i++)
 			CERROR("buffer %d length %d\n", i, m->lm_buflens[i]);
 		return -EINVAL;
-- 
1.8.3.1
