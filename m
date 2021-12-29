Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C7FDFC433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 29 Dec 2021 14:52:00 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BADED3AD59A;
	Wed, 29 Dec 2021 06:51:56 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E7E0E3AD4FC
 for <lustre-devel@lists.lustre.org>; Wed, 29 Dec 2021 06:51:32 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 9E6811006F14;
 Wed, 29 Dec 2021 09:51:28 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9B6EDD9E71; Wed, 29 Dec 2021 09:51:28 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed, 29 Dec 2021 09:51:24 -0500
Message-Id: <1640789487-22279-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
References: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/13] lustre: ptlrpc: use a cached value
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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
Cc: Alexey Lyashkov <alexey.lyashkov@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alexey Lyashkov <alexey.lyashkov@hpe.com>

Don't calculate a early reply size - use a cached,
as it don't changed after start

WC-bug-id: https://jira.whamcloud.com/browse/LU-15279
Lustre-commit: d6a3b0529d7da440a ("LU-15279 ptlrpc: use a cached value")
Signed-off-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-on: https://review.whamcloud.com/45661
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Andrew Perepechko <andrew.perepechko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h     | 2 +-
 fs/lustre/mdc/mdc_locks.c          | 4 ++--
 fs/lustre/ptlrpc/pack_generic.c    | 8 +++++---
 fs/lustre/ptlrpc/ptlrpc_internal.h | 1 +
 fs/lustre/ptlrpc/ptlrpc_module.c   | 1 +
 fs/lustre/ptlrpc/sec_null.c        | 4 ++--
 fs/lustre/ptlrpc/sec_plain.c       | 2 +-
 7 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 78df59b..cf1bb7f 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -2010,7 +2010,7 @@ int lustre_shrink_msg(struct lustre_msg *msg, int segment,
 u32 lustre_msg_size(u32 magic, int count, u32 *lengths);
 u32 lustre_msg_size_v2(int count, u32 *lengths);
 u32 lustre_packed_msg_size(struct lustre_msg *msg);
-u32 lustre_msg_early_size(void);
+extern u32 lustre_msg_early_size;
 void *lustre_msg_buf_v2(struct lustre_msg_v2 *m, u32 n, u32 min_size);
 void *lustre_msg_buf(struct lustre_msg *m, u32 n, u32 minlen);
 u32 lustre_msg_buflen(struct lustre_msg *m, u32 n);
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index aba94d1..b86d1b9 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -397,7 +397,7 @@ static int mdc_save_lovea(struct ptlrpc_request *req, void *data, u32 size)
 
 	/* Get real repbuf allocated size as rounded up power of 2 */
 	repsize = size_roundup_power2(req->rq_replen +
-				      lustre_msg_early_size());
+				      lustre_msg_early_size);
 	/* Estimate free space for DoM files in repbuf */
 	repsize_estimate = repsize - (req->rq_replen -
 			   mdt_md_capsule_size +
@@ -415,7 +415,7 @@ static int mdc_save_lovea(struct ptlrpc_request *req, void *data, u32 size)
 		CDEBUG(D_INFO, "Increase repbuf by %d bytes, total: %d\n",
 		       repsize, req->rq_replen);
 		repsize = size_roundup_power2(req->rq_replen +
-					      lustre_msg_early_size());
+					      lustre_msg_early_size);
 	}
 	/* The only way to report real allocated repbuf size to the server
 	 * is the lm_repsize but it must be set prior buffer allocation itself
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 23b36de..b41f51d 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -72,14 +72,16 @@ u32 lustre_msg_hdr_size(u32 magic, u32 count)
 	}
 }
 
+u32 lustre_msg_early_size;
+EXPORT_SYMBOL(lustre_msg_early_size);
+
 /* early reply size */
-u32 lustre_msg_early_size(void)
+void lustre_msg_early_size_init(void)
 {
 	u32 pblen = sizeof(struct ptlrpc_body);
 
-	return lustre_msg_size(LUSTRE_MSG_MAGIC_V2, 1, &pblen);
+	lustre_msg_early_size = lustre_msg_size(LUSTRE_MSG_MAGIC_V2, 1, &pblen);
 }
-EXPORT_SYMBOL(lustre_msg_early_size);
 
 u32 lustre_msg_size_v2(int count, u32 *lengths)
 {
diff --git a/fs/lustre/ptlrpc/ptlrpc_internal.h b/fs/lustre/ptlrpc/ptlrpc_internal.h
index f1f414c..d6edfde 100644
--- a/fs/lustre/ptlrpc/ptlrpc_internal.h
+++ b/fs/lustre/ptlrpc/ptlrpc_internal.h
@@ -244,6 +244,7 @@ void ptlrpc_fill_bulk_md(struct lnet_md *md, struct ptlrpc_bulk_desc *desc,
 struct ptlrpc_reply_state *
 lustre_get_emerg_rs(struct ptlrpc_service_part *svcpt);
 void lustre_put_emerg_rs(struct ptlrpc_reply_state *rs);
+void lustre_msg_early_size_init(void); /* just for init */
 
 /* pinger.c */
 int ptlrpc_start_pinger(void);
diff --git a/fs/lustre/ptlrpc/ptlrpc_module.c b/fs/lustre/ptlrpc/ptlrpc_module.c
index 8379bc4..7e29a91 100644
--- a/fs/lustre/ptlrpc/ptlrpc_module.c
+++ b/fs/lustre/ptlrpc/ptlrpc_module.c
@@ -85,6 +85,7 @@ static int __init ptlrpc_init(void)
 	mutex_init(&pinger_mutex);
 	mutex_init(&ptlrpcd_mutex);
 	ptlrpc_init_xid();
+	lustre_msg_early_size_init();
 
 	rc = libcfs_setup();
 	if (rc)
diff --git a/fs/lustre/ptlrpc/sec_null.c b/fs/lustre/ptlrpc/sec_null.c
index cf8f24b..a7241bd 100644
--- a/fs/lustre/ptlrpc/sec_null.c
+++ b/fs/lustre/ptlrpc/sec_null.c
@@ -195,7 +195,7 @@ int null_alloc_repbuf(struct ptlrpc_sec *sec,
 		      int msgsize)
 {
 	/* add space for early replied */
-	msgsize += lustre_msg_early_size();
+	msgsize += lustre_msg_early_size;
 
 	msgsize = size_roundup_power2(msgsize);
 
@@ -367,7 +367,7 @@ int null_authorize(struct ptlrpc_request *req)
 
 	if (likely(req->rq_packed_final)) {
 		if (lustre_msghdr_get_flags(req->rq_reqmsg) & MSGHDR_AT_SUPPORT)
-			req->rq_reply_off = lustre_msg_early_size();
+			req->rq_reply_off = lustre_msg_early_size;
 	} else {
 		u32 cksum;
 
diff --git a/fs/lustre/ptlrpc/sec_plain.c b/fs/lustre/ptlrpc/sec_plain.c
index 0d1c591..d546722 100644
--- a/fs/lustre/ptlrpc/sec_plain.c
+++ b/fs/lustre/ptlrpc/sec_plain.c
@@ -996,7 +996,7 @@ int sptlrpc_plain_init(void)
 	u32 buflens[PLAIN_PACK_SEGMENTS] = { 0, };
 	int rc;
 
-	buflens[PLAIN_PACK_MSG_OFF] = lustre_msg_early_size();
+	buflens[PLAIN_PACK_MSG_OFF] = lustre_msg_early_size;
 	plain_at_offset = lustre_msg_size_v2(PLAIN_PACK_SEGMENTS, buflens);
 
 	rc = sptlrpc_register_policy(&plain_policy);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
