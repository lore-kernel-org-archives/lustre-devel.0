From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Wed, 14 Oct 2015 00:23:14 +0200
Subject: [lustre-devel] [PATCH 2/7] staging: lustre: llite_nfs.c: replace
 container_of0 by container_of
In-Reply-To: <cover.1444774232.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1444774232.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <a9b823b1753239156b310ecb9ac109023629bc23.1444774232.git.mahfouz.saif.elyazal@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Replaces container_of0 by container_of. The only difference between
the two implementations is that container_of0 tries to evade
type casting if the pointer is erroneous or null. The use of
container_of is encouraged to bring lustre one step closer to
community standards.

Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
---
 drivers/staging/lustre/lustre/llite/llite_nfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index e578a11..340fb61 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -210,7 +210,7 @@ static int ll_nfs_get_name_filldir(struct dir_context *ctx, const char *name,
 {
 	/* It is hack to access lde_fid for comparison with lgd_fid.
 	 * So the input 'name' must be part of the 'lu_dirent'. */
-	struct lu_dirent *lde = container_of0(name, struct lu_dirent, lde_name);
+	struct lu_dirent *lde = container_of(name, struct lu_dirent, lde_name);
 	struct ll_getname_data *lgd =
 		container_of(ctx, struct ll_getname_data, ctx);
 	struct lu_fid fid;
-- 
2.4.2


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
