From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Wed, 14 Oct 2015 00:24:19 +0200
Subject: [lustre-devel] [PATCH 5/7] staging: lustre: osc_io.c: replace
 container_of0 by container_of
In-Reply-To: <cover.1444774232.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1444774232.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <f744c888f2d0c2820e1f08d74b725f17573c7bc8.1444774232.git.mahfouz.saif.elyazal@gmail.com>
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
 drivers/staging/lustre/lustre/osc/osc_io.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 3a4200f..fb3b415 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -56,13 +56,13 @@
 static struct osc_req *cl2osc_req(const struct cl_req_slice *slice)
 {
 	LINVRNT(slice->crs_dev->cd_lu_dev.ld_type == &osc_device_type);
-	return container_of0(slice, struct osc_req, or_cl);
+	return container_of(slice, struct osc_req, or_cl);
 }
 
 static struct osc_io *cl2osc_io(const struct lu_env *env,
 				const struct cl_io_slice *slice)
 {
-	struct osc_io *oio = container_of0(slice, struct osc_io, oi_cl);
+	struct osc_io *oio = container_of(slice, struct osc_io, oi_cl);
 
 	LINVRNT(oio == osc_env_io(env));
 	return oio;
-- 
2.4.2


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
