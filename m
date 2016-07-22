From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:11 -0400
Subject: [lustre-devel] [PATCH 18/58] staging: lustre: llite: do post work
	for statahead in readdir case
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Increase the post-work for the statahead thread in the readdir
case since it can become very busy.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/10761
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4906
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/llite/llite_internal.h   |    3 ++-
 drivers/staging/lustre/lustre/llite/statahead.c    |    7 +++++++
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index e650aeb..dc15957 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -997,7 +997,8 @@ struct ll_statahead_info {
 	unsigned int	    sai_ls_all:1,   /* "ls -al", do stat-ahead for
 					     * hidden entries
 					     */
-				sai_agl_valid:1;/* AGL is valid for the dir */
+				sai_agl_valid:1,/* AGL is valid for the dir */
+				sai_in_readpage:1;/* statahead is in readdir() */
 	wait_queue_head_t	sai_waitq;      /* stat-ahead wait queue */
 	struct ptlrpc_thread    sai_thread;     /* stat-ahead thread */
 	struct ptlrpc_thread    sai_agl_thread; /* AGL thread */
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index e4ca525..b5bd107 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -1229,7 +1229,9 @@ do_it:
 			 */
 			ll_release_page(page, le32_to_cpu(dp->ldp_flags) &
 					      LDF_COLLIDE);
+			sai->sai_in_readpage = 1;
 			page = ll_get_dir_page(dir, pos, &chain);
+			sai->sai_in_readpage = 0;
 		}
 	}
 
@@ -1548,6 +1550,11 @@ int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
 			return entry ? 1 : -EAGAIN;
 		}
 
+		/* if statahead is busy in readdir, help it do post-work */
+		while (!ll_sa_entry_stated(entry) && sai->sai_in_readpage &&
+		       !sa_received_empty(sai))
+			ll_post_statahead(sai);
+
 		if (!ll_sa_entry_stated(entry)) {
 			sai->sai_index_wait = entry->se_index;
 			lwi = LWI_TIMEOUT_INTR(cfs_time_seconds(30), NULL,
-- 
1.7.1
