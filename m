From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 1 Jan 2017 17:30:59 +0100
Subject: [lustre-devel] [PATCH 0/5] staging-Lustre: Fine-tuning for some
 function implementations
Message-ID: <45ae8939-a775-865b-ade0-9e38a7ff2b5d@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Andreas Dilger <andreas.dilger@intel.com>, Ben Evans <bevans@cray.com>, Bobi Jam <bobijam.xu@intel.com>, Emoly Liu <emoly.liu@intel.com>, Fan Yong <fan.yong@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Gregoire Pichon <gregoire.pichon@bull.net>, Henri Doreau <henri.doreau@cea.fr>, James Simmons <jsimmons@infradead.org>, Jinshan Xiong <jinshan.xiong@intel.com>, "John L. Hammond" <john.hammond@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Lai Siyao <lai.siyao@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Sebastien Buisson <sbuisson@ddn.com>, Stephen Champion <schamp@sgi.com>, wang di <di.wang@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 1 Jan 2017 17:10:10 +0100

A few update suggestions were taken into account
from static source code analysis.

Markus Elfring (5):
  llite: Use seq_puts() in three functions
  mgc: Combine two seq_printf() calls into one call in lprocfs_mgc_rd_ir_state()
  obdclass: Use seq_putc() in four functions
  obdclass: Combine two seq_printf() calls into one call in lprocfs_rd_state()
  obdclass: Use seq_puts() in three functions

 drivers/staging/lustre/lustre/llite/lproc_llite.c  | 12 +++++------
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |  5 +----
 drivers/staging/lustre/lustre/obdclass/cl_object.c |  8 ++++----
 .../lustre/lustre/obdclass/lprocfs_status.c        | 23 ++++++++++------------
 4 files changed, 21 insertions(+), 27 deletions(-)

-- 
2.11.0
