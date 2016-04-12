From: James Simmons <jsimmons@infradead.org>
Date: Tue, 12 Apr 2016 12:16:00 -0400
Subject: [lustre-devel] [PATCH v2 0/2] staging: lustre: selftest: remove
	typedefs
Message-ID: <1460477762-14167-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Convert the remaining typedefs into their proper data types.

Changelog:

v1) Based on 4.6-rc1 staging tree. Most patches were merged.

v2) Rebased on 4.6-rc3 due to PAGE_CACHE_* going away.

James Simmons (2):
  staging: lustre: selftest: convert lstcon_test_t to proper struct
  staging: lustre: selftest: convert wire protocol to use struct

 drivers/staging/lustre/lnet/selftest/brw_test.c  |   22 ++--
 drivers/staging/lustre/lnet/selftest/conctl.c    |    2 +-
 drivers/staging/lustre/lnet/selftest/conrpc.c    |   49 ++++----
 drivers/staging/lustre/lnet/selftest/console.c   |   36 +++---
 drivers/staging/lustre/lnet/selftest/console.h   |    7 +-
 drivers/staging/lustre/lnet/selftest/framework.c |   54 ++++----
 drivers/staging/lustre/lnet/selftest/ping_test.c |   10 +-
 drivers/staging/lustre/lnet/selftest/rpc.c       |    6 +-
 drivers/staging/lustre/lnet/selftest/rpc.h       |  150 +++++++++++-----------
 drivers/staging/lustre/lnet/selftest/selftest.h  |   13 +-
 10 files changed, 176 insertions(+), 173 deletions(-)
