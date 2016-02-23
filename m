From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:53:47 -0500
Subject: [lustre-devel] [PATCH 09/56] staging/lustre: Get rid of ldlm_cmd_t
	typedef
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-10-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Replace it with enum ldlm_cmd

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index bd8b622..938f91b 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2659,7 +2659,7 @@ void lustre_swab_lov_desc(struct lov_desc *ld);
  *   LDLM requests:
  */
 /* opcodes -- MUST be distinct from OST/MDS opcodes */
-typedef enum {
+enum ldlm_cmd {
 	LDLM_ENQUEUE     = 101,
 	LDLM_CONVERT     = 102,
 	LDLM_CANCEL      = 103,
@@ -2668,7 +2668,7 @@ typedef enum {
 	LDLM_GL_CALLBACK = 106,
 	LDLM_SET_INFO    = 107,
 	LDLM_LAST_OPC
-} ldlm_cmd_t;
+};
 #define LDLM_FIRST_OPC LDLM_ENQUEUE
 
 #define RES_NAME_SIZE 4
-- 
2.1.0
