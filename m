From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:38 -0500
Subject: [lustre-devel] [PATCH 050/622] lustre: osc: add T10PI support for
 RPC checksum
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-51-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Li Xi <lixi@ddn.com>

T10 Protection Information (T10 PI), previously known as Data
Integrity Field (DIF), is a standard for end-to-end data integrity
validation. T10 PI prevents silent data corruption, ensuring that
incomplete and incorrect data cannot overwrite good data.

Lustre file system already supports RPC level checksum which
validates the data in bulk RPCs when writing/reading data to/from
objects on OSTs. RPC level checksum can detect data corruption that
happens during RPC being transferred over the wire. However, it is
not capable to prevent silent data corruption happening in other
conditions, for example, memory corruption when data is cached in
page cache. And by using the existing checksum mechanism, only
disjoint protection coverage is provided. Thus, in order to provide
end-to-end data protection, T10PI support for Lustre should be added.

In order to provide end-to-end data integrity validation, the T10 PI
checksum of data in a sector need to be calculated on Lustre client
side and validated later on the Lustre OSS side. The T10 protection
information should be sent together with the data in the RPC.
However, in order to avoid significant performance degradation,
instead of sending all original guard tags for all sectors in a bulk
RPC, the existing checksum feature of bulk RPC will be integrated
together with the new T10PI feature.

When OST starts, necessary T10PI information will be extracted from
storage, i.e. the T10PI DIF type and sector size. The DIF type could
be one of TYPE1_IP, TYPE1_CRC, TYPE3_IP and TYPE3_CRC. And sector
size could be either 512 or 4K bytes.

When an OSC is connecting to OST, OSC and OST will negotiate about
the checksum types. New checksum types are added for T10PI support
including OBD_CKSUM_T10IP512, OBD_CKSUM_T10IP4K, OBD_CKSUM_T10CRC512,
and OBD_CKSUM_T10CRC4K. If the OST storage has T10PI suppoort, the
only selectable T10PI checksum type would have the same type with the
T10PI type of the hardware. The other existing checksum types (crc32,
crc32c, adler32) are still valid options for the RPC checksum type.

When calculating RPC checksum of T10PI, the T10PI checksums of all
sectors will be calculated first using the T10PI chekcsum type, i.e.
16-bit crc or IP checksum. And then RPC checksum will be calculated on
all of the T10PI checksums. The RPC checksum type used in this step is
always alder32. Considering that the checksum-of-checksums is only
computed on a * 4KB chunk of GRD tags for a 1MB RPC for 512B sectors,
or 16KB of GRD tags for 16MB of 4KB sectors, this is only 1/256 or
1/1024 of the total data being checksummed, so the checksum type used
here should not affect overall system performance noticeably.

obdfilter.*.enforce_t10pi_cksum can be used to tune whether to enforce
T10-PI checksum or not.

If the OST supports T10-PI feature and T10-PI chekcsum is enforced, clients
will have no other choice for RPC checksum type other than using the T10PI
chekcsum type. This is useful for enforcing end-to-end integrity in the
whole system.

If the OST doesn't support T10-PI feature and T10-PI chekcsum is enforced,
together with other checksums with reasonably good speeds (e.g. crc32,
crc32c, adler, etc.), all the T10-PI checksum types (t10ip512, t10ip4K,
t10crc512, t10crc4K) will be added to the available checksum types,
regardless of the speeds of T10-PI chekcsums. This is useful for testing
T10-PI checksums of RPC.

If the OST supports T10-PI feature and T10-PI chekcsum is NOT enforced,
the corresponding T10-PI checksum type will be added to the checksum type
list, regardless of the speed of the T10-PI chekcsum. This provide the
clients to flexibility to choose whether to enable end-to-end integrity
or not.

If the OST does NOT supports T10-PI feature and T10-PI chekcsum is NOT
enforced, together with other checksums with reasonably good speeds,
all the T10-PI checksum types with good speeds will be added into the
checksum type list. Note that a T10-PI checksum type with a speed worse
than half of Alder will NOT be added as a option. In this circumstance,
T10-PI checksum types has the same behavior like other normal checksum
types.

The clients that has no T10-PI RPC checksum support will not be affected
by the above-mentioned logic. And that logic will only be enforced to the
newly connected clients after changing obdfilter.*.enforce_t10pi_cksum on
an OST.

Following are the speeds of different checksum types on a server with CPU
of Intel(R) Xeon(R) E5-2650 @ 2.00GHz:

crc: 1575 MB/s
crc32c: 9763 MB/s
adler: 1255 MB/s
t10ip512: 6151 MB/s
t10ip4k: 7935 MB/s
t10crc512: 1119 MB/s
t10crc4k: 1531 MB/s

WC-bug-id: https://jira.whamcloud.com/browse/LU-10472
Lustre-commit: b1e7be00cb6e ("LU-10472 osc: add T10PI support for RPC checksum")
Signed-off-by: Li Xi <lixi@ddn.com>
Reviewed-on: https://review.whamcloud.com/30980
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Faccini Bruno <bruno.faccini@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_cksum.h          | 123 +++++++++------
 fs/lustre/include/obd_class.h          |   1 -
 fs/lustre/llite/llite_lib.c            |   4 +-
 fs/lustre/obdclass/Makefile            |   2 +-
 fs/lustre/obdclass/integrity.c         | 273 +++++++++++++++++++++++++++++++++
 fs/lustre/obdclass/obd_cksum.c         | 151 ++++++++++++++++++
 fs/lustre/osc/osc_request.c            | 214 +++++++++++++++++++++++---
 fs/lustre/ptlrpc/import.c              |   8 +-
 fs/lustre/ptlrpc/wiretest.c            |  17 +-
 include/uapi/linux/lustre/lustre_idl.h |  48 ++++--
 net/lnet/libcfs/linux-crypto.c         |   3 +
 11 files changed, 753 insertions(+), 91 deletions(-)
 create mode 100644 fs/lustre/obdclass/integrity.c
 create mode 100644 fs/lustre/obdclass/obd_cksum.c

diff --git a/fs/lustre/include/obd_cksum.h b/fs/lustre/include/obd_cksum.h
index 26a9555..cc47c44 100644
--- a/fs/lustre/include/obd_cksum.h
+++ b/fs/lustre/include/obd_cksum.h
@@ -35,6 +35,9 @@
 #include <linux/libcfs/libcfs_crypto.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 
+int obd_t10_cksum_speed(const char *obd_name,
+			enum cksum_type cksum_type);
+
 static inline unsigned char cksum_obd2cfs(enum cksum_type cksum_type)
 {
 	switch (cksum_type) {
@@ -51,59 +54,23 @@ static inline unsigned char cksum_obd2cfs(enum cksum_type cksum_type)
 	return 0;
 }
 
-/* The OBD_FL_CKSUM_* flags is packed into 5 bits of o_flags, since there can
- * only be a single checksum type per RPC.
- *
- * The OBD_CHECKSUM_* type bits passed in ocd_cksum_types are a 32-bit bitmask
- * since they need to represent the full range of checksum algorithms that
- * both the client and server can understand.
- *
- * In case of an unsupported types/flags we fall back to ADLER
- * because that is supported by all clients since 1.8
- *
- * In case multiple algorithms are supported the best one is used.
- */
-static inline u32 cksum_type_pack(enum cksum_type cksum_type)
-{
-	unsigned int performance = 0, tmp;
-	u32 flag = OBD_FL_CKSUM_ADLER;
-
-	if (cksum_type & OBD_CKSUM_CRC32) {
-		tmp = cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_CRC32));
-		if (tmp > performance) {
-			performance = tmp;
-			flag = OBD_FL_CKSUM_CRC32;
-		}
-	}
-	if (cksum_type & OBD_CKSUM_CRC32C) {
-		tmp = cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_CRC32C));
-		if (tmp > performance) {
-			performance = tmp;
-			flag = OBD_FL_CKSUM_CRC32C;
-		}
-	}
-	if (cksum_type & OBD_CKSUM_ADLER) {
-		tmp = cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_ADLER));
-		if (tmp > performance) {
-			performance = tmp;
-			flag = OBD_FL_CKSUM_ADLER;
-		}
-	}
-	if (unlikely(cksum_type && !(cksum_type & (OBD_CKSUM_CRC32C |
-						   OBD_CKSUM_CRC32 |
-						   OBD_CKSUM_ADLER))))
-		CWARN("unknown cksum type %x\n", cksum_type);
-
-	return flag;
-}
+u32 obd_cksum_type_pack(const char *obd_name, enum cksum_type cksum_type);
 
-static inline enum cksum_type cksum_type_unpack(u32 o_flags)
+static inline enum cksum_type obd_cksum_type_unpack(u32 o_flags)
 {
 	switch (o_flags & OBD_FL_CKSUM_ALL) {
 	case OBD_FL_CKSUM_CRC32C:
 		return OBD_CKSUM_CRC32C;
 	case OBD_FL_CKSUM_CRC32:
 		return OBD_CKSUM_CRC32;
+	case OBD_FL_CKSUM_T10IP512:
+		return OBD_CKSUM_T10IP512;
+	case OBD_FL_CKSUM_T10IP4K:
+		return OBD_CKSUM_T10IP4K;
+	case OBD_FL_CKSUM_T10CRC512:
+		return OBD_CKSUM_T10CRC512;
+	case OBD_FL_CKSUM_T10CRC4K:
+		return OBD_CKSUM_T10CRC4K;
 	default:
 		break;
 	}
@@ -115,7 +82,7 @@ static inline enum cksum_type cksum_type_unpack(u32 o_flags)
  * 1.8 supported ADLER it is base and not depend on hw
  * Client uses all available local algos
  */
-static inline enum cksum_type cksum_types_supported_client(void)
+static inline enum cksum_type obd_cksum_types_supported_client(void)
 {
 	enum cksum_type ret = OBD_CKSUM_ADLER;
 
@@ -128,6 +95,8 @@ static inline enum cksum_type cksum_types_supported_client(void)
 		ret |= OBD_CKSUM_CRC32C;
 	if (cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_CRC32)) > 0)
 		ret |= OBD_CKSUM_CRC32;
+	/* Client support all kinds of T10 checksum */
+	ret |= OBD_CKSUM_T10_ALL;
 
 	return ret;
 }
@@ -140,14 +109,68 @@ static inline enum cksum_type cksum_types_supported_client(void)
  * Caution is advised, however, since what is fastest on a single client may
  * not be the fastest or most efficient algorithm on the server.
  */
-static inline enum cksum_type cksum_type_select(enum cksum_type cksum_types)
+static inline enum cksum_type
+obd_cksum_type_select(const char *obd_name, enum cksum_type cksum_types)
 {
-	return cksum_type_unpack(cksum_type_pack(cksum_types));
+	u32 flag = obd_cksum_type_pack(obd_name, cksum_types);
+
+	return obd_cksum_type_unpack(flag);
 }
 
 /* Checksum algorithm names. Must be defined in the same order as the
  * OBD_CKSUM_* flags.
  */
-#define DECLARE_CKSUM_NAME char *cksum_name[] = {"crc32", "adler", "crc32c"}
+#define DECLARE_CKSUM_NAME const char *cksum_name[] = {"crc32", "adler", \
+	"crc32c", "reserved", "t10ip512", "t10ip4K", "t10crc512", "t10crc4K"}
+
+typedef u16 (obd_dif_csum_fn) (void *, unsigned int);
+
+u16 obd_dif_crc_fn(void *data, unsigned int len);
+u16 obd_dif_ip_fn(void *data, unsigned int len);
+int obd_page_dif_generate_buffer(const char *obd_name, struct page *page,
+				 u32 offset, u32 length,
+				 u16 *guard_start, int guard_number,
+				 int *used_number, int sector_size,
+				 obd_dif_csum_fn *fn);
+/*
+ * If checksum type is one T10 checksum types, init the csum_fn and sector
+ * size. Otherwise, init them to NULL/zero.
+ */
+static inline void obd_t10_cksum2dif(enum cksum_type cksum_type,
+				     obd_dif_csum_fn **fn, int *sector_size)
+{
+	*fn = NULL;
+	*sector_size = 0;
+
+	switch (cksum_type) {
+	case OBD_CKSUM_T10IP512:
+		*fn = obd_dif_ip_fn;
+		*sector_size = 512;
+		break;
+	case OBD_CKSUM_T10IP4K:
+		*fn = obd_dif_ip_fn;
+		*sector_size = 4096;
+		break;
+	case OBD_CKSUM_T10CRC512:
+		*fn = obd_dif_crc_fn;
+		*sector_size = 512;
+		break;
+	case OBD_CKSUM_T10CRC4K:
+		*fn = obd_dif_crc_fn;
+		*sector_size = 4096;
+		break;
+	default:
+		break;
+	}
+}
+
+enum obd_t10_cksum_type {
+	OBD_T10_CKSUM_UNKNOWN = 0,
+	OBD_T10_CKSUM_IP512,
+	OBD_T10_CKSUM_IP4K,
+	OBD_T10_CKSUM_CRC512,
+	OBD_T10_CKSUM_CRC4K,
+	OBD_T10_CKSUM_MAX
+};
 
 #endif /* __OBD_H */
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index d896049..0153c50 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1687,7 +1687,6 @@ static inline void class_uuid_unparse(class_uuid_t uu, struct obd_uuid *out)
 extern char obd_jobid_name[];
 int class_procfs_init(void);
 int class_procfs_clean(void);
-
 /* prng.c */
 #define ll_generate_random_uuid(uuid_out) \
 	get_random_bytes(uuid_out, sizeof(class_uuid_t))
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index eb29064..dff349f 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -218,7 +218,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				   OBD_CONNECT_LARGE_ACL;
 #endif
 
-	data->ocd_cksum_types = cksum_types_supported_client();
+	data->ocd_cksum_types = obd_cksum_types_supported_client();
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_MDC_LIGHTWEIGHT))
 		/* flag mdc connection as lightweight, only used for test
@@ -432,7 +432,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_CKSUM_ADLER_ONLY))
 		data->ocd_cksum_types = OBD_CKSUM_ADLER;
 	else
-		data->ocd_cksum_types = cksum_types_supported_client();
+		data->ocd_cksum_types = obd_cksum_types_supported_client();
 
 	data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
 
diff --git a/fs/lustre/obdclass/Makefile b/fs/lustre/obdclass/Makefile
index 96fce1b..25d2e1d 100644
--- a/fs/lustre/obdclass/Makefile
+++ b/fs/lustre/obdclass/Makefile
@@ -8,4 +8,4 @@ obdclass-y := llog.o llog_cat.o llog_obd.o llog_swab.o class_obd.o \
 	      lustre_handles.o lustre_peer.o statfs_pack.o linkea.o \
 	      obdo.o obd_config.o obd_mount.o lu_object.o lu_ref.o \
 	      cl_object.o cl_page.o cl_lock.o cl_io.o kernelcomm.o \
-	      jobid.o
+	      jobid.o integrity.o obd_cksum.o
diff --git a/fs/lustre/obdclass/integrity.c b/fs/lustre/obdclass/integrity.c
new file mode 100644
index 0000000..8348b16
--- /dev/null
+++ b/fs/lustre/obdclass/integrity.c
@@ -0,0 +1,273 @@
+// SPDX-License-Identifier: GPL-2.0
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
+ * Copyright (c) 2018, DataDirect Networks Storage.
+ * Author: Li Xi.
+ *
+ * General data integrity functions
+ */
+#include <linux/blkdev.h>
+#include <linux/crc-t10dif.h>
+#include <asm-generic/checksum.h>
+#include <obd_class.h>
+#include <obd_cksum.h>
+
+u16 obd_dif_crc_fn(void *data, unsigned int len)
+{
+	return cpu_to_be16(crc_t10dif(data, len));
+}
+EXPORT_SYMBOL(obd_dif_crc_fn);
+
+u16 obd_dif_ip_fn(void *data, unsigned int len)
+{
+	return ip_compute_csum(data, len);
+}
+EXPORT_SYMBOL(obd_dif_ip_fn);
+
+int obd_page_dif_generate_buffer(const char *obd_name, struct page *page,
+				 u32 offset, u32 length,
+				 u16 *guard_start, int guard_number,
+				 int *used_number, int sector_size,
+				 obd_dif_csum_fn *fn)
+{
+	unsigned int i;
+	char *data_buf;
+	u16 *guard_buf = guard_start;
+	unsigned int data_size;
+	int used = 0;
+
+	data_buf = kmap(page) + offset;
+	for (i = 0; i < length; i += sector_size) {
+		if (used >= guard_number) {
+			CERROR("%s: unexpected used guard number of DIF %u/%u, data length %u, sector size %u: rc = %d\n",
+			       obd_name, used, guard_number, length,
+			       sector_size, -E2BIG);
+			return -E2BIG;
+		}
+		data_size = length - i;
+		if (data_size > sector_size)
+			data_size = sector_size;
+		*guard_buf = fn(data_buf, data_size);
+		guard_buf++;
+		data_buf += data_size;
+		used++;
+	}
+	kunmap(page);
+	*used_number = used;
+
+	return 0;
+}
+EXPORT_SYMBOL(obd_page_dif_generate_buffer);
+
+static int __obd_t10_performance_test(const char *obd_name,
+				      enum cksum_type cksum_type,
+				      struct page *data_page,
+				      int repeat_number)
+{
+	unsigned char cfs_alg = cksum_obd2cfs(OBD_CKSUM_T10_TOP);
+	struct ahash_request *hdesc;
+	obd_dif_csum_fn *fn = NULL;
+	unsigned int bufsize;
+	unsigned char *buffer;
+	struct page *__page;
+	u16 *guard_start;
+	int guard_number;
+	int used_number = 0;
+	int sector_size = 0;
+	u32 cksum;
+	int rc = 0;
+	int rc2;
+	int used;
+	int i;
+
+	obd_t10_cksum2dif(cksum_type, &fn, &sector_size);
+	if (!fn)
+		return -EINVAL;
+
+	__page = alloc_page(GFP_KERNEL);
+	if (!__page)
+		return -ENOMEM;
+
+	hdesc = cfs_crypto_hash_init(cfs_alg, NULL, 0);
+	if (IS_ERR(hdesc)) {
+		rc = PTR_ERR(hdesc);
+		CERROR("%s: unable to initialize checksum hash %s: rc = %d\n",
+		       obd_name, cfs_crypto_hash_name(cfs_alg), rc);
+		goto out;
+	}
+
+	buffer = kmap(__page);
+	guard_start = (u16 *)buffer;
+	guard_number = PAGE_SIZE / sizeof(*guard_start);
+	for (i = 0; i < repeat_number; i++) {
+		/*
+		 * The left guard number should be able to hold checksums of a
+		 * whole page
+		 */
+		rc = obd_page_dif_generate_buffer(obd_name, data_page, 0,
+						  PAGE_SIZE,
+						  guard_start + used_number,
+						  guard_number - used_number,
+						  &used, sector_size, fn);
+		if (rc)
+			break;
+
+		used_number += used;
+		if (used_number == guard_number) {
+			cfs_crypto_hash_update_page(hdesc, __page, 0,
+				used_number * sizeof(*guard_start));
+			used_number = 0;
+		}
+	}
+	kunmap(__page);
+	if (rc)
+		goto out_final;
+
+	if (used_number != 0)
+		cfs_crypto_hash_update_page(hdesc, __page, 0,
+			used_number * sizeof(*guard_start));
+
+	bufsize = sizeof(cksum);
+out_final:
+	rc2 = cfs_crypto_hash_final(hdesc, (unsigned char *)&cksum, &bufsize);
+	rc = rc ? rc : rc2;
+out:
+	__free_page(__page);
+
+	return rc;
+}
+
+/**
+ *  Array of T10PI checksum algorithm speed in MByte per second
+ */
+static int obd_t10_cksum_speeds[OBD_T10_CKSUM_MAX];
+
+static enum obd_t10_cksum_type
+obd_t10_cksum2type(enum cksum_type cksum_type)
+{
+	switch (cksum_type) {
+	case OBD_CKSUM_T10IP512:
+		return OBD_T10_CKSUM_IP512;
+	case OBD_CKSUM_T10IP4K:
+		return OBD_T10_CKSUM_IP4K;
+	case OBD_CKSUM_T10CRC512:
+		return OBD_T10_CKSUM_CRC512;
+	case OBD_CKSUM_T10CRC4K:
+		return OBD_T10_CKSUM_CRC4K;
+	default:
+		return OBD_T10_CKSUM_UNKNOWN;
+	}
+}
+
+static const char *obd_t10_cksum_name(enum obd_t10_cksum_type index)
+{
+	DECLARE_CKSUM_NAME;
+
+	/* Need to skip "crc32", "adler", "crc32c", "reserved" */
+	return cksum_name[3 + index];
+}
+
+/**
+ * Compute the speed of specified T10PI checksum type
+ *
+ * Run a speed test on the given T10PI checksum on buffer using a 1MB buffer
+ * size. This is a reasonable buffer size for Lustre RPCs, even if the actual
+ * RPC size is larger or smaller.
+ *
+ * The speed is stored internally in the obd_t10_cksum_speeds[] array, and
+ * is available through the obd_t10_cksum_speed() function.
+ *
+ * This function needs to stay the same as cfs_crypto_performance_test() so
+ * that the speeds are comparable. And this function should reflect the real
+ * cost of the checksum calculation.
+ *
+ * \param[in] obd_name		name of the OBD device
+ * \param[in] cksum_type	checksum type (OBD_CKSUM_T10*)
+ */
+static void obd_t10_performance_test(const char *obd_name,
+				     enum cksum_type cksum_type)
+{
+	enum obd_t10_cksum_type index = obd_t10_cksum2type(cksum_type);
+	const int buf_len = max(PAGE_SIZE, 1048576UL);
+	unsigned long bcount;
+	unsigned long start;
+	unsigned long end;
+	struct page *page;
+	int rc = 0;
+	void *buf;
+
+	page = alloc_page(GFP_KERNEL);
+	if (!page) {
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	buf = kmap(page);
+	memset(buf, 0xAD, PAGE_SIZE);
+	kunmap(page);
+
+	for (start = jiffies, end = start + msecs_to_jiffies(MSEC_PER_SEC / 4),
+	     bcount = 0; time_before(jiffies, end) && rc == 0; bcount++) {
+		rc = __obd_t10_performance_test(obd_name, cksum_type, page,
+						buf_len / PAGE_SIZE);
+		if (rc)
+			break;
+	}
+	end = jiffies;
+	__free_page(page);
+out:
+	if (rc) {
+		obd_t10_cksum_speeds[index] = rc;
+		CDEBUG(D_INFO,
+		       "%s: T10 checksum algorithm %s test error: rc = %d\n",
+		       obd_name, obd_t10_cksum_name(index), rc);
+	} else {
+		unsigned long tmp;
+
+		tmp = ((bcount * buf_len / jiffies_to_msecs(end - start)) *
+		       1000) / (1024 * 1024);
+		obd_t10_cksum_speeds[index] = (int)tmp;
+		CDEBUG(D_CONFIG,
+		       "%s: T10 checksum algorithm %s speed = %d MB/s\n",
+		       obd_name, obd_t10_cksum_name(index),
+		       obd_t10_cksum_speeds[index]);
+	}
+}
+
+int obd_t10_cksum_speed(const char *obd_name,
+			enum cksum_type cksum_type)
+{
+	enum obd_t10_cksum_type index = obd_t10_cksum2type(cksum_type);
+
+	if (unlikely(obd_t10_cksum_speeds[index] == 0)) {
+		static DEFINE_MUTEX(obd_t10_cksum_speed_mutex);
+
+		mutex_lock(&obd_t10_cksum_speed_mutex);
+		if (obd_t10_cksum_speeds[index] == 0)
+			obd_t10_performance_test(obd_name, cksum_type);
+		mutex_unlock(&obd_t10_cksum_speed_mutex);
+	}
+
+	return obd_t10_cksum_speeds[index];
+}
+EXPORT_SYMBOL(obd_t10_cksum_speed);
diff --git a/fs/lustre/obdclass/obd_cksum.c b/fs/lustre/obdclass/obd_cksum.c
new file mode 100644
index 0000000..601feb7
--- /dev/null
+++ b/fs/lustre/obdclass/obd_cksum.c
@@ -0,0 +1,151 @@
+// SPDX-License-Identifier: GPL-2.0
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
+ * Copyright (c) 2018, DataDirect Networks Storage.
+ * Author: Li Xi.
+ *
+ * Checksum functions
+ */
+#include <obd_class.h>
+#include <obd_cksum.h>
+
+/* Server uses algos that perform at 50% or better of the Adler */
+enum cksum_type obd_cksum_types_supported_server(const char *obd_name)
+{
+	enum cksum_type ret = OBD_CKSUM_ADLER;
+	int base_speed;
+
+	CDEBUG(D_INFO,
+	       "%s: checksum speed: crc %d, crc32c %d, adler %d, t10ip512 %d, t10ip4k %d, t10crc512 %d, t10crc4k %d\n",
+	       obd_name,
+	       cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_CRC32)),
+	       cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_CRC32C)),
+	       cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_ADLER)),
+	       obd_t10_cksum_speed(obd_name, OBD_CKSUM_T10IP512),
+	       obd_t10_cksum_speed(obd_name, OBD_CKSUM_T10IP4K),
+	       obd_t10_cksum_speed(obd_name, OBD_CKSUM_T10CRC512),
+	       obd_t10_cksum_speed(obd_name, OBD_CKSUM_T10CRC4K));
+
+	base_speed = cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_ADLER)) / 2;
+
+	if (cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_CRC32C)) >=
+	    base_speed)
+		ret |= OBD_CKSUM_CRC32C;
+
+	if (cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_CRC32)) >=
+	    base_speed)
+		ret |= OBD_CKSUM_CRC32;
+
+	if (obd_t10_cksum_speed(obd_name, OBD_CKSUM_T10IP512) >= base_speed)
+		ret |= OBD_CKSUM_T10IP512;
+
+	if (obd_t10_cksum_speed(obd_name, OBD_CKSUM_T10IP4K) >= base_speed)
+		ret |= OBD_CKSUM_T10IP4K;
+
+	if (obd_t10_cksum_speed(obd_name, OBD_CKSUM_T10CRC512) >= base_speed)
+		ret |= OBD_CKSUM_T10CRC512;
+
+	if (obd_t10_cksum_speed(obd_name, OBD_CKSUM_T10CRC4K) >= base_speed)
+		ret |= OBD_CKSUM_T10CRC4K;
+
+	return ret;
+}
+EXPORT_SYMBOL(obd_cksum_types_supported_server);
+
+/* The OBD_FL_CKSUM_* flags is packed into 5 bits of o_flags, since there can
+ * only be a single checksum type per RPC.
+ *
+ * The OBD_CKSUM_* type bits passed in ocd_cksum_types are a 32-bit bitmask
+ * since they need to represent the full range of checksum algorithms that
+ * both the client and server can understand.
+ *
+ * In case of an unsupported types/flags we fall back to ADLER
+ * because that is supported by all clients since 1.8
+ *
+ * In case multiple algorithms are supported the best one is used.
+ */
+u32 obd_cksum_type_pack(const char *obd_name, enum cksum_type cksum_type)
+{
+	unsigned int performance = 0, tmp;
+	u32 flag = OBD_FL_CKSUM_ADLER;
+
+	if (cksum_type & OBD_CKSUM_CRC32) {
+		tmp = cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_CRC32));
+		if (tmp > performance) {
+			performance = tmp;
+			flag = OBD_FL_CKSUM_CRC32;
+		}
+	}
+	if (cksum_type & OBD_CKSUM_CRC32C) {
+		tmp = cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_CRC32C));
+		if (tmp > performance) {
+			performance = tmp;
+			flag = OBD_FL_CKSUM_CRC32C;
+		}
+	}
+	if (cksum_type & OBD_CKSUM_ADLER) {
+		tmp = cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_ADLER));
+		if (tmp > performance) {
+			performance = tmp;
+			flag = OBD_FL_CKSUM_ADLER;
+		}
+	}
+
+	if (cksum_type & OBD_CKSUM_T10IP512) {
+		tmp = obd_t10_cksum_speed(obd_name, OBD_CKSUM_T10IP512);
+		if (tmp > performance) {
+			performance = tmp;
+			flag = OBD_FL_CKSUM_T10IP512;
+		}
+	}
+
+	if (cksum_type & OBD_CKSUM_T10IP4K) {
+		tmp = obd_t10_cksum_speed(obd_name, OBD_CKSUM_T10IP4K);
+		if (tmp > performance) {
+			performance = tmp;
+			flag = OBD_FL_CKSUM_T10IP4K;
+		}
+	}
+
+	if (cksum_type & OBD_CKSUM_T10CRC512) {
+		tmp = obd_t10_cksum_speed(obd_name, OBD_CKSUM_T10CRC512);
+		if (tmp > performance) {
+			performance = tmp;
+			flag = OBD_FL_CKSUM_T10CRC512;
+		}
+	}
+
+	if (cksum_type & OBD_CKSUM_T10CRC4K) {
+		tmp = obd_t10_cksum_speed(obd_name, OBD_CKSUM_T10CRC4K);
+		if (tmp > performance) {
+			performance = tmp;
+			flag = OBD_FL_CKSUM_T10CRC4K;
+		}
+	}
+
+	if (unlikely(cksum_type && !(cksum_type & OBD_CKSUM_ALL)))
+		CWARN("%s: unknown cksum type %x\n", obd_name, cksum_type);
+
+	return flag;
+}
+EXPORT_SYMBOL(obd_cksum_type_pack);
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index c430239..9ac9c84 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1030,6 +1030,105 @@ static inline int can_merge_pages(struct brw_page *p1, struct brw_page *p2)
 	return (p1->off + p1->count == p2->off);
 }
 
+static int osc_checksum_bulk_t10pi(const char *obd_name, int nob,
+				   size_t pg_count, struct brw_page **pga,
+				   int opc, obd_dif_csum_fn *fn,
+				   int sector_size,
+				   u32 *check_sum)
+{
+	struct ahash_request *hdesc;
+	/* Used Adler as the default checksum type on top of DIF tags */
+	unsigned char cfs_alg = cksum_obd2cfs(OBD_CKSUM_T10_TOP);
+	struct page *__page;
+	unsigned char *buffer;
+	u16 *guard_start;
+	unsigned int bufsize;
+	int guard_number;
+	int used_number = 0;
+	int used;
+	u32 cksum;
+	int rc = 0;
+	int i = 0;
+
+	LASSERT(pg_count > 0);
+
+	__page = alloc_page(GFP_KERNEL);
+	if (!__page)
+		return -ENOMEM;
+
+	hdesc = cfs_crypto_hash_init(cfs_alg, NULL, 0);
+	if (IS_ERR(hdesc)) {
+		rc = PTR_ERR(hdesc);
+		CERROR("%s: unable to initialize checksum hash %s: rc = %d\n",
+		       obd_name, cfs_crypto_hash_name(cfs_alg), rc);
+		goto out;
+	}
+
+	buffer = kmap(__page);
+	guard_start = (u16 *)buffer;
+	guard_number = PAGE_SIZE / sizeof(*guard_start);
+	while (nob > 0 && pg_count > 0) {
+		unsigned int count = pga[i]->count > nob ? nob : pga[i]->count;
+
+		/* corrupt the data before we compute the checksum, to
+		 * simulate an OST->client data error
+		 */
+		if (unlikely(i == 0 && opc == OST_READ &&
+			     OBD_FAIL_CHECK(OBD_FAIL_OSC_CHECKSUM_RECEIVE))) {
+			unsigned char *ptr = kmap(pga[i]->pg);
+			int off = pga[i]->off & ~PAGE_MASK;
+
+			memcpy(ptr + off, "bad1", min_t(typeof(nob), 4, nob));
+			kunmap(pga[i]->pg);
+		}
+
+		/*
+		 * The left guard number should be able to hold checksums of a
+		 * whole page
+		 */
+		rc = obd_page_dif_generate_buffer(obd_name, pga[i]->pg, 0,
+						  count,
+						  guard_start + used_number,
+						  guard_number - used_number,
+						  &used, sector_size,
+						  fn);
+		if (rc)
+			break;
+
+		used_number += used;
+		if (used_number == guard_number) {
+			cfs_crypto_hash_update_page(hdesc, __page, 0,
+				used_number * sizeof(*guard_start));
+			used_number = 0;
+		}
+
+		nob -= pga[i]->count;
+		pg_count--;
+		i++;
+	}
+	kunmap(__page);
+	if (rc)
+		goto out;
+
+	if (used_number != 0)
+		cfs_crypto_hash_update_page(hdesc, __page, 0,
+			used_number * sizeof(*guard_start));
+
+	bufsize = sizeof(cksum);
+	cfs_crypto_hash_final(hdesc, (unsigned char *)&cksum, &bufsize);
+
+	/* For sending we only compute the wrong checksum instead
+	 * of corrupting the data so it is still correct on a redo
+	 */
+	if (opc == OST_WRITE && OBD_FAIL_CHECK(OBD_FAIL_OSC_CHECKSUM_SEND))
+		cksum++;
+
+	*check_sum = cksum;
+out:
+	__free_page(__page);
+	return rc;
+}
+
 static int osc_checksum_bulk(int nob, u32 pg_count,
 			     struct brw_page **pga, int opc,
 			     enum cksum_type cksum_type,
@@ -1090,6 +1189,28 @@ static int osc_checksum_bulk(int nob, u32 pg_count,
 	return 0;
 }
 
+static int osc_checksum_bulk_rw(const char *obd_name,
+				enum cksum_type cksum_type,
+				int nob, size_t pg_count,
+				struct brw_page **pga, int opc,
+				u32 *check_sum)
+{
+	obd_dif_csum_fn *fn = NULL;
+	int sector_size = 0;
+	int rc;
+
+	obd_t10_cksum2dif(cksum_type, &fn, &sector_size);
+
+	if (fn)
+		rc = osc_checksum_bulk_t10pi(obd_name, nob, pg_count, pga,
+					     opc, fn, sector_size, check_sum);
+	else
+		rc = osc_checksum_bulk(nob, pg_count, pga, opc, cksum_type,
+				       check_sum);
+
+	return rc;
+}
+
 static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 				struct obdo *oa, u32 page_count,
 				struct brw_page **pga,
@@ -1107,6 +1228,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	struct req_capsule *pill;
 	struct brw_page *pg_prev;
 	void *short_io_buf;
+	const char *obd_name = cli->cl_import->imp_obd->obd_name;
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_BRW_PREP_REQ))
 		return -ENOMEM; /* Recoverable */
@@ -1306,12 +1428,14 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 			if ((body->oa.o_valid & OBD_MD_FLFLAGS) == 0)
 				body->oa.o_flags = 0;
 
-			body->oa.o_flags |= cksum_type_pack(cksum_type);
+			body->oa.o_flags |= obd_cksum_type_pack(obd_name,
+								cksum_type);
 			body->oa.o_valid |= OBD_MD_FLCKSUM | OBD_MD_FLFLAGS;
 
-			rc = osc_checksum_bulk(requested_nob, page_count,
-					       pga, OST_WRITE, cksum_type,
-					       &body->oa.o_cksum);
+			rc = osc_checksum_bulk_rw(obd_name, cksum_type,
+						  requested_nob, page_count,
+						  pga, OST_WRITE,
+						  &body->oa.o_cksum);
 			if (rc < 0) {
 				CDEBUG(D_PAGE, "failed to checksum, rc = %d\n",
 				       rc);
@@ -1322,7 +1446,8 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 
 			/* save this in 'oa', too, for later checking */
 			oa->o_valid |= OBD_MD_FLCKSUM | OBD_MD_FLFLAGS;
-			oa->o_flags |= cksum_type_pack(cksum_type);
+			oa->o_flags |= obd_cksum_type_pack(obd_name,
+							   cksum_type);
 		} else {
 			/* clear out the checksum flag, in case this is a
 			 * resend but cl_checksum is no longer set. b=11238
@@ -1338,7 +1463,8 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 		    !sptlrpc_flavor_has_bulk(&req->rq_flvr)) {
 			if ((body->oa.o_valid & OBD_MD_FLFLAGS) == 0)
 				body->oa.o_flags = 0;
-			body->oa.o_flags |= cksum_type_pack(cli->cl_cksum_type);
+			body->oa.o_flags |= obd_cksum_type_pack(obd_name,
+				cli->cl_cksum_type);
 			body->oa.o_valid |= OBD_MD_FLCKSUM | OBD_MD_FLFLAGS;
 		}
 
@@ -1441,6 +1567,10 @@ static int check_write_checksum(struct obdo *oa,
 				u32 client_cksum, u32 server_cksum,
 				struct osc_brw_async_args *aa)
 {
+	const char *obd_name = aa->aa_cli->cl_import->imp_obd->obd_name;
+	obd_dif_csum_fn *fn = NULL;
+	int sector_size = 0;
+	bool t10pi = false;
 	u32 new_cksum;
 	char *msg;
 	enum cksum_type cksum_type;
@@ -1455,15 +1585,50 @@ static int check_write_checksum(struct obdo *oa,
 		dump_all_bulk_pages(oa, aa->aa_page_count, aa->aa_ppga,
 				    server_cksum, client_cksum);
 
-	cksum_type = cksum_type_unpack(oa->o_valid & OBD_MD_FLFLAGS ?
-				       oa->o_flags : 0);
-	rc = osc_checksum_bulk(aa->aa_requested_nob, aa->aa_page_count,
-			       aa->aa_ppga, OST_WRITE, cksum_type,
-			       &new_cksum);
+	cksum_type = obd_cksum_type_unpack(oa->o_valid & OBD_MD_FLFLAGS ?
+					   oa->o_flags : 0);
+
+	switch (cksum_type) {
+	case OBD_CKSUM_T10IP512:
+		t10pi = true;
+		fn = obd_dif_ip_fn;
+		sector_size = 512;
+		break;
+	case OBD_CKSUM_T10IP4K:
+		t10pi = true;
+		fn = obd_dif_ip_fn;
+		sector_size = 4096;
+		break;
+	case OBD_CKSUM_T10CRC512:
+		t10pi = true;
+		fn = obd_dif_crc_fn;
+		sector_size = 512;
+		break;
+	case OBD_CKSUM_T10CRC4K:
+		t10pi = true;
+		fn = obd_dif_crc_fn;
+		sector_size = 4096;
+		break;
+	default:
+		break;
+	}
+
+	if (t10pi)
+		rc = osc_checksum_bulk_t10pi(obd_name, aa->aa_requested_nob,
+					     aa->aa_page_count,
+					     aa->aa_ppga,
+					     OST_WRITE,
+					     fn,
+					     sector_size,
+					     &new_cksum);
+	else
+		rc = osc_checksum_bulk(aa->aa_requested_nob, aa->aa_page_count,
+				       aa->aa_ppga, OST_WRITE, cksum_type,
+				       &new_cksum);
 
 	if (rc < 0)
 		msg = "failed to calculate the client write checksum";
-	else if (cksum_type != cksum_type_unpack(aa->aa_oa->o_flags))
+	else if (cksum_type != obd_cksum_type_unpack(aa->aa_oa->o_flags))
 		msg = "the server did not use the checksum type specified in the original request - likely a protocol problem";
 	else if (new_cksum == server_cksum)
 		msg = "changed on the client after we checksummed it - likely false positive due to mmap IO (bug 11742)";
@@ -1474,15 +1639,15 @@ static int check_write_checksum(struct obdo *oa,
 
 	LCONSOLE_ERROR_MSG(0x132,
 			   "%s: BAD WRITE CHECKSUM: %s: from %s inode " DFID " object " DOSTID " extent [%llu-%llu], original client csum %x (type %x), server csum %x (type %x), client csum now %x\n",
-			   aa->aa_cli->cl_import->imp_obd->obd_name,
-			   msg, libcfs_nid2str(peer->nid),
+			   obd_name, msg, libcfs_nid2str(peer->nid),
 			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_seq : (u64)0,
 			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_oid : 0,
 			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_ver : 0,
 			   POSTID(&oa->o_oi), aa->aa_ppga[0]->off,
 			   aa->aa_ppga[aa->aa_page_count - 1]->off +
 			   aa->aa_ppga[aa->aa_page_count - 1]->count - 1,
-			   client_cksum, cksum_type_unpack(aa->aa_oa->o_flags),
+			   client_cksum,
+			   obd_cksum_type_unpack(aa->aa_oa->o_flags),
 			   server_cksum, cksum_type, new_cksum);
 
 	return 1;
@@ -1495,6 +1660,7 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 	const struct lnet_process_id *peer =
 			&req->rq_import->imp_connection->c_peer;
 	struct client_obd *cli = aa->aa_cli;
+	const char *obd_name = cli->cl_import->imp_obd->obd_name;
 	struct ost_body *body;
 	u32 client_cksum = 0;
 
@@ -1619,17 +1785,17 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 		char *via = "";
 		char *router = "";
 		enum cksum_type cksum_type;
+		u32 o_flags = body->oa.o_valid & OBD_MD_FLFLAGS ?
+			body->oa.o_flags : 0;
 
-		cksum_type = cksum_type_unpack(body->oa.o_valid & OBD_MD_FLFLAGS ?
-					       body->oa.o_flags : 0);
+		cksum_type = obd_cksum_type_unpack(o_flags);
 
-		rc = osc_checksum_bulk(rc, aa->aa_page_count, aa->aa_ppga,
-				       OST_READ, cksum_type, &client_cksum);
-		if (rc < 0) {
-			CDEBUG(D_PAGE,
-			       "failed to calculate checksum, rc = %d\n", rc);
+		rc = osc_checksum_bulk_rw(obd_name, cksum_type, rc,
+					  aa->aa_page_count, aa->aa_ppga,
+					  OST_READ, &client_cksum);
+		if (rc < 0)
 			goto out;
-		}
+
 		if (req->rq_bulk &&
 		    peer->nid != req->rq_bulk->bd_sender) {
 			via = " via ";
@@ -1652,7 +1818,7 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 				"%s: BAD READ CHECKSUM: from %s%s%s inode " DFID
 				" object " DOSTID
 				" extent [%llu-%llu], client %x, server %x, cksum_type %x\n",
-				req->rq_import->imp_obd->obd_name,
+				obd_name,
 				libcfs_nid2str(peer->nid),
 				via, router,
 				clbody->oa.o_valid & OBD_MD_FLFID ?
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 5d6546d..019648b 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -786,11 +786,12 @@ static int ptlrpc_connect_set_flags(struct obd_import *imp,
 		 * for algorithms we understand. The server masked off
 		 * the checksum types it doesn't support
 		 */
-		if (!(ocd->ocd_cksum_types & cksum_types_supported_client())) {
+		if (!(ocd->ocd_cksum_types &
+		      obd_cksum_types_supported_client())) {
 			LCONSOLE_ERROR("The negotiation of the checksum algorithm to use with server %s failed (%x/%x), disabling checksums\n",
 				      obd2cli_tgt(imp->imp_obd),
 				      ocd->ocd_cksum_types,
-				      cksum_types_supported_client());
+				      obd_cksum_types_supported_client());
 			return -EPROTO;
 		}
 		cli->cl_supp_cksum_types = ocd->ocd_cksum_types;
@@ -801,7 +802,8 @@ static int ptlrpc_connect_set_flags(struct obd_import *imp,
 		 */
 		cli->cl_supp_cksum_types = OBD_CKSUM_ADLER;
 	}
-	cli->cl_cksum_type = cksum_type_select(cli->cl_supp_cksum_types);
+	cli->cl_cksum_type = obd_cksum_type_select(imp->imp_obd->obd_name,
+						   cli->cl_supp_cksum_types);
 
 	if (ocd->ocd_connect_flags & OBD_CONNECT_BRW_SIZE)
 		cli->cl_max_pages_per_rpc =
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index c566dea..01ddbee 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1123,6 +1123,18 @@ void lustre_assert_wire_constants(void)
 		 (unsigned int)OBD_CKSUM_ADLER);
 	LASSERTF(OBD_CKSUM_CRC32C == 0x00000004UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32C);
+	LASSERTF(OBD_CKSUM_RESERVED == 0x00000008UL, "found 0x%.8xUL\n",
+		(unsigned int)OBD_CKSUM_RESERVED);
+	LASSERTF(OBD_CKSUM_T10IP512 == 0x00000010UL, "found 0x%.8xUL\n",
+		(unsigned int)OBD_CKSUM_T10IP512);
+	LASSERTF(OBD_CKSUM_T10IP4K == 0x00000020UL, "found 0x%.8xUL\n",
+		(unsigned int)OBD_CKSUM_T10IP4K);
+	LASSERTF(OBD_CKSUM_T10CRC512 == 0x00000040UL, "found 0x%.8xUL\n",
+		(unsigned int)OBD_CKSUM_T10CRC512);
+	LASSERTF(OBD_CKSUM_T10CRC4K == 0x00000080UL, "found 0x%.8xUL\n",
+		(unsigned int)OBD_CKSUM_T10CRC4K);
+	LASSERTF(OBD_CKSUM_T10_TOP == 0x00000002UL, "found 0x%.8xUL\n",
+		(unsigned int)OBD_CKSUM_T10_TOP);
 
 	/* Checks for struct ost_layout */
 	LASSERTF((int)sizeof(struct ost_layout) == 28, "found %lld\n",
@@ -1372,7 +1384,10 @@ void lustre_assert_wire_constants(void)
 	BUILD_BUG_ON(OBD_FL_CKSUM_CRC32 != 0x00001000);
 	BUILD_BUG_ON(OBD_FL_CKSUM_ADLER != 0x00002000);
 	BUILD_BUG_ON(OBD_FL_CKSUM_CRC32C != 0x00004000);
-	BUILD_BUG_ON(OBD_FL_CKSUM_RSVD2 != 0x00008000);
+	BUILD_BUG_ON(OBD_FL_CKSUM_T10IP512 != 0x00005000);
+	BUILD_BUG_ON(OBD_FL_CKSUM_T10IP4K != 0x00006000);
+	BUILD_BUG_ON(OBD_FL_CKSUM_T10CRC512 != 0x00007000);
+	BUILD_BUG_ON(OBD_FL_CKSUM_T10CRC4K != 0x00008000);
 	BUILD_BUG_ON(OBD_FL_CKSUM_RSVD3 != 0x00010000);
 	BUILD_BUG_ON(OBD_FL_SHRINK_GRANT != 0x00020000);
 	BUILD_BUG_ON(OBD_FL_MMAP != 0x00040000);
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 7cf7307..11df7b4 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -883,15 +883,37 @@ struct obd_connect_data {
 /*
  * Supported checksum algorithms. Up to 32 checksum types are supported.
  * (32-bit mask stored in obd_connect_data::ocd_cksum_types)
- * Please update DECLARE_CKSUM_NAME/OBD_CKSUM_ALL in obd.h when adding a new
- * algorithm and also the OBD_FL_CKSUM* flags.
+ * Please update DECLARE_CKSUM_NAME in obd_cksum.h when adding a new
+ * algorithm and also the OBD_FL_CKSUM* flags, OBD_CKSUM_ALL flag,
+ * OBD_FL_CKSUM_ALL flag and potentially OBD_CKSUM_T10_ALL flag.
  */
 enum cksum_type {
-	OBD_CKSUM_CRC32  = 0x00000001,
-	OBD_CKSUM_ADLER  = 0x00000002,
-	OBD_CKSUM_CRC32C = 0x00000004,
+	OBD_CKSUM_CRC32		= 0x00000001,
+	OBD_CKSUM_ADLER		= 0x00000002,
+	OBD_CKSUM_CRC32C	= 0x00000004,
+	OBD_CKSUM_RESERVED	= 0x00000008,
+	OBD_CKSUM_T10IP512	= 0x00000010,
+	OBD_CKSUM_T10IP4K	= 0x00000020,
+	OBD_CKSUM_T10CRC512	= 0x00000040,
+	OBD_CKSUM_T10CRC4K	= 0x00000080,
 };
 
+#define OBD_CKSUM_T10_ALL (OBD_CKSUM_T10IP512 | OBD_CKSUM_T10IP4K | \
+	OBD_CKSUM_T10CRC512 | OBD_CKSUM_T10CRC4K)
+
+#define OBD_CKSUM_ALL (OBD_CKSUM_CRC32 | OBD_CKSUM_ADLER | OBD_CKSUM_CRC32C | \
+		       OBD_CKSUM_T10_ALL)
+
+/*
+ * The default checksum algorithm used on top of T10PI GRD tags for RPC.
+ * Considering that the checksum-of-checksums is only computing CRC32 on a
+ * 4KB chunk of GRD tags for a 1MB RPC for 512B sectors, or 16KB of GRD
+ * tags for 16MB of 4KB sectors, this is only 1/256 or 1/1024 of the
+ * total data being checksummed, so the checksum type used here should not
+ * affect overall system performance noticeably.
+ */
+#define OBD_CKSUM_T10_TOP OBD_CKSUM_ADLER
+
 /*
  *   OST requests: OBDO & OBD request records
  */
@@ -940,7 +962,10 @@ enum obdo_flags {
 	OBD_FL_CKSUM_CRC32	= 0x00001000, /* CRC32 checksum type */
 	OBD_FL_CKSUM_ADLER	= 0x00002000, /* ADLER checksum type */
 	OBD_FL_CKSUM_CRC32C	= 0x00004000, /* CRC32C checksum type */
-	OBD_FL_CKSUM_RSVD2	= 0x00008000, /* for future cksum types */
+	OBD_FL_CKSUM_T10IP512	= 0x00005000, /* T10PI IP cksum, 512B sector */
+	OBD_FL_CKSUM_T10IP4K	= 0x00006000, /* T10PI IP cksum, 4KB sector */
+	OBD_FL_CKSUM_T10CRC512	= 0x00007000, /* T10PI CRC cksum, 512B sector */
+	OBD_FL_CKSUM_T10CRC4K	= 0x00008000, /* T10PI CRC cksum, 4KB sector */
 	OBD_FL_CKSUM_RSVD3	= 0x00010000, /* for future cksum types */
 	OBD_FL_SHRINK_GRANT	= 0x00020000, /* object shrink the grant */
 	OBD_FL_MMAP		= 0x00040000, /* object is mmapped on the client.
@@ -953,11 +978,16 @@ enum obdo_flags {
 	OBD_FL_SHORT_IO		= 0x00400000, /* short io request */
 	/* OBD_FL_LOCAL_MASK = 0xF0000000, was local-only flags until 2.10 */
 
-	/* Note that while these checksum values are currently separate bits,
-	 * in 2.x we can actually allow all values from 1-31 if we wanted.
+	/*
+	 * Note that while the original checksum values were separate bits,
+	 * in 2.x we can actually allow all values from 1-31. T10-PI checksum
+	 * types already use values which are not separate bits.
 	 */
 	OBD_FL_CKSUM_ALL	= (OBD_FL_CKSUM_CRC32 | OBD_FL_CKSUM_ADLER |
-				   OBD_FL_CKSUM_CRC32C),
+				   OBD_FL_CKSUM_CRC32C | OBD_FL_CKSUM_T10IP512 |
+				   OBD_FL_CKSUM_T10IP4K |
+				   OBD_FL_CKSUM_T10CRC512 |
+				   OBD_FL_CKSUM_T10CRC4K),
 };
 
 /*
diff --git a/net/lnet/libcfs/linux-crypto.c b/net/lnet/libcfs/linux-crypto.c
index 53285c2..532fab4 100644
--- a/net/lnet/libcfs/linux-crypto.c
+++ b/net/lnet/libcfs/linux-crypto.c
@@ -318,6 +318,9 @@ int cfs_crypto_hash_final(struct ahash_request *req,
  * The speed is stored internally in the cfs_crypto_hash_speeds[] array, and
  * is available through the cfs_crypto_hash_speed() function.
  *
+ * This function needs to stay the same as obd_t10_performance_test() so that
+ * the speeds are comparable.
+ *
  * @hash_alg	hash algorithm id (CFS_HASH_ALG_*)
  * @buf		data buffer on which to compute the hash
  * @buf_len	length of @buf on which to compute hash
-- 
1.8.3.1
