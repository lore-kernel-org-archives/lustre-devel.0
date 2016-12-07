From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed,  7 Dec 2016 17:41:32 -0500
Subject: [lustre-devel] [PATCH 6/8] staging/lustre: Declare
	lu_context/session_tags_default
In-Reply-To: <1481150494-1853127-1-git-send-email-green@linuxhacker.ru>
References: <1481150494-1853127-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1481150494-1853127-7-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

Make the declaration in a header, not as an extern in a C file,
that is frowned upon.
This also makes sparse a little bit more happy.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lu_object.h  | 3 +++
 drivers/staging/lustre/lustre/obdclass/cl_object.c | 3 +--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 260643e..69b2812 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -1326,5 +1326,8 @@ void lu_buf_realloc(struct lu_buf *buf, size_t size);
 int lu_buf_check_and_grow(struct lu_buf *buf, size_t len);
 struct lu_buf *lu_buf_check_and_alloc(struct lu_buf *buf, size_t len);
 
+extern __u32 lu_context_tags_default;
+extern __u32 lu_session_tags_default;
+
 /** @} lu */
 #endif /* __LUSTRE_LU_OBJECT_H */
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index f5d4e23..703cb67 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -54,6 +54,7 @@
 #include <linux/list.h>
 #include "../../include/linux/libcfs/libcfs_hash.h"	/* for cfs_hash stuff */
 #include "../include/cl_object.h"
+#include "../include/lu_object.h"
 #include "cl_internal.h"
 
 static struct kmem_cache *cl_env_kmem;
@@ -61,8 +62,6 @@ static struct kmem_cache *cl_env_kmem;
 /** Lock class of cl_object_header::coh_attr_guard */
 static struct lock_class_key cl_attr_guard_class;
 
-extern __u32 lu_context_tags_default;
-extern __u32 lu_session_tags_default;
 /**
  * Initialize cl_object_header.
  */
-- 
2.7.4
