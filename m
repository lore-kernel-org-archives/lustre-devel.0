From: Andreas Dilger <adilger@sun.com>
Date: Tue, 11 Mar 2008 12:19:04 -0600
Subject: [Lustre-devel] lu_dirent changes for zfs based mds
In-Reply-To: <47D667EC.4050107@sun.com>
References: <47D667EC.4050107@sun.com>
Message-ID: <20080311181904.GP5851@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mar 11, 2008  16:37 +0530, pravin shelar wrote:
> Hi All,
>         Lustre based on zfs need a change readdir page wire protocol.
> 
> lu_dirent->lde_hash maintains iterator cookie. with zfs - zap cursor API 
> we have 64bit cookie (ref. zap_cursor_serialize()). So we need to change 
> this lde_hash to 64 bit.
> This changes layout of readdir pages which is transmitted on wire, so we 
> need to merge it into head asap.

Note for the record that the 1.8 readdir wire protocol is already different
from that used by 1.6 (because of use of FID and ability to have cross-MDT
references for CMD) so changing the wire format again (before the 1.8 release)
is not a problem.  No release is yet using the new format.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
