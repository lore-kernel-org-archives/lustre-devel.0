From: James Simmons <jsimmons@infradead.org>
Date: Wed,  1 Jul 2020 20:04:40 -0400
Subject: [lustre-devel] [PATCH 00/18] Port of OpenSFS landing as of July 1,
 2020
Message-ID: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Port of patches that landed to the OpenSFS branch. A few patches added
the were missing that enables potential lustre utilities building
against the Linux client. Please review to make sure everything is
okay.

Alexander Boyko (1):
  lustre: llite: don't hold inode_lock for security notify

Alexey Lyashkov (2):
  lnet: restore an maximal fragments count
  lnet: o2ib: fix page mapping error

Amir Shehata (1):
  lnet: handle undefined parameters

Andriy Skulysh (1):
  lustre: llite: truncate deadlock with DoM files

Chris Horn (1):
  lnet: Skip health and resends for single rail configs

Emoly Liu (1):
  lustre: obd: add new LPROCFS_TYPE_*

Gregoire Pichon (1):
  lnet: define new network driver ptl4lnd

Hongchao Zhang (1):
  lustre: mdc: chlg device could be used after free

James Simmons (2):
  lustre: llite: bind kthread thread to accepted node set
  lustre: lov: use lov_pattern_support() to verify lmm

Lai Siyao (1):
  lustre: mdt: don't fetch LOOKUP lock for remote object

Mikhail Pershin (1):
  lustre: ptlrpc: limit rate of lock replays

Sebastien Buisson (5):
  lustre: sec: encryption for write path
  lustre: sec: decryption for read path
  lustre: sec: deal with encrypted object size
  lustre: sec: support truncate for encrypted files
  lustre: sec: ioctls to handle encryption policies

 fs/lustre/include/lprocfs_status.h         |   9 +-
 fs/lustre/include/lustre_import.h          |   2 +
 fs/lustre/include/lustre_osc.h             |   1 +
 fs/lustre/include/obd.h                    |  19 ++-
 fs/lustre/include/obd_class.h              |   3 +-
 fs/lustre/include/obd_support.h            |   5 +
 fs/lustre/ldlm/ldlm_request.c              |  69 ++++++++++-
 fs/lustre/llite/crypto.c                   |  15 ++-
 fs/lustre/llite/dir.c                      |  50 +++++++-
 fs/lustre/llite/file.c                     |  19 ++-
 fs/lustre/llite/llite_internal.h           |   1 +
 fs/lustre/llite/llite_lib.c                | 187 ++++++++++++++++++++++++++++-
 fs/lustre/llite/lproc_llite.c              |   8 +-
 fs/lustre/llite/namei.c                    | 105 +++++++++++++---
 fs/lustre/llite/rw.c                       |  13 +-
 fs/lustre/llite/rw26.c                     |   4 +
 fs/lustre/llite/statahead.c                |  11 +-
 fs/lustre/llite/vvp_io.c                   |  17 ++-
 fs/lustre/lmv/lmv_intent.c                 |  19 ++-
 fs/lustre/lmv/lmv_internal.h               |   1 +
 fs/lustre/lmv/lmv_obd.c                    |   3 +-
 fs/lustre/lov/lov_ea.c                     |   6 +-
 fs/lustre/mdc/mdc_changelog.c              |  46 ++++---
 fs/lustre/mdc/mdc_internal.h               |   1 +
 fs/lustre/mdc/mdc_request.c                |   8 +-
 fs/lustre/obdclass/genops.c                |   1 +
 fs/lustre/obdecho/echo_client.c            |   2 +
 fs/lustre/obdecho/echo_internal.h          |   3 +
 fs/lustre/osc/osc_internal.h               |   1 +
 fs/lustre/osc/osc_request.c                | 121 ++++++++++++++++++-
 fs/lustre/ptlrpc/import.c                  |   8 +-
 include/linux/lnet/lib-lnet.h              |   4 +-
 include/linux/lnet/lib-types.h             |   2 +-
 include/uapi/linux/lnet/nidstr.h           |   1 +
 include/uapi/linux/lustre/lustre_user.h    |   8 ++
 net/lnet/klnds/o2iblnd/o2iblnd.c           |   7 +-
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c        |   3 +-
 net/lnet/klnds/o2iblnd/o2iblnd_modparams.c |   4 +-
 net/lnet/klnds/socklnd/socklnd_modparams.c |   4 +-
 net/lnet/lnet/api-ni.c                     |  26 +++-
 net/lnet/lnet/lib-msg.c                    |  65 +++++++---
 net/lnet/lnet/nidstrings.c                 |   9 ++
 42 files changed, 759 insertions(+), 132 deletions(-)

-- 
1.8.3.1
