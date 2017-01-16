From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:24 -0500
Subject: [lustre-devel] [PATCH 21/34] staging: lustre: lnet: change
	lstio_batch_del_args_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstio_batch_del_args_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24188
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lnetst.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index 41cbe3a..c01931c 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -360,11 +360,11 @@ struct lstio_batch_add_args {
 	char __user *lstio_bat_namep;	/* IN: batch name */
 };
 
-typedef struct {
+struct lstio_batch_del_args {
 	int	 lstio_bat_key;		/* IN: session key */
 	int	 lstio_bat_nmlen;	/* IN: name length */
 	char __user *lstio_bat_namep;	/* IN: batch name */
-} lstio_batch_del_args_t;
+};
 
 typedef struct {
 	int			 lstio_bat_key;		/* IN: session key */
-- 
1.8.3.1
