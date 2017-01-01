From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 1 Jan 2017 17:33:51 +0100
Subject: [lustre-devel] [PATCH 1/5] staging/lustre/llite: Use seq_puts() in
	three functions
In-Reply-To: <45ae8939-a775-865b-ade0-9e38a7ff2b5d@users.sourceforge.net>
References: <45ae8939-a775-865b-ade0-9e38a7ff2b5d@users.sourceforge.net>
Message-ID: <6980a3a8-be35-e9a3-fc89-8394d503b80f@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Andreas Dilger <andreas.dilger@intel.com>, Ben Evans <bevans@cray.com>, Bobi Jam <bobijam.xu@intel.com>, Emoly Liu <emoly.liu@intel.com>, Fan Yong <fan.yong@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Gregoire Pichon <gregoire.pichon@bull.net>, Henri Doreau <henri.doreau@cea.fr>, James Simmons <jsimmons@infradead.org>, Jinshan Xiong <jinshan.xiong@intel.com>, "John L. Hammond" <john.hammond@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Lai Siyao <lai.siyao@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Sebastien Buisson <sbuisson@ddn.com>, Stephen Champion <schamp@sgi.com>, wang di <di.wang@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 1 Jan 2017 15:30:45 +0100

A string which did not contain a data format specification should be put
into a sequence. Thus use the corresponding function "seq_puts"
so that the data output will be a bit more efficient in these functions.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/llite/lproc_llite.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 03682c10fc9e..b195b7eb2883 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -1325,8 +1325,8 @@ static int ll_rw_extents_stats_pp_seq_show(struct seq_file *seq, void *v)
 	ktime_get_real_ts64(&now);
 
 	if (!sbi->ll_rw_stats_on) {
-		seq_printf(seq, "disabled\n"
-			   "write anything in this file to activate, then 0 or \"[D/d]isabled\" to deactivate\n");
+		seq_puts(seq, "disabled\n"
+			 "write anything in this file to activate, then 0 or \"[D/d]isabled\" to deactivate\n");
 		return 0;
 	}
 	seq_printf(seq, "snapshot_time:	 %llu.%09lu (secs.usecs)\n",
@@ -1403,8 +1403,8 @@ static int ll_rw_extents_stats_seq_show(struct seq_file *seq, void *v)
 	ktime_get_real_ts64(&now);
 
 	if (!sbi->ll_rw_stats_on) {
-		seq_printf(seq, "disabled\n"
-			   "write anything in this file to activate, then 0 or \"[D/d]isabled\" to deactivate\n");
+		seq_puts(seq, "disabled\n"
+			 "write anything in this file to activate, then 0 or \"[D/d]isabled\" to deactivate\n");
 		return 0;
 	}
 	seq_printf(seq, "snapshot_time:	 %llu.%09lu (secs.usecs)\n",
@@ -1583,8 +1583,8 @@ static int ll_rw_offset_stats_seq_show(struct seq_file *seq, void *v)
 	ktime_get_real_ts64(&now);
 
 	if (!sbi->ll_rw_stats_on) {
-		seq_printf(seq, "disabled\n"
-			   "write anything in this file to activate, then 0 or \"[D/d]isabled\" to deactivate\n");
+		seq_puts(seq, "disabled\n"
+			 "write anything in this file to activate, then 0 or \"[D/d]isabled\" to deactivate\n");
 		return 0;
 	}
 	spin_lock(&sbi->ll_process_lock);
-- 
2.11.0
