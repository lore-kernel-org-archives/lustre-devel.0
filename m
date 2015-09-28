From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Mon, 28 Sep 2015 01:09:18 +0000
Subject: [lustre-devel] [PATCH 30/73] staging/lustre: use 64-bit times
	for request times
In-Reply-To: <1443386773-305443-31-git-send-email-green@linuxhacker.ru>
References: <1443386773-305443-1-git-send-email-green@linuxhacker.ru>
	<1443386773-305443-31-git-send-email-green@linuxhacker.ru>
Message-ID: <D22E5B67.10D71A%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2015/09/27, 10:45 PM, "green at linuxhacker.ru" <green@linuxhacker.ru>
wrote:

>From: Arnd Bergmann <arnd@arndb.de>
>
>All request timestamps and deadlines in lustre are recorded in time_t
>and timeval units, which overflow in 2038 on 32-bit systems.
>
>In this patch, I'm converting them to time64_t and timespec64,
>respectively. Unfortunately, this makes a relatively large patch,
>but I could not find an obvious way to split it up some more without
>breaking atomicity of the change.
>
>Also unfortunately, this introduces two instances of div_u64_rem()
>in the request path, which can be slow on 32-bit architectures. This
>can probably be avoided by a larger restructuring of the code, but
>it is unlikely that lustre is used in performance critical setups
>on 32-bit architectures, so it seems better to optimize for correctness
>rather than speed here.
>
>Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
>---
> .../staging/lustre/lustre/include/lustre_import.h  |   2 +-
> drivers/staging/lustre/lustre/include/lustre_net.h |  22 ++--
> drivers/staging/lustre/lustre/mdc/mdc_locks.c      |   2 +-
> drivers/staging/lustre/lustre/mdc/mdc_reint.c      |   2 +-
> drivers/staging/lustre/lustre/osc/osc_request.c    |   4 +-
> drivers/staging/lustre/lustre/ptlrpc/client.c      |  48 ++++-----
> drivers/staging/lustre/lustre/ptlrpc/events.c      |   6 +-
> drivers/staging/lustre/lustre/ptlrpc/import.c      |   4 +-
> .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |   8 +-
> drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |  10 +-
> .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   6 +-
> drivers/staging/lustre/lustre/ptlrpc/service.c     | 115
>+++++++++++----------
> 12 files changed, 118 insertions(+), 111 deletions(-)

[snip]

>diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c
>b/drivers/staging/lustre/lustre/ptlrpc/events.c
>index 53f6b62..afd869b 100644
>--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
>+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
>@@ -246,7 +246,7 @@ static void ptlrpc_req_add_history(struct
>ptlrpc_service_part *svcpt,
> 				   struct ptlrpc_request *req)
> {
> 	__u64 sec = req->rq_arrival_time.tv_sec;
>-	__u32 usec = req->rq_arrival_time.tv_usec >> 4; /* usec / 16 */
>+	__u32 usec = req->rq_arrival_time.tv_nsec / NSEC_PER_USEC / 16; /* usec
>/ 16 */

This could just be written like:

	__u32 usec = req->rq_arrival_time.tv_nsec >> 14 /* nsec / 16384 */;

since the main point of this calculation is to get a number that fits
into a 16-bit field to provide ordering for items in a trace log.  It
doesn't have to be exactly "nsec / 16000", and it avoids the division.


>diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c
>b/drivers/staging/lustre/lustre/ptlrpc/service.c
>index 40de622..28f57d7 100644
>--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
>+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
>@@ -1191,7 +1191,7 @@ static int ptlrpc_at_add_timed(struct
>ptlrpc_request *req)
> 	spin_lock(&svcpt->scp_at_lock);
> 	LASSERT(list_empty(&req->rq_timed_list));
> 
>-	index = (unsigned long)req->rq_deadline % array->paa_size;
>+	div_u64_rem(req->rq_deadline, array->paa_size, &index);

Since this is just a round-robin index that advances once per second,
it doesn't matter at all whether the calculation is computed on the
64-bit seconds or on the 32-bit seconds, so there isn't any need for
the more expensive div_u64_rem() call here at all.  It is fine to
just truncate the seconds and then do the modulus on the 32-bit value.

>@@ -1421,7 +1421,7 @@ static int ptlrpc_at_check_timed(struct
>ptlrpc_service_part *svcpt)
> 	   server will take. Send early replies to everyone expiring soon. */
> 	INIT_LIST_HEAD(&work_list);
> 	deadline = -1;
>-	index = (unsigned long)array->paa_deadline % array->paa_size;
>+	div_u64_rem(array->paa_deadline, array->paa_size, &index);

Same here.

Cheers, Andreas
-- 
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division
