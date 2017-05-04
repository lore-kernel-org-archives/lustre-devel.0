From: Mathias Rav <mathiasrav@gmail.com>
Date: Thu,  4 May 2017 12:13:39 -0400
Subject: [lustre-devel] [PATCH 2/2] staging: lustre: lprocfs: Use seq_puts
In-Reply-To: <20170504161339.15901-2-mathiasrav@gmail.com>
References: <20170504161339.15901-1-mathiasrav@gmail.com>
	<20170504161339.15901-2-mathiasrav@gmail.com>
Message-ID: <20170504161339.15901-3-mathiasrav@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Mathias Rav <mathiasrav@gmail.com>

Replace all occurrences of seq_printf with no formatting directives
in lprocfs_status.c with seq_puts.

Reported by checkpatch.pl: "WARNING: Prefer seq_puts to seq_printf".

Signed-off-by: Mathias Rav <mathiasrav@gmail.com>
---
 .../staging/lustre/lustre/obdclass/lprocfs_status.c  | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 338ce34d6514..b5e0e46777ea 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -716,7 +716,7 @@ static int obd_import_flags2str(struct obd_import *imp, struct seq_file *m)
 	bool first = true;
 
 	if (imp->imp_obd->obd_no_recov) {
-		seq_printf(m, "no_recov");
+		seq_puts(m, "no_recov");
 		first = false;
 	}
 
@@ -782,15 +782,15 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 		   imp->imp_connect_data.ocd_instance);
 	obd_connect_seq_flags2str(m, imp->imp_connect_data.ocd_connect_flags,
 				  ", ");
-	seq_printf(m, " ]\n");
+	seq_puts(m, " ]\n");
 	obd_connect_data_seqprint(m, ocd);
-	seq_printf(m, "    import_flags: [ ");
+	seq_puts(m, "    import_flags: [ ");
 	obd_import_flags2str(imp, m);
 
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
@@ -923,7 +923,7 @@ int lprocfs_rd_state(struct seq_file *m, void *data)
 
 	seq_printf(m, "current_state: %s\n",
 		   ptlrpc_import_state_name(imp->imp_state));
-	seq_printf(m, "state_history:\n");
+	seq_puts(m, "state_history:\n");
 	k = imp->imp_state_hist_idx;
 	for (j = 0; j < IMP_STATE_HIST_LEN; j++) {
 		struct import_state_hist *ish =
@@ -945,7 +945,7 @@ int lprocfs_at_hist_helper(struct seq_file *m, struct adaptive_timeout *at)
 
 	for (i = 0; i < AT_BINS; i++)
 		seq_printf(m, "%3u ", at->at_hist[i]);
-	seq_printf(m, "\n");
+	seq_puts(m, "\n");
 	return 0;
 }
 EXPORT_SYMBOL(lprocfs_at_hist_helper);
@@ -1013,7 +1013,7 @@ int lprocfs_rd_connect_flags(struct seq_file *m, void *data)
 	flags = obd->u.cli.cl_import->imp_connect_data.ocd_connect_flags;
 	seq_printf(m, "flags=%#llx\n", flags);
 	obd_connect_seq_flags2str(m, flags, "\n");
-	seq_printf(m, "\n");
+	seq_puts(m, "\n");
 	up_read(&obd->u.cli.cl_sem);
 	return 0;
 }
-- 
2.12.2
