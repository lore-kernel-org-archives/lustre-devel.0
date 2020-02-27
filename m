From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:26 -0500
Subject: [lustre-devel] [PATCH 158/622] lustre: osc: Do not walk full extent
 list
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-159-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

It is only possible to merge with the extent immediately
before or immediately after the one we are trying to add,
so do not continue to walk the extent list after passing
that extent.

This has a significant impact when writing large sparse
files, where most writes create a new extent, and many
extents are too distant to be merged with their neighbors.

Writing 2 GiB of data randomly 4K at a time, we see an
improvement of about 15% with this patch.

mpirun -n 1 $IOR -w -t 4K -b 2G -o ./file -z
w/o patch:
write         285.86 MiB/s
w/patch:
write         324.03 MiB/s

Cray-bug-id: LUS-6523
WC-bug-id: https://jira.whamcloud.com/browse/LU-11423
Lustre-commit: 7f8143cf85b7 ("LU-11423 osc: Do not walk full extent list")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33227
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_cache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 2ed7ca2..961fc6bf 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -746,7 +746,7 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 		pgoff_t ext_chk_end = ext->oe_end >> ppc_bits;
 
 		LASSERT(osc_extent_sanity_check_nolock(ext) == 0);
-		if (chunk > ext_chk_end + 1)
+		if (chunk > ext_chk_end + 1 || chunk < ext_chk_start)
 			break;
 
 		/* if covering by different locks, no chance to match */
-- 
1.8.3.1
