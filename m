Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 12CE8C77B76
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 13:57:55 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T2q2m88z21JW;
	Mon, 17 Apr 2023 06:50:27 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0Szm2lzxz1y5y
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:47:48 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 7643B100526A;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 74D1A379; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:47:05 -0400
Message-Id: <1681739243-29375-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 09/27] lustre: readahead: clip readahead with
 kms
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
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Qian Yingjin <qian@ddn.com>

During I/O test, it found that the read-ahead pages reach 255 for
small files with only several KiB. The amount of read data reaches
more than 1MiB.
The reason is that the granted DLM extent lock is [0, EOF], which
is larger than the requested extent. During readahead, the OSC
layer will also return [0, EOF] extent which will clip into stripe
size (1MiB) regardless the actual object size.
In this patch, the readahead range is clipped to the known min
size (kms) on OSC layer during readahead. By this way, the
read-ahead data will not beyong the last page of the file.

This patch also fixes multiop to return successfully when reaching
EOF instead of exiting with ENODATA during read.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16338
Lustre-commit: b33808d3aebb06cf0 ("LU-16338 readahead: clip readahead with kms")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49226
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_io.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index c9a3175..d0ee748 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -83,6 +83,8 @@ static int osc_io_read_ahead(const struct lu_env *env,
 	oio->oi_is_readahead = true;
 	dlmlock = osc_dlmlock_at_pgoff(env, osc, start, 0);
 	if (dlmlock) {
+		struct lov_oinfo *oinfo = osc->oo_oinfo;
+
 		LASSERT(dlmlock->l_ast_data == osc);
 		if (dlmlock->l_req_mode != LCK_PR) {
 			struct lustre_handle lockh;
@@ -100,6 +102,9 @@ static int osc_io_read_ahead(const struct lu_env *env,
 		ra->cra_oio = oio;
 		if (ra->cra_end_idx != CL_PAGE_EOF)
 			ra->cra_contention = true;
+		ra->cra_end_idx = min_t(pgoff_t, ra->cra_end_idx,
+					cl_index(osc2cl(osc),
+						 oinfo->loi_kms - 1));
 		result = 0;
 	}
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
