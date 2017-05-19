From: Mathias Rav <mathiasrav@gmail.com>
Date: Thu, 18 May 2017 22:49:22 -0400
Subject: [lustre-devel] [PATCH v2 2/2] staging: lustre: lprocfs: Use
	seq_puts instead of seq_printf
In-Reply-To: <20170519024922.15222-1-mathiasrav@gmail.com>
References: <20170519024922.15222-1-mathiasrav@gmail.com>
Message-ID: <20170519024922.15222-3-mathiasrav@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: mathiasrav@gmail.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Reported by checkpatch.pl: "WARNING: Prefer seq_puts to seq_printf".

Signed-off-by: Mathias Rav <mathiasrav@gmail.com>
---
 .../staging/lustre/lustre/obdclass/lprocfs_status.c  | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index b42c4092bf22..6d1caed02733 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -702,7 +702,7 @@ static int obd_import_flags2str(struct obd_import *imp, struct seq_file *m)
 	bool first = true;
 
 	if (imp->imp_obd->obd_no_recov) {
-		seq_printf(m, "no_recov");
+		seq_puts(m, "no_recov");
 		first = false;
 	}
 
@@ -768,15 +768,15 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
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
@@ -909,7 +909,7 @@ int lprocfs_rd_state(struct seq_file *m, void *data)
 
 	seq_printf(m, "current_state: %s\n",
 		   ptlrpc_import_state_name(imp->imp_state));
-	seq_printf(m, "state_history:\n");
+	seq_puts(m, "state_history:\n");
 	k = imp->imp_state_hist_idx;
 	for (j = 0; j < IMP_STATE_HIST_LEN; j++) {
 		struct import_state_hist *ish =
@@ -931,7 +931,7 @@ int lprocfs_at_hist_helper(struct seq_file *m, struct adaptive_timeout *at)
 
 	for (i = 0; i < AT_BINS; i++)
 		seq_printf(m, "%3u ", at->at_hist[i]);
-	seq_printf(m, "\n");
+	seq_puts(m, "\n");
 	return 0;
 }
 EXPORT_SYMBOL(lprocfs_at_hist_helper);
@@ -999,7 +999,7 @@ int lprocfs_rd_connect_flags(struct seq_file *m, void *data)
 	flags = obd->u.cli.cl_import->imp_connect_data.ocd_connect_flags;
 	seq_printf(m, "flags=%#llx\n", flags);
 	obd_connect_seq_flags2str(m, flags, "\n");
-	seq_printf(m, "\n");
+	seq_puts(m, "\n");
 	up_read(&obd->u.cli.cl_sem);
 	return 0;
 }
-- 
2.13.0
