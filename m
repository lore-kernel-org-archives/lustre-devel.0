From: James Simmons <jsimmons@infradead.org>
Date: Sat, 18 Feb 2017 16:47:01 -0500
Subject: [lustre-devel] [PATCH 00/14] staging: lustre: missing fixes from
	lustre 2.8
Message-ID: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

This patch series is a batch of fixes from the lustre 2.8
release that is missing from the upstream client. These
patches are dependent on the order applied.

Alex Zhuravlev (1):
  staging: lustre: llog: limit file size of plain logs

Andreas Dilger (1):
  staging: lustre: llite: remove extraneous export parameter

Bobi Jam (2):
  staging: lustre: llite: lower message level for ll_setattr_raw()
  staging: lustre: llite: omit to update wire data

James Simmons (1):
  staging: lustre: lprocfs: move lprocfs_stats_[un]lock to a source file

Jinshan Xiong (4):
  staging: lustre: osc: remove obsolete asserts
  staging: lustre: lov: cleanup when cl_io_iter_init() fails
  staging: lustre: ldlm: handle ldlm lock cancel race when evicting client.
  staging: lustre: osc: further LRU OSC cleanup after eviction

Niu Yawei (1):
  staging: lustre: ldlm: fix race of starting bl threads

Vitaly Fertman (2):
  staging: lustre: ldlm: reduce ldlm pool recalc window
  staging: lustre: ldlm: disconnect speedup

Yang Sheng (1):
  staging: lustre: lov: trying smaller memory allocations

wang di (1):
  staging: lustre: llog: change lgh_hdr_lock to mutex

 drivers/staging/lustre/lustre/include/cl_object.h  |  13 +-
 .../staging/lustre/lustre/include/lprocfs_status.h | 120 ++------------
 drivers/staging/lustre/lustre/include/lustre_dlm.h |  11 +-
 .../lustre/lustre/include/lustre_dlm_flags.h       |   3 +
 drivers/staging/lustre/lustre/include/lustre_log.h |   2 +-
 .../staging/lustre/lustre/include/obd_support.h    |   1 +
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |   5 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |  47 ++++--
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    | 178 +++++++++++++--------
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |   7 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |  14 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   2 +-
 drivers/staging/lustre/lustre/llite/file.c         |  49 +++---
 drivers/staging/lustre/lustre/llite/glimpse.c      |   4 +-
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |   8 +-
 drivers/staging/lustre/lustre/llite/lcommon_misc.c |   2 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |   2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  14 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |   4 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |   2 +-
 drivers/staging/lustre/lustre/llite/rw.c           |   2 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |  10 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |   1 +
 drivers/staging/lustre/lustre/llite/xattr.c        |   2 +-
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |  41 +++--
 drivers/staging/lustre/lustre/lov/lov_io.c         |  24 +--
 drivers/staging/lustre/lustre/lov/lov_object.c     |   2 +-
 drivers/staging/lustre/lustre/obdclass/cl_object.c |   6 +-
 drivers/staging/lustre/lustre/obdclass/llog.c      |  18 ++-
 .../lustre/lustre/obdclass/lprocfs_status.c        | 111 +++++++++++++
 .../staging/lustre/lustre/obdecho/echo_client.c    |   6 +-
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |   2 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   3 +-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   4 +-
 drivers/staging/lustre/lustre/osc/osc_internal.h   |   3 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |  48 ++----
 drivers/staging/lustre/lustre/osc/osc_lock.c       |  60 ++++---
 drivers/staging/lustre/lustre/osc/osc_object.c     |  12 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       |  77 +++++++--
 drivers/staging/lustre/lustre/osc/osc_request.c    |  12 +-
 40 files changed, 554 insertions(+), 378 deletions(-)

-- 
1.8.3.1
