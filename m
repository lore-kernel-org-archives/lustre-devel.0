From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 12:13:20 +1100
Subject: [lustre-devel] [PATCH SERIES 2: 0/4] staging:lustre: improve
 mounting code
Message-ID: <151355938405.10227.11903161187102828189.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

These patches make improvements to the lustre code
for supporting the mount system call.

There is a user-visible change: "lustre" now appears in
/proc/filesystem with the "nodev" flag present.  Previously
it didn't have this flag, which was incorrect.

There is also a bugfix: there is a possible module-unload race
that could trigger a crash.

Thanks,
NeilBrown


---

NeilBrown (4):
      staging: lustre: obdclass: discard FS_NEEDS_DEV flag.
      staging: lustre: obdclass: remove pointless struct lustre_mount_data2
      staging: lustre: obdclass: remove vfsmount option from client_fill_super
      staging: lustre: obd_mount: fix possible race with module unload.


 .../staging/lustre/lustre/include/lustre_disk.h    |    6 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 -
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    7 +-
 drivers/staging/lustre/lustre/llite/super25.c      |    6 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   63 +++++++++-----------
 5 files changed, 38 insertions(+), 46 deletions(-)

--
Signature
