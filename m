From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:25 -0500
Subject: [lustre-devel] [PATCH 097/622] lustre: ptlrpc: replace
 simple_strtol with kstrtol
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-98-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eventually simple_strtol() will be removed so replace its use in
the ptlrpc with kstrtoXXX() class of functions.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9325
Lustre-commit: 8f37d64b6bc9 ("LU-9325 ptlrpc: replace simple_strtol with kstrtol")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/32785
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Nikitas Angelinas <nikitas.angelinas@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/lproc_ptlrpc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index 6af3384..eb0ecc0 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -1303,13 +1303,13 @@ int lprocfs_wr_import(struct file *file, const char __user *buffer,
 	ptr = strstr(uuid, "::");
 	if (ptr) {
 		u32 inst;
-		char *endptr;
+		int rc;
 
 		*ptr = 0;
 		do_reconn = 0;
 		ptr += strlen("::");
-		inst = simple_strtoul(ptr, &endptr, 10);
-		if (*endptr) {
+		rc = kstrtouint(ptr, 10, &inst);
+		if (rc) {
 			CERROR("config: wrong instance # %s\n", ptr);
 		} else if (inst != imp->imp_connect_data.ocd_instance) {
 			CDEBUG(D_INFO,
-- 
1.8.3.1
