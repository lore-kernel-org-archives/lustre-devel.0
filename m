From: Justin Skists <justin.skists@juzza.co.uk>
Date: Thu, 10 May 2018 20:41:29 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: lnet: add static to
 libcfs_dev declaration
Message-ID: <20180510194128.GA19653@tanglefoot>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: linux-kernel@vger.kernel.org

Add a static prefix to the declaration for libcfs_dev. This would fix
the following sparse warning:

drivers/staging/lustre/lnet/libcfs/module.c:317:19: warning: symbol
'libcfs_dev' was not declared. Should it be static?

Signed-off-by: Justin Skists <justin.skists@juzza.co.uk>
---
 drivers/staging/lustre/lnet/libcfs/module.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index ca942f474a55..e021e439f140 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -314,7 +314,7 @@ static const struct file_operations libcfs_fops = {
 	.unlocked_ioctl	= libcfs_psdev_ioctl,
 };
 
-struct miscdevice libcfs_dev = {
+static struct miscdevice libcfs_dev = {
 	.minor = MISC_DYNAMIC_MINOR,
 	.name = "lnet",
 	.fops = &libcfs_fops,
-- 
2.17.0
