From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:57:50 -0400
Subject: [lustre-devel] [PATCH 00/28] lustre: more assorted fixes for lustre
 2.10
Message-ID: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Another bacth of assorted fixes missing in the linux client from
lustre 2.10. All of these should be order independent and don't
collide with the PFL work that will land at a later date.

Alex Zhuravlev (2):
  lustre: llite: use security context if it's enabled in the kernel
  lustre: ptlrpc: do not wakeup every second

Andreas Dilger (2):
  lustre: mdc: improve mdc_enqueue() error message
  lustre: obdclass: deprecate OBD_GET_VERSION ioctl

Andrew Perepechko (1):
  lustre: osc: osc_extent_tree_dump0() implementation is suboptimal

Andriy Skulysh (1):
  lustre: ldlm: ELC shouldn't wait on lock flush

Bob Glossman (1):
  lustre: ptlrpc: handle case of epp_free_pages <= PTLRPC_MAX_BRW_PAGES

Doug Oucharek (1):
  lustre: ptlrpc: Do not assert when bd_nob_transferred != 0

Fan Yong (1):
  lustre: llite: control concurrent statahead instances

Frank Zago (1):
  lustre: llite: fix for stat under kthread and X86_X32

Henri Doreau (2):
  lustre: hsm: add kkuc before sending registration RPCs
  lustre: mdc: expose changelog through char devices

Hongchao Zhang (1):
  lustre: llite: IO accounting of page read

James Simmons (5):
  lustre: uapi: add back LUSTRE_MAXFSNAME to lustre_user.h
  lustre: uapi: add missing headers in lustre UAPI headers
  lustre: llite: enhance vvp_dev data structure naming
  lustre: clio: update spare bit handling
  lustre: llite: restore lld_nfs_dentry handling

Jinshan Xiong (2):
  lustre: llite: pipeline readahead better with large I/O
  lustre: ldlm: check lock cancellation in ldlm_cli_cancel()

John L. Hammond (2):
  lustre: llog: fix EOF handling in llog_client_next_block()
  lustre: mdc: set correct body eadatasize for getxattr()

Lai Siyao (3):
  lustre: ptlrpc: missing barrier before wake_up
  lustre: statahead: missing barrier before wake_up
  lustre: llite: disable statahead if starting statahead fail

Patrick Farrell (3):
  lustre: llite: Read ahead should return pages read
  lustre: llite: Update i_nlink on unlink
  lustre: ldlm: Make lru clear always discard read lock pages

 .../lustre/include/uapi/linux/lnet/libcfs_debug.h  |   2 +
 .../lustre/include/uapi/linux/lnet/lnetctl.h       |   1 +
 .../lustre/include/uapi/linux/lnet/nidstr.h        |   1 +
 .../lustre/include/uapi/linux/lustre/lustre_cfg.h  |   1 +
 .../lustre/include/uapi/linux/lustre/lustre_fid.h  |   1 +
 .../include/uapi/linux/lustre/lustre_fiemap.h      |   1 +
 .../include/uapi/linux/lustre/lustre_ioctl.h       |   2 +-
 .../include/uapi/linux/lustre/lustre_kernelcomm.h  |   3 -
 .../include/uapi/linux/lustre/lustre_ostid.h       |   1 +
 .../lustre/include/uapi/linux/lustre/lustre_user.h |   9 +-
 drivers/staging/lustre/lustre/include/cl_object.h  |   2 +-
 .../lustre/lustre/include/lustre_dlm_flags.h       |   2 +-
 drivers/staging/lustre/lustre/include/lustre_net.h |   2 +
 drivers/staging/lustre/lustre/include/obd.h        |  18 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |  20 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |   2 +
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |  13 -
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |  66 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   6 +-
 drivers/staging/lustre/lustre/llite/dir.c          |  14 +-
 drivers/staging/lustre/lustre/llite/file.c         |  25 +-
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |   4 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |  39 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  22 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  37 ++
 drivers/staging/lustre/lustre/llite/namei.c        |  12 +-
 drivers/staging/lustre/lustre/llite/rw.c           |  57 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |  39 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |  54 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  57 +-
 drivers/staging/lustre/lustre/mdc/Makefile         |   2 +-
 drivers/staging/lustre/lustre/mdc/mdc_changelog.c  | 722 +++++++++++++++++++++
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |   4 +
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |  10 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |  11 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    | 198 +-----
 drivers/staging/lustre/lustre/obdclass/class_obd.c |  18 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   2 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   7 +-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   2 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |   6 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |  10 +-
 drivers/staging/lustre/lustre/osc/osc_object.c     |   2 +-
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c |  24 +-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |   8 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |   4 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |  11 +-
 47 files changed, 1150 insertions(+), 404 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/mdc/mdc_changelog.c

-- 
1.8.3.1
