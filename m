From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:43:47 -0400
Subject: [lustre-devel] [PATCH 04/29] staging/lustre: Remove unused
	req_capsule_server_grow
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-5-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

It's only used on the server

Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../lustre/lustre/include/lustre_req_layout.h      |  3 --
 drivers/staging/lustre/lustre/ptlrpc/layout.c      | 62 ----------------------
 2 files changed, 65 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index c6457b2..04c0076 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -129,9 +129,6 @@ void req_capsule_shrink(struct req_capsule *pill,
 			const struct req_msg_field *field,
 			unsigned int newlen,
 			enum req_location loc);
-int req_capsule_server_grow(struct req_capsule *pill,
-			    const struct req_msg_field *field,
-			    unsigned int newlen);
 int  req_layout_init(void);
 void req_layout_fini(void);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 5d19cfc..4ddbe0d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -2376,67 +2376,5 @@ void req_capsule_shrink(struct req_capsule *pill,
 }
 EXPORT_SYMBOL(req_capsule_shrink);
 
-int req_capsule_server_grow(struct req_capsule *pill,
-			    const struct req_msg_field *field,
-			    unsigned int newlen)
-{
-	struct ptlrpc_reply_state *rs = pill->rc_req->rq_reply_state, *nrs;
-	char *from, *to;
-	int offset, len, rc;
-
-	LASSERT(pill->rc_fmt != NULL);
-	LASSERT(__req_format_is_sane(pill->rc_fmt));
-	LASSERT(req_capsule_has_field(pill, field, RCL_SERVER));
-	LASSERT(req_capsule_field_present(pill, field, RCL_SERVER));
-
-	len = req_capsule_get_size(pill, field, RCL_SERVER);
-	offset = __req_capsule_offset(pill, field, RCL_SERVER);
-	if (pill->rc_req->rq_repbuf_len >=
-	    lustre_packed_msg_size(pill->rc_req->rq_repmsg) - len + newlen)
-		CERROR("Inplace repack might be done\n");
-
-	pill->rc_req->rq_reply_state = NULL;
-	req_capsule_set_size(pill, field, RCL_SERVER, newlen);
-	rc = req_capsule_server_pack(pill);
-	if (rc) {
-		/* put old rs back, the caller will decide what to do */
-		pill->rc_req->rq_reply_state = rs;
-		return rc;
-	}
-	nrs = pill->rc_req->rq_reply_state;
-	/* Now we need only buffers, copy first chunk */
-	to = lustre_msg_buf(nrs->rs_msg, 0, 0);
-	from = lustre_msg_buf(rs->rs_msg, 0, 0);
-	len = (char *)lustre_msg_buf(rs->rs_msg, offset, 0) - from;
-	memcpy(to, from, len);
-	/* check if we have tail and copy it too */
-	if (rs->rs_msg->lm_bufcount > offset + 1) {
-		to = lustre_msg_buf(nrs->rs_msg, offset + 1, 0);
-		from = lustre_msg_buf(rs->rs_msg, offset + 1, 0);
-		offset = rs->rs_msg->lm_bufcount - 1;
-		len = (char *)lustre_msg_buf(rs->rs_msg, offset, 0) +
-		      cfs_size_round(rs->rs_msg->lm_buflens[offset]) - from;
-		memcpy(to, from, len);
-	}
-	/* drop old reply if everything is fine */
-	if (rs->rs_difficult) {
-		/* copy rs data */
-		int i;
-
-		nrs->rs_difficult = 1;
-		nrs->rs_no_ack = rs->rs_no_ack;
-		for (i = 0; i < rs->rs_nlocks; i++) {
-			nrs->rs_locks[i] = rs->rs_locks[i];
-			nrs->rs_modes[i] = rs->rs_modes[i];
-			nrs->rs_nlocks++;
-		}
-		rs->rs_nlocks = 0;
-		rs->rs_difficult = 0;
-		rs->rs_no_ack = 0;
-	}
-	ptlrpc_rs_decref(rs);
-	return 0;
-}
-EXPORT_SYMBOL(req_capsule_server_grow);
 /* __REQ_LAYOUT_USER__ */
 #endif
-- 
2.1.0
