From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Sat,  6 Feb 2016 02:01:49 -0500
Subject: [lustre-devel] [PATCH 0/2] Lustre debugfs fixes
Message-ID: <1454742111-2231460-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

These two patches tie some loose ends from the Lustre debugfs conversion,
but while investigating them I also accumulated some questions
that would be good to get answers for.

1. Unlike procfs, debugfs does not really guard your back and if root
comes in and tries to write to a readonly file (or read a write-only one),
it's allowed (as are permission changes too) as long as the appropriate write
(or read) method is provided.
So apparently there's whole class of bugs related to this, sample
exhibits are in e.g. acpi_ec_add_debugfs creating a totally noop module
parameter to control writes that does not really prevent any writes
(patch submitted separately).
But also things like wil_debugfs_create_iomem_x32 where when called from
e.g. wil6210_debugfs_init_offset, some read-only attributed get a generic
write method that would write straight to hardware registers (who knows
what would happen when you write there, possibly they are readonly, but
you are not getting an error).
At first it looked like an easy way to catch this would be to just check
for RO/WO mode with write/read handler set, but this is thwarted by
the simple attribute defines that always assign read and write methods,
but do the check internally for the get/set method instead.
But also some fault injection code that sets readonly access on some files,
but provides a fully functional write method that works as desired.

Would it make sense to redo the simple-attribute framework to easy such
cases detection (and also update writeable attributes to have permissions
reflecting this) and have a correspinding kernel debug compile option
to check for these?

2. I noticed we exported some of the presumably GPL-only debugfs
functionality with plain EXPORT_SYMBOL, so the second patch rectifies this.
Now, I also see that drm_debugfs_create_files allows anybody to
insert any debugfs file anywhere and it is a non-gpl EXPORT_SYMBOL as well,
should it be converted too, or is it sysfs access only that is restricted?

Oleg Drokin (2):
  staging/lustre/libcfs: Properly handle debugfs read- and write-only
    files
  staging/lustre/obdclass: export debugfs functionality for GPL only.

 drivers/staging/lustre/lustre/libcfs/module.c      | 27 ++++++++++++++++++++--
 .../lustre/lustre/obdclass/lprocfs_status.c        | 18 +++++++--------
 2 files changed, 34 insertions(+), 11 deletions(-)

-- 
2.1.0
