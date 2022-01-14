Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 76437C433FE
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:38:15 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 27F3B3AD876;
	Thu, 13 Jan 2022 17:38:14 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 127A23AD84A
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:11 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id DA55E100F334;
 Thu, 13 Jan 2022 20:38:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D81A7E07E3; Thu, 13 Jan 2022 20:38:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:37:54 -0500
Message-Id: <1642124283-10148-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
References: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/24] lustre: llite: Add start_idx debug
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

When readahead is triggered, current readahead debug
prints the page the user requested which triggered
readahead and the number of pages read by readahead.

However, readahead does not necessarily start reading from
the user requested page, so it's important to also print
the page where readahead starts.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15069
Lustre-commit: e13ed446337273a04 ("LU-15069 llite: Add start_idx debug")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45674
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw.c | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 9f6e140..b8cffde 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -713,12 +713,13 @@ static void ll_readahead_handle_work(struct work_struct *wq)
 static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 			struct cl_page_list *queue,
 			struct ll_readahead_state *ras, bool hit,
-			struct file *file, pgoff_t skip_index)
+			struct file *file, pgoff_t skip_index,
+			pgoff_t *start_idx)
 {
 	struct vvp_io *vio = vvp_env_io(env);
 	struct ll_thread_info *lti = ll_env_info(env);
 	unsigned long pages, pages_min = 0;
-	pgoff_t ra_end_idx = 0, start_idx = 0, end_idx = 0;
+	pgoff_t ra_end_idx = 0, end_idx = 0;
 	struct inode *inode;
 	struct ra_io_arg *ria = &lti->lti_ria;
 	struct cl_object *clob;
@@ -761,16 +762,16 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	 * so that stride read ahead can work correctly.
 	 */
 	if (stride_io_mode(ras))
-		start_idx = max_t(pgoff_t, ras->ras_next_readahead_idx,
+		*start_idx = max_t(pgoff_t, ras->ras_next_readahead_idx,
 				  ras->ras_stride_offset >> PAGE_SHIFT);
 	else
-		start_idx = ras->ras_next_readahead_idx;
+		*start_idx = ras->ras_next_readahead_idx;
 
 	if (ras->ras_window_pages > 0)
 		end_idx = ras->ras_window_start_idx + ras->ras_window_pages - 1;
 
 	if (skip_index)
-		end_idx = start_idx + ras->ras_window_pages - 1;
+		end_idx = *start_idx + ras->ras_window_pages - 1;
 
 	/* Enlarge the RA window to encompass the full read */
 	if (vio->vui_ra_valid &&
@@ -787,7 +788,7 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 			ria->ria_eof = true;
 		}
 	}
-	ria->ria_start_idx = start_idx;
+	ria->ria_start_idx = *start_idx;
 	ria->ria_end_idx = end_idx;
 	/* If stride I/O mode is detected, get stride window*/
 	if (stride_io_mode(ras)) {
@@ -1627,6 +1628,7 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 	struct cl_2queue *queue = &io->ci_queue;
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct cl_sync_io *anchor = NULL;
+	pgoff_t ra_start_index = 0;
 	pgoff_t io_start_index;
 	pgoff_t io_end_index;
 	int rc = 0, rc2 = 0;
@@ -1674,9 +1676,12 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 		if (ras->ras_next_readahead_idx < vvp_index(vpg))
 			skip_index = vvp_index(vpg);
 		rc2 = ll_readahead(env, io, &queue->c2_qin, ras,
-				   uptodate, file, skip_index);
-		CDEBUG(D_READA|D_IOTRACE, DFID " %d pages read ahead at %lu\n",
-		       PFID(ll_inode2fid(inode)), rc2, vvp_index(vpg));
+				   uptodate, file, skip_index,
+				   &ra_start_index);
+		CDEBUG(D_READA|D_IOTRACE,
+		       DFID " %d pages read ahead at %lu, triggered by user read at %lu\n",
+		       PFID(ll_inode2fid(inode)), rc2, ra_start_index,
+		       vvp_index(vpg));
 	} else if (vvp_index(vpg) == io_start_index &&
 		   io_end_index - io_start_index > 0) {
 		rc2 = ll_readpages(env, io, &queue->c2_qin, io_start_index + 1,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
