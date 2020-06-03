From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 20:59:39 -0400
Subject: [lustre-devel] [PATCH 00/22] lustre: OpenSFS backport patches for
 May 29 2020
Message-ID: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Batch of patches that landed to OpenSFS tree for around the
May 29 2020 date. This is against my git tree. Please review
to avoid any backport issues.

Amir Shehata (4):
  lnet: handle discovery off properly
  lnet: Force full discovery cycle
  lnet: set route aliveness properly
  lnet: lnd: gracefully handle unexpected events

Bruno Faccini (1):
  lustre: ldlm: no current source if lu_ref_del not in same tsk

Chris Horn (4):
  lnet: Correct the default LND timeout
  lnet: Add lnet_lnd_timeout to sysfs
  lnet: lnd: Allow independent ko2iblnd timeout
  lnet: lnd: Allow independent socklnd timeout

James Simmons (2):
  lnet: libcfs: fix CPT handling for UP systems
  lustre: obdclass: bind zombie export cleanup workqueue

Mr NeilBrown (6):
  lustre: use BIT() macro where appropriate in include
  lustre: use BIT() macro where appropriate
  lustre: ptlrpc: change LONG_UNLINK to PTLRPC_REQ_LONG_UNLINK
  lustre: llite: use %pd to report dentry names.
  lnet: tidy lnet_discover and fix mem accounting bug.
  lnet: always pass struct lnet_md by reference.

Oleg Drokin (1):
  lustre: update version to 2.13.54

Qian Yingjin (1):
  lustre: llite: integrate statx() API with Lustre

Sebastien Buisson (1):
  lustre: llite: prevent MAX_DIO_SIZE 32-bit truncation

Wang Shilong (1):
  lustre: llite: fix read if readahead window smaller than rpc size

Yang Sheng (1):
  lnet: procs: print new line based on distro

 fs/lustre/include/cl_object.h              |  14 ++--
 fs/lustre/include/lu_object.h              |  36 +++++-----
 fs/lustre/include/lustre_dlm.h             |  10 +--
 fs/lustre/include/lustre_net.h             |  32 ++++-----
 fs/lustre/include/lustre_sec.h             |  12 ++--
 fs/lustre/include/obd.h                    |   2 +-
 fs/lustre/include/obd_support.h            |   3 +-
 fs/lustre/ldlm/ldlm_extent.c               |   4 +-
 fs/lustre/ldlm/ldlm_lock.c                 |   4 +-
 fs/lustre/ldlm/ldlm_resource.c             |   2 +-
 fs/lustre/llite/dcache.c                   |   4 +-
 fs/lustre/llite/file.c                     |  86 +++++++++++++++++++++---
 fs/lustre/llite/llite_internal.h           |  12 +++-
 fs/lustre/llite/llite_lib.c                |  30 ++++-----
 fs/lustre/llite/namei.c                    |   2 +-
 fs/lustre/llite/pcc.c                      |  25 +++----
 fs/lustre/llite/pcc.h                      |   3 +-
 fs/lustre/llite/rw.c                       |   6 +-
 fs/lustre/llite/rw26.c                     |   2 +-
 fs/lustre/llite/statahead.c                |  59 ++++++++++++++--
 fs/lustre/lov/lov_cl_internal.h            |   2 +-
 fs/lustre/obdclass/genops.c                |   9 +--
 fs/lustre/osc/lproc_osc.c                  |   4 +-
 fs/lustre/ptlrpc/client.c                  |  13 ++--
 fs/lustre/ptlrpc/layout.c                  |   6 +-
 fs/lustre/ptlrpc/niobuf.c                  |  15 +++--
 fs/lustre/ptlrpc/pinger.c                  |  19 ++----
 fs/lustre/ptlrpc/service.c                 |   2 +-
 include/linux/libcfs/libcfs_cpu.h          | 104 ++++++++++++-----------------
 include/linux/lnet/api.h                   |   4 +-
 include/linux/lnet/lib-lnet.h              |   2 +-
 include/uapi/linux/lustre/lustre_ver.h     |   4 +-
 net/lnet/klnds/o2iblnd/o2iblnd.h           |   6 ++
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c        |  16 +++--
 net/lnet/klnds/o2iblnd/o2iblnd_modparams.c |   2 +-
 net/lnet/klnds/socklnd/socklnd.c           |   4 +-
 net/lnet/klnds/socklnd/socklnd.h           |   7 ++
 net/lnet/klnds/socklnd/socklnd_cb.c        |  16 ++---
 net/lnet/klnds/socklnd/socklnd_modparams.c |   2 +-
 net/lnet/libcfs/debug.c                    |   4 +-
 net/lnet/libcfs/libcfs_cpu.c               |   7 +-
 net/lnet/lnet/api-ni.c                     |  88 +++++++++++-------------
 net/lnet/lnet/lib-md.c                     |  24 +++----
 net/lnet/lnet/lib-move.c                   |   2 +-
 net/lnet/lnet/peer.c                       |  54 +++++++++------
 net/lnet/lnet/router.c                     |   9 ++-
 net/lnet/lnet/router_proc.c                |   7 ++
 net/lnet/selftest/rpc.c                    |   4 +-
 48 files changed, 453 insertions(+), 331 deletions(-)

-- 
1.8.3.1
