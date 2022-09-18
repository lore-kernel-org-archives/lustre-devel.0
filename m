Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 134CFC32771
	for <lustre-devel@archiver.kernel.org>; Sun, 18 Sep 2022 05:23:12 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MVbmv5N40z1yFD;
	Sat, 17 Sep 2022 22:23:11 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MVbm718x6z1yDP
 for <lustre-devel@lists.lustre.org>; Sat, 17 Sep 2022 22:22:31 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 06EE78F11;
 Sun, 18 Sep 2022 01:22:17 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0554C1C6DE; Sun, 18 Sep 2022 01:22:17 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 18 Sep 2022 01:22:07 -0400
Message-Id: <1663478534-19917-18-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
References: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 17/24] lustre: osc: remove oap_cli
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

From: "John L. Hammond" <jhammond@whamcloud.com>

Remove the redundant oap_cli member from struct osc_async_page.

...:(cl_page.c:216:__cl_page_alloc()) slab-alloced 'cl_page': 256 at 000000009ab84b37.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10994
Lustre-commit: 9b4fb6e65414fa75a ("LU-10994 osc: remove oap_cli")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/47403
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h | 1 -
 fs/lustre/osc/osc_cache.c      | 6 ++----
 fs/lustre/osc/osc_page.c       | 2 +-
 3 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 16d6a8e..d630169 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -88,7 +88,6 @@ struct osc_async_page {
 	struct brw_page		oap_brw_page;
 
 	struct ptlrpc_request	*oap_request;
-	struct client_obd	*oap_cli;
 	struct osc_object	*oap_obj;
 
 	spinlock_t		oap_lock;
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index e7b8372..29d13f5 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2314,7 +2314,6 @@ int __osc_io_unplug(const struct lu_env *env, struct client_obd *cli,
 int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
 			struct cl_page *page, loff_t offset)
 {
-	struct obd_export *exp = osc_export(osc);
 	struct osc_async_page *oap = &ops->ops_oap;
 	struct page *vmpage = page->cp_vmpage;
 
@@ -2322,7 +2321,6 @@ int osc_prep_async_page(struct osc_object *osc, struct osc_page *ops,
 		return -EIO;
 
 	oap->oap_magic = OAP_MAGIC;
-	oap->oap_cli = &exp->exp_obd->u.cli;
 	oap->oap_obj = osc;
 
 	oap->oap_page = vmpage;
@@ -2353,9 +2351,9 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 	struct osc_io *oio = osc_env_io(env);
 	struct osc_extent *ext = NULL;
 	struct osc_async_page *oap = &ops->ops_oap;
-	struct client_obd *cli = oap->oap_cli;
 	struct osc_object *osc = oap->oap_obj;
-	struct pagevec        *pvec = &osc_env_info(env)->oti_pagevec;
+	struct client_obd *cli = osc_cli(osc);
+	struct pagevec *pvec = &osc_env_info(env)->oti_pagevec;
 	pgoff_t index;
 	unsigned int grants = 0, tmp;
 	int brw_flags = OBD_BRW_ASYNC;
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index 7470dee..5300ac9 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -142,7 +142,7 @@ static int osc_page_print(const struct lu_env *env,
 			  /* 2 */
 			  oap->oap_obj_off, oap->oap_page_off, oap->oap_count,
 			  oap->oap_async_flags, oap->oap_brw_flags,
-			  oap->oap_request, oap->oap_cli, obj,
+			  oap->oap_request, cli, obj,
 			  /* 3 */
 			  opg->ops_transfer_pinned,
 			  osc_submit_duration(opg), opg->ops_srvlock,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
