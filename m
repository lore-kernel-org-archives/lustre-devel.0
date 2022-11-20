Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 83638C433FE
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Nov 2022 14:20:13 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4NFXfj0JXYz1yBy;
	Sun, 20 Nov 2022 06:17:49 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4NFXf03R3Vz1wM4
 for <lustre-devel@lists.lustre.org>; Sun, 20 Nov 2022 06:17:12 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id AC63710077E7;
 Sun, 20 Nov 2022 09:17:09 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A694AE8B89; Sun, 20 Nov 2022 09:17:09 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Nov 2022 09:16:48 -0500
Message-Id: <1668953828-10909-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
References: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/22] lustre: osc: Remove oap lock
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <pfarrell@whamcloud.com>

The OAP lock is taken around setting the oap flags, but not
any of the other fields in oap.  As far as I can tell, this
is just some cargo cult belief about locking - there's no
reason for it.

Remove it entirely.  (From the code, a queued spin lock
appears to be 12 bytes on x86_64.)

WC-bug-id: https://jira.whamcloud.com/browse/LU-15619
Lustre-commit: b2274a716087fad24 ("LU-15619 osc: Remove oap lock")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/46719
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Zhenyu Xu <bobijam@hotmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h |  2 --
 fs/lustre/osc/osc_cache.c      | 11 -----------
 fs/lustre/osc/osc_io.c         |  8 ++------
 fs/lustre/osc/osc_page.c       |  5 -----
 4 files changed, 2 insertions(+), 24 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 2e8c184..a0f1afc 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -88,8 +88,6 @@ struct osc_async_page {
 
 	struct ptlrpc_request	*oap_request;
 	struct osc_object	*oap_obj;
-
-	spinlock_t		oap_lock;
 };
 
 #define oap_page	oap_brw_page.pg
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index e563809..b5776a1 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -1140,9 +1140,7 @@ static int osc_extent_make_ready(const struct lu_env *env,
 		rc = osc_make_ready(env, oap, OBD_BRW_WRITE);
 		switch (rc) {
 		case 0:
-			spin_lock(&oap->oap_lock);
 			oap->oap_async_flags |= ASYNC_READY;
-			spin_unlock(&oap->oap_lock);
 			break;
 		case -EALREADY:
 			LASSERT((oap->oap_async_flags & ASYNC_READY) != 0);
@@ -1165,9 +1163,7 @@ static int osc_extent_make_ready(const struct lu_env *env,
 			 "last_oap_count %d\n", last_oap_count);
 		LASSERT(last->oap_page_off + last_oap_count <= PAGE_SIZE);
 		last->oap_count = last_oap_count;
-		spin_lock(&last->oap_lock);
 		last->oap_async_flags |= ASYNC_COUNT_STABLE;
-		spin_unlock(&last->oap_lock);
 	}
 
 	/* for the rest of pages, we don't need to call osf_refresh_count()
@@ -1176,9 +1172,7 @@ static int osc_extent_make_ready(const struct lu_env *env,
 	list_for_each_entry(oap, &ext->oe_pages, oap_pending_item) {
 		if (!(oap->oap_async_flags & ASYNC_COUNT_STABLE)) {
 			oap->oap_count = PAGE_SIZE - oap->oap_page_off;
-			spin_lock(&last->oap_lock);
 			oap->oap_async_flags |= ASYNC_COUNT_STABLE;
-			spin_unlock(&last->oap_lock);
 		}
 	}
 
@@ -1866,9 +1860,7 @@ static void osc_ap_completion(const struct lu_env *env, struct client_obd *cli,
 	}
 
 	/* As the transfer for this page is being done, clear the flags */
-	spin_lock(&oap->oap_lock);
 	oap->oap_async_flags = 0;
-	spin_unlock(&oap->oap_lock);
 
 	if (oap->oap_cmd & OBD_BRW_WRITE && xid > 0) {
 		spin_lock(&cli->cl_loi_list_lock);
@@ -2330,7 +2322,6 @@ int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
 	INIT_LIST_HEAD(&oap->oap_pending_item);
 	INIT_LIST_HEAD(&oap->oap_rpc_item);
 
-	spin_lock_init(&oap->oap_lock);
 	CDEBUG(D_INFO, "oap %p vmpage %p obj off %llu\n",
 	       oap, vmpage, oap->oap_obj_off);
 	return 0;
@@ -2619,9 +2610,7 @@ int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
 	if (rc)
 		goto out;
 
-	spin_lock(&oap->oap_lock);
 	oap->oap_async_flags |= ASYNC_READY | ASYNC_URGENT;
-	spin_unlock(&oap->oap_lock);
 
 	if (current->flags & PF_MEMALLOC)
 		ext->oe_memalloc = 1;
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index aa8f61d..b9362d9 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -192,12 +192,8 @@ int osc_io_submit(const struct lu_env *env, const struct cl_io_slice *ios,
 			continue;
 		}
 
-		if (page->cp_type != CPT_TRANSIENT) {
-			spin_lock(&oap->oap_lock);
-			oap->oap_async_flags = ASYNC_URGENT | ASYNC_READY;
-			oap->oap_async_flags |= ASYNC_COUNT_STABLE;
-			spin_unlock(&oap->oap_lock);
-		}
+		if (page->cp_type != CPT_TRANSIENT)
+			oap->oap_async_flags = ASYNC_URGENT | ASYNC_READY | ASYNC_COUNT_STABLE;
 
 		osc_page_submit(env, opg, crt, brw_flags);
 		list_add_tail(&oap->oap_pending_item, &list);
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index ba10ba3..667825a 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -204,12 +204,7 @@ static void osc_page_clip(const struct lu_env *env,
 	opg->ops_from = from;
 	/* argument @to is exclusive, but @ops_to is inclusive */
 	opg->ops_to = to - 1;
-	/* This isn't really necessary for transient pages, but we also don't
-	 * call clip on transient pages often, so it's OK.
-	 */
-	spin_lock(&oap->oap_lock);
 	oap->oap_async_flags |= ASYNC_COUNT_STABLE;
-	spin_unlock(&oap->oap_lock);
 }
 
 static int osc_page_flush(const struct lu_env *env,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
