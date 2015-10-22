From: James Simmons <jsimmons@infradead.org>
Date: Wed, 21 Oct 2015 21:52:38 -0400
Subject: [lustre-devel] [PATCH 00/11] staging: lustre: update NID string
	handling
Message-ID: <1445478769-21203-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Much of the LNet network setup is managed with modprobe configuration
files. Those configurations are parse with the code in nidstring.c
which currently located in the libcfs layer. This patch series moves
nidstring.c to the LNet layer where it belongs and we update the
source with all the changes that have occured on the OpenSFS lustre
development branch.

Gregoire Pichon (1):
  staging: lustre: add a service that prints a nidlist

Joshua Walgenbach (1):
  staging: lustre: add in NID range management for libcfs

Dmitry Eremin (1):
  staging: lustre: provide separate buffers for libcfs_*2str()

Frederic Saunier (1):
  staging: lustre: remove last entry of libcfs_netstrfns[]

James Simmons (7):
  staging: lustre: move nidstring handling to LNet layer
  staging: lustre: remove libcfs_init_string function
  staging: lustre: remove cfs_ip_addr_free wrapper
  staging: lustre: move struct netstrfns to nidstr.h
  staging: lustre: move cfs_ip_addr_* function from kernel libcfs to LNet
  staging: lustre: Avoid nid range related forward declarations in nidstring.c
  staging: lustre: add in NID range management for libcfs
  staging: lustre: Use C99 initializers for struct netstrfns

 .../staging/lustre/include/linux/libcfs/libcfs.h   |    2 -
 .../lustre/include/linux/libcfs/libcfs_string.h    |    5 +-
 drivers/staging/lustre/include/linux/lnet/nidstr.h |   47 +-
 drivers/staging/lustre/lnet/lnet/Makefile          |    2 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    6 +-
 drivers/staging/lustre/lnet/lnet/config.c          |    2 +-
 drivers/staging/lustre/lnet/lnet/nidstrings.c      | 1260 ++++++++++++++++++++
 drivers/staging/lustre/lnet/lnet/router.c          |    2 +-
 drivers/staging/lustre/lustre/libcfs/Makefile      |    2 +-
 .../staging/lustre/lustre/libcfs/libcfs_string.c   |  144 ++--
 drivers/staging/lustre/lustre/libcfs/module.c      |    2 -
 drivers/staging/lustre/lustre/libcfs/nidstrings.c  |  842 -------------
 .../lustre/lustre/obdclass/lprocfs_status.c        |   11 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |    9 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |    7 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    8 +-
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |    5 +-
 17 files changed, 1408 insertions(+), 948 deletions(-)
 create mode 100644 drivers/staging/lustre/lnet/lnet/nidstrings.c
 delete mode 100644 drivers/staging/lustre/lustre/libcfs/nidstrings.c
