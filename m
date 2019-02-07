From: NeilBrown <neilb@suse.com>
Date: Thu, 07 Feb 2019 11:03:32 +1100
Subject: [lustre-devel] [PATCH 00/21] lustre: Assorted cleanups for obdclass
Message-ID: <154949776249.10620.1215070753973826063.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I've been reading through obdclass and writing patches as I go.
I'm not done yet, but this patch set to big enough to send for
review.

NeilBrown


---

NeilBrown (21):
      lustre: obdclass: discard csi_end_io
      lustre: obd_class: remove csi_barrier from struct cl_sync_io
      lustre: obdclass: use list_sort() to sort a list.
      lustre: use list*entry macros in place of container_of()
      lustre: use list_first_entry() in lustre subdirectory.
      lustre: use list_first_entry() in lnet/lnet subdirectory.
      lustre: use list_first_entry() in lnet/klnds subdirectory.
      lustre: use list_first_entry() throughout
      lustre: use list_last_entry() throughout
      lustre: obdclass: use cl_object_for_each where appropriate
      lustre: cl_object: remove vestigial debugging.
      lustre: cl_page.c: remove PINVRNT()
      lustre: make cp_ref in cl_page a refcount_t
      lustre: make ccc_users in cl_client_cache a refcount_t
      lustre: obdclass: char obd_ioctl_getdata type.
      lustre: obdclass: normalize a switch statement.
      lustre: obdclass: result of try_module_get() should not be ignored.
      lustre: move debug.c from obdclass to obdecho
      lustre: obdclass: avoid races in class_register_type()
      lustre: obdclass: fix module load locking.
      lustre: make exp_refcount in obd_export a refcount_t


 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   19 ++-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   61 ++++++-----
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    9 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   79 +++++++-------
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |    4 -
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |   12 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  111 ++++++++++----------
 drivers/staging/lustre/lnet/lnet/config.c          |   22 ++--
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   53 +++++-----
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |   16 +--
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |    7 +
 drivers/staging/lustre/lnet/lnet/net_fault.c       |   24 ++--
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |    9 +-
 drivers/staging/lustre/lnet/lnet/peer.c            |   24 ++--
 drivers/staging/lustre/lnet/lnet/router.c          |   13 +-
 drivers/staging/lustre/lnet/selftest/conrpc.c      |    5 -
 drivers/staging/lustre/lnet/selftest/console.c     |   39 +++----
 drivers/staging/lustre/lnet/selftest/framework.c   |   44 ++++----
 drivers/staging/lustre/lnet/selftest/rpc.c         |   27 ++---
 drivers/staging/lustre/lnet/selftest/timer.c       |    4 -
 drivers/staging/lustre/lustre/include/cl_object.h  |   19 +--
 .../staging/lustre/lustre/include/lustre_debug.h   |   52 ---------
 .../staging/lustre/lustre/include/lustre_export.h  |    2 
 drivers/staging/lustre/lustre/include/obd.h        |    1 
 drivers/staging/lustre/lustre/include/obd_class.h  |    3 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   10 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    4 -
 drivers/staging/lustre/lustre/llite/dir.c          |   17 +--
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    8 +
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |    2 
 drivers/staging/lustre/lustre/llite/statahead.c    |   23 ++--
 drivers/staging/lustre/lustre/llite/vvp_page.c     |    9 +-
 drivers/staging/lustre/lustre/lov/lov_io.c         |    9 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   15 +--
 drivers/staging/lustre/lustre/lov/lov_page.c       |    3 -
 drivers/staging/lustre/lustre/obdclass/Makefile    |    2 
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |   91 ++++------------
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   |    5 -
 drivers/staging/lustre/lustre/obdclass/cl_object.c |  110 ++++++++------------
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |   77 ++++----------
 drivers/staging/lustre/lustre/obdclass/class_obd.c |   32 ++----
 drivers/staging/lustre/lustre/obdclass/debug.c     |   96 -----------------
 drivers/staging/lustre/lustre/obdclass/genops.c    |   90 ++++++++++------
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    7 +
 .../staging/lustre/lustre/obdclass/lustre_peer.c   |    5 -
 drivers/staging/lustre/lustre/obdecho/Makefile     |    2 
 drivers/staging/lustre/lustre/obdecho/debug.c      |   96 +++++++++++++++++
 .../staging/lustre/lustre/obdecho/echo_client.c    |    3 -
 .../staging/lustre/lustre/obdecho/echo_internal.h  |    4 +
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   17 ++-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |    7 +
 drivers/staging/lustre/lustre/osc/osc_page.c       |   21 ++--
 drivers/staging/lustre/lustre/osc/osc_request.c    |   11 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   14 +--
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |    1 
 drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c    |    6 +
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    4 -
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |    6 +
 drivers/staging/lustre/lustre/ptlrpc/service.c     |   68 ++++++------
 60 files changed, 689 insertions(+), 847 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/include/lustre_debug.h
 delete mode 100644 drivers/staging/lustre/lustre/obdclass/debug.c
 create mode 100644 drivers/staging/lustre/lustre/obdecho/debug.c

--
Signature
