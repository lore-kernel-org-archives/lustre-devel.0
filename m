From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:20 -0500
Subject: [lustre-devel] [PATCH 572/622] lustre: sysfs: use string helper
 like functions for sysfs
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-573-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

For a very long time the Linux kernel has supported the function
memparse() that allowed the passing in of memory sizes with the
suffix set of K, M, G, T, P, E. Lustre adopted this approach
with its proc / sysfs implementation. The difference being that
lustre expanded this functionality to allow sizes with a
fractional component, such as 1.5G for example. The code used to
parse for the numerical value is heavily tied into the debugfs
seq_file handling and stomps on the passed in buffer which you
can't do with sysfs files.

Similar functionality to what Lustre does today exist in newer
linux kernels in the form of string helpers. Currently the
string helpers only convert a numerical value to human readable
format. A new function, string_to_size(), was created that takes
a string and turns it into a numerical value. This enables the
use of string helper suffixes i.e MiB, kB etc with the lustre
tunables and we can now support 10 base numbers i.e MB, kB as
well. Already string helper suffixes are used for debugfs files
so I expect this to be adopted over time so it should be
encouraged to use string_to_size() for newer lustre sysfs files.

At the same time we want to perserve the original behavior of
using the suffix set of K, M, G, T, P, E. To do this we create
the function sysfs_memparse() that supports the new string helper
suffixes as well as the older set of suffixes. This new code is
also way simpler than what is currently done with the current code.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9091
Lustre-commit: d9e0c9f346d0 ("LU-9091 sysfs: use string helper like functions for sysfs")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/35658
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/include/lprocfs_status.h  |   4 +
 fs/lustre/lov/lproc_lov.c           |   4 +-
 fs/lustre/mdc/lproc_mdc.c           |  27 +++---
 fs/lustre/obdclass/class_obd.c      |  61 ++++++++++++
 fs/lustre/obdclass/lprocfs_status.c | 179 ++++++++++++++++++++++++++++++++++++
 fs/lustre/osc/lproc_osc.c           |  27 ++----
 6 files changed, 271 insertions(+), 31 deletions(-)

diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index ac62560..22d7741 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -42,6 +42,7 @@
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
 #include <linux/spinlock.h>
+#include <linux/string_helpers.h>
 #include <linux/types.h>
 #include <linux/device.h>
 
@@ -484,6 +485,9 @@ int lprocfs_write_u64_helper(const char __user *buffer,
 int lprocfs_write_frac_u64_helper(const char __user *buffer,
 				  unsigned long count,
 				  u64 *val, int mult);
+int string_to_size(u64 *size, const char *buffer, size_t count);
+int sysfs_memparse(const char *buffer, size_t count, u64 *val,
+		    const char *defunit);
 char *lprocfs_find_named_value(const char *buffer, const char *name,
 			       size_t *count);
 void lprocfs_oh_tally(struct obd_histogram *oh, unsigned int value);
diff --git a/fs/lustre/lov/lproc_lov.c b/fs/lustre/lov/lproc_lov.c
index c528a8b..37ef084 100644
--- a/fs/lustre/lov/lproc_lov.c
+++ b/fs/lustre/lov/lproc_lov.c
@@ -57,8 +57,8 @@ static ssize_t stripesize_store(struct kobject *kobj, struct attribute *attr,
 	u64 val;
 	int rc;
 
-	rc = kstrtoull(buf, 10, &val);
-	if (rc)
+	rc = sysfs_memparse(buf, count, &val, "B");
+	if (rc < 0)
 		return rc;
 
 	lov_fix_desc_stripe_size(&val);
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index 454b69d..c438198 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -61,12 +61,19 @@ static ssize_t mdc_max_dirty_mb_seq_write(struct file *file,
 	struct seq_file *sfl = file->private_data;
 	struct obd_device *dev = sfl->private;
 	struct client_obd *cli = &dev->u.cli;
-	__s64 pages_number;
+	char kernbuf[22] = "";
+	u64 pages_number;
 	int rc;
 
-	rc = lprocfs_write_frac_u64_helper(buffer, count, &pages_number,
-					   1 << (20 - PAGE_SHIFT));
-	if (rc)
+	if (count >= sizeof(kernbuf))
+		return -EINVAL;
+
+	if (copy_from_user(kernbuf, buffer, count))
+		return -EFAULT;
+	kernbuf[count] = 0;
+
+	rc = sysfs_memparse(kernbuf, count, &pages_number, "MiB");
+	if (rc < 0)
 		return rc;
 
 	/* MB -> pages */
@@ -111,6 +118,7 @@ static int mdc_cached_mb_seq_show(struct seq_file *m, void *v)
 	struct obd_device *dev = sfl->private;
 	struct client_obd *cli = &dev->u.cli;
 	u64 pages_number;
+	const char *tmp;
 	long rc;
 	char kernbuf[128];
 
@@ -121,18 +129,13 @@ static int mdc_cached_mb_seq_show(struct seq_file *m, void *v)
 		return -EFAULT;
 	kernbuf[count] = 0;
 
-	buffer += lprocfs_find_named_value(kernbuf, "used_mb:", &count) -
-		  kernbuf;
-	rc = lprocfs_write_frac_u64_helper(buffer, count, &pages_number,
-					   1 << (20 - PAGE_SHIFT));
-	if (rc)
+	tmp = lprocfs_find_named_value(kernbuf, "used_mb:", &count);
+	rc = sysfs_memparse(tmp, count, &pages_number, "MiB");
+	if (rc < 0)
 		return rc;
 
 	pages_number >>= PAGE_SHIFT;
 
-	if (pages_number < 0)
-		return -ERANGE;
-
 	rc = atomic_long_read(&cli->cl_lru_in_list) - pages_number;
 	if (rc > 0) {
 		struct lu_env *env;
diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index 0718fdb..d462317 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -524,6 +524,20 @@ static long obd_class_ioctl(struct file *filp, unsigned int cmd,
 	.fops		= &obd_psdev_fops,
 };
 
+#define test_string_to_size_one(value, result, def_unit)		\
+({									\
+	u64 __size;							\
+	int __ret;							\
+									\
+	BUILD_BUG_ON(strlen(value) >= 23);				\
+	__ret = sysfs_memparse((value), (result), &__size,		\
+			       (def_unit));				\
+	if (__ret == 0 && (u64)result != __size)			\
+		CERROR("string_helper: size %llu != result %llu\n",	\
+		       __size, (u64)result);				\
+	__ret;								\
+})
+
 static int obd_init_checks(void)
 {
 	u64 u64val, div64val;
@@ -590,6 +604,53 @@ static int obd_init_checks(void)
 		ret = -EINVAL;
 	}
 
+	/* invalid string */
+	ret = test_string_to_size_one("256B34", 256, "B");
+	if (ret == 0)
+		CERROR("string_helpers: format should be number then units\n");
+	ret = test_string_to_size_one("132OpQ", 132, "B");
+	if (ret == 0)
+		CERROR("string_helpers: invalid units should be rejected\n");
+	ret = 0;
+
+	/* small values */
+	test_string_to_size_one("0B", 0, "B");
+	ret = test_string_to_size_one("1.82B", 1, "B");
+	if (ret == 0)
+		CERROR("string_helpers: number string with 'B' and '.' should be invalid\n");
+	ret = 0;
+	test_string_to_size_one("512B", 512, "B");
+	test_string_to_size_one("1.067kB", 1067, "B");
+	test_string_to_size_one("1.042KiB", 1067, "B");
+
+	/* Lustre special handling */
+	test_string_to_size_one("16", 16777216, "MiB");
+	test_string_to_size_one("65536", 65536, "B");
+	test_string_to_size_one("128K", 131072, "B");
+	test_string_to_size_one("1M", 1048576, "B");
+	test_string_to_size_one("256.5G", 275414777856ULL, "GiB");
+
+	/* normal values */
+	test_string_to_size_one("8.39MB", 8390000, "MiB");
+	test_string_to_size_one("8.00MiB", 8388608, "MiB");
+	test_string_to_size_one("256GB", 256000000, "GiB");
+	test_string_to_size_one("238.731 GiB", 256335459385ULL, "GiB");
+
+	/* huge values */
+	test_string_to_size_one("0.4TB", 400000000000ULL, "TiB");
+	test_string_to_size_one("12.5TiB", 13743895347200ULL, "TiB");
+	test_string_to_size_one("2PB", 2000000000000000ULL, "PiB");
+	test_string_to_size_one("16PiB", 18014398509481984ULL, "PiB");
+
+	/* huge values should overflow */
+	ret = test_string_to_size_one("1000EiB", 0, "EiB");
+	if (ret != -EOVERFLOW)
+		CERROR("string_helpers: Failed to detect overflow\n");
+	ret = test_string_to_size_one("1000EB", 0, "EiB");
+	if (ret != -EOVERFLOW)
+		CERROR("string_helpers: Failed to detect overflow\n");
+	ret = 0;
+
 	return ret;
 }
 
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 4fc35c5..325005d 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -217,6 +217,185 @@ static void obd_connect_data_seqprint(struct seq_file *m,
 			   ocd->ocd_maxmodrpcs);
 }
 
+/**
+ * string_to_size - convert ASCII string representing a numerical
+ *		    value with optional units to 64-bit binary value
+ *
+ * @size:	The numerical value extract out of @buffer
+ * @buffer:	passed in string to parse
+ * @count:	length of the @buffer
+ *
+ * This function returns a 64-bit binary value if @buffer contains a valid
+ * numerical string. The string is parsed to 3 significant figures after
+ * the decimal point. Support the string containing an optional units at
+ * the end which can be base 2 or base 10 in value. If no units are given
+ * the string is assumed to just a numerical value.
+ *
+ * Returns:	@count if the string is successfully parsed,
+ *		-errno on invalid input strings. Error values:
+ *
+ *  - ``-EINVAL``: @buffer is not a proper numerical string
+ *  - ``-EOVERFLOW``: results does not fit into 64 bits.
+ *  - ``-E2BIG ``: @buffer is not large
+ */
+int string_to_size(u64 *size, const char *buffer, size_t count)
+{
+	/* For string_get_size() it can support values above exabytes,
+	 * (ZiB, YiB) due to breaking the return value into a size and
+	 * bulk size to avoid 64 bit overflow. We don't break the size
+	 * up into block size units so we don't support ZiB or YiB.
+	 */
+	static const char *const units_10[] = {
+		"kB", "MB", "GB", "TB", "PB", "EB"
+	};
+	static const char *const units_2[] = {
+		"KiB", "MiB", "GiB", "TiB", "PiB", "EiB"
+	};
+	static const char *const *const units_str[] = {
+		[STRING_UNITS_2] = units_2,
+		[STRING_UNITS_10] = units_10,
+	};
+	static const unsigned int coeff[] = {
+		[STRING_UNITS_10] = 1000,
+		[STRING_UNITS_2] = 1024,
+	};
+	enum string_size_units unit;
+	u64 whole, blk_size = 1;
+	char kernbuf[22], *end;
+	size_t len = count;
+	int rc;
+	int i;
+
+	if (count >= sizeof(kernbuf))
+		return -E2BIG;
+
+	*size = 0;
+	/* 'iB' is used for based 2 numbers. If @buffer contains only a 'B'
+	 * or only numbers then we treat it as a direct number which doesn't
+	 * matter if its STRING_UNITS_2 or STRING_UNIT_10.
+	 */
+	unit = strstr(buffer, "iB") ? STRING_UNITS_2 : STRING_UNITS_10;
+	i = unit == STRING_UNITS_2 ? ARRAY_SIZE(units_2) - 1 :
+				     ARRAY_SIZE(units_10) - 1;
+	do {
+		end = strstr(buffer, units_str[unit][i]);
+		if (end) {
+			for (; i >= 0; i--)
+				blk_size *= coeff[unit];
+			len -= strlen(end);
+			break;
+		}
+	} while (i--);
+
+	/* as 'B' is a substring of all units, we need to handle it
+	 * separately.
+	 */
+	if (!end) {
+		/* 'B' is only acceptable letter at this point */
+		end = strchr(buffer, 'B');
+		if (end) {
+			len -= strlen(end);
+
+			if (count - len > 2 ||
+			    (count - len == 2 && strcmp(end, "B\n") != 0))
+				return -EINVAL;
+		}
+		/* kstrtoull will error out if it has non digits */
+		goto numbers_only;
+	}
+
+	end = strchr(buffer, '.');
+	if (end) {
+		/* need to limit 3 decimal places */
+		char rem[4] = "000";
+		u64 frac = 0;
+		size_t off;
+
+		len = end - buffer;
+		end++;
+
+		/* limit to 3 decimal points */
+		off = min_t(size_t, 3, strspn(end, "0123456789"));
+		/* need to limit frac_d to a u32 */
+		memcpy(rem, end, off);
+		rc = kstrtoull(rem, 10, &frac);
+		if (rc)
+			return rc;
+
+		if (fls64(frac) + fls64(blk_size) - 1 > 64)
+			return -EOVERFLOW;
+
+		frac *= blk_size;
+		do_div(frac, 1000);
+		*size += frac;
+	}
+numbers_only:
+	snprintf(kernbuf, sizeof(kernbuf), "%.*s", (int)len, buffer);
+	rc = kstrtoull(kernbuf, 10, &whole);
+	if (rc)
+		return rc;
+
+	if (whole != 0 && fls64(whole) + fls64(blk_size) - 1 > 64)
+		return -EOVERFLOW;
+
+	*size += whole * blk_size;
+
+	return count;
+}
+EXPORT_SYMBOL(string_to_size);
+
+/**
+ * sysfs_memparse - parse a ASCII string to 64-bit binary value,
+ *		    with optional units
+ *
+ * @buffer:	kernel pointer to input string
+ * @count:	number of bytes in the input @buffer
+ * @val:	(output) binary value returned to caller
+ * @defunit:	default unit suffix to use if none is provided
+ *
+ * Parses a string into a number. The number stored at @buffer is
+ * potentially suffixed with K, M, G, T, P, E. Besides these other
+ * valid suffix units are shown in the string_to_size() function.
+ * If the string lacks a suffix then the defunit is used. The defunit
+ * should be given as a binary unit (e.g. MiB) as that is the standard
+ * for tunables in Lustre. If no unit suffix is given (e.g. 'G'), then
+ * it is assumed to be in binary units.
+ *
+ * Returns:	0 on success or -errno on failure.
+ */
+int sysfs_memparse(const char *buffer, size_t count, u64 *val,
+		   const char *defunit)
+{
+	char param[23];
+	int rc;
+
+	if (count >= sizeof(param))
+		return -E2BIG;
+
+	count = strlen(buffer);
+	if (count && buffer[count - 1] == '\n')
+		count--;
+
+	if (!count)
+		return -EINVAL;
+
+	if (isalpha(buffer[count - 1])) {
+		if (buffer[count - 1] != 'B') {
+			scnprintf(param, sizeof(param), "%.*siB",
+				  (int)count, buffer);
+		} else {
+			memcpy(param, buffer, count + 1);
+		}
+	} else {
+		scnprintf(param, sizeof(param), "%.*s%s", (int)count,
+			  buffer, defunit);
+	}
+
+	rc = string_to_size(val, param, strlen(param));
+	return rc < 0 ? rc : 0;
+}
+EXPORT_SYMBOL(sysfs_memparse);
+
 int lprocfs_read_frac_helper(char *buffer, unsigned long count, long val,
 			     int mult)
 {
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index d545d1b..5cf2148 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -203,10 +203,10 @@ static ssize_t osc_cached_mb_seq_write(struct file *file,
 	struct seq_file *m = file->private_data;
 	struct obd_device *dev = m->private;
 	struct client_obd *cli = &dev->u.cli;
-	long pages_number, rc;
+	u64 pages_number;
+	const char *tmp;
+	long rc;
 	char kernbuf[128];
-	int mult;
-	u64 val;
 
 	if (count >= sizeof(kernbuf))
 		return -EINVAL;
@@ -215,19 +215,12 @@ static ssize_t osc_cached_mb_seq_write(struct file *file,
 		return -EFAULT;
 	kernbuf[count] = 0;
 
-	mult = 1 << (20 - PAGE_SHIFT);
-	buffer += lprocfs_find_named_value(kernbuf, "used_mb:", &count) -
-		  kernbuf;
-	rc = lprocfs_write_frac_u64_helper(buffer, count, &val, mult);
-	if (rc)
+	tmp = lprocfs_find_named_value(kernbuf, "used_mb:", &count);
+	rc = sysfs_memparse(tmp, count, &pages_number, "MiB");
+	if (rc < 0)
 		return rc;
 
-	if (val > LONG_MAX)
-		return -ERANGE;
-	pages_number = (long)val;
-
-	if (pages_number < 0)
-		return -ERANGE;
+	pages_number >>= PAGE_SHIFT;
 
 	rc = atomic_long_read(&cli->cl_lru_in_list) - pages_number;
 	if (rc > 0) {
@@ -277,11 +270,11 @@ static ssize_t cur_grant_bytes_store(struct kobject *kobj,
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 	struct client_obd *cli = &obd->u.cli;
+	u64 val;
 	int rc;
-	unsigned long long val;
 
-	rc = kstrtoull(buffer, 10, &val);
-	if (rc)
+	rc = sysfs_memparse(buffer, count, &val, "MiB");
+	if (rc < 0)
 		return rc;
 
 	/* this is only for shrinking grant */
-- 
1.8.3.1
