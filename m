From: Shraddha <shraddha.6596@gmail.com>
Date: Fri, 18 Dec 2015 02:40:26 +0530
Subject: [lustre-devel] [PATCH 1/5] Staging: lustre: obdclass: Declare
	cl_env_peek as static
In-Reply-To: <1450386630-5662-1-git-send-email-shraddha.6596@gmail.com>
References: <1450386630-5662-1-git-send-email-shraddha.6596@gmail.com>
Message-ID: <1450386630-5662-2-git-send-email-shraddha.6596@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Shraddha Barke <shraddha.6596@gmail.com>

Declare cl_env_peek as static since it is used only in this file.
Also remove the EXPORT SYMBOL.

Signed-off-by: Shraddha Barke <shraddha.6596@gmail.com>
---
 drivers/staging/lustre/lustre/obdclass/cl_object.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index a1a6024..ed656a8 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -704,7 +704,7 @@ static inline struct cl_env *cl_env_container(struct lu_env *env)
 	return container_of(env, struct cl_env, ce_lu);
 }
 
-struct lu_env *cl_env_peek(int *refcheck)
+static struct lu_env *cl_env_peek(int *refcheck)
 {
 	struct lu_env *env;
 	struct cl_env *cle;
@@ -724,7 +724,6 @@ struct lu_env *cl_env_peek(int *refcheck)
 	CDEBUG(D_OTHER, "%d@%p\n", cle ? cle->ce_ref : 0, cle);
 	return env;
 }
-EXPORT_SYMBOL(cl_env_peek);
 
 /**
  * Returns lu_env: if there already is an environment associated with the
-- 
2.1.4
