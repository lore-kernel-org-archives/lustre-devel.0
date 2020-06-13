From: James Simmons <jsimmons@infradead.org>
Date: Sat, 13 Jun 2020 12:26:56 -0400
Subject: [lustre-devel] [PATCH 00/20] lustre: patches landed for week of
 June 8 2020
Message-ID: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Several patches from Neil tree to address bugs specific to linux
client. Backport patches from OpenSFS tree for the week of June 8
2020 and a few to support building the Lustre utilities.

Alexey Lyashkov (2):
  lustre: ptlrpc: separate number MD and refrences for bulk
  lustre: ptlrpc: fill md correctly.

Andreas Dilger (1):
  lustre: mdc: allow setting max_mod_rpcs_in_flight larger

Bobi Jam (1):
  lustre: llite: don't check mirror info for page discard

Chris Horn (1):
  lustre: ptlrpc: Clear bd_registered in ptlrpc_unregister_bulk

Di Wang (1):
  lustre: uapi: change LUSTRE_*_FL defines to enum

Lai Siyao (2):
  lustre: lmv: check stripe FID sanity
  lustre: dne: directory restripe and auto split

Mr NeilBrown (1):
  lnet: fix uninitialize var in choose_ipv4_src()

NeilBrown (5):
  lnet: fix kmalloc size in config.c
  lnet: test against LNET_STATE_RUNNING rather than LNET_STATE_SHUTDOWN
  lnet: use lnet_md_free in lnet_res_container_cleanup()
  lustre: obdclass: discard process_quota_config
  lnet: socklnd: remove comments about "darwin".

Patrick Farrell (2):
  lustre: SEL: Add flag & setstripe support
  lustre: obd: Rename OS_STATE flags to OS_STATFS

Sebastien Buisson (3):
  lustre: sec: documentation for client-side encryption
  lustre: sec: enable client side encryption
  lustre: sec: control client side encryption

Sonia Sharma (1):
  lnet: o2iblnd: 'Timed out tx' error message

 .../client_side_encryption/access_semantics.txt    | 128 +++++++++++++++++
 .../client_side_encryption/key_hierarchy.txt       | 112 +++++++++++++++
 .../lustre/client_side_encryption/modes_usage.txt  |  97 +++++++++++++
 .../lustre/client_side_encryption/threat_model.txt | 159 +++++++++++++++++++++
 fs/lustre/include/lustre_crypto.h                  | 106 ++++++++++++++
 fs/lustre/include/lustre_lmv.h                     |  20 ++-
 fs/lustre/include/lustre_net.h                     |   9 +-
 fs/lustre/include/obd_class.h                      |   4 +-
 fs/lustre/include/obd_support.h                    |   7 +
 fs/lustre/llite/Makefile                           |   1 +
 fs/lustre/llite/crypto.c                           | 132 +++++++++++++++++
 fs/lustre/llite/dir.c                              |  25 +---
 fs/lustre/llite/llite_internal.h                   |  43 ++++++
 fs/lustre/llite/llite_lib.c                        |  58 +++++++-
 fs/lustre/llite/super25.c                          |   1 +
 fs/lustre/lmv/lmv_obd.c                            |   6 +-
 fs/lustre/lov/lov_io.c                             |   9 +-
 fs/lustre/obdclass/genops.c                        |  50 +++++--
 fs/lustre/obdclass/obd_config.c                    |  10 --
 fs/lustre/ptlrpc/client.c                          |  24 +++-
 fs/lustre/ptlrpc/events.c                          |   6 +-
 fs/lustre/ptlrpc/niobuf.c                          |  40 +++---
 fs/lustre/ptlrpc/pers.c                            |  20 ++-
 fs/lustre/ptlrpc/wiretest.c                        |  29 ++--
 include/uapi/linux/lustre/lustre_idl.h             |  60 ++++++--
 include/uapi/linux/lustre/lustre_user.h            |  28 ++--
 net/lnet/klnds/o2iblnd/o2iblnd.h                   |   2 +
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c                |  26 +++-
 net/lnet/klnds/socklnd/socklnd_cb.c                |   8 --
 net/lnet/lnet/api-ni.c                             |  10 +-
 net/lnet/lnet/config.c                             |   6 +-
 net/lnet/lnet/lib-socket.c                         |   2 +-
 net/lnet/lnet/peer.c                               |   6 +-
 33 files changed, 1091 insertions(+), 153 deletions(-)
 create mode 100644 Documentation/lustre/client_side_encryption/access_semantics.txt
 create mode 100644 Documentation/lustre/client_side_encryption/key_hierarchy.txt
 create mode 100644 Documentation/lustre/client_side_encryption/modes_usage.txt
 create mode 100644 Documentation/lustre/client_side_encryption/threat_model.txt
 create mode 100644 fs/lustre/include/lustre_crypto.h
 create mode 100644 fs/lustre/llite/crypto.c

-- 
1.8.3.1
