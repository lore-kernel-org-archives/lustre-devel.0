From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:43 -0500
Subject: [lustre-devel] [PATCH 15/60] staging: lustre: hsm: stack overrun in
	hai_dump_data_field
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, frank zago <fzago@cray.com>, James Simmons <jsimmons@infradead.org>

From: frank zago <fzago@cray.com>

The function hai_dump_data_field will do a stack buffer
overrun when cat'ing /sys/fs/lustre/.../hsm/actions if an action has
some data in it.

hai_dump_data_field uses snprintf. But there is no check for
truncation, and the value returned by snprintf is used as-is.  The
coordinator code calls hai_dump_data_field with 12 bytes in the
buffer. The 6th byte of data is printed incompletely to make room for
the terminating NUL. However snprintf still returns 2, so when
hai_dump_data_field writes the final NUL, it does it outside the
reserved buffer, in the 13th byte of the buffer. This stack buffer
overrun hangs my VM.

Fix by checking that there is enough room for the next 2 characters
plus the NUL terminator. Don't print half bytes. Change the format to
02X instead of .2X, which makes more sense.

Signed-off-by: frank zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8171
Reviewed-on: http://review.whamcloud.com/20338
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jean-Baptiste Riaux <riaux.jb@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/lustre/lustre_user.h | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 3301ad6..21aec0c 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -1209,23 +1209,21 @@ struct hsm_action_item {
  * \retval buffer
  */
 static inline char *hai_dump_data_field(struct hsm_action_item *hai,
-					char *buffer, int len)
+					char *buffer, size_t len)
 {
-	int i, sz, data_len;
+	int i, data_len;
 	char *ptr;
 
 	ptr = buffer;
-	sz = len;
 	data_len = hai->hai_len - sizeof(*hai);
-	for (i = 0 ; (i < data_len) && (sz > 0) ; i++) {
-		int cnt;
-
-		cnt = snprintf(ptr, sz, "%.2X",
-			       (unsigned char)hai->hai_data[i]);
-		ptr += cnt;
-		sz -= cnt;
+	for (i = 0; (i < data_len) && (len > 2); i++) {
+		snprintf(ptr, 3, "%02X", (unsigned char)hai->hai_data[i]);
+		ptr += 2;
+		len -= 2;
 	}
+
 	*ptr = '\0';
+
 	return buffer;
 }
 
-- 
1.8.3.1
