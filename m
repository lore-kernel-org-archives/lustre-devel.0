From: Oleg Drokin <green@linuxhacker.ru>
Date: Tue,  6 Dec 2016 23:57:35 -0500
Subject: [lustre-devel] [PATCH 0/5] Lustre style fixes
Message-ID: <1481086660-1610943-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

These patches fix some more of the low hanging fruits
in the style problems highlighted by checkpatch.
Now only false positive ERRORs are left.
This also converts all bare unsigneds into unsigned ints
and a couple of spelling fixes.

Please consider.

Oleg Drokin (5):
  staging/lustre/o2iblnd: Add missing space
  staging/lustre/socklnd: Fix whitespace problem
  staging/lustre: Convert all bare unsigned to unsigned int
  staging/lustre/o2iblnd: Fix misspelling intialized->intialized
  staging/lustre/o2iblnd: Fix misspelled attemps->attempts

 drivers/staging/lustre/include/linux/lnet/lnetst.h |  6 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  4 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  4 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |  2 +-
 .../staging/lustre/lustre/include/lprocfs_status.h |  3 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |  8 +-
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |  2 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |  4 +-
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |  6 +-
 drivers/staging/lustre/lustre/lov/lov_pool.c       |  3 +-
 .../lustre/lustre/obdclass/lprocfs_status.c        |  3 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |  6 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |  4 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |  2 +-
 drivers/staging/lustre/lustre/osc/osc_quota.c      |  4 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |  6 +-
 drivers/staging/lustre/lustre/ptlrpc/connection.c  |  4 +-
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |  4 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |  6 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 92 +++++++++++-----------
 20 files changed, 88 insertions(+), 85 deletions(-)

-- 
2.7.4
