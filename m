From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:19:56 -0400
Subject: [lustre-devel] [PATCH 00/23] lustre: latest patches landed to
 OpenSFS 08/11/2020
Message-ID: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Latest patches to landed to the OpenSFS tree as of Aug 11, 2020.
Please review to make sure they are correct.

Bobi Jam (1):
  lustre: lov: one more fix to write_intent end for trunc

Chris Horn (6):
  lnet: Add param to control response tracking
  lnet: Ensure LNet pings and pushes are always tracked
  lnet: Preferred NI logic breaks MR routing
  lnet: Allow duplicate nets in ip2nets syntax
  lnet: Clear lp_dc_error when discovery completes
  lnet: Have LNet routers monitor the ni_fatal flag

James Simmons (1):
  lustre: obd: rename lprocfs_ / LPROC_SEQ_ to debugfs name

Lai Siyao (2):
  lustre: uapi: add OBD_CONNECT2_GETATTR_PFID
  lustre: llite: pack parent FID in getattr

Mr NeilBrown (7):
  lustre: lov: annotate nested locking of obd_dev_mutex
  lustre: ptlrpc: make ptlrpc_connection_put() static inline
  lustre: mdc: create mdc_acl.c
  lustre: sysfs: error-check value stored in jobid_var
  lnet: socklnd: remove declarations of missing functions.
  lnet: discard unused lnet_print_hdr()
  lnet: clarify initialization of lpni_refcount

Oleg Drokin (1):
  lustre: update version to 2.13.55

Patrick Farrell (1):
  lustre: llite: Remove mutex on dio read

Sebastien Buisson (3):
  lustre: sec: atomicity of encryption context getting/setting
  lustre: sec: encryption support for DoM files
  lustre: sec: check if page is empty with ZERO_PAGE

Serguei Smirnov (1):
  lnet: socklnd: NID to interface mapping issues

 fs/lustre/fid/fid_internal.h           |   2 +-
 fs/lustre/fid/lproc_fid.c              |  10 +--
 fs/lustre/fld/fld_internal.h           |   2 +-
 fs/lustre/fld/lproc_fld.c              |  12 +--
 fs/lustre/include/lprocfs_status.h     | 158 +++++++++++----------------------
 fs/lustre/include/lustre_crypto.h      |   2 +
 fs/lustre/include/lustre_export.h      |   5 ++
 fs/lustre/include/lustre_net.h         |  32 ++++++-
 fs/lustre/include/lustre_req_layout.h  |   3 +-
 fs/lustre/include/obd.h                |   6 +-
 fs/lustre/include/obd_class.h          |  20 ++---
 fs/lustre/ldlm/ldlm_internal.h         |   2 +-
 fs/lustre/ldlm/ldlm_pool.c             |   4 +-
 fs/lustre/ldlm/ldlm_resource.c         |  10 +--
 fs/lustre/llite/crypto.c               |  85 +++++++++++-------
 fs/lustre/llite/dir.c                  |  16 +++-
 fs/lustre/llite/file.c                 |  30 ++++++-
 fs/lustre/llite/llite_internal.h       |   5 ++
 fs/lustre/llite/llite_lib.c            |   4 +-
 fs/lustre/llite/lproc_llite.c          |  30 ++++---
 fs/lustre/llite/namei.c                | 112 ++++++++++++++++++++---
 fs/lustre/llite/rw26.c                 |  10 ---
 fs/lustre/llite/xattr_cache.c          |  34 +++++++
 fs/lustre/lmv/lmv_intent.c             |   5 +-
 fs/lustre/lmv/lmv_obd.c                |   3 +-
 fs/lustre/lov/lov_io.c                 |   5 +-
 fs/lustre/mdc/Makefile                 |   1 +
 fs/lustre/mdc/lproc_mdc.c              |  28 +++---
 fs/lustre/mdc/mdc_acl.c                |  64 +++++++++++++
 fs/lustre/mdc/mdc_internal.h           |  12 +++
 fs/lustre/mdc/mdc_lib.c                |  23 +++++
 fs/lustre/mdc/mdc_locks.c              |  22 +++++
 fs/lustre/mdc/mdc_reint.c              |   3 +
 fs/lustre/mdc/mdc_request.c            |  65 ++------------
 fs/lustre/mgc/lproc_mgc.c              |  12 +--
 fs/lustre/obdclass/genops.c            |  11 +--
 fs/lustre/obdclass/lprocfs_status.c    |  50 ++++++-----
 fs/lustre/obdclass/obd_config.c        |  92 -------------------
 fs/lustre/obdclass/obd_sysfs.c         |  24 +++--
 fs/lustre/osc/lproc_osc.c              |  24 ++---
 fs/lustre/osc/osc_request.c            |  11 +--
 fs/lustre/ptlrpc/connection.c          |  35 --------
 fs/lustre/ptlrpc/import.c              |   6 +-
 fs/lustre/ptlrpc/layout.c              |  25 ++++--
 fs/lustre/ptlrpc/lproc_ptlrpc.c        |  30 ++++---
 fs/lustre/ptlrpc/ptlrpc_module.c       |   2 -
 fs/lustre/ptlrpc/sec_lproc.c           |  15 ++--
 fs/lustre/ptlrpc/wiretest.c            |   6 +-
 include/linux/lnet/lib-lnet.h          |  31 ++++++-
 include/uapi/linux/lustre/lustre_idl.h |   4 +-
 include/uapi/linux/lustre/lustre_ver.h |   4 +-
 net/lnet/klnds/socklnd/socklnd.c       |   2 +-
 net/lnet/klnds/socklnd/socklnd.h       |   2 -
 net/lnet/lnet/api-ni.c                 |  37 ++++++++
 net/lnet/lnet/config.c                 |  36 +-------
 net/lnet/lnet/lib-move.c               |  86 +++++-------------
 net/lnet/lnet/peer.c                   |  52 ++++++-----
 net/lnet/lnet/router.c                 |  35 +++++---
 58 files changed, 793 insertions(+), 664 deletions(-)
 create mode 100644 fs/lustre/mdc/mdc_acl.c

-- 
1.8.3.1
