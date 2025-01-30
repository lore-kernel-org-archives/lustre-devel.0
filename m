Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9C0F9C0218F
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:42:32 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLhq72Lfz229t;
	Thu, 30 Jan 2025 06:18:03 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLZK5vP7z1xpR
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:12:25 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 268A9899AD9;
 Thu, 30 Jan 2025 09:11:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 22E9C106BE14; Thu, 30 Jan 2025 09:11:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:11:07 -0500
Message-ID: <20250130141115.950749-18-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 17/25] lustre: ptlrpc: grow PtlRPC properly
 when prepare sub request
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Mikhail Pershin <mpershin@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Qian Yingjin <qian@ddn.com>

In this patch, it prepares and grows PtlRPC reply buffer
properly for SUB batch request in @req_capsule_server_pack().

At the same time, it adds a limit of reply buffer size with
BUT_MAXREPSIZE = (1000 * 1024).

WC-bug-id: https://jira.whamcloud.com/browse/LU-14139
Lustre-commit: 5a2dfd36f9c2b6c10 ("LU-14139 ptlrpc: grow PtlRPC properly when prepare sub request")
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/43707
WC-bug-id: https://jira.whamcloud.com/browse/LU-16907
Lustre-commit: 8a7703eec9bb77a0d ("LU-16907 ptlrpc: correct the reply buffer size for batch RPC")
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/56645
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Timothy Day <timday@amazon.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h        |   5 +
 fs/lustre/include/lustre_req_layout.h |   3 +
 fs/lustre/mdc/mdc_batch.c             |   2 +-
 fs/lustre/ptlrpc/batch.c              |   5 +
 fs/lustre/ptlrpc/layout.c             | 191 +++++++++++++++++++++++++-
 fs/lustre/ptlrpc/pack_generic.c       |  70 ++++++++++
 6 files changed, 273 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index de1ef881d9d0..b8b4afe96230 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -265,6 +265,9 @@
 #define OUT_MAXREQSIZE	(1000 * 1024)
 #define OUT_MAXREPSIZE	MDS_MAXREPSIZE
 
+#define BUT_MAXREQSIZE	OUT_MAXREQSIZE
+#define BUT_MAXREPSIZE	BUT_MAXREQSIZE
+
  /*
   * LDLM threads constants:
   *
@@ -2051,6 +2054,7 @@ int lustre_pack_reply_flags(struct ptlrpc_request *, int count, u32 *lens,
 			    char **bufs, int flags);
 int lustre_shrink_msg(struct lustre_msg *msg, int segment,
 		      unsigned int newlen, int move_data);
+int lustre_grow_msg(struct lustre_msg *msg, int segment, unsigned int newlen);
 void lustre_free_reply_state(struct ptlrpc_reply_state *rs);
 int __lustre_unpack_msg(struct lustre_msg *m, int len);
 u32 lustre_msg_hdr_size(u32 magic, u32 count);
@@ -2061,6 +2065,7 @@ extern u32 lustre_msg_early_size;
 void *lustre_msg_buf_v2(struct lustre_msg_v2 *m, u32 n, u32 min_size);
 void *lustre_msg_buf(struct lustre_msg *m, u32 n, u32 minlen);
 u32 lustre_msg_buflen(struct lustre_msg *m, u32 n);
+void lustre_msg_set_buflen(struct lustre_msg *m, u32 n, u32 len);
 u32 lustre_msg_bufcount(struct lustre_msg *m);
 char *lustre_msg_string(struct lustre_msg *m, u32 n, u32 max_len);
 u32 lustre_msghdr_get_flags(struct lustre_msg *msg);
diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index 505e9a10c486..1504a591d96e 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -132,6 +132,9 @@ int req_capsule_field_present(const struct req_capsule *pill,
 void req_capsule_shrink(struct req_capsule *pill,
 			const struct req_msg_field *field,
 			u32 newlen, enum req_location loc);
+int req_capsule_server_grow(struct req_capsule *pill,
+			    const struct req_msg_field *field,
+			    u32 newlen);
 bool req_capsule_need_swab(struct req_capsule *pill, enum req_location loc,
 			   u32 index);
 void req_capsule_set_swabbed(struct req_capsule *pill, enum req_location loc,
diff --git a/fs/lustre/mdc/mdc_batch.c b/fs/lustre/mdc/mdc_batch.c
index 73f5a8c5f9ed..16805243165f 100644
--- a/fs/lustre/mdc/mdc_batch.c
+++ b/fs/lustre/mdc/mdc_batch.c
@@ -133,7 +133,7 @@ static int mdc_batch_getattr_pack(struct batch_update_head *head,
 	req_capsule_set_size(&pill, &RMF_ACL, RCL_SERVER,
 			     LUSTRE_POSIX_ACL_MAX_SIZE_OLD);
 	req_capsule_set_size(&pill, &RMF_DEFAULT_MDT_MD, RCL_SERVER,
-			     sizeof(struct lmv_user_md));
+			     /*sizeof(struct lmv_user_md)*/MIN_MD_SIZE);
 
 	if (have_secctx) {
 		char *secctx_name;
diff --git a/fs/lustre/ptlrpc/batch.c b/fs/lustre/ptlrpc/batch.c
index 75a6bc21b869..83342c7b3605 100644
--- a/fs/lustre/ptlrpc/batch.c
+++ b/fs/lustre/ptlrpc/batch.c
@@ -360,11 +360,16 @@ static int batch_update_request_fini(struct batch_update_head *head,
 			 */
 			repmsg = NULL;
 			rc1 = -ECANCELED;
+			/*
+			 * TODO: resend the unfinished sub request when the
+			 * return code is -EOVERFLOW.
+			 */
 		}
 
 		if (ouc->ouc_interpret)
 			ouc->ouc_interpret(req, repmsg, ouc, rc1);
 
+		index++;
 		object_update_callback_fini(ouc);
 		if (rc == 0 && rc1 < 0)
 			rc = rc1;
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 5beebb7776a3..3a9e83f5262b 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -1915,16 +1915,62 @@ int req_capsule_server_pack(struct req_capsule *pill)
 				   count, fmt->rf_name);
 		}
 	} else { /* SUB request */
+		struct ptlrpc_request *req = pill->rc_req;
+		u32 used_len;
 		u32 msg_len;
 
 		msg_len = lustre_msg_size_v2(count, pill->rc_area[RCL_SERVER]);
-		if (msg_len > pill->rc_reqmsg->lm_repsize) {
+		used_len = (char *)pill->rc_repmsg - (char *)req->rq_repmsg;
+		/* Overflow the reply buffer */
+		if (used_len + msg_len > req->rq_replen) {
+			u32 len;
+			u32 max;
+			u32 add;
+
+			if (!req_capsule_has_field(&req->rq_pill,
+						   &RMF_BUT_REPLY, RCL_SERVER))
+				return -EINVAL;
+
+			if (!req_capsule_field_present(&req->rq_pill,
+						       &RMF_BUT_REPLY,
+						       RCL_SERVER))
+				return -EINVAL;
+
+			if (used_len + msg_len > BUT_MAXREPSIZE)
+				return -EOVERFLOW;
+
+			len = req_capsule_get_size(&req->rq_pill,
+						    &RMF_BUT_REPLY, RCL_SERVER);
+			/*
+			 * Currently just increase the batch RPC reply buffer
+			 * (including @RMF_PTLRPC_BODY + @RMF_BUT_REPLY) by 2.
+			 * We must set the new length carefully as it will be
+			 * rounded up with 8.
+			 */
+			max = BUT_MAXREPSIZE - req->rq_replen;
+			add = len;
+			if (used_len + msg_len > len)
+				add = used_len + msg_len;
+
+			if (add > max)
+				len += max;
+			else
+				len += add;
+			rc = req_capsule_server_grow(&req->rq_pill,
+						     &RMF_BUT_REPLY, len);
+			if (rc)
+				return rc;
+
+			pill->rc_repmsg =
+			(struct lustre_msg *)((char *)req->rq_repmsg +
+						      used_len);
+		}
+		if (msg_len > pill->rc_reqmsg->lm_repsize)
 			/* TODO: Check whether there is enough buffer size */
 			CDEBUG(D_INFO,
 			       "Overflow pack %d fields in format '%s' for the SUB request with message len %u:%u\n",
 			       count, fmt->rf_name, msg_len,
 			       pill->rc_reqmsg->lm_repsize);
-		}
 
 		rc = 0;
 		lustre_init_msg_v2(pill->rc_repmsg, count,
@@ -2498,6 +2544,147 @@ void req_capsule_shrink(struct req_capsule *pill,
 }
 EXPORT_SYMBOL(req_capsule_shrink);
 
+int req_capsule_server_grow(struct req_capsule *pill,
+			    const struct req_msg_field *field,
+			    u32 newlen)
+{
+	struct ptlrpc_request *req = pill->rc_req;
+	struct ptlrpc_reply_state *rs = req->rq_reply_state, *nrs;
+	char *from, *to, *sptr = NULL;
+	u32 slen = 0, snewlen = 0;
+	u32 offset, len, max, diff;
+	int rc;
+
+	LASSERT(pill->rc_fmt);
+	LASSERT(__req_format_is_sane(pill->rc_fmt));
+	LASSERT(req_capsule_has_field(pill, field, RCL_SERVER));
+	LASSERT(req_capsule_field_present(pill, field, RCL_SERVER));
+
+	if (req_capsule_subreq(pill)) {
+		if (!req_capsule_has_field(&req->rq_pill, &RMF_BUT_REPLY,
+					   RCL_SERVER))
+			return -EINVAL;
+
+		if (!req_capsule_field_present(&req->rq_pill, &RMF_BUT_REPLY,
+					       RCL_SERVER))
+			return -EINVAL;
+
+		len = req_capsule_get_size(&req->rq_pill, &RMF_BUT_REPLY,
+					   RCL_SERVER);
+		sptr = req_capsule_server_get(&req->rq_pill, &RMF_BUT_REPLY);
+		slen = req_capsule_get_size(pill, field, RCL_SERVER);
+
+		LASSERT(len >= (char *)pill->rc_repmsg - sptr +
+			       lustre_packed_msg_size(pill->rc_repmsg));
+		if (len >= (char *)pill->rc_repmsg - sptr +
+			   lustre_packed_msg_size(pill->rc_repmsg) - slen +
+			   newlen) {
+			req_capsule_set_size(pill, field, RCL_SERVER, newlen);
+			offset = __req_capsule_offset(pill, field, RCL_SERVER);
+			lustre_grow_msg(pill->rc_repmsg, offset, newlen);
+			return 0;
+		}
+
+		/*
+		 * Currently first try to increase the reply buffer by
+		 * 2 * newlen with reply buffer limit of BUT_MAXREPSIZE.
+		 * TODO: Enlarge the reply buffer properly according to the
+		 * left SUB requests in the batch PTLRPC request.
+		 */
+		snewlen = newlen;
+		diff = snewlen - slen;
+		max = BUT_MAXREPSIZE - req->rq_replen;
+		if (diff > max)
+			return -EOVERFLOW;
+
+		if (diff * 2 + len < max)
+			newlen = (len + diff) * 2;
+		else
+			newlen = len + max;
+
+		req_capsule_set_size(pill, field, RCL_SERVER, snewlen);
+		req_capsule_set_size(&req->rq_pill, &RMF_BUT_REPLY, RCL_SERVER,
+				     newlen);
+		offset = __req_capsule_offset(&req->rq_pill, &RMF_BUT_REPLY,
+					      RCL_SERVER);
+	} else {
+		len = req_capsule_get_size(pill, field, RCL_SERVER);
+		offset = __req_capsule_offset(pill, field, RCL_SERVER);
+		req_capsule_set_size(pill, field, RCL_SERVER, newlen);
+	}
+
+	CDEBUG(D_INFO, "Reply packed: %d, allocated: %d, field len %d -> %d\n",
+	       lustre_packed_msg_size(rs->rs_msg), rs->rs_repbuf_len,
+				      len, newlen);
+
+	/**
+	 * There can be enough space in current reply buffer, make sure
+	 * that rs_repbuf is not a wrapper but real reply msg, otherwise
+	 * re-packing is still needed.
+	 */
+	if (rs->rs_msg == rs->rs_repbuf &&
+	    rs->rs_repbuf_len >=
+	    lustre_packed_msg_size(rs->rs_msg) - len + newlen) {
+		req->rq_replen = lustre_grow_msg(rs->rs_msg, offset, newlen);
+		return 0;
+	}
+
+	/* Re-allocate replay state */
+	req->rq_reply_state = NULL;
+	rc = req_capsule_server_pack(&req->rq_pill);
+	if (rc) {
+		/* put old values back, the caller should decide what to do */
+		if (req_capsule_subreq(pill)) {
+			req_capsule_set_size(&req->rq_pill, &RMF_BUT_REPLY,
+					     RCL_SERVER, len);
+			req_capsule_set_size(pill, field, RCL_SERVER, slen);
+		} else {
+			req_capsule_set_size(pill, field, RCL_SERVER, len);
+		}
+		pill->rc_req->rq_reply_state = rs;
+		return rc;
+	}
+	nrs = req->rq_reply_state;
+	LASSERT(lustre_packed_msg_size(nrs->rs_msg) >
+		lustre_packed_msg_size(rs->rs_msg));
+
+	/* Now we need only buffers, copy them and grow the needed one */
+	to = lustre_msg_buf(nrs->rs_msg, 0, 0);
+	from = lustre_msg_buf(rs->rs_msg, 0, 0);
+	memcpy(to, from,
+	       (char *)rs->rs_msg + lustre_packed_msg_size(rs->rs_msg) - from);
+	lustre_msg_set_buflen(nrs->rs_msg, offset, len);
+	req->rq_replen = lustre_grow_msg(nrs->rs_msg, offset, newlen);
+
+	if (req_capsule_subreq(pill)) {
+		char *ptr;
+
+		ptr = req_capsule_server_get(&req->rq_pill, &RMF_BUT_REPLY);
+		pill->rc_repmsg = (struct lustre_msg *)(ptr +
+				  ((char *)pill->rc_repmsg - sptr));
+		offset = __req_capsule_offset(pill, field, RCL_SERVER);
+		lustre_grow_msg(pill->rc_repmsg, offset, snewlen);
+	}
+
+	if (rs->rs_difficult) {
+		/* copy rs data */
+		int i;
+
+		nrs->rs_difficult = 1;
+		nrs->rs_no_ack = rs->rs_no_ack;
+		for (i = 0; i < rs->rs_nlocks; i++) {
+			nrs->rs_locks[i] = rs->rs_locks[i];
+			nrs->rs_nlocks++;
+		}
+		rs->rs_nlocks = 0;
+		rs->rs_difficult = 0;
+		rs->rs_no_ack = 0;
+	}
+	ptlrpc_rs_decref(rs);
+	return 0;
+}
+EXPORT_SYMBOL(req_capsule_server_grow);
+
 void req_capsule_subreq_init(struct req_capsule *pill,
 			     const struct req_format *fmt,
 			     struct ptlrpc_request *req,
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 53e2912a28e7..16058b9cd9be 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -454,6 +454,58 @@ int lustre_shrink_msg(struct lustre_msg *msg, int segment,
 }
 EXPORT_SYMBOL(lustre_shrink_msg);
 
+static int lustre_grow_msg_v2(struct lustre_msg_v2 *msg, __u32 segment,
+			      unsigned int newlen)
+{
+	char *tail = NULL, *newpos;
+	int tail_len = 0, n;
+
+	LASSERT(msg);
+	LASSERT(msg->lm_bufcount > segment);
+	LASSERT(msg->lm_buflens[segment] <= newlen);
+
+	if (msg->lm_buflens[segment] == newlen)
+		goto out;
+
+	if (msg->lm_bufcount > segment + 1) {
+		tail = lustre_msg_buf_v2(msg, segment + 1, 0);
+		for (n = segment + 1; n < msg->lm_bufcount; n++)
+			tail_len += round_up(msg->lm_buflens[n], 8);
+	}
+
+	msg->lm_buflens[segment] = newlen;
+
+	if (tail && tail_len) {
+		newpos = lustre_msg_buf_v2(msg, segment + 1, 0);
+		memmove(newpos, tail, tail_len);
+	}
+out:
+	return lustre_msg_size_v2(msg->lm_bufcount, msg->lm_buflens);
+}
+
+/*
+ * for @msg, grow @segment to size @newlen.
+ * Always move higher buffer forward.
+ *
+ * return new msg size after growing.
+ *
+ * CAUTION:
+ * - caller must make sure there is enough space in allocated message buffer
+ * - caller should NOT keep pointers to msg buffers which higher than @segment
+ *   after call shrink.
+ */
+int lustre_grow_msg(struct lustre_msg *msg, int segment, unsigned int newlen)
+{
+	switch (msg->lm_magic) {
+	case LUSTRE_MSG_MAGIC_V2:
+		return lustre_grow_msg_v2(msg, segment, newlen);
+	default:
+		LASSERTF(0, "incorrect message magic: %08x\n", msg->lm_magic);
+		return -EINVAL;
+	}
+}
+EXPORT_SYMBOL(lustre_grow_msg);
+
 void lustre_free_reply_state(struct ptlrpc_reply_state *rs)
 {
 	PTLRPC_RS_DEBUG_LRU_DEL(rs);
@@ -660,6 +712,24 @@ u32 lustre_msg_buflen(struct lustre_msg *m, u32 n)
 }
 EXPORT_SYMBOL(lustre_msg_buflen);
 
+static inline void
+lustre_msg_set_buflen_v2(struct lustre_msg_v2 *m, u32 n, u32 len)
+{
+	LASSERT(n < m->lm_bufcount);
+	m->lm_buflens[n] = len;
+}
+
+void lustre_msg_set_buflen(struct lustre_msg *m, u32 n, u32 len)
+{
+	switch (m->lm_magic) {
+	case LUSTRE_MSG_MAGIC_V2:
+		lustre_msg_set_buflen_v2(m, n, len);
+		return;
+	default:
+		LASSERTF(0, "incorrect message magic: %08x\n", m->lm_magic);
+	}
+}
+
 /* NB return the bufcount for lustre_msg_v2 format, so if message is packed
  * in V1 format, the result is one bigger. (add struct ptlrpc_body).
  */
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
