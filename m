Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEC7BC433DB
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:40 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6F71723A5A
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F71723A5A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 98BAA21FEF8;
	Thu, 21 Jan 2021 09:17:58 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EB35221FA40
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:08 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 3BCBA1008052;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 38BBF11596; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:33 -0500
Message-Id: <1611249422-556-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/39] lustre: Use vfree_atomic instead of
 vfree
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Oleg Drokin <green@whamcloud.com>

Since vfree is unsafe to use in atomic context, we can use
vmalloc_free() introduced in linux 4.10 commit
bf22e37a641327e34681b7b6959d9646e3886770. To use this we have
to export vmalloc_free(). The biggest offender is in the ptlrpc
code so replace the kvfree() with vfree_atomic().

WC-bug-id: https://jira.whamcloud.com/browse/LU-12564
Lustre-commit: 7a9c0ca690eb00 ("LU-12564 libcfs: Use vfree_atomic instead of vfree")
Signed-off-by: Oleg Drokin <green@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40136
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Aurelien Degremont <degremoa@amazon.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/client.c    |  6 +++++-
 fs/lustre/ptlrpc/sec.c       | 21 +++++++++++++++++----
 fs/lustre/ptlrpc/sec_bulk.c  |  6 +++++-
 fs/lustre/ptlrpc/sec_null.c  | 24 +++++++++++++++++++-----
 fs/lustre/ptlrpc/sec_plain.c | 24 +++++++++++++++++++-----
 fs/lustre/ptlrpc/service.c   | 21 +++++++++++++++++----
 mm/vmalloc.c                 |  1 +
 7 files changed, 83 insertions(+), 20 deletions(-)

diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 2002c03..4b8aa25 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -38,6 +38,7 @@
 #include <linux/libcfs/libcfs_cpu.h>
 #include <linux/delay.h>
 #include <linux/random.h>
+#include <linux/vmalloc.h>
 
 #include <obd_support.h>
 #include <obd_class.h>
@@ -529,7 +530,10 @@ void ptlrpc_free_rq_pool(struct ptlrpc_request_pool *pool)
 		list_del(&req->rq_list);
 		LASSERT(req->rq_reqbuf);
 		LASSERT(req->rq_reqbuf_len == pool->prp_rq_size);
-		kvfree(req->rq_reqbuf);
+		if (is_vmalloc_addr(req->rq_reqbuf))
+			vfree_atomic(req->rq_reqbuf);
+		else
+			kfree(req->rq_reqbuf);
 		ptlrpc_request_cache_free(req);
 	}
 	kfree(pool);
diff --git a/fs/lustre/ptlrpc/sec.c b/fs/lustre/ptlrpc/sec.c
index 44c15e6..43d4f76 100644
--- a/fs/lustre/ptlrpc/sec.c
+++ b/fs/lustre/ptlrpc/sec.c
@@ -42,6 +42,7 @@
 #include <linux/cred.h>
 #include <linux/key.h>
 #include <linux/sched/task.h>
+#include <linux/vmalloc.h>
 
 #include <obd.h>
 #include <obd_class.h>
@@ -474,7 +475,10 @@ int sptlrpc_req_ctx_switch(struct ptlrpc_request *req,
 			req->rq_flvr = old_flvr;
 		}
 
-		kvfree(reqmsg);
+		if (is_vmalloc_addr(reqmsg))
+			vfree_atomic(reqmsg);
+		else
+			kfree(reqmsg);
 	}
 	return rc;
 }
@@ -836,7 +840,10 @@ void sptlrpc_request_out_callback(struct ptlrpc_request *req)
 	if (req->rq_pool || !req->rq_reqbuf)
 		return;
 
-	kvfree(req->rq_reqbuf);
+	if (is_vmalloc_addr(req->rq_reqbuf))
+		vfree_atomic(req->rq_reqbuf);
+	else
+		kfree(req->rq_reqbuf);
 	req->rq_reqbuf = NULL;
 	req->rq_reqbuf_len = 0;
 }
@@ -1133,7 +1140,10 @@ int sptlrpc_cli_unwrap_early_reply(struct ptlrpc_request *req,
 err_ctx:
 	sptlrpc_cli_ctx_put(early_req->rq_cli_ctx, 1);
 err_buf:
-	kvfree(early_buf);
+	if (is_vmalloc_addr(early_buf))
+		vfree_atomic(early_buf);
+	else
+		kfree(early_buf);
 err_req:
 	ptlrpc_request_cache_free(early_req);
 	return rc;
@@ -1151,7 +1161,10 @@ void sptlrpc_cli_finish_early_reply(struct ptlrpc_request *early_req)
 	LASSERT(early_req->rq_repmsg);
 
 	sptlrpc_cli_ctx_put(early_req->rq_cli_ctx, 1);
-	kvfree(early_req->rq_repbuf);
+	if (is_vmalloc_addr(early_req->rq_repbuf))
+		vfree_atomic(early_req->rq_repbuf);
+	else
+		kfree(early_req->rq_repbuf);
 	ptlrpc_request_cache_free(early_req);
 }
 
diff --git a/fs/lustre/ptlrpc/sec_bulk.c b/fs/lustre/ptlrpc/sec_bulk.c
index 3c3ae8b..9548721 100644
--- a/fs/lustre/ptlrpc/sec_bulk.c
+++ b/fs/lustre/ptlrpc/sec_bulk.c
@@ -37,6 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
+#include <linux/vmalloc.h>
 #include <linux/libcfs/libcfs.h>
 
 #include <obd.h>
@@ -380,7 +381,10 @@ static inline void enc_pools_free(void)
 	LASSERT(page_pools.epp_max_pools);
 	LASSERT(page_pools.epp_pools);
 
-	kvfree(page_pools.epp_pools);
+	if (is_vmalloc_addr(page_pools.epp_pools))
+		vfree_atomic(page_pools.epp_pools);
+	else
+		kfree(page_pools.epp_pools);
 }
 
 static struct shrinker pools_shrinker = {
diff --git a/fs/lustre/ptlrpc/sec_null.c b/fs/lustre/ptlrpc/sec_null.c
index 97c4e19..3892d6e 100644
--- a/fs/lustre/ptlrpc/sec_null.c
+++ b/fs/lustre/ptlrpc/sec_null.c
@@ -37,6 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_SEC
 
+#include <linux/vmalloc.h>
 #include <obd_support.h>
 #include <obd_cksum.h>
 #include <obd_class.h>
@@ -180,7 +181,10 @@ void null_free_reqbuf(struct ptlrpc_sec *sec,
 			 "req %p: reqlen %d should smaller than buflen %d\n",
 			 req, req->rq_reqlen, req->rq_reqbuf_len);
 
-		kvfree(req->rq_reqbuf);
+		if (is_vmalloc_addr(req->rq_reqbuf))
+			vfree_atomic(req->rq_reqbuf);
+		else
+			kfree(req->rq_reqbuf);
 		req->rq_reqbuf = NULL;
 		req->rq_reqbuf_len = 0;
 	}
@@ -210,7 +214,10 @@ void null_free_repbuf(struct ptlrpc_sec *sec,
 {
 	LASSERT(req->rq_repbuf);
 
-	kvfree(req->rq_repbuf);
+	if (is_vmalloc_addr(req->rq_repbuf))
+		vfree_atomic(req->rq_repbuf);
+	else
+		kfree(req->rq_repbuf);
 	req->rq_repbuf = NULL;
 	req->rq_repbuf_len = 0;
 }
@@ -257,7 +264,10 @@ int null_enlarge_reqbuf(struct ptlrpc_sec *sec,
 			spin_lock(&req->rq_import->imp_lock);
 		memcpy(newbuf, req->rq_reqbuf, req->rq_reqlen);
 
-		kvfree(req->rq_reqbuf);
+		if (is_vmalloc_addr(req->rq_reqbuf))
+			vfree_atomic(req->rq_reqbuf);
+		else
+			kfree(req->rq_reqbuf);
 		req->rq_reqbuf = newbuf;
 		req->rq_reqmsg = newbuf;
 		req->rq_reqbuf_len = alloc_size;
@@ -337,8 +347,12 @@ void null_free_rs(struct ptlrpc_reply_state *rs)
 	LASSERT_ATOMIC_GT(&rs->rs_svc_ctx->sc_refcount, 1);
 	atomic_dec(&rs->rs_svc_ctx->sc_refcount);
 
-	if (!rs->rs_prealloc)
-		kvfree(rs);
+	if (!rs->rs_prealloc) {
+		if (is_vmalloc_addr(rs))
+			vfree_atomic(rs);
+		else
+			kfree(rs);
+	}
 }
 
 static
diff --git a/fs/lustre/ptlrpc/sec_plain.c b/fs/lustre/ptlrpc/sec_plain.c
index b487968..80831af 100644
--- a/fs/lustre/ptlrpc/sec_plain.c
+++ b/fs/lustre/ptlrpc/sec_plain.c
@@ -38,6 +38,7 @@
 #define DEBUG_SUBSYSTEM S_SEC
 
 #include <linux/highmem.h>
+#include <linux/vmalloc.h>
 #include <obd_support.h>
 #include <obd_cksum.h>
 #include <obd_class.h>
@@ -582,7 +583,10 @@ void plain_free_reqbuf(struct ptlrpc_sec *sec,
 		       struct ptlrpc_request *req)
 {
 	if (!req->rq_pool) {
-		kvfree(req->rq_reqbuf);
+		if (is_vmalloc_addr(req->rq_reqbuf))
+			vfree_atomic(req->rq_reqbuf);
+		else
+			kfree(req->rq_reqbuf);
 		req->rq_reqbuf = NULL;
 		req->rq_reqbuf_len = 0;
 	}
@@ -623,7 +627,10 @@ int plain_alloc_repbuf(struct ptlrpc_sec *sec,
 void plain_free_repbuf(struct ptlrpc_sec *sec,
 		       struct ptlrpc_request *req)
 {
-	kvfree(req->rq_repbuf);
+	if (is_vmalloc_addr(req->rq_repbuf))
+		vfree_atomic(req->rq_repbuf);
+	else
+		kfree(req->rq_repbuf);
 	req->rq_repbuf = NULL;
 	req->rq_repbuf_len = 0;
 }
@@ -678,7 +685,10 @@ int plain_enlarge_reqbuf(struct ptlrpc_sec *sec,
 
 		memcpy(newbuf, req->rq_reqbuf, req->rq_reqbuf_len);
 
-		kvfree(req->rq_reqbuf);
+		if (is_vmalloc_addr(req->rq_reqbuf))
+			vfree_atomic(req->rq_reqbuf);
+		else
+			kfree(req->rq_reqbuf);
 		req->rq_reqbuf = newbuf;
 		req->rq_reqbuf_len = newbuf_size;
 		req->rq_reqmsg = lustre_msg_buf(req->rq_reqbuf,
@@ -823,8 +833,12 @@ void plain_free_rs(struct ptlrpc_reply_state *rs)
 	LASSERT(atomic_read(&rs->rs_svc_ctx->sc_refcount) > 1);
 	atomic_dec(&rs->rs_svc_ctx->sc_refcount);
 
-	if (!rs->rs_prealloc)
-		kvfree(rs);
+	if (!rs->rs_prealloc) {
+		if (is_vmalloc_addr(rs))
+			vfree_atomic(rs);
+		else
+			kfree(rs);
+	}
 }
 
 static
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 5881e0a..b341877 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -36,6 +36,7 @@
 #include <linux/kthread.h>
 #include <linux/ratelimit.h>
 #include <linux/fs_struct.h>
+#include <linux/vmalloc.h>
 
 #include <obd_support.h>
 #include <obd_class.h>
@@ -118,7 +119,10 @@ static void ptlrpc_free_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
 	svcpt->scp_nrqbds_total--;
 	spin_unlock(&svcpt->scp_lock);
 
-	kvfree(rqbd->rqbd_buffer);
+	if (is_vmalloc_addr(rqbd->rqbd_buffer))
+		vfree_atomic(rqbd->rqbd_buffer);
+	else
+		kfree(rqbd->rqbd_buffer);
 	kfree(rqbd);
 }
 
@@ -838,7 +842,10 @@ static void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 			    test_req_buffer_pressure) {
 				/* like in ptlrpc_free_rqbd() */
 				svcpt->scp_nrqbds_total--;
-				kvfree(rqbd->rqbd_buffer);
+				if (is_vmalloc_addr(rqbd->rqbd_buffer))
+					vfree_atomic(rqbd->rqbd_buffer);
+				else
+					kfree(rqbd->rqbd_buffer);
 				kfree(rqbd);
 			} else {
 				list_add_tail(&rqbd->rqbd_list,
@@ -1197,7 +1204,10 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 	class_export_put(reqcopy->rq_export);
 out:
 	sptlrpc_svc_ctx_decref(reqcopy);
-	kvfree(reqmsg);
+	if (is_vmalloc_addr(reqmsg))
+		vfree_atomic(reqmsg);
+	else
+		kfree(reqmsg);
 out_free:
 	ptlrpc_request_cache_free(reqcopy);
 	return rc;
@@ -2938,7 +2948,10 @@ static void ptlrpc_wait_replies(struct ptlrpc_service_part *svcpt)
 						      struct ptlrpc_reply_state,
 						      rs_list)) != NULL) {
 			list_del(&rs->rs_list);
-			kvfree(rs);
+			if (is_vmalloc_addr(rs))
+				vfree_atomic(rs);
+			else
+				kfree(rs);
 		}
 	}
 }
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 9a8227a..9a27fbd 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2355,6 +2355,7 @@ void vfree_atomic(const void *addr)
 		return;
 	__vfree_deferred(addr);
 }
+EXPORT_SYMBOL(vfree_atomic);
 
 static void __vfree(const void *addr)
 {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
