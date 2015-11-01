From: Paul Davies C <pauldaviesc@gmail.com>
Date: Sun, 1 Nov 2015 14:12:29 +0530
Subject: [lustre-devel] [PATCH] lustre: obdclass: fix sparse warning
Message-ID: <5635d078.a1ee440a.16126.ffffcaf6@mx.google.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Fix the following warning given by sparse:

drivers/staging/lustre/lustre/obdclass/cl_lock.c:690:5: warning: symbol 'cl_lock_mutex_try' was not declared. Should it be static?

Signed-off-by: Paul Davies C <pauldaviesc@gmail.com>
---
 drivers/staging/lustre/lustre/obdclass/cl_lock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
index 5621beb..6f83452 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
@@ -687,7 +687,7 @@ EXPORT_SYMBOL(cl_lock_mutex_get);
  *
  * \see cl_lock_mutex_get()
  */
-int cl_lock_mutex_try(const struct lu_env *env, struct cl_lock *lock)
+static int cl_lock_mutex_try(const struct lu_env *env, struct cl_lock *lock)
 {
 	int result;
 
-- 
1.9.1
