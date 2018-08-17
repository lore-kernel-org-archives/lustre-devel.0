From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:36 -0400
Subject: [lustre-devel] [PATCH 33/38] lustre: osc: make unstable_stats a
 debugfs file
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-34-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The sysfs attribute unstable_stats breaks the one item per file
rule. Make it a debugfs file instead.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/lproc_osc.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 5fb7a16..79a30b3 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -614,12 +614,9 @@ static ssize_t max_pages_per_rpc_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(max_pages_per_rpc);
 
-static ssize_t unstable_stats_show(struct kobject *kobj,
-				   struct attribute *attr,
-				   char *buf)
+static int osc_unstable_stats_seq_show(struct seq_file *m, void *v)
 {
-	struct obd_device *dev = container_of(kobj, struct obd_device,
-					      obd_kset.kobj);
+	struct obd_device *dev = m->private;
 	struct client_obd *cli = &dev->u.cli;
 	long pages;
 	int mb;
@@ -627,10 +624,14 @@ static ssize_t unstable_stats_show(struct kobject *kobj,
 	pages = atomic_long_read(&cli->cl_unstable_count);
 	mb = (pages * PAGE_SIZE) >> 20;
 
-	return sprintf(buf, "unstable_pages: %20ld\n"
-		       "unstable_mb:              %10d\n", pages, mb);
+	seq_printf(m,
+		   "unstable_pages: %20ld\n"
+		   "unstable_mb:              %10d\n",
+		   pages, mb);
+	return 0;
 }
-LUSTRE_RO_ATTR(unstable_stats);
+
+LPROC_SEQ_FOPS_RO(osc_unstable_stats);
 
 LPROC_SEQ_FOPS_RO_TYPE(osc, connect_flags);
 LPROC_SEQ_FOPS_RO_TYPE(osc, server_uuid);
@@ -655,6 +656,8 @@ static ssize_t unstable_stats_show(struct kobject *kobj,
 	{ "import",		&osc_import_fops, NULL },
 	{ "state",		&osc_state_fops, NULL, 0 },
 	{ "pinger_recov",	&osc_pinger_recov_fops, NULL },
+	{ .name	=	"unstable_stats",
+	  .fops	=	&osc_unstable_stats_fops	},
 	{ NULL }
 };
 
@@ -837,7 +840,6 @@ void lproc_osc_attach_seqstat(struct obd_device *dev)
 	&lustre_attr_max_pages_per_rpc.attr,
 	&lustre_attr_max_rpcs_in_flight.attr,
 	&lustre_attr_resend_count.attr,
-	&lustre_attr_unstable_stats.attr,
 	NULL,
 };
 
-- 
1.8.3.1
