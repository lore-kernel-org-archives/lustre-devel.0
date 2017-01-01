From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 1 Jan 2017 17:38:21 +0100
Subject: [lustre-devel] [PATCH 4/5] staging/lustre/obdclass: Combine two
 seq_printf() calls into one call in lprocfs_rd_state()
In-Reply-To: <45ae8939-a775-865b-ade0-9e38a7ff2b5d@users.sourceforge.net>
References: <45ae8939-a775-865b-ade0-9e38a7ff2b5d@users.sourceforge.net>
Message-ID: <92ca443f-4791-f291-e2ea-5e67e3a846ac@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Andreas Dilger <andreas.dilger@intel.com>, Ben Evans <bevans@cray.com>, Bobi Jam <bobijam.xu@intel.com>, Emoly Liu <emoly.liu@intel.com>, Fan Yong <fan.yong@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Gregoire Pichon <gregoire.pichon@bull.net>, Henri Doreau <henri.doreau@cea.fr>, James Simmons <jsimmons@infradead.org>, Jinshan Xiong <jinshan.xiong@intel.com>, "John L. Hammond" <john.hammond@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Lai Siyao <lai.siyao@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Sebastien Buisson <sbuisson@ddn.com>, Stephen Champion <schamp@sgi.com>, wang di <di.wang@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 1 Jan 2017 16:26:36 +0100

Some data were printed into a sequence by two separate function calls.
Print the same data by a single function call instead.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/obdclass/lprocfs_status.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 3f6fcab5a1fc..a167cbe8a50e 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -853,10 +853,8 @@ int lprocfs_rd_state(struct seq_file *m, void *data)
 		return rc;
 
 	imp = obd->u.cli.cl_import;
-
-	seq_printf(m, "current_state: %s\n",
+	seq_printf(m, "current_state: %s\nstate_history:\n",
 		   ptlrpc_import_state_name(imp->imp_state));
-	seq_printf(m, "state_history:\n");
 	k = imp->imp_state_hist_idx;
 	for (j = 0; j < IMP_STATE_HIST_LEN; j++) {
 		struct import_state_hist *ish =
-- 
2.11.0
