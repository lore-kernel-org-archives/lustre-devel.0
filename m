Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 557DFC433EF
	for <lustre-devel@archiver.kernel.org>; Tue, 19 Apr 2022 00:31:47 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 62A23427690;
	Mon, 18 Apr 2022 17:31:23 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D62A1425525
 for <lustre-devel@lists.lustre.org>; Mon, 18 Apr 2022 17:31:07 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 2709F10058DF;
 Mon, 18 Apr 2022 20:31:06 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1CCAED75A2; Mon, 18 Apr 2022 20:31:06 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 18 Apr 2022 20:30:59 -0400
Message-Id: <1650328264-8763-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1650328264-8763-1-git-send-email-jsimmons@infradead.org>
References: <1650328264-8763-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 2/7] lustre: llite: Fix use of uninitialized
 fields
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

From: Patrick Farrell <pfarrell@whamcloud.com>

We use data from ci_rw to set io_start_index and
io_end_index, which is a problem for mmap because mmap does
not use ci_rw.

When ci_rand_read is set or readahead is disabled, we use
these values to decide how much data to read.

ci_rw is uninitialized, and if the values are non-zero,
we may try to read data beyond the locks we took for our
I/O.

If there is no lock (either because there was never one or
it was cancelled), this results in an LBUG in
osc_req_attr_set when it verifies the pages are covered by
a lock.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15637
Lustre-commit: 9884f37985c1108fb ("LU-15637 llite: Fix use of uninitialized fields")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/46776
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index b8cffde..0ddd920 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -1627,6 +1627,8 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 	struct ll_readahead_state *ras = NULL;
 	struct cl_2queue *queue = &io->ci_queue;
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	struct vvp_io *vio = vvp_env_io(env);
+	bool mmap = !vio->vui_ra_valid;
 	struct cl_sync_io *anchor = NULL;
 	pgoff_t ra_start_index = 0;
 	pgoff_t io_start_index;
@@ -1644,12 +1646,11 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 	uptodate = vpg->vpg_defer_uptodate;
 
 	if (ll_readahead_enabled(sbi) && !vpg->vpg_ra_updated && ras) {
-		struct vvp_io *vio = vvp_env_io(env);
 		enum ras_update_flags flags = 0;
 
 		if (uptodate)
 			flags |= LL_RAS_HIT;
-		if (!vio->vui_ra_valid)
+		if (mmap)
 			flags |= LL_RAS_MMAP;
 		ras_update(sbi, inode, ras, vvp_index(vpg), flags, io);
 	}
@@ -1667,9 +1668,16 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 		cl_page_list_add(&queue->c2_qin, page, true);
 	}
 
-	io_start_index = cl_index(io->ci_obj, io->u.ci_rw.crw_pos);
-	io_end_index = cl_index(io->ci_obj, io->u.ci_rw.crw_pos +
-				io->u.ci_rw.crw_count - 1);
+	/* mmap does not set the ci_rw fields */
+	if (!mmap) {
+		io_start_index = cl_index(io->ci_obj, io->u.ci_rw.crw_pos);
+		io_end_index = cl_index(io->ci_obj, io->u.ci_rw.crw_pos +
+					io->u.ci_rw.crw_count - 1);
+	} else {
+		io_start_index = vvp_index(vpg);
+		io_end_index = vvp_index(vpg);
+	}
+
 	if (ll_readahead_enabled(sbi) && ras && !io->ci_rand_read) {
 		pgoff_t skip_index = 0;
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
