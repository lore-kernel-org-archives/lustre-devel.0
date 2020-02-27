From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:48 -0500
Subject: [lustre-devel] [PATCH 120/622] lnet: libcfs: fix wrong check in
 libcfs_debug_vmsg2()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-121-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

Logic here is we skip output if time is before @cdls_next
reach and increase @cdls_count. however we did it in the
opposite way:

1)libcfs_debug_vmsg2() is called for a long time, that means
current check succeed, we skip print messages and return, we
will skip all messages later too..

2)libcfs_debug_vmsg2() is called frequently, current check
fail every time, message will be bumped out always. the
worst case is we never skip any messages.

Also fix test case to cover this later which is from Andreas:

The test_60a() llog test is being run on the MGS, while the
check in test_60b() to confirm that CDEBUG_LIMIT() works properly
is being run on the client.  There has been a breakage in
CDEBUG_LIMIT() that this test failed to catch, now we need to
track it down.

Change test_60b to dump the dmesg logs on the MGS.

Fixes: b49946b2e ("staging: lustre: libcfs: discard cfs_time_after()")
WC-bug-id: https://jira.whamcloud.com/browse/LU-11373
Lustre-commit: 4037c1462730 ("LU-11373 libcfs: fix wrong check in libcfs_debug_vmsg2()")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/33154
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/tracefile.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/lnet/libcfs/tracefile.c b/net/lnet/libcfs/tracefile.c
index 6e4cc31..bda3523 100644
--- a/net/lnet/libcfs/tracefile.c
+++ b/net/lnet/libcfs/tracefile.c
@@ -544,7 +544,7 @@ int libcfs_debug_msg(struct libcfs_debug_msg_data *msgdata,
 	if (cdls) {
 		if (libcfs_console_ratelimit &&
 		    cdls->cdls_next &&		/* not first time ever */
-		    !time_after(jiffies, cdls->cdls_next)) {
+		    time_before(jiffies, cdls->cdls_next)) {
 			/* skipping a console message */
 			cdls->cdls_count++;
 			if (tcd)
-- 
1.8.3.1
