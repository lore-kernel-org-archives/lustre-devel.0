From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:17 -0500
Subject: [lustre-devel] [PATCH 10/22] staging: lustre: obdclass: limit
	lu_site hash table size on clients
In-Reply-To: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480726409-20350-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Li Dongyang <dongyang.li@anu.edu.au>, James Simmons <jsimmons@infradead.org>

From: Li Dongyang <dongyang.li@anu.edu.au>

Allocating a big hash table using the current formula
does not really work for clients. We will create new
hash table for each mount on a single client which is
a lot of memory more than expected.

This patch limits the hash table up to 8M for clients,
which has 524288 entries.

Signed-off-by: Li Dongyang <dongyang.li@anu.edu.au>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7689
Reviewed-on: http://review.whamcloud.com/18048
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index a02aaa3..80e0984 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -68,6 +68,7 @@ enum {
 
 #define LU_SITE_BITS_MIN	12
 #define LU_SITE_BITS_MAX	24
+#define LU_SITE_BITS_MAX_CL	19
 /**
  * total 256 buckets, we don't want too many buckets because:
  * - consume too much memory
@@ -878,6 +879,9 @@ static unsigned long lu_htable_order(struct lu_device *top)
 	unsigned long cache_size;
 	unsigned long bits;
 
+	if (!strcmp(top->ld_type->ldt_name, LUSTRE_VVP_NAME))
+		bits_max = LU_SITE_BITS_MAX_CL;
+
 	/*
 	 * Calculate hash table size, assuming that we want reasonable
 	 * performance when 20% of total memory is occupied by cache of
-- 
1.7.1
