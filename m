From: James Simmons <jsimmons@infradead.org>
Date: Fri, 18 Nov 2016 11:48:38 -0500
Subject: [lustre-devel] [PATCH 04/10] staging: lustre: libcfs: remove blank
	line in header
In-Reply-To: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
References: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479487724-20386-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The header libcfs_fail.h has a extra blank line that
is not needed.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_fail.h      |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
index b1658c8..f06b4aa 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
@@ -168,7 +168,6 @@ static inline int cfs_fail_timeout_set(__u32 id, __u32 value, int ms, int set)
  */
 static inline void cfs_race(__u32 id)
 {
-
 	if (CFS_FAIL_PRECHECK(id)) {
 		if (unlikely(__cfs_fail_check_set(id, 0, CFS_FAIL_LOC_NOSET))) {
 			int rc;
-- 
1.7.1
