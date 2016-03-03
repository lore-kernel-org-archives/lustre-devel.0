From: James Simmons <jsimmons@infradead.org>
Date: Thu,  3 Mar 2016 11:00:58 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: handle complex strings in
	cfs_str2num_check
Message-ID: <1457020858-15839-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Originally the function cfs_str2num_check used simple_strtoul
but has been updated to kstrtoul. The string passed into
cfs_str2num_check can be a very complex, for example we could
have 10.37.202.[59-61]. When simple_strtoul was used the first
number until we hit a non-digit character could be extracted
but testing showed that kstrtoul will not return any value if
it detects any non-digit character. Because of this change in
behavior a different approach is needed to handle these types
of complex strings. The use of sscanf was investigated to see
if it could be used to extract numbers from the passed in
string but unlike its glibc counterpart the kernel version
also just reported a error with no results if a non-digit value
in the string was encountered. Another possible approach would
be to use __parse_int directly but that class of functions is
not exported by the kernel. So the approach in this patch is
to scan the string passed in for the first non-digit character
and replace that character with a '\0' so kstrtoul can be used.
Once completed the original character is restored. We also
restore a original behavior that was removed to return 0 when
we encounter any non digit character before the nob count.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/libcfs/libcfs_string.c   |   27 +++++++++++++++++++-
 1 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
index 9dca666..50ac153 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
@@ -229,11 +229,36 @@ int
 cfs_str2num_check(char *str, int nob, unsigned *num,
 		  unsigned min, unsigned max)
 {
+	bool all_numbers = true;
+	char *endp, cache;
 	int rc;
 
 	str = cfs_trimwhite(str);
+
+	/**
+	 * kstrouint can only handle strings composed
+	 * of only numbers. We need to scan the string
+	 * passed in for the first non-digit character
+	 * and end the string at that location. If we
+	 * don't find any non-digit character we still
+	 * need to place a '\0' at position nob since
+	 * we are not interested in the rest of the
+	 * string which is longer than nob in size.
+	 * After we are done the character at the
+	 * position we placed '\0' must be restored.
+	 */
+	for (endp = str; endp < str + nob; endp++) {
+		if (!isdigit(*endp)) {
+			all_numbers = false;
+			break;
+		}
+	}
+	cache = *endp;
+	*endp = '\0';
+
 	rc = kstrtouint(str, 10, num);
-	if (rc)
+	*endp = cache;
+	if (rc || !all_numbers)
 		return 0;
 
 	return (*num >= min && *num <= max);
-- 
1.7.1
