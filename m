From: James Simmons <jsimmons@infradead.org>
Date: Thu, 17 Nov 2016 14:35:51 -0500
Subject: [lustre-devel] [PATCH 13/19] staging: lustre: libcfs: white space
	cleanup
In-Reply-To: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
References: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479411357-28979-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Remove white space present for variable declarations
or initialization. Cleanup structs was strange
alignments due to white spacing.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/debug.c         |   16 ++--
 drivers/staging/lustre/lnet/libcfs/hash.c          |   24 +++---
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    |    2 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_lock.c   |   14 ++--
 drivers/staging/lustre/lnet/libcfs/libcfs_mem.c    |   22 ++--
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |   24 +++---
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   |  100 ++++++++++----------
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |   20 ++--
 .../staging/lustre/lnet/libcfs/linux/linux-debug.c |    6 +-
 .../staging/lustre/lnet/libcfs/linux/linux-prim.c  |   10 +-
 .../lustre/lnet/libcfs/linux/linux-tracefile.c     |    8 +-
 drivers/staging/lustre/lnet/libcfs/module.c        |   14 ++--
 drivers/staging/lustre/lnet/libcfs/tracefile.c     |   80 ++++++++--------
 drivers/staging/lustre/lnet/libcfs/tracefile.h     |   28 +++---
 drivers/staging/lustre/lnet/libcfs/workitem.c      |   40 ++++----
 15 files changed, 204 insertions(+), 204 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index 67f043e..a38db23 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -255,9 +255,9 @@ static int param_set_uintpos(const char *val, const struct kernel_param *kp)
 {
 	const char *(*fn)(int bit) = is_subsys ? libcfs_debug_subsys2str :
 						 libcfs_debug_dbg2str;
-	int	   len = 0;
-	const char   *token;
-	int	   i;
+	int len = 0;
+	const char *token;
+	int i;
 
 	if (!mask) {			/* "0" */
 		if (size > 0)
@@ -301,10 +301,10 @@ static int param_set_uintpos(const char *val, const struct kernel_param *kp)
 {
 	const char *(*fn)(int bit) = is_subsys ? libcfs_debug_subsys2str :
 						 libcfs_debug_dbg2str;
-	int	 m = 0;
-	int	 matched;
-	int	 n;
-	int	 t;
+	int m = 0;
+	int matched;
+	int n;
+	int t;
 
 	/* Allow a number for backwards compatibility */
 
@@ -389,8 +389,8 @@ void libcfs_debug_dumplog(void)
 
 int libcfs_debug_init(unsigned long bufsize)
 {
-	int    rc = 0;
 	unsigned int max = libcfs_debug_mb;
+	int rc = 0;
 
 	init_waitqueue_head(&debug_ctlwq);
 
diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index 22e1e25..12ed71c 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -289,7 +289,7 @@ struct cfs_hash_head_dep {
 static struct hlist_head *
 cfs_hash_hd_hhead(struct cfs_hash *hs, struct cfs_hash_bd *bd)
 {
-	struct cfs_hash_head_dep   *head;
+	struct cfs_hash_head_dep *head;
 
 	head = (struct cfs_hash_head_dep *)&bd->bd_bucket->hsb_head[0];
 	return &head[bd->bd_offset].hd_head;
@@ -512,9 +512,9 @@ struct cfs_hash_dhead_dep {
 		return;
 
 	spin_lock(&hs->hs_dep_lock);
-	hs->hs_dep_max  = dep_cur;
-	hs->hs_dep_bkt  = bd->bd_bucket->hsb_index;
-	hs->hs_dep_off  = bd->bd_offset;
+	hs->hs_dep_max = dep_cur;
+	hs->hs_dep_bkt = bd->bd_bucket->hsb_index;
+	hs->hs_dep_off = bd->bd_offset;
 	hs->hs_dep_bits = hs->hs_cur_bits;
 	spin_unlock(&hs->hs_dep_lock);
 
@@ -908,9 +908,9 @@ struct hlist_node *
 			return NULL;
 		}
 
-		new_bkts[i]->hsb_index   = i;
-		new_bkts[i]->hsb_version = 1;  /* shouldn't be zero */
-		new_bkts[i]->hsb_depmax  = -1; /* unknown */
+		new_bkts[i]->hsb_index = i;
+		new_bkts[i]->hsb_version = 1;	/* shouldn't be zero */
+		new_bkts[i]->hsb_depmax = -1;	/* unknown */
 		bd.bd_bucket = new_bkts[i];
 		cfs_hash_bd_for_each_hlist(hs, &bd, hhead)
 			INIT_HLIST_HEAD(hhead);
@@ -950,9 +950,9 @@ static int cfs_hash_dep_print(struct cfs_workitem *wi)
 	int bits;
 
 	spin_lock(&hs->hs_dep_lock);
-	dep  = hs->hs_dep_max;
-	bkt  = hs->hs_dep_bkt;
-	off  = hs->hs_dep_off;
+	dep = hs->hs_dep_max;
+	bkt = hs->hs_dep_bkt;
+	off = hs->hs_dep_off;
 	bits = hs->hs_dep_bits;
 	spin_unlock(&hs->hs_dep_lock);
 
@@ -1040,7 +1040,7 @@ struct cfs_hash *
 	hs->hs_max_bits = (__u8)max_bits;
 	hs->hs_bkt_bits = (__u8)bkt_bits;
 
-	hs->hs_ops	   = ops;
+	hs->hs_ops = ops;
 	hs->hs_extra_bytes = extra_bytes;
 	hs->hs_rehash_bits = 0;
 	cfs_wi_init(&hs->hs_rehash_wi, hs, cfs_hash_rehash_worker);
@@ -1292,7 +1292,7 @@ void cfs_hash_putref(struct cfs_hash *hs)
 	}
 
 	if (hnode) {
-		obj  = cfs_hash_object(hs, hnode);
+		obj = cfs_hash_object(hs, hnode);
 		bits = cfs_hash_rehash_bits(hs);
 	}
 
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 33352af..55caa19 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -74,7 +74,7 @@ struct cfs_cpt_table *
 int
 cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
 {
-	int	rc;
+	int rc;
 
 	rc = snprintf(buf, len, "%d\t: %d\n", 0, 0);
 	len -= rc;
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
index 66f020b..1967b97 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
@@ -52,9 +52,9 @@ struct cfs_percpt_lock *
 cfs_percpt_lock_create(struct cfs_cpt_table *cptab,
 		       struct lock_class_key *keys)
 {
-	struct cfs_percpt_lock	*pcl;
-	spinlock_t		*lock;
-	int			i;
+	struct cfs_percpt_lock *pcl;
+	spinlock_t *lock;
+	int i;
 
 	/* NB: cptab can be NULL, pcl will be for HW CPUs on that case */
 	LIBCFS_ALLOC(pcl, sizeof(*pcl));
@@ -94,8 +94,8 @@ struct cfs_percpt_lock *
 cfs_percpt_lock(struct cfs_percpt_lock *pcl, int index)
 	__acquires(pcl->pcl_locks)
 {
-	int	ncpt = cfs_cpt_number(pcl->pcl_cptab);
-	int	i;
+	int ncpt = cfs_cpt_number(pcl->pcl_cptab);
+	int i;
 
 	LASSERT(index >= CFS_PERCPT_LOCK_EX && index < ncpt);
 
@@ -130,8 +130,8 @@ struct cfs_percpt_lock *
 cfs_percpt_unlock(struct cfs_percpt_lock *pcl, int index)
 	__releases(pcl->pcl_locks)
 {
-	int	ncpt = cfs_cpt_number(pcl->pcl_cptab);
-	int	i;
+	int ncpt = cfs_cpt_number(pcl->pcl_cptab);
+	int i;
 
 	index = ncpt == 1 ? 0 : index;
 
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c b/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
index d0e81bb..ef085ba 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
@@ -43,8 +43,8 @@ struct cfs_var_array {
 void
 cfs_percpt_free(void *vars)
 {
-	struct	cfs_var_array *arr;
-	int	i;
+	struct cfs_var_array *arr;
+	int i;
 
 	arr = container_of(vars, struct cfs_var_array, va_ptrs[0]);
 
@@ -72,9 +72,9 @@ struct cfs_var_array {
 void *
 cfs_percpt_alloc(struct cfs_cpt_table *cptab, unsigned int size)
 {
-	struct cfs_var_array	*arr;
-	int			count;
-	int			i;
+	struct cfs_var_array *arr;
+	int count;
+	int i;
 
 	count = cfs_cpt_number(cptab);
 
@@ -120,8 +120,8 @@ struct cfs_var_array {
 void
 cfs_array_free(void *vars)
 {
-	struct cfs_var_array	*arr;
-	int			i;
+	struct cfs_var_array *arr;
+	int i;
 
 	arr = container_of(vars, struct cfs_var_array, va_ptrs[0]);
 
@@ -144,15 +144,15 @@ struct cfs_var_array {
 void *
 cfs_array_alloc(int count, unsigned int size)
 {
-	struct cfs_var_array	*arr;
-	int			i;
+	struct cfs_var_array *arr;
+	int i;
 
 	LIBCFS_ALLOC(arr, offsetof(struct cfs_var_array, va_ptrs[count]));
 	if (!arr)
 		return NULL;
 
-	arr->va_count	= count;
-	arr->va_size	= size;
+	arr->va_count = count;
+	arr->va_size = size;
 
 	for (i = 0; i < count; i++) {
 		LIBCFS_ALLOC(arr->va_ptrs[i], size);
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
index 6f6f240..ccebeb4 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
@@ -112,7 +112,7 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 char *cfs_firststr(char *str, size_t size)
 {
 	size_t i = 0;
-	char  *end;
+	char *end;
 
 	/* trim leading spaces */
 	while (i < size && *str && isspace(*str)) {
@@ -276,8 +276,8 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 cfs_range_expr_parse(struct cfs_lstr *src, unsigned int min, unsigned int max,
 		     int bracketed, struct cfs_range_expr **expr)
 {
-	struct cfs_range_expr	*re;
-	struct cfs_lstr		tok;
+	struct cfs_range_expr *re;
+	struct cfs_lstr tok;
 
 	LIBCFS_ALLOC(re, sizeof(*re));
 	if (!re)
@@ -413,7 +413,7 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 int
 cfs_expr_list_match(__u32 value, struct cfs_expr_list *expr_list)
 {
-	struct cfs_range_expr	*expr;
+	struct cfs_range_expr *expr;
 
 	list_for_each_entry(expr, &expr_list->el_exprs, re_link) {
 		if (value >= expr->re_lo && value <= expr->re_hi &&
@@ -435,10 +435,10 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 int
 cfs_expr_list_values(struct cfs_expr_list *expr_list, int max, __u32 **valpp)
 {
-	struct cfs_range_expr	*expr;
-	__u32			*val;
-	int			count = 0;
-	int			i;
+	struct cfs_range_expr *expr;
+	__u32 *val;
+	int count = 0;
+	int i;
 
 	list_for_each_entry(expr, &expr_list->el_exprs, re_link) {
 		for (i = expr->re_lo; i <= expr->re_hi; i++) {
@@ -504,10 +504,10 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 cfs_expr_list_parse(char *str, int len, unsigned int min, unsigned int max,
 		    struct cfs_expr_list **elpp)
 {
-	struct cfs_expr_list	*expr_list;
-	struct cfs_range_expr	*expr;
-	struct cfs_lstr		src;
-	int			rc;
+	struct cfs_expr_list *expr_list;
+	struct cfs_range_expr *expr;
+	struct cfs_lstr	src;
+	int rc;
 
 	LIBCFS_ALLOC(expr_list, sizeof(*expr_list));
 	if (!expr_list)
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index 8c3fcdb..6b9cf06 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -90,7 +90,7 @@ struct cfs_cpt_data {
 void
 cfs_cpt_table_free(struct cfs_cpt_table *cptab)
 {
-	int	i;
+	int i;
 
 	if (cptab->ctb_cpu2cpt) {
 		LIBCFS_FREE(cptab->ctb_cpu2cpt,
@@ -128,7 +128,7 @@ struct cfs_cpt_table *
 cfs_cpt_table_alloc(unsigned int ncpt)
 {
 	struct cfs_cpt_table *cptab;
-	int	i;
+	int i;
 
 	LIBCFS_ALLOC(cptab, sizeof(*cptab));
 	if (!cptab)
@@ -179,10 +179,10 @@ struct cfs_cpt_table *
 int
 cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
 {
-	char	*tmp = buf;
-	int	rc = 0;
-	int	i;
-	int	j;
+	char *tmp = buf;
+	int rc = 0;
+	int i;
+	int j;
 
 	for (i = 0; i < cptab->ctb_nparts; i++) {
 		if (len > 0) {
@@ -273,7 +273,7 @@ struct cfs_cpt_table *
 int
 cfs_cpt_set_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
 {
-	int	node;
+	int node;
 
 	LASSERT(cpt >= 0 && cpt < cptab->ctb_nparts);
 
@@ -313,8 +313,8 @@ struct cfs_cpt_table *
 void
 cfs_cpt_unset_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
 {
-	int	node;
-	int	i;
+	int node;
+	int i;
 
 	LASSERT(cpt == CFS_CPT_ANY || (cpt >= 0 && cpt < cptab->ctb_nparts));
 
@@ -373,7 +373,7 @@ struct cfs_cpt_table *
 int
 cfs_cpt_set_cpumask(struct cfs_cpt_table *cptab, int cpt, cpumask_t *mask)
 {
-	int	i;
+	int i;
 
 	if (!cpumask_weight(mask) ||
 	    cpumask_any_and(mask, cpu_online_mask) >= nr_cpu_ids) {
@@ -394,7 +394,7 @@ struct cfs_cpt_table *
 void
 cfs_cpt_unset_cpumask(struct cfs_cpt_table *cptab, int cpt, cpumask_t *mask)
 {
-	int	i;
+	int i;
 
 	for_each_cpu(i, mask)
 		cfs_cpt_unset_cpu(cptab, cpt, i);
@@ -404,8 +404,8 @@ struct cfs_cpt_table *
 int
 cfs_cpt_set_node(struct cfs_cpt_table *cptab, int cpt, int node)
 {
-	cpumask_t	*mask;
-	int		rc;
+	cpumask_t *mask;
+	int rc;
 
 	if (node < 0 || node >= MAX_NUMNODES) {
 		CDEBUG(D_INFO,
@@ -451,7 +451,7 @@ struct cfs_cpt_table *
 int
 cfs_cpt_set_nodemask(struct cfs_cpt_table *cptab, int cpt, nodemask_t *mask)
 {
-	int	i;
+	int i;
 
 	for_each_node_mask(i, *mask) {
 		if (!cfs_cpt_set_node(cptab, cpt, i))
@@ -465,7 +465,7 @@ struct cfs_cpt_table *
 void
 cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab, int cpt, nodemask_t *mask)
 {
-	int	i;
+	int i;
 
 	for_each_node_mask(i, *mask)
 		cfs_cpt_unset_node(cptab, cpt, i);
@@ -475,8 +475,8 @@ struct cfs_cpt_table *
 void
 cfs_cpt_clear(struct cfs_cpt_table *cptab, int cpt)
 {
-	int	last;
-	int	i;
+	int last;
+	int i;
 
 	if (cpt == CFS_CPT_ANY) {
 		last = cptab->ctb_nparts - 1;
@@ -495,10 +495,10 @@ struct cfs_cpt_table *
 int
 cfs_cpt_spread_node(struct cfs_cpt_table *cptab, int cpt)
 {
-	nodemask_t	*mask;
-	int		weight;
-	int		rotor;
-	int		node;
+	nodemask_t *mask;
+	int weight;
+	int rotor;
+	int node;
 
 	/* convert CPU partition ID to HW node id */
 
@@ -528,8 +528,8 @@ struct cfs_cpt_table *
 int
 cfs_cpt_current(struct cfs_cpt_table *cptab, int remap)
 {
-	int	cpu = smp_processor_id();
-	int	cpt = cptab->ctb_cpu2cpt[cpu];
+	int cpu = smp_processor_id();
+	int cpt = cptab->ctb_cpu2cpt[cpu];
 
 	if (cpt < 0) {
 		if (!remap)
@@ -557,10 +557,10 @@ struct cfs_cpt_table *
 int
 cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
 {
-	cpumask_t	*cpumask;
-	nodemask_t	*nodemask;
-	int		rc;
-	int		i;
+	cpumask_t *cpumask;
+	nodemask_t *nodemask;
+	int rc;
+	int i;
 
 	LASSERT(cpt == CFS_CPT_ANY || (cpt >= 0 && cpt < cptab->ctb_nparts));
 
@@ -603,10 +603,10 @@ struct cfs_cpt_table *
 cfs_cpt_choose_ncpus(struct cfs_cpt_table *cptab, int cpt,
 		     cpumask_t *node, int number)
 {
-	cpumask_t	*socket = NULL;
-	cpumask_t	*core = NULL;
-	int		rc = 0;
-	int		cpu;
+	cpumask_t *socket = NULL;
+	cpumask_t *core = NULL;
+	int rc = 0;
+	int cpu;
 
 	LASSERT(number > 0);
 
@@ -640,7 +640,7 @@ struct cfs_cpt_table *
 		LASSERT(!cpumask_empty(socket));
 
 		while (!cpumask_empty(socket)) {
-			int     i;
+			int i;
 
 			/* get cpumask for hts in the same core */
 			cpumask_copy(core, topology_sibling_cpumask(cpu));
@@ -665,7 +665,7 @@ struct cfs_cpt_table *
 		}
 	}
 
- out:
+out:
 	if (socket)
 		LIBCFS_FREE(socket, cpumask_size());
 	if (core)
@@ -705,7 +705,7 @@ struct cfs_cpt_table *
 
 	ncpt = nnode;
 
- out:
+out:
 #if (BITS_PER_LONG == 32)
 	/* config many CPU partitions on 32-bit system could consume
 	 * too much memory
@@ -722,11 +722,11 @@ struct cfs_cpt_table *
 cfs_cpt_table_create(int ncpt)
 {
 	struct cfs_cpt_table *cptab = NULL;
-	cpumask_t	*mask = NULL;
-	int		cpt = 0;
-	int		num;
-	int		rc;
-	int		i;
+	cpumask_t *mask = NULL;
+	int cpt = 0;
+	int num;
+	int rc;
+	int i;
 
 	rc = cfs_cpt_num_estimate();
 	if (ncpt <= 0)
@@ -766,7 +766,7 @@ struct cfs_cpt_table *
 
 		while (!cpumask_empty(mask)) {
 			struct cfs_cpu_partition *part;
-			int    n;
+			int n;
 
 			/*
 			 * Each emulated NUMA node has all allowed CPUs in
@@ -819,14 +819,14 @@ struct cfs_cpt_table *
 static struct cfs_cpt_table *
 cfs_cpt_table_create_pattern(char *pattern)
 {
-	struct cfs_cpt_table	*cptab;
+	struct cfs_cpt_table *cptab;
 	char *str;
-	int			node	= 0;
-	int			high;
+	int node = 0;
+	int high;
 	int ncpt = 0;
 	int cpt;
 	int rc;
-	int			c;
+	int c;
 	int i;
 
 	str = cfs_trimwhite(pattern);
@@ -882,10 +882,10 @@ struct cfs_cpt_table *
 	high = node ? MAX_NUMNODES - 1 : nr_cpu_ids - 1;
 
 	for (str = cfs_trimwhite(pattern), c = 0;; c++) {
-		struct cfs_range_expr	*range;
-		struct cfs_expr_list	*el;
-		char			*bracket = strchr(str, '[');
-		int			n;
+		struct cfs_range_expr *range;
+		struct cfs_expr_list *el;
+		char *bracket = strchr(str, '[');
+		int n;
 
 		if (!bracket) {
 			if (*str) {
@@ -970,8 +970,8 @@ struct cfs_cpt_table *
 static int
 cfs_cpu_notify(struct notifier_block *self, unsigned long action, void *hcpu)
 {
-	unsigned int  cpu = (unsigned long)hcpu;
-	bool	     warn;
+	unsigned int cpu = (unsigned long)hcpu;
+	bool warn;
 
 	switch (action) {
 	case CPU_DEAD:
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index ac2e055..53b1bf7 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -64,7 +64,7 @@ static int cfs_crypto_hash_alloc(enum cfs_crypto_hash_alg hash_alg,
 				 unsigned int key_len)
 {
 	struct crypto_ahash *tfm;
-	int     err = 0;
+	int err = 0;
 
 	*type = cfs_crypto_hash_type(hash_alg);
 
@@ -147,10 +147,10 @@ int cfs_crypto_hash_digest(enum cfs_crypto_hash_alg hash_alg,
 			   unsigned char *key, unsigned int key_len,
 			   unsigned char *hash, unsigned int *hash_len)
 {
-	struct scatterlist	sl;
+	struct scatterlist sl;
 	struct ahash_request *req;
-	int			err;
-	const struct cfs_crypto_hash_type	*type;
+	int err;
+	const struct cfs_crypto_hash_type *type;
 
 	if (!buf || !buf_len || !hash_len)
 		return -EINVAL;
@@ -198,8 +198,8 @@ struct cfs_crypto_hash_desc *
 		     unsigned char *key, unsigned int key_len)
 {
 	struct ahash_request *req;
-	int		     err;
-	const struct cfs_crypto_hash_type       *type;
+	int err;
+	const struct cfs_crypto_hash_type *type;
 
 	err = cfs_crypto_hash_alloc(hash_alg, &type, &req, key, key_len);
 
@@ -273,7 +273,7 @@ int cfs_crypto_hash_update(struct cfs_crypto_hash_desc *hdesc,
 int cfs_crypto_hash_final(struct cfs_crypto_hash_desc *hdesc,
 			  unsigned char *hash, unsigned int *hash_len)
 {
-	int     err;
+	int err;
 	struct ahash_request *req = (void *)hdesc;
 	int size = crypto_ahash_digestsize(crypto_ahash_reqtfm(req));
 
@@ -312,8 +312,8 @@ static void cfs_crypto_performance_test(enum cfs_crypto_hash_alg hash_alg)
 {
 	int buf_len = max(PAGE_SIZE, 1048576UL);
 	void *buf;
-	unsigned long		   start, end;
-	int			     bcount, err = 0;
+	unsigned long start, end;
+	int bcount, err = 0;
 	struct page *page;
 	unsigned char hash[CFS_CRYPTO_HASH_DIGESTSIZE_MAX];
 	unsigned int hash_len = sizeof(hash);
@@ -358,7 +358,7 @@ static void cfs_crypto_performance_test(enum cfs_crypto_hash_alg hash_alg)
 		CDEBUG(D_INFO, "Crypto hash algorithm %s test error: rc = %d\n",
 		       cfs_crypto_hash_name(hash_alg), err);
 	} else {
-		unsigned long   tmp;
+		unsigned long tmp;
 
 		tmp = ((bcount * buf_len / jiffies_to_msecs(end - start)) *
 		       1000) / (1024 * 1024);
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
index 435b784..8d37938 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
@@ -68,7 +68,7 @@
 void libcfs_run_debug_log_upcall(char *file)
 {
 	char *argv[3];
-	int   rc;
+	int rc;
 	char *envp[] = {
 		"HOME=/",
 		"PATH=/sbin:/bin:/usr/sbin:/usr/bin",
@@ -93,8 +93,8 @@ void libcfs_run_debug_log_upcall(char *file)
 
 void libcfs_run_upcall(char **argv)
 {
-	int   rc;
-	int   argc;
+	int rc;
+	int argc;
 	char *envp[] = {
 		"HOME=/",
 		"PATH=/sbin:/bin:/usr/sbin:/usr/bin",
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
index 291d286..cf90215 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
@@ -45,8 +45,8 @@
 sigset_t
 cfs_block_allsigs(void)
 {
-	unsigned long	  flags;
-	sigset_t	old;
+	unsigned long flags;
+	sigset_t old;
 
 	spin_lock_irqsave(&current->sighand->siglock, flags);
 	old = current->blocked;
@@ -60,8 +60,8 @@
 
 sigset_t cfs_block_sigs(unsigned long sigs)
 {
-	unsigned long  flags;
-	sigset_t	old;
+	unsigned long flags;
+	sigset_t old;
 
 	spin_lock_irqsave(&current->sighand->siglock, flags);
 	old = current->blocked;
@@ -91,7 +91,7 @@ sigset_t cfs_block_sigsinv(unsigned long sigs)
 void
 cfs_restore_sigs(sigset_t old)
 {
-	unsigned long  flags;
+	unsigned long flags;
 
 	spin_lock_irqsave(&current->sighand->siglock, flags);
 	current->blocked = old;
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
index 404c2cc..a3cabb9 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
@@ -49,8 +49,8 @@
 
 int cfs_tracefile_init_arch(void)
 {
-	int    i;
-	int    j;
+	int i;
+	int j;
 	struct cfs_trace_cpu_data *tcd;
 
 	/* initialize trace_data */
@@ -91,8 +91,8 @@ int cfs_tracefile_init_arch(void)
 
 void cfs_tracefile_fini_arch(void)
 {
-	int    i;
-	int    j;
+	int i;
+	int j;
 
 	for (i = 0; i < num_possible_cpus(); i++)
 		for (j = 0; j < 3; j++) {
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index cd057f1..5884a33 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -183,12 +183,12 @@ int lprocfs_call_handler(void *data, int write, loff_t *ppos,
 static int __proc_dobitmasks(void *data, int write,
 			     loff_t pos, void __user *buffer, int nob)
 {
-	const int     tmpstrlen = 512;
-	char	 *tmpstr;
-	int	   rc;
+	const int tmpstrlen = 512;
+	char *tmpstr;
+	int rc;
 	unsigned int *mask = data;
-	int	   is_subsys = (mask == &libcfs_subsystem_debug) ? 1 : 0;
-	int	   is_printk = (mask == &libcfs_printk) ? 1 : 0;
+	int is_subsys = (mask == &libcfs_subsystem_debug) ? 1 : 0;
+	int is_printk = (mask == &libcfs_printk) ? 1 : 0;
 
 	rc = cfs_trace_allocate_string_buffer(&tmpstr, tmpstrlen);
 	if (rc < 0)
@@ -293,8 +293,8 @@ static int __proc_cpt_table(void *data, int write,
 			    loff_t pos, void __user *buffer, int nob)
 {
 	char *buf = NULL;
-	int   len = 4096;
-	int   rc  = 0;
+	int len = 4096;
+	int rc  = 0;
 
 	if (write)
 		return -EPERM;
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index a15cedd..d7b29f8 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -59,13 +59,13 @@ struct page_collection {
 	 * ->tcd_daemon_pages and ->tcd_pages to the ->pc_pages. Otherwise,
 	 * only ->tcd_pages are spilled.
 	 */
-	int		pc_want_daemon_pages;
+	int			pc_want_daemon_pages;
 };
 
 struct tracefiled_ctl {
 	struct completion	tctl_start;
 	struct completion	tctl_stop;
-	wait_queue_head_t		tctl_waitq;
+	wait_queue_head_t	tctl_waitq;
 	pid_t			tctl_pid;
 	atomic_t		tctl_shutdown;
 };
@@ -77,24 +77,24 @@ struct cfs_trace_page {
 	/*
 	 * page itself
 	 */
-	struct page	  *page;
+	struct page		*page;
 	/*
 	 * linkage into one of the lists in trace_data_union or
 	 * page_collection
 	 */
-	struct list_head	   linkage;
+	struct list_head	linkage;
 	/*
 	 * number of bytes used within this page
 	 */
-	unsigned int	 used;
+	unsigned int		used;
 	/*
 	 * cpu that owns this page
 	 */
-	unsigned short       cpu;
+	unsigned short		cpu;
 	/*
 	 * type(context) of this page
 	 */
-	unsigned short       type;
+	unsigned short		type;
 };
 
 static void put_pages_on_tcd_daemon_list(struct page_collection *pc,
@@ -108,7 +108,7 @@ static void put_pages_on_tcd_daemon_list(struct page_collection *pc,
 
 static struct cfs_trace_page *cfs_tage_alloc(gfp_t gfp)
 {
-	struct page	    *page;
+	struct page *page;
 	struct cfs_trace_page *tage;
 
 	/* My caller is trying to free memory */
@@ -278,7 +278,7 @@ int libcfs_debug_msg(struct libcfs_debug_msg_data *msgdata,
 		     const char *format, ...)
 {
 	va_list args;
-	int     rc;
+	int rc;
 
 	va_start(args, format);
 	rc = libcfs_debug_vmsg2(msgdata, format, args, NULL);
@@ -293,21 +293,21 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 		       const char *format2, ...)
 {
 	struct cfs_trace_cpu_data *tcd = NULL;
-	struct ptldebug_header     header = {0};
-	struct cfs_trace_page     *tage;
+	struct ptldebug_header header = { 0 };
+	struct cfs_trace_page *tage;
 	/* string_buf is used only if tcd != NULL, and is always set then */
-	char		      *string_buf = NULL;
-	char		      *debug_buf;
-	int			known_size;
-	int			needed = 85; /* average message length */
-	int			max_nob;
-	va_list		    ap;
-	int			depth;
-	int			i;
-	int			remain;
-	int			mask = msgdata->msg_mask;
-	const char		*file = kbasename(msgdata->msg_file);
-	struct cfs_debug_limit_state   *cdls = msgdata->msg_cdls;
+	char *string_buf = NULL;
+	char *debug_buf;
+	int known_size;
+	int needed = 85; /* average message length */
+	int max_nob;
+	va_list ap;
+	int depth;
+	int i;
+	int remain;
+	int mask = msgdata->msg_mask;
+	const char *file = kbasename(msgdata->msg_file);
+	struct cfs_debug_limit_state *cdls = msgdata->msg_cdls;
 
 	tcd = cfs_trace_get_tcd();
 
@@ -535,9 +535,9 @@ int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
 	 * CPUs have been stopped during a panic.  If this isn't true for some
 	 * arch, this will have to be implemented separately in each arch.
 	 */
-	int			i;
-	int			j;
 	struct cfs_trace_cpu_data *tcd;
+	int i;
+	int j;
 
 	INIT_LIST_HEAD(&pc->pc_pages);
 
@@ -698,11 +698,11 @@ void cfs_trace_debug_print(void)
 
 int cfs_tracefile_dump_all_pages(char *filename)
 {
-	struct page_collection	pc;
-	struct file		*filp;
-	struct cfs_trace_page	*tage;
-	struct cfs_trace_page	*tmp;
-	char			*buf;
+	struct page_collection pc;
+	struct file *filp;
+	struct cfs_trace_page *tage;
+	struct cfs_trace_page *tmp;
+	char *buf;
 	mm_segment_t __oldfs;
 	int rc;
 
@@ -778,7 +778,7 @@ void cfs_trace_flush_pages(void)
 int cfs_trace_copyin_string(char *knl_buffer, int knl_buffer_nob,
 			    const char __user *usr_buffer, int usr_buffer_nob)
 {
-	int    nob;
+	int nob;
 
 	if (usr_buffer_nob > knl_buffer_nob)
 		return -EOVERFLOW;
@@ -810,7 +810,7 @@ int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 	 * NB if 'append' != NULL, it's a single character to append to the
 	 * copied out string - usually "\n" or "" (i.e. a terminating zero byte)
 	 */
-	int   nob = strlen(knl_buffer);
+	int nob = strlen(knl_buffer);
 
 	if (nob > usr_buffer_nob)
 		nob = usr_buffer_nob;
@@ -843,8 +843,8 @@ int cfs_trace_allocate_string_buffer(char **str, int nob)
 
 int cfs_trace_dump_debug_buffer_usrstr(void __user *usr_str, int usr_str_nob)
 {
-	char	 *str;
-	int	   rc;
+	char *str;
+	int rc;
 
 	rc = cfs_trace_allocate_string_buffer(&str, usr_str_nob + 1);
 	if (rc)
@@ -867,7 +867,7 @@ int cfs_trace_dump_debug_buffer_usrstr(void __user *usr_str, int usr_str_nob)
 
 int cfs_trace_daemon_command(char *str)
 {
-	int       rc = 0;
+	int rc = 0;
 
 	cfs_tracefile_write_lock();
 
@@ -909,7 +909,7 @@ int cfs_trace_daemon_command(char *str)
 int cfs_trace_daemon_command_usrstr(void __user *usr_str, int usr_str_nob)
 {
 	char *str;
-	int   rc;
+	int rc;
 
 	rc = cfs_trace_allocate_string_buffer(&str, usr_str_nob + 1);
 	if (rc)
@@ -1135,10 +1135,10 @@ void cfs_trace_stop_thread(void)
 int cfs_tracefile_init(int max_pages)
 {
 	struct cfs_trace_cpu_data *tcd;
-	int		    i;
-	int		    j;
-	int		    rc;
-	int		    factor;
+	int i;
+	int j;
+	int rc;
+	int factor;
 
 	rc = cfs_tracefile_init_arch();
 	if (rc)
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index d878676..f644cbc 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -45,7 +45,7 @@ enum cfs_trace_buf_type {
 /* trace file lock routines */
 
 #define TRACEFILE_NAME_SIZE 1024
-extern char      cfs_tracefile[TRACEFILE_NAME_SIZE];
+extern char cfs_tracefile[TRACEFILE_NAME_SIZE];
 extern long long cfs_tracefile_size;
 
 void libcfs_run_debug_log_upcall(char *file);
@@ -80,7 +80,7 @@ int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 void libcfs_debug_dumplog_internal(void *arg);
 void libcfs_register_panic_notifier(void);
 void libcfs_unregister_panic_notifier(void);
-extern int  libcfs_panic_in_progress;
+extern int libcfs_panic_in_progress;
 int cfs_trace_max_debug_mb(void);
 
 #define TCD_MAX_PAGES (5 << (20 - PAGE_SHIFT))
@@ -113,14 +113,14 @@ int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 		 * tcd_for_each_type_lock
 		 */
 		spinlock_t		tcd_lock;
-		unsigned long	   tcd_lock_flags;
+		unsigned long		tcd_lock_flags;
 
 		/*
 		 * pages with trace records not yet processed by tracefiled.
 		 */
-		struct list_head	      tcd_pages;
+		struct list_head	tcd_pages;
 		/* number of pages on ->tcd_pages */
-		unsigned long	   tcd_cur_pages;
+		unsigned long		tcd_cur_pages;
 
 		/*
 		 * pages with trace records already processed by
@@ -132,9 +132,9 @@ int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 		 * (put_pages_on_daemon_list()). LRU pages from this list are
 		 * discarded when list grows too large.
 		 */
-		struct list_head	      tcd_daemon_pages;
+		struct list_head	tcd_daemon_pages;
 		/* number of pages on ->tcd_daemon_pages */
-		unsigned long	   tcd_cur_daemon_pages;
+		unsigned long		tcd_cur_daemon_pages;
 
 		/*
 		 * Maximal number of pages allowed on ->tcd_pages and
@@ -142,7 +142,7 @@ int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 		 * Always TCD_MAX_PAGES * tcd_pages_factor / 100 in current
 		 * implementation.
 		 */
-		unsigned long	   tcd_max_pages;
+		unsigned long		tcd_max_pages;
 
 		/*
 		 * preallocated pages to write trace records into. Pages from
@@ -166,15 +166,15 @@ int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
 		 * TCD_STOCK_PAGES pagesful are consumed by trace records all
 		 * emitted in non-blocking contexts. Which is quite unlikely.
 		 */
-		struct list_head	      tcd_stock_pages;
+		struct list_head	tcd_stock_pages;
 		/* number of pages on ->tcd_stock_pages */
-		unsigned long	   tcd_cur_stock_pages;
+		unsigned long		tcd_cur_stock_pages;
 
-		unsigned short	  tcd_shutting_down;
-		unsigned short	  tcd_cpu;
-		unsigned short	  tcd_type;
+		unsigned short		tcd_shutting_down;
+		unsigned short		tcd_cpu;
+		unsigned short		tcd_type;
 		/* The factors to share debug memory. */
-		unsigned short	  tcd_pages_factor;
+		unsigned short		tcd_pages_factor;
 	} tcd;
 	char __pad[L1_CACHE_ALIGN(sizeof(struct cfs_trace_cpu_data))];
 };
diff --git a/drivers/staging/lustre/lnet/libcfs/workitem.c b/drivers/staging/lustre/lnet/libcfs/workitem.c
index f5f1e9e..d0512da 100644
--- a/drivers/staging/lustre/lnet/libcfs/workitem.c
+++ b/drivers/staging/lustre/lnet/libcfs/workitem.c
@@ -45,7 +45,7 @@ struct cfs_wi_sched {
 	/* chain on global list */
 	struct list_head		ws_list;
 	/** serialised workitems */
-	spinlock_t		ws_lock;
+	spinlock_t			ws_lock;
 	/** where schedulers sleep */
 	wait_queue_head_t		ws_waitq;
 	/** concurrent workitems */
@@ -59,26 +59,26 @@ struct cfs_wi_sched {
 	 */
 	struct list_head		ws_rerunq;
 	/** CPT-table for this scheduler */
-	struct cfs_cpt_table	*ws_cptab;
+	struct cfs_cpt_table		*ws_cptab;
 	/** CPT id for affinity */
-	int			ws_cpt;
+	int				ws_cpt;
 	/** number of scheduled workitems */
-	int			ws_nscheduled;
+	int				ws_nscheduled;
 	/** started scheduler thread, protected by cfs_wi_data::wi_glock */
-	unsigned int		ws_nthreads:30;
+	unsigned int			ws_nthreads:30;
 	/** shutting down, protected by cfs_wi_data::wi_glock */
-	unsigned int		ws_stopping:1;
+	unsigned int			ws_stopping:1;
 	/** serialize starting thread, protected by cfs_wi_data::wi_glock */
-	unsigned int		ws_starting:1;
+	unsigned int			ws_starting:1;
 	/** scheduler name */
-	char			ws_name[CFS_WS_NAME_LEN];
+	char				ws_name[CFS_WS_NAME_LEN];
 };
 
 static struct cfs_workitem_data {
 	/** serialize */
 	spinlock_t		wi_glock;
 	/** list of all schedulers */
-	struct list_head		wi_scheds;
+	struct list_head	wi_scheds;
 	/** WI module is initialized */
 	int			wi_init;
 	/** shutting down the whole WI module */
@@ -136,7 +136,7 @@ struct cfs_wi_sched {
 int
 cfs_wi_deschedule(struct cfs_wi_sched *sched, struct cfs_workitem *wi)
 {
-	int	rc;
+	int rc;
 
 	LASSERT(!in_interrupt()); /* because we use plain spinlock */
 	LASSERT(!sched->ws_stopping);
@@ -202,7 +202,7 @@ struct cfs_wi_sched {
 
 static int cfs_wi_scheduler(void *arg)
 {
-	struct cfs_wi_sched	*sched = (struct cfs_wi_sched *)arg;
+	struct cfs_wi_sched *sched = (struct cfs_wi_sched *)arg;
 
 	cfs_block_allsigs();
 
@@ -223,8 +223,8 @@ static int cfs_wi_scheduler(void *arg)
 	spin_lock(&sched->ws_lock);
 
 	while (!sched->ws_stopping) {
-		int	     nloops = 0;
-		int	     rc;
+		int nloops = 0;
+		int rc;
 		struct cfs_workitem *wi;
 
 		while (!list_empty(&sched->ws_runq) &&
@@ -238,13 +238,13 @@ static int cfs_wi_scheduler(void *arg)
 			LASSERT(sched->ws_nscheduled > 0);
 			sched->ws_nscheduled--;
 
-			wi->wi_running   = 1;
+			wi->wi_running = 1;
 			wi->wi_scheduled = 0;
 
 			spin_unlock(&sched->ws_lock);
 			nloops++;
 
-			rc = (*wi->wi_action) (wi);
+			rc = (*wi->wi_action)(wi);
 
 			spin_lock(&sched->ws_lock);
 			if (rc) /* WI should be dead, even be freed! */
@@ -289,7 +289,7 @@ static int cfs_wi_scheduler(void *arg)
 void
 cfs_wi_sched_destroy(struct cfs_wi_sched *sched)
 {
-	int	i;
+	int i;
 
 	LASSERT(cfs_wi_data.wi_init);
 	LASSERT(!cfs_wi_data.wi_stopping);
@@ -335,8 +335,8 @@ static int cfs_wi_scheduler(void *arg)
 cfs_wi_sched_create(char *name, struct cfs_cpt_table *cptab,
 		    int cpt, int nthrs, struct cfs_wi_sched **sched_pp)
 {
-	struct cfs_wi_sched	*sched;
-	int			rc;
+	struct cfs_wi_sched *sched;
+	int rc;
 
 	LASSERT(cfs_wi_data.wi_init);
 	LASSERT(!cfs_wi_data.wi_stopping);
@@ -364,7 +364,7 @@ static int cfs_wi_scheduler(void *arg)
 
 	rc = 0;
 	while (nthrs > 0)  {
-		char	name[16];
+		char name[16];
 		struct task_struct *task;
 
 		spin_lock(&cfs_wi_data.wi_glock);
@@ -431,7 +431,7 @@ static int cfs_wi_scheduler(void *arg)
 void
 cfs_wi_shutdown(void)
 {
-	struct cfs_wi_sched	*sched;
+	struct cfs_wi_sched *sched;
 	struct cfs_wi_sched *temp;
 
 	spin_lock(&cfs_wi_data.wi_glock);
-- 
1.7.1
