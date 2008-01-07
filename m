From: Andreas Dilger <adilger@sun.com>
Date: Mon, 7 Jan 2008 13:07:18 -0700
Subject: [Lustre-devel] moving /proc to $MNT/.lustre
In-Reply-To: <1199729436.23325.65.camel@pc.ilinx>
References: <47618E96.3080709@sun.com>
	<F8F87424-C3EE-45E7-838E-95E1047F521D@Sun.COM>
	<4782665E.1070406@sun.com> <1199729436.23325.65.camel@pc.ilinx>
Message-ID: <20080107200718.GT3351@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 07, 2008  13:10 -0500, Brian J. Murrell wrote:
> On Mon, 2008-01-07 at 09:50 -0800, Nathan Rutman wrote:
> > well, that's why I asked.  As I said, Andreas and I are in agreement, 
> > and it certainly makes sense from a portability point of view, as well 
> > as consistency with future features (snapshots, audit logs, etc.), and 
> > the final elimination of our various /proc locking headaches.  But yes, 
> > it would break user's scripts  - that's a 1-time thing, and I think not 
> > too terrible.
> 
> Is it possible to support both for a release or two to give people time
> to migrate and have an actual implementation to test against as they
> work to port their scripts?  The alternative is that given that we don't
> provide public beta binaries or nightly snapshot binaries, we'd be
> requiring people who want to port, test and release their ports on "flag
> day" to build from CVS to test.

It wasn't mentioned here, but this is already planned.  There will be
new commands "lctl get_param" and "lctl set_param" (or similar) that
will be usable by scripts to get/set Lustre tunables.  This will work
with both /proc and .../.lustre files so will allow scripts to move
over to the new mechanism.

For user-space servers there will be no alternative but to use the lctl
mechanism since /proc entries will not exist at all.  Then again, there
will not be any existing systems using the old mechanism since uOSS will
only work with ZFS.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
