Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 99FB0C6FA86
	for <lustre-devel@archiver.kernel.org>; Sun, 18 Sep 2022 05:23:02 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MVbmk2grjz1y7W;
	Sat, 17 Sep 2022 22:23:02 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MVbm762VQz1yDb
 for <lustre-devel@lists.lustre.org>; Sat, 17 Sep 2022 22:22:31 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 0A7438F12;
 Sun, 18 Sep 2022 01:22:17 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 085C81C6DF; Sun, 18 Sep 2022 01:22:17 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 18 Sep 2022 01:22:08 -0400
Message-Id: <1663478534-19917-19-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
References: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 18/24] lustre: osc: Remove submit time
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

The osc page submit time is an unused bit of debugging
information, but it's allocated for every page.  Let's
just remove it to save memory.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15619
Lustre-commit: 28a7bbdb81cfd8359 ("LU-15619 osc: Remove submit time")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/46712
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h |  6 +-----
 fs/lustre/osc/osc_cache.c      |  9 +--------
 fs/lustre/osc/osc_io.c         |  3 +--
 fs/lustre/osc/osc_page.c       | 15 +++------------
 4 files changed, 6 insertions(+), 27 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index d630169..89f02c5 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -542,10 +542,6 @@ struct osc_page {
 	 * lru page list. See osc_lru_{del|use}() in osc_page.c for usage.
 	 */
 	struct list_head	ops_lru;
-	/*
-	 * Submit time - the time when the page is starting RPC. For debugging.
-	 */
-	ktime_t			ops_submit_time;
 };
 
 struct osc_brw_async_args {
@@ -582,7 +578,7 @@ void osc_index2policy(union ldlm_policy_data *policy,
 		      pgoff_t start, pgoff_t end);
 void osc_lru_add_batch(struct client_obd *cli, struct list_head *list);
 void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
-		     enum cl_req_type crt, int brw_flags, ktime_t submit_time);
+		     enum cl_req_type crt, int brw_flags);
 int lru_queue_work(const struct lu_env *env, void *data);
 long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 		    long target, bool force);
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 29d13f5..b6f0cdb 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -1310,17 +1310,11 @@ static inline int osc_is_ready(struct osc_object *osc)
 static int osc_make_ready(const struct lu_env *env, struct osc_async_page *oap,
 			  int cmd)
 {
-	struct osc_page *opg = oap2osc_page(oap);
 	struct cl_page *page = oap2cl_page(oap);
-	int result;
 
 	LASSERT(cmd == OBD_BRW_WRITE); /* no cached reads */
 
-	result = cl_page_make_ready(env, page, CRT_WRITE);
-	if (result == 0)
-		opg->ops_submit_time = ktime_get();
-
-	return result;
+	return cl_page_make_ready(env, page, CRT_WRITE);
 }
 
 static int osc_refresh_count(const struct lu_env *env,
@@ -1372,7 +1366,6 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 	/* Clear opg->ops_transfer_pinned before VM lock is released. */
 	opg->ops_transfer_pinned = 0;
 
-	opg->ops_submit_time = ktime_set(0, 0);
 	srvlock = oap->oap_brw_flags & OBD_BRW_SRVLOCK;
 
 	/* statistic */
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 1361d7f..655c7c6 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -132,7 +132,6 @@ int osc_io_submit(const struct lu_env *env, const struct cl_io_slice *ios,
 	unsigned int max_pages;
 	unsigned int ppc_bits; /* pages per chunk bits */
 	unsigned int ppc;
-	ktime_t submit_time = ktime_get();
 	bool sync_queue = false;
 
 	LASSERT(qin->pl_nr > 0);
@@ -200,7 +199,7 @@ int osc_io_submit(const struct lu_env *env, const struct cl_io_slice *ios,
 			spin_unlock(&oap->oap_lock);
 		}
 
-		osc_page_submit(env, opg, crt, brw_flags, submit_time);
+		osc_page_submit(env, opg, crt, brw_flags);
 		list_add_tail(&oap->oap_pending_item, &list);
 
 		if (page->cp_sync_io)
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index 5300ac9..12ba108 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -115,14 +115,6 @@ void osc_index2policy(union ldlm_policy_data *policy,
 	policy->l_extent.end = cl_offset(obj, end + 1) - 1;
 }
 
-static inline s64 osc_submit_duration(struct osc_page *opg)
-{
-	if (ktime_to_ns(opg->ops_submit_time) == 0)
-		return 0;
-
-	return ktime_ms_delta(ktime_get(), opg->ops_submit_time);
-}
-
 static int osc_page_print(const struct lu_env *env,
 			  const struct cl_page_slice *slice,
 			  void *cookie, lu_printer_t printer)
@@ -133,7 +125,7 @@ static int osc_page_print(const struct lu_env *env,
 	struct client_obd *cli = &osc_export(obj)->exp_obd->u.cli;
 
 	return (*printer)(env, cookie, LUSTRE_OSC_NAME
-			  "-page@%p %lu: 1< %#x %d %c %c > 2< %llu %u %u %#x %#x | %p %p %p > 3< %d %lld %d > 4< %d %d %d %lu %c | %c %c %c %c > 5< %c %c %c %c | %d %c | %d %c %c>\n",
+			  "-page@%p %lu: 1< %#x %d %c %c > 2< %llu %u %u %#x %#x | %p %p %p > 3< %d %d > 4< %d %d %d %lu %c | %c %c %c %c > 5< %c %c %c %c | %d %c | %d %c %c>\n",
 			  opg, osc_index(opg),
 			  /* 1 */
 			  oap->oap_magic, oap->oap_cmd,
@@ -145,7 +137,7 @@ static int osc_page_print(const struct lu_env *env,
 			  oap->oap_request, cli, obj,
 			  /* 3 */
 			  opg->ops_transfer_pinned,
-			  osc_submit_duration(opg), opg->ops_srvlock,
+			  opg->ops_srvlock,
 			  /* 4 */
 			  cli->cl_r_in_flight, cli->cl_w_in_flight,
 			  cli->cl_max_rpcs_in_flight,
@@ -296,7 +288,7 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
  * transfer (i.e., transferred synchronously).
  */
 void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
-		     enum cl_req_type crt, int brw_flags, ktime_t submit_time)
+		     enum cl_req_type crt, int brw_flags)
 {
 	struct osc_io *oio = osc_env_io(env);
 	struct osc_async_page *oap = &opg->ops_oap;
@@ -317,7 +309,6 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 		oap->oap_cmd |= OBD_BRW_SYS_RESOURCE;
 	}
 
-	opg->ops_submit_time = submit_time;
 	osc_page_transfer_get(opg, "transfer\0imm");
 	osc_page_transfer_add(env, opg, crt);
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
