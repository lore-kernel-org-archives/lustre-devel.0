From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 21 Aug 2016 18:04:33 -0400
Subject: [lustre-devel] [PATCH 0/3] Rebased Lustre patches
Message-ID: <1471817076-563589-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

Here are the three patches rebased after merge conflict
with some other patches that were accepted first.

Oleg Drokin (3):
  staging/lustre: Add spaces preferred around that '{+,-,*,/,|,<<,>>,&}'
  staging/lustre: Make alignment match open parenthesis
  staging/lustre: Remove unused cp_error from struct cl_page

 .../staging/lustre/include/linux/libcfs/libcfs.h   |   6 +-
 .../lustre/include/linux/libcfs/libcfs_debug.h     |  10 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   5 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |   2 +-
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |   4 +-
 drivers/staging/lustre/lustre/include/cl_object.h  |   4 +-
 drivers/staging/lustre/lustre/include/lu_object.h  |   3 +-
 .../lustre/lustre/include/lustre/lustre_idl.h      |  28 +-
 .../lustre/lustre/include/lustre/lustre_user.h     |   2 +-
 drivers/staging/lustre/lustre/include/lustre_fid.h |   2 +-
 .../staging/lustre/lustre/include/lustre_lite.h    |   2 +-
 .../staging/lustre/lustre/include/obd_support.h    |  13 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |   4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |   4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |  17 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |   8 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |  26 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |  21 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |   4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |  14 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   5 +-
 drivers/staging/lustre/lustre/llite/file.c         |   4 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  25 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |   4 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  14 +-
 drivers/staging/lustre/lustre/llite/namei.c        |   4 +-
 drivers/staging/lustre/lustre/llite/rw.c           |   9 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |   2 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |   3 +-
 drivers/staging/lustre/lustre/llite/super25.c      |   4 +-
 drivers/staging/lustre/lustre/llite/vvp_object.c   |   2 +-
 drivers/staging/lustre/lustre/llite/vvp_page.c     |   4 +-
 drivers/staging/lustre/lustre/lov/lov_ea.c         |   3 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c        |  18 +-
 drivers/staging/lustre/lustre/lov/lov_pool.c       |   2 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |   5 +-
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |   5 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |   4 +-
 drivers/staging/lustre/lustre/obdclass/debug.c     |   4 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    |   2 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |  12 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   8 +-
 drivers/staging/lustre/lustre/obdclass/obdo.c      |   6 +-
 .../staging/lustre/lustre/obdecho/echo_internal.h  |   4 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   6 +-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   2 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |   2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |  12 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |   6 +-
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |   2 +-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |   3 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   5 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |   4 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |   5 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |  18 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |  24 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 288 ++++++++++-----------
 58 files changed, 368 insertions(+), 343 deletions(-)

-- 
2.7.4
