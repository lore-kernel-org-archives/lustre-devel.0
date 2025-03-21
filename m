Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id D1F9EC36000
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:46:21 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2xq2Sd0z2138;
	Fri, 21 Mar 2025 06:15:43 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2q72WZVz1ynp
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:09:55 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm4-e204-208.ccs.ornl.gov [160.91.203.22])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B324A17B5B8;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id B1CEB106BE14; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:07:10 -0400
Message-ID: <20250321130711.3257092-28-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 27/27] lustre: obd: remove unused
 obd_evict_inprogress
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Timothy Day <timday@amazon.com>

Remove the atomic_t struct field obd_evict_inprogress
from 'struct obd_device'. This field was only ever
incremented in a unused function that was removed in
a previous patch. Hence, remove it altogther. This
patch also removes the associated wait queue.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16965
Lustre-commit: d5051f374799bed52 ("LU-16965 obd: remove unused obd_evict_inprogress")
Signed-off-by: Timothy Day <timday@amazon.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51681
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h     | 2 --
 fs/lustre/obdclass/genops.c | 2 --
 2 files changed, 4 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 8f6d42544711..f385c677020e 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -620,8 +620,6 @@ struct obd_device {
 	struct lprocfs_stats	*obd_svc_stats;
 	const struct attribute **obd_attrs;
 	struct ldebugfs_vars	*obd_vars;
-	atomic_t		 obd_evict_inprogress;
-	wait_queue_head_t	 obd_evict_inprogress_waitq;
 	struct list_head	 obd_evict_list; /* protected with pet_lock */
 
 	/**
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 0cbc2c7c393d..935ba92c387a 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -309,8 +309,6 @@ struct obd_device *class_newdev(const char *type_name, const char *name,
 
 	/* XXX belongs in setup not attach  */
 	init_rwsem(&newdev->obd_observer_link_sem);
-	/* recovery data */
-	init_waitqueue_head(&newdev->obd_evict_inprogress_waitq);
 
 	llog_group_init(&newdev->obd_olg);
 	/* Detach drops this */
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
