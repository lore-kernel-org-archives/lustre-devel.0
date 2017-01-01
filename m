From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 1 Jan 2017 17:35:25 +0100
Subject: [lustre-devel] [PATCH 2/5] staging/lustre/mgc: Combine two
 seq_printf() calls into one call in lprocfs_mgc_rd_ir_state()
In-Reply-To: <45ae8939-a775-865b-ade0-9e38a7ff2b5d@users.sourceforge.net>
References: <45ae8939-a775-865b-ade0-9e38a7ff2b5d@users.sourceforge.net>
Message-ID: <25b07069-c624-cdd4-ca7b-85aaae51e79e@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Andreas Dilger <andreas.dilger@intel.com>, Ben Evans <bevans@cray.com>, Bobi Jam <bobijam.xu@intel.com>, Emoly Liu <emoly.liu@intel.com>, Fan Yong <fan.yong@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Gregoire Pichon <gregoire.pichon@bull.net>, Henri Doreau <henri.doreau@cea.fr>, James Simmons <jsimmons@infradead.org>, Jinshan Xiong <jinshan.xiong@intel.com>, "John L. Hammond" <john.hammond@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Lai Siyao <lai.siyao@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Sebastien Buisson <sbuisson@ddn.com>, Stephen Champion <schamp@sgi.com>, wang di <di.wang@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 1 Jan 2017 15:40:29 +0100

Some data were printed into a sequence by two separate function calls.
Print the same data by a single function call instead.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/mgc/mgc_request.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index b9c522a3c7a4..a6ca48d7e96b 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -460,11 +460,8 @@ int lprocfs_mgc_rd_ir_state(struct seq_file *m, void *data)
 
 	imp = obd->u.cli.cl_import;
 	ocd = &imp->imp_connect_data;
-
-	seq_printf(m, "imperative_recovery: %s\n",
+	seq_printf(m, "imperative_recovery: %s\nclient_state:\n",
 		   OCD_HAS_FLAG(ocd, IMP_RECOV) ? "ENABLED" : "DISABLED");
-	seq_printf(m, "client_state:\n");
-
 	spin_lock(&config_list_lock);
 	list_for_each_entry(cld, &config_llog_list, cld_list_chain) {
 		if (!cld->cld_recover)
-- 
2.11.0
