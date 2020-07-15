From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:44:54 -0400
Subject: [lustre-devel] [PATCH 13/37] lustre: obdcalss: ensure LCT_QUIESCENT
 take sync
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Yang Sheng <ys@whamcloud.com>

Add locking in lu_device_init ensure LCT_QUIESCENT
operating can be seen on other thread in parallel
mounting. Also add extra checking before unset the
flag to make sure we don't do it after device has
been started.

(osd_handler.c:7730:osd_device_init0()) ASSERTION( info ) failed:
(osd_handler.c:7730:osd_device_init0()) LBUG
Pid: 28098, comm: mount.lustre 3.10.0-1062.9.1.el7_lustre.x86_64
Call Trace:
 libcfs_call_trace+0x8c/0xc0 [libcfs]
 lbug_with_loc+0x4c/0xa0 [libcfs]
 osd_device_alloc+0x778/0x8f0 [osd_ldiskfs]
 obd_setup+0x129/0x2f0 [obdclass]
 class_setup+0x48f/0x7f0 [obdclass]
 class_process_config+0x190f/0x2830 [obdclass]
 do_lcfg+0x258/0x500 [obdclass]
 lustre_start_simple+0x88/0x210 [obdclass]
 server_fill_super+0xf55/0x1890 [obdclass]
 lustre_fill_super+0x498/0x990 [obdclass]
 mount_nodev+0x4f/0xb0
 lustre_mount+0x18/0x20 [obdclass]
 mount_fs+0x3e/0x1b0
 vfs_kern_mount+0x67/0x110
 do_mount+0x1ef/0xce0
 SyS_mount+0x83/0xd0
 system_call_fastpath+0x25/0x2a
 0xffffffffffffffff
 Kernel panic - not syncing: LBUG

WC-bug-id: https://jira.whamcloud.com/browse/LU-11814
Lustre-commit: 979f5e1db041d ("LU-11814 obdcalss: ensure LCT_QUIESCENT take sync")
Signed-off-by: Yang Sheng <ys@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38416
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h  |  8 +++---
 fs/lustre/obdclass/lu_object.c | 58 ++++++++++++++++++++++++------------------
 2 files changed, 38 insertions(+), 28 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index 1a6b6e1..6c47f43 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1151,7 +1151,8 @@ struct lu_context_key {
 void lu_context_key_degister(struct lu_context_key *key);
 void *lu_context_key_get(const struct lu_context *ctx,
 			 const struct lu_context_key *key);
-void lu_context_key_quiesce(struct lu_context_key *key);
+void lu_context_key_quiesce(struct lu_device_type *t,
+			    struct lu_context_key *key);
 void lu_context_key_revive(struct lu_context_key *key);
 
 /*
@@ -1199,7 +1200,7 @@ void *lu_context_key_get(const struct lu_context *ctx,
 #define LU_TYPE_STOP(mod, ...)						\
 	static void mod##_type_stop(struct lu_device_type *t)		\
 	{								\
-		lu_context_key_quiesce_many(__VA_ARGS__, NULL);		\
+		lu_context_key_quiesce_many(t, __VA_ARGS__, NULL);	\
 	}								\
 	struct __##mod##_dummy_type_stop {; }
 
@@ -1223,7 +1224,8 @@ void *lu_context_key_get(const struct lu_context *ctx,
 int lu_context_key_register_many(struct lu_context_key *k, ...);
 void lu_context_key_degister_many(struct lu_context_key *k, ...);
 void lu_context_key_revive_many(struct lu_context_key *k, ...);
-void lu_context_key_quiesce_many(struct lu_context_key *k, ...);
+void lu_context_key_quiesce_many(struct lu_device_type *t,
+				 struct lu_context_key *k, ...);
 
 /*
  * update/clear ctx/ses tags.
diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index 5cd8231..42bb7a6 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -1185,14 +1185,25 @@ void lu_device_put(struct lu_device *d)
 }
 EXPORT_SYMBOL(lu_device_put);
 
+enum { /* Maximal number of tld slots. */
+	LU_CONTEXT_KEY_NR = 40
+};
+static struct lu_context_key *lu_keys[LU_CONTEXT_KEY_NR] = { NULL, };
+static DECLARE_RWSEM(lu_key_initing);
+
 /**
  * Initialize device @d of type @t.
  */
 int lu_device_init(struct lu_device *d, struct lu_device_type *t)
 {
-	if (atomic_inc_return(&t->ldt_device_nr) == 1 &&
-	    t->ldt_ops->ldto_start)
-		t->ldt_ops->ldto_start(t);
+	if (atomic_add_unless(&t->ldt_device_nr, 1, 0) == 0) {
+		down_write(&lu_key_initing);
+		if (t->ldt_ops->ldto_start &&
+		    atomic_read(&t->ldt_device_nr) == 0)
+			t->ldt_ops->ldto_start(t);
+		atomic_inc(&t->ldt_device_nr);
+		up_write(&lu_key_initing);
+	}
 
 	memset(d, 0, sizeof(*d));
 	atomic_set(&d->ld_ref, 0);
@@ -1358,17 +1369,6 @@ void lu_stack_fini(const struct lu_env *env, struct lu_device *top)
 	}
 }
 
-enum {
-	/**
-	 * Maximal number of tld slots.
-	 */
-	LU_CONTEXT_KEY_NR = 40
-};
-
-static struct lu_context_key *lu_keys[LU_CONTEXT_KEY_NR] = { NULL, };
-
-static DECLARE_RWSEM(lu_key_initing);
-
 /**
  * Global counter incremented whenever key is registered, unregistered,
  * revived or quiesced. This is used to void unnecessary calls to
@@ -1442,7 +1442,7 @@ void lu_context_key_degister(struct lu_context_key *key)
 	LASSERT(atomic_read(&key->lct_used) >= 1);
 	LINVRNT(0 <= key->lct_index && key->lct_index < ARRAY_SIZE(lu_keys));
 
-	lu_context_key_quiesce(key);
+	lu_context_key_quiesce(NULL, key);
 
 	key_fini(&lu_shrink_env.le_ctx, key->lct_index);
 
@@ -1527,13 +1527,14 @@ void lu_context_key_revive_many(struct lu_context_key *k, ...)
 /**
  * Quiescent a number of keys.
  */
-void lu_context_key_quiesce_many(struct lu_context_key *k, ...)
+void lu_context_key_quiesce_many(struct lu_device_type *t,
+				 struct lu_context_key *k, ...)
 {
 	va_list args;
 
 	va_start(args, k);
 	do {
-		lu_context_key_quiesce(k);
+		lu_context_key_quiesce(t, k);
 		k = va_arg(args, struct lu_context_key*);
 	} while (k);
 	va_end(args);
@@ -1564,18 +1565,22 @@ void *lu_context_key_get(const struct lu_context *ctx,
  * values in "shared" contexts (like service threads), when a module owning
  * the key is about to be unloaded.
  */
-void lu_context_key_quiesce(struct lu_context_key *key)
+void lu_context_key_quiesce(struct lu_device_type *t,
+			    struct lu_context_key *key)
 {
 	struct lu_context *ctx;
 
+	if (key->lct_tags & LCT_QUIESCENT)
+		return;
+	/*
+	 * The write-lock on lu_key_initing will ensure that any
+	 * keys_fill() which didn't see LCT_QUIESCENT will have
+	 * finished before we call key_fini().
+	 */
+	down_write(&lu_key_initing);
 	if (!(key->lct_tags & LCT_QUIESCENT)) {
-		/*
-		 * The write-lock on lu_key_initing will ensure that any
-		 * keys_fill() which didn't see LCT_QUIESCENT will have
-		 * finished before we call key_fini().
-		 */
-		down_write(&lu_key_initing);
-		key->lct_tags |= LCT_QUIESCENT;
+		if (!t || atomic_read(&t->ldt_device_nr) == 0)
+			key->lct_tags |= LCT_QUIESCENT;
 		up_write(&lu_key_initing);
 
 		spin_lock(&lu_context_remembered_guard);
@@ -1584,7 +1589,10 @@ void lu_context_key_quiesce(struct lu_context_key *key)
 			key_fini(ctx, key->lct_index);
 		}
 		spin_unlock(&lu_context_remembered_guard);
+
+		return;
 	}
+	up_write(&lu_key_initing);
 }
 
 void lu_context_key_revive(struct lu_context_key *key)
-- 
1.8.3.1
