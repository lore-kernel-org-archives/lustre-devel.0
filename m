From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 21:59:56 -0500
Subject: [lustre-devel] [PATCH v2 13/84] staging/lustre: Get rid of
	obd_cmd_t typedef
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-14-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Replace with enum obd_cmd

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 19a99c5..27ee853 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2918,13 +2918,13 @@ void lustre_swab_cfg_marker(struct cfg_marker *marker, int swab, int size);
  * Opcodes for multiple servers.
  */
 
-typedef enum {
+enum obd_cmd {
 	OBD_PING = 400,
 	OBD_LOG_CANCEL,
 	OBD_QC_CALLBACK,
 	OBD_IDX_READ,
 	OBD_LAST_OPC
-} obd_cmd_t;
+};
 #define OBD_FIRST_OPC OBD_PING
 
 /* catalog of log objects */
-- 
2.1.0
