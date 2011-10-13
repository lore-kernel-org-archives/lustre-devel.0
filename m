From: Vitaly Fertman <vitaly_fertman@xyratex.com>
Date: Thu, 13 Oct 2011 22:53:35 +0400
Subject: [Lustre-devel] Xyratex Releases 1.8 to 2.x Lustre Migrator Tool
Message-ID: <5945F2BF-ED83-4605-8389-0FAAA19244FB@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lustre users,

Xyratex, a leading provider of enterprise-class data storage subsystems,
announces the release of a Lustre? migrator tool, which converts Lustre
file system MDS on-disk data structures from version 1.8 format to version
2.x native format. The Xyratex migrator tool uses the ?upgrade? mount
option to change the on-disk data format of the MDS/MDT component
to native Lustre 2.x. Specifically, the migrator tool:
	? Allocates and assigns true FIDs to objects, storing them in the LMA EA
	? Assigns parent FIDs to objects, storing them in the Link EA
	? Assigns children FIDs to directory entries, storing them correctly in
	  directory entries
	? Creates an Object Index for the newly-allocated FID, so it points
	  to the proper inode number

The Xyratex migrator tool uses the ?restore? mount option to enable the
file system level backups (tar, rsync, cp); specifically, it restores the Object
Index for restored files.

The Xyratex migrator tool, released under the GPL v.2 license, is available
as a patch from http://www.xyratex.com/technology/lustre.aspx, Xyratex?s
Lustre Community page  . The migrator tool?s code cleanly patches against
Lustre 2.x versions, and has been fully tested against the latest Lustre
community release version 2.1.  In addition, we have requested the landing
of this tool in a future release at the Whamcloud Community Jira under issue
ID: LU-591 (http://jira.whamcloud.com/browse/LU-591).

Xyratex values the Lustre community?s feedback on this new migrator tool.
Comments can be directed to lustre-devel at lists.opensfs.org or
lustreinfo at xyratex.com

Warm regards,
Vitaly 

-----------------------------
Vitaly Fertman
Senior Lustre Engineer
Xyratex, Inc.
