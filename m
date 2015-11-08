From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 14:17:05 -0500
Subject: [lustre-devel] [PATCH 00/13] bring lustre's kernel_comm code up to
	date
Message-ID: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This patch series brings the kernel_comm code used by Lustre up
to the latest verison with various fixes and style improvements
which makes the code compliant with the linux kernel standard.

Henri Doreau (1):
  staging: lustre: Prevent duplicate CT registrations

Hongchao Zhang (1):
  staging: lustre: embed kr_data into kkuc_reg

James Simmons (8):
  staging: lustre: kg_sem semaphore handling is incorrectly
  staging: lustre: convert kernelcomm group to unsigned int
  staging: lustre: remove unnecessary NULL checks in kernel_comm.c
  staging: lustre: cleanup block comment style in kernel_comm code
  staging: lustre: add space around '+' in kernel_comm code
  staging: lustre: use proper braces in libcfs_kkuc_group_put
  staging: lustre: return proper error code for libcfs_kkuc_msg_put
  staging: lustre: cleanup white space in kernel comm code

John L. Hammond (1):
  staging: lustre: remove hsm_nl proc file

frank zago (2):
  staging: lustre: move kernel_user_comm.c from libcfs to lustre
  staging: lustre: split kernel comm between user and kernel

 .../staging/lustre/include/linux/libcfs/libcfs.h   |    1 -
 .../staging/lustre/lustre/include/lustre_export.h  |    7 ++
 .../lustre/lustre/include/lustre_kernelcomm.h      |   56 ++++++++++++++
 .../include/uapi_kernelcomm.h}                     |   72 ++++++------------
 drivers/staging/lustre/lustre/libcfs/Makefile      |    5 +-
 drivers/staging/lustre/lustre/llite/dir.c          |    1 +
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   30 ++++++---
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c      |   77 --------------------
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   21 ++++--
 drivers/staging/lustre/lustre/obdclass/Makefile    |   10 ++--
 drivers/staging/lustre/lustre/obdclass/genops.c    |    1 +
 .../kernel_user_comm.c => obdclass/kernelcomm.c}   |   76 ++++++++++---------
 12 files changed, 171 insertions(+), 186 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
 rename drivers/staging/lustre/{include/linux/libcfs/libcfs_kernelcomm.h => lustre/include/uapi_kernelcomm.h} (51%)
 rename drivers/staging/lustre/lustre/{libcfs/kernel_user_comm.c => obdclass/kernelcomm.c} (82%)
