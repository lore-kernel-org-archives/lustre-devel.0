From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:47:33 -0400
Subject: [lustre-devel] [PATCH 01/43] staging/lustre/obdclass: limit lu_site
	hash table size
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-2-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>, Li Dongyang <dongyang.li@anu.edu.au>

From: Oleg Drokin <green@linuxhacker.ru>

Allocating a big hash table using the formula for osd
does not really work for clients. We will create new
hash table for each mount on a single client which is
a lot of memory more than expected.

This patch limits the hash table up to 8M which has
524288 entries

Signed-off-by: Li Dongyang <dongyang.li@anu.edu.au>
Reviewed-on: http://review.whamcloud.com/18048
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7689
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/obdclass/lu_object.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 65a4746..69fdcee 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -935,7 +935,7 @@ static void lu_dev_add_linkage(struct lu_site *s, struct lu_device *d)
  * Initialize site \a s, with \a d as the top level device.
  */
 #define LU_SITE_BITS_MIN    12
-#define LU_SITE_BITS_MAX    24
+#define LU_SITE_BITS_MAX    19
 /**
  * total 256 buckets, we don't want too many buckets because:
  * - consume too much memory
-- 
2.1.0
