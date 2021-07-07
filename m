Return-Path: <SRS0=JyPa=L7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D28DC07E95
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:12:09 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C607B61A13
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:12:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C607B61A13
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 58DCE338A95;
	Wed,  7 Jul 2021 12:11:50 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AB3AB21F978
 for <lustre-devel@lists.lustre.org>; Wed,  7 Jul 2021 12:11:23 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 59925100F3E0;
 Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 587219D8B2; Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  7 Jul 2021 15:11:15 -0400
Message-Id: <1625685076-1964-15-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
References: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 14/15] lustre: osc: Simplify clipping for
 transient pages
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
Cc: Patrick Farrell <farr0186@gmail.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <farr0186@gmail.com>

The combination of page clip and page flag setting for
transient pages takes up several % of the time when
submitting them for async DIO.

But neither is required - Transient pages do not change
after creation except in limited cases, and in any case,
they are only accessible from the submitting thread -
there is no possibility of parallel access.

So we can set the page flags, etc, at init time.

This patch improves i/o time in ms/GiB by:
Write: 17 ms/GiB
Read: 22 ms/GiB

Totals:
Write: 204 ms/GiB
Read: 198 ms/GiB

mpirun -np 1  $IOR -w -r -t 64M -b 64G -o ./iorfile --posix.odirect

With previous patches in series:
write     4647 MiB/s
read      4888 MiB/s

Plus this patch:
write     5030 MiB/s
read      5174 MiB/s

WC-bug-id: https://jira.whamcloud.com/browse/LU-13799
Lustre-commit: b64b9646f17b771c ("LU-13799 osc: Simplify clipping for transient pages")
Signed-off-by: Patrick Farrell <farr0186@gmail.com>
Reviewed-on: https://review.whamcloud.com/39440
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h |  2 +-
 fs/lustre/llite/rw26.c         |  3 ++-
 fs/lustre/osc/osc_cache.c      | 18 +++++++++++++-----
 fs/lustre/osc/osc_io.c         | 10 ++++++----
 fs/lustre/osc/osc_page.c       |  6 ++++--
 5 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 208bb59..13e9363 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -593,7 +593,7 @@ long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 int osc_set_async_flags(struct osc_object *obj, struct osc_page *opg,
 			u32 async_flags);
 int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
-			struct page *page, loff_t offset);
+			struct cl_page *page, loff_t offset);
 int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 		       struct osc_page *ops, cl_commit_cbt cb);
 int osc_page_cache_add(const struct lu_env *env, struct osc_page *opg,
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 6a1b5bb..ba9c070 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -269,7 +269,8 @@ struct ll_dio_pages {
 		 * Set page clip to tell transfer formation engine
 		 * that page has to be sent even if it is beyond KMS.
 		 */
-		cl_page_clip(env, page, 0, min(size, page_size));
+		if (size < page_size)
+			cl_page_clip(env, page, 0, size);
 		++io_pages;
 
 		/* drop the reference count for cl_page_find */
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index e37c034..84c6b68 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2311,10 +2311,11 @@ int __osc_io_unplug(const struct lu_env *env, struct client_obd *cli,
 EXPORT_SYMBOL(__osc_io_unplug);
 
 int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
-			struct page *page, loff_t offset)
+			struct cl_page *page, loff_t offset)
 {
 	struct obd_export *exp = osc_export(osc);
 	struct osc_async_page *oap = &ops->ops_oap;
+	struct page *vmpage = page->cp_vmpage;
 
 	if (!page)
 		return -EIO;
@@ -2323,17 +2324,24 @@ int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
 	oap->oap_cli = &exp->exp_obd->u.cli;
 	oap->oap_obj = osc;
 
-	oap->oap_page = page;
+	oap->oap_page = vmpage;
 	oap->oap_obj_off = offset;
 	LASSERT(!(offset & ~PAGE_MASK));
 
+	/* Count of transient (direct i/o) pages is always stable by the time
+	 * they're submitted.  Setting this here lets us avoid calling
+	 * cl_page_clip later to set this.
+	 */
+	if (page->cp_type == CPT_TRANSIENT)
+		oap->oap_async_flags |= ASYNC_COUNT_STABLE|ASYNC_URGENT|
+					ASYNC_READY;
+
 	INIT_LIST_HEAD(&oap->oap_pending_item);
 	INIT_LIST_HEAD(&oap->oap_rpc_item);
 
 	spin_lock_init(&oap->oap_lock);
-	CDEBUG(D_INFO, "oap %p page %p obj off %llu\n",
-	       oap, page, oap->oap_obj_off);
-
+	CDEBUG(D_INFO, "oap %p vmpage %p obj off %llu\n",
+	       oap, vmpage, oap->oap_obj_off);
 	return 0;
 }
 EXPORT_SYMBOL(osc_prep_async_page);
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index bd92b5d..f69f201 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -191,10 +191,12 @@ int osc_io_submit(const struct lu_env *env, const struct cl_io_slice *ios,
 			continue;
 		}
 
-		spin_lock(&oap->oap_lock);
-		oap->oap_async_flags = ASYNC_URGENT | ASYNC_READY;
-		oap->oap_async_flags |= ASYNC_COUNT_STABLE;
-		spin_unlock(&oap->oap_lock);
+		if (page->cp_type != CPT_TRANSIENT) {
+			spin_lock(&oap->oap_lock);
+			oap->oap_async_flags = ASYNC_URGENT | ASYNC_READY;
+			oap->oap_async_flags |= ASYNC_COUNT_STABLE;
+			spin_unlock(&oap->oap_lock);
+		}
 
 		osc_page_submit(env, opg, crt, brw_flags, submit_time);
 		list_add_tail(&oap->oap_pending_item, &list);
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index 0f088fe..8aa21ee 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -212,6 +212,9 @@ static void osc_page_clip(const struct lu_env *env,
 	opg->ops_from = from;
 	/* argument @to is exclusive, but @ops_to is inclusive */
 	opg->ops_to = to - 1;
+	/* This isn't really necessary for transient pages, but we also don't
+	 * call clip on transient pages often, so it's OK.
+	 */
 	spin_lock(&oap->oap_lock);
 	oap->oap_async_flags |= ASYNC_COUNT_STABLE;
 	spin_unlock(&oap->oap_lock);
@@ -257,8 +260,7 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
 	opg->ops_to = PAGE_SIZE - 1;
 	INIT_LIST_HEAD(&opg->ops_lru);
 
-	result = osc_prep_async_page(osc, opg, cl_page->cp_vmpage,
-				     cl_offset(obj, index));
+	result = osc_prep_async_page(osc, opg, cl_page, cl_offset(obj, index));
 	if (result != 0)
 		return result;
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
