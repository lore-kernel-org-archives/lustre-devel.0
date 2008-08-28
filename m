From: Andreas Dilger <adilger@sun.com>
Date: Thu, 28 Aug 2008 14:25:41 -0600
Subject: [Lustre-devel] [RFC] "lctl readonly" modification proposal
In-Reply-To: <48B6DC27.5020308@sun.com>
References: <200808201523.36720.alexander.zarochentsev@sun.com>
	<C4D1B2E1.575A%peter.braam@sun.com>
	<20080820192922.GG3392@webber.adilger.int>
	<200808221945.57702.alexander.zarochentsev@sun.com>
	<20080824020210.GY3392@webber.adilger.int> <48B6DC27.5020308@sun.com>
Message-ID: <20080828202541.GR3392@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Aug 28, 2008  10:11 -0700, Nathaniel Rutman wrote:
> Andreas Dilger wrote:
> >>> I'd be thrilled if this was fixed so a normal shutdown did not do a
> >>> "force" unmount and set the device read-only, because that would also
> >>> avoid leaving the journal needing recovery.
>
> umount does either force or failover shutdown; failover sets readonly 
> but force does not.  Test-framework regularly does both.  Andreas, if 
> you want to avoid journal recovery, use umount -f.

Well, issue is that with normal mount/unmount the filesystem is always
dirty and needs journal recovery.  Also, for the DMU, where we will
likely not have "read-only" support we need to be able to just block
all client transactions and flush everything to disk, doing a normal
shutdown.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
