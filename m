From: James Simmons <jsimmons@infradead.org>
Date: Tue, 12 Apr 2016 16:14:00 -0400
Subject: [lustre-devel] [PATCH v2 00/16] staging : lustre : rest of missing
	patches from 2.5.0 release
Message-ID: <1460492056-31792-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

This is the last collection of missing fixes present in the
Lustre 2.5.0 release. Once these are merged the upstream
client will be equal to the pre-2.6 lustre version since the
major of clio cleanups from that time frame have already
landed.

changelog:

v1) Based on 4.6-rc1.

v2) Rebased for 4.6-rc3. Patch for lloop was dropped. Updated
    to handle PAGE_CACHE_* changes.

Andrew Perepechko (3):
  staging: lustre: llite: variable rename in namei.c
  staging: lustre: llite: speedup in unlink/rmdir
  staging: lustre: lprocfs: implement log2 using bitops

Andriy Skulysh (1):
  staging: lustre: lov: Don't wait for active target with OBD_STATFS_NODELAY

Bobi Jam (1):
  staging: lustre: obd: MDT mount fails on MDS w/o MGS on it

Bruno Faccini (3):
  staging: lustre: ldlm: Fix a race during FLock handling
  staging: lustre: ldlm: refine LU-2665 patch for POSIX compliance
  staging: lustre: lov: return minimal FIEMAP for released files

Jinshan Xiong (3):
  staging: lustre: llite: error setting max_cache_mb at mount time
  staging: lustre: llite: Truncate to restore file
  staging: lustre: osc: osc_extent_wait() shouldn't be interruptible

John L. Hammond (2):
  staging: lustre: hsm: permission checks for HSM ioctl operations
  staging: lustre: hsm: don't use real suppgid

Niu Yawei (1):
  staging: lustre: clio: incorrect assertions in 'enable-invariants'

Sebastien Buisson (1):
  staging: lustre: osc: fix race issues thanks to oap_lock

Swapnil Pimpale (1):
  staging: lustre: ptlrpc: return a meaningful status from ptlrpcd_init()

 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |   15 +++--
 drivers/staging/lustre/lustre/llite/dir.c          |    3 +
 drivers/staging/lustre/lustre/llite/file.c         |    5 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   60 +++++++++----------
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |    4 +-
 drivers/staging/lustre/lustre/llite/namei.c        |   65 ++++++++++----------
 drivers/staging/lustre/lustre/llite/vvp_io.c       |    5 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   21 ++++++
 drivers/staging/lustre/lustre/lov/lov_request.c    |    7 ++-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |    4 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   17 +++--
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    5 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |    5 +-
 .../lustre/lustre/obdclass/lprocfs_status.c        |    6 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   13 +++--
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   10 +++-
 drivers/staging/lustre/lustre/osc/osc_io.c         |    2 +
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |    5 +-
 19 files changed, 155 insertions(+), 99 deletions(-)
