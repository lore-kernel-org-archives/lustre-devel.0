Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 6C0D5C43217
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Oct 2022 21:38:35 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mq0BM0NzZz21JS;
	Fri, 14 Oct 2022 14:38:35 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mq0B54XXqz1y60
 for <lustre-devel@lists.lustre.org>; Fri, 14 Oct 2022 14:38:21 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 087C510084A7;
 Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 04C5ADD53E; Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 14 Oct 2022 17:38:00 -0400
Message-Id: <1665783491-13827-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
References: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 09/20] lustre: osc: Remove oap_magic
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

oap_magic exists only to debug init and allocation
failures, but is allocated for every page of memory, which
wastes a lot of memory for something we don't need
dedicated debug for.

Remove it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15619
Lustre-commit: 721df28648c4b3faa ("LU-15619 osc: Remove oap_magic")
Author: Patrick Farrell <pfarrell@whamcloud.com>
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/46713
Reviewed-by: Zhenyu Xu <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h | 1 -
 fs/lustre/osc/osc_cache.c      | 6 ------
 fs/lustre/osc/osc_page.c       | 7 ++-----
 3 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 323eeba3da42..884eafee8a83 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -75,7 +75,6 @@ enum async_flags {
 };
 
 struct osc_async_page {
-	int			oap_magic;
 	unsigned short		oap_cmd;
 
 	struct list_head        oap_pending_item;
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 36fec837d93e..12d9ab519e48 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2313,7 +2313,6 @@ int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
 	if (!page)
 		return -EIO;
 
-	oap->oap_magic = OAP_MAGIC;
 	oap->oap_obj = osc;
 
 	oap->oap_page = vmpage;
@@ -2354,9 +2353,6 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 	bool need_release = false;
 	int rc = 0;
 
-	if (oap->oap_magic != OAP_MAGIC)
-		return -EINVAL;
-
 	if (!cli->cl_import || cli->cl_import->imp_invalid)
 		return -EIO;
 
@@ -2537,8 +2533,6 @@ int osc_teardown_async_page(const struct lu_env *env,
 	struct osc_async_page *oap = &ops->ops_oap;
 	int rc = 0;
 
-	LASSERT(oap->oap_magic == OAP_MAGIC);
-
 	CDEBUG(D_INFO, "teardown oap %p page %p at index %lu.\n",
 	       oap, ops, osc_index(oap2osc(oap)));
 
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index 12ba10827a23..ba10ba320079 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -125,10 +125,10 @@ static int osc_page_print(const struct lu_env *env,
 	struct client_obd *cli = &osc_export(obj)->exp_obd->u.cli;
 
 	return (*printer)(env, cookie, LUSTRE_OSC_NAME
-			  "-page@%p %lu: 1< %#x %d %c %c > 2< %llu %u %u %#x %#x | %p %p %p > 3< %d %d > 4< %d %d %d %lu %c | %c %c %c %c > 5< %c %c %c %c | %d %c | %d %c %c>\n",
+			  "-page@%p %lu: 1< %d %c %c > 2< %llu %u %u %#x %#x | %p %p %p > 3< %d %d > 4< %d %d %d %lu %c | %c %c %c %c > 5< %c %c %c %c | %d %c | %d %c %c>\n",
 			  opg, osc_index(opg),
 			  /* 1 */
-			  oap->oap_magic, oap->oap_cmd,
+			  oap->oap_cmd,
 			  list_empty_marker(&oap->oap_pending_item),
 			  list_empty_marker(&oap->oap_rpc_item),
 			  /* 2 */
@@ -293,9 +293,6 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 	struct osc_io *oio = osc_env_io(env);
 	struct osc_async_page *oap = &opg->ops_oap;
 
-	LASSERTF(oap->oap_magic == OAP_MAGIC,
-		 "Bad oap magic: oap %p, magic 0x%x\n",
-		 oap, oap->oap_magic);
 	LASSERT(oap->oap_async_flags & ASYNC_READY);
 	LASSERT(oap->oap_async_flags & ASYNC_COUNT_STABLE);
 
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
