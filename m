From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:28 -0500
Subject: [lustre-devel] [PATCH 00/60] staging: lustre: batches of fixes for
	lustre client
Message-ID: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Batch of missing fixes for lustre for the upstream client.

Alex Zhuravlev (1):
  staging: lustre: obdclass: do not call lu_site_purge() for single object exceed

Alexander Boyko (1):
  staging: lustre: ptlrpc: skip lock if export failed

Andreas Dilger (3):
  staging: lustre: mdc: quiet console message for known -EINTR
  staging: lustre: obdclass: add more info to sysfs version string
  staging: lustre: llite: handle inactive OSTs better in statfs

Andriy Skulysh (1):
  staging: lustre: ldlm: ASSERTION(flock->blocking_export!=0) failed

Ann Koehler (1):
  staging: lustre: obd: RCU stalls in lu_cache_shrink_count()

Ben Evans (1):
  staging: lustre: lustre: Remove old commented out code

Bobi Jam (3):
  staging: lustre: clio: add cl_page LRU shrinker
  staging: lustre: lov: ld_target could be NULL
  staging: lustre: llite: specify READA debug mask for ras_update

Bruno Faccini (1):
  staging: lustre: obdclass: health_check to report unhealthy upon LBUG

Dmitry Eremin (6):
  staging: lustre: llite: Setting xattr are properly checked with and without ACLs
  staging: lustre: libcfs: avoid stomping on module param cpu_pattern
  staging: lustre: libcfs: default CPT matches NUMA topology
  staging: lustre: libcfs: fix error messages
  staging: lustre: ptlrpc: remove unused pc->pc_env
  staging: lustre: ptlrpc: update MODULE_PARAM_DESC in ptlrpcd.c

Fan Yong (4):
  staging: lustre: fid: fix race in fid allocation
  staging: lustre: mgc: handle config_llog_data::cld_refcount properly
  staging: lustre: ptlrpc: comment for FLD_QUERY RPC reply swab
  staging: lustre: linkea: linkEA size limitation

Giuseppe Di Natale (1):
  staging: lustre: lmv: Correctly generate target_obd

James Simmons (7):
  staging: lustre: header: remove assert from interval_set()
  staging: libcfs: remove integer types abstraction from libcfs
  staging: lustre: socklnd: remove socklnd_init_msg
  staging: lustre: obd: move s3 in lmd_parse to inner loop
  staging: lustre: osc: avoid 64 divide in osc_cache_too_much
  staging: lustre: ptlrpc : remove userland usage from ptlrpc
  staging: lustre: libcfs: fix minimum size check for libcfs ioctl

Jeremy Filizetti (1):
  staging: lustre: ldlm: Restore connect flags on failure

Jinshan Xiong (4):
  staging: lustre: llite: Remove access of stripe in ll_setattr_raw
  staging: lustre: clio: revise readahead to support 16MB IO
  staging: lustre: llite: don't ignore layout for group lock request
  staging: lustre: osc: limits the number of chunks in write RPC

John L. Hammond (5):
  staging: lustre: llite: remove obsolete comment for ll_unlink()
  staging: lustre: ptlrpc: correct use of list_add_tail()
  staging: lustre: lmv: remove unused placement parameter
  staging: lustre: obd: remove OBD_NOTIFY_CREATE
  staging: lustre: mdc: avoid returning freed request

Lai Siyao (2):
  staging: lustre: statahead: drop support for remote entry
  staging: lustre: llite: normal user can't set FS default stripe

Liang Zhen (1):
  staging: lustre: ksocklnd: ignore timedout TX on closing connection

Nathaniel Clark (1):
  staging: lustre: lov: Ensure correct operation for large object sizes

Niu Yawei (4):
  staging: lustre: ptlrpc: set proper mbits for EINPROGRESS resend
  staging: lustre: clio: sync write should update mtime
  staging: ptlrpc: leaked rs on difficult reply
  staging: lustre: ptlrpc: update replay cursor when close during replay

Oleg Drokin (1):
  staging: lustre: llite: Trust creates in revalidate too.

Patrick Farrell (1):
  staging: lustre: mdc: Make IT_OPEN take lookup bits lock

Rahul Deshmukh (1):
  staging: lustre: llite: Adding timed wait in ll_umount_begin

Steve Guminski (3):
  staging: lustre: osc: osc_match_base prototype differs from declaration
  staging: lustre: libcfs: Change positional struct initializers to C99
  staging: lustre: fid: Change positional struct initializers to C99

Ulka Vaze (1):
  staging: lustre: lmv: Error not handled for lmv_find_target

Vladimir Saveliev (1):
  staging: lustre: ptlrpc: allow blocking asts to be delayed

Yang Sheng (1):
  staging: lustre: llite: don't invoke direct_IO for the EOF case

frank zago (1):
  staging: lustre: hsm: stack overrun in hai_dump_data_field

wang di (2):
  staging: lustre: llite: check request != NULL in ll_migrate
  staging: lustre: lmv: remove nlink check in lmv_revalidate_slaves

 .../lustre/include/linux/libcfs/libcfs_crypto.h    |  60 +++++--
 .../lustre/include/linux/libcfs/linux/libcfs.h     |   4 -
 .../staging/lustre/include/linux/lnet/socklnd.h    |   9 -
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |  29 +--
 drivers/staging/lustre/lnet/libcfs/debug.c         |   2 +-
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   |  17 +-
 .../lustre/lnet/libcfs/linux/linux-module.c        |   2 +-
 drivers/staging/lustre/lnet/libcfs/workitem.c      |   2 +-
 drivers/staging/lustre/lnet/lnet/acceptor.c        |   4 +-
 drivers/staging/lustre/lnet/selftest/module.c      |   3 +-
 drivers/staging/lustre/lustre/fid/fid_lib.c        |   7 +-
 drivers/staging/lustre/lustre/fid/fid_request.c    |  55 +++---
 drivers/staging/lustre/lustre/fid/lproc_fid.c      |  12 +-
 drivers/staging/lustre/lustre/include/cl_object.h  |  10 +-
 .../staging/lustre/lustre/include/interval_tree.h  |  12 +-
 drivers/staging/lustre/lustre/include/lu_object.h  |  14 +-
 .../lustre/lustre/include/lustre/lustre_idl.h      |   5 +-
 .../lustre/lustre/include/lustre/lustre_user.h     |  18 +-
 .../staging/lustre/lustre/include/lustre_linkea.h  |  15 +-
 drivers/staging/lustre/lustre/include/lustre_net.h |   4 -
 .../lustre/lustre/include/lustre_req_layout.h      |  10 +-
 drivers/staging/lustre/lustre/include/obd.h        |  18 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |   5 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |   6 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |   1 -
 .../staging/lustre/lustre/ldlm/ldlm_inodebits.c    |   1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |  13 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   7 +
 drivers/staging/lustre/lustre/llite/dcache.c       |  13 +-
 drivers/staging/lustre/lustre/llite/dir.c          |  14 +-
 drivers/staging/lustre/lustre/llite/file.c         |  83 +++++----
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |   9 +-
 drivers/staging/lustre/lustre/llite/lcommon_misc.c |   2 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |  16 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 124 ++++++-------
 drivers/staging/lustre/lustre/llite/namei.c        |   5 -
 drivers/staging/lustre/lustre/llite/range_lock.c   |  10 +-
 drivers/staging/lustre/lustre/llite/range_lock.h   |   2 +-
 drivers/staging/lustre/lustre/llite/rw.c           | 199 ++++++++++-----------
 drivers/staging/lustre/lustre/llite/rw26.c         |   4 +
 drivers/staging/lustre/lustre/llite/statahead.c    |  94 ++++------
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  17 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |   9 +
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |  16 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  65 ++++---
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c      |  85 ++-------
 drivers/staging/lustre/lustre/lov/lov_ea.c         |  22 +--
 drivers/staging/lustre/lustre/lov/lov_io.c         |   7 +-
 drivers/staging/lustre/lustre/lov/lov_lock.c       |   5 +
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   2 -
 drivers/staging/lustre/lustre/lov/lov_object.c     |  33 +++-
 drivers/staging/lustre/lustre/lov/lov_request.c    |   6 +-
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |   3 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |  18 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   9 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    | 183 ++++++++++---------
 drivers/staging/lustre/lustre/obdclass/linkea.c    |  70 ++++++--
 .../lustre/lustre/obdclass/linux/linux-module.c    |   8 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c | 106 +++++------
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   3 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      | 125 +++++++++----
 drivers/staging/lustre/lustre/osc/osc_internal.h   |  15 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |  15 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |  98 +++++++++-
 drivers/staging/lustre/lustre/osc/osc_request.c    |  21 +++
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  24 ++-
 drivers/staging/lustre/lustre/ptlrpc/events.c      |   3 +-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |  26 ++-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |   5 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |  18 +-
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |  24 +--
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |   2 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |  21 +--
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |  16 +-
 76 files changed, 1136 insertions(+), 868 deletions(-)

-- 
1.8.3.1
