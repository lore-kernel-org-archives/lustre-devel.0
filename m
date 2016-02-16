From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:59 -0500
Subject: [lustre-devel] [PATCH 27/45] staging/lustre: Remove the "write to
	FSF to get a copy of GPL" wording
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-28-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Checkpatch highlighted that some of our Lustre files carry this
extra paragraph and indeed it does seem somewhat redundant, so remove it.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/include/linux/lnet/lnetctl.h           | 4 ----
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h           | 4 ----
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c        | 3 ---
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c | 3 ---
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c     | 3 ---
 drivers/staging/lustre/lnet/lnet/router.c                     | 4 ----
 drivers/staging/lustre/lnet/lnet/router_proc.c                | 4 ----
 drivers/staging/lustre/lustre/include/lu_ref.h                | 4 ----
 drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c             | 5 -----
 drivers/staging/lustre/lustre/libcfs/libcfs_lock.c            | 5 -----
 drivers/staging/lustre/lustre/libcfs/libcfs_mem.c             | 5 -----
 drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c        | 5 -----
 drivers/staging/lustre/lustre/ptlrpc/nrs.c                    | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c               | 4 ----
 14 files changed, 57 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lnetctl.h b/drivers/staging/lustre/include/linux/lnet/lnetctl.h
index bdd69b2..4b64f62 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetctl.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetctl.h
@@ -10,10 +10,6 @@
  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *   GNU General Public License for more details.
  *
- *   You should have received a copy of the GNU General Public License
- *   along with Portals; if not, write to the Free Software
- *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
- *
  * header for lnet ioctl
  */
 #ifndef _LNETCTL_H_
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index a4117ad..a176544 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -19,10 +19,6 @@
  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *   GNU General Public License for more details.
  *
- *   You should have received a copy of the GNU General Public License
- *   along with Portals; if not, write to the Free Software
- *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
- *
  */
 
 #ifndef _SOCKLND_SOCKLND_H_
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 02da02d..efb7169 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -19,9 +19,6 @@
  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *   GNU General Public License for more details.
  *
- *   You should have received a copy of the GNU General Public License
- *   along with Portals; if not, write to the Free Software
- *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
 #include "socklnd.h"
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
index 77ce597..6329cbe 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
@@ -14,9 +14,6 @@
  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *   GNU General Public License for more details.
  *
- *   You should have received a copy of the GNU General Public License
- *   along with Portals; if not, write to the Free Software
- *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
 #include "socklnd.h"
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index 70910ed..976a072 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -19,9 +19,6 @@
  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *   GNU General Public License for more details.
  *
- *   You should have received a copy of the GNU General Public License
- *   along with Portals; if not, write to the Free Software
- *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
 #include "socklnd.h"
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 735a8f2..83ed123 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -15,10 +15,6 @@
  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *   GNU General Public License for more details.
  *
- *   You should have received a copy of the GNU General Public License
- *   along with Portals; if not, write to the Free Software
- *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
- *
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index a7aaf0c..01dd900 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -15,10 +15,6 @@
  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *   GNU General Public License for more details.
  *
- *   You should have received a copy of the GNU General Public License
- *   along with Portals; if not, write to the Free Software
- *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
- *
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
diff --git a/drivers/staging/lustre/lustre/include/lu_ref.h b/drivers/staging/lustre/lustre/include/lu_ref.h
index 97cd157..f7dfd83 100644
--- a/drivers/staging/lustre/lustre/include/lu_ref.h
+++ b/drivers/staging/lustre/lustre/include/lu_ref.h
@@ -17,10 +17,6 @@
  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *   GNU General Public License for more details.
  *
- *   You should have received a copy of the GNU General Public License
- *   along with Lustre; if not, write to the Free Software
- *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
- *
  */
 
 #ifndef __LUSTRE_LU_REF_H
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c
index 9137df9..33352af 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c
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
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_lock.c b/drivers/staging/lustre/lustre/libcfs/libcfs_lock.c
index 2d08ba6..9c64bfd 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_lock.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_lock.c
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
 /* Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved.
diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_mem.c b/drivers/staging/lustre/lustre/libcfs/libcfs_mem.c
index e0a8783..7396d66 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_mem.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_mem.c
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
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c
index 41b9512..7fb277a 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c
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
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
index ed40be6..d603a57 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
@@ -13,10 +13,6 @@
  * GNU General Public License version 2 for more details.  A copy is
  * included in the COPYING file that accompanied this code.
 
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
index 77894f8..0d8da35 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
@@ -13,10 +13,6 @@
  * GNU General Public License version 2 for more details.  A copy is
  * included in the COPYING file that accompanied this code.
 
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
- *
  * GPL HEADER END
  */
 /*
-- 
2.1.0
