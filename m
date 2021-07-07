Return-Path: <SRS0=JyPa=L7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E824C07E9C
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:11:27 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 15B8A61A13
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:11:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15B8A61A13
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CC1933379F4;
	Wed,  7 Jul 2021 12:11:25 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 78DDD21F888
 for <lustre-devel@lists.lustre.org>; Wed,  7 Jul 2021 12:11:20 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 3ECEF10090E5;
 Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 35B8C9D8BC; Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  7 Jul 2021 15:11:04 -0400
Message-Id: <1625685076-1964-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
References: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/15] lustre: client: don't panic for mgs
 evictions
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
Cc: Ben Evans <jevans@cray.com>, Alexander Boyko <alexander.boyko@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alexander Boyko <alexander.boyko@hpe.com>

Avoid client panics for MGS evictions.
Create a function to check if the eviction is coming
from an MGS, and if so to ignore it.

Rework dump_on_eviction and lbug_on_eviction so
all logic is handled in one place.

HPE-bug-id: LUS-197
WC-bug-id: https://jira.whamcloud.com/browse/LU-13811
Lustre-commit: 5d8f6742e65d588d ("LU-13811 client: don't panic for mgs evictions")
Signed-off-by: Alexander Boyko <alexander.boyko@hpe.com>
Signed-off-by: Ben Evans <jevans@cray.com>
Reviewed-on: https://review.whamcloud.com/43655
Reviewed-by: Andriy Skulysh <askulysh@gmail.com>
Reviewed-by: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h | 15 +++++++++++++++
 fs/lustre/ptlrpc/import.c     |  5 ++---
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 2fe4ea2..f2a3d2b 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1701,6 +1701,21 @@ int class_add_nids_to_uuid(struct obd_uuid *uuid, lnet_nid_t *nids,
 int class_procfs_init(void);
 int class_procfs_clean(void);
 
+extern unsigned int obd_lbug_on_eviction;
+extern unsigned int obd_dump_on_eviction;
+
+static inline bool do_dump_on_eviction(struct obd_device *exp_obd)
+{
+	if (obd_lbug_on_eviction &&
+	    strncmp(exp_obd->obd_type->typ_name, LUSTRE_MGC_NAME,
+		    strlen(LUSTRE_MGC_NAME))) {
+		CERROR("LBUG upon eviction\n");
+		LBUG();
+	}
+
+	return obd_dump_on_eviction;
+}
+
 /* statfs_pack.c */
 struct kstatfs;
 void statfs_pack(struct obd_statfs *osfs, struct kstatfs *sfs);
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 1f31edb..f28fb68 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -1473,13 +1473,12 @@ static int ptlrpc_invalidate_import_thread(void *data)
 	       imp->imp_obd->obd_name, obd2cli_tgt(imp->imp_obd),
 	       imp->imp_connection->c_remote_uuid.uuid);
 
-	ptlrpc_invalidate_import(imp);
-
-	if (obd_dump_on_eviction) {
+	if (do_dump_on_eviction(imp->imp_obd)) {
 		CERROR("dump the log upon eviction\n");
 		libcfs_debug_dumplog();
 	}
 
+	ptlrpc_invalidate_import(imp);
 	import_set_state(imp, LUSTRE_IMP_RECOVER);
 	ptlrpc_import_recovery_state_machine(imp);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
