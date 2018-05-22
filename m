From: Ivan Bornyakov <brnkv.i1@gmail.com>
Date: Tue, 22 May 2018 16:34:39 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: libcfs: add parens around
 macros args
Message-ID: <20180522133439.12338-1-brnkv.i1@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org
Cc: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Ivan Bornyakov <brnkv.i1@gmail.com>

One may call 'CFS_FAIL_TIMEOUT(id, secs + 5);' and get unexpected result
after macro substitution, viz., 'secs + 5' will turn into
'secs + 5 * 1000'

Signed-off-by: Ivan Bornyakov <brnkv.i1@gmail.com>
---
 drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
index d6fc3164e7e7..f96b9a51554d 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
@@ -140,7 +140,7 @@ static inline int cfs_fail_timeout_set(u32 id, u32 value, int ms, int set)
 
 /* If id hit cfs_fail_loc, sleep for seconds or milliseconds */
 #define CFS_FAIL_TIMEOUT(id, secs) \
-	cfs_fail_timeout_set(id, 0, secs * 1000, CFS_FAIL_LOC_NOSET)
+	cfs_fail_timeout_set(id, 0, (secs) * 1000, CFS_FAIL_LOC_NOSET)
 
 #define CFS_FAIL_TIMEOUT_MS(id, ms) \
 	cfs_fail_timeout_set(id, 0, ms, CFS_FAIL_LOC_NOSET)
@@ -150,10 +150,10 @@ static inline int cfs_fail_timeout_set(u32 id, u32 value, int ms, int set)
  * sleep seconds or milliseconds
  */
 #define CFS_FAIL_TIMEOUT_ORSET(id, value, secs) \
-	cfs_fail_timeout_set(id, value, secs * 1000, CFS_FAIL_LOC_ORSET)
+	cfs_fail_timeout_set(id, value, (secs) * 1000, CFS_FAIL_LOC_ORSET)
 
 #define CFS_FAIL_TIMEOUT_RESET(id, value, secs) \
-	cfs_fail_timeout_set(id, value, secs * 1000, CFS_FAIL_LOC_RESET)
+	cfs_fail_timeout_set(id, value, (secs) * 1000, CFS_FAIL_LOC_RESET)
 
 #define CFS_FAIL_TIMEOUT_MS_ORSET(id, value, ms) \
 	cfs_fail_timeout_set(id, value, ms, CFS_FAIL_LOC_ORSET)
-- 
2.16.1
