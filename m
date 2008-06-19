From: Andreas Dilger <adilger@sun.com>
Date: Thu, 19 Jun 2008 00:29:00 -0600
Subject: [Lustre-devel] security_inode_unlink in obdfilter.
In-Reply-To: <1213809141.3681.35.camel@bear.shadowland>
References: <1213809141.3681.35.camel@bear.shadowland>
Message-ID: <20080619062900.GP3726@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jun 18, 2008  20:12 +0300, Alexey Lyashkov wrote:
> Is anybody know - why filter use this function in filter_vfs_unlink?
> >From my point view this only add Selinux checks for OST objects, but ost
> not set any selinux context for object and this do nothing.
> I see only one possible variant for usage are log events via audit log.
> Is we really need this?

This is just to keep filter_vfs_unlink() the same as vfs_unlink(),
to be consistent in case SELinux or other security framework is in
place.  If SELinux is NOT in use, then it just ends up as a no-op.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
