From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 28 Sep 2015 10:19:02 +0200
Subject: [lustre-devel] [PATCH 30/73] staging/lustre: use 64-bit times
	for request times
In-Reply-To: <D22E5B67.10D71A%andreas.dilger@intel.com>
References: <1443386773-305443-1-git-send-email-green@linuxhacker.ru>
	<1443386773-305443-31-git-send-email-green@linuxhacker.ru>
	<D22E5B67.10D71A%andreas.dilger@intel.com>
Message-ID: <1670598.hVGksRcUem@wuerfel>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Monday 28 September 2015 01:09:18 Dilger, Andreas wrote:
> On 2015/09/27, 10:45 PM, "green at linuxhacker.ru" <green@linuxhacker.ru>
> wrote:
> >diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c
> >b/drivers/staging/lustre/lustre/ptlrpc/events.c
> >index 53f6b62..afd869b 100644
> >--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
> >+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
> >@@ -246,7 +246,7 @@ static void ptlrpc_req_add_history(struct
> >ptlrpc_service_part *svcpt,
> > 				   struct ptlrpc_request *req)
> > {
> > 	__u64 sec = req->rq_arrival_time.tv_sec;
> >-	__u32 usec = req->rq_arrival_time.tv_usec >> 4; /* usec / 16 */
> >+	__u32 usec = req->rq_arrival_time.tv_nsec / NSEC_PER_USEC / 16; /* usec
> >/ 16 */
> 
> This could just be written like:
> 
> 	__u32 usec = req->rq_arrival_time.tv_nsec >> 14 /* nsec / 16384 */;
> 
> since the main point of this calculation is to get a number that fits
> into a 16-bit field to provide ordering for items in a trace log.  It
> doesn't have to be exactly "nsec / 16000", and it avoids the division.

Ok, that wasn't clear from the original code, so I just moved the division
from the do_gettimeofday() here to keep the data unchanged.

With your change, the 

new_seq = (sec << REQS_SEC_SHIFT) |
                  (usec << REQS_USEC_SHIFT) |
                  (svcpt->scp_cpt < 0 ? 0 : svcpt->scp_cpt);

calculation will get forward jumps once a second, but I guess that
doesn't matter if it's only used for sequencing.

The part that I had not noticed here is the y2106 overflow in the
sequence number. If we change the logic, we should probably give
a few more bits to the seconds, as well, or use monotonic time.

> >diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c
> >b/drivers/staging/lustre/lustre/ptlrpc/service.c
> >index 40de622..28f57d7 100644
> >--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
> >+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
> >@@ -1191,7 +1191,7 @@ static int ptlrpc_at_add_timed(struct
> >ptlrpc_request *req)
> > 	spin_lock(&svcpt->scp_at_lock);
> > 	LASSERT(list_empty(&req->rq_timed_list));
> > 
> >-	index = (unsigned long)req->rq_deadline % array->paa_size;
> >+	div_u64_rem(req->rq_deadline, array->paa_size, &index);
> 
> Since this is just a round-robin index that advances once per second,
> it doesn't matter at all whether the calculation is computed on the
> 64-bit seconds or on the 32-bit seconds, so there isn't any need for
> the more expensive div_u64_rem() call here at all.  It is fine to
> just truncate the seconds and then do the modulus on the 32-bit value.
> 
> >@@ -1421,7 +1421,7 @@ static int ptlrpc_at_check_timed(struct
> >ptlrpc_service_part *svcpt)
> > 	   server will take. Send early replies to everyone expiring soon. */
> > 	INIT_LIST_HEAD(&work_list);
> > 	deadline = -1;
> >-	index = (unsigned long)array->paa_deadline % array->paa_size;
> >+	div_u64_rem(array->paa_deadline, array->paa_size, &index);
> 
> Same here.

I went back and forth on these. Initially I did just what you suggest
here and added a (u32) cast on the deadline fields, but I could not
convince myself that the backwards jump in 2038 is harmless. For all
I can tell,  array->paa_size is not normally a power-of-two number, so
(0xffffffff % array->paa_size) and (0 % array->paa_size) are not
neighboring indices. If you are sure that the index can be allowed to
jump in 2038, we should do the simpler math and add a comment.

	Arnd
