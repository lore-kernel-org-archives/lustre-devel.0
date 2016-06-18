From: Craig Inches <craig@craiginches.com>
Date: Sat, 18 Jun 2016 22:26:08 +0100
Subject: [lustre-devel] [PATCH 3/3] staging: luster: Checkpatch Cleanup
In-Reply-To: <cover.1466279901.git.craig@craiginches.com>
References: <cover.1466279901.git.craig@craiginches.com>
Message-ID: <34e8b044236880f37be45c5d8fd527071bdfe9f9.1466279901.git.craig@craiginches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

WARNING: Prefer 'unsigned int' to bare use of 'unsigned'

Signed-off-by: Craig Inches <craig@craiginches.com>
---
 drivers/staging/lustre/lustre/include/cl_object.h | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 712355a..5c5e319 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -371,7 +371,7 @@ struct cl_object_operations {
 	 * cl_object_operations::coo_attr_get() is used.
 	 */
 	int (*coo_attr_set)(const struct lu_env *env, struct cl_object *obj,
-			    const struct cl_attr *attr, unsigned valid);
+			    const struct cl_attr *attr, unsigned int valid);
 	/**
 	 * Update object configuration. Called top-to-bottom to modify object
 	 * configuration.
@@ -761,7 +761,7 @@ struct cl_page {
 	/** Link to a queue, for debugging. */
 	struct lu_ref_link       cp_queue_ref;
 	/** Per-page flags from enum cl_page_flags. Protected by a VM lock. */
-	unsigned                 cp_flags;
+	unsigned int                cp_flags;
 	/** Assigned if doing a sync_io */
 	struct cl_sync_io       *cp_sync_io;
 };
@@ -1320,7 +1320,7 @@ do {								    \
  * @{
  */
 struct cl_page_list {
-	unsigned	     pl_nr;
+	unsigned int	     pl_nr;
 	struct list_head	   pl_pages;
 	struct task_struct	*pl_owner;
 };
@@ -1838,7 +1838,7 @@ struct cl_io {
 	/**
 	 * Number of pages owned by this IO. For invariant checking.
 	 */
-	unsigned	     ci_owned_nr;
+	unsigned int	     ci_owned_nr;
 };
 
 /** @} cl_io */
@@ -1996,11 +1996,11 @@ struct cl_req {
 	/** A list of pages being transferred */
 	struct list_head	    crq_pages;
 	/** Number of pages in cl_req::crq_pages */
-	unsigned	      crq_nrpages;
+	unsigned int	      crq_nrpages;
 	/** An array of objects which pages are in ->crq_pages */
 	struct cl_req_obj    *crq_o;
 	/** Number of elements in cl_req::crq_objs[] */
-	unsigned	      crq_nrobjs;
+	unsigned int	      crq_nrobjs;
 	struct list_head	    crq_layers;
 };
 
@@ -2181,7 +2181,7 @@ void cl_object_attr_unlock(struct cl_object *o);
 int  cl_object_attr_get(const struct lu_env *env, struct cl_object *obj,
 			struct cl_attr *attr);
 int  cl_object_attr_set(const struct lu_env *env, struct cl_object *obj,
-			const struct cl_attr *attr, unsigned valid);
+			const struct cl_attr *attr, unsigned int valid);
 int  cl_object_glimpse(const struct lu_env *env, struct cl_object *obj,
 		       struct ost_lvb *lvb);
 int  cl_conf_set(const struct lu_env *env, struct cl_object *obj,
-- 
2.7.3
