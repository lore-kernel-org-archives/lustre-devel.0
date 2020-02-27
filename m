From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:56 -0500
Subject: [lustre-devel] [PATCH 308/622] lnet: libcfs: crashes with certain
 cpu part numbers
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-309-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andrew Perepechko <c17827@cray.com>

Due to a bug in the code, libcfs will crash if the
number of online cpus does not divide by the number
of cpu partitions.

Based on the checks in cfs_cpt_table_create(), it
appears that the original intent was to push the
remaining cpus into the initial partitions.

So let's do that properly.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12352
Lustre-commit: e33e3da58972 ("LU-12352 libcfs: crashes with certain cpu part numbers")
Signed-off-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Alexander Boyko <c17825@cray.com>
Reviewed-by: Alexander Zarochentsev <c17826@cray.com>
Cray-bug-id: LUS-6455
Reviewed-on: https://review.whamcloud.com/34991
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/libcfs_cpu.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/lnet/libcfs/libcfs_cpu.c b/net/lnet/libcfs/libcfs_cpu.c
index 80533c2..20ca15a 100644
--- a/net/lnet/libcfs/libcfs_cpu.c
+++ b/net/lnet/libcfs/libcfs_cpu.c
@@ -913,7 +913,7 @@ static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
 			int ncpu = cpumask_weight(part->cpt_cpumask);
 
 			rc = cfs_cpt_choose_ncpus(cptab, cpt, node_mask,
-						  num - ncpu);
+						  (rem > 0) + num - ncpu);
 			if (rc < 0) {
 				rc = -EINVAL;
 				goto failed_mask;
-- 
1.8.3.1
