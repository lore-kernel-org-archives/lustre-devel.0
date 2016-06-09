From: James Simmons <jsimmons@infradead.org>
Date: Thu,  9 Jun 2016 18:45:47 -0400
Subject: [lustre-devel] [PATCH 3/3] staging: lustre: lnet: optimize memory
	foot print for lnet_libmd
In-Reply-To: <1465512347-11650-1-git-send-email-jsimmons@infradead.org>
References: <1465512347-11650-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1465512347-11650-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bruno Faccini <bruno.faccini@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bruno Faccini <bruno.faccini@intel.com>

The lnet_libmd struct fields have been re-ordered to optimize its
memory foot-print.

Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4430
Reviewed-on: http://review.whamcloud.com/18586
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 7967b01..79a4ecf 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -151,9 +151,9 @@ typedef struct lnet_libmd {
 	int			 md_refcount;
 	unsigned int		 md_options;
 	unsigned int		 md_flags;
+	unsigned int		 md_niov;	/* # frags at end of struct */
 	void			*md_user_ptr;
 	lnet_eq_t		*md_eq;
-	unsigned int		 md_niov;	/* # frags */
 	union {
 		struct kvec	iov[LNET_MAX_IOV];
 		lnet_kiov_t	kiov[LNET_MAX_IOV];
-- 
1.7.1
