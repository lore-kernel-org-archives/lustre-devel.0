From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Mon, 17 Oct 2016 23:47:23 +0200
Subject: [lustre-devel] [PATCH 2/2] staging: lustre: remove class_devno_max
In-Reply-To: <cover.1476739569.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1476739569.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <d4c2778c956ae91ac4c21109945c9a400ce1aa64.1476739569.git.mahfouz.saif.elyazal@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org, linux-kernel@vger.kernel.org

class_devno_max is an inline function that is not used
anymore. Hence, it is removed.

Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
---
 drivers/staging/lustre/lustre/include/obd_class.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 6482a93..84f36b0 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -406,11 +406,6 @@ do {								 \
 	}							    \
 } while (0)
 
-static inline int class_devno_max(void)
-{
-	return MAX_OBD_DEVICES;
-}
-
 static inline int obd_get_info(const struct lu_env *env,
 			       struct obd_export *exp, __u32 keylen,
 			       void *key, __u32 *vallen, void *val,
-- 
2.5.0


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
