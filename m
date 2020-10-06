From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:05:39 -0400
Subject: [lustre-devel] [PATCH 00/42] lustre: OpenSFS backport for Oct 4 2020
Message-ID: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Backport of various patches from the OpenSFS tree. Only the fscrypto
has been held back. Some fixes are needed for PCC as well.

Alexander Boyko (1):
  lustre: llite: add test to check client deadlock selinux

Alexander Zarochentsev (1):
  lustre: mdc: fix lovea for replay

Alexey Lyashkov (1):
  lustre: ldlm: don't use a locks without l_ast_data

Amir Shehata (1):
  lustre: mgc: Use IR for client->MDS/OST connections

Andreas Dilger (4):
  lustre: ptlrpc: don't require CONFIG_CRYPTO_CRC32
  lustre: llite: return -ENODATA if no default layout
  lustre: ptlrpc: prefer crc32_le() over CryptoAPI
  lustre: llite: increase readahead default values

Chris Horn (5):
  lnet: Do not set preferred NI for MR peer
  lnet: Conditionally attach rspt in LNetPut & LNetGet
  lnet: Loosen restrictions on LNet Health params
  lnet: Fix reference leak in lnet_select_pathway
  lnet: Do not overwrite destination when routing

James Simmons (1):
  lnet: don't read debugfs lnet stats when shutting down

Jinshan Xiong (1):
  lustre: ldlm: control lru_size for extent lock

Lai Siyao (2):
  lustre: llite: prune invalid dentries
  lustre: obdclass: don't initialize obj for zero FID

Mikhail Pershin (2):
  lustre: dom: lock cancel to drop pages
  lustre: osc: don't allow negative grants

Mr NeilBrown (10):
  lustre: lov: make various lov_object.c function static.
  lustre: sec: use memchr_inv() to check if page is zero.
  lnet: use init_wait(), not init_waitqueue_entry()
  lnet: libcfs: don't save journal_info in dumplog thread.
  lnet: call event handlers without res_lock
  lnet: Support checking for MD leaks.
  lustre: lov: don't use inline for operations functions.
  lustre: lov: discard unused lov_dump_lmm* functions
  lustre: lov: guard against class_exp2obd() returning NULL.
  lustre: don't take spinlock to read a 'long'.

NeilBrown (1):
  lustre: obdclass: fixes and improvements for jobid.

Oleg Drokin (1):
  lustre: update version to 2.13.56

Patrick Farrell (1):
  lustre: osc: Do ELC on locks with no OSC object

Serguei Smirnov (1):
  lnet: deadlock on LNet shutdown

Shaun Tancheff (1):
  lustre: llite: it_lock_bits should be bit-wise tested

Vitaly Fertman (4):
  lustre: ldlm: lru code cleanup
  lustre: ldlm: cancel LRU improvement
  lustre: ldlm: pool fixes
  lustre: ldlm: pool recalc forceful call

Wang Shilong (4):
  lustre: llite: reuse same cl_dio_aio for one IO
  lustre: llite: move iov iter forward by ourself
  lustre: llite: report client stats sumsq
  lustre: clio: don't call aio_complete() in lustre upon errors

 fs/lustre/Kconfig                      |   3 -
 fs/lustre/include/cl_object.h          |   1 +
 fs/lustre/include/lustre_dlm.h         |  72 +++++++--
 fs/lustre/include/lustre_net.h         |   6 +-
 fs/lustre/include/lustre_osc.h         |   4 +
 fs/lustre/include/obd.h                |   9 +-
 fs/lustre/include/obd_cksum.h          |  20 +--
 fs/lustre/include/obd_class.h          |   2 +
 fs/lustre/include/obd_support.h        |   1 +
 fs/lustre/ldlm/ldlm_internal.h         |  22 +--
 fs/lustre/ldlm/ldlm_lib.c              |  44 ++++++
 fs/lustre/ldlm/ldlm_lock.c             |  32 ++--
 fs/lustre/ldlm/ldlm_lockd.c            |  13 +-
 fs/lustre/ldlm/ldlm_pool.c             | 151 +++++++++++--------
 fs/lustre/ldlm/ldlm_request.c          | 268 +++++++++++++++------------------
 fs/lustre/ldlm/ldlm_resource.c         |  79 ++++++++--
 fs/lustre/llite/dcache.c               |  15 +-
 fs/lustre/llite/dir.c                  |  11 +-
 fs/lustre/llite/file.c                 | 141 +++++++++++------
 fs/lustre/llite/llite_internal.h       |  24 +--
 fs/lustre/llite/llite_lib.c            |   8 +-
 fs/lustre/llite/lproc_llite.c          |  31 +---
 fs/lustre/llite/namei.c                |  57 ++++---
 fs/lustre/llite/rw26.c                 |   5 +
 fs/lustre/llite/vvp_io.c               |  20 +--
 fs/lustre/lov/lov_cl_internal.h        |  12 --
 fs/lustre/lov/lov_ea.c                 |  33 +++-
 fs/lustre/lov/lov_internal.h           |   1 -
 fs/lustre/lov/lov_obd.c                |   7 +-
 fs/lustre/lov/lov_object.c             |  19 +--
 fs/lustre/lov/lov_pack.c               |  17 +--
 fs/lustre/lov/lovsub_object.c          |   4 +-
 fs/lustre/mdc/lproc_mdc.c              |   7 +-
 fs/lustre/mdc/mdc_dev.c                |  27 +++-
 fs/lustre/mdc/mdc_locks.c              |  37 ++---
 fs/lustre/mdc/mdc_request.c            |   6 +
 fs/lustre/mgc/lproc_mgc.c              |  30 ++++
 fs/lustre/mgc/mgc_request.c            |  58 +++++--
 fs/lustre/obdclass/cl_io.c             |   3 +-
 fs/lustre/obdclass/integrity.c         |   8 +-
 fs/lustre/obdclass/jobid.c             |  14 +-
 fs/lustre/obdclass/lu_object.c         |   7 +
 fs/lustre/obdclass/lustre_peer.c       |  37 ++++-
 fs/lustre/obdclass/obd_cksum.c         |   6 +-
 fs/lustre/osc/lproc_osc.c              |  23 +--
 fs/lustre/osc/osc_cache.c              |   2 +-
 fs/lustre/osc/osc_internal.h           |   3 +-
 fs/lustre/osc/osc_lock.c               |  14 +-
 fs/lustre/osc/osc_object.c             |   2 +-
 fs/lustre/osc/osc_request.c            |  41 +++--
 fs/lustre/ptlrpc/events.c              |   1 +
 fs/lustre/ptlrpc/pack_generic.c        |  18 ++-
 fs/lustre/ptlrpc/sec_null.c            |  10 +-
 fs/lustre/ptlrpc/sec_plain.c           |  26 +---
 include/linux/lnet/api.h               |   2 +
 include/linux/lnet/lib-lnet.h          |  25 ++-
 include/linux/lnet/lib-types.h         |   9 ++
 include/uapi/linux/lustre/lustre_idl.h |   2 +-
 include/uapi/linux/lustre/lustre_ver.h |   4 +-
 net/lnet/libcfs/debug.c                |   7 +-
 net/lnet/libcfs/tracefile.c            |   2 +-
 net/lnet/libcfs/tracefile.h            |   1 -
 net/lnet/lnet/api-ni.c                 |  86 ++++++-----
 net/lnet/lnet/lib-md.c                 |  45 +++++-
 net/lnet/lnet/lib-move.c               | 145 ++++++++++++------
 net/lnet/lnet/lib-msg.c                |  36 +++--
 net/lnet/lnet/peer.c                   |   1 +
 net/lnet/lnet/router_proc.c            |  17 +--
 net/lnet/selftest/rpc.c                |   1 +
 69 files changed, 1180 insertions(+), 715 deletions(-)

-- 
1.8.3.1
