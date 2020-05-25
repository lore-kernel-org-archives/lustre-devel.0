From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:46 -0400
Subject: [lustre-devel] [PATCH 09/45] lustre: ptlrpc: return proper write
 count from ping_store
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@whamcloud.com>

If we return 0 as a measure of success, that is actually taken
by userspace as "we wrote 0 bytes, but there's no error, so
they want us to retry". So tell them we ate all their data
instead to make them happy.

Interesting that when you do shell-redirect it enters the
retry loop, but badarea_io does not.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13470
Lustre-commit: 16d62976d212d ("LU-13470 ptlrpc: return proper write count from ping_store")
Signed-off-by: Oleg Drokin <green@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38304
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/lproc_ptlrpc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index 5125ecd..86ec1f5 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -1271,7 +1271,9 @@ ssize_t ping_show(struct kobject *kobj, struct attribute *attr,
 ssize_t ping_store(struct kobject *kobj, struct attribute *attr,
 		   const char *buffer, size_t count)
 {
-	return ping_show(kobj, attr, (char *)buffer);
+	int rc = ping_show(kobj, attr, (char *)buffer);
+
+	return (rc < 0) ? rc : count;
 }
 EXPORT_SYMBOL(ping_store);
 
-- 
1.8.3.1
