From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 1 Jan 2017 17:40:05 +0100
Subject: [lustre-devel] [PATCH 5/5] staging/lustre/obdclass: Use seq_puts()
 in three functions
In-Reply-To: <45ae8939-a775-865b-ade0-9e38a7ff2b5d@users.sourceforge.net>
References: <45ae8939-a775-865b-ade0-9e38a7ff2b5d@users.sourceforge.net>
Message-ID: <8d8a448c-4648-2b52-ab88-d3145f6be804@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Andreas Dilger <andreas.dilger@intel.com>, Ben Evans <bevans@cray.com>, Bobi Jam <bobijam.xu@intel.com>, Emoly Liu <emoly.liu@intel.com>, Fan Yong <fan.yong@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Gregoire Pichon <gregoire.pichon@bull.net>, Henri Doreau <henri.doreau@cea.fr>, James Simmons <jsimmons@infradead.org>, Jinshan Xiong <jinshan.xiong@intel.com>, "John L. Hammond" <john.hammond@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Lai Siyao <lai.siyao@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Sebastien Buisson <sbuisson@ddn.com>, Stephen Champion <schamp@sgi.com>, wang di <di.wang@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 1 Jan 2017 16:45:32 +0100

A string which did not contain a data format specification should be put
into a sequence. Thus use the corresponding function "seq_puts"
so that the data output will be a bit more efficient in these functions.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/obdclass/cl_object.c      |  4 ++--
 drivers/staging/lustre/lustre/obdclass/lprocfs_status.c | 15 +++++++--------
 2 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 277908d66a89..3e00aa4747b8 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -510,11 +510,11 @@ locks: ...... ...... ...... ...... ...... [...... ...... ...... ...... ......]
  */
 	lu_site_stats_print(&site->cs_lu, m);
 	cache_stats_print(&site->cs_pages, m, 1);
-	seq_printf(m, " [");
+	seq_puts(m, " [");
 	for (i = 0; i < ARRAY_SIZE(site->cs_pages_state); ++i)
 		seq_printf(m, "%s: %u ", pstate[i],
 			   atomic_read(&site->cs_pages_state[i]));
-	seq_printf(m, "]\n");
+	seq_puts(m, "]\n");
 	cache_stats_print(&cl_env_stats, m, 0);
 	seq_putc(m, '\n');
 	return 0;
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index a167cbe8a50e..3ce590cdd957 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -649,7 +649,7 @@ static int obd_import_flags2str(struct obd_import *imp, struct seq_file *m)
 	bool first = true;
 
 	if (imp->imp_obd->obd_no_recov) {
-		seq_printf(m, "no_recov");
+		seq_puts(m, "no_recov");
 		first = false;
 	}
 
@@ -715,15 +715,14 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 		   imp->imp_connect_data.ocd_instance);
 	obd_connect_seq_flags2str(m, imp->imp_connect_data.ocd_connect_flags,
 				  ", ");
-	seq_printf(m, " ]\n");
+	seq_puts(m, " ]\n");
 	obd_connect_data_seqprint(m, ocd);
-	seq_printf(m, "    import_flags: [ ");
+	seq_puts(m, "    import_flags: [ ");
 	obd_import_flags2str(imp, m);
-
-	seq_printf(m,
-		   " ]\n"
-		   "    connection:\n"
-		   "       failover_nids: [ ");
+	seq_puts(m,
+		 " ]\n"
+		 "    connection:\n"
+		 "       failover_nids: [ ");
 	spin_lock(&imp->imp_lock);
 	j = 0;
 	list_for_each_entry(conn, &imp->imp_conn_list, oic_item) {
-- 
2.11.0
