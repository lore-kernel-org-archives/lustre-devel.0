From: Quentin Lambert <lambert.quentin@gmail.com>
Date: Fri,  2 Dec 2016 18:33:32 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: Fix a spatch warning due to
	an assignment from kernel to user space
Message-ID: <20161202173332.5100-1-lambert.quentin@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Cc: Quentin Lambert <lambert.quentin@gmail.com>

lnet_ipif_enumerate was assigning a pointer from kernel space to user
space. This patch uses copy_to_user to properly do that assignment.

Signed-off-by: Quentin Lambert <lambert.quentin@gmail.com>
---
 shouldn't we be using ifc_req instead of ifc_buf?

 drivers/staging/lustre/lnet/lnet/lib-socket.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -181,7 +181,13 @@ lnet_ipif_enumerate(char ***namesp)
 			goto out0;
 		}
 
-		ifc.ifc_buf = (char *)ifr;
+		rc = copy_to_user(ifc.ifc_buf, (char *)ifr,
+				  nalloc * sizeof(*ifr));
+		if (rc) {
+			rc = -ENOMEM;
+			goto out1;
+		}
+
 		ifc.ifc_len = nalloc * sizeof(*ifr);
 
 		rc = lnet_sock_ioctl(SIOCGIFCONF, (unsigned long)&ifc);
