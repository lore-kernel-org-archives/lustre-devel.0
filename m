From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 21:00:01 -0400
Subject: [lustre-devel] [PATCH 22/22] lnet: procs: print new line based on
 distro
In-Reply-To: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
References: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1591146001-27171-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Yang Sheng <ys@whamcloud.com>

Since upstream changed to print new line in module
parameter callback instead of kernel self. So we
need test output of param_get_byte to determine
whether output the new line.
(upstream: v4.14-rc3-148-g96802e6b1dbf)
Also output filename and file content when test
failed for santy 133h.

Lustre-commit: 0130d70195346 ("LU-10401 procs: print new line based on distro")
Signed-off-by: Yang Sheng <ys@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38699
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/debug.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/lnet/libcfs/debug.c b/net/lnet/libcfs/debug.c
index 41a0a5e..dd03520 100644
--- a/net/lnet/libcfs/debug.c
+++ b/net/lnet/libcfs/debug.c
@@ -129,7 +129,9 @@ static int param_get_delay(char *buffer, const struct kernel_param *kp)
 {
 	unsigned int d = *(unsigned int *)kp->arg;
 
-	return sprintf(buffer, "%lu", jiffies_to_msecs(d * 10) / MSEC_PER_SEC);
+	param_get_byte(buffer, kp);
+	return sprintf(buffer, "%lu%c", jiffies_to_msecs(d * 10) / MSEC_PER_SEC,
+		       strnchr(buffer, PAGE_SIZE, '\n') ? '\n' : '\0');
 }
 
 unsigned int libcfs_console_max_delay;
-- 
1.8.3.1
