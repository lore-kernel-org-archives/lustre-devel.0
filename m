From: James Simmons <jsimmons@infradead.org>
Date: Sat,  7 Jul 2018 20:14:16 -0400
Subject: [lustre-devel] [PATCH v4 02/14] lustre: libcfs: always range-check
 libcfs_debug_mb setting.
In-Reply-To: <1531008868-4194-1-git-send-email-jsimmons@infradead.org>
References: <1531008868-4194-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1531008868-4194-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

When the libcfs_debug_mb module parameter is set
at module-load time it isn't range-checked.  When
it is set via sysfs it is.  This inconsistency
makes the code harder to follow.

It is quite safe to call cfs_trace_set_debug_mb()
and cfs_trace_get_debug_mb() before the module
is initialized as cfs_tcd_for_each() does nothing
before initializtion.

So change cfs_trace_set_debug_mb() - which does
range checking - to returned the ranged checked number (it currently
always returns zero) and use that as the new value, unless
cfs_trace_get_debug_mb() now returns a non-zero value.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/libcfs/debug.c     | 16 +++++++---------
 drivers/staging/lustre/lnet/libcfs/tracefile.c |  2 +-
 2 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index 06f694f..50c2995 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -67,17 +67,15 @@ static int libcfs_param_debug_mb_set(const char *val,
 	if (rc < 0)
 		return rc;
 
-	if (!*((unsigned int *)kp->arg)) {
-		*((unsigned int *)kp->arg) = num;
-		return 0;
-	}
-
-	rc = cfs_trace_set_debug_mb(num);
+	num = cfs_trace_set_debug_mb(num);
 
-	if (!rc)
-		*((unsigned int *)kp->arg) = cfs_trace_get_debug_mb();
+	*((unsigned int *)kp->arg) = num;
+	num = cfs_trace_get_debug_mb();
+	if (num)
+		/* This value is more precise */
+		*((unsigned int *)kp->arg) = num;
 
-	return rc;
+	return 0;
 }
 
 /* While debug_mb setting look like unsigned int, in fact
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 5f31933..3b92fd7 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -958,7 +958,7 @@ int cfs_trace_set_debug_mb(int mb)
 
 	up_write(&cfs_tracefile_sem);
 
-	return 0;
+	return mb;
 }
 
 int cfs_trace_get_debug_mb(void)
-- 
1.8.3.1
