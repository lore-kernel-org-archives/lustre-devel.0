Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50F35C4338F
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:54:27 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 1152161037
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:54:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 1152161037
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7EB4E351B45;
	Mon,  2 Aug 2021 12:54:22 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BBD5D35286A
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:50:55 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 5588C1007AA4;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 4F51AC2F55; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:24 -0400
Message-Id: <1627933851-7603-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
References: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/25] lnet: convert
 kiblnd/ksocknal_thread_start to vararg
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

From: Mr NeilBrown <neilb@suse.de>

Rather than requiring the called to format a thread name into a temp
buffer, change these thread_start function to accept a format and
args, and to hand them directly to kthread_run().

This is done with a macro rather than a function as the functions are
trivial and varargs is slightly easier with macros.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 9976d2c35d40a170 ("LU-6142 lnet: convert kiblnd/ksocknal_thread_start to vararg")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/44122
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c    | 10 ++++------
 net/lnet/klnds/o2iblnd/o2iblnd.h    | 10 +++++++++-
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 12 ------------
 net/lnet/klnds/socklnd/socklnd.c    | 16 ++++++----------
 net/lnet/klnds/socklnd/socklnd.h    | 10 +++++++++-
 net/lnet/klnds/socklnd/socklnd_cb.c | 17 ++---------------
 6 files changed, 30 insertions(+), 45 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index b519a31..3141953 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2712,13 +2712,11 @@ static int kiblnd_start_schedulers(struct kib_sched_info *sched)
 	}
 
 	for (i = 0; i < nthrs; i++) {
-		long id;
-		char name[20];
+		long id = KIB_THREAD_ID(sched->ibs_cpt, sched->ibs_nthreads + i);
 
-		id = KIB_THREAD_ID(sched->ibs_cpt, sched->ibs_nthreads + i);
-		snprintf(name, sizeof(name), "kiblnd_sd_%02ld_%02ld",
-			 KIB_THREAD_CPT(id), KIB_THREAD_TID(id));
-		rc = kiblnd_thread_start(kiblnd_scheduler, (void *)id, name);
+		rc = kiblnd_thread_start(kiblnd_scheduler, (void *)id,
+					 "kiblnd_sd_%02ld_%02ld",
+					 KIB_THREAD_CPT(id), KIB_THREAD_TID(id));
 		if (!rc)
 			continue;
 
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 8d1d7eb..3691bfe 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -907,7 +907,15 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 
 int kiblnd_connd(void *arg);
 int kiblnd_scheduler(void *arg);
-int kiblnd_thread_start(int (*fn)(void *arg), void *arg, char *name);
+#define kiblnd_thread_start(fn, data, namefmt, arg...)			\
+	({								\
+		struct task_struct *__task = kthread_run(fn, data,	\
+							 namefmt, ##arg);\
+		if (!IS_ERR(__task))					\
+			atomic_inc(&kiblnd_data.kib_nthreads);		\
+		PTR_ERR_OR_ZERO(__task);				\
+	})
+
 int kiblnd_failover_thread(void *arg);
 
 int kiblnd_alloc_pages(struct kib_pages **pp, int cpt, int npages);
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 32ccac2..193e75b 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1830,18 +1830,6 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	return rc;
 }
 
-int
-kiblnd_thread_start(int (*fn)(void *arg), void *arg, char *name)
-{
-	struct task_struct *task = kthread_run(fn, arg, "%s", name);
-
-	if (IS_ERR(task))
-		return PTR_ERR(task);
-
-	atomic_inc(&kiblnd_data.kib_nthreads);
-	return 0;
-}
-
 static void
 kiblnd_thread_fini(void)
 {
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index e15f1c0..cbbbb0c 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -2066,15 +2066,13 @@ static int ksocknal_device_event(struct notifier_block *unused,
 	}
 
 	for (i = 0; i < *ksocknal_tunables.ksnd_nconnds; i++) {
-		char name[16];
-
 		spin_lock_bh(&ksocknal_data.ksnd_connd_lock);
 		ksocknal_data.ksnd_connd_starting++;
 		spin_unlock_bh(&ksocknal_data.ksnd_connd_lock);
 
-		snprintf(name, sizeof(name), "socknal_cd%02d", i);
 		rc = ksocknal_thread_start(ksocknal_connd,
-					   (void *)((uintptr_t)i), name);
+					   (void *)((uintptr_t)i),
+					   "socknal_cd%02d", i);
 		if (rc) {
 			spin_lock_bh(&ksocknal_data.ksnd_connd_lock);
 			ksocknal_data.ksnd_connd_starting--;
@@ -2241,14 +2239,12 @@ static int ksocknal_device_event(struct notifier_block *unused,
 
 	for (i = 0; i < nthrs; i++) {
 		long id;
-		char name[20];
 
 		id = KSOCK_THREAD_ID(sched->kss_cpt, sched->kss_nthreads + i);
-		snprintf(name, sizeof(name), "socknal_sd%02d_%02d",
-			 sched->kss_cpt, (int)KSOCK_THREAD_SID(id));
-
-		rc = ksocknal_thread_start(ksocknal_scheduler,
-					   (void *)id, name);
+		rc = ksocknal_thread_start(ksocknal_scheduler, (void *)id,
+					   "socknal_sd%02d_%02d",
+					   sched->kss_cpt,
+					   (int)KSOCK_THREAD_SID(id));
 		if (!rc)
 			continue;
 
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 357769a..45103a3 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -650,7 +650,15 @@ int ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
 void ksocknal_queue_tx_locked(struct ksock_tx *tx, struct ksock_conn *conn);
 void ksocknal_txlist_done(struct lnet_ni *ni, struct list_head *txlist, int error);
 void ksocknal_query(struct lnet_ni *ni, lnet_nid_t nid, time64_t *when);
-int ksocknal_thread_start(int (*fn)(void *arg), void *arg, char *name);
+#define ksocknal_thread_start(fn, data, namefmt, arg...)		\
+	({								\
+		struct task_struct *__task = kthread_run(fn, data,	\
+							 namefmt, ##arg);\
+		if (!IS_ERR(__task))					\
+			atomic_inc(&ksocknal_data.ksnd_nthreads);	\
+		PTR_ERR_OR_ZERO(__task);				\
+	})
+
 void ksocknal_thread_fini(void);
 void ksocknal_launch_all_connections_locked(struct ksock_peer_ni *peer_ni);
 struct ksock_conn_cb *
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index bfb98f5..efec479 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -966,18 +966,6 @@ struct ksock_conn_cb *
 	return -EIO;
 }
 
-int
-ksocknal_thread_start(int (*fn)(void *arg), void *arg, char *name)
-{
-	struct task_struct *task = kthread_run(fn, arg, "%s", name);
-
-	if (IS_ERR(task))
-		return PTR_ERR(task);
-
-	atomic_inc(&ksocknal_data.ksnd_nthreads);
-	return 0;
-}
-
 void
 ksocknal_thread_fini(void)
 {
@@ -1951,7 +1939,6 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 static int
 ksocknal_connd_check_start(time64_t sec, long *timeout)
 {
-	char name[16];
 	int rc;
 	int total = ksocknal_data.ksnd_connd_starting +
 		    ksocknal_data.ksnd_connd_running;
@@ -1991,8 +1978,8 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	spin_unlock_bh(&ksocknal_data.ksnd_connd_lock);
 
 	/* NB: total is the next id */
-	snprintf(name, sizeof(name), "socknal_cd%02d", total);
-	rc = ksocknal_thread_start(ksocknal_connd, NULL, name);
+	rc = ksocknal_thread_start(ksocknal_connd, NULL,
+				   "socknal_cd%02d", total);
 
 	spin_lock_bh(&ksocknal_data.ksnd_connd_lock);
 	if (!rc)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
