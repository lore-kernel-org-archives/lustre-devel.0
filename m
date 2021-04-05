Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0593C433B4
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:53:27 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 846F860FF0
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:53:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 846F860FF0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E8A7632C545;
	Mon,  5 Apr 2021 00:52:45 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D33DD32C4C7
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:28 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 31215EC8;
 Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2EE3D90AA8; Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:51:08 -0400
Message-Id: <1617583870-32029-40-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 39/41] lnet: use init_wait() rather than
 init_waitqueue_entry()
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

init_waitqueue_entry(foo, current)

is equivalent to

  init_wait(foo)

So use the shorter version.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: dd0e7523e10202d2 ("LU-12678 lnet: use init_wait() rather than init_waitqueue_entry()")
Signed-off-by: Mr. NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39295
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 6 +++---
 net/lnet/klnds/socklnd/socklnd_cb.c | 4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index e29cb4b..9f9afce 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -3389,7 +3389,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	int peer_index = 0;
 	unsigned long deadline = jiffies;
 
-	init_waitqueue_entry(&wait, current);
+	init_wait(&wait);
 	kiblnd_data.kib_connd = current;
 
 	spin_lock_irqsave(lock, flags);
@@ -3680,7 +3680,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	int did_something;
 	int rc;
 
-	init_waitqueue_entry(&wait, current);
+	init_wait(&wait);
 
 	sched = kiblnd_data.kib_scheds[KIB_THREAD_CPT(id)];
 
@@ -3812,7 +3812,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 
 	LASSERT(*kiblnd_tunables.kib_dev_failover);
 
-	init_waitqueue_entry(&wait, current);
+	init_wait(&wait);
 	write_lock_irqsave(glock, flags);
 
 	while (!kiblnd_data.kib_shutdown) {
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index a1c0c3d..7fa2d58 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -2075,7 +2075,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	wait_queue_entry_t wait;
 	int cons_retry = 0;
 
-	init_waitqueue_entry(&wait, current);
+	init_wait(&wait);
 
 	spin_lock_bh(connd_lock);
 
@@ -2458,7 +2458,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	int peer_index = 0;
 	time64_t deadline = ktime_get_seconds();
 
-	init_waitqueue_entry(&wait, current);
+	init_wait(&wait);
 
 	spin_lock_bh(&ksocknal_data.ksnd_reaper_lock);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
