From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:01:50 -0500
Subject: [lustre-devel] [PATCH 07/27] staging: lustre: issue in the offset
	in lnet match hash table
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Alyona Romanenko <alyona.romanenko@seagate.com>

From: Alyona Romanenko <alyona.romanenko@seagate.com>

the offset in hash table is overflowed for no wildcard portal.
The offset for no wildcard has been corrected as for wildcard
in the LU-1622

Signed-off-by: Alyona Romanenko <alyona.romanenko@seagate.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7774
Reviewed-on: http://review.whamcloud.com/18422
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/lib-ptl.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index 2b41205..3947e8b 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -360,16 +360,15 @@ lnet_mt_match_head(struct lnet_match_table *mtable,
 		   lnet_process_id_t id, __u64 mbits)
 {
 	struct lnet_portal *ptl = the_lnet.ln_portals[mtable->mt_portal];
+	unsigned long hash = mbits;
 
-	if (lnet_ptl_is_wildcard(ptl)) {
-		return &mtable->mt_mhash[mbits & LNET_MT_HASH_MASK];
-	} else {
-		unsigned long hash = mbits + id.nid + id.pid;
+	if (!lnet_ptl_is_wildcard(ptl)) {
+		hash += id.nid + id.pid;
 
 		LASSERT(lnet_ptl_is_unique(ptl));
 		hash = hash_long(hash, LNET_MT_HASH_BITS);
-		return &mtable->mt_mhash[hash];
 	}
+	return &mtable->mt_mhash[hash & LNET_MT_HASH_MASK];
 }
 
 int
-- 
1.7.1
