Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E3EB8C05027
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:17:12 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15Lm32XTz21JG;
	Mon, 23 Jan 2023 15:06:08 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15Jp6fz0z1xJL
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:04:26 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 4BA266DF;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 4847858987; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:26 -0500
Message-Id: <1674514855-15399-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/42] lustre: llite: update statx size/ctime
 for fallocate
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

In the VFS interface ->fallocate(), it should update i_size and
i_ctime returned by statx() accordingly when the file size grows.

fallocate() call does not update the attributes on MDT.
We use STATX with cached-always mode to verify it as it will not
send Glimpse lock RPCs to OSTs to obtain file size information
and use the caching attributes (size) on the client side as much
as possible.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16334
Lustre-commit: 51851705e936b2dbc ("LU-16334 llite: update statx size/ctime for fallocate")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49221
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/vvp_io.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index be6f17f5f072..317704172080 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -754,15 +754,25 @@ static void vvp_io_setattr_end(const struct lu_env *env,
 	struct cl_io *io = ios->cis_io;
 	struct inode *inode = vvp_object_inode(io->ci_obj);
 	struct ll_inode_info *lli = ll_i2info(inode);
+	loff_t size = io->u.ci_setattr.sa_attr.lvb_size;
 
 	if (cl_io_is_trunc(io)) {
 		/* Truncate in memory pages - they must be clean pages
 		 * because osc has already notified to destroy osc_extents.
 		 */
-		vvp_do_vmtruncate(inode, io->u.ci_setattr.sa_attr.lvb_size);
+		vvp_do_vmtruncate(inode, size);
 		mutex_unlock(&lli->lli_setattr_mutex);
 		trunc_sem_up_write(&lli->lli_trunc_sem);
 	} else if (cl_io_is_fallocate(io)) {
+		int mode = io->u.ci_setattr.sa_falloc_mode;
+
+		if (!(mode & FALLOC_FL_KEEP_SIZE) &&
+		    size > i_size_read(inode)) {
+			ll_inode_size_lock(inode);
+			i_size_write(inode, size);
+			ll_inode_size_unlock(inode);
+		}
+		inode->i_ctime = current_time(inode);
 		mutex_unlock(&lli->lli_setattr_mutex);
 		trunc_sem_up_write(&lli->lli_trunc_sem);
 	} else {
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
