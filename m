From: Oleg Drokin <green@linuxhacker.ru>
Date: Tue, 23 Aug 2016 17:11:34 -0400
Subject: [lustre-devel] [PATCH 0/8] Lustre fixes
Message-ID: <1471986702-682922-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

HEre are some more recent Lustre fixes and a cleanup.

Alexander Boyko (1):
  staging/lustre/mdc: fix panic at mdc_free_open()

Andrew Perepechko (1):
  staging/lustre: avoid clearing i_nlink for inodes in use

Dmitry Eremin (1):
  staging/lustre/llite: Fix suspicious dereference of pointer
    'vma->vm_file'

James Simmons (1):
  staging/lustre/o2iblnd: handle mixed page size configurations.

John L. Hammond (2):
  staging/lustre: const correct set_lock_data()
  staging/lustre: release MGC device if connect fails

Lokesh Nagappa Jaliminche (1):
  staging/lustre/llite: changes to avoid cache corruption

Yang Sheng (1):
  staging/lustre/llite: check return value for obd_set_info_async

 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    | 14 +++---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    | 13 ++---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 55 ++++++++++-----------
 drivers/staging/lustre/lustre/include/obd.h        |  7 +--
 drivers/staging/lustre/lustre/include/obd_class.h  | 28 +----------
 .../staging/lustre/lustre/include/obd_support.h    |  2 +
 drivers/staging/lustre/lustre/llite/dcache.c       | 55 ---------------------
 drivers/staging/lustre/lustre/llite/file.c         |  4 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |  5 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 10 ++++
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  2 -
 drivers/staging/lustre/lustre/llite/namei.c        |  3 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |  2 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        | 47 ++----------------
 drivers/staging/lustre/lustre/lov/lov_obd.c        | 41 ----------------
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |  6 +--
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      | 30 ++----------
 drivers/staging/lustre/lustre/mdc/mdc_request.c    | 56 +++++++++++++---------
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |  2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    | 22 ---------
 20 files changed, 108 insertions(+), 296 deletions(-)

-- 
2.7.4
