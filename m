From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Feb 2019 11:09:06 +1100
Subject: [lustre-devel] [PATCH 27/37] lustre: discard lu_ref
In-Reply-To: <155053473693.24125.6976971762921761309.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
Message-ID: <155053494627.24125.13508435808475179343.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

struct lu_ref is always an empty structure, and the functions
which manipulate it do nothing.
So this is not being tested and so cannot be trusted.
So remove all these calls and field declarations.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |    6 -
 drivers/staging/lustre/lustre/include/lu_object.h  |   45 -----
 drivers/staging/lustre/lustre/include/lu_ref.h     |  178 --------------------
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   20 --
 drivers/staging/lustre/lustre/include/obd.h        |    7 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   36 +---
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   12 -
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    4 
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |    2 
 drivers/staging/lustre/lustre/llite/rw.c           |    6 -
 drivers/staging/lustre/lustre/llite/rw26.c         |    6 -
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |   20 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |    5 -
 drivers/staging/lustre/lustre/lov/lov_object.c     |    2 
 drivers/staging/lustre/lustre/lov/lovsub_dev.c     |    1 
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |    2 
 drivers/staging/lustre/lustre/obdclass/Makefile    |    2 
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |    8 -
 drivers/staging/lustre/lustre/obdclass/cl_object.c |    2 
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |    5 -
 drivers/staging/lustre/lustre/obdclass/genops.c    |    3 
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   34 ----
 drivers/staging/lustre/lustre/obdclass/lu_ref.c    |   45 -----
 .../staging/lustre/lustre/obdclass/obd_config.c    |    2 
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   12 -
 drivers/staging/lustre/lustre/osc/osc_lock.c       |    2 
 drivers/staging/lustre/lustre/osc/osc_page.c       |    2 
 drivers/staging/lustre/lustre/osc/osc_request.c    |    2 
 28 files changed, 19 insertions(+), 452 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/include/lu_ref.h
 delete mode 100644 drivers/staging/lustre/lustre/obdclass/lu_ref.c

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 05be85306663..1484821995e9 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -742,12 +742,6 @@ struct cl_page {
 	 * by sub-io. Protected by a VM lock.
 	 */
 	struct cl_io			*cp_owner;
-	/** List of references to this page, for debugging. */
-	struct lu_ref			 cp_reference;
-	/** Link to an object, for debugging. */
-	struct lu_ref_link		 cp_obj_ref;
-	/** Link to a queue, for debugging. */
-	struct lu_ref_link		 cp_queue_ref;
 	/** Assigned if doing a sync_io */
 	struct cl_sync_io		*cp_sync_io;
 };
diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 68aa0d05b03a..cef02e66ea8e 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -38,7 +38,6 @@
 #include <linux/percpu_counter.h>
 #include <linux/libcfs/libcfs.h>
 #include <uapi/linux/lustre/lustre_idl.h>
-#include <lu_ref.h>
 
 struct seq_file;
 struct lustre_cfg;
@@ -277,10 +276,6 @@ struct lu_device {
 
 	/** \todo XXX: temporary back pointer into obd. */
 	struct obd_device			*ld_obd;
-	/**
-	 * A list of references to this object, for debugging.
-	 */
-	struct lu_ref				ld_reference;
 	/**
 	 * Link the device to the site.
 	 **/
@@ -464,10 +459,6 @@ struct lu_object {
 	 * Linkage into list of all layers.
 	 */
 	struct list_head			 lo_linkage;
-	/**
-	 * Link to the device, for debugging.
-	 */
-	struct lu_ref_link			 lo_dev_ref;
 };
 
 enum lu_object_header_flags {
@@ -536,10 +527,6 @@ struct lu_object_header {
 	 * during object destruction). No locking is necessary.
 	 */
 	struct list_head	loh_layers;
-	/**
-	 * A list of references to this object, for debugging.
-	 */
-	struct lu_ref		loh_reference;
 };
 
 struct fld;
@@ -818,34 +805,6 @@ static inline u32 lu_object_attr(const struct lu_object *o)
 	return o->lo_header->loh_attr;
 }
 
-static inline void lu_object_ref_add(struct lu_object *o,
-				     const char *scope,
-				     const void *source)
-{
-	lu_ref_add(&o->lo_header->loh_reference, scope, source);
-}
-
-static inline void lu_object_ref_add_at(struct lu_object *o,
-					struct lu_ref_link *link,
-					const char *scope,
-					const void *source)
-{
-	lu_ref_add_at(&o->lo_header->loh_reference, link, scope, source);
-}
-
-static inline void lu_object_ref_del(struct lu_object *o,
-				     const char *scope, const void *source)
-{
-	lu_ref_del(&o->lo_header->loh_reference, scope, source);
-}
-
-static inline void lu_object_ref_del_at(struct lu_object *o,
-					struct lu_ref_link *link,
-					const char *scope, const void *source)
-{
-	lu_ref_del_at(&o->lo_header->loh_reference, link, scope, source);
-}
-
 /** input params, should be filled out by mdt */
 struct lu_rdpg {
 	/** hash */
@@ -1084,10 +1043,6 @@ struct lu_context_key {
 	 * Internal implementation detail: module for this key.
 	 */
 	struct module	*lct_owner;
-	/**
-	 * References to this key. For debugging.
-	 */
-	struct lu_ref	lct_reference;
 };
 
 #define LU_KEY_INIT(mod, type)						\
diff --git a/drivers/staging/lustre/lustre/include/lu_ref.h b/drivers/staging/lustre/lustre/include/lu_ref.h
deleted file mode 100644
index ad0c24d29ffa..000000000000
--- a/drivers/staging/lustre/lustre/include/lu_ref.h
+++ /dev/null
@@ -1,178 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2012, Intel Corporation.
- *
- *   Author: Nikita Danilov <nikita.danilov@sun.com>
- *
- *   This file is part of Lustre, http://www.lustre.org.
- *
- *   Lustre is free software; you can redistribute it and/or
- *   modify it under the terms of version 2 of the GNU General Public
- *   License as published by the Free Software Foundation.
- *
- *   Lustre is distributed in the hope that it will be useful,
- *   but WITHOUT ANY WARRANTY; without even the implied warranty of
- *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- *   GNU General Public License for more details.
- *
- */
-
-#ifndef __LUSTRE_LU_REF_H
-#define __LUSTRE_LU_REF_H
-
-#include <linux/list.h>
-
-/** \defgroup lu_ref lu_ref
- *
- * An interface to track references between objects. Mostly for debugging.
- *
- * Suppose there is a reference counted data-structure struct foo. To track
- * who acquired references to instance of struct foo, add lu_ref field to it:
- *
- * \code
- *	 struct foo {
- *		 atomic_t      foo_refcount;
- *		 struct lu_ref foo_reference;
- *		 ...
- *	 };
- * \endcode
- *
- * foo::foo_reference has to be initialized by calling
- * lu_ref_init(). Typically there will be functions or macros to increment and
- * decrement foo::foo_refcount, let's say they are foo_get(struct foo *foo)
- * and foo_put(struct foo *foo), respectively.
- *
- * Whenever foo_get() is called to acquire a reference on a foo, lu_ref_add()
- * has to be called to insert into foo::foo_reference a record, describing
- * acquired reference. Dually, lu_ref_del() removes matching record. Typical
- * usages are:
- *
- * \code
- *	struct bar *bar;
- *
- *	// bar owns a reference to foo.
- *	bar->bar_foo = foo_get(foo);
- *	lu_ref_add(&foo->foo_reference, "bar", bar);
- *
- *	...
- *
- *	// reference from bar to foo is released.
- *	lu_ref_del(&foo->foo_reference, "bar", bar);
- *	foo_put(bar->bar_foo);
- *
- *
- *	// current thread acquired a temporary reference to foo.
- *	foo_get(foo);
- *	lu_ref_add(&foo->reference, __func__, current);
- *
- *	...
- *
- *	// temporary reference is released.
- *	lu_ref_del(&foo->reference, __func__, current);
- *	foo_put(foo);
- * \endcode
- *
- * \e Et \e cetera. Often it makes sense to include lu_ref_add() and
- * lu_ref_del() calls into foo_get() and foo_put(). When an instance of struct
- * foo is destroyed, lu_ref_fini() has to be called that checks that no
- * pending references remain. lu_ref_print() can be used to dump a list of
- * pending references, while hunting down a leak.
- *
- * For objects to which a large number of references can be acquired,
- * lu_ref_del() can become cpu consuming, as it has to scan the list of
- * references. To work around this, remember result of lu_ref_add() (usually
- * in the same place where pointer to struct foo is stored), and use
- * lu_ref_del_at():
- *
- * \code
- *	// There is a large number of bar's for a single foo.
- *	bar->bar_foo     = foo_get(foo);
- *	bar->bar_foo_ref = lu_ref_add(&foo->foo_reference, "bar", bar);
- *
- *	...
- *
- *	// reference from bar to foo is released.
- *	lu_ref_del_at(&foo->foo_reference, bar->bar_foo_ref, "bar", bar);
- *	foo_put(bar->bar_foo);
- * \endcode
- *
- * lu_ref interface degrades gracefully in case of memory shortages.
- *
- * @{
- */
-
-/*
- * dummy data structures/functions to pass compile for now.
- * We need to reimplement them with kref.
- */
-struct lu_ref {};
-struct lu_ref_link {};
-
-static inline void lu_ref_init(struct lu_ref *ref)
-{
-}
-
-static inline void lu_ref_fini(struct lu_ref *ref)
-{
-}
-
-static inline struct lu_ref_link *lu_ref_add(struct lu_ref *ref,
-					     const char *scope,
-					     const void *source)
-{
-	return NULL;
-}
-
-static inline struct lu_ref_link *lu_ref_add_atomic(struct lu_ref *ref,
-						    const char *scope,
-						    const void *source)
-{
-	return NULL;
-}
-
-static inline void lu_ref_add_at(struct lu_ref *ref,
-				 struct lu_ref_link *link,
-				 const char *scope,
-				 const void *source)
-{
-}
-
-static inline void lu_ref_del(struct lu_ref *ref, const char *scope,
-			      const void *source)
-{
-}
-
-static inline void lu_ref_set_at(struct lu_ref *ref, struct lu_ref_link *link,
-				 const char *scope, const void *source0,
-				 const void *source1)
-{
-}
-
-static inline void lu_ref_del_at(struct lu_ref *ref, struct lu_ref_link *link,
-				 const char *scope, const void *source)
-{
-}
-
-static inline int lu_ref_global_init(void)
-{
-	return 0;
-}
-
-static inline void lu_ref_global_fini(void)
-{
-}
-
-static inline void lu_ref_print(const struct lu_ref *ref)
-{
-}
-
-static inline void lu_ref_print_all(void)
-{
-}
-
-/** @} lu */
-
-#endif /* __LUSTRE_LU_REF_H */
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index c561d61d1a49..6c0371ef056c 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -49,7 +49,6 @@
 #include <lustre_net.h>
 #include <lustre_import.h>
 #include <lustre_handles.h>
-#include <lu_ref.h>
 
 #include "lustre_dlm_flags.h"
 
@@ -785,8 +784,6 @@ struct ldlm_lock {
 	struct list_head		l_sl_mode;
 	struct list_head		l_sl_policy;
 
-	/** Reference tracking structure to debug leaked locks. */
-	struct lu_ref			l_reference;
 #if LUSTRE_TRACKS_LOCK_EXP_REFS
 	/* Debugging stuff for bug 20498, for tracking export references. */
 	/** number of export references taken */
@@ -859,9 +856,6 @@ struct ldlm_resource {
 	 * Associated inode, used only on client side.
 	 */
 	struct inode			*lr_lvb_inode;
-
-	/** List of references to this resource. For debugging. */
-	struct lu_ref			lr_reference;
 };
 
 static inline bool ldlm_has_layout(struct ldlm_lock *lock)
@@ -1066,17 +1060,12 @@ static inline struct ldlm_lock *ldlm_handle2lock(const struct lustre_handle *h)
 	return __ldlm_handle2lock(h, 0);
 }
 
-#define LDLM_LOCK_REF_DEL(lock) \
-	lu_ref_del(&lock->l_reference, "handle", current)
-
 static inline struct ldlm_lock *
 ldlm_handle2lock_long(const struct lustre_handle *h, u64 flags)
 {
 	struct ldlm_lock *lock;
 
 	lock = __ldlm_handle2lock(h, flags);
-	if (lock)
-		LDLM_LOCK_REF_DEL(lock);
 	return lock;
 }
 
@@ -1107,7 +1096,6 @@ void ldlm_dump_export_locks(struct obd_export *exp);
  */
 #define LDLM_LOCK_PUT(lock)		\
 do {					\
-	LDLM_LOCK_REF_DEL(lock);	\
 	/*LDLM_DEBUG((lock), "put");*/	\
 	ldlm_lock_put(lock);		\
 } while (0)
@@ -1198,14 +1186,6 @@ void ldlm_resource_dump(int level, struct ldlm_resource *);
 int ldlm_lock_change_resource(struct ldlm_namespace *, struct ldlm_lock *,
 			      const struct ldlm_res_id *);
 
-#define LDLM_RESOURCE_ADDREF(res) do {					\
-	lu_ref_add_atomic(&(res)->lr_reference, __func__, current);	\
-} while (0)
-
-#define LDLM_RESOURCE_DELREF(res) do {				\
-	lu_ref_del(&(res)->lr_reference, __func__, current);	\
-} while (0)
-
 /* ldlm_request.c */
 /** \defgroup ldlm_local_ast Default AST handlers for local locks
  * These AST handlers are typically used for server-side local locks and are
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index e09268f08e5c..f7f4db0481b2 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -40,7 +40,6 @@
 
 #include <uapi/linux/lustre/lustre_idl.h>
 #include <lustre_lib.h>
-#include <lu_ref.h>
 #include <lustre_export.h>
 #include <lustre_fid.h>
 #include <lustre_fld.h>
@@ -615,12 +614,6 @@ struct obd_device {
 
 	int			 obd_conn_inprogress;
 
-	/**
-	 * A list of outstanding class_incref()'s against this obd. For
-	 * debugging.
-	 */
-	struct lu_ref		 obd_reference;
-
 	struct kset		 obd_kset; /* sysfs object collection */
 	struct kobj_type	 obd_ktype;
 	struct completion	 obd_kobj_unregister;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 6789d3bf0485..60a6ec2f7136 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -175,7 +175,6 @@ void ldlm_lock_put(struct ldlm_lock *lock)
 
 		lprocfs_counter_decr(ldlm_res_to_ns(res)->ns_stats,
 				     LDLM_NSS_LOCKS);
-		lu_ref_del(&res->lr_reference, "lock", lock);
 		ldlm_resource_putref(res);
 		lock->l_resource = NULL;
 		if (lock->l_export) {
@@ -185,7 +184,6 @@ void ldlm_lock_put(struct ldlm_lock *lock)
 
 		kfree(lock->l_lvb_data);
 
-		lu_ref_fini(&lock->l_reference);
 		OBD_FREE_RCU(lock, sizeof(*lock), &lock->l_handle);
 	}
 }
@@ -334,10 +332,8 @@ static void ldlm_lock_destroy(struct ldlm_lock *lock)
 	unlock_res_and_lock(lock);
 
 	/* drop reference from hashtable only for first destroy */
-	if (first) {
-		lu_ref_del(&lock->l_reference, "hash", lock);
+	if (first)
 		LDLM_LOCK_RELEASE(lock);
-	}
 }
 
 /**
@@ -349,10 +345,8 @@ void ldlm_lock_destroy_nolock(struct ldlm_lock *lock)
 
 	first = ldlm_lock_destroy_internal(lock);
 	/* drop reference from hashtable only for first destroy */
-	if (first) {
-		lu_ref_del(&lock->l_reference, "hash", lock);
+	if (first)
 		LDLM_LOCK_RELEASE(lock);
-	}
 }
 
 /* this is called by portals_handle2object with the handle lock taken */
@@ -392,7 +386,6 @@ static struct ldlm_lock *ldlm_lock_new(struct ldlm_resource *resource)
 
 	spin_lock_init(&lock->l_lock);
 	lock->l_resource = resource;
-	lu_ref_add(&resource->lr_reference, "lock", lock);
 
 	atomic_set(&lock->l_refc, 2);
 	INIT_LIST_HEAD(&lock->l_res_link);
@@ -412,8 +405,6 @@ static struct ldlm_lock *ldlm_lock_new(struct ldlm_resource *resource)
 	INIT_LIST_HEAD(&lock->l_handle.h_link);
 	class_handle_hash(&lock->l_handle, &lock_handle_ops);
 
-	lu_ref_init(&lock->l_reference);
-	lu_ref_add(&lock->l_reference, "hash", lock);
 	lock->l_callback_timeout = 0;
 
 #if LUSTRE_TRACKS_LOCK_EXP_REFS
@@ -457,7 +448,6 @@ int ldlm_lock_change_resource(struct ldlm_namespace *ns, struct ldlm_lock *lock,
 	if (IS_ERR(newres))
 		return PTR_ERR(newres);
 
-	lu_ref_add(&newres->lr_reference, "lock", lock);
 	/*
 	 * To flip the lock from the old to the new resource, lock, oldres and
 	 * newres have to be locked. Resource spin-locks are nested within
@@ -480,7 +470,6 @@ int ldlm_lock_change_resource(struct ldlm_namespace *ns, struct ldlm_lock *lock,
 	unlock_res_and_lock(lock);
 
 	/* ...and the flowers are still standing! */
-	lu_ref_del(&oldres->lr_reference, "lock", lock);
 	ldlm_resource_putref(oldres);
 
 	return 0;
@@ -528,16 +517,13 @@ struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *handle,
 	/* It's unlikely but possible that someone marked the lock as
 	 * destroyed after we did handle2object on it
 	 */
-	if (flags == 0 && !ldlm_is_destroyed(lock)) {
-		lu_ref_add(&lock->l_reference, "handle", current);
+	if (flags == 0 && !ldlm_is_destroyed(lock))
 		return lock;
-	}
 
 	lock_res_and_lock(lock);
 
 	LASSERT(lock->l_resource);
 
-	lu_ref_add_atomic(&lock->l_reference, "handle", current);
 	if (unlikely(ldlm_is_destroyed(lock))) {
 		unlock_res_and_lock(lock);
 		CDEBUG(D_INFO, "lock already destroyed: lock %p\n", lock);
@@ -658,16 +644,13 @@ void ldlm_lock_addref_internal_nolock(struct ldlm_lock *lock,
 				      enum ldlm_mode mode)
 {
 	ldlm_lock_remove_from_lru(lock);
-	if (mode & (LCK_NL | LCK_CR | LCK_PR)) {
+	if (mode & (LCK_NL | LCK_CR | LCK_PR))
 		lock->l_readers++;
-		lu_ref_add_atomic(&lock->l_reference, "reader", lock);
-	}
-	if (mode & (LCK_EX | LCK_CW | LCK_PW | LCK_GROUP | LCK_COS)) {
+
+	if (mode & (LCK_EX | LCK_CW | LCK_PW | LCK_GROUP | LCK_COS))
 		lock->l_writers++;
-		lu_ref_add_atomic(&lock->l_reference, "writer", lock);
-	}
+
 	LDLM_LOCK_GET(lock);
-	lu_ref_add_atomic(&lock->l_reference, "user", lock);
 	LDLM_DEBUG(lock, "ldlm_lock_addref(%s)", ldlm_lockname[mode]);
 }
 
@@ -725,16 +708,13 @@ void ldlm_lock_decref_internal_nolock(struct ldlm_lock *lock,
 	LDLM_DEBUG(lock, "ldlm_lock_decref(%s)", ldlm_lockname[mode]);
 	if (mode & (LCK_NL | LCK_CR | LCK_PR)) {
 		LASSERT(lock->l_readers > 0);
-		lu_ref_del(&lock->l_reference, "reader", lock);
 		lock->l_readers--;
 	}
 	if (mode & (LCK_EX | LCK_CW | LCK_PW | LCK_GROUP | LCK_COS)) {
 		LASSERT(lock->l_writers > 0);
-		lu_ref_del(&lock->l_reference, "writer", lock);
 		lock->l_writers--;
 	}
 
-	lu_ref_del(&lock->l_reference, "user", lock);
 	LDLM_LOCK_RELEASE(lock);    /* matches the LDLM_LOCK_GET() in addref */
 }
 
@@ -1285,7 +1265,6 @@ enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, u64 flags,
 		return 0;
 	}
 
-	LDLM_RESOURCE_ADDREF(res);
 	lock_res(res);
 
 	if (res->lr_type == LDLM_EXTENT)
@@ -1307,7 +1286,6 @@ enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, u64 flags,
 	}
 out:
 	unlock_res(res);
-	LDLM_RESOURCE_DELREF(res);
 	ldlm_resource_putref(res);
 
 	if (lock) {
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index b819adef2bfe..1f04a782bd89 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1423,7 +1423,6 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 
 		LDLM_LOCK_GET(lock);
 		spin_unlock(&ns->ns_lock);
-		lu_ref_add(&lock->l_reference, __func__, current);
 
 		/* Pass the lock through the policy filter and see if it
 		 * should stay in LRU.
@@ -1441,15 +1440,11 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 		 */
 		result = pf(ns, lock, unused, added, count);
 		if (result == LDLM_POLICY_KEEP_LOCK) {
-			lu_ref_del(&lock->l_reference,
-				   __func__, current);
 			LDLM_LOCK_RELEASE(lock);
 			spin_lock(&ns->ns_lock);
 			break;
 		}
 		if (result == LDLM_POLICY_SKIP_LOCK) {
-			lu_ref_del(&lock->l_reference,
-				   __func__, current);
 			LDLM_LOCK_RELEASE(lock);
 			spin_lock(&ns->ns_lock);
 			continue;
@@ -1467,8 +1462,6 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 			 * pages could be put under it.
 			 */
 			unlock_res_and_lock(lock);
-			lu_ref_del(&lock->l_reference,
-				   __func__, current);
 			LDLM_LOCK_RELEASE(lock);
 			spin_lock(&ns->ns_lock);
 			continue;
@@ -1507,7 +1500,6 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 		LASSERT(list_empty(&lock->l_bl_ast));
 		list_add(&lock->l_bl_ast, cancels);
 		unlock_res_and_lock(lock);
-		lu_ref_del(&lock->l_reference, __func__, current);
 		spin_lock(&ns->ns_lock);
 		added++;
 		unused--;
@@ -1695,7 +1687,6 @@ int ldlm_cli_cancel_unused_resource(struct ldlm_namespace *ns,
 		return 0;
 	}
 
-	LDLM_RESOURCE_ADDREF(res);
 	count = ldlm_cancel_resource_local(res, &cancels, policy, mode,
 					   0, flags | LCF_BL_AST, opaque);
 	rc = ldlm_cli_cancel_list(&cancels, count, NULL, flags);
@@ -1703,7 +1694,6 @@ int ldlm_cli_cancel_unused_resource(struct ldlm_namespace *ns,
 		CERROR("canceling unused lock " DLDLMRES ": rc = %d\n",
 		       PLDLMRES(res), rc);
 
-	LDLM_RESOURCE_DELREF(res);
 	ldlm_resource_putref(res);
 	return 0;
 }
@@ -1843,9 +1833,7 @@ int ldlm_resource_iterate(struct ldlm_namespace *ns,
 	if (IS_ERR(res))
 		return 0;
 
-	LDLM_RESOURCE_ADDREF(res);
 	rc = ldlm_resource_foreach(res, iter, data);
-	LDLM_RESOURCE_DELREF(res);
 	ldlm_resource_putref(res);
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index ae2fddd044ea..371cc1d5e539 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -1021,7 +1021,6 @@ static struct ldlm_resource *ldlm_resource_new(enum ldlm_type ldlm_type)
 
 	atomic_set(&res->lr_refcount, 1);
 	spin_lock_init(&res->lr_lock);
-	lu_ref_init(&res->lr_reference);
 
 	/* The creator of the resource must unlock the mutex after LVB
 	 * initialization.
@@ -1084,8 +1083,6 @@ ldlm_resource_get(struct ldlm_namespace *ns, struct ldlm_resource *parent,
 	if (hnode) {
 		/* Someone won the race and already added the resource. */
 		cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 1);
-		/* Clean lu_ref for failed resource. */
-		lu_ref_fini(&res->lr_reference);
 		/* We have taken lr_lvb_mutex. Drop it. */
 		mutex_unlock(&res->lr_lvb_mutex);
 		if (res->lr_itree)
@@ -1163,7 +1160,6 @@ static void __ldlm_resource_putref_final(struct cfs_hash_bd *bd,
 
 	cfs_hash_bd_del_locked(ns->ns_rs_hash,
 			       bd, &res->lr_hash);
-	lu_ref_fini(&res->lr_reference);
 	cfs_hash_bd_unlock(ns->ns_rs_hash, bd, 1);
 	if (ns->ns_lvbo && ns->ns_lvbo->lvbo_free)
 		ns->ns_lvbo->lvbo_free(res);
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index afcaa5ec13c2..94299fc2f5e3 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -179,7 +179,6 @@ int cl_file_inode_init(struct inode *inode, struct lustre_md *md)
 			 * locked by I_NEW bit.
 			 */
 			lli->lli_clob = clob;
-			lu_object_ref_add(&clob->co_lu, "inode", inode);
 		} else {
 			result = PTR_ERR(clob);
 		}
@@ -254,7 +253,6 @@ void cl_inode_fini(struct inode *inode)
 		 * when its master is evicted.
 		 */
 		cl_object_kill(env, clob);
-		lu_object_ref_del(&clob->co_lu, "inode", inode);
 		cl_object_put_last(env, clob);
 		lli->lli_clob = NULL;
 		if (emergency)
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index af983ee09e8e..185d1692d79b 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -209,7 +209,6 @@ static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 		goto out;
 	}
 
-	lu_ref_add(&page->cp_reference, "ra", current);
 	cl_page_assume(env, io, page);
 	vpg = cl2vvp_page(cl_object_page_slice(clob, page));
 	if (!vpg->vpg_defer_uptodate && !PageUptodate(vmpage)) {
@@ -225,7 +224,6 @@ static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 		rc = 1;
 	}
 
-	lu_ref_del(&page->cp_reference, "ra", current);
 	cl_page_put(env, page);
 out:
 	if (vmpage) {
@@ -936,8 +934,6 @@ int ll_writepage(struct page *vmpage, struct writeback_control *wbc)
 		page = cl_page_find(env, clob, vmpage->index,
 				    vmpage, CPT_CACHEABLE);
 		if (!IS_ERR(page)) {
-			lu_ref_add(&page->cp_reference, "writepage",
-				   current);
 			cl_page_assume(env, io, page);
 			result = cl_page_flush(env, io, page);
 			if (result != 0) {
@@ -954,8 +950,6 @@ int ll_writepage(struct page *vmpage, struct writeback_control *wbc)
 			}
 			cl_page_disown(env, io, page);
 			unlocked = true;
-			lu_ref_del(&page->cp_reference,
-				   "writepage", current);
 			cl_page_put(env, page);
 		} else {
 			result = PTR_ERR(page);
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index e4ce3b6f5772..9bcbc8b084e5 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -482,7 +482,6 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 	}
 
 	lcc->lcc_page = page;
-	lu_ref_add(&page->cp_reference, "cl_io", io);
 
 	cl_page_assume(env, io, page);
 	if (!PageUptodate(vmpage)) {
@@ -511,10 +510,8 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 			unlock_page(vmpage);
 			put_page(vmpage);
 		}
-		if (!IS_ERR_OR_NULL(page)) {
-			lu_ref_del(&page->cp_reference, "cl_io", io);
+		if (!IS_ERR_OR_NULL(page))
 			cl_page_put(env, page);
-		}
 		if (io)
 			io->ci_result = result;
 	} else {
@@ -575,7 +572,6 @@ static int ll_write_end(struct file *file, struct address_space *mapping,
 		cl_page_disown(env, io, page);
 
 		lcc->lcc_page = NULL;
-		lu_ref_del(&page->cp_reference, "cl_io", io);
 		cl_page_put(env, page);
 
 		/* page list is not contiguous now, commit it now */
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index c10ca6e7c606..34206166ada4 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -240,10 +240,9 @@ static int vvp_device_init(const struct lu_env *env, struct lu_device *d,
 	rc = next->ld_type->ldt_ops->ldto_device_init(env, next,
 						      next->ld_type->ldt_name,
 						      NULL);
-	if (rc == 0) {
+	if (rc == 0)
 		lu_device_get(next);
-		lu_ref_add(&next->ld_reference, "lu-stack", &lu_site_init);
-	}
+
 	return rc;
 }
 
@@ -420,10 +419,9 @@ static struct cl_object *vvp_pgcache_obj(const struct lu_env *env,
 		struct lu_object *lu_obj;
 
 		lu_obj = lu_object_locate(id->vpi_obj, dev->ld_type);
-		if (lu_obj) {
-			lu_object_ref_add(lu_obj, "dump", current);
+		if (lu_obj)
 			return lu2cl(lu_obj);
-		}
+
 		lu_object_put(env, lu_object_top(id->vpi_obj));
 	}
 	return NULL;
@@ -456,7 +454,6 @@ static struct page *vvp_pgcache_current(struct vvp_seq_private *priv)
 			priv->vsp_id.vpi_index = vmpage->index;
 			return vmpage;
 		}
-		lu_object_ref_del(&priv->vsp_clob->co_lu, "dump", current);
 		cl_object_put(priv->vsp_env, priv->vsp_clob);
 		priv->vsp_clob = NULL;
 		priv->vsp_id.vpi_index = 0;
@@ -527,11 +524,8 @@ static void vvp_pgcache_rewind(struct vvp_seq_private *priv)
 	if (priv->vsp_prev_pos) {
 		memset(&priv->vsp_id, 0, sizeof(priv->vsp_id));
 		priv->vsp_prev_pos = 0;
-		if (priv->vsp_clob) {
-			lu_object_ref_del(&priv->vsp_clob->co_lu, "dump",
-					  current);
+		if (priv->vsp_clob)
 			cl_object_put(priv->vsp_env, priv->vsp_clob);
-		}
 		priv->vsp_clob = NULL;
 	}
 }
@@ -607,10 +601,8 @@ static int vvp_dump_pgcache_seq_release(struct inode *inode, struct file *file)
 	struct seq_file *seq = file->private_data;
 	struct vvp_seq_private *priv = seq->private;
 
-	if (priv->vsp_clob) {
-		lu_object_ref_del(&priv->vsp_clob->co_lu, "dump", current);
+	if (priv->vsp_clob)
 		cl_object_put(priv->vsp_env, priv->vsp_clob);
-	}
 
 	cl_env_put(priv->vsp_env, &priv->vsp_refcheck);
 	return seq_release_private(inode, file);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 593b10cecf7d..62b507926c20 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -382,7 +382,6 @@ static void vvp_io_fault_fini(const struct lu_env *env,
 	CLOBINVRNT(env, io->ci_obj, vvp_object_invariant(io->ci_obj));
 
 	if (page) {
-		lu_ref_del(&page->cp_reference, "fault", io);
 		cl_page_put(env, page);
 		io->u.ci_fault.ft_page = NULL;
 	}
@@ -824,7 +823,6 @@ static int vvp_io_commit_sync(const struct lu_env *env, struct cl_io *io,
 			cl_page_disown(env, io, page);
 
 			/* held in ll_cl_init() */
-			lu_ref_del(&page->cp_reference, "cl_io", io);
 			cl_page_put(env, page);
 		}
 	}
@@ -843,7 +841,6 @@ static void write_commit_callback(const struct lu_env *env, struct cl_io *io,
 	cl_page_disown(env, io, page);
 
 	/* held in ll_cl_init() */
-	lu_ref_del(&page->cp_reference, "cl_io", cl_io_top(io));
 	cl_page_put(env, page);
 }
 
@@ -944,7 +941,6 @@ int vvp_io_write_commit(const struct lu_env *env, struct cl_io *io)
 		cl_page_disown(env, io, page);
 
 		/* held in ll_cl_init() */
-		lu_ref_del(&page->cp_reference, "cl_io", io);
 		cl_page_put(env, page);
 	}
 	cl_page_list_fini(env, queue);
@@ -1260,7 +1256,6 @@ static int vvp_io_fault_start(const struct lu_env *env,
 	else
 		fio->ft_nob = cl_page_size(obj);
 
-	lu_ref_add(&page->cp_reference, "fault", io);
 	fio->ft_page = page;
 
 out:
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 397ecc1dbb4c..cde8215a0b4c 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -149,7 +149,6 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
 		subhdr->coh_parent = hdr;
 		spin_unlock(&subhdr->coh_attr_guard);
 		subhdr->coh_nesting = hdr->coh_nesting + 1;
-		lu_object_ref_add(&subobj->co_lu, "lov-parent", lov);
 		r0->lo_sub[stripe] = cl2lovsub(subobj);
 		r0->lo_sub[stripe]->lso_super = lov;
 		r0->lo_sub[stripe]->lso_index = idx;
@@ -405,7 +404,6 @@ static void lov_subobject_kill(const struct lu_env *env, struct lov_object *lov,
 
 	cl_object_kill(env, sub);
 	/* release a reference to the sub-object and ... */
-	lu_object_ref_del(&sub->co_lu, "lov-parent", lov);
 	cl_object_put(env, sub);
 
 	/* ... wait until it is actually destroyed---sub-object clears its
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_dev.c b/drivers/staging/lustre/lustre/lov/lovsub_dev.c
index 69380fc6aeab..d9b044e5aca1 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_dev.c
@@ -65,7 +65,6 @@ static int lovsub_device_init(const struct lu_env *env, struct lu_device *d,
 	}
 
 	lu_device_get(next);
-	lu_ref_add(&next->ld_reference, "lu-stack", &lu_site_init);
 	lsd->acid_next = lu2cl_dev(next);
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index e0e7b00fd2be..e878bc76da8a 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -87,12 +87,10 @@ int mdc_resource_get_unused(struct obd_export *exp, const struct lu_fid *fid,
 				NULL, &res_id, 0, 0);
 	if (IS_ERR(res))
 		return 0;
-	LDLM_RESOURCE_ADDREF(res);
 	/* Initialize ibits lock policy. */
 	policy.l_inodebits.bits = bits;
 	count = ldlm_cancel_resource_local(res, cancels, &policy,
 					   mode, 0, 0, NULL);
-	LDLM_RESOURCE_DELREF(res);
 	ldlm_resource_putref(res);
 	return count;
 }
diff --git a/drivers/staging/lustre/lustre/obdclass/Makefile b/drivers/staging/lustre/lustre/obdclass/Makefile
index 1669c24a0b03..ee63ebd3947b 100644
--- a/drivers/staging/lustre/lustre/obdclass/Makefile
+++ b/drivers/staging/lustre/lustre/obdclass/Makefile
@@ -7,5 +7,5 @@ obj-$(CONFIG_LUSTRE_FS) += obdclass.o
 obdclass-y := llog.o llog_cat.o llog_obd.o llog_swab.o class_obd.o \
 	      genops.o obd_sysfs.o lprocfs_status.o lprocfs_counters.o \
 	      lustre_handles.o lustre_peer.o statfs_pack.o linkea.o \
-	      obdo.o obd_config.o obd_mount.o lu_object.o lu_ref.o \
+	      obdo.o obd_config.o obd_mount.o lu_object.o \
 	      cl_object.o cl_page.o cl_lock.o cl_io.o kernelcomm.o
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 3b4aca4e4a53..9755174c2db6 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -770,7 +770,6 @@ void cl_page_list_add(struct cl_page_list *plist, struct cl_page *page)
 	LASSERT(list_empty(&page->cp_batch));
 	list_add_tail(&page->cp_batch, &plist->pl_pages);
 	++plist->pl_nr;
-	lu_ref_add_at(&page->cp_reference, &page->cp_queue_ref, "queue", plist);
 	cl_page_get(page);
 }
 EXPORT_SYMBOL(cl_page_list_add);
@@ -787,7 +786,6 @@ void cl_page_list_del(const struct lu_env *env, struct cl_page_list *plist,
 
 	list_del_init(&page->cp_batch);
 	--plist->pl_nr;
-	lu_ref_del_at(&page->cp_reference, &page->cp_queue_ref, "queue", plist);
 	cl_page_put(env, page);
 }
 EXPORT_SYMBOL(cl_page_list_del);
@@ -805,8 +803,6 @@ void cl_page_list_move(struct cl_page_list *dst, struct cl_page_list *src,
 	list_move_tail(&page->cp_batch, &dst->pl_pages);
 	--src->pl_nr;
 	++dst->pl_nr;
-	lu_ref_set_at(&page->cp_reference, &page->cp_queue_ref, "queue",
-		      src, dst);
 }
 EXPORT_SYMBOL(cl_page_list_move);
 
@@ -823,8 +819,6 @@ void cl_page_list_move_head(struct cl_page_list *dst, struct cl_page_list *src,
 	list_move(&page->cp_batch, &dst->pl_pages);
 	--src->pl_nr;
 	++dst->pl_nr;
-	lu_ref_set_at(&page->cp_reference, &page->cp_queue_ref, "queue",
-		      src, dst);
 }
 EXPORT_SYMBOL(cl_page_list_move_head);
 
@@ -869,8 +863,6 @@ void cl_page_list_disown(const struct lu_env *env,
 		 * XXX __cl_page_disown() will fail if page is not locked.
 		 */
 		__cl_page_disown(env, io, page);
-		lu_ref_del_at(&page->cp_reference, &page->cp_queue_ref, "queue",
-			      plist);
 		cl_page_put(env, page);
 	}
 }
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index b09621f0f1f8..c7cf2e736ff7 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -924,8 +924,6 @@ struct cl_device *cl_type_setup(const struct lu_env *env, struct lu_site *site,
 		rc = ldt->ldt_ops->ldto_device_init(env, d, typename, next);
 		if (rc == 0) {
 			lu_device_get(d);
-			lu_ref_add(&d->ld_reference,
-				   "lu-stack", &lu_site_init);
 		} else {
 			ldt->ldt_ops->ldto_device_free(env, d);
 			CERROR("can't init device '%s', %d\n", typename, rc);
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 7dcd3aff229f..a44533a063df 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -106,9 +106,7 @@ static void cl_page_free(const struct lu_env *env, struct cl_page *page)
 		if (unlikely(slice->cpl_ops->cpo_fini))
 			slice->cpl_ops->cpo_fini(env, slice);
 	}
-	lu_object_ref_del_at(&obj->co_lu, &page->cp_obj_ref, "cl_page", page);
 	cl_object_put(env, obj);
-	lu_ref_fini(&page->cp_reference);
 	kfree(page);
 }
 
@@ -138,14 +136,11 @@ struct cl_page *cl_page_alloc(const struct lu_env *env,
 		refcount_set(&page->cp_ref, 1);
 		page->cp_obj = o;
 		cl_object_get(o);
-		lu_object_ref_add_at(&o->co_lu, &page->cp_obj_ref, "cl_page",
-				     page);
 		page->cp_vmpage = vmpage;
 		cl_page_state_set_trust(page, CPS_CACHED);
 		page->cp_type = type;
 		INIT_LIST_HEAD(&page->cp_layers);
 		INIT_LIST_HEAD(&page->cp_batch);
-		lu_ref_init(&page->cp_reference);
 		cl_object_for_each(o2, o) {
 			if (o2->co_ops->coo_page_init) {
 				result = o2->co_ops->coo_page_init(env, o2, page,
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index c91704d87042..ce92c8c1dc75 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -80,7 +80,6 @@ static void obd_device_free(struct obd_device *obd)
 		       obd, obd->obd_namespace, obd->obd_force);
 		LBUG();
 	}
-	lu_ref_fini(&obd->obd_reference);
 	kmem_cache_free(obd_device_cachep, obd);
 }
 
@@ -314,8 +313,6 @@ struct obd_device *class_newdev(const char *type_name, const char *name,
 	llog_group_init(&newdev->obd_olg);
 	/* Detach drops this */
 	atomic_set(&newdev->obd_refcount, 1);
-	lu_ref_init(&newdev->obd_reference);
-	lu_ref_add(&newdev->obd_reference, "newdev", newdev);
 
 	newdev->obd_conn_inprogress = 0;
 
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 3e23babb329a..6a1c3bc3e9e8 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -52,7 +52,6 @@
 #include <lustre_fid.h>
 #include <lu_object.h>
 #include <cl_object.h>
-#include <lu_ref.h>
 #include <linux/list.h>
 
 struct lu_site_bkt_data {
@@ -1018,7 +1017,6 @@ int lu_site_init(struct lu_site *s, struct lu_device *top)
 	s->ls_top_dev = top;
 	top->ld_site = s;
 	lu_device_get(top);
-	lu_ref_add(&top->ld_reference, "site-top", s);
 
 	INIT_LIST_HEAD(&s->ls_ld_linkage);
 	spin_lock_init(&s->ls_ld_lock);
@@ -1047,7 +1045,6 @@ void lu_site_fini(struct lu_site *s)
 
 	if (s->ls_top_dev) {
 		s->ls_top_dev->ld_site = NULL;
-		lu_ref_del(&s->ls_top_dev->ld_reference, "site-top", s);
 		lu_device_put(s->ls_top_dev);
 		s->ls_top_dev = NULL;
 	}
@@ -1104,7 +1101,6 @@ int lu_device_init(struct lu_device *d, struct lu_device_type *t)
 	memset(d, 0, sizeof(*d));
 	atomic_set(&d->ld_ref, 0);
 	d->ld_type = t;
-	lu_ref_init(&d->ld_reference);
 	INIT_LIST_HEAD(&d->ld_linkage);
 	return 0;
 }
@@ -1122,7 +1118,6 @@ void lu_device_fini(struct lu_device *d)
 		d->ld_obd = NULL;
 	}
 
-	lu_ref_fini(&d->ld_reference);
 	LASSERTF(atomic_read(&d->ld_ref) == 0,
 		 "Refcount is %u\n", atomic_read(&d->ld_ref));
 	LASSERT(atomic_read(&t->ldt_device_nr) > 0);
@@ -1144,7 +1139,6 @@ int lu_object_init(struct lu_object *o, struct lu_object_header *h,
 	o->lo_header = h;
 	o->lo_dev = d;
 	lu_device_get(d);
-	lu_ref_add_at(&d->ld_reference, &o->lo_dev_ref, "lu_object", o);
 	INIT_LIST_HEAD(&o->lo_linkage);
 
 	return 0;
@@ -1161,8 +1155,6 @@ void lu_object_fini(struct lu_object *o)
 	LASSERT(list_empty(&o->lo_linkage));
 
 	if (dev) {
-		lu_ref_del_at(&dev->ld_reference, &o->lo_dev_ref,
-			      "lu_object", o);
 		lu_device_put(dev);
 		o->lo_dev = NULL;
 	}
@@ -1203,7 +1195,6 @@ int lu_object_header_init(struct lu_object_header *h)
 	INIT_HLIST_NODE(&h->loh_hash);
 	INIT_LIST_HEAD(&h->loh_lru);
 	INIT_LIST_HEAD(&h->loh_layers);
-	lu_ref_init(&h->loh_reference);
 	return 0;
 }
 EXPORT_SYMBOL(lu_object_header_init);
@@ -1216,7 +1207,6 @@ void lu_object_header_fini(struct lu_object_header *h)
 	LASSERT(list_empty(&h->loh_layers));
 	LASSERT(list_empty(&h->loh_lru));
 	LASSERT(hlist_unhashed(&h->loh_hash));
-	lu_ref_fini(&h->loh_reference);
 }
 EXPORT_SYMBOL(lu_object_header_fini);
 
@@ -1253,7 +1243,6 @@ void lu_stack_fini(const struct lu_env *env, struct lu_device *top)
 	lu_site_purge(env, site, ~0);
 	for (scan = top; scan; scan = next) {
 		next = scan->ld_type->ldt_ops->ldto_device_fini(env, scan);
-		lu_ref_del(&scan->ld_reference, "lu-stack", &lu_site_init);
 		lu_device_put(scan);
 	}
 
@@ -1306,7 +1295,6 @@ int lu_context_key_register(struct lu_context_key *key)
 
 	result = -ENFILE;
 	atomic_set(&key->lct_used, 1);
-	lu_ref_init(&key->lct_reference);
 	for (i = 0; i < ARRAY_SIZE(lu_keys); ++i) {
 		if (lu_keys[i])
 			continue;
@@ -1318,10 +1306,9 @@ int lu_context_key_register(struct lu_context_key *key)
 		atomic_inc(&key_set_version);
 		break;
 	}
-	if (result) {
-		lu_ref_fini(&key->lct_reference);
+	if (result)
 		atomic_set(&key->lct_used, 0);
-	}
+
 	return result;
 }
 EXPORT_SYMBOL(lu_context_key_register);
@@ -1335,7 +1322,6 @@ static void key_fini(struct lu_context *ctx, int index)
 		LASSERT(atomic_read(&key->lct_used) > 1);
 
 		key->lct_fini(ctx, key, ctx->lc_value[index]);
-		lu_ref_del(&key->lct_reference, "ctx", ctx);
 		if (atomic_dec_and_test(&key->lct_used))
 			wake_up_var(&key->lct_used);
 
@@ -1364,8 +1350,7 @@ void lu_context_key_degister(struct lu_context_key *key)
 	atomic_dec(&key->lct_used);
 	wait_var_event(&key->lct_used, atomic_read(&key->lct_used) == 0);
 
-	if (!WARN_ON(lu_keys[key->lct_index] == NULL))
-		lu_ref_fini(&key->lct_reference);
+	WARN_ON(lu_keys[key->lct_index] == NULL);
 	smp_store_release(&lu_keys[key->lct_index], NULL);
 }
 EXPORT_SYMBOL(lu_context_key_degister);
@@ -1562,7 +1547,6 @@ static int keys_fill(struct lu_context *ctx)
 				break;
 			}
 
-			lu_ref_add_atomic(&key->lct_reference, "ctx", ctx);
 			atomic_inc(&key->lct_used);
 			/*
 			 * This is the only place in the code, where an
@@ -1873,16 +1857,10 @@ int lu_global_init(void)
 
 	CDEBUG(D_INFO, "Lustre LU module (%p).\n", &lu_keys);
 
-	result = lu_ref_global_init();
-	if (result != 0)
-		return result;
-
 	LU_CONTEXT_KEY_INIT(&lu_global_key);
 	result = lu_context_key_register(&lu_global_key);
-	if (result != 0) {
-		lu_ref_global_fini();
+	if (result != 0)
 		return result;
-	}
 
 	/*
 	 * At this level, we don't know what tags are needed, so allocate them
@@ -1894,7 +1872,6 @@ int lu_global_init(void)
 	up_write(&lu_sites_guard);
 	if (result != 0) {
 		lu_context_key_degister(&lu_global_key);
-		lu_ref_global_fini();
 		return result;
 	}
 
@@ -1912,7 +1889,6 @@ int lu_global_init(void)
 		lu_env_fini(&lu_shrink_env);
 		up_write(&lu_sites_guard);
 
-		lu_ref_global_fini();
 		return result;
 	}
 
@@ -1934,8 +1910,6 @@ void lu_global_fini(void)
 	down_write(&lu_sites_guard);
 	lu_env_fini(&lu_shrink_env);
 	up_write(&lu_sites_guard);
-
-	lu_ref_global_fini();
 }
 
 static u32 ls_stats_read(struct lprocfs_stats *stats, int idx)
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_ref.c b/drivers/staging/lustre/lustre/obdclass/lu_ref.c
deleted file mode 100644
index f67cb89ea0ba..000000000000
--- a/drivers/staging/lustre/lustre/obdclass/lu_ref.c
+++ /dev/null
@@ -1,45 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2012, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * lustre/obdclass/lu_ref.c
- *
- * Lustre reference.
- *
- *   Author: Nikita Danilov <nikita.danilov@sun.com>
- */
-
-#define DEBUG_SUBSYSTEM S_CLASS
-
-#include <obd.h>
-#include <obd_class.h>
-#include <obd_support.h>
-#include <lu_ref.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 0cdadea4e63c..45e8f03dec80 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -520,7 +520,6 @@ static int class_cleanup(struct obd_device *obd, struct lustre_cfg *lcfg)
 struct obd_device *class_incref(struct obd_device *obd,
 				const char *scope, const void *source)
 {
-	lu_ref_add_atomic(&obd->obd_reference, scope, source);
 	atomic_inc(&obd->obd_refcount);
 	CDEBUG(D_INFO, "incref %s (%p) now %d\n", obd->obd_name, obd,
 	       atomic_read(&obd->obd_refcount));
@@ -538,7 +537,6 @@ void class_decref(struct obd_device *obd, const char *scope, const void *source)
 
 	LASSERT(obd->obd_num_exports >= 0);
 	last = atomic_dec_and_test(&obd->obd_refcount);
-	lu_ref_del(&obd->obd_reference, scope, source);
 
 	if (last) {
 		struct obd_export *exp;
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 4359a9320f37..81af452fbd85 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -388,8 +388,6 @@ static void osc_extent_free(struct kref *kref)
 	LASSERT(RB_EMPTY_NODE(&ext->oe_node));
 
 	if (ext->oe_dlmlock) {
-		lu_ref_add(&ext->oe_dlmlock->l_reference,
-			   "osc_extent", ext);
 		LDLM_LOCK_PUT(ext->oe_dlmlock);
 		ext->oe_dlmlock = NULL;
 	}
@@ -731,7 +729,6 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 	if (olck->ols_dlmlock) {
 		LASSERT(olck->ols_hold);
 		cur->oe_dlmlock = LDLM_LOCK_GET(olck->ols_dlmlock);
-		lu_ref_add(&olck->ols_dlmlock->l_reference, "osc_extent", cur);
 	}
 
 	/* grants has been allocated by caller */
@@ -1039,7 +1036,6 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 		list_del_init(&oap->oap_pending_item);
 
 		cl_page_get(page);
-		lu_ref_add(&page->cp_reference, "truncate", current);
 
 		if (cl_page_own(env, io, page) == 0) {
 			cl_page_discard(env, io, page);
@@ -1049,7 +1045,6 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 			LASSERT(0);
 		}
 
-		lu_ref_del(&page->cp_reference, "truncate", current);
 		cl_page_put(env, page);
 
 		--ext->oe_nr_pages;
@@ -1386,7 +1381,6 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 	 * released in cl_page_completion() and nothing except for the
 	 * reference counter protects page from concurrent reclaim.
 	 */
-	lu_ref_del(&page->cp_reference, "transfer", page);
 
 	cl_page_completion(env, page, crt, rc);
 	cl_page_put(env, page);
@@ -2208,7 +2202,6 @@ static void osc_check_rpcs(const struct lu_env *env, struct client_obd *cli)
 	spin_lock(&cli->cl_loi_list_lock);
 	while ((osc = osc_next_obj(cli)) != NULL) {
 		struct cl_object *obj = osc2cl(osc);
-		struct lu_ref_link link;
 
 		OSC_IO_DEBUG(osc, "%lu in flight\n", rpcs_in_flight(cli));
 
@@ -2219,7 +2212,6 @@ static void osc_check_rpcs(const struct lu_env *env, struct client_obd *cli)
 
 		cl_object_get(obj);
 		spin_unlock(&cli->cl_loi_list_lock);
-		lu_object_ref_add_at(&obj->co_lu, &link, "check", current);
 
 		/* attempt some read/write balancing by alternating between
 		 * reads and writes in an object.  The makes_rpc checks here
@@ -2256,7 +2248,6 @@ static void osc_check_rpcs(const struct lu_env *env, struct client_obd *cli)
 			CERROR("Read request failed with %d\n", rc);
 
 		osc_list_maint(cli, osc);
-		lu_object_ref_del_at(&obj->co_lu, &link, "check", current);
 		cl_object_put(env, obj);
 
 		spin_lock(&cli->cl_loi_list_lock);
@@ -3065,8 +3056,6 @@ bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 				continue;
 
 			cl_page_get(page);
-			lu_ref_add_atomic(&page->cp_reference,
-					  "gang_lookup", current);
 			pvec[j++] = ops;
 		}
 		++idx;
@@ -3088,7 +3077,6 @@ bool osc_page_gang_lookup(const struct lu_env *env, struct cl_io *io,
 				res = (*cb)(env, io, ops, cbdata);
 
 			page = ops->ops_cl.cpl_page;
-			lu_ref_del(&page->cp_reference, "gang_lookup", current);
 			cl_page_put(env, page);
 		}
 		if (nr < OTI_PVEC_SIZE || end_of_region)
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index bfc1abb47b49..ccdbdeffd1f3 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -239,7 +239,6 @@ static void osc_lock_granted(const struct lu_env *env, struct osc_lock *oscl,
 	/* lock reference taken by ldlm_handle2lock_long() is
 	 * owned by osc_lock and released in osc_lock_detach()
 	 */
-	lu_ref_add(&dlmlock->l_reference, "osc_lock", oscl);
 	oscl->ols_has_ref = 1;
 
 	LASSERT(!oscl->ols_dlmlock);
@@ -1031,7 +1030,6 @@ static void osc_lock_detach(const struct lu_env *env, struct osc_lock *olck)
 
 	/* release a reference taken in osc_lock_upcall(). */
 	LASSERT(olck->ols_has_ref);
-	lu_ref_del(&dlmlock->l_reference, "osc_lock", olck);
 	LDLM_LOCK_RELEASE(dlmlock);
 	olck->ols_has_ref = 0;
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index ce911b82512d..3ee7f14f7c7a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -61,7 +61,6 @@ static void osc_page_transfer_get(struct osc_page *opg, const char *label)
 
 	LASSERT(!opg->ops_transfer_pinned);
 	cl_page_get(page);
-	lu_ref_add_atomic(&page->cp_reference, label, page);
 	opg->ops_transfer_pinned = 1;
 }
 
@@ -72,7 +71,6 @@ static void osc_page_transfer_put(const struct lu_env *env,
 
 	if (opg->ops_transfer_pinned) {
 		opg->ops_transfer_pinned = 0;
-		lu_ref_del(&page->cp_reference, "transfer", page);
 		cl_page_put(env, page);
 	}
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 765b5a7b9662..6ba443be1026 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -556,10 +556,8 @@ static int osc_resource_get_unused(struct obd_export *exp, struct obdo *oa,
 	if (IS_ERR(res))
 		return 0;
 
-	LDLM_RESOURCE_ADDREF(res);
 	count = ldlm_cancel_resource_local(res, cancels, NULL, mode,
 					   lock_flags, 0, NULL);
-	LDLM_RESOURCE_DELREF(res);
 	ldlm_resource_putref(res);
 	return count;
 }
