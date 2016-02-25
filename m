From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 21:59:50 -0500
Subject: [lustre-devel] [PATCH v2 07/84] staging/lustre: Get rid of
	quota_cmd_t typedef
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-8-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Replace it with enum quota_cmd

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 50e70fe..c0b05d4 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2006,11 +2006,11 @@ void lustre_swab_lquota_lvb(struct lquota_lvb *lvb);
 #define lvb_glb_ver  lvb_id_may_rel /* current version of the global index */
 
 /* op codes */
-typedef enum {
+enum quota_cmd {
 	QUOTA_DQACQ	= 601,
 	QUOTA_DQREL	= 602,
 	QUOTA_LAST_OPC
-} quota_cmd_t;
+};
 #define QUOTA_FIRST_OPC	QUOTA_DQACQ
 
 /*
-- 
2.1.0
