Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B059C4338F
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:52:01 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 13ED160F36
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:52:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 13ED160F36
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A5F64352F15;
	Mon,  2 Aug 2021 12:51:43 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9896D352BAD
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:50:58 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 71A55100804F;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 6F549C2F4C; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:34 -0400
Message-Id: <1627933851-7603-15-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
References: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 14/25] lustre: clio: Skip prep for transients
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

The work done by cpo_prep() (etc) is unnecessary for
transient pages.  This gives only a minimal performance
boost and is better seen as a step towards removing the
cl_page abstraction for transient pages.

But, it does consistently give around 1% better
performance.

This patch reduces i/o time in ms/GiB by:
Write: 1 ms/GiB
Read: 1 ms/GiB

Totals:
Write: 169 ms/GiB
Read: 161 ms/GiB

mpirun -np 1  $IOR -w -r -t 64M -b 64G -o ./iorfile --posix.odirect

With previous patches in series:
write        6028 MiB/s
read         6305 MiB/s

Plus this patch:
write        6071 MiB/s
read         6355 MiB/s

WC-bug-id: https://jira.whamcloud.com/browse/LU-13799
Lustre-commit: b8553978789ad3dd ("LU-13799 clio: Skip prep for transients")
Signed-off-by: Patrick Farrell <farr0186@gmail.com>
Reviewed-on: https://review.whamcloud.com/39448
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/cl_page.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index 41bd767..4bfa1c5 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -850,12 +850,15 @@ int cl_page_prep(const struct lu_env *env, struct cl_io *io,
 	if (crt >= CRT_NR)
 		return -EINVAL;
 
-	cl_page_slice_for_each(cl_page, slice, i) {
-		if (slice->cpl_ops->cpo_own)
-			result = (*slice->cpl_ops->io[crt].cpo_prep)(env, slice,
-								     io);
-		if (result != 0)
-			break;
+	if (cl_page->cp_type != CPT_TRANSIENT) {
+		cl_page_slice_for_each(cl_page, slice, i) {
+			if (slice->cpl_ops->cpo_own)
+				result = (*slice->cpl_ops->io[crt].cpo_prep)(env,
+									     slice,
+									     io);
+			if (result != 0)
+				break;
+		}
 	}
 
 	if (result >= 0) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
