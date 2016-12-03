From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:07 -0500
Subject: [lustre-devel] [PATCH 00/22] Next batch of missing work for
	upstream client
Message-ID: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Batch of various fixes and clean ups missing in the upstream client.
Only one smaller batch of patches left to sync lustre 2.8.0 version.
These patches are independent of each other so they can be landed
in any order.

Alex Zhuravlev (1):
  staging: lustre: obdclass: lu_site_purge() to handle purge-all

Alexander Boyko (1):
  staging: lustre: obd: add callback for llog_cat_process_or_fork

Alexander Zarochentsev (1):
  staging: lustre: libcfs: remove lnet upcall code

Ashish Purkar (1):
  staging: lustre: osc: fix debug log message formatting

Bobi Jam (1):
  staging: lustre: clio: remove mtime check in vvp_io_fault_start()

Fan Yong (1):
  staging: lustre: statahead: set sai_index_wait with lli_sa_lock held

Jinshan Xiong (5):
  staging: lustre: llite: clear LLIF_DATA_MODIFIED in atomic
  staging: lustre: osc: handle osc eviction correctly
  staging: lustre: clio: revise read ahead algorithm
  staging: lustre: rpc: increase bulk size
  staging: lustre: osc: set lock data for readahead lock

Li Dongyang (2):
  staging: lustre: obdclass: limit lu_site hash table size on clients
  staging: lustre: mdt: fail FMODE_WRITE open if the client is read only

Mikhal Pershin (1):
  staging: lustre: import: don't reconnect during connect interpret

Parinay Kondekar (1):
  staging: lustre: llite: ll_dir_ioctl cleanup of redundant comparisons

Wally Wang (1):
  staging: lustre: llite: Add client mount opt to ignore suppress_pings

Yang Sheng (3):
  staging: lustre: libcfs: report hnode value for cfs_hash_putref
  staging: lustre: llite: Invoke file_update_time in page_mkwrite
  staging: lustre: remove set but unused variables

wang di (3):
  staging: lustre: mdt: race between open and migrate
  staging: lustre: lmv: remove nlink check in lmv_revalidate_slaves
  staging: lustre: llog: reset llog bitmap

 .../staging/lustre/include/linux/libcfs/libcfs.h   |    1 -
 .../lustre/include/linux/libcfs/libcfs_private.h   |    2 -
 drivers/staging/lustre/lnet/libcfs/hash.c          |    2 +-
 .../staging/lustre/lnet/libcfs/linux/linux-debug.c |   54 --------
 drivers/staging/lustre/lnet/libcfs/module.c        |    8 -
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |    2 -
 .../lustre/lustre/include/lustre/lustre_idl.h      |    6 +-
 .../staging/lustre/lustre/include/lustre_import.h  |    4 +-
 drivers/staging/lustre/lustre/include/lustre_net.h |    8 +-
 .../lustre/lustre/include/lustre_req_layout.h      |    1 +
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    3 +-
 drivers/staging/lustre/lustre/llite/dir.c          |    5 +-
 drivers/staging/lustre/lustre/llite/file.c         |  137 +++++++++++++-------
 .../staging/lustre/lustre/llite/llite_internal.h   |   22 ++--
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   34 +++---
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |    8 +-
 drivers/staging/lustre/lustre/llite/namei.c        |    4 +
 drivers/staging/lustre/lustre/llite/rw.c           |   71 ++++++-----
 drivers/staging/lustre/lustre/llite/statahead.c    |   18 ++-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |   16 +--
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |    7 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |   16 +--
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |   59 +++++----
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |   20 +++-
 drivers/staging/lustre/lustre/obdclass/llog.c      |    7 +
 drivers/staging/lustre/lustre/obdclass/llog_cat.c  |   16 +--
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    9 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   25 ++--
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   11 +-
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    2 +
 drivers/staging/lustre/lustre/osc/osc_io.c         |   61 +++++++--
 drivers/staging/lustre/lustre/osc/osc_lock.c       |    7 +-
 drivers/staging/lustre/lustre/osc/osc_object.c     |   19 +++
 drivers/staging/lustre/lustre/osc/osc_page.c       |    2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |   94 +++++++-------
 drivers/staging/lustre/lustre/ptlrpc/import.c      |   16 ++-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |   18 +++
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |    2 +
 38 files changed, 452 insertions(+), 345 deletions(-)
