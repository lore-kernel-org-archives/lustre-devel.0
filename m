From: NeilBrown <neilb@suse.com>
Date: Mon, 12 Feb 2018 12:20:43 +1100
Subject: [lustre-devel] [e2fsprogs PATCH] tune2fs: don't recover journal if
 device is busy.
Message-ID: <871shrrok4.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tytso-3s7WtUTddSA@public.gmane.org
Cc: linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lustre <lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org>


tune2fs currently replays the journal if it needs
recovery and the filesystem isn't mounted.

The test for "is the filesystem mounted" isn't completely robust.
Lustre makes use of ext4 filesystems in a way that they are mounted
without being visible in /proc/mounts or similar.
This usage can easily be detected by attempting to open the device
with O_EXCL.  tune2fs already does this and the EXT2_MF_BUSY flag
is set if open(O_EXCL) fails.
Several uses other than lustre mounts could cause O_EXCL to fail,
but in any case it seems unwise to recover the journal when something
else is keeping the device busy.

So add an extra test to avoid journal recovery when the device
is busy.  This fixes some problems with lustre usage.

Signed-off-by: NeilBrown <neilb@suse.com>

--
Note: it seems wrong to recover the journal *after* making
changes to the superblock - there is a good chance that
recovering the journal will over-write those changes.
This is what was happening that lead me to this problem.
Shouldn't journal recovery happen *first*??

Thanks,
NeilBrown
---
 misc/tune2fs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/misc/tune2fs.c b/misc/tune2fs.c
index c33fb9d80b10..703e55b6b972 100644
--- a/misc/tune2fs.c
+++ b/misc/tune2fs.c
@@ -3337,7 +3337,7 @@ _("Warning: The journal is dirty. You may wish to replay the journal like:\n\n"
 	}
 #else
 	/* Recover the journal if possible. */
-	if ((open_flag & EXT2_FLAG_RW) && !(mount_flags & EXT2_MF_MOUNTED) &&
+	if ((open_flag & EXT2_FLAG_RW) && !(mount_flags & (EXT2_MF_BUSY | EXT2_MF_MOUNTED)) &&
 	    ext2fs_has_feature_journal_needs_recovery(fs->super)) {
 		errcode_t err;
 
-- 
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180212/80144b67/attachment.sig>
