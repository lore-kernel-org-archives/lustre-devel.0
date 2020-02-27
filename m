From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:32 -0500
Subject: [lustre-devel] [PATCH 284/622] lnet: libcfs: poll fail_loc in
 cfs_fail_timeout_set()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-285-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

Some internal test usually take 800-900s which is almost
half of the whole sanityn test suite run time. 99.(9)% of
the time the tests just wait to ensure specific order the
operations execute in.

the patch changes cfs_fail_timeout_set() so that it can
interrupt waiting if fail_loc is set to 0 - polling with
1/10s frequency is used.

the tests itself are modified to reset fail_loc. to be
able to do so both operations (referenced as OP1 and OP2
in the tests) are run in background. once started and then
ensured with pdo_sched() helper that MDS threads got to the
blocking points, we can interrupt OP1 and do usual checks.

ONLY=40-47 sh sanityn.sh take: 1017s before and 78s after.

WC-bug-id: https://jira.whamcloud.com/browse/LU-2233
Lustre-commit: 743b85a32e24 ("LU-2233 tests: improve tests sanityn/40-47")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/4392
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/fail.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/lnet/libcfs/fail.c b/net/lnet/libcfs/fail.c
index 6ee4de2..40e93b00 100644
--- a/net/lnet/libcfs/fail.c
+++ b/net/lnet/libcfs/fail.c
@@ -131,14 +131,21 @@ int __cfs_fail_check_set(u32 id, u32 value, int set)
 
 int __cfs_fail_timeout_set(u32 id, u32 value, int ms, int set)
 {
+	ktime_t till = ktime_add_ms(ktime_get(), ms);
 	int ret;
 
 	ret = __cfs_fail_check_set(id, value, set);
 	if (ret && likely(ms > 0)) {
-		CERROR("cfs_fail_timeout id %x sleeping for %dms\n",
-		       id, ms);
-		schedule_timeout_uninterruptible(ms * HZ / 1000);
-		CERROR("cfs_fail_timeout id %x awake\n", id);
+		CERROR("cfs_fail_timeout id %x sleeping for %dms\n", id, ms);
+		while (ktime_before(ktime_get(), till)) {
+			schedule_timeout_uninterruptible(HZ / 10);
+			if (!cfs_fail_loc) {
+				CERROR("cfs_fail_timeout interrupted\n");
+				break;
+			}
+		}
+		if (cfs_fail_loc)
+			CERROR("cfs_fail_timeout id %x awake\n", id);
 	}
 	return ret;
 }
-- 
1.8.3.1
