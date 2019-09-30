From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:49 -0400
Subject: [lustre-devel] [PATCH 090/151] lustre: sec: migrate to 64 bit time
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-91-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Replace cfs_time_current_sec() to avoid the overflow
issues in 2038 with ktime_get_real_seconds(). Mirgate
the rest of the gss code to time64_t to avoid the 2038
overflow issue.

Currently in encrypt_page_pools we are reporting the jiffy
cycles for "max wait time" which not only doesn't make
sense but can vary from platform to platform. Instead we
will report in terms of milliseconds. That requires changing
epp_st_max_wait into ktime_t since we need better than
seconds precision. Lastly the time in encrypt_page_pools for
"last access" and "last shrink" was showing up negative.
This was due to epp_last_* field being set to the number of
seconds since the epoch instead of the number of seconds
since the node booted. Change epp_last_* to being set by
ktime_get_seconds() instead of ktime_get_real_seconds()
resolves this problem.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9019
Lustre-commit: cc759278f18f (LU-9019 sec: migrate to 64 bit time")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/29859
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_sec.h |  2 +-
 fs/lustre/ptlrpc/sec_bulk.c    | 22 ++++++++++------------
 2 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/include/lustre_sec.h b/fs/lustre/include/lustre_sec.h
index 66054d5..dabc663 100644
--- a/fs/lustre/include/lustre_sec.h
+++ b/fs/lustre/include/lustre_sec.h
@@ -484,7 +484,7 @@ struct ptlrpc_cli_ctx {
 	atomic_t		cc_refcount;
 	struct ptlrpc_sec      *cc_sec;
 	struct ptlrpc_ctx_ops  *cc_ops;
-	unsigned long		cc_expire;	/* in seconds */
+	time64_t		cc_expire;	/* in seconds */
 	unsigned int		cc_early_expire:1;
 	unsigned long		cc_flags;
 	struct vfs_cred		cc_vcred;
diff --git a/fs/lustre/ptlrpc/sec_bulk.c b/fs/lustre/ptlrpc/sec_bulk.c
index 74cfdd8..755781c 100644
--- a/fs/lustre/ptlrpc/sec_bulk.c
+++ b/fs/lustre/ptlrpc/sec_bulk.c
@@ -108,7 +108,7 @@
 	unsigned long		epp_st_missings;	/* # of cache missing */
 	unsigned long		epp_st_lowfree;		/* lowest free pages reached */
 	unsigned int		epp_st_max_wqlen;	/* highest waitqueue length */
-	unsigned long		epp_st_max_wait;	/* in jiffies */
+	ktime_t			epp_st_max_wait;	/* in nanoseconds */
 	unsigned long		epp_st_outofmem;	/* # of out of mem requests */
 	/*
 	 * pointers to pools
@@ -131,8 +131,8 @@ int sptlrpc_proc_enc_pool_seq_show(struct seq_file *m, void *v)
 		   "total pages:	     %lu\n"
 		   "total free:	      %lu\n"
 		   "idle index:	      %lu/100\n"
-		   "last shrink:	     %lds\n"
-		   "last access:	     %lds\n"
+		   "last shrink:	     %llds\n"
+		   "last access:	     %llds\n"
 		   "max pages reached:       %lu\n"
 		   "grows:		   %u\n"
 		   "grows failure:	   %u\n"
@@ -141,7 +141,7 @@ int sptlrpc_proc_enc_pool_seq_show(struct seq_file *m, void *v)
 		   "cache missing:	   %lu\n"
 		   "low free mark:	   %lu\n"
 		   "max waitqueue depth:     %u\n"
-		   "max wait time:	   %ld/%lu\n"
+		   "max wait time ms:        %lld\n"
 		   "out of mem:		 %lu\n",
 		   totalram_pages(),
 		   PAGES_PER_POOL,
@@ -150,8 +150,8 @@ int sptlrpc_proc_enc_pool_seq_show(struct seq_file *m, void *v)
 		   page_pools.epp_total_pages,
 		   page_pools.epp_free_pages,
 		   page_pools.epp_idle_idx,
-		   (long)(ktime_get_seconds() - page_pools.epp_last_shrink),
-		   (long)(ktime_get_seconds() - page_pools.epp_last_access),
+		   ktime_get_seconds() - page_pools.epp_last_shrink,
+		   ktime_get_seconds() - page_pools.epp_last_access,
 		   page_pools.epp_st_max_pages,
 		   page_pools.epp_st_grows,
 		   page_pools.epp_st_grow_fails,
@@ -160,8 +160,7 @@ int sptlrpc_proc_enc_pool_seq_show(struct seq_file *m, void *v)
 		   page_pools.epp_st_missings,
 		   page_pools.epp_st_lowfree,
 		   page_pools.epp_st_max_wqlen,
-		   page_pools.epp_st_max_wait,
-		   msecs_to_jiffies(MSEC_PER_SEC),
+		   ktime_to_ms(page_pools.epp_st_max_wait),
 		   page_pools.epp_st_outofmem);
 
 	spin_unlock(&page_pools.epp_lock);
@@ -432,7 +431,7 @@ int sptlrpc_enc_pool_init(void)
 	page_pools.epp_st_missings = 0;
 	page_pools.epp_st_lowfree = 0;
 	page_pools.epp_st_max_wqlen = 0;
-	page_pools.epp_st_max_wait = 0;
+	page_pools.epp_st_max_wait = ktime_set(0, 0);
 	page_pools.epp_st_outofmem = 0;
 
 	enc_pools_alloc();
@@ -463,13 +462,12 @@ void sptlrpc_enc_pool_fini(void)
 
 	if (page_pools.epp_st_access > 0) {
 		CDEBUG(D_SEC,
-		       "max pages %lu, grows %u, grow fails %u, shrinks %u, access %lu, missing %lu, max qlen %u, max wait %ld/%ld, out of mem %lu\n",
+		       "max pages %lu, grows %u, grow fails %u, shrinks %u, access %lu, missing %lu, max qlen %u, max wait ms %lld, out of mem %lu\n",
 		       page_pools.epp_st_max_pages, page_pools.epp_st_grows,
 		       page_pools.epp_st_grow_fails,
 		       page_pools.epp_st_shrinks, page_pools.epp_st_access,
 		       page_pools.epp_st_missings, page_pools.epp_st_max_wqlen,
-		       page_pools.epp_st_max_wait,
-		       msecs_to_jiffies(MSEC_PER_SEC),
+		       ktime_to_ms(page_pools.epp_st_max_wait),
 		       page_pools.epp_st_outofmem);
 	}
 }
-- 
1.8.3.1
