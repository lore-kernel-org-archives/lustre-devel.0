From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 18:17:59 +1100
Subject: [lustre-devel] [PATCH SERIES 5: 00/16] staging: lustre: use
 standard wait_event macros
Message-ID: <151358127190.5099.12792810096274074963.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

Lustre has l_wait_event() which is a complex macro that does
similar things to the wait_event macro family in Linux.
This patch series converts all l_wait_event to something more
familiar to Linux developers.

Some of the conversions are subtle.  I think I've understood the code
and got the conversion correct, but I've quite possibly messed up.
If you only review one series, this is the one that demands review.

I haven't converted the single use of l_wait_event_exclusive_head().
That needs more thought.

This is the last series for today.  I do have some more patches, but
that are all individual patches that I hope to send as a  set of
ad-hoc patches tomorrow.

Thanks,
NeilBrown


---

NeilBrown (16):
      staging: lustre: discard SVC_SIGNAL and related functions
      staging: lustre: replace simple cases of l_wait_event() with wait_event().
      staging: lustre: discard cfs_time_seconds()
      staging: lustre: use wait_event_timeout() where appropriate.
      staging: lustre: introduce and use l_wait_event_abortable()
      staging: lustre: simplify l_wait_event when intr handler but no timeout.
      staging: lustre: simplify waiting in ldlm_completion_ast()
      staging: lustre: open code polling loop instead of using l_wait_event()
      staging: lustre: simplify waiting in ptlrpc_invalidate_import()
      staging: lustre: remove back_to_sleep() and use loops.
      staging: lustre: make polling loop in ptlrpc_unregister_bulk more obvious
      staging: lustre: use wait_event_timeout in ptlrpcd()
      staging: lustre: improve waiting in sptlrpc_req_refresh_ctx
      staging: lustre: use explicit poll loop in ptlrpc_service_unlink_rqbd
      staging: lustre: use explicit poll loop in ptlrpc_unregister_reply
      staging: lustre: remove l_wait_event from ptlrpc_set_wait


 .../lustre/include/linux/libcfs/libcfs_debug.h     |    4 -
 .../lustre/include/linux/libcfs/libcfs_time.h      |    2 
 .../lustre/include/linux/libcfs/linux/linux-time.h |    7 -
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    8 +
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    4 -
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    6 -
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   22 ++-
 drivers/staging/lustre/lnet/libcfs/debug.c         |    2 
 drivers/staging/lustre/lnet/libcfs/fail.c          |    2 
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |    4 -
 drivers/staging/lustre/lnet/lnet/acceptor.c        |    2 
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    4 -
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    4 -
 drivers/staging/lustre/lnet/lnet/net_fault.c       |   14 +-
 drivers/staging/lustre/lnet/lnet/peer.c            |    2 
 drivers/staging/lustre/lnet/lnet/router.c          |    8 +
 drivers/staging/lustre/lnet/selftest/conrpc.c      |    4 -
 drivers/staging/lustre/lnet/selftest/rpc.c         |    2 
 drivers/staging/lustre/lnet/selftest/selftest.h    |    2 
 drivers/staging/lustre/lnet/selftest/timer.c       |    2 
 drivers/staging/lustre/lustre/include/lustre_dlm.h |    2 
 drivers/staging/lustre/lustre/include/lustre_lib.h |  126 ++++++++++++++++++--
 drivers/staging/lustre/lustre/include/lustre_mdc.h |    2 
 drivers/staging/lustre/lustre/include/lustre_net.h |    8 -
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |   30 +----
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   14 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |   12 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |   17 +--
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   51 +++-----
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   14 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   23 +---
 drivers/staging/lustre/lustre/llite/statahead.c    |   60 ++++------
 drivers/staging/lustre/lustre/lov/lov_object.c     |    6 -
 drivers/staging/lustre/lustre/lov/lov_request.c    |   12 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    5 -
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |   19 +--
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |   23 ++--
 drivers/staging/lustre/lustre/obdclass/genops.c    |   24 +---
 drivers/staging/lustre/lustre/obdclass/llog_obd.c  |    5 -
 .../staging/lustre/lustre/obdecho/echo_client.c    |    2 
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   28 ++--
 drivers/staging/lustre/lustre/osc/osc_object.c     |    6 -
 drivers/staging/lustre/lustre/osc/osc_page.c       |    6 -
 drivers/staging/lustre/lustre/osc/osc_request.c    |    6 -
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  101 +++++++---------
 drivers/staging/lustre/lustre/ptlrpc/events.c      |    7 -
 drivers/staging/lustre/lustre/ptlrpc/import.c      |   51 +++-----
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |   14 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    9 +
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |   28 ++--
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |    2 
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |   17 +--
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |   12 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |   23 ++--
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |   23 +---
 drivers/staging/lustre/lustre/ptlrpc/service.c     |   40 +++---
 56 files changed, 446 insertions(+), 487 deletions(-)

--
Signature
