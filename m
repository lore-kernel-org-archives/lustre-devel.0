From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:55 -0400
Subject: [lustre-devel] [PATCH 18/45] lnet: libcfs: use BIT() macro where
 appropriate
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

When accessing a bit in a bitmap/mask/flags-word it can be more
readable to use BIT(num) rather than "1 << num".

This patch makes that change to various places in libcfs.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 5bb99e46bc904 ("LU-6142 libcfs: use BIT() macro where appropriate")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/38374
Reviewed-by: Olaf Faaland-LLNL <faaland1@llnl.gov>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/debug.c         | 2 +-
 net/lnet/libcfs/libcfs_string.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/lnet/libcfs/debug.c b/net/lnet/libcfs/debug.c
index c0ec184..41a0a5e 100644
--- a/net/lnet/libcfs/debug.c
+++ b/net/lnet/libcfs/debug.c
@@ -273,7 +273,7 @@ static const char *libcfs_debug_dbg2str(int debug)
 		len = 1;
 	} else {				/* space-separated tokens */
 		for (i = 0; i < 32; i++) {
-			if (!(mask & (1 << i)))
+			if ((mask & BIT(i)) == 0)
 				continue;
 
 			token = fn(i);
diff --git a/net/lnet/libcfs/libcfs_string.c b/net/lnet/libcfs/libcfs_string.c
index cefe6fee..b042de5 100644
--- a/net/lnet/libcfs/libcfs_string.c
+++ b/net/lnet/libcfs/libcfs_string.c
@@ -88,9 +88,9 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 			if (debugstr && strlen(debugstr) == len &&
 			    !strncasecmp(str, debugstr, len)) {
 				if (op == '-')
-					newmask &= ~(1 << i);
+					newmask &= ~BIT(i);
 				else
-					newmask |= (1 << i);
+					newmask |= BIT(i);
 				found = 1;
 				break;
 			}
-- 
1.8.3.1
