From: James Simmons <jsimmons@infradead.org>
Date: Fri, 11 Mar 2016 20:29:41 -0500
Subject: [lustre-devel] [PATCH 00/10] Cleanup and audit of lnet selftest code
Message-ID: <1457746191-27981-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

With lnet selftest nearly in sync with the OpenSFS code base it
was time to do a audit to see if anything was missed. One patch
was missed a few errors unique to upstream needed to be addressed.
Besides adding in fixes it was time to do more kernel style
cleanups. In the process several more checkpatch issues were
addressed.

Isaac Huang (1):
  staging: lustre: fix bogus lst errors for lnet selftest

James Simmons (9):
  staging: lustre: remove returns in void function for lnet selftest
  staging: lustre: fix spacing issues checkpatch reported in lnet selftest
  staging: lustre: remove extra spacing of variable declartions for lnet selftest
  staging: lustre: remove extra spacing when setting variable for lnet selftest
  staging: lustre: filter remaining extra spacing for lnet selftest
  staging: lustre: cleanup comment style for lnet selftest
  staging: lustre: test for proper errno code in lstcon_rpc_trans_abort
  staging: lustre: report minimum of two buffers for LNet selftest load test
  staging: lustre: fix aligments in lnet selftest

 drivers/staging/lustre/lnet/selftest/brw_test.c  |   97 ++++----
 drivers/staging/lustre/lnet/selftest/conctl.c    |  106 ++++----
 drivers/staging/lustre/lnet/selftest/conrpc.c    |  148 ++++++------
 drivers/staging/lustre/lnet/selftest/conrpc.h    |   56 +++---
 drivers/staging/lustre/lnet/selftest/console.c   |  140 ++++++------
 drivers/staging/lustre/lnet/selftest/console.h   |  116 +++++-----
 drivers/staging/lustre/lnet/selftest/framework.c |  187 +++++++--------
 drivers/staging/lustre/lnet/selftest/module.c    |    5 +-
 drivers/staging/lustre/lnet/selftest/ping_test.c |   21 +-
 drivers/staging/lustre/lnet/selftest/rpc.c       |  143 ++++++------
 drivers/staging/lustre/lnet/selftest/rpc.h       |  180 +++++++-------
 drivers/staging/lustre/lnet/selftest/selftest.h  |  278 +++++++++++-----------
 drivers/staging/lustre/lnet/selftest/timer.c     |   14 +-
 drivers/staging/lustre/lnet/selftest/timer.h     |    6 +-
 14 files changed, 735 insertions(+), 762 deletions(-)
