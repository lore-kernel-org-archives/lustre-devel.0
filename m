Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A1F19C32771
	for <lustre-devel@archiver.kernel.org>; Sun, 18 Sep 2022 05:23:03 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MVbml2qVbz1yFk;
	Sat, 17 Sep 2022 22:23:03 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MVbm62nSDz1yD9
 for <lustre-devel@lists.lustre.org>; Sat, 17 Sep 2022 22:22:30 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 038A88F10;
 Sun, 18 Sep 2022 01:22:17 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0247AE8BA9; Sun, 18 Sep 2022 01:22:17 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 18 Sep 2022 01:22:06 -0400
Message-Id: <1663478534-19917-17-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
References: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 16/24] lustre: clio: remove cpl_obj
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

Remove cpl_obj from struct cl_page_slice. This member is only used in
the osc layer and struct osc_page already contains a pointer to the
osc_object.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10994
Lustre-commit: 10da530a2411f28988ab5 ("LU-10994 clio: remove cpl_obj")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/47402
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h  | 5 -----
 fs/lustre/include/lustre_osc.h | 5 +++++
 fs/lustre/obdclass/cl_page.c   | 1 -
 fs/lustre/osc/osc_cache.c      | 7 +++----
 fs/lustre/osc/osc_page.c       | 8 ++++----
 5 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index c5adbda..41ce0b0 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -795,11 +795,6 @@ struct cl_page {
  */
 struct cl_page_slice {
 	struct cl_page			*cpl_page;
-	/**
-	 * Object slice corresponding to this page slice. Immutable after
-	 * creation.
-	 */
-	struct cl_object		*cpl_obj;
 	const struct cl_page_operations *cpl_ops;
 };
 
diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 7551390..16d6a8e 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -858,6 +858,11 @@ static inline pgoff_t osc_index(struct osc_page *opg)
 	return opg->ops_oap.oap_obj_off >> PAGE_SHIFT;
 }
 
+static inline struct osc_object *osc_page_object(struct osc_page *ops)
+{
+	return ops->ops_oap.oap_obj;
+}
+
 static inline struct cl_page *oap2cl_page(struct osc_async_page *oap)
 {
 	return oap2osc(oap)->ops_cl.cpl_page;
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index 7829b90d..7011235 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -1078,7 +1078,6 @@ void cl_page_slice_add(struct cl_page *cl_page, struct cl_page_slice *slice,
 	LASSERT(cl_page->cp_layer_count < CP_MAX_LAYER);
 	LASSERT(offset < (1 << sizeof(cl_page->cp_layer_offset[0]) * 8));
 	cl_page->cp_layer_offset[cl_page->cp_layer_count++] = offset;
-	slice->cpl_obj = obj;
 	slice->cpl_ops = ops;
 	slice->cpl_page = cl_page;
 }
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 072cfac..e7b8372 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -1328,14 +1328,13 @@ static int osc_refresh_count(const struct lu_env *env,
 {
 	struct osc_page *opg = oap2osc_page(oap);
 	pgoff_t index = osc_index(oap2osc(oap));
-	struct cl_object *obj;
+	struct cl_object *obj = osc2cl(osc_page_object(opg));
 	struct cl_attr *attr = &osc_env_info(env)->oti_attr;
 	int result;
 	loff_t kms;
 
 	/* readpage queues with _COUNT_STABLE, shouldn't get here. */
 	LASSERT(!(cmd & OBD_BRW_READ));
-	obj = opg->ops_cl.cpl_obj;
 
 	cl_object_attr_lock(obj);
 	result = cl_object_attr_get(env, obj, attr);
@@ -1378,7 +1377,7 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 
 	/* statistic */
 	if (rc == 0 && srvlock) {
-		struct lu_device *ld = opg->ops_cl.cpl_obj->co_lu.lo_dev;
+		struct lu_device *ld = osc_page_object(opg)->oo_cl.co_lu.lo_dev;
 		struct osc_stats *stats = &lu2osc_dev(ld)->od_stats;
 		size_t bytes = oap->oap_count;
 
@@ -2588,7 +2587,7 @@ int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
 			 struct osc_page *ops)
 {
 	struct osc_extent *ext = NULL;
-	struct osc_object *obj = cl2osc(ops->ops_cl.cpl_obj);
+	struct osc_object *obj = osc_page_object(ops);
 	struct cl_page *cp = ops->ops_cl.cpl_page;
 	pgoff_t index = osc_index(ops);
 	struct osc_async_page *oap = &ops->ops_oap;
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index fd87698..7470dee 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -86,7 +86,7 @@ static void osc_page_transfer_put(const struct lu_env *env,
 static void osc_page_transfer_add(const struct lu_env *env,
 				  struct osc_page *opg, enum cl_req_type crt)
 {
-	struct osc_object *obj = cl2osc(opg->ops_cl.cpl_obj);
+	struct osc_object *obj = osc_page_object(opg);
 
 	osc_lru_use(osc_cli(obj), opg);
 }
@@ -129,7 +129,7 @@ static int osc_page_print(const struct lu_env *env,
 {
 	struct osc_page *opg = cl2osc_page(slice);
 	struct osc_async_page *oap = &opg->ops_oap;
-	struct osc_object *obj = cl2osc(slice->cpl_obj);
+	struct osc_object *obj = osc_page_object(opg);
 	struct client_obd *cli = &osc_export(obj)->exp_obd->u.cli;
 
 	return (*printer)(env, cookie, LUSTRE_OSC_NAME
@@ -171,7 +171,7 @@ static void osc_page_delete(const struct lu_env *env,
 			    const struct cl_page_slice *slice)
 {
 	struct osc_page *opg = cl2osc_page(slice);
-	struct osc_object *obj = cl2osc(opg->ops_cl.cpl_obj);
+	struct osc_object *obj = osc_page_object(opg);
 	int rc;
 
 	CDEBUG(D_TRACE, "%p\n", opg);
@@ -235,7 +235,7 @@ static void osc_page_touch(const struct lu_env *env,
 			  const struct cl_page_slice *slice, size_t to)
 {
 	struct osc_page *opg = cl2osc_page(slice);
-	struct cl_object *obj = opg->ops_cl.cpl_obj;
+	struct cl_object *obj = osc2cl(osc_page_object(opg));
 
 	osc_page_touch_at(env, obj, osc_index(opg), to);
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
