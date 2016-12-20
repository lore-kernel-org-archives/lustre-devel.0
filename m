From: Geliang Tang <geliangtang@gmail.com>
Date: Tue, 20 Dec 2016 13:57:06 -0000
Subject: [lustre-devel] [PATCH] staging: lustre: osc: use rb_entry_safe
Message-ID: <0d014cb5a85c053f88ef7d53e5e3c1514f4e28c0.1482206001.git.geliangtang@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Geliang Tang <geliangtang@gmail.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Use rb_entry_safe() instead of container_of() to simplify the code.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index b0f030c..6048df9 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -142,10 +142,7 @@ static const char *oes_strings[] = {
 
 static inline struct osc_extent *rb_extent(struct rb_node *n)
 {
-	if (!n)
-		return NULL;
-
-	return container_of(n, struct osc_extent, oe_node);
+	return rb_entry_safe(n, struct osc_extent, oe_node);
 }
 
 static inline struct osc_extent *next_extent(struct osc_extent *ext)
-- 
2.9.3
