From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:52 -0400
Subject: [lustre-devel] [PATCH 053/124] staging: lustre: obd: restore linkea
	support
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-54-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Original linkea was only used for the lustre server code
so it was removed from the upstream client. Now it needs
to be restored for client work that uses this infrastructure.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lu_object.h  |    7 +
 .../staging/lustre/lustre/include/lustre_linkea.h  |   79 ++++++++
 drivers/staging/lustre/lustre/obdclass/Makefile    |    2 +-
 drivers/staging/lustre/lustre/obdclass/linkea.c    |  201 ++++++++++++++++++++
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   70 +++++++
 5 files changed, 358 insertions(+), 1 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/include/lustre_linkea.h
 create mode 100644 drivers/staging/lustre/lustre/obdclass/linkea.c

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 66ab98a..7b37cae 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -1319,5 +1319,12 @@ struct lu_kmem_descr {
 int  lu_kmem_init(struct lu_kmem_descr *caches);
 void lu_kmem_fini(struct lu_kmem_descr *caches);
 
+void lu_buf_free(struct lu_buf *buf);
+void lu_buf_alloc(struct lu_buf *buf, size_t size);
+void lu_buf_realloc(struct lu_buf *buf, size_t size);
+
+int lu_buf_check_and_grow(struct lu_buf *buf, size_t len);
+struct lu_buf *lu_buf_check_and_alloc(struct lu_buf *buf, size_t len);
+
 /** @} lu */
 #endif /* __LUSTRE_LU_OBJECT_H */
diff --git a/drivers/staging/lustre/lustre/include/lustre_linkea.h b/drivers/staging/lustre/lustre/include/lustre_linkea.h
new file mode 100644
index 0000000..249e8bf
--- /dev/null
+++ b/drivers/staging/lustre/lustre/include/lustre_linkea.h
@@ -0,0 +1,79 @@
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2013, 2014, Intel Corporation.
+ * Use is subject to license terms.
+ *
+ * Author: di wang <di.wang@intel.com>
+ */
+
+#define DEFAULT_LINKEA_SIZE	4096
+
+struct linkea_data {
+	/**
+	 * Buffer to keep link EA body.
+	 */
+	struct lu_buf		*ld_buf;
+	/**
+	 * The matched header, entry and its length in the EA
+	 */
+	struct link_ea_header	*ld_leh;
+	struct link_ea_entry	*ld_lee;
+	int			ld_reclen;
+};
+
+int linkea_data_new(struct linkea_data *ldata, struct lu_buf *buf);
+int linkea_init(struct linkea_data *ldata);
+void linkea_entry_unpack(const struct link_ea_entry *lee, int *reclen,
+			 struct lu_name *lname, struct lu_fid *pfid);
+int linkea_entry_pack(struct link_ea_entry *lee, const struct lu_name *lname,
+		      const struct lu_fid *pfid);
+int linkea_add_buf(struct linkea_data *ldata, const struct lu_name *lname,
+		   const struct lu_fid *pfid);
+void linkea_del_buf(struct linkea_data *ldata, const struct lu_name *lname);
+int linkea_links_find(struct linkea_data *ldata, const struct lu_name *lname,
+		      const struct lu_fid  *pfid);
+
+static inline void linkea_first_entry(struct linkea_data *ldata)
+{
+	LASSERT(ldata);
+	LASSERT(ldata->ld_leh);
+
+	if (ldata->ld_leh->leh_reccount == 0)
+		ldata->ld_lee = NULL;
+	else
+		ldata->ld_lee = (struct link_ea_entry *)(ldata->ld_leh + 1);
+}
+
+static inline void linkea_next_entry(struct linkea_data *ldata)
+{
+	LASSERT(ldata);
+	LASSERT(ldata->ld_leh);
+
+	if (ldata->ld_lee) {
+		ldata->ld_lee = (struct link_ea_entry *)((char *)ldata->ld_lee +
+							 ldata->ld_reclen);
+		if ((char *)ldata->ld_lee >= ((char *)ldata->ld_leh +
+					      ldata->ld_leh->leh_len))
+			ldata->ld_lee = NULL;
+	}
+}
diff --git a/drivers/staging/lustre/lustre/obdclass/Makefile b/drivers/staging/lustre/lustre/obdclass/Makefile
index df7e47f..b42e109 100644
--- a/drivers/staging/lustre/lustre/obdclass/Makefile
+++ b/drivers/staging/lustre/lustre/obdclass/Makefile
@@ -3,6 +3,6 @@ obj-$(CONFIG_LUSTRE_FS) += obdclass.o
 obdclass-y := linux/linux-module.o linux/linux-obdo.o linux/linux-sysctl.o \
 	      llog.o llog_cat.o llog_obd.o llog_swab.o class_obd.o debug.o \
 	      genops.o uuid.o lprocfs_status.o lprocfs_counters.o \
-	      lustre_handles.o lustre_peer.o statfs_pack.o \
+	      lustre_handles.o lustre_peer.o statfs_pack.o linkea.o \
 	      obdo.o obd_config.o obd_mount.o lu_object.o lu_ref.o \
 	      cl_object.o cl_page.o cl_lock.o cl_io.o kernelcomm.o
diff --git a/drivers/staging/lustre/lustre/obdclass/linkea.c b/drivers/staging/lustre/lustre/obdclass/linkea.c
new file mode 100644
index 0000000..ee0a6e7
--- /dev/null
+++ b/drivers/staging/lustre/lustre/obdclass/linkea.c
@@ -0,0 +1,201 @@
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2013, 2014, Intel Corporation.
+ * Use is subject to license terms.
+ *
+ * Author: Di Wang <di.wang@intel.com>
+ */
+
+#include "../include/lustre/lustre_idl.h"
+#include "../include/obd.h"
+#include "../include/lustre_linkea.h"
+
+int linkea_data_new(struct linkea_data *ldata, struct lu_buf *buf)
+{
+	ldata->ld_buf = lu_buf_check_and_alloc(buf, PAGE_SIZE);
+	if (!ldata->ld_buf->lb_buf)
+		return -ENOMEM;
+	ldata->ld_leh = ldata->ld_buf->lb_buf;
+	ldata->ld_leh->leh_magic = LINK_EA_MAGIC;
+	ldata->ld_leh->leh_len = sizeof(struct link_ea_header);
+	ldata->ld_leh->leh_reccount = 0;
+	return 0;
+}
+EXPORT_SYMBOL(linkea_data_new);
+
+int linkea_init(struct linkea_data *ldata)
+{
+	struct link_ea_header *leh;
+
+	LASSERT(ldata->ld_buf);
+	leh = ldata->ld_buf->lb_buf;
+	if (leh->leh_magic == __swab32(LINK_EA_MAGIC)) {
+		leh->leh_magic = LINK_EA_MAGIC;
+		leh->leh_reccount = __swab32(leh->leh_reccount);
+		leh->leh_len = __swab64(leh->leh_len);
+		/* entries are swabbed by linkea_entry_unpack */
+	}
+	if (leh->leh_magic != LINK_EA_MAGIC)
+		return -EINVAL;
+	if (leh->leh_reccount == 0)
+		return -ENODATA;
+
+	ldata->ld_leh = leh;
+	return 0;
+}
+EXPORT_SYMBOL(linkea_init);
+
+/**
+ * Pack a link_ea_entry.
+ * All elements are stored as chars to avoid alignment issues.
+ * Numbers are always big-endian
+ * \retval record length
+ */
+int linkea_entry_pack(struct link_ea_entry *lee, const struct lu_name *lname,
+		      const struct lu_fid *pfid)
+{
+	struct lu_fid   tmpfid;
+	int             reclen;
+
+	tmpfid = *pfid;
+	if (OBD_FAIL_CHECK(OBD_FAIL_LFSCK_LINKEA_CRASH))
+		tmpfid.f_ver = ~0;
+	fid_cpu_to_be(&tmpfid, &tmpfid);
+	memcpy(&lee->lee_parent_fid, &tmpfid, sizeof(tmpfid));
+	memcpy(lee->lee_name, lname->ln_name, lname->ln_namelen);
+	reclen = sizeof(struct link_ea_entry) + lname->ln_namelen;
+
+	lee->lee_reclen[0] = (reclen >> 8) & 0xff;
+	lee->lee_reclen[1] = reclen & 0xff;
+	return reclen;
+}
+EXPORT_SYMBOL(linkea_entry_pack);
+
+void linkea_entry_unpack(const struct link_ea_entry *lee, int *reclen,
+			 struct lu_name *lname, struct lu_fid *pfid)
+{
+	*reclen = (lee->lee_reclen[0] << 8) | lee->lee_reclen[1];
+	memcpy(pfid, &lee->lee_parent_fid, sizeof(*pfid));
+	fid_be_to_cpu(pfid, pfid);
+	if (lname) {
+		lname->ln_name = lee->lee_name;
+		lname->ln_namelen = *reclen - sizeof(struct link_ea_entry);
+	}
+}
+EXPORT_SYMBOL(linkea_entry_unpack);
+
+/**
+ * Add a record to the end of link ea buf
+ **/
+int linkea_add_buf(struct linkea_data *ldata, const struct lu_name *lname,
+		   const struct lu_fid *pfid)
+{
+	LASSERT(ldata->ld_leh);
+
+	if (!lname || !pfid)
+		return -EINVAL;
+
+	ldata->ld_reclen = lname->ln_namelen + sizeof(struct link_ea_entry);
+	if (ldata->ld_leh->leh_len + ldata->ld_reclen >
+	    ldata->ld_buf->lb_len) {
+		if (lu_buf_check_and_grow(ldata->ld_buf,
+					  ldata->ld_leh->leh_len +
+					  ldata->ld_reclen) < 0)
+			return -ENOMEM;
+	}
+
+	ldata->ld_leh = ldata->ld_buf->lb_buf;
+	ldata->ld_lee = ldata->ld_buf->lb_buf + ldata->ld_leh->leh_len;
+	ldata->ld_reclen = linkea_entry_pack(ldata->ld_lee, lname, pfid);
+	ldata->ld_leh->leh_len += ldata->ld_reclen;
+	ldata->ld_leh->leh_reccount++;
+	CDEBUG(D_INODE, "New link_ea name '" DFID ":%.*s' is added\n",
+	       PFID(pfid), lname->ln_namelen, lname->ln_name);
+	return 0;
+}
+EXPORT_SYMBOL(linkea_add_buf);
+
+/** Del the current record from the link ea buf */
+void linkea_del_buf(struct linkea_data *ldata, const struct lu_name *lname)
+{
+	LASSERT(ldata->ld_leh && ldata->ld_lee);
+
+	ldata->ld_leh->leh_reccount--;
+	ldata->ld_leh->leh_len -= ldata->ld_reclen;
+	memmove(ldata->ld_lee, (char *)ldata->ld_lee + ldata->ld_reclen,
+		(char *)ldata->ld_leh + ldata->ld_leh->leh_len -
+		(char *)ldata->ld_lee);
+	CDEBUG(D_INODE, "Old link_ea name '%.*s' is removed\n",
+	       lname->ln_namelen, lname->ln_name);
+
+	if ((char *)ldata->ld_lee >= ((char *)ldata->ld_leh +
+				      ldata->ld_leh->leh_len))
+		ldata->ld_lee = NULL;
+}
+EXPORT_SYMBOL(linkea_del_buf);
+
+/**
+ * Check if such a link exists in linkEA.
+ *
+ * \param ldata link data the search to be done on
+ * \param lname name in the parent's directory entry pointing to this object
+ * \param pfid parent fid the link to be found for
+ *
+ * \retval   0 success
+ * \retval -ENOENT link does not exist
+ * \retval -ve on error
+ */
+int linkea_links_find(struct linkea_data *ldata, const struct lu_name *lname,
+		      const struct lu_fid  *pfid)
+{
+	struct lu_name tmpname;
+	struct lu_fid  tmpfid;
+	int count;
+
+	LASSERT(ldata->ld_leh);
+
+	/* link #0 */
+	ldata->ld_lee = (struct link_ea_entry *)(ldata->ld_leh + 1);
+
+	for (count = 0; count < ldata->ld_leh->leh_reccount; count++) {
+		linkea_entry_unpack(ldata->ld_lee, &ldata->ld_reclen,
+				    &tmpname, &tmpfid);
+		if (tmpname.ln_namelen == lname->ln_namelen &&
+		    lu_fid_eq(&tmpfid, pfid) &&
+		    (strncmp(tmpname.ln_name, lname->ln_name,
+			     tmpname.ln_namelen) == 0))
+			break;
+		ldata->ld_lee = (struct link_ea_entry *)((char *)ldata->ld_lee +
+							 ldata->ld_reclen);
+	}
+
+	if (count == ldata->ld_leh->leh_reccount) {
+		CDEBUG(D_INODE, "Old link_ea name '%.*s' not found\n",
+		       lname->ln_namelen, lname->ln_name);
+		ldata->ld_lee = NULL;
+		ldata->ld_reclen = 0;
+		return -ENOENT;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(linkea_links_find);
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 44a854c..e284e5d 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -1984,3 +1984,73 @@ void lu_kmem_fini(struct lu_kmem_descr *caches)
 	}
 }
 EXPORT_SYMBOL(lu_kmem_fini);
+
+void lu_buf_free(struct lu_buf *buf)
+{
+	LASSERT(buf);
+	if (buf->lb_buf) {
+		LASSERT(buf->lb_len > 0);
+		kvfree(buf->lb_buf);
+		buf->lb_buf = NULL;
+		buf->lb_len = 0;
+	}
+}
+EXPORT_SYMBOL(lu_buf_free);
+
+void lu_buf_alloc(struct lu_buf *buf, size_t size)
+{
+	LASSERT(buf);
+	LASSERT(!buf->lb_buf);
+	LASSERT(!buf->lb_len);
+	buf->lb_buf = libcfs_kvzalloc(size, GFP_NOFS);
+	if (likely(buf->lb_buf))
+		buf->lb_len = size;
+}
+EXPORT_SYMBOL(lu_buf_alloc);
+
+void lu_buf_realloc(struct lu_buf *buf, size_t size)
+{
+	lu_buf_free(buf);
+	lu_buf_alloc(buf, size);
+}
+EXPORT_SYMBOL(lu_buf_realloc);
+
+struct lu_buf *lu_buf_check_and_alloc(struct lu_buf *buf, size_t len)
+{
+	if (!buf->lb_buf && !buf->lb_len)
+		lu_buf_alloc(buf, len);
+
+	if ((len > buf->lb_len) && buf->lb_buf)
+		lu_buf_realloc(buf, len);
+
+	return buf;
+}
+EXPORT_SYMBOL(lu_buf_check_and_alloc);
+
+/**
+ * Increase the size of the \a buf.
+ * preserves old data in buffer
+ * old buffer remains unchanged on error
+ * \retval 0 or -ENOMEM
+ */
+int lu_buf_check_and_grow(struct lu_buf *buf, size_t len)
+{
+	char *ptr;
+
+	if (len <= buf->lb_len)
+		return 0;
+
+	ptr = libcfs_kvzalloc(len, GFP_NOFS);
+	if (!ptr)
+		return -ENOMEM;
+
+	/* Free the old buf */
+	if (buf->lb_buf) {
+		memcpy(ptr, buf->lb_buf, buf->lb_len);
+		kvfree(buf->lb_buf);
+	}
+
+	buf->lb_buf = ptr;
+	buf->lb_len = len;
+	return 0;
+}
-- 
1.7.1
