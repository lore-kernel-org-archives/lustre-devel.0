From: James Simmons <jsimmons@infradead.org>
Date: Mon, 15 Feb 2016 10:25:44 -0500
Subject: [lustre-devel] [PATCH 00/10] First 10 patches for LNet layer bug
	fixes
Message-ID: <1455549954-29532-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The first set of patches to bring the upstream LNet into sync with
the latest production LNet code. Below is listed what bugs that
have been addressed.

Amir Shehata (3):
  staging: lustre: Dynamic LNet Configuration (DLC)
  staging: lustre: Dynamic LNet Configuration (DLC) dynamic routing
  staging: lustre: DLC Feature dynamic net config

Chris Horn (2):
  staging: lustre: rename variables in lnet_find_route_locked
  staging: lustre: reflect down routes in /proc/sys/lnet/routes

Frank Zago (1):
  staging: lustre: do not memset after LIBCFS_ALLOC

James Simmons (1):
  staging: lustre: eliminate obsolete Cray SeaStar support

John L. Hammond (1):
  staging: lustre: remove uses of IS_ERR_VALUE()

Liang Zhen (2):
  staging: lustre: fix failure handle of create reply
  staging: lustre: return +ve for blocked lnet message

 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   27 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |   13 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    2 -
 drivers/staging/lustre/lnet/lnet/acceptor.c        |    9 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  810 +++++++++++++-------
 drivers/staging/lustre/lnet/lnet/config.c          |   31 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |  185 +++--
 drivers/staging/lustre/lnet/lnet/peer.c            |  134 +++-
 drivers/staging/lustre/lnet/lnet/router.c          |  296 ++++++--
 drivers/staging/lustre/lnet/lnet/router_proc.c     |    2 +-
 drivers/staging/lustre/lustre/libcfs/tracefile.c   |    6 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |    8 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   18 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    9 +-
 drivers/staging/lustre/lustre/obdclass/llog.c      |   13 +-
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |   10 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |   29 +-
 17 files changed, 1077 insertions(+), 525 deletions(-)
