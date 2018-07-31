From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:25:52 -0400
Subject: [lustre-devel] [PATCH 00/31] lustre: missing fixes and cleanups
 from lustre 2.10
Message-ID: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This covers all the missing patches landed from the start of the
lustre 2.10 development cycle until right before the PFL feature
landed. Several bug fixes as well as cleanups. This is based on
top of the recent list patches as well as my mount code for llite
patch series.

Abrarahmed Momin (1):
  lustre: llite: Remove OBD_FAIL_OSC_CONNECT_CKSUM

Amir Shehata (1):
  lustre: lnet: Fix route hops print

Andreas Dilger (2):
  lustre: libcfs: reduce libcfs checksum speed test time
  lustre: obdclass: improve missing operation message

Andriy Skulysh (1):
  lustre: osc: hung in osc_destroy()

Bruno Faccini (3):
  lustre: obdclass: obdclass module cleanup upon load error
  lustre: obdclass: handle early requests vs CT registering
  lustre: llite: handle client racy case during create

Chris Horn (1):
  lustre: llite: Return -ERESTARTSYS in range_lock()

Di Wang (1):
  lustre: lmv: honour the specified stripe index

Dmitry Eremin (1):
  lustre: clio: remove unused members from struct cl_thread_info

Fan Yong (1):
  lustre: fid: race between client_fid_fini and seq_client_flush

Gu Zheng (1):
  lustre: libcfs: avoid overflow of crypto bandwidth calculation

Hongchao Zhang (1):
  lustre: mgc: relate sptlrpc & param to MGC

James Simmons (1):
  lustre: docs: update TODO file

Jinshan Xiong (1):
  lustre: llite: ignore layout for ll_writepages()

John L. Hammond (5):
  lustre: llite: return small device numbers for compat stat()
  lustre: obd: remove OBD_NOTIFY_SYNC{,_NONBLOCK}
  lustre: obd: remove OBD_NOTIFY_CONFIG
  lustre: obdclass: use static initializer macros where possible
  lustre: obd: remove unused data parameter from obd_notify()

Niu Yawei (4):
  lustre: llite: don't zero timestamps internally
  lustre: config: don't attach sub logs for LWP
  lustre: llite: buggy special handling on MULTIMODRPCS
  lustre: config: move config types into lustre_idl.h

Patrick Farrell (2):
  lustre: osc: Send RPCs when extents are full
  lustre: llite: reduce jobstats race window

Sebastien Buisson (1):
  lustre: obd: add 'network' client mount option

Sonia Sharma (1):
  lustre: lnet: removal of obsolete LNDs

Steve Guminski (2):
  lustre: obd: change positional struct initializers to C99
  lustre: lnet: change positional struct initializers to C99

 drivers/staging/lustre/TODO                        | 51 +-----------
 .../lustre/include/linux/libcfs/libcfs_crypto.h    |  4 +-
 .../lustre/include/uapi/linux/lnet/nidstr.h        | 18 ++---
 .../lustre/include/uapi/linux/lustre/lustre_idl.h  | 10 ++-
 drivers/staging/lustre/lnet/libcfs/linux-crypto.c  | 33 ++++++--
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  9 +--
 drivers/staging/lustre/lnet/lnet/lo.c              | 20 +++--
 drivers/staging/lustre/lnet/lnet/router_proc.c     |  2 +-
 drivers/staging/lustre/lnet/selftest/framework.c   |  2 +-
 drivers/staging/lustre/lustre/fid/fid_request.c    | 21 +++--
 drivers/staging/lustre/lustre/include/cl_object.h  |  1 -
 drivers/staging/lustre/lustre/include/lu_object.h  |  6 --
 .../staging/lustre/lustre/include/lustre_disk.h    |  1 +
 drivers/staging/lustre/lustre/include/lustre_net.h |  3 +-
 drivers/staging/lustre/lustre/include/obd.h        | 10 +--
 drivers/staging/lustre/lustre/include/obd_class.h  | 66 +++++++---------
 .../staging/lustre/lustre/include/obd_support.h    |  4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      | 42 ++++++----
 drivers/staging/lustre/lustre/llite/file.c         | 16 +++-
 drivers/staging/lustre/lustre/llite/lcommon_misc.c | 12 ++-
 .../staging/lustre/lustre/llite/llite_internal.h   | 10 ++-
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 26 +++----
 drivers/staging/lustre/lustre/llite/namei.c        |  9 +--
 drivers/staging/lustre/lustre/llite/range_lock.c   |  2 +-
 drivers/staging/lustre/lustre/llite/rw.c           | 15 ++--
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        | 51 +++++-------
 drivers/staging/lustre/lustre/lov/lov_obd.c        | 63 ++++-----------
 drivers/staging/lustre/lustre/mdc/mdc_request.c    | 17 ++--
 drivers/staging/lustre/lustre/mgc/mgc_request.c    | 47 ++++++-----
 .../staging/lustre/lustre/obdclass/cl_internal.h   | 45 +----------
 drivers/staging/lustre/lustre/obdclass/cl_io.c     | 21 +----
 drivers/staging/lustre/lustre/obdclass/cl_object.c | 16 +---
 drivers/staging/lustre/lustre/obdclass/class_obd.c | 91 +++++++++++++++-------
 drivers/staging/lustre/lustre/obdclass/genops.c    |  5 +-
 .../staging/lustre/lustre/obdclass/kernelcomm.c    |  8 ++
 drivers/staging/lustre/lustre/obdclass/lu_object.c | 15 ----
 .../staging/lustre/lustre/obdclass/lustre_peer.c   | 16 +---
 .../staging/lustre/lustre/obdclass/obd_config.c    | 46 ++++++++++-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c | 38 +++++++++
 drivers/staging/lustre/lustre/osc/osc_cache.c      | 45 +++++++----
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |  2 +-
 drivers/staging/lustre/lustre/osc/osc_object.c     |  4 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    | 18 +++--
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  4 +-
 drivers/staging/lustre/lustre/ptlrpc/events.c      |  4 +
 drivers/staging/lustre/lustre/ptlrpc/import.c      |  5 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 85 ++++++++++++++++++++
 47 files changed, 561 insertions(+), 478 deletions(-)

-- 
1.8.3.1
