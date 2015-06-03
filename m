From: James Simmons <jsimmons@infradead.org>
Date: Wed,  3 Jun 2015 10:32:27 -0400
Subject: [lustre-devel] [PATCH v3 0/7] staging:lustre: remove tcpip
	abstraction from libcfs
Message-ID: <1433341954-654-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Since libcfs no longer builds for user land we can
move the TCPIP abstraction that exist to the LNET
layer which is the only place that uses it. Also
the migrated code will use native linux kernel
APIs directly instead of with wrappers.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/13760
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>

James Simmons (7):
  staging:lustre: move tcpip abstraction
  staging:lustre: remove useless libcfs_sock_release
  staging:lustre: remove useless libcfs_sock_abort_accept
  staging:lustre: rename tcpip handling functions to lnet_* prefix
  staging:lustre: use available kernel wrappers in lib-socket.c
  staging:lustre: style cleanups for lib-socket.c
  staging:lustre: Update license and copyright for lib-socket.c

 .../staging/lustre/include/linux/libcfs/libcfs.h   |   17 -
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   16 +
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   17 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |    2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |    6 +-
 .../lustre/lnet/klnds/socklnd/socklnd_lib-linux.c  |   15 +-
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |   43 +-
 drivers/staging/lustre/lnet/lnet/Makefile          |    7 +-
 drivers/staging/lustre/lnet/lnet/acceptor.c        |   55 +-
 drivers/staging/lustre/lnet/lnet/config.c          |   21 +-
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |  595 +++++++++++++++++++
 drivers/staging/lustre/lustre/libcfs/Makefile      |    1 -
 .../lustre/lustre/libcfs/linux/linux-tcpip.c       |  623 --------------------
 14 files changed, 688 insertions(+), 732 deletions(-)
 create mode 100644 drivers/staging/lustre/lnet/lnet/lib-socket.c
 delete mode 100644 drivers/staging/lustre/lustre/libcfs/linux/linux-tcpip.c
