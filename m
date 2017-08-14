From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:46:59 -0400
Subject: [lustre-devel] [PATCH 31/64] staging: lustre: libcfs: remove htonl
	hack in libcfs.h
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-32-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

This is really old hack for earlier gcc version that
had a hard time compiling byteorder.h. Lets remove it.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: https://review.whamcloud.com/22138
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/libcfs/libcfs_private.h | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index e774c75..005713b 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -154,18 +154,6 @@
 
 /******************************************************************************/
 
-/* htonl hack - either this, or compile with -O2. Stupid byteorder/generic.h */
-#if defined(__GNUC__) && (__GNUC__ >= 2) && !defined(__OPTIMIZE__)
-#define ___htonl(x) __cpu_to_be32(x)
-#define ___htons(x) __cpu_to_be16(x)
-#define ___ntohl(x) __be32_to_cpu(x)
-#define ___ntohs(x) __be16_to_cpu(x)
-#define htonl(x) ___htonl(x)
-#define ntohl(x) ___ntohl(x)
-#define htons(x) ___htons(x)
-#define ntohs(x) ___ntohs(x)
-#endif
-
 void libcfs_debug_dumplog(void);
 int libcfs_debug_init(unsigned long bufsize);
 int libcfs_debug_cleanup(void);
-- 
1.8.3.1
