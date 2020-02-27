From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:38 -0500
Subject: [lustre-devel] [PATCH 230/622] lustre: dne: performance improvement
 for file creation
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-231-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

This is to remove an obsoleted code where it causes drastic
performance degradation. This code is written before PERM lock
is introduced, and it requests UPDATE lock at path walk for
remote directory, which will be cancelled at later file creation.

Tests result before and after this patch is applied:

Test case:
rm -rf /mnt/lustre_purple/testdir
lfs mkdir -i 0 /mnt/lustre_purple/testdir
lfs mkdir -i 2 /mnt/lustre_purple/testdir/dir2
./lustre-release/lustre/tests/createmany -o \
        /mnt/lustre_purple/testdir/dir2/f 10000

Before the patch is applied:
total: 10000 open/close in 12.82 seconds: 780.22 ops/second

After the patch is applied:
total: 10000 open/close in 4.89 seconds: 2044.75 ops/second

WC-bug-id: https://jira.whamcloud.com/browse/LU-11999
Lustre-commit: bfbd062e6b17 ("LU-11999 dne: performance improvement for file creation")
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: https://review.whamcloud.com/34291
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lmv/lmv_intent.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index 3f51032..6933f7d 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -71,13 +71,6 @@ static int lmv_intent_remote(struct obd_export *exp, struct lookup_intent *it,
 	LASSERT((body->mbo_valid & OBD_MD_MDS));
 
 	/*
-	 * Unfortunately, we have to lie to MDC/MDS to retrieve
-	 * attributes llite needs and provideproper locking.
-	 */
-	if (it->it_op & IT_LOOKUP)
-		it->it_op = IT_GETATTR;
-
-	/*
 	 * We got LOOKUP lock, but we really need attrs.
 	 */
 	pmode = it->it_lock_mode;
-- 
1.8.3.1
