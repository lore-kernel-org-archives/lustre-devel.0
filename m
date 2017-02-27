From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:45 -0500
Subject: [lustre-devel] [PATCH 20/34] staging: lustre: lnet: change
	lnet_portal_t to proper structure
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_portal_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lib-lnet.h  | 10 +++++-----
 drivers/staging/lustre/include/linux/lnet/lib-types.h |  8 ++++----
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 223e5a3..37b9d66 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -502,31 +502,31 @@ void lnet_prep_send(struct lnet_msg *msg, int type, lnet_process_id_t target,
 /* portals functions */
 /* portals attributes */
 static inline int
-lnet_ptl_is_lazy(lnet_portal_t *ptl)
+lnet_ptl_is_lazy(struct lnet_portal *ptl)
 {
 	return !!(ptl->ptl_options & LNET_PTL_LAZY);
 }
 
 static inline int
-lnet_ptl_is_unique(lnet_portal_t *ptl)
+lnet_ptl_is_unique(struct lnet_portal *ptl)
 {
 	return !!(ptl->ptl_options & LNET_PTL_MATCH_UNIQUE);
 }
 
 static inline int
-lnet_ptl_is_wildcard(lnet_portal_t *ptl)
+lnet_ptl_is_wildcard(struct lnet_portal *ptl)
 {
 	return !!(ptl->ptl_options & LNET_PTL_MATCH_WILDCARD);
 }
 
 static inline void
-lnet_ptl_setopt(lnet_portal_t *ptl, int opt)
+lnet_ptl_setopt(struct lnet_portal *ptl, int opt)
 {
 	ptl->ptl_options |= opt;
 }
 
 static inline void
-lnet_ptl_unsetopt(lnet_portal_t *ptl, int opt)
+lnet_ptl_unsetopt(struct lnet_portal *ptl, int opt)
 {
 	ptl->ptl_options &= ~opt;
 }
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index f939492..e00bd38 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -438,7 +438,7 @@ enum {
 	LNET_MATCHMD_FINISH	= (LNET_MATCHMD_OK | LNET_MATCHMD_DROP),
 };
 
-/* Options for lnet_portal_t::ptl_options */
+/* Options for lnet_portal::ptl_options */
 #define LNET_PTL_LAZY		(1 << 0)
 #define LNET_PTL_MATCH_UNIQUE	(1 << 1)	/* unique match, for RDMA */
 #define LNET_PTL_MATCH_WILDCARD	(1 << 2)	/* wildcard match,
@@ -497,7 +497,7 @@ struct lnet_match_table {
 /* dispatch routed PUT message by hashing source NID for wildcard portals */
 #define	LNET_PTL_ROTOR_HASH_RT	3
 
-typedef struct lnet_portal {
+struct lnet_portal {
 	spinlock_t		  ptl_lock;
 	unsigned int		  ptl_index;	/* portal ID, reserved */
 	/* flags on this portal: lazy, unique... */
@@ -514,7 +514,7 @@ struct lnet_match_table {
 	int			  ptl_mt_nmaps;
 	/* array of active entries' cpu-partition-id */
 	int			  ptl_mt_maps[0];
-} lnet_portal_t;
+};
 
 #define LNET_LH_HASH_BITS	12
 #define LNET_LH_HASH_SIZE	(1ULL << LNET_LH_HASH_BITS)
@@ -557,7 +557,7 @@ struct lnet_msg_container {
 	/* # portals */
 	int				  ln_nportals;
 	/* the vector of portals */
-	lnet_portal_t			**ln_portals;
+	struct lnet_portal		**ln_portals;
 	/* percpt ME containers */
 	struct lnet_res_container	**ln_me_containers;
 	/* percpt MD container */
-- 
1.8.3.1
