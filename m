From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Wed, 14 Oct 2015 00:24:37 +0200
Subject: [lustre-devel] [PATCH 6/7] staging: lustre: osc_object.c: replace
 container_of0 by container_of
In-Reply-To: <cover.1444774232.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1444774232.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <9e8c34322eb346f02f3c6c0e9bac7c0652cb78d0.1444774232.git.mahfouz.saif.elyazal@gmail.com>
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
 drivers/staging/lustre/lustre/osc/osc_object.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index acffab9..f916b09 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -60,7 +60,7 @@ static struct lu_object *osc2lu(struct osc_object *osc)
 static struct osc_object *lu2osc(const struct lu_object *obj)
 {
 	LINVRNT(osc_is_object(obj));
-	return container_of0(obj, struct osc_object, oo_cl.co_lu);
+	return container_of(obj, struct osc_object, oo_cl.co_lu);
 }
 
 /*****************************************************************************
-- 
2.4.2


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
