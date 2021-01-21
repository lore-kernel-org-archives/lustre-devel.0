Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1FE9C433E0
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:17:43 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6331F23A57
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:17:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6331F23A57
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4C1E921FDDE;
	Thu, 21 Jan 2021 09:17:31 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3416321FC28
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:13 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 6C722100848A;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 6B15F1B49C; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:49 -0500
Message-Id: <1611249422-556-27-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 26/39] lustre: lov: fix SEEK_HOLE calcs at
 component end
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
Cc: Mikhail Pershin <mpershin@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mikhail Pershin <mpershin@whamcloud.com>

If data ends exactly at component end then LOV assumed that
is not yet hole in file and the next component will take care.
Meanwhile there can be no next component initialized yet if file
ends exactly at component boundary, so no hole offset is returned
but error

Patch fixes that issue. If component reports hole offset at
component end then it is saved to be used as result when no
other components report valid hole offset.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14143
Lustre-commit: dbb6b493ad9f98 ("LU-14143 lov: fix SEEK_HOLE calcs at component end")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40713
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_io.c | 22 ++++++++++++++++++++--
 1 file changed, 20 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 7f0e945..ac88a55 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -1295,6 +1295,7 @@ static void lov_io_lseek_end(const struct lu_env *env,
 	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
 	struct lov_io_sub *sub;
 	loff_t offset = -ENXIO;
+	u64 hole_off = 0;
 	bool seek_hole = io->u.ci_lseek.ls_whence == SEEK_HOLE;
 
 	list_for_each_entry(sub, &lio->lis_active, sub_linkage) {
@@ -1302,6 +1303,7 @@ static void lov_io_lseek_end(const struct lu_env *env,
 		int index = lov_comp_entry(sub->sub_subio_index);
 		int stripe = lov_comp_stripe(sub->sub_subio_index);
 		loff_t sub_off, lov_off;
+		u64 comp_end = lsm->lsm_entries[index]->lsme_extent.e_end;
 
 		lov_io_end_wrapper(sub->sub_env, subio);
 
@@ -1347,10 +1349,22 @@ static void lov_io_lseek_end(const struct lu_env *env,
 		/* resulting offset can be out of component range if stripe
 		 * object is full and its file size was returned as virtual
 		 * hole start. Skip this result, the next component will give
-		 * us correct lseek result.
+		 * us correct lseek result but keep possible hole offset in
+		 * case there is no more components ahead
 		 */
-		if (lov_off >= lsm->lsm_entries[index]->lsme_extent.e_end)
+		if (lov_off >= comp_end) {
+			/* must be SEEK_HOLE case */
+			if (likely(seek_hole)) {
+				/* save comp end as potential hole offset */
+				hole_off = max_t(u64, comp_end, hole_off);
+			} else {
+				io->ci_result = -EINVAL;
+				CDEBUG(D_INFO,
+				       "off %lld >= comp_end %llu: rc = %d\n",
+				       lov_off, comp_end, io->ci_result);
+			}
 			continue;
+		}
 
 		CDEBUG(D_INFO, "SEEK_%s: %lld->%lld/%lld: rc = %d\n",
 		       seek_hole ? "HOLE" : "DATA",
@@ -1358,6 +1372,10 @@ static void lov_io_lseek_end(const struct lu_env *env,
 		       sub->sub_io.ci_result);
 		offset = min_t(u64, offset, lov_off);
 	}
+	/* no result but some component returns hole as component end */
+	if (seek_hole && offset == -ENXIO && hole_off > 0)
+		offset = hole_off;
+
 	io->u.ci_lseek.ls_result = offset;
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
