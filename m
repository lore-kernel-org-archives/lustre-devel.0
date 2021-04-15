Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82046C433ED
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:11 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 385BE610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 385BE610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 45D7B32EECA;
	Wed, 14 Apr 2021 21:04:03 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1CA5932F564
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:58 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B98AF100F368;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B87B79188F; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:31 -0400
Message-Id: <1618459361-17909-40-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 39/49] lustre: lov: fault page update
 cp_lov_index
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

In fault IO, vvp_io_fault_start() could find an existing cl_page
associated with the vmpage covering the fault index, and the page
may still refer to another mirror of an old IO.

This patch update the fault page's cp_lov_index in lov_io_fault_start

WC-bug-id: https://jira.whamcloud.com/browse/LU-14502
Lustre-commit: e9bac5fa455eab5 ("LU-14502 lov: fault page update cp_lov_index")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41954
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_io.c | 37 +++++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index a8bba1c..9f67d16 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -1341,9 +1341,46 @@ static int lov_io_fault_start(const struct lu_env *env,
 	struct cl_fault_io *fio;
 	struct lov_io *lio;
 	struct lov_io_sub *sub;
+	loff_t offset;
+	int entry;
+	int stripe;
 
 	fio = &ios->cis_io->u.ci_fault;
 	lio = cl2lov_io(env, ios);
+
+	/**
+	 * LU-14502: ft_page could be an existing cl_page associated with
+	 * the vmpage covering the fault index, and the page may still
+	 * refer to another mirror of an old IO.
+	 */
+	if (lov_is_flr(lio->lis_object)) {
+		offset = cl_offset(ios->cis_obj, fio->ft_index);
+		entry = lov_io_layout_at(lio, offset);
+		if (entry < 0) {
+			CERROR(DFID": page fault index %lu invalid component: %d, mirror: %d\n",
+			       PFID(lu_object_fid(&ios->cis_obj->co_lu)),
+			       fio->ft_index, entry,
+			       lio->lis_mirror_index);
+			return -EIO;
+		}
+		stripe = lov_stripe_number(lio->lis_object->lo_lsm,
+					   entry, offset);
+
+		if (fio->ft_page->cp_lov_index !=
+		    lov_comp_index(entry, stripe)) {
+			CDEBUG(D_INFO,
+			       DFID": page fault at index %lu, at mirror %u comp entry %u stripe %u, been used with comp entry %u stripe %u\n",
+			       PFID(lu_object_fid(&ios->cis_obj->co_lu)),
+			       fio->ft_index, lio->lis_mirror_index,
+			       entry, stripe,
+			       lov_comp_entry(fio->ft_page->cp_lov_index),
+			       lov_comp_stripe(fio->ft_page->cp_lov_index));
+
+			fio->ft_page->cp_lov_index =
+					lov_comp_index(entry, stripe);
+		}
+	}
+
 	sub = lov_sub_get(env, lio, fio->ft_page->cp_lov_index);
 	if (IS_ERR(sub))
 		return PTR_ERR(sub);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
