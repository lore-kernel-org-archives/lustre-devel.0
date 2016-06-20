From: Oleg Drokin <green@linuxhacker.ru>
Date: Mon, 20 Jun 2016 16:55:23 -0400
Subject: [lustre-devel] [PATCH v2 00/29] Lustre fixes
Message-ID: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

Changes from v1:
This is rebased and retested on top of latest staging tree,
one patch dropped because it made it to the tree by other means,
two more fixes added.

These patches represent another round of Lustre fixes
and also a few cleanups that some of the fixes were
building up upon.

Alex Zhuravlev (1):
  staging/lustre: LDLM_DEBUG() shouldn't be passed \n

Andreas Dilger (1):
  staging: lustre: quiet lockdep recursive lock warning

Andriy Skulysh (1):
  staging/lustre/osc: glimpse lock should match only with granted locks

Ben Evans (1):
  staging/lustre/ptlrpc: Remove __ptlrpc_request_bufs_pack

Bob Glossman (1):
  staging/lustre: Add newline to LU_OBJECT_DEBUG() message

Bruno Faccini (1):
  staging/lustre/llite: lock i_lock before __d_drop()

Dmitry Eremin (1):
  staging/lustre/osc: fix signed one bit field

Emoly Liu (1):
  staging/lustre/llite: allocate and free client cache asynchronously

Jinshan Xiong (1):
  staging/lustre/osc: osc_lock_weight endless loop fix

John L. Hammond (4):
  staging/lustre/llite: correct request handling after ll_lookup_it()
  staging/lustre/llite: flatten struct lookup_intent
  staging/lustre/llite: change it_data to it_request
  staging/lustre/ldlm: const qualify struct lustre_handle * params

Liang Zhen (2):
  staging/lustre/ptlrpc: reorganize ptlrpc_request
  staging/lustre/ptlrpc: missing wakeup for ptlrpc_check_set

Niu Yawei (1):
  staging/lustre/mdc: Zero atime in close RPC

Oleg Drokin (7):
  staging/lustre/llite: Get rid of ll_lock_dcache/ll_unlock_dcache
  staging/lustre/osc: Fix reverted condition in osc_lock_weight
  staging/lustre: Inline Lustre intent disposition functions
  staging/lustre/llite: Restore proper opencache operations
  staging/lustre/llite: ll_revalidate_dentry update
  staging/lustre: Add documentation for unstable_stats in sysfs
  staging/lustre/libcfs: Do not call kthread_run in wrong state

Patrick Farrell (1):
  staging/lustre/llite: take trunc_sem only at vvp layer

Sergey Cheremencev (1):
  staging/lustre/llite: don't panic when fid is insane

Vitaly Fertman (2):
  staging/lustre/ptlrpc: Early Reply vs Reply MDunlink
  staging/lustre/ptlrpc: lost bulk leads to a hang

Yang Sheng (1):
  staging/lustre/llite: ensure obd is effective in onu_upcall

akam kumar bharathi (1):
  staging/lustre/llite: IOC_MDC_GETFILEINFO returns the wrong ino

 drivers/staging/lustre/lnet/libcfs/debug.c         |   2 +-
 drivers/staging/lustre/lustre/include/cl_object.h  |  10 +-
 drivers/staging/lustre/lustre/include/lu_object.h  |   2 +-
 drivers/staging/lustre/lustre/include/lustre_dlm.h |  18 +-
 .../staging/lustre/lustre/include/lustre_intent.h  |  30 +-
 drivers/staging/lustre/lustre/include/lustre_mdc.h |   3 -
 drivers/staging/lustre/lustre/include/lustre_net.h | 414 ++++++++++++---------
 drivers/staging/lustre/lustre/include/obd.h        |   8 +-
 .../staging/lustre/lustre/include/obd_support.h    |   3 +
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |  16 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |   5 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   6 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   2 +-
 drivers/staging/lustre/lustre/llite/dcache.c       |  41 +-
 drivers/staging/lustre/lustre/llite/dir.c          |   8 +-
 drivers/staging/lustre/lustre/llite/file.c         |  66 ++--
 drivers/staging/lustre/lustre/llite/lcommon_misc.c |   8 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |  27 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  47 +--
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |   7 -
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |  18 +
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |   6 +-
 drivers/staging/lustre/lustre/llite/namei.c        |  25 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |  10 +-
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |  16 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |  26 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   8 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   7 +
 drivers/staging/lustre/lustre/lov/lov_object.c     |   4 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |  12 +
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |  93 ++---
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   2 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |   4 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |  46 +++
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   4 +-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   2 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |  18 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |   4 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |  12 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      | 159 ++++----
 drivers/staging/lustre/lustre/ptlrpc/events.c      |  30 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |   3 +-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |  20 +-
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |  43 +++
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |   4 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |   9 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c  |   2 +-
 drivers/staging/lustre/sysfs-fs-lustre             |   8 +
 48 files changed, 783 insertions(+), 535 deletions(-)

-- 
2.7.4
