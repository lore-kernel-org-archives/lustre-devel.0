From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:01 -0500
Subject: [lustre-devel] [PATCH 33/60] staging: lustre: libcfs: avoid
	stomping on module param cpu_pattern
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-34-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, Liang Zhen <liang.zhen@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

The function cfs_cpt_table_create_pattern() alters the string
passed to it. Currently we are passing in the module parameter
string cpu_pattern which is incorrect. Instead lets duplicate
the module parameter string and pass that to the function
cfs_cpt_table_create_pattern().

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5050
Reviewed-on: http://review.whamcloud.com/22377
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index 427e219..71a5b19 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -1050,7 +1050,15 @@ static int cfs_cpu_dead(unsigned int cpu)
 	ret = -EINVAL;
 
 	if (*cpu_pattern) {
-		cfs_cpt_table = cfs_cpt_table_create_pattern(cpu_pattern);
+		char *cpu_pattern_dup = kstrdup(cpu_pattern, GFP_KERNEL);
+
+		if (!cpu_pattern_dup) {
+			CERROR("Failed to duplicate cpu_pattern\n");
+			goto failed;
+		}
+
+		cfs_cpt_table = cfs_cpt_table_create_pattern(cpu_pattern_dup);
+		kfree(cpu_pattern_dup);
 		if (!cfs_cpt_table) {
 			CERROR("Failed to create cptab from pattern %s\n",
 			       cpu_pattern);
-- 
1.8.3.1
