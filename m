From: James Simmons <jsimmons@infradead.org>
Date: Fri, 23 Oct 2015 15:59:12 -0400
Subject: [lustre-devel] [PATCH 0/5] staging:lustre: split kernel comm
	between user and kernel
Message-ID: <1445630357-27149-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The kernel communication code used for HSM and changelog is
entangled. Move the user space bits into the liblustreapi. This will
also help for a possible relicensing. The kernel portion is also moved
from libcfs to obdclass.

The original libcfs_kernelcomm.h header is split into three parts:

  * lustre_kernelcomm.h, a new header for the kernel parts;
  * uapi_kernelcomm.h, a new header for the data structures shared
    between userspace and kernelspace;
  * lustreapi_internal.h receives the private liblustreapi prototypes.

The original code in kernel_user_comm.c is split into two parts:

  * obdclass/kernelcomm.c for the kernel part. filp_user_write() was
    moved there, and linux-fs.c deleted;
  * liblustreapi_kernelconn.c for the user part. The calls to CDEBUG
    have been removed, and calls to CERROR have been transformed to
    llapi_err_noerrno. The type lustre_kernelcomm has been removed and
    replace by struct lustre_kernelcomm.

Various names and filenames have been harmonized to *kernelcomm*.

The unused symbol KUC_FL_BLOCK has been removed.

Signed-off-by: frank zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/14270
Reviewed-by: Nathan Rutman <nathan.rutman@seagate.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>

Henri Doreau (1):
  staging:lustre: Prevent duplicate CT registrations

James Simmons (1):
  staging:lustre: kg_sem semaphore handling is incorrectly

frank zago (3):
  staging:lustre: move kernel_user_comm.c from libcfs to lustre
  staging:lustre: split kernel comm between user and kernel
  staging:lustre: Update license and copyright for kernel comm

 .../staging/lustre/include/linux/libcfs/libcfs.h   |    1 -
 .../staging/lustre/lustre/include/lustre_export.h  |    7 +++
 .../lustre/lustre/include/lustre_kernelcomm.h      |   56 ++++++++++++++++++++
 .../include/uapi_kernelcomm.h}                     |   52 +++++--------------
 drivers/staging/lustre/lustre/libcfs/Makefile      |    5 +-
 drivers/staging/lustre/lustre/llite/dir.c          |    1 +
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   43 +++++++++++-----
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c      |    2 +
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   23 +++++---
 drivers/staging/lustre/lustre/obdclass/Makefile    |    7 ++-
 drivers/staging/lustre/lustre/obdclass/genops.c    |    1 +
 .../kernel_user_comm.c => obdclass/kernelcomm.c}   |   40 +++++++-------
 12 files changed, 150 insertions(+), 88 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
 rename drivers/staging/lustre/{include/linux/libcfs/libcfs_kernelcomm.h => lustre/include/uapi_kernelcomm.h} (61%)
 rename drivers/staging/lustre/lustre/{libcfs/kernel_user_comm.c => obdclass/kernelcomm.c} (88%)
