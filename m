From: Andreas Dilger <adilger@sun.com>
Date: Thu, 17 Jan 2008 11:35:41 -0700
Subject: [Lustre-devel] [URGENT] Lustre 1.6.4.1 data loss bug
Message-ID: <20080117183541.GY3351@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Attention to all Lustre users.

There was a serious problem discovered with only the 1.6.4.1 release
which could lead to major data loss on relatively new Lustre filesystems
in certain situations.  The 1.6.4.2 release is being prepared that will
fix the problem, and workarounds are available for existing 1.6.4.1 users,
but in the meantime customers should be aware of the problem and take
measures to avoid the problem (described at the end of the email).

The problem is described in bug 14631, and while there are no known cases
that this has impacted a production environment, the consequences can be
severe and all users should take note.  The bug can cause objects on newly
formatted OSTs to be deleted if the following conditions are true:

OST has had fewer than 20000 objects created on it ever
-------------------------------------------------------
This can be seen on each OST via "cat /proc/fs/lustre/obdfilter/*/last_id"
which reports the highest object ID ever created on that OST.  If this
number is greater than 20000 that OST is not at risk of data loss.

The OST must be in recovery at the time the MDT is first mounted
----------------------------------------------------------------
This would happen if the OSS node crashed, or if the OST filesystem is
unmounted while the MDT or a client is still connected.  Unmounting all
clients and MDT before the OST is always the correct process and will
avoid this problem, but it is also possible to force unmount the OST
with "umount -f /mnt/ost*" (or path as appropriate) to evict all
connections and avoid the problem.

If the OST is in recovery at mount time then it can be mounted before the
MDT and "lct --device {OST device number} abort_recovery" used to abort
recovery before the MDT is mounted.  Alternately, the OST will only wait
a specific time for recovery (4:10 by default, actual value printed in
dmesg) and this can be allowed to expire before mounting the MDT to avoid
the problem.

The MDT is not in recovery when it connects to the OST(s)
---------------------------------------------------------
If the MDT is not in recovery at mount time (i.e. it was shut down
cleanly), but the OST is in recovery then the MDT will try and get
information from the OST on existing objects, but fail.  Later in
the startup process the MDT would incorrectly signal the OST to delete
all unused objects.  If the MDT is in recovery at startup, then the
MDT recovery period will expire after the OST recovery and the problem
will not be triggered.  If the OSTs are mounted and are not in recovery
when the MDT mounts then the problem will also not be triggered.


To avoid triggering the problem:
--------------------------------
- unmount the clients and MDT before the OST.  When unmounting
the OST use "umount -f /mnt/ost*" to force disconnect all clients.
- mount the OSTs before the MDT, and wait for the recovery to timeout
(or cancel it, as above) before mounting the MDT
- create at least 20000 objects on each OST.  Specific OSTs can be
targetted via "lfs setstripe -i {OST index} /path/to/lustre/file".
These objects do not need to remain on the OST, there just have to have
been that many objects created on the OST ever, to activate a sanity
check when the 1.6.4.1 MDT connects to the OST.
- upgrade to lustre 1.6.4.2 when available

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
