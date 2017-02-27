From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:58 -0500
Subject: [lustre-devel] [PATCH 33/34] staging: lustre: lnet: remove unused
	lnet_md_iovec_t
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-34-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

The typedef lnet_md_iovec_t is never used so kill it
off.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/types.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 7d39496..44cee82 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -510,9 +510,6 @@ struct lnet_md {
 /** Infinite threshold on MD operations. See lnet_md::threshold */
 #define LNET_MD_THRESH_INF	(-1)
 
-/* NB lustre portals uses struct iovec internally! */
-typedef struct iovec lnet_md_iovec_t;
-
 typedef struct bio_vec lnet_kiov_t;
 /** @} lnet_md */
 
-- 
1.8.3.1
