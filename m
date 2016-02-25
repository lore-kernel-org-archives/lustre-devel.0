From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:01:02 -0500
Subject: [lustre-devel] [PATCH v2 79/84] staging/lustre/obdecho: Fix style
	vs open parenthesis alignment
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-80-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This mostly fixes checkpatch complaints about
"Alignment should match open parenthesis"

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/obdecho/echo_client.c    | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 3be28c5..ab56e67 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -220,7 +220,7 @@ static struct lu_kmem_descr echo_caches[] = {
  * @{
  */
 static struct page *echo_page_vmpage(const struct lu_env *env,
-				    const struct cl_page_slice *slice)
+				     const struct cl_page_slice *slice)
 {
 	return cl2echo_page(slice)->ep_vmpage;
 }
@@ -367,7 +367,7 @@ static struct cl_lock_operations echo_lock_ops = {
  * @{
  */
 static int echo_page_init(const struct lu_env *env, struct cl_object *obj,
-			struct cl_page *page, struct page *vmpage)
+			  struct cl_page *page, struct page *vmpage)
 {
 	struct echo_page *ep = cl_object_page_slice(obj, page);
 	struct echo_object *eco = cl2echo_obj(obj);
@@ -529,7 +529,7 @@ static void echo_object_free(const struct lu_env *env, struct lu_object *obj)
 }
 
 static int echo_object_print(const struct lu_env *env, void *cookie,
-			    lu_printer_t p, const struct lu_object *o)
+			     lu_printer_t p, const struct lu_object *o)
 {
 	struct echo_object *obj = cl2echo_obj(lu2cl(o));
 
@@ -621,7 +621,7 @@ static void echo_site_fini(const struct lu_env *env, struct echo_device *ed)
 }
 
 static void *echo_thread_key_init(const struct lu_context *ctx,
-			  struct lu_context_key *key)
+				  struct lu_context_key *key)
 {
 	struct echo_thread_info *info;
 
@@ -632,7 +632,7 @@ static void *echo_thread_key_init(const struct lu_context *ctx,
 }
 
 static void echo_thread_key_fini(const struct lu_context *ctx,
-			 struct lu_context_key *key, void *data)
+				 struct lu_context_key *key, void *data)
 {
 	struct echo_thread_info *info = data;
 
@@ -640,7 +640,7 @@ static void echo_thread_key_fini(const struct lu_context *ctx,
 }
 
 static void echo_thread_key_exit(const struct lu_context *ctx,
-			 struct lu_context_key *key, void *data)
+				 struct lu_context_key *key, void *data)
 {
 }
 
@@ -652,7 +652,7 @@ static struct lu_context_key echo_thread_key = {
 };
 
 static void *echo_session_key_init(const struct lu_context *ctx,
-				  struct lu_context_key *key)
+				   struct lu_context_key *key)
 {
 	struct echo_session_info *session;
 
@@ -663,7 +663,7 @@ static void *echo_session_key_init(const struct lu_context *ctx,
 }
 
 static void echo_session_key_fini(const struct lu_context *ctx,
-				 struct lu_context_key *key, void *data)
+				  struct lu_context_key *key, void *data)
 {
 	struct echo_session_info *session = data;
 
@@ -671,7 +671,7 @@ static void echo_session_key_fini(const struct lu_context *ctx,
 }
 
 static void echo_session_key_exit(const struct lu_context *ctx,
-				 struct lu_context_key *key, void *data)
+				  struct lu_context_key *key, void *data)
 {
 }
 
@@ -720,7 +720,7 @@ static struct lu_device *echo_device_alloc(const struct lu_env *env,
 	tgt = class_name2obd(lustre_cfg_string(cfg, 1));
 	if (!tgt) {
 		CERROR("Can not find tgt device %s\n",
-			lustre_cfg_string(cfg, 1));
+		       lustre_cfg_string(cfg, 1));
 		rc = -ENODEV;
 		goto out;
 	}
@@ -796,7 +796,7 @@ out:
 }
 
 static int echo_device_init(const struct lu_env *env, struct lu_device *d,
-			  const char *name, struct lu_device *next)
+			    const char *name, struct lu_device *next)
 {
 	LBUG();
 	return 0;
-- 
2.1.0
