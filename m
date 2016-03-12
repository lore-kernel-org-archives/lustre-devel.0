From: James Simmons <jsimmons@infradead.org>
Date: Sat, 12 Mar 2016 13:00:30 -0500
Subject: [lustre-devel] [PATCH 0/6] Last batch of lnet selftest cleanup
Message-ID: <1457805636-23859-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Some fixes from two earlier patches got dropped so we add them to
this batch. Last of the style cleanups for LNet selftest. Redid
the comment style patch to format the comments correctly.

Dmitry Eremin (1):
  staging: lustre: add missing buffer overflow fix for console.c

James Nunez (1):
  staging: lustre: Correct missing newline for CERROR call in sfw_handle_server_rpc

James Simmons (4):
  staging: lustre: handle error returned from wait_event_timeout seltest timer
  staging: lustre: remove excess blank lines in lnet selftest code
  staging: lustre: realign some code in lnet selftest so its readable
  staging: lustre: cleanup comment style for lnet selftest

 drivers/staging/lustre/lnet/selftest/brw_test.c  |    4 +-
 drivers/staging/lustre/lnet/selftest/conctl.c    |   50 +++++++++++-----------
 drivers/staging/lustre/lnet/selftest/conrpc.c    |   19 ++++----
 drivers/staging/lustre/lnet/selftest/console.c   |   11 ++---
 drivers/staging/lustre/lnet/selftest/framework.c |   14 +++---
 drivers/staging/lustre/lnet/selftest/ping_test.c |    6 +-
 drivers/staging/lustre/lnet/selftest/rpc.c       |    8 ++--
 drivers/staging/lustre/lnet/selftest/timer.c     |   12 +++--
 8 files changed, 61 insertions(+), 63 deletions(-)
