From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:53:40 -0500
Subject: [lustre-devel] [PATCH 02/56] staging/lustre: Get rid of
	client_obd_lock_t typedef
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-3-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Replace it with struct client_obd_lock

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/linux/obd.h | 12 ++++++------
 drivers/staging/lustre/lustre/include/obd.h       |  4 ++--
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/linux/obd.h b/drivers/staging/lustre/lustre/include/linux/obd.h
index 240947b..3907bf4 100644
--- a/drivers/staging/lustre/lustre/include/linux/obd.h
+++ b/drivers/staging/lustre/lustre/include/linux/obd.h
@@ -57,16 +57,16 @@ struct ll_iattr {
 
 #define CLIENT_OBD_LIST_LOCK_DEBUG 1
 
-typedef struct {
+struct client_obd_lock {
 	spinlock_t		lock;
 
 	unsigned long       time;
 	struct task_struct *task;
 	const char	 *func;
 	int		 line;
-} client_obd_lock_t;
+};
 
-static inline void __client_obd_list_lock(client_obd_lock_t *lock,
+static inline void __client_obd_list_lock(struct client_obd_lock *lock,
 					  const char *func, int line)
 {
 	unsigned long cur = jiffies;
@@ -106,7 +106,7 @@ static inline void __client_obd_list_lock(client_obd_lock_t *lock,
 #define client_obd_list_lock(lock) \
 	__client_obd_list_lock(lock, __func__, __LINE__)
 
-static inline void client_obd_list_unlock(client_obd_lock_t *lock)
+static inline void client_obd_list_unlock(struct client_obd_lock *lock)
 {
 	LASSERT(lock->task);
 	lock->task = NULL;
@@ -114,12 +114,12 @@ static inline void client_obd_list_unlock(client_obd_lock_t *lock)
 	spin_unlock(&lock->lock);
 }
 
-static inline void client_obd_list_lock_init(client_obd_lock_t *lock)
+static inline void client_obd_list_lock_init(struct client_obd_lock *lock)
 {
 	spin_lock_init(&lock->lock);
 }
 
-static inline void client_obd_list_lock_done(client_obd_lock_t *lock)
+static inline void client_obd_list_lock_done(struct client_obd_lock *lock)
 {}
 
 #endif /* __LINUX_OBD_H */
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 2245359..d6e5a17 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -294,7 +294,7 @@ struct client_obd {
 	 * NB by Jinshan: though field names are still _loi_, but actually
 	 * osc_object{}s are in the list.
 	 */
-	client_obd_lock_t	cl_loi_list_lock;
+	struct client_obd_lock	       cl_loi_list_lock;
 	struct list_head	       cl_loi_ready_list;
 	struct list_head	       cl_loi_hp_ready_list;
 	struct list_head	       cl_loi_write_list;
@@ -321,7 +321,7 @@ struct client_obd {
 	atomic_t		 cl_lru_shrinkers;
 	atomic_t		 cl_lru_in_list;
 	struct list_head	 cl_lru_list; /* lru page list */
-	client_obd_lock_t	 cl_lru_list_lock; /* page list protector */
+	struct client_obd_lock   cl_lru_list_lock; /* page list protector */
 
 	/* number of in flight destroy rpcs is limited to max_rpcs_in_flight */
 	atomic_t	     cl_destroy_in_flight;
-- 
2.1.0
