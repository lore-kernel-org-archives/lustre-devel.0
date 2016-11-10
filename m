From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:30 -0500
Subject: [lustre-devel] [PATCH 00/35] second batch of missing lustre 2.8
	patches
Message-ID: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

More fixes missing from the upstream client. Also a nice cleanup
with the removal of cl_req which is no longer needed. More cleanup
for lustre_idl.h which is a uapi header. Like the last batch these
patches are independent of order.

Aditya Pandit (1):
  staging: lustre: llite: tar restore fails for HSM released files.

Alexander Boyko (1):
  staging: lustre: ptlrpc: race at req processing

Andreas Dilger (4):
  staging: lustre: obdclass: remove structure holes to reduce memory
  staging: lustre: mdc: remove console spew from mdc_ioc_fid2path
  staging: lustre: misc: clean up DFID related error messages
  staging: lustre: idl: clean up file attribute flags

Andrew Wellington (1):
  staging: lustre: llite: support SELinux context labelling

Ben Evans (1):
  staging: lustre: ptlrpc: Move IT_* definitions to lustre_idl.h

Bobi Jam (1):
  staging: lustre: lov: init LOV stripe type beforehand

Chennaiah Palla (1):
  staging: lustre: obdclass: add export for lprocfs_stats_alloc_one()

Gregoire Pichon (1):
  staging: lustre: osc: fix max_dirty_mb tunable setting limit

Henri Doreau (3):
  staging: lustre: hsm: Use file lease to implement migration
  staging: lustre: nrs: serialize executions of nrs_policy_stop
  staging: lustre: obd: Remove dead code in precleanup

Hiroya Nozaki (1):
  staging: lustre: llite: ll_write_begin/end not passing on errors

Hongchao Zhang (1):
  staging: lustre: ptlrpc: reset imp_replay_cursor

Jian Yu (1):
  staging: lustre: mount: fix lmd_parse() to handle commas in expr_list

Jinshan Xiong (4):
  staging: lustre: osc: Performance tune for LRU
  staging: lustre: clio: get rid of cl_req
  staging: lustre: osc: osc_extent should hold refcount to osc_object
  staging: lustre: osc: Do not merge extents with partial pages

John L. Hammond (4):
  staging: lustre: obd: rename obd_unpackmd() to md_unpackmd()
  staging: lustre: lov: avoid infinite loop in lsm_alloc_plain()
  staging: lustre: ldlm: improve lock timeout messages
  staging: lustre: hsm: prevent migration of HSM archived files

Lai Siyao (1):
  staging: lustre: statahead: lock leaks if statahead file recreated

Liang Zhen (2):
  staging: lustre: ptlrpc: mbits is sent within ptlrpc_body
  staging: lustre: lnet: add offset for selftest brw

Mikhail Pershin (1):
  staging: lustre: llog: fix wrong offset in llog_process_thread()

Oleg Drokin (1):
  staging: lustre: osc: Remove remains of osc_ast_guard

wang di (5):
  staging: lustre: lmv: lock necessary part of lmv_add_target
  staging: lustre: mgc: IR log failure should not stop mount
  staging: lustre: lmv: revalidate the dentry for striped dir
  staging: lustre: llite: lookup master inode by ilookup5_nowait
  staging: lustre: llite: clear dir stripe md in ll_iget

 drivers/staging/lustre/include/linux/lnet/lnetst.h |    2 +
 drivers/staging/lustre/lnet/selftest/brw_test.c    |   73 ++++---
 drivers/staging/lustre/lnet/selftest/conrpc.c      |    8 +-
 drivers/staging/lustre/lnet/selftest/framework.c   |    2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |   19 +-
 drivers/staging/lustre/lnet/selftest/rpc.h         |    2 +-
 drivers/staging/lustre/lnet/selftest/selftest.h    |    5 +-
 drivers/staging/lustre/lustre/fld/fld_internal.h   |    5 -
 drivers/staging/lustre/lustre/fld/fld_request.c    |    8 -
 drivers/staging/lustre/lustre/include/cl_object.h  |  242 ++------------------
 .../lustre/lustre/include/lustre/lustre_idl.h      |   53 ++++-
 .../lustre/lustre/include/lustre/lustre_user.h     |   19 +-
 drivers/staging/lustre/lustre/include/lustre_dlm.h |    2 +-
 drivers/staging/lustre/lustre/include/lustre_fld.h |    2 -
 drivers/staging/lustre/lustre/include/lustre_lmv.h |   13 +-
 drivers/staging/lustre/lustre/include/lustre_net.h |   12 +-
 .../lustre/lustre/include/lustre_req_layout.h      |    2 +-
 drivers/staging/lustre/lustre/include/obd.h        |  104 +++++----
 drivers/staging/lustre/lustre/include/obd_class.h  |   68 ++----
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    6 +-
 drivers/staging/lustre/lustre/llite/Makefile       |    2 +-
 drivers/staging/lustre/lustre/llite/file.c         |  237 ++++++++++++-------
 .../staging/lustre/lustre/llite/llite_internal.h   |   12 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   55 ++++-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |    4 -
 drivers/staging/lustre/lustre/llite/namei.c        |   46 ++++-
 drivers/staging/lustre/lustre/llite/rw26.c         |    5 +
 drivers/staging/lustre/lustre/llite/statahead.c    |    2 +
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |   12 -
 drivers/staging/lustre/lustre/llite/vvp_internal.h |    8 -
 drivers/staging/lustre/lustre/llite/vvp_io.c       |   78 +++++--
 drivers/staging/lustre/lustre/llite/vvp_object.c   |   23 ++-
 drivers/staging/lustre/lustre/llite/vvp_req.c      |  115 ---------
 drivers/staging/lustre/lustre/llite/xattr.c        |   61 +++++-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |   11 +-
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |    3 -
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  122 ++++------
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |   26 --
 drivers/staging/lustre/lustre/lov/lov_dev.c        |   52 -----
 drivers/staging/lustre/lustre/lov/lov_ea.c         |   14 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h   |    5 +
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   24 --
 drivers/staging/lustre/lustre/lov/lov_object.c     |    1 +
 drivers/staging/lustre/lustre/lov/lovsub_dev.c     |   61 -----
 drivers/staging/lustre/lustre/lov/lovsub_object.c  |   22 ++-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   34 ++--
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   52 ++---
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |   55 +++--
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |  231 +------------------
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |   19 +--
 drivers/staging/lustre/lustre/obdclass/llog.c      |   81 +++++--
 .../lustre/lustre/obdclass/lprocfs_status.c        |    2 +
 .../staging/lustre/lustre/obdclass/obd_config.c    |    2 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   96 +++++++-
 .../staging/lustre/lustre/obdecho/echo_client.c    |    4 -
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |    8 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   56 ++---
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   44 ++---
 drivers/staging/lustre/lustre/osc/osc_dev.c        |   15 +--
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    7 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |  146 +-----------
 drivers/staging/lustre/lustre/osc/osc_object.c     |   82 ++++++-
 drivers/staging/lustre/lustre/osc/osc_page.c       |  146 +++++++-----
 drivers/staging/lustre/lustre/osc/osc_quota.c      |    4 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |  207 ++++++-----------
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   76 ++++---
 drivers/staging/lustre/lustre/ptlrpc/import.c      |    1 +
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |   10 +-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |   63 +++---
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         |   16 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   20 ++-
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |    1 +
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |   52 ++++-
 74 files changed, 1387 insertions(+), 1795 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/llite/vvp_req.c
