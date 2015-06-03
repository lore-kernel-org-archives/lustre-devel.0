From: James Simmons <jsimmons@infradead.org>
Date: Wed,  3 Jun 2015 16:43:19 -0400
Subject: [lustre-devel] [PATCH v3 0/8] staging:lustre: remove kernel defines
	in userland headers
Message-ID: <1433364207-14307-1-git-send-email-jsimmons@infradead.org>
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

James Simmons (7):
  staging:lustre: fixup LNet resource container api
  staging:lustre: delete no longer used LNet headers
  staging:lustre: move LNet NID macros to LNet layer
  staging:lustre: separate kernel and user land defines in the LNet headers
  staging:lustre: fix camel case for LNetInit and LNetFini
  staging:lustre: style cleanups for LNet headers
  staging:lustre: Update license and copyright for the LNET headers

John L. Hammond (1):
  staging:lustre: assume a kernel build

 .../lustre/include/linux/libcfs/libcfs_private.h   |   55 --
 .../lustre/include/linux/lnet/api-support.h        |   44 --
 drivers/staging/lustre/include/linux/lnet/api.h    |   48 +-
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |  266 ++---------
 .../staging/lustre/include/linux/lnet/lib-types.h  |  523 +++++++-------------
 .../lustre/include/linux/lnet/linux/api-support.h  |   42 --
 .../lustre/include/linux/lnet/linux/lib-lnet.h     |   71 ---
 .../lustre/include/linux/lnet/linux/lib-types.h    |   45 --
 .../staging/lustre/include/linux/lnet/linux/lnet.h |   56 ---
 .../lustre/include/linux/lnet/lnet-sysctl.h        |   49 --
 drivers/staging/lustre/include/linux/lnet/lnet.h   |   17 +-
 .../staging/lustre/include/linux/lnet/lnetctl.h    |    7 +-
 drivers/staging/lustre/include/linux/lnet/lnetst.h |  490 ++++++++++---------
 drivers/staging/lustre/include/linux/lnet/nidstr.h |   77 +++
 drivers/staging/lustre/include/linux/lnet/ptllnd.h |   93 ----
 .../lustre/include/linux/lnet/ptllnd_wire.h        |  119 -----
 .../staging/lustre/include/linux/lnet/socklnd.h    |   68 ++--
 drivers/staging/lustre/include/linux/lnet/types.h  |  288 +++++++++---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    1 -
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |    1 -
 .../lustre/lnet/klnds/socklnd/socklnd_lib-linux.c  |    4 +-
 drivers/staging/lustre/lnet/lnet/acceptor.c        |    2 -
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   97 +---
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |    2 +-
 drivers/staging/lustre/lnet/lnet/lib-md.c          |    6 +-
 drivers/staging/lustre/lnet/lnet/lib-me.c          |    6 +-
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |    2 +-
 drivers/staging/lustre/lnet/lnet/module.c          |    6 +-
 drivers/staging/lustre/lnet/lnet/router.c          |  145 ------
 .../lustre/lustre/include/lustre/lustre_idl.h      |    1 +
 drivers/staging/lustre/lustre/include/lustre_net.h |    4 +-
 32 files changed, 876 insertions(+), 1761 deletions(-)
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/api-support.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/linux/api-support.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/linux/lib-lnet.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/linux/lib-types.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/linux/lnet.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/lnet-sysctl.h
 create mode 100644 drivers/staging/lustre/include/linux/lnet/nidstr.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/ptllnd.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/ptllnd_wire.h
