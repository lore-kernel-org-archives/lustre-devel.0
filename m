From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Fri,  1 Apr 2016 15:18:00 -0400
Subject: [lustre-devel] [PATCH 0/3] A few more Lustre styel cleanups
Message-ID: <1459538283-3031249-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

More of the checkpatch warning fixes.

Oleg Drokin (3):
  staging/lustre: Fix braces {} style
  staging/lustre: Fix blank line after/before {/} style
  staging/lustre: Get rid of ldlm_policy_res_t typedef

 drivers/staging/lustre/lustre/fld/fld_cache.c      |  3 +-
 drivers/staging/lustre/lustre/fld/fld_request.c    |  1 -
 drivers/staging/lustre/lustre/include/lu_object.h  |  1 -
 .../lustre/lustre/include/lustre/lustre_idl.h      |  3 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |  3 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |  2 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |  1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |  1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 50 +++++++++++-----------
 drivers/staging/lustre/lustre/llite/dir.c          | 22 +++++-----
 drivers/staging/lustre/lustre/llite/llite_close.c  |  3 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  9 ++--
 drivers/staging/lustre/lustre/llite/lloop.c        |  3 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  1 -
 drivers/staging/lustre/lustre/llite/namei.c        |  6 ++-
 drivers/staging/lustre/lustre/llite/rw.c           |  6 ++-
 drivers/staging/lustre/lustre/llite/rw26.c         |  3 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      | 12 ++++--
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  3 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |  4 +-
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |  1 -
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  3 +-
 drivers/staging/lustre/lustre/lov/lov_dev.c        | 10 +++--
 drivers/staging/lustre/lustre/lov/lov_io.c         | 10 +++--
 drivers/staging/lustre/lustre/lov/lov_obd.c        |  1 -
 drivers/staging/lustre/lustre/lov/lov_object.c     |  6 ++-
 drivers/staging/lustre/lustre/lov/lov_pack.c       |  5 +--
 drivers/staging/lustre/lustre/lov/lov_request.c    |  1 -
 drivers/staging/lustre/lustre/lov/lovsub_dev.c     |  9 ++--
 drivers/staging/lustre/lustre/lov/lovsub_lock.c    |  3 +-
 drivers/staging/lustre/lustre/lov/lovsub_object.c  |  7 +--
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |  1 -
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |  1 -
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |  1 -
 drivers/staging/lustre/lustre/obdclass/cl_io.c     | 13 +++---
 drivers/staging/lustre/lustre/obdclass/cl_object.c |  9 ++--
 drivers/staging/lustre/lustre/obdclass/class_obd.c |  1 -
 drivers/staging/lustre/lustre/obdclass/genops.c    |  1 -
 drivers/staging/lustre/lustre/obdclass/llog.c      |  1 -
 .../lustre/lustre/obdclass/lprocfs_status.c        |  3 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |  5 +--
 .../staging/lustre/lustre/obdclass/lustre_peer.c   |  3 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |  1 -
 .../staging/lustre/lustre/obdecho/echo_client.c    |  2 -
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  1 -
 drivers/staging/lustre/lustre/osc/osc_io.c         |  4 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |  3 +-
 drivers/staging/lustre/lustre/osc/osc_object.c     |  3 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |  4 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |  4 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  5 +--
 drivers/staging/lustre/lustre/ptlrpc/events.c      |  1 -
 drivers/staging/lustre/lustre/ptlrpc/import.c      |  3 --
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    | 10 ++---
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         |  1 -
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |  3 --
 56 files changed, 141 insertions(+), 136 deletions(-)

-- 
2.1.0
