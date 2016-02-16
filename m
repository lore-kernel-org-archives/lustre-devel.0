From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:40 -0500
Subject: [lustre-devel] [PATCH 08/45] staging/lustre: Remove server code
	from client_obd_setup()
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-9-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

In client_obd_setup references to LUSTRE_OSP_NAME could only
happen on metadata servers, so remove them as never true

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c | 16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index b52ffc0..774d89c 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -261,22 +261,6 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 		cli->cl_sp_me = LUSTRE_SP_CLI;
 		cli->cl_sp_to = LUSTRE_SP_MDT;
 		ns_type = LDLM_NS_TYPE_MDC;
-	} else if (!strcmp(name, LUSTRE_OSP_NAME)) {
-		if (strstr(lustre_cfg_buf(lcfg, 1), "OST") == NULL) {
-			/* OSP_on_MDT for other MDTs */
-			connect_op = MDS_CONNECT;
-			cli->cl_sp_to = LUSTRE_SP_MDT;
-			ns_type = LDLM_NS_TYPE_MDC;
-			rq_portal = OUT_PORTAL;
-		} else {
-			/* OSP on MDT for OST */
-			connect_op = OST_CONNECT;
-			cli->cl_sp_to = LUSTRE_SP_OST;
-			ns_type = LDLM_NS_TYPE_OSC;
-			rq_portal = OST_REQUEST_PORTAL;
-		}
-		rp_portal = OSC_REPLY_PORTAL;
-		cli->cl_sp_me = LUSTRE_SP_CLI;
 	} else if (!strcmp(name, LUSTRE_MGC_NAME)) {
 		rq_portal = MGS_REQUEST_PORTAL;
 		rp_portal = MGC_REPLY_PORTAL;
-- 
2.1.0
