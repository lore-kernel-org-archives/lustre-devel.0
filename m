From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Mon, 28 Sep 2015 00:38:37 +0000
Subject: [lustre-devel] [PATCH 04/73] staging/lustre: tracefile:
 document seconds overflow
In-Reply-To: <1443386773-305443-5-git-send-email-green@linuxhacker.ru>
References: <1443386773-305443-1-git-send-email-green@linuxhacker.ru>
	<1443386773-305443-5-git-send-email-green@linuxhacker.ru>
Message-ID: <D22E51DB.10D6D3%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2015/09/27, 10:45 PM, "green at linuxhacker.ru" <green@linuxhacker.ru>
wrote:

>From: Arnd Bergmann <arnd@arndb.de>
>
>The lustre tracefile has a timestamp defined as
>
>       __u32 ph_sec;
>       __u64 ph_usec;
>
>which seems completely backwards, as the microsecond portion of
>a time stamp will always fit into a __u32 value, while the second
>portion will overflow in 2038 or 2106 (in case of unsigned seconds).

This is indeed confusing, but the original reason for such a thing is
lost in the mists of antiquity.

>Changing this would unfortunately change the format in an incompatible
>way, breaking all existing user space tools that access the data.

It seems that it would be possible to fix this declaration to be
compatible with current usage, since these fields are always written
in host-endian order:


#ifdef(__LITTLE_ENDIAN)
	__u32 ph_sec;
	__u32 ph_usec;
        __u32 ph_sec_hi;
#else
	__u32 ph_sec;
        __u32 ph_sec_hi;
        __u32 ph_usec;
#endif

ph_sec_hi will always be zero today because microseconds don't grow
so large, and we have 22 years to ensure existing user tools are
updated to handle this in a similar manner.

Another option would be to mark in ph_flags whether the ph_sec field
is a __u32 or __u64 and that would allow us to migrate over to a
"normal" field ordering gradually (these debug logs are only useful
for a short time anyway).

It would probably also make sense to change to use ph_nsec at this point
as well, since that avoids the division (which might be noticeable in
itself) and gives us better time resolution.

Cheers, Andreas

>This uses ktime_get_real_ts64() to replace the insufficient
>do_gettimeofday() and then truncates the seconds portion to
>an u32 type, along with comments to explain the result.
>
>A possible alternative would be the use of ktime_get_ts64() to
>read a monotonic timestamp that never overflows, but this would
>trigger a check in user space 'hdr->ph_sec < (1 << 30)' that
>attempts to ensure that the values are within a reasonable range.
>
>Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
>---
> drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h   |  1 +
> drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c | 10
>++++++----
> 2 files changed, 7 insertions(+), 4 deletions(-)
>
>diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
>b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
>index a3aa644..a1787bb 100644
>--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
>+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
>@@ -73,6 +73,7 @@ struct ptldebug_header {
> 	__u32 ph_mask;
> 	__u16 ph_cpu_id;
> 	__u16 ph_type;
>+	/* time_t overflow in 2106 */
> 	__u32 ph_sec;
> 	__u64 ph_usec;
> 	__u32 ph_stack;
>diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
>b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
>index 87d8449..64a136c 100644
>--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
>+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
>@@ -191,16 +191,18 @@ cfs_set_ptldebug_header(struct ptldebug_header
>*header,
> 			struct libcfs_debug_msg_data *msgdata,
> 			unsigned long stack)
> {
>-	struct timeval tv;
>+	struct timespec64 ts;
> 
>-	do_gettimeofday(&tv);
>+	ktime_get_real_ts64(&ts);
> 
> 	header->ph_subsys = msgdata->msg_subsys;
> 	header->ph_mask = msgdata->msg_mask;
> 	header->ph_cpu_id = smp_processor_id();
> 	header->ph_type = cfs_trace_buf_idx_get();
>-	header->ph_sec = (__u32)tv.tv_sec;
>-	header->ph_usec = tv.tv_usec;
>+	/* y2038 safe since all user space treats this as unsigned, but
>+	 * will overflow in 2106 */
>+	header->ph_sec = (u32)ts.tv_sec;
>+	header->ph_usec = ts.tv_nsec / NSEC_PER_USEC;
> 	header->ph_stack = stack;
> 	header->ph_pid = current->pid;
> 	header->ph_line_num = msgdata->msg_line;
>-- 
>2.1.0
>
>


Cheers, Andreas
-- 
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division
