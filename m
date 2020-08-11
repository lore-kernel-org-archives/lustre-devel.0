From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:20:01 -0400
Subject: [lustre-devel] [PATCH 05/23] lustre: llite: Remove mutex on dio read
In-Reply-To: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
References: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1597148419-20629-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <farr0186@gmail.com>

DIO reads in Lustre are protected by Lustre range locking
and do not need the inode mutex.  This code was removed
in LU-1669, the range lock was added for DIO reads in
LU-6227, and then the mutex was accidentally re-introduced
in LU-6260.

Remove it again.

Fixes: fde7ac1942f5 ("lustre: llite: add support for direct IO api changes")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13196
Lustre-commit: 5bc1fe092cba0 ("LU-13196 llite: Remove mutex on dio read")
Signed-off-by: Patrick Farrell <farr0186@gmail.com>
Reviewed-on: https://review.whamcloud.com/37419
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw26.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index b3802cf..7010fe8 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -328,13 +328,6 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	LASSERT(aio);
 	LASSERT(aio->cda_iocb == iocb);
 
-	/* 0. Need locking between buffered and direct access. and race with
-	 *    size changing by concurrent truncates and writes.
-	 * 1. Need inode mutex to operate transient pages.
-	 */
-	if (rw == READ)
-		inode_lock(inode);
-
 	while (iov_iter_count(iter)) {
 		struct ll_dio_pages pvec = { .ldp_aio = aio };
 		struct page **pages;
@@ -406,9 +399,6 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 		result = -EIOCBQUEUED;
 	}
 
-	if (rw == READ)
-		inode_unlock(inode);
-
 	return result;
 }
 
-- 
1.8.3.1
