From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:00 +1100
Subject: [lustre-devel] [PATCH 00/29] assorted osc cleanups.
Message-ID: <154701488711.26726.17363928508883972338.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I was reading through the osc code recently trying to understand it,
and tripped over various things that made it harded to understand.
So I wrote patches to clean those things up.  As you can see below,
this deleted nearly 300 lines of code.

None of these are bug-fixes, and some may only be subjective
improvements, so I can drop any that anyone objects to.

This seems to fit well with James' recent suggesting to focus on
house-cleaning for a while (which I support).

Thanks,
NeilBrown


---

NeilBrown (29):
      lustre: osc_cache: discard oe_intree
      lustre: osc_cache: use assert_spin_locked()
      lustre: osc: simplify osc_extent_wait()
      lustre: osc: simplify list manipulation
      lustre: osc: convert oe_refc and oe_users to kref and refcount_
      lustre: osc: use overlapped() consistently.
      lustre: osc: convert a while loop to for
      lustre: osc: simplify osc_extent_find()
      lustre: osc: remove test on 'found' being an error.
      lustre: osc_cache: avoid list_for_each_entry_safe when clearing list.
      lustre: osc_cache: simplify osc_wake_cache_waiters()
      lustre: osc_cache: avoid confusing variable reuse.
      lustre: osc_cache: change osc_enter_cache_try to return bool.
      lustre: osc_cache: convert cl_cache_waiters to a wait_queue.
      lustre: osc_cache: change osc_make_rpc() to return bool.
      lustre: osc_cache: use osc_makes_hprpc() more consistently.
      lustre: osc_cache: simplify list walk in get_write_extents().
      lustre: osc_cache: avoid unnecessary tests.
      lustre: osc_cache: convert while to for in get_write_extents()
      lustre: osc_cache: don't drop a lock we didn't take.
      lustre: osc_cache: don't drop a lock we didn't take - two
      lustre: osc_cache: osc_prep_async_page() has meaningless return
      lustre: osc_cache: remove 'transient' arg from osc_enter_cache_try
      lustre: osc_cache: change need_release to bool
      lustre: remove cl_page_cancel()
      lustre: osc_cache: simplify osc_page_gang_lookup()
      lustre: osc_cache: white-space and other checkpatch fixes.
      lustre: osc_request: assorted white-space and check-patch fixes.
      lustre: centralize handling of PTLRPCD_SET


 drivers/staging/lustre/lustre/include/cl_object.h  |   25 -
 drivers/staging/lustre/lustre/include/lustre_net.h |    2 
 drivers/staging/lustre/lustre/include/obd.h        |    2 
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |    2 
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |   20 -
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  722 +++++++-------------
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   33 -
 drivers/staging/lustre/lustre/osc/osc_internal.h   |   15 
 drivers/staging/lustre/lustre/osc/osc_io.c         |    4 
 drivers/staging/lustre/lustre/osc/osc_lock.c       |   27 -
 drivers/staging/lustre/lustre/osc/osc_page.c       |   22 -
 drivers/staging/lustre/lustre/osc/osc_request.c    |  199 +++---
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   20 -
 13 files changed, 399 insertions(+), 694 deletions(-)

--
Signature
