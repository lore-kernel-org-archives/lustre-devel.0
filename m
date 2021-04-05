Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A744FC433ED
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:44 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5631C61396
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5631C61396
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AA01621F746;
	Mon,  5 Apr 2021 00:52:16 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 78B9621F949
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:24 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id E01EEA03;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id DD95290AA9; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:52 -0400
Message-Id: <1617583870-32029-24-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 23/41] lustre: lov: fix layout generation inc
 for mirror split
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

From: Bobi Jam <bobijam@whamcloud.com>

Mirror split does not increase the layout generation properly.

Mirror split does not change FLR state of the file, even when it
contains 1 mirror afterwards, and FLR state should be LCM_FL_NONE
instead.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14268
Lustre-commit: ffa858b1657145c ("LU-14268 lod: fix layout generation inc for mirror split")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41068
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_ea.c     | 4 ++--
 fs/lustre/lov/lov_object.c | 1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/lov/lov_ea.c b/fs/lustre/lov/lov_ea.c
index 75a19a4..f6b3df0 100644
--- a/fs/lustre/lov/lov_ea.c
+++ b/fs/lustre/lov/lov_ea.c
@@ -635,10 +635,10 @@ void dump_lsm(unsigned int level, const struct lov_stripe_md *lsm)
 	int i, j;
 
 	CDEBUG_LIMIT(level,
-		     "lsm %p, objid " DOSTID ", maxbytes %#llx, magic 0x%08X, refc: %d, entry: %u, layout_gen %u\n",
+		     "lsm %p, objid " DOSTID ", maxbytes %#llx, magic 0x%08X, refc: %d, entry: %u, mirror: %u, flags: %u,layout_gen %u\n",
 	       lsm, POSTID(&lsm->lsm_oi), lsm->lsm_maxbytes, lsm->lsm_magic,
 	       atomic_read(&lsm->lsm_refc), lsm->lsm_entry_count,
-	       lsm->lsm_layout_gen);
+	       lsm->lsm_mirror_count, lsm->lsm_flags, lsm->lsm_layout_gen);
 
 	if (lsm->lsm_magic == LOV_MAGIC_FOREIGN) {
 		struct lov_foreign_md *lfm = (void *)lsm_foreign(lsm);
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 5d618c1..abe1cee 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -1374,6 +1374,7 @@ static int lov_conf_set(const struct lu_env *env, struct cl_object *obj,
 	if ((!lsm && !lov->lo_lsm) ||
 	    ((lsm && lov->lo_lsm) &&
 	     (lov->lo_lsm->lsm_layout_gen == lsm->lsm_layout_gen) &&
+	     (lov->lo_lsm->lsm_flags == lsm->lsm_flags) &&
 	     (lov->lo_lsm->lsm_entries[0]->lsme_pattern ==
 	      lsm->lsm_entries[0]->lsme_pattern))) {
 		/* same version of layout */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
