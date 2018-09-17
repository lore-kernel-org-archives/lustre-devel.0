From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:10 -0400
Subject: [lustre-devel] [PATCH 00/30] lustre: first batch of fixes from
 lustre 2.10
Message-ID: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

First collection of patches to address various cleanups and bugs in the
lustre 2.10 release that are missing for the lustre linux client. These
patches can be applied in any order.

Alexander Boyko (2):
  lustre: osc: fix for cl_env_get in low memory
  lustre: ptlrpc: fix wrong error handlers

Alexandr Boyko (1):
  lustre: osc: adds radix_tree_preload

Andreas Dilger (2):
  lustre: llog: update llog print format to use FIDs
  lustre: mdc: allow setting readdir RPC size parameter

Andrew Perepechko (1):
  lustre: llite: llite.stat_blocksize param for fixed st_blksize

Andriy Skulysh (3):
  lustre: osc: GPF while doing ELC with no_wait_policy
  lustre: ldlm: GPF in _ldlm_lock_debug()
  lustre: llite: protect ll_dentry_data modification

Bobi Jam (2):
  lustre: osc: osc page lru list race
  lustre: llite: check the return value of cl_file_inode_init()

Bruno Faccini (1):
  lustre: ptlrpc: drain "ptlrpc_request_buffer_desc" objects

Doug Oucharek (1):
  lustre: lnet: Change sock_create() to sock_create_kern()

Fan Yong (1):
  lustre: ptlrpc: free reply buffer earlier for open RPC

James Simmons (2):
  lustre: lnd: resolve IP query code in LND drivers
  lustre: clio: fix spare bit handling

John L. Hammond (3):
  lustre: ptlrpc: set rq_sent when send fails due to -ENOMEM
  lustre: kuc: initialize kkuc_groups at module init time
  lustre: ldlm: use static initializer macros where possible

Niu Yawei (3):
  lustre: uapi: add documentation about FIDs
  lustre: osc: update timestamps on write only
  lustre: ptlrpc: add replay request into unreplied list

Patrick Farrell (1):
  lustre: ldlm: cond_resched in ldlm_bl_thread_main

Sebastien Buisson (1):
  lustre: llite: set sec ctx on client's inode at create time

Steve Guminski (3):
  lustre: ptlrpc: Prevent possible dereference of NULL pointers
  lustre: mgc: Remove unnecessary checks for config_log_put()
  lustre: llite: rcu-walk check should not depend on statahead

Vitaly Fertman (1):
  lustre: ptlrpc: increase sleep time in ptlrpc_request_bufs_pack()

Wang Shilong (1):
  lustre: obd: remove obsolete OBD_FL_LOCAL_MASK

Yang Sheng (1):
  lustre: libcfs: use save_stack_trace for stack dump

 .../lustre/include/linux/libcfs/libcfs_debug.h     |  1 +
 .../lustre/include/uapi/linux/lustre/lustre_idl.h  | 88 +++++++++++++++++++++-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    | 12 ++-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |  2 +-
 drivers/staging/lustre/lnet/libcfs/debug.c         | 46 ++++++++++-
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |  2 +-
 .../staging/lustre/lustre/include/lprocfs_status.h |  5 ++
 drivers/staging/lustre/lustre/include/lustre_dlm.h |  4 +-
 .../lustre/lustre/include/lustre_kernelcomm.h      |  1 +
 drivers/staging/lustre/lustre/include/lustre_net.h | 14 ++--
 drivers/staging/lustre/lustre/include/obd.h        |  5 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 13 +++-
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    | 12 +--
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |  6 +-
 drivers/staging/lustre/lustre/llite/dcache.c       |  7 +-
 drivers/staging/lustre/lustre/llite/dir.c          | 22 +++---
 drivers/staging/lustre/lustre/llite/file.c         |  2 +-
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   | 19 ++---
 .../staging/lustre/lustre/llite/llite_internal.h   |  8 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 24 +++---
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |  4 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  | 33 ++++++++
 drivers/staging/lustre/lustre/llite/namei.c        | 59 ++++++++++++---
 drivers/staging/lustre/lustre/llite/statahead.c    |  4 -
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c      | 20 +----
 drivers/staging/lustre/lustre/mdc/mdc_request.c    | 35 ++++++---
 drivers/staging/lustre/lustre/mgc/mgc_request.c    | 36 ++++-----
 drivers/staging/lustre/lustre/obdclass/class_obd.c |  3 +
 .../staging/lustre/lustre/obdclass/kernelcomm.c    | 38 +++++++---
 drivers/staging/lustre/lustre/obdclass/llog_cat.c  | 28 +++----
 drivers/staging/lustre/lustre/obdclass/llog_swab.c |  4 +-
 .../lustre/lustre/obdclass/lprocfs_status.c        | 54 +++++++++++++
 drivers/staging/lustre/lustre/obdclass/obdo.c      | 11 ---
 drivers/staging/lustre/lustre/osc/lproc_osc.c      | 46 -----------
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  3 +
 drivers/staging/lustre/lustre/osc/osc_io.c         |  2 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       | 13 +++-
 drivers/staging/lustre/lustre/osc/osc_object.c     |  2 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       | 43 ++++++-----
 drivers/staging/lustre/lustre/osc/osc_request.c    |  7 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      | 67 +++++++++++-----
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      | 20 ++---
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    | 26 +++++--
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |  1 +
 drivers/staging/lustre/lustre/ptlrpc/recover.c     | 12 +--
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     | 14 +++-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |  1 -
 48 files changed, 585 insertions(+), 296 deletions(-)

-- 
1.8.3.1
