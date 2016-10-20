From: Jinshan Xiong <jinshan.xiong@intel.com>
Date: Fri, 21 Oct 2016 07:33:52 +0800
Subject: [lustre-devel] [PATCH] Staging: lustre: lov: check return value of
	lov_sub_get()
Message-ID: <20161020233352.14879-1-jinshan.xiong@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Check return value of lov_sub_get() in lov_io_read_ahead().

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
---
 drivers/staging/lustre/lustre/lov/lov_io.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index a1d1ec9..011ab0f 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -606,6 +606,8 @@ static int lov_io_read_ahead(const struct lu_env *env,
 		return -EIO;
 
 	sub = lov_sub_get(env, lio, stripe);
+	if (IS_ERR(sub))
+		return PTR_ERR(sub);
 
 	lov_stripe_offset(loo->lo_lsm, cl_offset(obj, start), stripe, &suboff);
 	rc = cl_io_read_ahead(sub->sub_env, sub->sub_io,
-- 
2.8.3
