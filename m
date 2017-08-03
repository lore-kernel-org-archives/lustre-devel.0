From: Bhumika Goyal <bhumirks@gmail.com>
Date: Thu,  3 Aug 2017 14:42:48 +0530
Subject: [lustre-devel] [PATCH] staging: lustre: obd: make echo_lock_ops
	const
Message-ID: <1501751568-5662-1-git-send-email-bhumirks@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: julia.lawall@lip6.fr, oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org
Cc: Bhumika Goyal <bhumirks@gmail.com>

Declare echo_lock_ops object of type cl_lock_operations as const as it
is only passed to the function cl_lock_slice_add. The corresponding
argument is of type const, so make the object const.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/staging/lustre/lustre/obdecho/echo_client.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 1c4a8fe..b3fbc3c 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -319,7 +319,7 @@ static void echo_lock_fini(const struct lu_env *env,
 	kmem_cache_free(echo_lock_kmem, ecl);
 }
 
-static struct cl_lock_operations echo_lock_ops = {
+static const struct cl_lock_operations echo_lock_ops = {
 	.clo_fini      = echo_lock_fini,
 };
 
-- 
1.9.1
