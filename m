From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 May 2015 18:46:15 -0400
Subject: [lustre-devel] [PATCH 0/3] First set of Intel branch merger for
	libcfs/lnet
In-Reply-To: <uja.ornl@gmail.com>
References: <uja.ornl@gmail.com>
Message-ID: <1432248378-28912-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This is the first set of patches that are current in the Intel branch
which are apart of the effort to cleanup LNet/libcfs.

James Simmons (3):
  staging:lustre: remove tcpip abstraction from libcfs
  staging:lustre: remove kernel defines in userland headers
  staging:lustre: cleanup libcfs lock handling

 .../staging/lustre/include/linux/libcfs/libcfs.h   |   21 -
 .../lustre/include/linux/libcfs/libcfs_private.h   |   51 --
 .../lustre/include/linux/lnet/api-support.h        |   44 --
 drivers/staging/lustre/include/linux/lnet/api.h    |   51 +-
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |  264 ++-------
 .../staging/lustre/include/linux/lnet/lib-types.h  |  649 +++++++++-----------
 .../lustre/include/linux/lnet/linux/api-support.h  |   42 --
 .../lustre/include/linux/lnet/linux/lib-lnet.h     |   71 ---
 .../lustre/include/linux/lnet/linux/lib-types.h    |   45 --
 .../staging/lustre/include/linux/lnet/linux/lnet.h |   56 --
 .../lustre/include/linux/lnet/lnet-sysctl.h        |   49 --
 drivers/staging/lustre/include/linux/lnet/lnet.h   |   11 +-
 .../staging/lustre/include/linux/lnet/lnetctl.h    |   36 +-
 drivers/staging/lustre/include/linux/lnet/lnetst.h |  665 ++++++++++++--------
 drivers/staging/lustre/include/linux/lnet/nidstr.h |   73 +++
 drivers/staging/lustre/include/linux/lnet/ptllnd.h |   93 ---
 .../lustre/include/linux/lnet/ptllnd_wire.h        |  119 ----
 .../staging/lustre/include/linux/lnet/socklnd.h    |   91 ++--
 drivers/staging/lustre/include/linux/lnet/types.h  |  266 +++++++--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    4 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    9 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   16 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |    3 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |    7 +-
 .../lustre/lnet/klnds/socklnd/socklnd_lib-linux.c  |   21 +-
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |   30 +-
 drivers/staging/lustre/lnet/lnet/Makefile          |    7 +-
 drivers/staging/lustre/lnet/lnet/acceptor.c        |   47 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  100 +---
 drivers/staging/lustre/lnet/lnet/config.c          |   21 +-
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |    2 +-
 drivers/staging/lustre/lnet/lnet/lib-md.c          |    6 +-
 drivers/staging/lustre/lnet/lnet/lib-me.c          |   24 +-
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |   22 +-
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |  616 ++++++++++++++++++
 drivers/staging/lustre/lnet/lnet/module.c          |    4 +-
 drivers/staging/lustre/lnet/lnet/router.c          |  145 -----
 drivers/staging/lustre/lustre/include/lustre_net.h |    4 +-
 drivers/staging/lustre/lustre/libcfs/Makefile      |    1 -
 drivers/staging/lustre/lustre/libcfs/fail.c        |    2 +-
 .../lustre/lustre/libcfs/linux/linux-tcpip.c       |  623 ------------------
 .../lustre/lustre/libcfs/linux/linux-tracefile.c   |    4 +-
 drivers/staging/lustre/lustre/libcfs/module.c      |   11 +-
 drivers/staging/lustre/lustre/libcfs/tracefile.c   |    2 +-
 44 files changed, 1856 insertions(+), 2572 deletions(-)
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/api-support.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/linux/api-support.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/linux/lib-lnet.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/linux/lib-types.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/linux/lnet.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/lnet-sysctl.h
 create mode 100644 drivers/staging/lustre/include/linux/lnet/nidstr.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/ptllnd.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/ptllnd_wire.h
 create mode 100644 drivers/staging/lustre/lnet/lnet/lib-socket.c
 delete mode 100644 drivers/staging/lustre/lustre/libcfs/linux/linux-tcpip.c
