From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:19 -0500
Subject: [lustre-devel] [PATCH 12/22] staging: lustre: libcfs: report hnode
	value for cfs_hash_putref
In-Reply-To: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480726409-20350-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Yang Sheng <yang.sheng@intel.com>, James Simmons <jsimmons@infradead.org>

From: Yang Sheng <yang.sheng@intel.com>

Add more debugging info.

Signed-off-by: Yang Sheng <yang.sheng@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7084
Reviewed-on: http://review.whamcloud.com/17673
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/hash.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index b90dfb9..c93c59d 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -1215,7 +1215,7 @@ void cfs_hash_putref(struct cfs_hash *hs)
 	struct cfs_hash_bd bds[2];
 	int bits = 0;
 
-	LASSERT(hlist_unhashed(hnode));
+	LASSERTF(hlist_unhashed(hnode), "hnode = %p\n", hnode);
 
 	cfs_hash_lock(hs, 0);
 	cfs_hash_dual_bd_get_and_lock(hs, key, bds, 1);
-- 
1.7.1
