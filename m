From: Shraddha <shraddha.6596@gmail.com>
Date: Fri, 18 Dec 2015 02:40:29 +0530
Subject: [lustre-devel] [PATCH 4/5] Staging: lustre: osc: Declare
	osc_attr_set as static
In-Reply-To: <1450386630-5662-1-git-send-email-shraddha.6596@gmail.com>
References: <1450386630-5662-1-git-send-email-shraddha.6596@gmail.com>
Message-ID: <1450386630-5662-5-git-send-email-shraddha.6596@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Shraddha Barke <shraddha.6596@gmail.com>

osc_attr_set is used only in this particular file. Thus declare it
as static.

Signed-off-by: Shraddha Barke <shraddha.6596@gmail.com>
---
 drivers/staging/lustre/lustre/osc/osc_object.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index ba57f8d..2a171eb 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -158,8 +158,8 @@ static int osc_attr_get(const struct lu_env *env, struct cl_object *obj,
 	return 0;
 }
 
-int osc_attr_set(const struct lu_env *env, struct cl_object *obj,
-		 const struct cl_attr *attr, unsigned valid)
+static int osc_attr_set(const struct lu_env *env, struct cl_object *obj,
+			const struct cl_attr *attr, unsigned valid)
 {
 	struct lov_oinfo *oinfo = cl2osc(obj)->oo_oinfo;
 	struct ost_lvb *lvb = &oinfo->loi_lvb;
-- 
2.1.4
