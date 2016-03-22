From: James Simmons <jsimmons@infradead.org>
Date: Tue, 22 Mar 2016 19:03:47 -0400
Subject: [lustre-devel] [PATCH 00/29] Bring libcfs ioctl handling up to date
Message-ID: <1458687856-24959-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

This brings the upstream libcfs ioctl handling up to date with
the latest production code. Most of the work was to make libcfs_ioctl.h
a simple uapi header that can be used by user land utilities.
Lots of ioctl code cleanup and simplification.

James Simmons (9):
  staging: lustre: libcfs: change variable name
  staging: lustre: libcfs: removal all userland only macros from libcfs_ioctl.h
  staging: lustre: libcfs: migrate inline functions to source file
  staging: lustre: libcfs: move function declarations from libcfs_ioctl.h
  staging: lustre: libcfs: make libcfs_ioctl.h readable
  staging: lustre: libcfs: add uapi headers to libcfs_ioctl.h
  staging: lustre: libcfs: return proper bool values
  staging: lustre: libcfs: use BIT macro in linux-module.c
  staging: lustre: libcfs: return size_t for libcfs_ioctl_packlen

John L. Hammond (3):
  staging: lustre: libcfs: remove libcfsutil.h in comment
  staging: lustre: libcfs: move libcfs_ioctl_handler stuff to libcfs.h
  staging: lustre: libcfs: remove libcfs_ioctl_popdata wrapper

Liang Zhen (12):
  staging: lustre: libcfs: replace LNET_MAX_IOCTL_BUF_LEN with something bigger
  staging: lustre: libcfs: use break in switch options for libcfs_ioctl_handle
  staging: lustre: libcfs: merge code from libcfs_ioctl into libcfs_ioctl_getdata
  staging: lustre: libcfs: merge libcfs_ioctl_handle into libcfs_ioctl
  staging: lustre: libcfs: add debugging info for libcfs_ioctl
  staging: lustre: libcfs: move comment in libcfs_ioctl
  staging: lustre: libcfs: test if data is NULL
  staging: lustre: libcfs: invert test condition for libcfs_ioctl
  staging: lustre: libcfs: update error messages in linux-module.c
  staging: lustre: libcfs: test if userland data is to small
  staging: lustre: lnet: make sure lnet data not greater than LIBCFS_IOC_DATA_MAX
  staging: lustre: simple cleanup in obd_ioctl_popdata

Parinay Kondekar (5):
  staging:lustre: remove last bits of the IOC_LIBCFS_PANIC ioctl
  staging:lustre: remove the IOC_LIBCFS_MEMHOG ioctl
  staging:lustre: remove libcfs_psdev_[open|release]
  staging:lustre: call libcfs_ioctl directly
  staging:lustre: remove libcfs pseudo device abstraction

 .../staging/lustre/include/linux/libcfs/libcfs.h   |   42 +++---
 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |  161 +++++---------------
 .../lustre/lnet/libcfs/linux/linux-module.c        |  154 +++++++++++--------
 drivers/staging/lustre/lnet/libcfs/module.c        |  125 +++++-----------
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    4 +
 .../lustre/lustre/obdclass/linux/linux-module.c    |    4 +-
 6 files changed, 190 insertions(+), 300 deletions(-)
