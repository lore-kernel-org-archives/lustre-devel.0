Return-Path: <SRS0=JyPa=L7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9957EC07E95
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:11:59 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 45A7561C48
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:11:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45A7561C48
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id DB7D9338A6F;
	Wed,  7 Jul 2021 12:11:42 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 28B1C21F978
 for <lustre-devel@lists.lustre.org>; Wed,  7 Jul 2021 12:11:23 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 53617100F3DE;
 Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 525769D8BF; Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  7 Jul 2021 15:11:13 -0400
Message-Id: <1625685076-1964-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
References: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/15] lustre: osc: Don't get time for each
 page
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

Getting the time when each batch of pages starts is
sufficiently accurate, and ktime_get() is several % of the
CPU time when doing AIO + DIO.

This relies on previous patches in this series.

Measuring this in milliseconds/gigabyte lets us measure the
improvement in absolute terms, rather than just relative
terms.

This patch reduces i/o time in ms/GiB by:
Write: 17 ms/GiB
Read: 6 ms/GiB

Totals:
Write: 237 ms/GiB
Read: 223 ms/GiB

IOR:
mpirun -np 1  $IOR -w -r -t 64M -b 64G -o ./iorfile --posix.odirect
Without the patch:
write     4030 MiB/s
read      4468  MiB/s

With patch:
write     4326 MiB/s
read      4587 MiB/s

WC-bug-id: https://jira.whamcloud.com/browse/LU-13799
Lustre-commit: 485976ab451dd6708 ("LU-13799 osc: Don't get time for each page")
Signed-off-by: Patrick Farrell <farr0186@gmail.com>
Reviewed-on: https://review.whamcloud.com/39437
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h | 2 +-
 fs/lustre/osc/osc_io.c         | 3 ++-
 fs/lustre/osc/osc_page.c       | 4 ++--
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 884ea59..208bb59 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -584,7 +584,7 @@ void osc_index2policy(union ldlm_policy_data *policy,
 		      pgoff_t start, pgoff_t end);
 void osc_lru_add_batch(struct client_obd *cli, struct list_head *list);
 void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
-		     enum cl_req_type crt, int brw_flags);
+		     enum cl_req_type crt, int brw_flags, ktime_t submit_time);
 int lru_queue_work(const struct lu_env *env, void *data);
 long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 		    long target, bool force);
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 67fe85b..bd92b5d 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -132,6 +132,7 @@ int osc_io_submit(const struct lu_env *env, const struct cl_io_slice *ios,
 	unsigned int max_pages;
 	unsigned int ppc_bits; /* pages per chunk bits */
 	unsigned int ppc;
+	ktime_t submit_time = ktime_get();
 	bool sync_queue = false;
 
 	LASSERT(qin->pl_nr > 0);
@@ -195,7 +196,7 @@ int osc_io_submit(const struct lu_env *env, const struct cl_io_slice *ios,
 		oap->oap_async_flags |= ASYNC_COUNT_STABLE;
 		spin_unlock(&oap->oap_lock);
 
-		osc_page_submit(env, opg, crt, brw_flags);
+		osc_page_submit(env, opg, crt, brw_flags, submit_time);
 		list_add_tail(&oap->oap_pending_item, &list);
 
 		if (page->cp_sync_io)
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index 94db9d2..0f088fe 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -295,7 +295,7 @@ int osc_page_init(const struct lu_env *env, struct cl_object *obj,
  * transfer (i.e., transferred synchronously).
  */
 void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
-		     enum cl_req_type crt, int brw_flags)
+		     enum cl_req_type crt, int brw_flags, ktime_t submit_time)
 {
 	struct osc_io *oio = osc_env_io(env);
 	struct osc_async_page *oap = &opg->ops_oap;
@@ -316,7 +316,7 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 		oap->oap_cmd |= OBD_BRW_NOQUOTA;
 	}
 
-	opg->ops_submit_time = ktime_get();
+	opg->ops_submit_time = submit_time;
 	osc_page_transfer_get(opg, "transfer\0imm");
 	osc_page_transfer_add(env, opg, crt);
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
