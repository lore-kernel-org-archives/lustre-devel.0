From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:49 -0400
Subject: [lustre-devel] [PATCH 12/45] lustre: lov: lov_io_sub_init())
 ASSERTION
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@whamcloud.com>

The assertion is_index_within_mirror() in lov_io_sub_init() should
only be applied for a FLR file, since a plain file does not initialize
the relevant FLR fields of the layout structure.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13429
Lustre-commit: 53274fbd4bcf4 ("LU-13429 lov: lov_io_sub_init()) ASSERTION")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38169
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_io.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index d69e3a4..fefbf39 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -113,7 +113,9 @@ static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
 		     !lov_r0(lov, index)->lo_sub[stripe]))
 		return -EIO;
 
-	LASSERTF(is_index_within_mirror(lov, index, lio->lis_mirror_index),
+	LASSERTF(ergo(lov_is_flr(lov),
+		      is_index_within_mirror(lov, index,
+					     lio->lis_mirror_index)),
 		 DFID "iot = %d, index = %d, mirror = %d\n",
 		 PFID(lu_object_fid(lov2lu(lov))), io->ci_type, index,
 		 lio->lis_mirror_index);
-- 
1.8.3.1
