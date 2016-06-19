From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 18 Jun 2016 23:53:09 -0400
Subject: [lustre-devel] [PATCH 0/4] Some Lustre style cleanups
Message-ID: <1466308393-1183295-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

These are just some more cleanups in Lustre styel and comments

Emoly Liu (2):
  staging/lustre: Fix blank line before EXPORT_SYMBOL()
  staging/lustre: Keep logical continuations on the previous line

Oleg Drokin (2):
  staging/lustre: Remove unnecessary space after a cast
  staging/lustre: Update FID documentation link.

 drivers/staging/lustre/include/linux/lnet/lib-dlc.h       |  2 +-
 drivers/staging/lustre/include/linux/lnet/types.h         |  4 ++--
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h       |  2 +-
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c    |  2 +-
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c       |  4 ++--
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c    |  4 ++--
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c |  6 +++---
 drivers/staging/lustre/lnet/lnet/api-ni.c                 |  2 +-
 drivers/staging/lustre/lnet/lnet/module.c                 |  2 +-
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h |  4 ++--
 drivers/staging/lustre/lustre/include/lustre_fid.h        |  2 +-
 drivers/staging/lustre/lustre/include/lustre_sec.h        |  6 +++---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c           |  9 ++++-----
 drivers/staging/lustre/lustre/llite/file.c                |  2 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c             |  2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c           |  4 ++--
 drivers/staging/lustre/lustre/mgc/mgc_request.c           |  4 ++--
 drivers/staging/lustre/lustre/obdclass/cl_object.c        |  6 +++---
 drivers/staging/lustre/lustre/obdclass/obd_config.c       |  6 +++---
 drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c       |  1 -
 drivers/staging/lustre/lustre/ptlrpc/nrs.c                |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c                |  4 ++--
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c           |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c         |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_null.c           |  4 ++--
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c          | 10 +++++-----
 26 files changed, 48 insertions(+), 50 deletions(-)

-- 
2.7.4
