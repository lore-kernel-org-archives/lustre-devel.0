Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F415BC4338F
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:08 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A72D660F36
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org A72D660F36
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B5814352D9E;
	Mon,  2 Aug 2021 12:51:06 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 131FE352B78
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:50:58 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 6A297100804D;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 690CAC2F56; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:32 -0400
Message-Id: <1627933851-7603-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
References: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/25] lustre: lov: Improve DIO submit
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

Skip some unnecessary looping in page submission for the
DIO case.

This gives about a 2% improvement for AIO/DIO page
submission.

This patch reduces i/o time in ms/GiB by:
Write: 2 ms/GiB
Read: 2 ms/GiB

Totals:
Write: 172 ms/GiB
Read: 165 ms/GiB

mpirun -np 1  $IOR -w -r -t 64M -b 64G -o ./iorfile --posix.odirect

With previous patches in series:
write        7726 MiB/s
read         5899 MiB/s

Plus this patch:
write        5954 MiB/s
read         6217 MiB/s

WC-bug-id: https://jira.whamcloud.com/browse/LU-13799
Lustre-commit: d31647c017a390c9 ("LU-13799 lov: Improve DIO submit")
Signed-off-by: Patrick Farrell <farr0186@gmail.com>
Reviewed-on: https://review.whamcloud.com/39446
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_io.c | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 9012ad6..2885943 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -1255,11 +1255,15 @@ static int lov_io_submit(const struct lu_env *env,
 	struct lov_io *lio = cl2lov_io(env, ios);
 	struct lov_io_sub *sub;
 	struct cl_page_list *plist = &lov_env_info(env)->lti_plist;
-	struct cl_page *page;
+	struct cl_page *page = cl_page_list_first(qin);
 	struct cl_page *tmp;
+	bool dio = false;
 	int index;
 	int rc = 0;
 
+	if (page->cp_type == CPT_TRANSIENT)
+		dio = true;
+
 	cl_page_list_init(plist);
 	while (qin->pl_nr > 0) {
 		struct cl_2queue *cl2q = &lov_env_info(env)->lti_cl2q;
@@ -1281,12 +1285,17 @@ static int lov_io_submit(const struct lu_env *env,
 		cl_page_list_move(&cl2q->c2_qin, qin, page);
 
 		index = page->cp_lov_index;
-		cl_page_list_for_each_safe(page, tmp, qin) {
-			/* this page is not on this stripe */
-			if (index != page->cp_lov_index)
-				continue;
-
-			cl_page_list_move(&cl2q->c2_qin, qin, page);
+		/* DIO is already split by stripe */
+		if (!dio) {
+			cl_page_list_for_each_safe(page, tmp, qin) {
+				/* this page is not on this stripe */
+				if (index != page->cp_lov_index)
+					continue;
+
+				cl_page_list_move(&cl2q->c2_qin, qin, page);
+			}
+		} else {
+			cl_page_list_splice(qin, &cl2q->c2_qin);
 		}
 
 		sub = lov_sub_get(env, lio, index);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
