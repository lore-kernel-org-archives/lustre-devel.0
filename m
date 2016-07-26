From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 20:54:17 +0200
Subject: [lustre-devel] [PATCH 00/12] staging-Lustre: Fine-tuning for seven
 function implementations
In-Reply-To: <20151221234857.GA27079@kroah.com>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<56784D83.7080108@users.sourceforge.net>
	<56784F0C.6040007@users.sourceforge.net>
	<20151221234857.GA27079@kroah.com>
Message-ID: <59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Bhumika Goyal <bhumirks@gmail.com>

From: Markus Elfring <elfring@users.sourceforge.net>

Further update suggestions were taken into account
after a patch was applied from static source code analysis.

Markus Elfring (12):
  ldlm: Delete unnecessary checks before the function call "kset_unregister"
  Delete unnecessary checks before the function call "kobject_put"
  One function call less in class_register_type() after error detection
  Split a condition check in class_register_type()
  Optimize error handling in class_register_type()
  Return directly after a failed kcalloc() in mgc_process_recover_log()
  Less checks after a failed alloc_page() in mgc_process_recover_log()
  Less checks after a failed ptlrpc_request_alloc() inmgc_process_recover_log()
  Delete a check for the variable "req" in mgc_process_recover_log()
  Rename jump labels in mgc_process_recover_log()
  Move an assignment for the variable "eof" in mgc_process_recover_log()
  Delete an unnecessary variable initialisation in mgc_process_recover_log()

 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c | 10 ++---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c     |  5 +--
 drivers/staging/lustre/lustre/lov/lov_obd.c     |  4 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c | 50 ++++++++++++-------------
 drivers/staging/lustre/lustre/obdclass/genops.c | 41 ++++++++++++--------
 5 files changed, 54 insertions(+), 56 deletions(-)

-- 
2.9.2
