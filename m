From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:08 -0400
Subject: [lustre-devel] [PATCH 009/124] staging: lustre: obdclass: serialize
	lu_site purge
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Niu Yawei <yawei.niu@intel.com>

Umount process relies on lu_site_purge(-1) to purge all
objects before umount, however, if there happen to have a
cache shrinker which calls lu_site_purge(nr) in parallel,
some objects may still being freed by cache shrinker even
after the lu_site_purge(-1) called by umount done.

This can be simply fixed by serializing purge threads,
since it doesn't make any sense to have them in parallel.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5331
Reviewed-on: http://review.whamcloud.com/11099
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lu_object.h  |    5 +++++
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    7 +++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 502bc41..fe40b42 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -623,6 +623,11 @@ struct lu_site {
 	spinlock_t		ls_ld_lock;
 
 	/**
+	 * Lock to serialize site purge.
+	 */
+	struct mutex		ls_purge_mutex;
+
+	/**
 	 * lu_site stats
 	 */
 	struct lprocfs_stats	*ls_stats;
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 9d1c96b..b6fd9af 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -354,6 +354,11 @@ int lu_site_purge(const struct lu_env *env, struct lu_site *s, int nr)
 	start = s->ls_purge_start;
 	bnr = (nr == ~0) ? -1 : nr / CFS_HASH_NBKT(s->ls_obj_hash) + 1;
  again:
+	/*
+	 * It doesn't make any sense to make purge threads parallel, that can
+	 * only bring troubles to us. See LU-5331.
+	 */
+	mutex_lock(&s->ls_purge_mutex);
 	did_sth = 0;
 	cfs_hash_for_each_bucket(s->ls_obj_hash, &bd, i) {
 		if (i < start)
@@ -399,6 +404,7 @@ int lu_site_purge(const struct lu_env *env, struct lu_site *s, int nr)
 		if (nr == 0)
 			break;
 	}
+	mutex_unlock(&s->ls_purge_mutex);
 
 	if (nr != 0 && did_sth && start != 0) {
 		start = 0; /* restart from the first bucket */
@@ -983,6 +989,7 @@ int lu_site_init(struct lu_site *s, struct lu_device *top)
 	char name[16];
 
 	memset(s, 0, sizeof(*s));
+	mutex_init(&s->ls_purge_mutex);
 	snprintf(name, 16, "lu_site_%s", top->ld_type->ldt_name);
 	for (bits = lu_htable_order(top); bits >= LU_SITE_BITS_MIN; bits--) {
 		s->ls_obj_hash = cfs_hash_create(name, bits, bits,
-- 
1.7.1
