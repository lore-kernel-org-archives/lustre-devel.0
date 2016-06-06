From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Sun,  5 Jun 2016 23:28:49 -0400
Subject: [lustre-devel] [PATCH 0/4] Lustre fixes and cleanups
Message-ID: <1465183733-3147667-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Here are a few more Lustre fixes and cleanups.

Jinshan Xiong (2):
  staging/lustre/lov: calculate file offset correctly
  staging/lustre/llite: define per open file cache for ll_cl_context

Oleg Drokin (2):
  staging/lustre/osc: Remove ops_temp from osc_page
  staging/lustre/osc: Get rid of osc_page_protected()

 drivers/staging/lustre/lustre/llite/file.c         |   7 +
 .../staging/lustre/lustre/llite/llite_internal.h   |  11 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |   5 +
 drivers/staging/lustre/lustre/llite/rw.c           | 145 +++++++++------------
 drivers/staging/lustre/lustre/llite/rw26.c         |  17 +--
 drivers/staging/lustre/lustre/lov/lov_offset.c     |   2 +-
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   5 -
 drivers/staging/lustre/lustre/osc/osc_page.c       |  22 ----
 8 files changed, 89 insertions(+), 125 deletions(-)

-- 
2.7.4
