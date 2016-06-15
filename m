From: Oleg Drokin <green@linuxhacker.ru>
Date: Tue, 14 Jun 2016 20:44:18 -0400
Subject: [lustre-devel] [PATCH 5/5] staging/lustre/libcfs: Remove "Please
	contact Oracle" from header
In-Reply-To: <1465951458-847547-1-git-send-email-green@linuxhacker.ru>
References: <1465951458-847547-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1465951458-847547-6-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

The "Please contact Oracle Corporation" lines are removed since not
only Oracle has nothing to do with Lustre anymore, there's a pointer
to GPL already that's independent of any particular company.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h | 4 ----
 drivers/staging/lustre/lnet/libcfs/fail.c                 | 4 ----
 2 files changed, 8 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
index 2e008bf..d3f9a60 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
@@ -16,10 +16,6 @@
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see http://www.gnu.org/licenses
  *
- * Please contact Oracle Corporation, Inc., 500 Oracle Parkway, Redwood Shores,
- * CA 94065 USA or visit www.oracle.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/libcfs/fail.c b/drivers/staging/lustre/lnet/libcfs/fail.c
index 086e690..9288ee0 100644
--- a/drivers/staging/lustre/lnet/libcfs/fail.c
+++ b/drivers/staging/lustre/lnet/libcfs/fail.c
@@ -16,10 +16,6 @@
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see http://www.gnu.org/licenses
  *
- * Please contact Oracle Corporation, Inc., 500 Oracle Parkway, Redwood Shores,
- * CA 94065 USA or visit www.oracle.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
-- 
2.7.4
