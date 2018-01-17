From: James Simmons <jsimmons@infradead.org>
Date: Wed, 17 Jan 2018 15:24:29 +0000 (GMT)
Subject: [lustre-devel] [PATCH 5 v2: 00/19] staging: lustre: use
 standard wait_event macros
In-Reply-To: <151538168618.23920.8261096424342988792.stgit@noble>
References: <151538168618.23920.8261096424342988792.stgit@noble>
Message-ID: <alpine.LFD.2.21.1801171518230.11282@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>


> Hi,
>  this is a revised version of the patch series I sent under a similar
>  subject in mid December.
>  Improvements are:
>    - new wait_event_idle* macros are now in include/linux/wait.h which
>      Ack from peterz.
>    - *all* waits are now TASK_IDLE or TASK_INTERRUPTIBLE and so don't
>      affect the load average.  There is no need to choose whether load
>      is appropriate or not in each case.
>    - all l_wait_event() users are handled so l_wait_event() is
>      removed.  The one case I had left out before uses
>      wait_event_idle_exclusive() with and option of using
>      wait_event_idle_exclusive_lifo() is that ever gets approved.
> 
>  I think this set is ready to go.
>  If you only review two patches, please review
> 
>     staging: lustre: simplify waiting in ldlm_completion_ast()
> and
>     staging: lustre: remove back_to_sleep()
> 
>  as in both of those, the actual behaviour of the current code (as I
>  understand it) doesn't seem to agree with comments/debug message, or
>  just generally looks odd.

I have been doing extenstive test with this patch set on my local test
cluster and its looking good. So the reason for the original code is
in times past under very heavy IO load the cpu loads would spike due to
the work queues. I don't have a large enough test cluster to exercise
that case. I trust it works even in those conditions and it can be fixed
if its not the case. Thanks Neil for this work. 

> Thanks,
> NeilBrown
> 
> 
> ---
> 
> NeilBrown (19):
>       sched/wait: add wait_event_idle() functions.
>       staging: lustre: discard SVC_SIGNAL and related functions
>       staging: lustre: replace simple cases of l_wait_event() with wait_event().
>       staging: lustre: discard cfs_time_seconds()
>       staging: lustre: use wait_event_idle_timeout() where appropriate.
>       staging: lustre: introduce and use l_wait_event_abortable()
>       staging: lustre: simplify l_wait_event when intr handler but no timeout.
>       staging: lustre: simplify waiting in ldlm_completion_ast()
>       staging: lustre: open code polling loop instead of using l_wait_event()
>       staging: lustre: simplify waiting in ptlrpc_invalidate_import()
>       staging: lustre: remove back_to_sleep()
>       staging: lustre: make polling loop in ptlrpc_unregister_bulk more obvious
>       staging: lustre: use wait_event_idle_timeout in ptlrpcd()
>       staging: lustre: improve waiting in sptlrpc_req_refresh_ctx
>       staging: lustre: use explicit poll loop in ptlrpc_service_unlink_rqbd
>       staging: lustre: use explicit poll loop in ptlrpc_unregister_reply
>       staging: lustre: remove l_wait_event from ptlrpc_set_wait
>       staging: lustre: replace l_wait_event_exclusive_head() with wait_event_idle_exclusive
>       staging: lustre: remove l_wait_event() and related code
> 
> 
>  .../lustre/include/linux/libcfs/libcfs_debug.h     |    4 
>  .../lustre/include/linux/libcfs/libcfs_time.h      |    2 
>  .../lustre/include/linux/libcfs/linux/linux-time.h |    7 
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    8 -
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    4 
>  .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    6 
>  .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   22 +
>  drivers/staging/lustre/lnet/libcfs/debug.c         |    2 
>  drivers/staging/lustre/lnet/libcfs/fail.c          |    2 
>  drivers/staging/lustre/lnet/libcfs/tracefile.c     |    4 
>  drivers/staging/lustre/lnet/lnet/acceptor.c        |    2 
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |    4 
>  drivers/staging/lustre/lnet/lnet/lib-move.c        |    4 
>  drivers/staging/lustre/lnet/lnet/net_fault.c       |   14 -
>  drivers/staging/lustre/lnet/lnet/peer.c            |    2 
>  drivers/staging/lustre/lnet/lnet/router.c          |    8 -
>  drivers/staging/lustre/lnet/selftest/conrpc.c      |    4 
>  drivers/staging/lustre/lnet/selftest/rpc.c         |    2 
>  drivers/staging/lustre/lnet/selftest/selftest.h    |    2 
>  drivers/staging/lustre/lnet/selftest/timer.c       |    2 
>  drivers/staging/lustre/lustre/include/lustre_dlm.h |    2 
>  drivers/staging/lustre/lustre/include/lustre_lib.h |  296 ++------------------
>  drivers/staging/lustre/lustre/include/lustre_mdc.h |    2 
>  drivers/staging/lustre/lustre/include/lustre_net.h |    8 -
>  drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |   30 --
>  drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   14 -
>  drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |   12 -
>  drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |   17 -
>  drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   55 +---
>  drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   14 -
>  drivers/staging/lustre/lustre/llite/llite_lib.c    |   23 +-
>  drivers/staging/lustre/lustre/llite/statahead.c    |   60 ++--
>  drivers/staging/lustre/lustre/lov/lov_object.c     |    6 
>  drivers/staging/lustre/lustre/lov/lov_request.c    |   12 -
>  drivers/staging/lustre/lustre/mdc/mdc_request.c    |    5 
>  drivers/staging/lustre/lustre/mgc/mgc_request.c    |   19 -
>  drivers/staging/lustre/lustre/obdclass/cl_io.c     |   23 +-
>  drivers/staging/lustre/lustre/obdclass/genops.c    |   24 +-
>  drivers/staging/lustre/lustre/obdclass/llog_obd.c  |    5 
>  .../staging/lustre/lustre/obdecho/echo_client.c    |    2 
>  drivers/staging/lustre/lustre/osc/osc_cache.c      |   28 +-
>  drivers/staging/lustre/lustre/osc/osc_object.c     |    6 
>  drivers/staging/lustre/lustre/osc/osc_page.c       |    6 
>  drivers/staging/lustre/lustre/osc/osc_request.c    |    6 
>  drivers/staging/lustre/lustre/ptlrpc/client.c      |  101 +++----
>  drivers/staging/lustre/lustre/ptlrpc/events.c      |    7 
>  drivers/staging/lustre/lustre/ptlrpc/import.c      |   51 +--
>  drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |   15 +
>  .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    9 -
>  drivers/staging/lustre/lustre/ptlrpc/pinger.c      |   28 +-
>  .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |    2 
>  drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |   18 +
>  drivers/staging/lustre/lustre/ptlrpc/recover.c     |   12 -
>  drivers/staging/lustre/lustre/ptlrpc/sec.c         |   34 ++
>  drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |   23 --
>  drivers/staging/lustre/lustre/ptlrpc/service.c     |   84 +++---
>  include/linux/wait.h                               |  114 ++++++++
>  57 files changed, 516 insertions(+), 762 deletions(-)
> 
> --
> Signature
> 
> 
