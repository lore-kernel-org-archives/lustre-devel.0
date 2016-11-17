From: James Simmons <jsimmons@infradead.org>
Date: Thu, 17 Nov 2016 14:35:54 -0500
Subject: [lustre-devel] [PATCH 16/19] staging: lustre: libcfs: use pr_*
	instead of printk
In-Reply-To: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
References: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479411357-28979-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Checkpatch recommended that we use pr_*() instead
of printk directly.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lnet/libcfs/linux/linux-tracefile.c     |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
index a3cabb9..75eb84e 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
@@ -85,7 +85,7 @@ int cfs_tracefile_init_arch(void)
 
 out:
 	cfs_tracefile_fini_arch();
-	printk(KERN_ERR "lnet: Not enough memory\n");
+	pr_err("lnet: Not enough memory\n");
 	return -ENOMEM;
 }
 
@@ -239,11 +239,11 @@ void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
 	}
 
 	if (mask & D_CONSOLE) {
-		printk("%s%s: %.*s", ptype, prefix, len, buf);
+		pr_info("%s%s: %.*s", ptype, prefix, len, buf);
 	} else {
-		printk("%s%s: %d:%d:(%s:%d:%s()) %.*s", ptype, prefix,
-		       hdr->ph_pid, hdr->ph_extern_pid, file, hdr->ph_line_num,
-		       fn, len, buf);
+		pr_info("%s%s: %d:%d:(%s:%d:%s()) %.*s", ptype, prefix,
+			hdr->ph_pid, hdr->ph_extern_pid, file,
+			hdr->ph_line_num, fn, len, buf);
 	}
 }
 
-- 
1.7.1
