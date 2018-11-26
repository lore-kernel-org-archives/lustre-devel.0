From: James Simmons <jsimmons@infradead.org>
Date: Sun, 25 Nov 2018 21:48:16 -0500
Subject: [lustre-devel] [PATCH 00/12] lustre: new patches to address
 previous reviews
Message-ID: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

New patches from myself to address issues with the last batch I sent.
Found a bug in the llite debugfs stats registeration code while
testing. Updated the TODO since many of the task have been done.
The patch for LU-5461 has been ported which makes sanity test 244 to
pass. The patch ported from LU-10218 now makes it possible to run
the sanity 160 changelog test without locking up the client node.
Several patches independent of PFL have been ported from lustre
2.10 LTS release.

Alexander Boyko (1):
  lustre: obdclass: obd_device improvement

Dmitry Eremin (1):
  lustre: clio: Introduce parallel tasks framework

James Simmons (6):
  lustre: llite: move CONFIG_SECURITY handling to llite_internal.h
  lustre: lnd: create enum kib_dev_caps
  lustre: lnd: test fpo_fmr_pool pointer instead of special bool
  lustre: llite: remove llite_loop left overs
  lustre: llite: avoid duplicate stats debugfs registration
  lustre: update TODO lustre list

John L. Hammond (2):
  lustre: mdc: propagate changelog errors to readers
  lustre: mdc: use large xattr buffers for old servers

Lai Siyao (1):
  lustre: mdc: don't add to page cache upon failure

Patrick Farrell (1):
  lustre: ldlm: No -EINVAL for canceled != unused

 drivers/staging/lustre/TODO                        |  85 ----
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  17 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  13 +-
 drivers/staging/lustre/lustre/include/cl_ptask.h   | 145 ++++++
 drivers/staging/lustre/lustre/include/obd_class.h  |   9 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |  16 +-
 drivers/staging/lustre/lustre/llite/file.c         | 107 +----
 .../staging/lustre/lustre/llite/llite_internal.h   |  81 +---
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  11 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |   2 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |  51 +--
 drivers/staging/lustre/lustre/mdc/mdc_changelog.c  |  45 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |  14 +
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   5 +-
 drivers/staging/lustre/lustre/obdclass/Makefile    |   3 +-
 drivers/staging/lustre/lustre/obdclass/cl_ptask.c  | 501 +++++++++++++++++++++
 drivers/staging/lustre/lustre/obdclass/genops.c    | 284 ++++++++----
 .../staging/lustre/lustre/obdclass/obd_config.c    | 143 ++----
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   6 +-
 19 files changed, 1007 insertions(+), 531 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/include/cl_ptask.h
 create mode 100644 drivers/staging/lustre/lustre/obdclass/cl_ptask.c

-- 
1.8.3.1
