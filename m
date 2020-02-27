From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:38 -0500
Subject: [lustre-devel] [PATCH 290/622] lustre: ptlrpc: Fix style issues for
 sec_gc.c
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-291-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Arshad Hussain <arshad.super@gmail.com>

This patch fixes issues reported by checkpatch for
file fs/lustre/ptlrpc/sec_gc.c

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 930d88e71d16 ("LU-6142 ptlrpc: Fix style issues for sec_gc.c")
Signed-off-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-on: https://review.whamcloud.com/34551
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/sec_gc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/ptlrpc/sec_gc.c b/fs/lustre/ptlrpc/sec_gc.c
index 3baed8c..36ac319 100644
--- a/fs/lustre/ptlrpc/sec_gc.c
+++ b/fs/lustre/ptlrpc/sec_gc.c
@@ -147,7 +147,8 @@ static void sec_gc_main(struct work_struct *ws)
 
 	sec_process_ctx_list();
 again:
-	/* go through sec list do gc.
+	/*
+	 * go through sec list do gc.
 	 * FIXME here we iterate through the whole list each time which
 	 * is not optimal. we perhaps want to use balanced binary tree
 	 * to trace each sec as order of expiry time.
@@ -156,7 +157,8 @@ static void sec_gc_main(struct work_struct *ws)
 	 */
 	mutex_lock(&sec_gc_mutex);
 	list_for_each_entry(sec, &sec_gc_list, ps_gc_list) {
-		/* if someone is waiting to be deleted, let it
+		/*
+		 * if someone is waiting to be deleted, let it
 		 * proceed as soon as possible.
 		 */
 		if (atomic_read(&sec_gc_wait_del)) {
-- 
1.8.3.1
