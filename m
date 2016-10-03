From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:27:56 -0400
Subject: [lustre-devel] [PATCH 00/41] missing patches for lustre 2.7.50 to
	2.7.55
Message-ID: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Another batch of cleanups and fixes missing up to Lustre
version 2.7.55.

Alex Zhuravlev (1):
  staging: lustre: echo: request pages in batches

Andreas Dilger (1):
  staging: lustre: ptlrpc: remove old protocol compatibility

Bobi Jam (3):
  staging: lustre: llite: remove duplicate fiemap defines
  staging: lustre: clio: get rid of lov_stripe_md reference
  staging: lustre: llite: restart short read/write for normal IO

Bruno Faccini (1):
  staging: lustre: obdclass: fix race during key quiescency

Chris Horn (1):
  staging: lustre: ptlrpc: Move NRS structures out of lustre_net.h

Gregoire Pichon (3):
  staging: lustre: ptlrpc: Add OBD_CONNECT_MULTIMODRPCS flag
  staging: lustre: ptlrpc: Add a tag field to ptlrpc messages
  staging: lustre: mdc: add max modify RPCs in flight variable

Henri Doreau (3):
  staging: lustre: llite: Report first encountered error
  staging: lustre: mdc: Removed unneeded NULL check
  staging: lustre: hsm: Use file lease to implement migration

James Simmons (1):
  staging: lustre: lov: copy_to_user uses wrong casting

Jinshan Xiong (2):
  staging: lustre: clio: Revise read ahead implementation
  staging: lustre: llite: remove lli_has_smd

John L. Hammond (12):
  staging: lustre: llite: remove client Size on MDS support
  staging: lustre: obd: remove client Size on MDS support
  staging: lustre: clio: use CIT_SETATTR for FSFILT_IOC_SETFLAGS
  staging: lustre: remove Size on MDS support
  staging: lustre: obd: remove unused LSM parameters
  staging: lustre: clio: add CIT_DATA_VERSION and remove IOC_LOV_GETINFO
  staging: lustre: lov: add cl_object_layout_get()
  staging: lustre: llite: add cl_object_maxbytes()
  staging: lustre: obd: remove destroy cookie handling
  staging: lustre: lov: use obd_get_info() to get def/max LOV EA sizes
  staging: lustre: osc: remove remaining bits for capa support
  staging: lustre: lov: move LSM to LOV layer

Liang Zhen (1):
  staging: lustre: libcfs: shortcut to create CPT from NUMA topology

Mikhail Pershin (1):
  staging: lustre: hsm: make HSM modification requests replayable

Niu Yawei (2):
  staging: lustre: quota: remove obsolete quota code
  staging: lustre: ldlm: cancel aged locks for LRUR

Patrick Farrell (1):
  staging: lustre: ldlm: Do not use cbpending for group locks

Patrick Valentin (1):
  staging: lustre: obdclass: Add synchro in lu_context_key_degister()

Sebastien Buisson (2):
  staging: lustre: ptlrpc: ret -ECONNREFUSED if not context found in req
  staging: lustre: ptlrpc: dont take unwrap in req_waittime calculation

Vitaly Fertman (1):
  staging: lustre: ldlm: interval tree search in ldlm_lock_match()

Wu Libin (1):
  staging: lustre: osc: fix bug when setting max_pages_per_rpc

frank zago (1):
  staging: lustre: ldlm: remove unnecessary EXPORT_SYMBOL

wang di (2):
  staging: lustre: llite: default dir stripe index only for mkdir
  staging: lustre: mgc: MGC should retry for invalid import

 drivers/staging/lustre/lnet/libcfs/fail.c          |    1 +
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   |   48 +-
 drivers/staging/lustre/lustre/include/cl_object.h  |  113 ++-
 .../lustre/lustre/include/lustre/ll_fiemap.h       |   75 +--
 .../lustre/lustre/include/lustre/lustre_idl.h      |  107 +--
 .../lustre/lustre/include/lustre/lustre_ioctl.h    |    4 +-
 .../lustre/lustre/include/lustre/lustre_user.h     |   24 +-
 .../staging/lustre/lustre/include/lustre_compat.h  |    2 +
 drivers/staging/lustre/lustre/include/lustre_dlm.h |    2 +-
 drivers/staging/lustre/lustre/include/lustre_ha.h  |    1 +
 drivers/staging/lustre/lustre/include/lustre_mdc.h |   20 +-
 drivers/staging/lustre/lustre/include/lustre_net.h |  714 +------------------
 drivers/staging/lustre/lustre/include/lustre_nrs.h |  717 ++++++++++++++++++
 .../lustre/lustre/include/lustre_nrs_fifo.h        |   70 ++
 .../lustre/lustre/include/lustre_req_layout.h      |    6 +-
 drivers/staging/lustre/lustre/include/obd.h        |  174 +----
 drivers/staging/lustre/lustre/include/obd_class.h  |  181 +----
 .../staging/lustre/lustre/include/obd_support.h    |   12 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |   18 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |    7 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |    5 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |  282 +++++---
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |   26 -
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |    6 -
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   11 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    4 -
 drivers/staging/lustre/lustre/llite/Makefile       |    2 +-
 drivers/staging/lustre/lustre/llite/dir.c          |  157 +----
 drivers/staging/lustre/lustre/llite/file.c         |  781 ++++++++------------
 drivers/staging/lustre/lustre/llite/glimpse.c      |  139 ++---
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |   28 +-
 drivers/staging/lustre/lustre/llite/lcommon_misc.c |   37 +-
 drivers/staging/lustre/lustre/llite/llite_close.c  |  395 ----------
 .../staging/lustre/lustre/llite/llite_internal.h   |   87 +--
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  246 ++-----
 drivers/staging/lustre/lustre/llite/namei.c        |    8 -
 drivers/staging/lustre/lustre/llite/rw.c           |  218 ++++---
 drivers/staging/lustre/lustre/llite/rw26.c         |    4 -
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |    3 +-
 drivers/staging/lustre/lustre/llite/vvp_internal.h |   33 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  170 +++--
 drivers/staging/lustre/lustre/llite/vvp_object.c   |   25 +-
 drivers/staging/lustre/lustre/llite/vvp_page.c     |   40 +-
 drivers/staging/lustre/lustre/llite/vvp_req.c      |   13 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |  234 +++---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  198 +-----
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |    1 -
 drivers/staging/lustre/lustre/lov/lov_ea.c         |  195 +++---
 drivers/staging/lustre/lustre/lov/lov_internal.h   |   94 ++-
 drivers/staging/lustre/lustre/lov/lov_io.c         |  109 +++-
 drivers/staging/lustre/lustre/lov/lov_merge.c      |   50 --
 drivers/staging/lustre/lustre/lov/lov_obd.c        |  677 +----------------
 drivers/staging/lustre/lustre/lov/lov_object.c     |  570 ++++++++++++++-
 drivers/staging/lustre/lustre/lov/lov_pack.c       |  184 ++---
 drivers/staging/lustre/lustre/lov/lov_page.c       |   46 --
 drivers/staging/lustre/lustre/lov/lov_request.c    |  292 --------
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c      |   38 +
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |    5 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   57 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |    2 -
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |   62 +--
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |  204 +-----
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |   94 ++-
 drivers/staging/lustre/lustre/obdclass/Makefile    |    2 +-
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |   58 +--
 drivers/staging/lustre/lustre/obdclass/cl_object.c |   61 ++
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |   47 --
 drivers/staging/lustre/lustre/obdclass/genops.c    |   57 ++
 .../lustre/lustre/obdclass/linux/linux-obdo.c      |   80 --
 .../lustre/lustre/obdclass/lprocfs_status.c        |    7 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   63 ++-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |    2 +-
 drivers/staging/lustre/lustre/obdclass/obdo.c      |   65 --
 .../staging/lustre/lustre/obdecho/echo_client.c    |  102 +--
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |    3 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |    3 +-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |    1 -
 drivers/staging/lustre/lustre/osc/osc_internal.h   |   32 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |  184 +++++-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |   14 +-
 drivers/staging/lustre/lustre/osc/osc_object.c     |   91 +++-
 drivers/staging/lustre/lustre/osc/osc_page.c       |   20 -
 drivers/staging/lustre/lustre/osc/osc_quota.c      |   44 --
 drivers/staging/lustre/lustre/osc/osc_request.c    |  363 +--------
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    8 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |   25 +-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |   36 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   57 ++-
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |  248 +++----
 90 files changed, 3936 insertions(+), 5867 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/include/lustre_nrs.h
 create mode 100644 drivers/staging/lustre/lustre/include/lustre_nrs_fifo.h
 delete mode 100644 drivers/staging/lustre/lustre/llite/llite_close.c
 delete mode 100644 drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
