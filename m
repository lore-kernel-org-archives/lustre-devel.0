Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8CD1EC36000
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:18:08 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2ns4wJNz1xfP;
	Fri, 21 Mar 2025 06:08:49 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2m82Hfdz1xch
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:07:20 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 6365488F9D6;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 60D40106BE1A; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:06:49 -0400
Message-ID: <20250321130711.3257092-7-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 06/27] lnet: libcfs: Remove reference to
 LASSERT_ATOMIC_GT
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

This patch removes all reference to LASSERT_ATOMIC_GT macro.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16796
Lustre-commit: acdc2c8bb7aaf8d19 ("LU-16796 libcfs: Remove reference to LASSERT_ATOMIC_GT")
Signed-off-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51189
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/sec_null.c           | 2 +-
 include/linux/libcfs/libcfs_private.h | 5 -----
 2 files changed, 1 insertion(+), 6 deletions(-)

diff --git a/fs/lustre/ptlrpc/sec_null.c b/fs/lustre/ptlrpc/sec_null.c
index a7241bde7525..9f3a4ef43818 100644
--- a/fs/lustre/ptlrpc/sec_null.c
+++ b/fs/lustre/ptlrpc/sec_null.c
@@ -343,7 +343,7 @@ int null_alloc_rs(struct ptlrpc_request *req, int msgsize)
 static
 void null_free_rs(struct ptlrpc_reply_state *rs)
 {
-	LASSERT_ATOMIC_GT(&rs->rs_svc_ctx->sc_refcount, 1);
+	LASSERT(atomic_read(&rs->rs_svc_ctx->sc_refcount) > 1);
 	atomic_dec(&rs->rs_svc_ctx->sc_refcount);
 
 	if (!rs->rs_prealloc) {
diff --git a/include/linux/libcfs/libcfs_private.h b/include/linux/libcfs/libcfs_private.h
index cc9115a89f43..d46c66e8534b 100644
--- a/include/linux/libcfs/libcfs_private.h
+++ b/include/linux/libcfs/libcfs_private.h
@@ -112,10 +112,6 @@ int libcfs_debug_mark_buffer(const char *text);
 #define LASSERT_ATOMIC_EQ(a, v)			\
 	LASSERTF(atomic_read(a) == v, "value: %d\n", atomic_read((a)))
 
-/** assert value of @a is great than @v */
-#define LASSERT_ATOMIC_GT(a, v)		\
-	LASSERTF(atomic_read(a) > v, "value: %d\n", atomic_read((a)))
-
 /** assert value of @a is great than @v1 and little than @v2 */
 #define LASSERT_ATOMIC_GT_LT(a, v1, v2)				\
 do {								\
@@ -126,7 +122,6 @@ do {								\
 #else /* !LASSERT_ATOMIC_ENABLED */
 
 #define LASSERT_ATOMIC_EQ(a, v)		do {} while (0)
-#define LASSERT_ATOMIC_GT(a, v)		do {} while (0)
 #define LASSERT_ATOMIC_GT_LT(a, v1, v2)	do {} while (0)
 
 #endif /* LASSERT_ATOMIC_ENABLED */
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
