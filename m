From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:42 -0500
Subject: [lustre-devel] [PATCH 294/622] lnet: libcfs: fix panic for too
 large cpu partitions
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-295-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

If cpu partitions larger than online cpus, following calcuation
will be 0:

num = num_online_cpus() / ncpt;

And it will trigger following panic in cfs_cpt_choose_ncpus()

        LASSERT(number > 0);

We actually did not support this, instead of panic
it, return failure is better.

Also fix a invalid pointer access if we failed to init @cfs_cpt_table,
as it will be converted to ERR_PTR() if error happen.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12299
Lustre-commit: 77771ff24c03 ("LU-12299 libcfs: fix panic for too large cpu partions")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/34864
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/libcfs_cpu.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/lnet/libcfs/libcfs_cpu.c b/net/lnet/libcfs/libcfs_cpu.c
index 3e566ac..80533c2 100644
--- a/net/lnet/libcfs/libcfs_cpu.c
+++ b/net/lnet/libcfs/libcfs_cpu.c
@@ -878,7 +878,14 @@ static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
 	if (ncpt <= 0)
 		ncpt = num;
 
-	if (ncpt > num_online_cpus() || ncpt > 4 * num) {
+	if (ncpt > num_online_cpus()) {
+		rc = -EINVAL;
+		CERROR("libcfs: CPU partition count %d > cores %d: rc = %d\n",
+		       ncpt, num_online_cpus(), rc);
+		goto failed;
+	}
+
+	if (ncpt > 4 * num) {
 		CWARN("CPU partition number %d is larger than suggested value (%d), your system may have performance issue or run out of memory while under pressure\n",
 		      ncpt, num);
 	}
-- 
1.8.3.1
