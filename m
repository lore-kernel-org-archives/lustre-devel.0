From: Andreas Dilger <adilger@sun.com>
Date: Mon, 7 Jan 2008 23:48:15 -0700
Subject: [Lustre-devel] moving /proc to $MNT/.lustre
In-Reply-To: <69573950-6797-4203-8516-CB7B0FC3271E@sun.com>
References: <47618E96.3080709@sun.com>
	<F8F87424-C3EE-45E7-838E-95E1047F521D@Sun.COM>
	<4782665E.1070406@sun.com> <1199729436.23325.65.camel@pc.ilinx>
	<20080107200718.GT3351@webber.adilger.int>
	<69573950-6797-4203-8516-CB7B0FC3271E@sun.com>
Message-ID: <20080108064815.GC3351@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 07, 2008  22:39 -0500, Oleg Drokin wrote:
> On Jan 7, 2008, at 3:07 PM, Andreas Dilger wrote:
>>> Is it possible to support both for a release or two to give people time
>>> to migrate and have an actual implementation to test against as they
>>> work to port their scripts?  The alternative is that given that we don't
>>> provide public beta binaries or nightly snapshot binaries, we'd be
>>> requiring people who want to port, test and release their ports on "flag
>>> day" to build from CVS to test.
>> It wasn't mentioned here, but this is already planned.  There will be
>> new commands "lctl get_param" and "lctl set_param" (or similar) that
>> will be usable by scripts to get/set Lustre tunables.  This will work
>> with both /proc and .../.lustre files so will allow scripts to move
>> over to the new mechanism.
>
> What's the plan to prevent various backups software (and also tar & 
> friends)
> from backing up and restoring (esp. restoring of course) values in these
> files?

The typical way is that .lustre would not appear in readdir/getdirents
but could be accessed if explicitly named.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
