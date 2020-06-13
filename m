From: James Simmons <jsimmons@infradead.org>
Date: Sat, 13 Jun 2020 12:27:11 -0400
Subject: [lustre-devel] [PATCH 15/20] lustre: llite: don't check mirror info
 for page discard
In-Reply-To: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
References: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1592065636-28333-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@whamcloud.com>

The CIT_MISC is used for locks/pages manipulation, it will not
go with full io procedure, i.e. cl_io_loop() will not be called
for it. So don't check it for plain file since the mirror info
is not initialized/set in this case.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13473
Lustre-commit: d0dd744ed6ae0 ("LU-13473 llite: don't check mirror info for page discard")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38307
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_io.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 615db73..99b68d8 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -299,8 +299,13 @@ static int lov_io_mirror_init(struct lov_io *lio, struct lov_object *obj,
 	int result;
 
 	if (!lov_is_flr(obj)) {
-		LASSERT(comp->lo_preferred_mirror == 0);
-		lio->lis_mirror_index = comp->lo_preferred_mirror;
+		/* only locks/pages are manipulated for CIT_MISC op, no
+		 * cl_io_loop() will be called, don't check/set mirror info.
+		 */
+		if (io->ci_type != CIT_MISC) {
+			LASSERT(comp->lo_preferred_mirror == 0);
+			lio->lis_mirror_index = comp->lo_preferred_mirror;
+		}
 		io->ci_ndelay = 0;
 		return 0;
 	}
-- 
1.8.3.1
