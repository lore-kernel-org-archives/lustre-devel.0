Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 37343C36000
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:35:56 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2tq51WWz20yq;
	Fri, 21 Mar 2025 06:13:07 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2nd1cqCz1y7P
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:08:37 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id A1373893D84;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 9E4A3106BE19; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:07:05 -0400
Message-ID: <20250321130711.3257092-23-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 22/27] lnet: libcfs: Remove reference to
 LASSERT_ATOMIC_GT_LT
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

This patch removes all reference to LASSERT_ATOMIC_GT_LT macro.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16796
Lustre-commit: 5cc0c6b2630e955ee ("LU-16796 libcfs: Remove reference to LASSERT_ATOMIC_GT_LT")
Signed-off-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51157
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_log.h        | 8 ++++++--
 fs/lustre/ldlm/ldlm_resource.c        | 5 ++++-
 include/linux/libcfs/libcfs_private.h | 8 --------
 3 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/include/lustre_log.h b/fs/lustre/include/lustre_log.h
index 1586595399cf..60d451ca1710 100644
--- a/fs/lustre/include/lustre_log.h
+++ b/fs/lustre/include/lustre_log.h
@@ -286,10 +286,14 @@ static inline struct llog_ctxt *llog_ctxt_get(struct llog_ctxt *ctxt)
 
 static inline void llog_ctxt_put(struct llog_ctxt *ctxt)
 {
+	int refcount;
+
 	if (!ctxt)
 		return;
-	LASSERT(refcount_read(&ctxt->loc_refcount) > 0);
-	LASSERT(refcount_read(&ctxt->loc_refcount) < LI_POISON);
+
+	refcount = refcount_read(&ctxt->loc_refcount);
+	LASSERT(refcount > 0 && refcount < LI_POISON);
+
 	CDEBUG(D_INFO, "PUTting ctxt %p : new refcount %d\n", ctxt,
 	       refcount_read(&ctxt->loc_refcount) - 1);
 	__llog_ctxt_put(NULL, ctxt);
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index 7da47976e994..db0f7f169701 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -1220,8 +1220,11 @@ void ldlm_resource_putref(struct ldlm_resource *res)
 {
 	struct ldlm_namespace *ns = ldlm_res_to_ns(res);
 	struct cfs_hash_bd bd;
+	int refcount;
+
+	refcount = atomic_read(&res->lr_refcount);
+	LASSERT(refcount > 0 && refcount < LI_POISON);
 
-	LASSERT_ATOMIC_GT_LT(&res->lr_refcount, 0, LI_POISON);
 	CDEBUG(D_INFO, "putref res: %p count: %d\n",
 	       res, atomic_read(&res->lr_refcount) - 1);
 
diff --git a/include/linux/libcfs/libcfs_private.h b/include/linux/libcfs/libcfs_private.h
index d46c66e8534b..0a377f09d6dd 100644
--- a/include/linux/libcfs/libcfs_private.h
+++ b/include/linux/libcfs/libcfs_private.h
@@ -112,17 +112,9 @@ int libcfs_debug_mark_buffer(const char *text);
 #define LASSERT_ATOMIC_EQ(a, v)			\
 	LASSERTF(atomic_read(a) == v, "value: %d\n", atomic_read((a)))
 
-/** assert value of @a is great than @v1 and little than @v2 */
-#define LASSERT_ATOMIC_GT_LT(a, v1, v2)				\
-do {								\
-	int __v = atomic_read(a);				\
-	LASSERTF(__v > v1 && __v < v2, "value: %d\n", __v);	\
-} while (0)
-
 #else /* !LASSERT_ATOMIC_ENABLED */
 
 #define LASSERT_ATOMIC_EQ(a, v)		do {} while (0)
-#define LASSERT_ATOMIC_GT_LT(a, v1, v2)	do {} while (0)
 
 #endif /* LASSERT_ATOMIC_ENABLED */
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
