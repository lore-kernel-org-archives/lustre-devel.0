From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 10 Feb 2016 13:00:20 -0500
Subject: [lustre-devel] [PATCH 3/5] staging/lustre: Adjust import state
	history output format
In-Reply-To: <1455127222-2557752-1-git-send-email-green@linuxhacker.ru>
References: <1455127222-2557752-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455127222-2557752-4-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

New test scripts expect spaces around state names and square brackets
when parsing debugfs output, so add them to avoid false failures.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/obdclass/lprocfs_status.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 9a1434d..eda44d8 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -642,21 +642,21 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 		     "    target: %s\n"
 		     "    state: %s\n"
 		     "    instance: %u\n"
-		     "    connect_flags: [",
+		     "    connect_flags: [ ",
 		     obd->obd_name,
 		     obd2cli_tgt(obd),
 		     ptlrpc_import_state_name(imp->imp_state),
 		     imp->imp_connect_data.ocd_instance);
 	obd_connect_seq_flags2str(m, imp->imp_connect_data.ocd_connect_flags, ", ");
 	seq_printf(m,
-		      "]\n"
-		      "    import_flags: [");
+		      " ]\n"
+		      "    import_flags: [ ");
 	obd_import_flags2str(imp, m);
 
 	seq_printf(m,
-		      "]\n"
+		      " ]\n"
 		      "    connection:\n"
-		      "       failover_nids: [");
+		      "       failover_nids: [ ");
 	spin_lock(&imp->imp_lock);
 	j = 0;
 	list_for_each_entry(conn, &imp->imp_conn_list, oic_item) {
@@ -671,7 +671,7 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 	else
 		strncpy(nidstr, "<none>", sizeof(nidstr));
 	seq_printf(m,
-		      "]\n"
+		      " ]\n"
 		      "       current_connection: %s\n"
 		      "       connection_attempts: %u\n"
 		      "       generation: %u\n"
@@ -795,7 +795,7 @@ int lprocfs_rd_state(struct seq_file *m, void *data)
 			&imp->imp_state_hist[(k + j) % IMP_STATE_HIST_LEN];
 		if (ish->ish_state == 0)
 			continue;
-		seq_printf(m, " - [%lld, %s]\n", (s64)ish->ish_time,
+		seq_printf(m, " - [ %lld, %s ]\n", (s64)ish->ish_time,
 			   ptlrpc_import_state_name(ish->ish_state));
 	}
 
-- 
2.1.0
