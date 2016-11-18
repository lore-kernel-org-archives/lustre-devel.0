From: James Simmons <jsimmons@infradead.org>
Date: Fri, 18 Nov 2016 11:48:41 -0500
Subject: [lustre-devel] [PATCH 07/10] staging: lustre: libcfs: remove
	whitespace in libcfs_fail.h
In-Reply-To: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
References: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479487724-20386-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

One last white space is still left in libcfs_fail.h. Lets
remove it.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_fail.h      |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
index 6f019a4..73cbb47 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
@@ -73,7 +73,7 @@ static inline bool CFS_FAIL_PRECHECK(__u32 id)
 {
 	return cfs_fail_loc != 0 &&
 	       ((cfs_fail_loc & CFS_FAIL_MASK_LOC) == (id & CFS_FAIL_MASK_LOC) ||
-	        (cfs_fail_loc & id & CFS_FAULT));
+		(cfs_fail_loc & id & CFS_FAULT));
 }
 
 static inline int cfs_fail_check_set(__u32 id, __u32 value,
-- 
1.7.1
