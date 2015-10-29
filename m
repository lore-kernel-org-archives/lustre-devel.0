From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Thu, 29 Oct 2015 02:54:09 +0200
Subject: [lustre-devel] [PATCH v3 1/5] staging: lustre: ldlm_extent.c:
 replace IS_PO2 by is_power_of_2
In-Reply-To: <cover.1446079745.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1446079745.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <f64d28ead855c4ecebdebaa0232e255d4317d7eb.1446079745.git.mahfouz.saif.elyazal@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Replaces IS_PO2 by is_power_of_2. It is more accurate to use
is_power_of_2 since it returns 1 for numbers that are powers
of 2 only whereas IS_PO2 returns 1 for 0 and numbers that are
powers of 2.

Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
---
v2:
        -changed commit message
v3:
	-no change

 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index c787888..9c70f31 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -149,7 +149,7 @@ static inline int lock_mode_to_index(ldlm_mode_t mode)
 	int index;
 
 	LASSERT(mode != 0);
-	LASSERT(IS_PO2(mode));
+	LASSERT(is_power_of_2(mode));
 	for (index = -1; mode; index++)
 		mode >>= 1;
 	LASSERT(index < LCK_MODE_NUM);
-- 
2.4.2


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
