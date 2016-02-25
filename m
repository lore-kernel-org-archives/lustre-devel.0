From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:10 -0500
Subject: [lustre-devel] [PATCH v2 27/84] staging/lustre: Remove FSF mailing
	address from GPL notices
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-28-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This patch removes remaining several places that still had that
extra paragraph included in Lustre code.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h      | 5 -----
 drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h | 5 -----
 drivers/staging/lustre/lnet/lnet/lib-ptl.c                    | 5 -----
 drivers/staging/lustre/lustre/obdecho/echo_internal.h         | 5 -----
 drivers/staging/lustre/lustre/osc/osc_quota.c                 | 5 -----
 5 files changed, 25 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index 1530b04..9e62c59 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -13,11 +13,6 @@
  * General Public License version 2 for more details (a copy is included
  * in the LICENSE file that accompanied this code).
  *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
index 520209f..c04979a 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
@@ -13,11 +13,6 @@
  * General Public License version 2 for more details (a copy is included
  * in the LICENSE file that accompanied this code).
  *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index 5a9ab87..0281c6a 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -13,11 +13,6 @@
  * General Public License version 2 for more details (a copy is included
  * in the LICENSE file that accompanied this code).
  *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_internal.h b/drivers/staging/lustre/lustre/obdecho/echo_internal.h
index 69063fa..f5034a2 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_internal.h
+++ b/drivers/staging/lustre/lustre/obdecho/echo_internal.h
@@ -13,11 +13,6 @@
  * General Public License version 2 for more details (a copy is included
  * in the LICENSE file that accompanied this code).
  *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/osc/osc_quota.c b/drivers/staging/lustre/lustre/osc/osc_quota.c
index d6731c5..508fcf2 100644
--- a/drivers/staging/lustre/lustre/osc/osc_quota.c
+++ b/drivers/staging/lustre/lustre/osc/osc_quota.c
@@ -13,11 +13,6 @@
  * General Public License version 2 for more details (a copy is included
  * in the LICENSE file that accompanied this code).
  *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; if not, write to the
- * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
- * Boston, MA 021110-1307, USA
- *
  * GPL HEADER END
  */
 /*
-- 
2.1.0
