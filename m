From: NeilBrown <neilb@suse.com>
Date: Mon, 16 Apr 2018 10:42:37 +1000
Subject: [lustre-devel] [PATCH 0/6] staging: lustre: code rearrangement
Message-ID: <152383910760.23409.2327082725637657049.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

This series rearranges some code and manages to delete four
files in the process, all from directories called "linux".
This results in
  drivers/staging/lustre/include/linux/libcfs/linux
becoming empty, so it disappears too.

These patches depend on
  [PATCH] staging: lustre: libcfs: use dynamic minors for /dev/{lnet,obd}
which James posted on 30th March.

Thanks,
NeilBrown

---

NeilBrown (6):
      staging: lustre: move stack-check macros to libcfs_debug.h
      staging: lustre: remove libcfs/linux/libcfs.h
      staging: lustre: remove include/linux/libcfs/linux/linux-cpu.h
      staging: lustre: rearrange placement of CPU partition management code.
      staging: lustre: move misc-device registration closer to related code.
      staging: lustre: move remaining code from linux-module.c to module.c


 .../staging/lustre/include/linux/libcfs/libcfs.h   |   48 +
 .../lustre/include/linux/libcfs/libcfs_cpu.h       |  206 +++-
 .../lustre/include/linux/libcfs/libcfs_debug.h     |   32 +
 .../lustre/include/linux/libcfs/linux/libcfs.h     |  114 --
 .../lustre/include/linux/libcfs/linux/linux-cpu.h  |   78 -
 drivers/staging/lustre/lnet/libcfs/Makefile        |    2 
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    |  961 +++++++++++++++++-
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   | 1079 --------------------
 .../lustre/lnet/libcfs/linux/linux-module.c        |  196 ----
 drivers/staging/lustre/lnet/libcfs/module.c        |  162 +++
 10 files changed, 1344 insertions(+), 1534 deletions(-)
 delete mode 100644 drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
 delete mode 100644 drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux/linux-module.c

--
Signature
