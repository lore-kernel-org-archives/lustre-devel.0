From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:09:48 -0400
Subject: [lustre-devel] [PATCH 06/25] staging: lustre: libcfs: replace
 num_possible_cpus() with nr_cpu_ids
In-Reply-To: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523851807-16573-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Amir Shehata <amir.shehata@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Amir Shehata <amir.shehata@intel.com>

Move from num_possible_cpus() to nr_cpu_ids.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7734
Reviewed-on: http://review.whamcloud.com/18916
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index b2a88ef..741db69 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -105,14 +105,14 @@ struct cfs_cpt_table *
 	    !cptab->ctb_nodemask)
 		goto failed;
 
-	cptab->ctb_cpu2cpt = kvmalloc_array(num_possible_cpus(),
+	cptab->ctb_cpu2cpt = kvmalloc_array(nr_cpu_ids,
 					    sizeof(cptab->ctb_cpu2cpt[0]),
 					    GFP_KERNEL);
 	if (!cptab->ctb_cpu2cpt)
 		goto failed;
 
 	memset(cptab->ctb_cpu2cpt, -1,
-	       num_possible_cpus() * sizeof(cptab->ctb_cpu2cpt[0]));
+	       nr_cpu_ids * sizeof(cptab->ctb_cpu2cpt[0]));
 
 	cptab->ctb_parts = kvmalloc_array(ncpt, sizeof(cptab->ctb_parts[0]),
 					  GFP_KERNEL);
-- 
1.8.3.1
