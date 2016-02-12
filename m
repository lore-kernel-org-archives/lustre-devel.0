From: James Simmons <jsimmons@infradead.org>
Date: Fri, 12 Feb 2016 12:05:58 -0500
Subject: [lustre-devel] [PATCH 00/11] Massive style cleanup for LNet layer
Message-ID: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Dorkin <oleg.dorkin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

This is the start of the work to bring the upstream client LNet layer
up to date. Before merging in various bug fixes the majority of the
checkpatch issues need to be addressed. This patch series cleans up
the majority of the check patch issues and brings the code style much
closer to what is required for the linux kernel.

James Simmons (11):
  staging: lustre: drop *_t from end of struct lnet_text_buf
  staging: lustre: format properly all comment blocks for LNet core
  staging: lustre: align all code properly for LNet core
  staging: lustre: remove unnecessary parentheses around LNet function pointer
  staging: lustre: remove unnecessary blank lines reported by checkpatch.pl
  staging: lustre: add missing spaces for LNet layer reported by checkpatch.pl
  staging: lustre: don't set more than one variable per line in LNet layer
  staging: lustre: remove space in LNet function declarations
  staging: lustre: balance braces properly in LNet layer
  staging: lustre: fix all NULL comparisons in LNet layer
  staging: lustre: fix all conditional comparison to zero in LNet layer

 drivers/staging/lustre/include/linux/lnet/api.h    |   22 +-
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   45 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |   58 +-
 drivers/staging/lustre/include/linux/lnet/nidstr.h |    9 +-
 .../staging/lustre/include/linux/lnet/socklnd.h    |    9 +-
 drivers/staging/lustre/include/linux/lnet/types.h  |   47 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  490 +++++++------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   30 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  607 ++++++++-------
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |    8 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |  594 ++++++++-------
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |   25 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |  784 +++++++++++---------
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |  195 +++---
 .../lustre/lnet/klnds/socklnd/socklnd_modparams.c  |    8 +-
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |  165 +++--
 drivers/staging/lustre/lnet/lnet/acceptor.c        |   85 ++-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  276 ++++----
 drivers/staging/lustre/lnet/lnet/config.c          |  230 +++---
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |   74 +-
 drivers/staging/lustre/lnet/lnet/lib-md.c          |   90 ++-
 drivers/staging/lustre/lnet/lnet/lib-me.c          |   18 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |  429 ++++++-----
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |   90 ++-
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |  128 ++--
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |   99 ++--
 drivers/staging/lustre/lnet/lnet/lo.c              |   14 +-
 drivers/staging/lustre/lnet/lnet/module.c          |   20 +-
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |  116 ++--
 drivers/staging/lustre/lnet/lnet/peer.c            |   44 +-
 drivers/staging/lustre/lnet/lnet/router.c          |  248 ++++---
 drivers/staging/lustre/lnet/lnet/router_proc.c     |  155 ++--
 drivers/staging/lustre/lnet/selftest/brw_test.c    |  105 ++--
 drivers/staging/lustre/lnet/selftest/conctl.c      |  254 +++----
 drivers/staging/lustre/lnet/selftest/conrpc.c      |  191 +++---
 drivers/staging/lustre/lnet/selftest/console.c     |  291 ++++----
 drivers/staging/lustre/lnet/selftest/console.h     |    2 +-
 drivers/staging/lustre/lnet/selftest/framework.c   |  277 ++++----
 drivers/staging/lustre/lnet/selftest/module.c      |   14 +-
 drivers/staging/lustre/lnet/selftest/ping_test.c   |   30 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |  344 +++++----
 drivers/staging/lustre/lnet/selftest/rpc.h         |    6 +-
 drivers/staging/lustre/lnet/selftest/selftest.h    |   47 +-
 drivers/staging/lustre/lnet/selftest/timer.c       |    6 +-
 44 files changed, 3600 insertions(+), 3179 deletions(-)
