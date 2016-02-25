From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 21:59:55 -0500
Subject: [lustre-devel] [PATCH v2 12/84] staging/lustre: Get rid of
	mgs_cmd_t typedef
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-13-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Replace it with enum mgs_cmd

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index d3fb6f9..19a99c5 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2820,7 +2820,7 @@ void lustre_swab_ldlm_reply(struct ldlm_reply *r);
 /*
  * Opcodes for mountconf (mgs and mgc)
  */
-typedef enum {
+enum mgs_cmd {
 	MGS_CONNECT = 250,
 	MGS_DISCONNECT,
 	MGS_EXCEPTION,	 /* node died, etc. */
@@ -2829,7 +2829,7 @@ typedef enum {
 	MGS_SET_INFO,
 	MGS_CONFIG_READ,
 	MGS_LAST_OPC
-} mgs_cmd_t;
+};
 #define MGS_FIRST_OPC MGS_CONNECT
 
 #define MGS_PARAM_MAXLEN 1024
-- 
2.1.0
