From: James Simmons <jsimmons@infradead.org>
Date: Mon, 22 Aug 2016 12:57:43 -0400
Subject: [lustre-devel] [PATCH] staging: lustre: mdc: fix NULL pointer
	dereference in mdc_adjust_dirpages
Message-ID: <1471885063-14904-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The function mdc_adjust_dirpages is only called on platforms which
don't have pages 4K in size which is why kbuild only reported this
for platforms like the Alpha. The problem was a typo in ordering of
variables in the beginning of a while loop. We were accessing the
dp pointer before it was kmapped.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_request.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 88848d8..7a182be 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1133,9 +1133,9 @@ static void mdc_adjust_dirpages(struct page **pages, int cfs_pgs, int lu_pgs)
 	int i;
 
 	for (i = 0; i < cfs_pgs; i++) {
+		struct lu_dirpage *dp = kmap(pages[i]);
 		__u64 hash_end = le64_to_cpu(dp->ldp_hash_end);
 		__u32 flags = le32_to_cpu(dp->ldp_flags);
-		struct lu_dirpage *dp = kmap(pages[i]);
 		struct lu_dirpage *first = dp;
 		struct lu_dirent *end_dirent = NULL;
 		struct lu_dirent *ent;
-- 
1.7.1
