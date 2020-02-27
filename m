From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:46 -0500
Subject: [lustre-devel] [PATCH 238/622] lnet: libcfs: do not calculate
 debug_mb if it is set
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-239-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vladimir Saveliev <c17830@cray.com>

debug_mb is libcfs module parameter. It should be possible to set it
via

modprobe libcfs libcfs_debug_mb=800

or via adding

options libcfs libcfs_debug_mb=800

to modules configuration.

Fixes: 0871d551af ("staging/lustre/libcfs: move /proc/sys/lnet to debugfs")
WC-bug-id: https://jira.whamcloud.com/browse/LU-11898
Lustre-commit: adeb29400a4a ("LU-11898 libcfs: do not calculate debug_mb if it is set")
Signed-off-by: Vladimir Saveliev <c17830@cray.com>
Cray-bug-id: LUS-6936
Reviewed-on: https://review.whamcloud.com/34128
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexander Zarochentsev <c17826@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/debug.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/lnet/libcfs/debug.c b/net/lnet/libcfs/debug.c
index 88c4c36..c6b92df 100644
--- a/net/lnet/libcfs/debug.c
+++ b/net/lnet/libcfs/debug.c
@@ -553,7 +553,8 @@ int libcfs_debug_init(unsigned long bufsize)
 
 	libcfs_register_panic_notifier();
 	kernel_param_lock(THIS_MODULE);
-	libcfs_debug_mb = cfs_trace_get_debug_mb();
+	if (libcfs_debug_mb == 0)
+		libcfs_debug_mb = cfs_trace_get_debug_mb();
 	kernel_param_unlock(THIS_MODULE);
 	return rc;
 }
-- 
1.8.3.1
