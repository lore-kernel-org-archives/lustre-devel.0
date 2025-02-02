Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C17DEC0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 20:59:57 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMFf0g3jz212d;
	Sun, 02 Feb 2025 12:49:58 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMFT74WZz211j
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:49:49 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 1D5E6182374;
 Sun,  2 Feb 2025 15:46:42 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 1BB4A106BE16; Sun,  2 Feb 2025 15:46:42 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:31 -0500
Message-ID: <20250202204633.1148872-32-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 31/33] lnet: libcfs: Remove reference to
 LASSERT_ATOMIC_POS
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
Cc: Arshad Hussain <arshad.hussain@aeoncomputing.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Arshad Hussain <arshad.hussain@aeoncomputing.com>

This patch removes all reference to LASSERT_ATOMIC_POS macro.
Once all the access is removed it would be easier to just
toggle atomic_* API calls with recount_* counts.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16796
Lustre-commit: 165433bb4ced42560 ("LU-16796 libcfs: Remove reference to LASSERT_ATOMIC_POS")
Signed-off-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50881
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Timothy Day <timday@amazon.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h         |  4 ++--
 fs/lustre/ptlrpc/sec.c                | 16 ++++++++--------
 include/linux/libcfs/libcfs_private.h |  1 -
 net/lnet/klnds/o2iblnd/o2iblnd.h      |  2 +-
 4 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 06dfcf9bbd9e..f8ae45b6e986 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -270,7 +270,7 @@ static inline void class_export_rpc_inc(struct obd_export *exp)
 
 static inline void class_export_rpc_dec(struct obd_export *exp)
 {
-	LASSERT_ATOMIC_POS(&exp->exp_rpc_count);
+	LASSERT(atomic_read(&(exp)->exp_rpc_count) > 0);
 	atomic_dec(&(exp)->exp_rpc_count);
 	CDEBUG(D_INFO, "RPC PUTting export %p : new rpc_count %d\n",
 	       (exp), atomic_read(&(exp)->exp_rpc_count));
@@ -289,7 +289,7 @@ static inline struct obd_export *class_export_lock_get(struct obd_export *exp,
 static inline void class_export_lock_put(struct obd_export *exp,
 					 struct ldlm_lock *lock)
 {
-	LASSERT_ATOMIC_POS(&exp->exp_locks_count);
+	LASSERT(atomic_read(&(exp)->exp_rpc_count) > 0);
 	atomic_dec(&(exp)->exp_locks_count);
 	__class_export_del_lock_ref(exp, lock);
 	CDEBUG(D_INFO, "lock PUTting export %p : new locks_count %d\n",
diff --git a/fs/lustre/ptlrpc/sec.c b/fs/lustre/ptlrpc/sec.c
index 7cd09ebe78db..576e6480cda8 100644
--- a/fs/lustre/ptlrpc/sec.c
+++ b/fs/lustre/ptlrpc/sec.c
@@ -290,7 +290,7 @@ void sptlrpc_cli_ctx_put(struct ptlrpc_cli_ctx *ctx, int sync)
 	struct ptlrpc_sec *sec = ctx->cc_sec;
 
 	LASSERT(sec);
-	LASSERT_ATOMIC_POS(&ctx->cc_refcount);
+	LASSERT(atomic_read(&(ctx)->cc_refcount) > 0);
 
 	if (!atomic_dec_and_test(&ctx->cc_refcount))
 		return;
@@ -1214,7 +1214,7 @@ static void sec_cop_destroy_sec(struct ptlrpc_sec *sec)
 
 static void sptlrpc_sec_kill(struct ptlrpc_sec *sec)
 {
-	LASSERT_ATOMIC_POS(&sec->ps_refcount);
+	LASSERT(atomic_read(&(sec)->ps_refcount) > 0);
 
 	if (sec->ps_policy->sp_cops->kill_sec) {
 		sec->ps_policy->sp_cops->kill_sec(sec);
@@ -1234,7 +1234,7 @@ static struct ptlrpc_sec *sptlrpc_sec_get(struct ptlrpc_sec *sec)
 void sptlrpc_sec_put(struct ptlrpc_sec *sec)
 {
 	if (sec) {
-		LASSERT_ATOMIC_POS(&sec->ps_refcount);
+		LASSERT(atomic_read(&(sec)->ps_refcount) > 0);
 
 		if (atomic_dec_and_test(&sec->ps_refcount)) {
 			sptlrpc_gc_del_sec(sec);
@@ -1314,7 +1314,7 @@ static void sptlrpc_import_sec_install(struct obd_import *imp,
 {
 	struct ptlrpc_sec *old_sec;
 
-	LASSERT_ATOMIC_POS(&sec->ps_refcount);
+	LASSERT(atomic_read(&(sec)->ps_refcount) > 0);
 
 	write_lock(&imp->imp_sec_lock);
 	old_sec = imp->imp_sec;
@@ -1507,7 +1507,7 @@ int sptlrpc_cli_alloc_reqbuf(struct ptlrpc_request *req, int msgsize)
 	LASSERT(ctx->cc_sec);
 	LASSERT(ctx->cc_sec->ps_policy);
 	LASSERT(!req->rq_reqmsg);
-	LASSERT_ATOMIC_POS(&ctx->cc_refcount);
+	LASSERT(atomic_read(&(ctx)->cc_refcount) > 0);
 
 	policy = ctx->cc_sec->ps_policy;
 	rc = policy->sp_cops->alloc_reqbuf(ctx->cc_sec, req, msgsize);
@@ -1535,7 +1535,7 @@ void sptlrpc_cli_free_reqbuf(struct ptlrpc_request *req)
 	LASSERT(ctx);
 	LASSERT(ctx->cc_sec);
 	LASSERT(ctx->cc_sec->ps_policy);
-	LASSERT_ATOMIC_POS(&ctx->cc_refcount);
+	LASSERT(atomic_read(&(ctx)->cc_refcount) > 0);
 
 	if (!req->rq_reqbuf && !req->rq_clrbuf)
 		return;
@@ -1655,7 +1655,7 @@ void sptlrpc_cli_free_repbuf(struct ptlrpc_request *req)
 	LASSERT(ctx);
 	LASSERT(ctx->cc_sec);
 	LASSERT(ctx->cc_sec->ps_policy);
-	LASSERT_ATOMIC_POS(&ctx->cc_refcount);
+	LASSERT(atomic_read(&(ctx)->cc_refcount) > 0);
 
 	if (!req->rq_repbuf)
 		return;
@@ -2239,7 +2239,7 @@ void sptlrpc_svc_ctx_decref(struct ptlrpc_request *req)
 	if (!ctx)
 		return;
 
-	LASSERT_ATOMIC_POS(&ctx->sc_refcount);
+	LASSERT(atomic_read(&(ctx)->sc_refcount) > 0);
 	if (atomic_dec_and_test(&ctx->sc_refcount)) {
 		if (ctx->sc_policy->sp_sops->free_ctx)
 			ctx->sc_policy->sp_sops->free_ctx(ctx);
diff --git a/include/linux/libcfs/libcfs_private.h b/include/linux/libcfs/libcfs_private.h
index 7c0fb5a1c652..cc9115a89f43 100644
--- a/include/linux/libcfs/libcfs_private.h
+++ b/include/linux/libcfs/libcfs_private.h
@@ -132,7 +132,6 @@ do {								\
 #endif /* LASSERT_ATOMIC_ENABLED */
 
 #define LASSERT_ATOMIC_ZERO(a)		LASSERT_ATOMIC_EQ(a, 0)
-#define LASSERT_ATOMIC_POS(a)		LASSERT_ATOMIC_GT(a, 0)
 
 /* implication */
 #define ergo(a, b) (!(a) || (b))
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 5884cda7a707..4f83bce9e797 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -614,7 +614,7 @@ static inline void kiblnd_conn_decref(struct kib_conn *conn)
 	CDEBUG(D_NET, "conn[%p] (%d)--\n",
 	       conn, atomic_read(&conn->ibc_refcount));
 #endif
-	LASSERT_ATOMIC_POS(&conn->ibc_refcount);
+	LASSERT(atomic_read(&(conn)->ibc_refcount) > 0);
 	if (atomic_dec_and_test(&conn->ibc_refcount)) {
 		spin_lock_irqsave(&kiblnd_data.kib_connd_lock, flags);
 		list_add_tail(&conn->ibc_list,
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
