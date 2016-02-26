From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Fri, 26 Feb 2016 01:50:00 -0500
Subject: [lustre-devel] [PATCH 12/25] staging/lustre: Remove
	RELEASEPAGE_ARG_TYPE compat macro
In-Reply-To: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
References: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456469413-931943-13-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Not used in the kernel proper.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/rw26.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 64110c5..6a5762e 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -109,12 +109,7 @@ static void ll_invalidatepage(struct page *vmpage, unsigned int offset,
 	}
 }
 
-#ifdef HAVE_RELEASEPAGE_WITH_INT
-#define RELEASEPAGE_ARG_TYPE int
-#else
-#define RELEASEPAGE_ARG_TYPE gfp_t
-#endif
-static int ll_releasepage(struct page *vmpage, RELEASEPAGE_ARG_TYPE gfp_mask)
+static int ll_releasepage(struct page *vmpage, gfp_t gfp_mask)
 {
 	struct cl_env_nest nest;
 	struct lu_env     *env;
-- 
2.1.0
