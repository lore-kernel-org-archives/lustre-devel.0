From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:47:09 -0500
Subject: [lustre-devel] [PATCH 37/45] staging/lustre/libcfs: Remove useless
	returns in void functions
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-38-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Return at the end of a void function does not serve any particular
purpose and makes checkpatch unhappy, so eliminate them.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c       | 2 --
 drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.c    | 2 --
 drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c | 2 --
 drivers/staging/lustre/lustre/libcfs/workitem.c              | 3 ---
 4 files changed, 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c
index 8d6a4ee..6c3e448 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c
@@ -354,8 +354,6 @@ cfs_cpt_unset_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
 
 	if (i >= nr_cpu_ids)
 		node_clear(node, *cptab->ctb_nodemask);
-
-	return;
 }
 EXPORT_SYMBOL(cfs_cpt_unset_cpu);
 
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.c
index 44d1ad6..140134d 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.c
@@ -286,6 +286,4 @@ void cfs_crypto_unregister(void)
 {
 	if (adler32 == 0)
 		cfs_crypto_adler32_unregister();
-
-	return;
 }
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
index c50e24f..f0880a0 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
@@ -198,7 +198,6 @@ cfs_set_ptldebug_header(struct ptldebug_header *header,
 	header->ph_pid = current->pid;
 	header->ph_line_num = msgdata->msg_line;
 	header->ph_extern_pid = 0;
-	return;
 }
 
 static char *
@@ -252,7 +251,6 @@ void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
 		       hdr->ph_pid, hdr->ph_extern_pid, file, hdr->ph_line_num,
 		       fn, len, buf);
 	}
-	return;
 }
 
 int cfs_trace_max_debug_mb(void)
diff --git a/drivers/staging/lustre/lustre/libcfs/workitem.c b/drivers/staging/lustre/lustre/libcfs/workitem.c
index 08c5b19..136bc13 100644
--- a/drivers/staging/lustre/lustre/libcfs/workitem.c
+++ b/drivers/staging/lustre/lustre/libcfs/workitem.c
@@ -131,8 +131,6 @@ cfs_wi_exit(struct cfs_wi_sched *sched, cfs_workitem_t *wi)
 
 	wi->wi_scheduled = 1; /* LBUG future schedule attempts */
 	spin_unlock(&sched->ws_lock);
-
-	return;
 }
 EXPORT_SYMBOL(cfs_wi_exit);
 
@@ -203,7 +201,6 @@ cfs_wi_schedule(struct cfs_wi_sched *sched, cfs_workitem_t *wi)
 
 	LASSERT(!list_empty(&wi->wi_list));
 	spin_unlock(&sched->ws_lock);
-	return;
 }
 EXPORT_SYMBOL(cfs_wi_schedule);
 
-- 
2.1.0
