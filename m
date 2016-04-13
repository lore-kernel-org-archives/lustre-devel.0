From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 12 Apr 2016 21:11:07 -0400
Subject: [lustre-devel] [PATCH 0/2] Couple of lustre cleanups
Message-ID: <1460509869-3288664-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

These are rebased cleanups from before -
style fixes and suppressign a spurious message.

Bobi Jam (1):
  staging/lustre/llite: suppress non active IO error message

Oleg Drokin (1):
  staging/lustre: Fix blank line after/before {/} style

 drivers/staging/lustre/lustre/fld/fld_request.c     |  1 -
 drivers/staging/lustre/lustre/include/lu_object.h   |  1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c       |  1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c      |  1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c   |  1 -
 drivers/staging/lustre/lustre/llite/dir.c           |  2 --
 drivers/staging/lustre/lustre/llite/lproc_llite.c   |  1 -
 drivers/staging/lustre/lustre/llite/rw.c            | 11 ++---------
 drivers/staging/lustre/lustre/llite/xattr.c         |  1 -
 drivers/staging/lustre/lustre/llite/xattr_cache.c   |  1 -
 drivers/staging/lustre/lustre/lov/lov_io.c          |  1 -
 drivers/staging/lustre/lustre/lov/lov_obd.c         |  1 -
 drivers/staging/lustre/lustre/lov/lov_pack.c        |  1 -
 drivers/staging/lustre/lustre/lov/lov_request.c     |  1 -
 drivers/staging/lustre/lustre/lov/lovsub_object.c   |  1 -
 drivers/staging/lustre/lustre/mdc/mdc_lib.c         |  1 -
 drivers/staging/lustre/lustre/mdc/mdc_locks.c       |  1 -
 drivers/staging/lustre/lustre/mgc/mgc_request.c     |  1 -
 drivers/staging/lustre/lustre/obdclass/class_obd.c  |  1 -
 drivers/staging/lustre/lustre/obdclass/genops.c     |  1 -
 drivers/staging/lustre/lustre/obdclass/llog.c       |  1 -
 drivers/staging/lustre/lustre/obdclass/lu_object.c  |  2 --
 drivers/staging/lustre/lustre/obdclass/obd_config.c |  1 -
 drivers/staging/lustre/lustre/obdecho/echo_client.c |  2 --
 drivers/staging/lustre/lustre/osc/osc_cache.c       |  1 -
 drivers/staging/lustre/lustre/osc/osc_io.c          |  1 -
 drivers/staging/lustre/lustre/osc/osc_page.c        |  1 -
 drivers/staging/lustre/lustre/osc/osc_request.c     |  1 -
 drivers/staging/lustre/lustre/ptlrpc/client.c       |  1 -
 drivers/staging/lustre/lustre/ptlrpc/events.c       |  1 -
 drivers/staging/lustre/lustre/ptlrpc/import.c       |  3 ---
 drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c |  1 -
 drivers/staging/lustre/lustre/ptlrpc/nrs.c          |  1 -
 drivers/staging/lustre/lustre/ptlrpc/pack_generic.c |  3 ---
 34 files changed, 2 insertions(+), 49 deletions(-)

-- 
2.1.0
