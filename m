Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 1CC10C433FE
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Oct 2022 21:38:28 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mq0B95tDdz1y2t;
	Fri, 14 Oct 2022 14:38:25 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mq0B1326wz1xJR
 for <lustre-devel@lists.lustre.org>; Fri, 14 Oct 2022 14:38:17 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id EB6A01006F21;
 Fri, 14 Oct 2022 17:38:13 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E32F2DD6ED; Fri, 14 Oct 2022 17:38:13 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 14 Oct 2022 17:37:55 -0400
Message-Id: <1665783491-13827-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
References: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/20] lustre: osc: take ldlm lock when queue
 sync pages
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

From: Bobi Jam <bobijam@whamcloud.com>

osc_queue_sync_pages() add osc_extent to osc_object's IO extent
list without taking ldlm locks, and then it calls
osc_io_unplug_async() to queue the IO work for the client.

This patch make sync page queuing take ldlm lock in the
osc_extent.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16160
Lustre-commit: 67aca1fcc6bed2079 ("LU-16160 osc: take ldlm lock when queue sync pages")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/48557
Reviewed-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h |  3 +++
 fs/lustre/mdc/mdc_dev.c        |  3 +++
 fs/lustre/osc/osc_cache.c      |  7 +++++++
 fs/lustre/osc/osc_io.c         |  1 +
 fs/lustre/osc/osc_lock.c       | 19 +++++++++++++++++++
 5 files changed, 33 insertions(+)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 89f02c51dbb3..323eeba3da42 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -157,6 +157,7 @@ struct osc_io {
 
 	/* write osc_lock for this IO, used by osc_extent_find(). */
 	struct osc_lock		*oi_write_osclock;
+	struct osc_lock		*oi_read_osclock;
 	struct obdo		oi_oa;
 	struct osc_async_cbargs {
 		bool			opc_rpc_sent;
@@ -724,6 +725,8 @@ int osc_lock_enqueue_wait(const struct lu_env *env, struct osc_object *obj,
 			  struct osc_lock *oscl);
 void osc_lock_set_writer(const struct lu_env *env, const struct cl_io *io,
 			 struct cl_object *obj, struct osc_lock *oscl);
+void osc_lock_set_reader(const struct lu_env *env, const struct cl_io *io,
+			 struct cl_object *obj, struct osc_lock *oscl);
 int osc_lock_print(const struct lu_env *env, void *cookie,
 		   lu_printer_t p, const struct cl_lock_slice *slice);
 void osc_lock_cancel(const struct lu_env *env,
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index fd0e36225c13..2fd137d2fa4b 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -966,6 +966,9 @@ int mdc_lock_init(const struct lu_env *env, struct cl_object *obj,
 
 	if (io->ci_type == CIT_WRITE || cl_io_is_mkwrite(io))
 		osc_lock_set_writer(env, io, obj, ols);
+	else if (io->ci_type == CIT_READ ||
+		 (io->ci_type == CIT_FAULT && !io->u.ci_fault.ft_mkwrite))
+		osc_lock_set_reader(env, io, obj, ols);
 
 	LDLM_DEBUG_NOLOCK("lock %p, mdc lock %p, flags %llx\n",
 			  lock, ols, ols->ols_flags);
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index b6f0cdb92bdc..36fec837d93e 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2655,6 +2655,7 @@ int osc_queue_sync_pages(const struct lu_env *env, struct cl_io *io,
 			 struct osc_object *obj, struct list_head *list,
 			 int brw_flags)
 {
+	struct osc_io *oio = osc_env_io(env);
 	struct client_obd *cli = osc_cli(obj);
 	struct osc_extent *ext;
 	struct osc_async_page *oap;
@@ -2663,6 +2664,7 @@ int osc_queue_sync_pages(const struct lu_env *env, struct cl_io *io,
 	bool can_merge = true;
 	pgoff_t start = CL_PAGE_EOF;
 	pgoff_t end = 0;
+	struct osc_lock *oscl;
 
 	list_for_each_entry(oap, list, oap_pending_item) {
 		struct osc_page *opg = oap2osc_page(oap);
@@ -2703,6 +2705,11 @@ int osc_queue_sync_pages(const struct lu_env *env, struct cl_io *io,
 	ext->oe_srvlock = !!(brw_flags & OBD_BRW_SRVLOCK);
 	ext->oe_ndelay = !!(brw_flags & OBD_BRW_NDELAY);
 	ext->oe_dio = !!(brw_flags & OBD_BRW_NOCACHE);
+	oscl = oio->oi_write_osclock ? : oio->oi_read_osclock;
+	if (oscl && oscl->ols_dlmlock != NULL) {
+		ext->oe_dlmlock = LDLM_LOCK_GET(oscl->ols_dlmlock);
+		lu_ref_add(&ext->oe_dlmlock->l_reference, "osc_extent", ext);
+	}
 	if (ext->oe_dio && !ext->oe_rw) { /* direct io write */
 		int grants;
 		int ppc;
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 4c9b3d2bb481..aa8f61d710b9 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -461,6 +461,7 @@ void osc_io_rw_iter_fini(const struct lu_env *env,
 		oio->oi_lru_reserved = 0;
 	}
 	oio->oi_write_osclock = NULL;
+	oio->oi_read_osclock = NULL;
 
 	osc_io_iter_fini(env, ios);
 }
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index c8f85020c8fe..dd109496d260 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -1178,6 +1178,22 @@ void osc_lock_set_writer(const struct lu_env *env, const struct cl_io *io,
 }
 EXPORT_SYMBOL(osc_lock_set_writer);
 
+void osc_lock_set_reader(const struct lu_env *env, const struct cl_io *io,
+			 struct cl_object *obj, struct osc_lock *oscl)
+{
+	struct osc_io *oio = osc_env_io(env);
+
+	if (!cl_object_same(io->ci_obj, obj))
+		return;
+
+	if (oscl->ols_glimpse || osc_lock_is_lockless(oscl))
+		return;
+
+	if (oio->oi_read_osclock == NULL)
+		oio->oi_read_osclock = oscl;
+}
+EXPORT_SYMBOL(osc_lock_set_reader);
+
 int osc_lock_init(const struct lu_env *env,
 		  struct cl_object *obj, struct cl_lock *lock,
 		  const struct cl_io *io)
@@ -1224,6 +1240,9 @@ int osc_lock_init(const struct lu_env *env,
 
 	if (io->ci_type == CIT_WRITE || cl_io_is_mkwrite(io))
 		osc_lock_set_writer(env, io, obj, oscl);
+	else if (io->ci_type == CIT_READ ||
+		 (io->ci_type == CIT_FAULT && !io->u.ci_fault.ft_mkwrite))
+		osc_lock_set_reader(env, io, obj, oscl);
 
 
 	LDLM_DEBUG_NOLOCK("lock %p, osc lock %p, flags %llx",
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
