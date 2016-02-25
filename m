From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:53 -0500
Subject: [lustre-devel] [PATCH v2 70/84] staging/lustre: MS_POSIXACL is
	always defined, don't check for it
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-71-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 5b155b2..db9072c 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -309,15 +309,11 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 	}
 
 	if (data->ocd_connect_flags & OBD_CONNECT_ACL) {
-#ifdef MS_POSIXACL
 		sb->s_flags |= MS_POSIXACL;
-#endif
 		sbi->ll_flags |= LL_SBI_ACL;
 	} else {
 		LCONSOLE_INFO("client wants to enable acl, but mdt not!\n");
-#ifdef MS_POSIXACL
 		sb->s_flags &= ~MS_POSIXACL;
-#endif
 		sbi->ll_flags &= ~LL_SBI_ACL;
 	}
 
-- 
2.1.0
