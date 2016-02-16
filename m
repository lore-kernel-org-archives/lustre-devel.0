From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:47:13 -0500
Subject: [lustre-devel] [PATCH 41/45] staging/lustre/libcfs: Get rid of
	multiple assignments
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-42-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

They make checkpatch unhappy, and I guess overall might confuse
people too.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/libcfs/libcfs_mem.c    | 7 ++++---
 drivers/staging/lustre/lustre/libcfs/libcfs_string.c | 6 ++++--
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_mem.c b/drivers/staging/lustre/lustre/libcfs/libcfs_mem.c
index 7396d66..c5a6951 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_mem.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_mem.c
@@ -82,9 +82,10 @@ cfs_percpt_alloc(struct cfs_cpt_table *cptab, unsigned int size)
 	if (!arr)
 		return NULL;
 
-	arr->va_size	= size = L1_CACHE_ALIGN(size);
-	arr->va_count	= count;
-	arr->va_cptab	= cptab;
+	size = L1_CACHE_ALIGN(size);
+	arr->va_size = size;
+	arr->va_count = count;
+	arr->va_cptab = cptab;
 
 	for (i = 0; i < count; i++) {
 		LIBCFS_CPT_ALLOC(arr->va_ptrs[i], cptab, i, size);
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
index 4a2c83b..09ab0e4 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
@@ -337,8 +337,10 @@ cfs_range_expr_print(char *buffer, int count, struct cfs_range_expr *expr,
 	char s[] = "[";
 	char e[] = "]";
 
-	if (bracketed)
-		s[0] = e[0] = '\0';
+	if (bracketed) {
+		s[0] = '\0';
+		e[0] = '\0';
+	}
 
 	if (expr->re_lo == expr->re_hi)
 		i = scnprintf(buffer, count, "%u", expr->re_lo);
-- 
2.1.0
