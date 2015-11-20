From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:35:36 -0500
Subject: [lustre-devel] [PATCH 00/40] Sync upstream lustre client LNet core
Message-ID: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This is the majority of the fixes that have gone into the LNet layer.
Outside a few remaining patches this brings LNet close to what is
running in production world wide.

This patch series needs the remove IOC_LIBCFS_PING_TEST ioctl patch
landed first.

Amir Shehata (19):
  staging: lustre: Dynamic LNet Configuration (DLC)
  staging: lustre: Dynamic LNet Configuration (DLC) dynamic routing
  staging: lustre: DLC Feature dynamic net config
  staging: lustre: Dynamic LNet Configuration (DLC) IOCTL changes
  staging: lustre: Dynamic LNet Configuration (DLC) show command
  staging: lustre: fix crash due to NULL networks string
  staging: lustre: DLC user/kernel space glue code
  staging: lustre: fix kernel crash when network failed to start
  staging: lustre: improve LNet clean up code and API
  staging: lustre: return appropriate errno when adding route
  staging: lustre: startup lnet acceptor thread dynamically
  staging: lustre: reject invalid net configuration for lnet
  staging: lustre: return -EEXIST if NI is not unique
  staging: lustre: handle lnet_check_routes() errors
  staging: lustre: improvement to router checker
  staging: lustre: prevent assert on LNet module unload
  staging: lustre: remove messages from lazy portal on NI shutdown
  staging: lustre: remove unnecessary NULL check in IOC_LIBCFS_GET_NET
  staging: lustre: Allocate the correct number of rtr buffers

Bruno Faccini (1):
  staging: lustre: avoid race during lnet acceptor thread termination

Chris Horn (2):
  staging: lustre: reflect down routes in /proc/sys/lnet/routes
  staging: lustre: Use lnet_is_route_alive for router aliveness

Doug Oucharek (1):
  staging: lustre: Remove LASSERTS from router checker

Frank Zago (1):
  staging: lustre: do not memset after LIBCFS_ALLOC

James Simmons (4):
  staging: lustre: drop *_t from end of struct lnet_text_buf
  staging: lustre: eliminate obsolete Cray SeaStar support
  staging: lustre: Fixes to make lnetctl function as expected.
  staging: lustre: test for sk_sleep presence in compact-2.6.h

John L. Hammond (3):
  staging: lustre: remove uses of IS_ERR_VALUE()
  staging: lustre: remove LUSTRE_{,SRV_}LNET_PID
  staging: lustre: assume a kernel build

Liang Zhen (3):
  staging: lustre: fix failure handle of create reply
  staging: lustre: return +ve for blocked lnet message
  staging: lustre: copy out libcfs ioctl inline buffer

Sebastien Buisson (1):
  staging: lustre: fix 'NULL pointer dereference' errors for LNet

frank zago (5):
  staging: lustre: make local functions static for LNet ni
  staging: lustre: add sparse annotation __user wherever needed for lnet
  staging: lustre: make some lnet functions static
  staging: lustre: missed a few cases of using NULL instead of 0
  staging: lustre: remove unnecessary EXPORT_SYMBOL from lnet layer

 .../staging/lustre/include/linux/libcfs/libcfs.h   |    2 -
 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |   89 ++-
 .../lustre/include/linux/libcfs/linux/libcfs.h     |    3 -
 .../staging/lustre/include/linux/lnet/lib-dlc.h    |  118 ++
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   60 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |   38 +-
 drivers/staging/lustre/include/linux/lnet/lnetst.h |   96 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    4 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    7 +-
 drivers/staging/lustre/lnet/lnet/acceptor.c        |   30 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          | 1295 +++++++++++++------
 drivers/staging/lustre/lnet/lnet/config.c          |  113 +-
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |    3 -
 drivers/staging/lustre/lnet/lnet/lib-md.c          |    3 -
 drivers/staging/lustre/lnet/lnet/lib-me.c          |    3 -
 drivers/staging/lustre/lnet/lnet/lib-move.c        |  195 ++-
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |   20 +-
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |   54 +-
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |    3 -
 drivers/staging/lustre/lnet/lnet/module.c          |   70 +-
 drivers/staging/lustre/lnet/lnet/peer.c            |  197 +++-
 drivers/staging/lustre/lnet/lnet/router.c          |  426 +++++--
 drivers/staging/lustre/lnet/lnet/router_proc.c     |    4 +-
 drivers/staging/lustre/lnet/selftest/conctl.c      |   62 +-
 drivers/staging/lustre/lnet/selftest/conrpc.c      |    4 +-
 drivers/staging/lustre/lnet/selftest/conrpc.h      |    5 +-
 drivers/staging/lustre/lnet/selftest/console.c     |   97 +-
 drivers/staging/lustre/lnet/selftest/console.h     |   55 +-
 drivers/staging/lustre/lnet/selftest/framework.c   |   10 -
 drivers/staging/lustre/lnet/selftest/module.c      |    4 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |    4 +-
 .../lustre/lustre/libcfs/linux/linux-module.c      |   74 +-
 drivers/staging/lustre/lustre/libcfs/module.c      |  104 +-
 drivers/staging/lustre/lustre/libcfs/tracefile.c   |    6 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    2 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |    8 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   18 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    9 +-
 .../lustre/lustre/obdclass/linux/linux-module.c    |   17 +-
 drivers/staging/lustre/lustre/obdclass/llog.c      |   13 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |    4 +-
 drivers/staging/lustre/lustre/ptlrpc/events.c      |    4 +-
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |   10 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |   29 +-
 44 files changed, 2297 insertions(+), 1075 deletions(-)
 create mode 100644 drivers/staging/lustre/include/linux/lnet/lib-dlc.h
