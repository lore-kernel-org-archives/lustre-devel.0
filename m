From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 1 Jan 2017 17:37:04 +0100
Subject: [lustre-devel] [PATCH 3/5] staging/lustre/obdclass: Use seq_putc()
	in four functions
In-Reply-To: <45ae8939-a775-865b-ade0-9e38a7ff2b5d@users.sourceforge.net>
References: <45ae8939-a775-865b-ade0-9e38a7ff2b5d@users.sourceforge.net>
Message-ID: <c88fdadd-bdef-7e7f-7704-487587693838@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Andreas Dilger <andreas.dilger@intel.com>, Ben Evans <bevans@cray.com>, Bobi Jam <bobijam.xu@intel.com>, Emoly Liu <emoly.liu@intel.com>, Fan Yong <fan.yong@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Gregoire Pichon <gregoire.pichon@bull.net>, Henri Doreau <henri.doreau@cea.fr>, James Simmons <jsimmons@infradead.org>, Jinshan Xiong <jinshan.xiong@intel.com>, "John L. Hammond" <john.hammond@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Lai Siyao <lai.siyao@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Sebastien Buisson <sbuisson@ddn.com>, Stephen Champion <schamp@sgi.com>, wang di <di.wang@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 1 Jan 2017 16:12:23 +0100

A few single characters (line breaks) should be put into a sequence.
Thus use the corresponding function "seq_putc".

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/lustre/lustre/obdclass/cl_object.c      | 4 ++--
 drivers/staging/lustre/lustre/obdclass/lprocfs_status.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index f5d4e23c64b7..277908d66a89 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -441,7 +441,7 @@ static int cache_stats_print(const struct cache_stats *cs,
 		seq_printf(m, "%6s", " ");
 		for (i = 0; i < CS_NR; i++)
 			seq_printf(m, "%8s", names[i]);
-		seq_printf(m, "\n");
+		seq_putc(m, '\n');
 	}
 
 	seq_printf(m, "%5.5s:", cs->cs_name);
@@ -516,7 +516,7 @@ locks: ...... ...... ...... ...... ...... [...... ...... ...... ...... ......]
 			   atomic_read(&site->cs_pages_state[i]));
 	seq_printf(m, "]\n");
 	cache_stats_print(&cl_env_stats, m, 0);
-	seq_printf(m, "\n");
+	seq_putc(m, '\n');
 	return 0;
 }
 EXPORT_SYMBOL(cl_site_stats_print);
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 2c99717b0aba..3f6fcab5a1fc 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -878,7 +878,7 @@ int lprocfs_at_hist_helper(struct seq_file *m, struct adaptive_timeout *at)
 
 	for (i = 0; i < AT_BINS; i++)
 		seq_printf(m, "%3u ", at->at_hist[i]);
-	seq_printf(m, "\n");
+	seq_putc(m, '\n');
 	return 0;
 }
 EXPORT_SYMBOL(lprocfs_at_hist_helper);
@@ -946,7 +946,7 @@ int lprocfs_rd_connect_flags(struct seq_file *m, void *data)
 	flags = obd->u.cli.cl_import->imp_connect_data.ocd_connect_flags;
 	seq_printf(m, "flags=%#llx\n", flags);
 	obd_connect_seq_flags2str(m, flags, "\n");
-	seq_printf(m, "\n");
+	seq_putc(m, '\n');
 	up_read(&obd->u.cli.cl_sem);
 	return 0;
 }
-- 
2.11.0
