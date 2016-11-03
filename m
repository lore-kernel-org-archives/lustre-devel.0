From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed,  2 Nov 2016 21:24:50 -0400
Subject: [lustre-devel] [PATCH 00/14] Lustre fixes
Message-ID: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

This batch of patches represents mostly recent fixes,
also a couple of cleanups and a couple of changes that fixes depend on.

Amir Shehata (1):
  staging/lustre/ptlrpc: Correctly calculate hrp->hrp_nthrs

Andrew Perepechko (1):
  staging/lustre/llite: drop_caches hangs in cl_inode_fini()

Andriy Skulysh (1):
  staging/lustre: conflicting PW & PR extent locks on a client

Bobi Jam (2):
  staging/lustre/llite: protect from accessing NULL lli_clob
  staging/lustre/llite: update ras window correctly

Hongchao Zhang (2):
  staging/lustre/ldlm: fix export reference problem
  staging/lustre/ldlm: engage ELC for all ldlm enqueue req

Jinshan Xiong (2):
  staging/lustre: Get rid of cl_env hash table
  staging/lustre/llite: do not clear uptodate bit in page delete

Niu Yawei (1):
  staging/lustre/llite: clear inode timestamps after losing UPDATE lock

Oleg Drokin (3):
  staging/lustre/ldlm: Drop unused blocking_refs flock field
  staging/lustre/ldlm: Reinstate ldlm_enqueue_pack()
  staging/lustre: Get rid of LIBLUSTRE_CLIENT and its users

Patrick Farrell (1):
  staging/lustre/ptlrpc: Suppress error for flock requests

 drivers/staging/lustre/lustre/include/cl_object.h  |  22 --
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   2 -
 drivers/staging/lustre/lustre/include/lustre_lib.h |   2 -
 .../staging/lustre/lustre/include/obd_support.h    |   3 +
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |  20 ++
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |   3 +
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |   9 -
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |  61 ++--
 drivers/staging/lustre/lustre/llite/file.c         |  26 +-
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |  11 +-
 drivers/staging/lustre/lustre/llite/lcommon_misc.c |   8 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  59 ++--
 drivers/staging/lustre/lustre/llite/namei.c        |  10 +
 drivers/staging/lustre/lustre/llite/rw.c           |  21 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |  52 +--
 drivers/staging/lustre/lustre/llite/vvp_page.c     |   1 -
 drivers/staging/lustre/lustre/lov/lov_io.c         |   5 -
 drivers/staging/lustre/lustre/lov/lov_object.c     |   7 +-
 .../staging/lustre/lustre/obdclass/cl_internal.h   |  23 --
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |   1 -
 drivers/staging/lustre/lustre/obdclass/cl_object.c | 389 ++++-----------------
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   4 -
 .../staging/lustre/lustre/obdecho/echo_client.c    |  14 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   6 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       | 116 +++---
 drivers/staging/lustre/lustre/osc/osc_page.c       |   6 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |   1 +
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   4 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |  19 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |   3 +-
 30 files changed, 298 insertions(+), 610 deletions(-)

-- 
2.7.4
