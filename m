From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:47:32 -0400
Subject: [lustre-devel] [PATCH 00/43] Lustre IO stack simplifications and
	cleanups
Message-ID: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This large body of patches mostly deals with Lustre IO stack
simplifications and related cleanups.
In particular the whole cl_page and cl_lock stuff is reduced to
basically nothing.
The simplifications remove about 5K lines of code and the other 5k
are mostly due to shuffling code around and renaming stuff
to get rid of now defunct layers.

Bobi Jam (1):
  staging/lustre: update comments after cl_lock simplification

Jinshan Xiong (14):
  staging/lustre: Reintroduce global env list
  staging/lustre/osc: Adjustment on osc LRU for performance
  staging/lustre/osc: to drop LRU pages with cl_lru_work
  staging/lustre/clio: collapse layer of cl_page
  staging/lustre/obdclass: Add a preallocated percpu cl_env
  staging/lustre/clio: add pages into writeback cache in batches
  staging/lustre/osc: add weight function for DLM lock
  staging/lustre/clio: remove stackable cl_page completely
  staging/lustre/clio: optimize read ahead code
  staging/lustre/clio: generalize cl_sync_io
  staging/lustre/clio: cl_lock simplification
  staging/lustre/llite: clip page correctly for vvp_io_commit_sync
  staging/lustre/llite: deadlock for page write
  staging/lustre/ldlm: ELC picks locks in a safer policy

John Hammond (5):
  staging/lustre/llite: Rename struct ccc_grouplock to ll_grouplock
  staging/lustre/llite: Rename struct vvp_thread_info to ll_thread_info
  staging/lustre/llite: rename struct ccc_thread_info to vvp_thread_info
  staging/lustre/llite: Remove ccc_global_{init,fini}()
  staging/lustre/llite: Move several declarations to llite_internal.h

John L. Hammond (15):
  staging/lustre: merge lclient/*.c into llite/
  staging/lustre/llite: remove lli_lvb
  staging/lustre/lmv: remove lmv_init_{lock,unlock}()
  staging/lustre/obd: remove struct client_obd_lock
  staging/lustre/llite: remove some cl wrappers
  staging/lustre/llite: merge lclient.h into llite/vvp_internal.h
  staging/lustre/llite: rename ccc_device to vvp_device
  staging/lustre/llite: rename ccc_object to vvp_object
  staging/lustre/llite: rename ccc_page to vvp_page
  staging/lustre/llite: rename ccc_lock to vvp_lock
  staging/lustre:llite: remove struct ll_ra_read
  staging/lustre/llite: merge ccc_io and vvp_io
  staging/lustre/llite: use vui prefix for struct vvp_io members
  staging/lustre/llite: move vvp_io functions to vvp_io.c
  staging/lustre/llite: rename ccc_req to vvp_req

Li Dongyang (1):
  staging/lustre/llite: make sure we do cl_page_clip on the last page

Niu Yawei (1):
  staging/lustre/ldlm: revert changes to ldlm_cancel_aged_policy()

Oleg Drokin (5):
  staging/lustre/obdclass: limit lu_site hash table size
  staging/lustre: Get rid of CFS_PAGE_MASK
  staging/lustre: Remove struct ll_iattr
  staging/lustre/llite: Move ll_dirent_type_get and make it static
  staging/lustre/llite: Remove unused vui_local_lock field

Vitaly Fertman (1):
  staging/lustre/ldlm: restore the ELC for enqueue

 .../lustre/include/linux/libcfs/linux/linux-mem.h  |    1 -
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |    2 +-
 drivers/staging/lustre/lnet/selftest/brw_test.c    |    2 +-
 drivers/staging/lustre/lustre/fld/fld_request.c    |   14 +-
 drivers/staging/lustre/lustre/include/cl_object.h  |  962 ++-------
 drivers/staging/lustre/lustre/include/lclient.h    |  408 ----
 drivers/staging/lustre/lustre/include/linux/obd.h  |  125 --
 .../lustre/lustre/include/lustre/lustre_idl.h      |    2 +
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   14 +-
 drivers/staging/lustre/lustre/include/obd.h        |   14 +-
 drivers/staging/lustre/lustre/lclient/glimpse.c    |  270 ---
 drivers/staging/lustre/lustre/lclient/lcommon_cl.c | 1203 -----------
 .../staging/lustre/lustre/lclient/lcommon_misc.c   |  200 --
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |    7 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |    5 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    3 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   74 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    1 +
 drivers/staging/lustre/lustre/llite/Makefile       |    5 +-
 drivers/staging/lustre/lustre/llite/dir.c          |   24 +-
 drivers/staging/lustre/lustre/llite/file.c         |  133 +-
 drivers/staging/lustre/lustre/llite/glimpse.c      |  255 +++
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |  327 +++
 drivers/staging/lustre/lustre/llite/lcommon_misc.c |  201 ++
 drivers/staging/lustre/lustre/llite/llite_close.c  |   28 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |  244 +--
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   21 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |   38 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |   10 +-
 drivers/staging/lustre/lustre/llite/rw.c           |  363 ++--
 drivers/staging/lustre/lustre/llite/rw26.c         |  304 ++-
 drivers/staging/lustre/lustre/llite/super25.c      |   14 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |  253 ++-
 drivers/staging/lustre/lustre/llite/vvp_internal.h |  332 ++-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  925 +++++----
 drivers/staging/lustre/lustre/llite/vvp_lock.c     |   53 +-
 drivers/staging/lustre/lustre/llite/vvp_object.c   |  141 +-
 drivers/staging/lustre/lustre/llite/vvp_page.c     |  209 +-
 drivers/staging/lustre/lustre/llite/vvp_req.c      |  121 ++
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |    3 -
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   26 +-
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |  105 +-
 drivers/staging/lustre/lustre/lov/lov_dev.c        |    5 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h   |    2 +
 drivers/staging/lustre/lustre/lov/lov_io.c         |  229 +--
 drivers/staging/lustre/lustre/lov/lov_lock.c       |  996 +--------
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    1 -
 drivers/staging/lustre/lustre/lov/lov_object.c     |   48 +-
 drivers/staging/lustre/lustre/lov/lov_offset.c     |   13 +
 drivers/staging/lustre/lustre/lov/lov_page.c       |  183 +-
 drivers/staging/lustre/lustre/lov/lovsub_lock.c    |  383 ----
 drivers/staging/lustre/lustre/lov/lovsub_page.c    |    4 +-
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c      |    8 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   21 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    4 +-
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |  416 ++--
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   | 2152 +-------------------
 drivers/staging/lustre/lustre/obdclass/cl_object.c |  294 ++-
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |  654 +-----
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    2 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    4 +-
 drivers/staging/lustre/lustre/obdclass/obdo.c      |    3 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |  115 +-
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |   50 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  378 +++-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |  137 +-
 drivers/staging/lustre/lustre/osc/osc_internal.h   |   23 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |  279 +--
 drivers/staging/lustre/lustre/osc/osc_lock.c       | 1693 ++++++---------
 drivers/staging/lustre/lustre/osc/osc_object.c     |   35 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |  513 +++--
 drivers/staging/lustre/lustre/osc/osc_request.c    |  376 ++--
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |   16 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |    2 +-
 75 files changed, 5713 insertions(+), 10770 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/include/lclient.h
 delete mode 100644 drivers/staging/lustre/lustre/include/linux/obd.h
 delete mode 100644 drivers/staging/lustre/lustre/lclient/glimpse.c
 delete mode 100644 drivers/staging/lustre/lustre/lclient/lcommon_cl.c
 delete mode 100644 drivers/staging/lustre/lustre/lclient/lcommon_misc.c
 create mode 100644 drivers/staging/lustre/lustre/llite/glimpse.c
 create mode 100644 drivers/staging/lustre/lustre/llite/lcommon_cl.c
 create mode 100644 drivers/staging/lustre/lustre/llite/lcommon_misc.c
 create mode 100644 drivers/staging/lustre/lustre/llite/vvp_req.c

-- 
2.1.0
