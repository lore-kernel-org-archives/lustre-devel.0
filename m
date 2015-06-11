From: James Simmons <jsimmons@infradead.org>
Date: Thu, 11 Jun 2015 15:18:06 -0400
Subject: [lustre-devel] [PATCH 0/9] staging:lustre: remove kernel defines in
	userland headers
Message-ID: <1434050295-10986-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Currently the lnet headers used for user land applications
contain various kernel definations. This is due to the
fact libcfs contains kernel wrappers for user land which
will be going away. This patch sorted the header data
so all kernel containing structures are moved out of
headers that user land will use.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/13792
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

James Simmons (6):
  staging:lustre: Delete all obsolete LND drivers
  staging:lustre: move LNet NID macros to LNet layer
  staging:lustre: separate kernel and user land defines in the LNet headers
  staging:lustre: fix camel case for LNetInit and LNetFini
  staging:lustre: LNet header code cleanup - indentation etc
  staging:lustre: Update license and copyright for the LNET headers

John L. Hammond (3):
  staging:lustre: remove lnet/include/lnet/linux/
  staging:lustre: rename socklnd_lib-linux.c
  staging:lustre: merge socklnd_lib-linux.h into socklnd.h

 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |    2 +-
 .../lustre/include/linux/libcfs/libcfs_private.h   |   55 --
 .../lustre/include/linux/lnet/api-support.h        |   44 --
 drivers/staging/lustre/include/linux/lnet/api.h    |   48 +-
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   56 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |  647 ++++++++------------
 .../lustre/include/linux/lnet/linux/api-support.h  |   42 --
 .../lustre/include/linux/lnet/linux/lib-lnet.h     |   71 ---
 .../lustre/include/linux/lnet/linux/lib-types.h    |   45 --
 .../staging/lustre/include/linux/lnet/linux/lnet.h |   56 --
 .../lustre/include/linux/lnet/lnet-sysctl.h        |   49 --
 drivers/staging/lustre/include/linux/lnet/lnet.h   |   17 +-
 .../staging/lustre/include/linux/lnet/lnetctl.h    |    7 +-
 drivers/staging/lustre/include/linux/lnet/lnetst.h |  490 ++++++++-------
 drivers/staging/lustre/include/linux/lnet/nidstr.h |   77 +++
 drivers/staging/lustre/include/linux/lnet/ptllnd.h |   93 ---
 .../lustre/include/linux/lnet/ptllnd_wire.h        |  119 ----
 .../staging/lustre/include/linux/lnet/socklnd.h    |   68 +--
 drivers/staging/lustre/include/linux/lnet/types.h  |  290 +++++++--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    5 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    1 -
 drivers/staging/lustre/lnet/klnds/socklnd/Makefile |    2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |   40 ++-
 .../lustre/lnet/klnds/socklnd/socklnd_lib-linux.h  |   86 ---
 .../socklnd/{socklnd_lib-linux.c => socklnd_lib.c} |    7 +-
 drivers/staging/lustre/lnet/lnet/acceptor.c        |    2 -
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   21 +-
 drivers/staging/lustre/lnet/lnet/config.c          |   77 ---
 drivers/staging/lustre/lnet/lnet/module.c          |    6 +-
 drivers/staging/lustre/lnet/lnet/router.c          |  145 -----
 .../lustre/lustre/include/lustre/lustre_idl.h      |    1 +
 drivers/staging/lustre/lustre/include/lustre_net.h |    4 +-
 32 files changed, 975 insertions(+), 1698 deletions(-)
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/api-support.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/linux/api-support.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/linux/lib-lnet.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/linux/lib-types.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/linux/lnet.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/lnet-sysctl.h
 create mode 100644 drivers/staging/lustre/include/linux/lnet/nidstr.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/ptllnd.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/ptllnd_wire.h
 delete mode 100644 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.h
 rename drivers/staging/lustre/lnet/klnds/socklnd/{socklnd_lib-linux.c => socklnd_lib.c} (99%)
