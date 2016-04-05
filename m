From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Date: Tue,  5 Apr 2016 20:15:34 +0530
Subject: [lustre-devel] [PATCH] staging/lustre/obdclass: fix build warning
Message-ID: <1459867534-4507-1-git-send-email-sudipm.mukherjee@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, Sudip Mukherjee <sudipm.mukherjee@gmail.com>

While building with W=1 we were getting the warning:

drivers/staging/lustre/lustre/obdclass/cl_object.c:1056:16:
	warning: old-style function definition
 struct lu_env *cl_env_percpu_get()
                ^

Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>
---
 drivers/staging/lustre/lustre/obdclass/cl_object.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 395b92c..d84ec00 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -1053,7 +1053,7 @@ void cl_env_percpu_put(struct lu_env *env)
 }
 EXPORT_SYMBOL(cl_env_percpu_put);
 
-struct lu_env *cl_env_percpu_get()
+struct lu_env *cl_env_percpu_get(void)
 {
 	struct cl_env *cle;
 
-- 
1.9.1
