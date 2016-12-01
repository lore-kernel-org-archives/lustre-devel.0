From: James Simmons <jsimmons@infradead.org>
Date: Thu,  1 Dec 2016 17:35:29 -0500
Subject: [lustre-devel] [PATCH 0/3] staging: lustre: osc: performance tuning
	for LRU
Message-ID: <1480631732-6880-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, Jinshan Xiong <jinshan.xiong@intel.com>

Early launch page LRU work in osc_io_rw_iter_init();
Change the page LRU shrinking policy by OSC attributes;
Delete the contented lock osc_object::oo_seatbelt
Original patch has been broken into 3 parts for upstream
merger.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5108
Reviewed-on: http://review.whamcloud.com/10458
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>

Jinshan Xiong (3):
  staging: lustre: osc: add and fixup comments for LRU handling
  staging: lustre: osc: create cli_name to get obd name
  staging: lustre: osc: Performance tune for LRU

 drivers/staging/lustre/lustre/include/obd.h        |   35 ++++-
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |    6 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   34 ++---
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   19 ---
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    7 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |   13 ++-
 drivers/staging/lustre/lustre/osc/osc_object.c     |    9 --
 drivers/staging/lustre/lustre/osc/osc_page.c       |  148 ++++++++++++--------
 drivers/staging/lustre/lustre/osc/osc_quota.c      |    4 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |   17 +--
 10 files changed, 162 insertions(+), 130 deletions(-)
