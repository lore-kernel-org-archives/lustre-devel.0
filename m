From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Wed, 14 Oct 2015 00:22:34 +0200
Subject: [lustre-devel] [PATCH 1/7] staging: lustre: lcommon_cl.c: replace
 container_of0 by container_of
In-Reply-To: <cover.1444774232.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1444774232.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <b0f3a818cbf5c3895e87f73005d33e90824f28e6.1444774232.git.mahfouz.saif.elyazal@gmail.com>
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

Cc: jes.sorensen at gmail.com
Cc: kyle at mcmartin.ca 
Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
---
 drivers/staging/lustre/lustre/lclient/lcommon_cl.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
index ef2e266..a941aaf 100644
--- a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
@@ -917,12 +917,12 @@ struct lu_device *ccc2lu_dev(struct ccc_device *vdv)
 
 struct ccc_device *lu2ccc_dev(const struct lu_device *d)
 {
-	return container_of0(d, struct ccc_device, cdv_cl.cd_lu_dev);
+	return container_of(d, struct ccc_device, cdv_cl.cd_lu_dev);
 }
 
 struct ccc_device *cl2ccc_dev(const struct cl_device *d)
 {
-	return container_of0(d, struct ccc_device, cdv_cl);
+	return container_of(d, struct ccc_device, cdv_cl);
 }
 
 struct lu_object *ccc2lu(struct ccc_object *vob)
@@ -932,12 +932,12 @@ struct lu_object *ccc2lu(struct ccc_object *vob)
 
 struct ccc_object *lu2ccc(const struct lu_object *obj)
 {
-	return container_of0(obj, struct ccc_object, cob_cl.co_lu);
+	return container_of(obj, struct ccc_object, cob_cl.co_lu);
 }
 
 struct ccc_object *cl2ccc(const struct cl_object *obj)
 {
-	return container_of0(obj, struct ccc_object, cob_cl);
+	return container_of(obj, struct ccc_object, cob_cl);
 }
 
 struct ccc_lock *cl2ccc_lock(const struct cl_lock_slice *slice)
@@ -957,7 +957,7 @@ struct ccc_io *cl2ccc_io(const struct lu_env *env,
 
 struct ccc_req *cl2ccc_req(const struct cl_req_slice *slice)
 {
-	return container_of0(slice, struct ccc_req, crq_cl);
+	return container_of(slice, struct ccc_req, crq_cl);
 }
 
 struct page *cl2vm_page(const struct cl_page_slice *slice)
-- 
2.4.2


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
