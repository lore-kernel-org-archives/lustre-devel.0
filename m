From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 12:41:42 +1100
Subject: [lustre-devel] [PATCH SERIES 4: 0/4] staging: lustre: use standard
 prng
Message-ID: <151356119565.24290.5570928075046338898.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

Lustre has its own internal PRNG code.
This adds nothing of value to the Linux standard prng code,
so switch over to using the standard interfaces.
This adds a few callers to add_device_randomness(), which
helps everyone, and removes unnecessary code.

Thanks,
NeilBrown


---

NeilBrown (4):
      staging: lustre: replace cfs_rand() with prandom_u32_max()
      staging: lustre: replace cfs_srand() calls with add_device_randomness().
      staging: lustre: replace cfs_get_random_bytes calls with get_random_byte()
      staging: lustre: libcfs: remove prng


 .../staging/lustre/include/linux/libcfs/libcfs.h   |   10 -
 drivers/staging/lustre/lnet/libcfs/Makefile        |    2 
 drivers/staging/lustre/lnet/libcfs/fail.c          |    2 
 drivers/staging/lustre/lnet/libcfs/prng.c          |  137 --------------------
 drivers/staging/lustre/lnet/lnet/net_fault.c       |   38 +++---
 drivers/staging/lustre/lnet/lnet/router.c          |   19 +--
 drivers/staging/lustre/lustre/include/obd_class.h  |    2 
 drivers/staging/lustre/lustre/llite/super25.c      |   17 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    4 -
 .../lustre/lustre/obdclass/lustre_handles.c        |    9 -
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    2 
 11 files changed, 42 insertions(+), 200 deletions(-)
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/prng.c

--
Signature
