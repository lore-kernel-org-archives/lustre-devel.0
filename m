From: NeilBrown <neilb@suse.com>
Date: Mon, 02 Jul 2018 12:17:48 +1000
Subject: [lustre-devel] [PATCH v3 02/13] lustre: libcfs: open code
 cfs_trace_max_debug_mb() into cfs_trace_set_debug_mb()
In-Reply-To: <8760225jr0.fsf@notabene.neil.brown.name>
References: <1530128322-32535-1-git-send-email-jsimmons@infradead.org>
 <1530128322-32535-3-git-send-email-jsimmons@infradead.org>
 <D3940542-5913-4E4D-8FEB-E3B27CB7AD04@whamcloud.com>
 <8760225jr0.fsf@notabene.neil.brown.name>
Message-ID: <87k1qe2xf7.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Jun 29 2018, NeilBrown wrote:
>> It may be that there is a mechanism to limit the value set by module option
>> in newer kernels, but that wasn't the case in the past.
>
> There is such a mechanism now.
> When the libcfs_debug_mb module parameter is detected,
> libcfs_param_debug_mb_set() is called to parse it.
> This function uses kstrtouint() to convert the string
> to unsigned int, and then...... oh, that's odd.
> If the current value of libcfs_debug_mb is zero, then
> then the number is used without further checking.  I hadn't noticed
> that.
> If that current value is non-zero, then the parsed number
> is passed to cfs_trace_set_debug_mb().  I had assumed that
> always happens, and that function imposes the required limit.
>
> I'll fix that up - make sure it always imposes the
> appropriate limit.

I've inserted the following patch before this one.
That makes it correct :-)

Thanks,
NeilBrown

From: NeilBrown <neilb@suse.com>
Date: Mon, 2 Jul 2018 12:14:15 +1000
Subject: [PATCH] lustre: always range-check libcfs_debug_mb setting.

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
index 06f694f6a28f..50c2995c1c99 100644
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
index 5f319332f60b..3b92fd7d3182 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -958,7 +958,7 @@ int cfs_trace_set_debug_mb(int mb)
 
 	up_write(&cfs_tracefile_sem);
 
-	return 0;
+	return mb;
 }
 
 int cfs_trace_get_debug_mb(void)
-- 
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180702/dc2265db/attachment.sig>
