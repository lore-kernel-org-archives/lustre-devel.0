From: Colin King <colin.king@canonical.com>
Date: Wed, 19 Jul 2017 17:20:36 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: lnet: fix incorrect
	arguments order calling lstcon_session_new
Message-ID: <20170719162036.21621-1-colin.king@canonical.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Doug Oucharek <doug.s.oucharek@intel.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The arguments args->lstio_ses_force and args->lstio_ses_timeout are
in the incorrect order. Fix this by swapping them around.

Detected by CoverityScan, CID#1226833 ("Arguments in wrong order")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/staging/lustre/lnet/selftest/conctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 6ca7192b03b7..043eafb5ea40 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -69,8 +69,8 @@ lst_session_new_ioctl(struct lstio_session_new_args *args)
 	rc = lstcon_session_new(name,
 				args->lstio_ses_key,
 				args->lstio_ses_feats,
-				args->lstio_ses_force,
 				args->lstio_ses_timeout,
+				args->lstio_ses_force,
 				args->lstio_ses_idp);
 
 	LIBCFS_FREE(name, args->lstio_ses_nmlen + 1);
-- 
2.11.0
