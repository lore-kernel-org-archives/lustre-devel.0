From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:46 -0500
Subject: [lustre-devel] [PATCH v2 63/84] staging/lustre: Remove unused
	liblustre_check_services prototype
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-64-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

liblustre_check_services is no longer present in the tree.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_net.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index b857055..4fa1a18 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -2515,7 +2515,6 @@ struct ptlrpc_service *ptlrpc_register_service(struct ptlrpc_service_conf *conf,
 
 int ptlrpc_start_threads(struct ptlrpc_service *svc);
 int ptlrpc_unregister_service(struct ptlrpc_service *service);
-int liblustre_check_services(void *arg);
 
 int ptlrpc_hr_init(void);
 void ptlrpc_hr_fini(void);
-- 
2.1.0
