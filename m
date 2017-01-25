From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 25 Jan 2017 23:36:34 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: ptlrpc: avoid warning on
	missing return
Message-ID: <20170125223804.1479716-1-arnd@arndb.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Gregoire Pichon <gregoire.pichon@bull.net>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

The newly added function triggers a harmless warning:

drivers/staging/lustre/lustre/ptlrpc/pack_generic.c: In function 'lustre_shrink_msg':
drivers/staging/lustre/lustre/ptlrpc/pack_generic.c:472:1: error: control reaches end of non-void function [-Werror=return-type]

This probably happens because LASSERTF() contains an 'unlikely()' that
sometimes prevents gcc from analysing the control flow correctly.
Adding a return statement here seems harmless and lets us keep that
unlikely().

Fixes: 96049bd1ecd0 ("staging: lustre: ptlrpc: embed highest XID in each request")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/staging/lustre/lustre/ptlrpc/pack_generic.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 13f00b7cbbe5..b1170277fd84 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -469,6 +469,7 @@ int lustre_shrink_msg(struct lustre_msg *msg, int segment,
 	default:
 		LASSERTF(0, "incorrect message magic: %08x\n", msg->lm_magic);
 	}
+	return 0;
 }
 EXPORT_SYMBOL(lustre_shrink_msg);
 
-- 
2.9.0
