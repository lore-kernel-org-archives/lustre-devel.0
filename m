Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA856C433ED
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:06:09 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 80E49610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:06:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80E49610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EA88832BA51;
	Wed, 14 Apr 2021 21:04:31 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C6D2932F613
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:03:00 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id D8D3F100F379;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D7A056DF9E; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:41 -0400
Message-Id: <1618459361-17909-50-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 49/49] lnet: libcfs: discard cfs_array_alloc()
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

From: "Mr. NeilBrown" <neilb@suse.de>

cfs_array_alloc() and _free() are used for precisely one array, and
provide little value beyond open-coding the alloc and free.

So discard these functions and alloc/free in the loops that already
exist for setup and cleanup.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14289
Lustre-commit: 8ec9fe0d55b1f5a ("LU-14289 libcfs: discard cfs_array_alloc()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/41992
Reviewed-by: Aurelien Degremont <degremoa@amazon.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/libcfs/libcfs_private.h |  7 -----
 net/lnet/libcfs/libcfs_mem.c          | 52 -----------------------------------
 net/lnet/lnet/lib-ptl.c               | 19 ++++++++-----
 3 files changed, 12 insertions(+), 66 deletions(-)

diff --git a/include/linux/libcfs/libcfs_private.h b/include/linux/libcfs/libcfs_private.h
index cf13fe0..3996d0e 100644
--- a/include/linux/libcfs/libcfs_private.h
+++ b/include/linux/libcfs/libcfs_private.h
@@ -105,13 +105,6 @@
 int libcfs_debug_clear_buffer(void);
 int libcfs_debug_mark_buffer(const char *text);
 
-/*
- * allocate a variable array, returned value is an array of pointers.
- * Caller can specify length of array by count.
- */
-void *cfs_array_alloc(int count, unsigned int size);
-void  cfs_array_free(void *vars);
-
 #define LASSERT_ATOMIC_ENABLED	  (1)
 
 #if LASSERT_ATOMIC_ENABLED
diff --git a/net/lnet/libcfs/libcfs_mem.c b/net/lnet/libcfs/libcfs_mem.c
index 2d533be..6a49d39 100644
--- a/net/lnet/libcfs/libcfs_mem.c
+++ b/net/lnet/libcfs/libcfs_mem.c
@@ -117,55 +117,3 @@ struct cfs_var_array {
 	return arr->va_count;
 }
 EXPORT_SYMBOL(cfs_percpt_number);
-
-/*
- * free variable array, see more detail in cfs_array_alloc
- */
-void
-cfs_array_free(void *vars)
-{
-	struct cfs_var_array *arr;
-	int i;
-
-	arr = container_of(vars, struct cfs_var_array, va_ptrs[0]);
-
-	for (i = 0; i < arr->va_count; i++) {
-		if (!arr->va_ptrs[i])
-			continue;
-
-		kvfree(arr->va_ptrs[i]);
-	}
-	kvfree(arr);
-}
-EXPORT_SYMBOL(cfs_array_free);
-
-/*
- * allocate a variable array, returned value is an array of pointers.
- * Caller can specify length of array by @count, @size is size of each
- * memory block in array.
- */
-void *
-cfs_array_alloc(int count, unsigned int size)
-{
-	struct cfs_var_array *arr;
-	int i;
-
-	arr = kvmalloc(offsetof(struct cfs_var_array, va_ptrs[count]), GFP_KERNEL);
-	if (!arr)
-		return NULL;
-
-	arr->va_count = count;
-	arr->va_size = size;
-
-	for (i = 0; i < count; i++) {
-		arr->va_ptrs[i] = kvzalloc(size, GFP_KERNEL);
-
-		if (!arr->va_ptrs[i]) {
-			cfs_array_free((void *)&arr->va_ptrs[0]);
-			return NULL;
-		}
-	}
-
-	return (void *)&arr->va_ptrs[0];
-}
-EXPORT_SYMBOL(cfs_array_alloc);
diff --git a/net/lnet/lnet/lib-ptl.c b/net/lnet/lnet/lib-ptl.c
index ae38bc3..45d1be2 100644
--- a/net/lnet/lnet/lib-ptl.c
+++ b/net/lnet/lnet/lib-ptl.c
@@ -830,6 +830,7 @@ struct list_head *
 	return -ENOMEM;
 }
 
+#define PORTAL_SIZE (offsetof(struct lnet_portal, ptl_mt_maps[LNET_CPT_NUMBER]))
 void
 lnet_portals_destroy(void)
 {
@@ -839,9 +840,12 @@ struct list_head *
 		return;
 
 	for (i = 0; i < the_lnet.ln_nportals; i++)
-		lnet_ptl_cleanup(the_lnet.ln_portals[i]);
+		if (the_lnet.ln_portals[i]) {
+			lnet_ptl_cleanup(the_lnet.ln_portals[i]);
+			kfree(the_lnet.ln_portals[i]);
+		}
 
-	cfs_array_free(the_lnet.ln_portals);
+	kvfree(the_lnet.ln_portals);
 	the_lnet.ln_portals = NULL;
 	the_lnet.ln_nportals = 0;
 }
@@ -849,12 +853,11 @@ struct list_head *
 int
 lnet_portals_create(void)
 {
-	int size;
 	int i;
 
-	size = offsetof(struct lnet_portal, ptl_mt_maps[LNET_CPT_NUMBER]);
-
-	the_lnet.ln_portals = cfs_array_alloc(MAX_PORTALS, size);
+	the_lnet.ln_portals = kvmalloc_array(MAX_PORTALS,
+					     sizeof(*the_lnet.ln_portals),
+					     GFP_KERNEL);
 	if (!the_lnet.ln_portals) {
 		CERROR("Failed to allocate portals table\n");
 		return -ENOMEM;
@@ -862,7 +865,9 @@ struct list_head *
 	the_lnet.ln_nportals = MAX_PORTALS;
 
 	for (i = 0; i < the_lnet.ln_nportals; i++) {
-		if (lnet_ptl_setup(the_lnet.ln_portals[i], i)) {
+		the_lnet.ln_portals[i] = kzalloc(PORTAL_SIZE, GFP_KERNEL);
+		if (!the_lnet.ln_portals[i] ||
+		    lnet_ptl_setup(the_lnet.ln_portals[i], i)) {
 			lnet_portals_destroy();
 			return -ENOMEM;
 		}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
