From: James Simmons <jsimmons@infradead.org>
Date: Fri, 18 Nov 2016 11:48:39 -0500
Subject: [lustre-devel] [PATCH 05/10] staging: lustre: libcfs: correct
	spelling in libcfs_cpu.h
In-Reply-To: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
References: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479487724-20386-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Spell the word destroy correctly.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_cpu.h       |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 81d8079..61bd951 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -211,7 +211,7 @@ void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
  */
 void *cfs_percpt_alloc(struct cfs_cpt_table *cptab, unsigned int size);
 /*
- * destory per-cpu-partition variable
+ * destroy per-cpu-partition variable
  */
 void cfs_percpt_free(void *vars);
 int cfs_percpt_number(void *vars);
-- 
1.7.1
