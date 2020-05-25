From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:58 -0400
Subject: [lustre-devel] [PATCH 21/45] lustre: llite: fix to make jobstats
 work for async ra
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

We use workqueue to triger async readahead, this will make
the problem that read jobstats are not accounted by real
IO, we could fix this by overwritting jobid which inited in
vvp_io_init().

WC-bug-id: https://jira.whamcloud.com/browse/LU-13490
Lustre-commit: da8972322134a ("LU-13490 lustre: fix to make jobstats work for async ra")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/38426
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Ben Evans <beevans@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h | 1 +
 fs/lustre/llite/rw.c             | 8 ++++++++
 2 files changed, 9 insertions(+)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index c3f60bb..76715818 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -780,6 +780,7 @@ struct ll_readahead_work {
 
 	/* async worker to handler read */
 	struct work_struct		 lrw_readahead_work;
+	char				 lrw_jobid[LUSTRE_JOBID_SIZE];
 };
 
 extern struct kmem_cache *ll_file_data_slab;
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 7018c7c..9e004f4 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -629,6 +629,12 @@ static void ll_readahead_handle_work(struct work_struct *wq)
 	if (rc)
 		goto out_put_env;
 
+	/* overwrite jobid inited in vvp_io_init() */
+	if (strncmp(ll_i2info(inode)->lli_jobid, work->lrw_jobid,
+		    sizeof(work->lrw_jobid)))
+		memcpy(ll_i2info(inode)->lli_jobid, work->lrw_jobid,
+		       sizeof(work->lrw_jobid));
+
 	vvp_env_io(env)->vui_fd = fd;
 	io->ci_state = CIS_LOCKED;
 	io->ci_async_readahead = true;
@@ -1582,6 +1588,8 @@ static int kickoff_async_readahead(struct file *file, unsigned long pages)
 		ras->ras_next_readahead_idx = end_idx + 1;
 		ras->ras_async_last_readpage_idx = start_idx;
 		spin_unlock(&ras->ras_lock);
+		memcpy(lrw->lrw_jobid, ll_i2info(inode)->lli_jobid,
+		       sizeof(lrw->lrw_jobid));
 		ll_readahead_work_add(inode, lrw);
 	} else {
 		return -ENOMEM;
-- 
1.8.3.1
