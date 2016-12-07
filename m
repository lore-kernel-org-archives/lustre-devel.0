From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed,  7 Dec 2016 17:41:33 -0500
Subject: [lustre-devel] [PATCH 7/8] staging/lustre: Move
	lov_read_and_clear_async_rc declaration
In-Reply-To: <1481150494-1853127-1-git-send-email-green@linuxhacker.ru>
References: <1481150494-1853127-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1481150494-1853127-8-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

Move it to obd.h, so that it's included from both the users and
the actual definition, making sure they never get out of sync.
This also silences a sparse warning.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/obd.h        | 3 +++
 drivers/staging/lustre/lustre/llite/vvp_internal.h | 2 --
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 0f48e9c..1839f4f 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -43,6 +43,7 @@
 #include "lustre_fld.h"
 #include "lustre_handles.h"
 #include "lustre_intent.h"
+#include "cl_object.h"
 
 #define MAX_OBD_DEVICES 8192
 
@@ -76,6 +77,8 @@ static inline void loi_init(struct lov_oinfo *loi)
 struct lov_stripe_md;
 struct obd_info;
 
+int lov_read_and_clear_async_rc(struct cl_object *clob);
+
 typedef int (*obd_enqueue_update_f)(void *cookie, int rc);
 
 /* obd info for a particular level (lov, osc). */
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index c60d041..f40fd7f 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -301,8 +301,6 @@ static inline struct vvp_lock *cl2vvp_lock(const struct cl_lock_slice *slice)
 # define CLOBINVRNT(env, clob, expr)					\
 	((void)sizeof(env), (void)sizeof(clob), (void)sizeof(!!(expr)))
 
-int lov_read_and_clear_async_rc(struct cl_object *clob);
-
 int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 		struct cl_io *io);
 int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io);
-- 
2.7.4
