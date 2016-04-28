From: James Simmons <jsimmons@infradead.org>
Date: Thu, 28 Apr 2016 12:07:37 -0400
Subject: [lustre-devel] [PATCH 7/8] staging: lustre: debugfs: improve
	osc/mdc "imports" connect data
In-Reply-To: <1461859658-22200-1-git-send-email-jsimmons@infradead.org>
References: <1461859658-22200-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461859658-22200-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Emoly Liu <emoly.liu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Emoly Liu <emoly.liu@intel.com>

Improve /sys/debug/fs/lustre/{osc,mdc}/*/import files to print
the struct obd_connect_data data fields as "connect_data:"
in addition to the "connect_flags:" field.

Signed-off-by: Emoly Liu <emoly.liu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3386
Reviewed-on: http://review.whamcloud.com/6588
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/obdclass/lprocfs_status.c        | 63 +++++++++++++++++++---
 1 file changed, 57 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index b2f309d..5a1eae1 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -49,7 +49,7 @@
 static const char * const obd_connect_names[] = {
 	"read_only",
 	"lov_index",
-	"unused",
+	"connect_from_mds",
 	"write_grant",
 	"server_lock",
 	"version",
@@ -122,6 +122,56 @@ int obd_connect_flags2str(char *page, int count, __u64 flags, char *sep)
 }
 EXPORT_SYMBOL(obd_connect_flags2str);
 
+static void obd_connect_data_seqprint(struct seq_file *m,
+				      struct obd_connect_data *ocd)
+{
+	int flags;
+
+	LASSERT(ocd);
+	flags = ocd->ocd_connect_flags;
+
+	seq_printf(m, "    connect_data:\n"
+		   "       flags: %llx\n"
+		   "       instance: %u\n",
+		   ocd->ocd_connect_flags,
+		   ocd->ocd_instance);
+	if (flags & OBD_CONNECT_VERSION)
+		seq_printf(m, "       target_version: %u.%u.%u.%u\n",
+			   OBD_OCD_VERSION_MAJOR(ocd->ocd_version),
+			   OBD_OCD_VERSION_MINOR(ocd->ocd_version),
+			   OBD_OCD_VERSION_PATCH(ocd->ocd_version),
+			   OBD_OCD_VERSION_FIX(ocd->ocd_version));
+	if (flags & OBD_CONNECT_MDS)
+		seq_printf(m, "       mdt_index: %d\n", ocd->ocd_group);
+	if (flags & OBD_CONNECT_GRANT)
+		seq_printf(m, "       initial_grant: %d\n", ocd->ocd_grant);
+	if (flags & OBD_CONNECT_INDEX)
+		seq_printf(m, "       target_index: %u\n", ocd->ocd_index);
+	if (flags & OBD_CONNECT_BRW_SIZE)
+		seq_printf(m, "       max_brw_size: %d\n", ocd->ocd_brw_size);
+	if (flags & OBD_CONNECT_IBITS)
+		seq_printf(m, "       ibits_known: %llx\n",
+			   ocd->ocd_ibits_known);
+	if (flags & OBD_CONNECT_GRANT_PARAM)
+		seq_printf(m, "       grant_block_size: %d\n"
+			   "       grant_inode_size: %d\n"
+			   "       grant_extent_overhead: %d\n",
+			   ocd->ocd_blocksize,
+			   ocd->ocd_inodespace,
+			   ocd->ocd_grant_extent);
+	if (flags & OBD_CONNECT_TRANSNO)
+		seq_printf(m, "       first_transno: %llx\n",
+			   ocd->ocd_transno);
+	if (flags & OBD_CONNECT_CKSUM)
+		seq_printf(m, "       cksum_types: %#x\n",
+			   ocd->ocd_cksum_types);
+	if (flags & OBD_CONNECT_MAX_EASIZE)
+		seq_printf(m, "       max_easize: %d\n", ocd->ocd_max_easize);
+	if (flags & OBD_CONNECT_MAXBYTES)
+		seq_printf(m, "       max_object_bytes: %llx\n",
+			   ocd->ocd_maxbytes);
+}
+
 int lprocfs_read_frac_helper(char *buffer, unsigned long count, long val,
 			     int mult)
 {
@@ -624,6 +674,7 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 	struct obd_device		*obd	= data;
 	struct obd_import		*imp;
 	struct obd_import_conn		*conn;
+	struct obd_connect_data *ocd;
 	int				j;
 	int				k;
 	int				rw	= 0;
@@ -635,9 +686,9 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 		return rc;
 
 	imp = obd->u.cli.cl_import;
+	ocd = &imp->imp_connect_data;
 
-	seq_printf(m,
-		   "import:\n"
+	seq_printf(m, "import:\n"
 		   "    name: %s\n"
 		   "    target: %s\n"
 		   "    state: %s\n"
@@ -649,9 +700,9 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 		   imp->imp_connect_data.ocd_instance);
 	obd_connect_seq_flags2str(m, imp->imp_connect_data.ocd_connect_flags,
 				  ", ");
-	seq_printf(m,
-		   " ]\n"
-		   "    import_flags: [ ");
+	seq_printf(m, " ]\n");
+	obd_connect_data_seqprint(m, ocd);
+	seq_printf(m, "    import_flags: [ ");
 	obd_import_flags2str(imp, m);
 
 	seq_printf(m,
-- 
2.7.4
