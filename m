From: James Simmons <jsimmons@infradead.org>
Date: Mon, 22 Feb 2016 17:29:01 -0500
Subject: [lustre-devel] [PATCH 00/24] Second batch of LNet updates
Message-ID: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

This patch set fixes many of the LNet issues encounter run in
production environments. One of the long standing issues was
not being able to reconfigure LNet after initialization. Doing
so left it in a broken state. Several other issues are also
addressed in this patch set. Merged back into this patch set
are also the suggestions for improvement from Dan Carpenter
when the original patch set was posted.

Amir Shehata (14):
  staging: lustre: Dynamic LNet Configuration (DLC) IOCTL changes
  staging: lustre: Dynamic LNet Configuration (DLC) show command
  staging: lustre: fix crash due to NULL networks string
  staging: lustre: DLC user/kernel space glue code
  staging: lustre: improve LNet clean up code and API
  staging: lustre: return appropriate errno when adding route
  staging: lustre: startup lnet acceptor thread dynamically
  staging: lustre: reject invalid net configuration for lnet
  staging: lustre: return -EEXIST if NI is not unique
  staging: lustre: handle lnet_check_routes() errors
  staging: lustre: improvement to router checker
  staging: lustre: prevent assert on LNet module unload
  staging: lustre: remove messages from lazy portal on NI shutdown
  staging: lustre: Allocate the correct number of rtr buffers

Bruno Faccini (1):
  staging: lustre: avoid race during lnet acceptor thread termination

Chris Horn (1):
  staging: lustre: Use lnet_is_route_alive for router aliveness

Doug Oucharek (1):
  staging: lustre: Remove LASSERTS from router checker

Frank Zago (4):
  staging: lustre: make local functions static for LNet ni
  staging: lustre: make some lnet functions static
  staging: lustre: missed a few cases of using NULL instead of 0
  staging: lustre: remove unnecessary EXPORT_SYMBOL from lnet layer

James Simmons (1):
  staging: lustre: use sock.h in only acceptor.c

John L. Hammond (2):
  staging: lustre: remove LUSTRE_{,SRV_}LNET_PID
  staging: lustre: assume a kernel build

 .../staging/lustre/include/linux/libcfs/libcfs.h   |    2 -
 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |   49 +-
 .../lustre/include/linux/libcfs/linux/libcfs.h     |    3 -
 .../staging/lustre/include/linux/lnet/lib-dlc.h    |  122 ++++
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   22 +
 .../staging/lustre/include/linux/lnet/lib-types.h  |   25 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    7 +-
 drivers/staging/lustre/lnet/lnet/acceptor.c        |   21 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  761 +++++++++++++-------
 drivers/staging/lustre/lnet/lnet/config.c          |   25 +-
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |    3 -
 drivers/staging/lustre/lnet/lnet/lib-md.c          |    3 -
 drivers/staging/lustre/lnet/lnet/lib-me.c          |    3 -
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   10 +-
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |   20 +-
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |   54 +-
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |    3 -
 drivers/staging/lustre/lnet/lnet/module.c          |   81 ++-
 drivers/staging/lustre/lnet/lnet/peer.c            |   63 ++
 drivers/staging/lustre/lnet/lnet/router.c          |  181 ++++--
 drivers/staging/lustre/lnet/lnet/router_proc.c     |    2 -
 drivers/staging/lustre/lnet/selftest/conctl.c      |    9 +-
 drivers/staging/lustre/lnet/selftest/console.c     |    6 +-
 drivers/staging/lustre/lnet/selftest/console.h     |    1 -
 drivers/staging/lustre/lnet/selftest/framework.c   |   10 -
 drivers/staging/lustre/lnet/selftest/module.c      |    4 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |    4 +-
 .../lustre/lustre/libcfs/linux/linux-module.c      |   55 +-
 drivers/staging/lustre/lustre/libcfs/module.c      |   58 ++-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    2 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |    4 +-
 drivers/staging/lustre/lustre/ptlrpc/events.c      |    4 +-
 32 files changed, 1122 insertions(+), 495 deletions(-)
 create mode 100644 drivers/staging/lustre/include/linux/lnet/lib-dlc.h
