From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 18:20:52 -0400
Subject: [lustre-devel] [PATCH 00/15] patches missing from lustre 2.5.51
Message-ID: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

This is the collection of bug fixes and code cleanup that are
missing from the upstream client that exist with lustre
version 2.5.51.

Andreas Dilger (1):
  staging: lustre: ptlrpc: quiet warning for 2.1/2.5 connections

Bruce Korb (4):
  staging: lustre: ldlm: use accessor macros for l_flags
  staging: lustre: ldlm: clean up l_flags
  staging: lustre: ldlm: remove code wireshark handling
  staging: lustre: ldlm: update comments about ldlm l_flags

Dmitry Eremin (2):
  staging: lustre: llite: NFS reexport issue
  staging: lustre: lmv: kernel crash due to misconfigured MDT

James Nunez (1):
  staging: lustre: llite: Replace printing of i_ino with ll_inode2fid()

Jinshan Xiong (1):
  staging: lustre: llite: reset writeback index in ll_writepages

Niu Yawei (1):
  staging: lustre: clio: add debug message in osc_completion()

Prakash Surya (3):
  staging: lustre: osc: Track and limit "unstable" pages
  staging: lustre: osc: Track number of "unstable" pages per osc
  staging: lustre: osc: Use SOFT_SYNC to urge server commit

Sebastien Buisson (1):
  staging: lustre: mgc: fix 'error handling' issues

Wang Di (1):
  staging: lustre: obdclass: add LCT_SERVER_SESSION for server session

 drivers/staging/lustre/lustre/include/cl_object.h  |   10 ++
 drivers/staging/lustre/lustre/include/lu_object.h  |    4 +
 .../lustre/lustre/include/lustre/lustre_idl.h      |    5 +
 .../lustre/lustre/include/lustre_dlm_flags.h       |  120 ++--------------
 drivers/staging/lustre/lustre/include/lustre_net.h |    4 +-
 drivers/staging/lustre/lustre/include/obd.h        |    3 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |    2 +-
 .../staging/lustre/lustre/include/obd_support.h    |    1 +
 drivers/staging/lustre/lustre/ldlm/l_lock.c        |    4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |    4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |   11 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |    7 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |    1 +
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   96 ++++++-------
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |   28 ++--
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   34 ++---
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   12 +-
 drivers/staging/lustre/lustre/llite/dcache.c       |   15 +--
 drivers/staging/lustre/lustre/llite/dir.c          |   23 ++--
 drivers/staging/lustre/lustre/llite/file.c         |   76 +++++-----
 drivers/staging/lustre/lustre/llite/llite_close.c  |   40 +++---
 .../staging/lustre/lustre/llite/llite_internal.h   |   16 ++-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   60 +++++---
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |    6 +-
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |   16 ++-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |   18 +++
 drivers/staging/lustre/lustre/llite/namei.c        |   78 +++++------
 drivers/staging/lustre/lustre/llite/rw.c           |    5 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |    5 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |   17 +--
 drivers/staging/lustre/lustre/llite/symlink.c      |   10 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |    5 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |   20 ++--
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  151 ++++++++++++--------
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    6 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    2 +
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |   18 +++
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  142 ++++++++++++++++--
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    4 +
 drivers/staging/lustre/lustre/osc/osc_lock.c       |    2 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |   29 ++++
 drivers/staging/lustre/lustre/osc/osc_request.c    |   31 ++++-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |   11 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |    3 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |    6 +
 45 files changed, 682 insertions(+), 479 deletions(-)
