From: James Simmons <jsimmons@infradead.org>
Date: Thu, 17 Nov 2016 14:35:55 -0500
Subject: [lustre-devel] [PATCH 17/19] staging: lustre: libcfs: remove use of
	__u* types
In-Reply-To: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
References: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479411357-28979-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

The __[u|s]* types are for UAPI headers or user
space. They shouldn't be used in core kernel code.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/fail.c          |    4 ++--
 drivers/staging/lustre/lnet/libcfs/hash.c          |   16 ++++++++--------
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |    6 +++---
 .../lustre/lnet/libcfs/linux/linux-module.c        |    2 +-
 4 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/fail.c b/drivers/staging/lustre/lnet/libcfs/fail.c
index 3a9c8dd..12dd50a 100644
--- a/drivers/staging/lustre/lnet/libcfs/fail.c
+++ b/drivers/staging/lustre/lnet/libcfs/fail.c
@@ -46,7 +46,7 @@
 int cfs_race_state;
 EXPORT_SYMBOL(cfs_race_state);
 
-int __cfs_fail_check_set(__u32 id, __u32 value, int set)
+int __cfs_fail_check_set(u32 id, u32 value, int set)
 {
 	static atomic_t cfs_fail_count = ATOMIC_INIT(0);
 
@@ -124,7 +124,7 @@ int __cfs_fail_check_set(__u32 id, __u32 value, int set)
 }
 EXPORT_SYMBOL(__cfs_fail_check_set);
 
-int __cfs_fail_timeout_set(__u32 id, __u32 value, int ms, int set)
+int __cfs_fail_timeout_set(u32 id, u32 value, int ms, int set)
 {
 	int ret;
 
diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index 12ed71c..b90dfb9 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -1035,10 +1035,10 @@ struct cfs_hash *
 	cfs_hash_lock_setup(hs);
 	cfs_hash_hlist_setup(hs);
 
-	hs->hs_cur_bits = (__u8)cur_bits;
-	hs->hs_min_bits = (__u8)cur_bits;
-	hs->hs_max_bits = (__u8)max_bits;
-	hs->hs_bkt_bits = (__u8)bkt_bits;
+	hs->hs_cur_bits = (u8)cur_bits;
+	hs->hs_min_bits = (u8)cur_bits;
+	hs->hs_max_bits = (u8)max_bits;
+	hs->hs_bkt_bits = (u8)bkt_bits;
 
 	hs->hs_ops = ops;
 	hs->hs_extra_bytes = extra_bytes;
@@ -1405,14 +1405,14 @@ void cfs_hash_putref(struct cfs_hash *hs)
  *    . if @removal_safe is true, use can remove current item by
  *      cfs_hash_bd_del_locked
  */
-static __u64
+static u64
 cfs_hash_for_each_tight(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
 			void *data, int remove_safe)
 {
 	struct hlist_node *hnode;
 	struct hlist_node *pos;
 	struct cfs_hash_bd bd;
-	__u64 count = 0;
+	u64 count = 0;
 	int excl = !!remove_safe;
 	int loop = 0;
 	int i;
@@ -1525,7 +1525,7 @@ struct cfs_hash_cond_arg {
 }
 EXPORT_SYMBOL(cfs_hash_is_empty);
 
-__u64
+u64
 cfs_hash_size_get(struct cfs_hash *hs)
 {
 	return cfs_hash_with_counter(hs) ?
@@ -1556,7 +1556,7 @@ struct cfs_hash_cond_arg {
 	struct hlist_node *hnode;
 	struct hlist_node *tmp;
 	struct cfs_hash_bd bd;
-	__u32 version;
+	u32 version;
 	int count = 0;
 	int stop_on_change;
 	int end = -1;
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
index ccebeb4..02de1ee 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
@@ -411,7 +411,7 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
  * \retval 0 otherwise
  */
 int
-cfs_expr_list_match(__u32 value, struct cfs_expr_list *expr_list)
+cfs_expr_list_match(u32 value, struct cfs_expr_list *expr_list)
 {
 	struct cfs_range_expr *expr;
 
@@ -433,10 +433,10 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
  * \retval < 0 for failure
  */
 int
-cfs_expr_list_values(struct cfs_expr_list *expr_list, int max, __u32 **valpp)
+cfs_expr_list_values(struct cfs_expr_list *expr_list, int max, u32 **valpp)
 {
 	struct cfs_range_expr *expr;
-	__u32 *val;
+	u32 *val;
 	int count = 0;
 	int i;
 
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index 38308f8..3f5d58b 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
@@ -83,7 +83,7 @@ static inline bool libcfs_ioctl_is_invalid(struct libcfs_ioctl_data *data)
 		CERROR("LIBCFS ioctl: plen2 nonzero but no pbuf2 pointer\n");
 		return true;
 	}
-	if ((__u32)libcfs_ioctl_packlen(data) != data->ioc_hdr.ioc_len) {
+	if ((u32)libcfs_ioctl_packlen(data) != data->ioc_hdr.ioc_len) {
 		CERROR("LIBCFS ioctl: packlen != ioc_len\n");
 		return true;
 	}
-- 
1.7.1
