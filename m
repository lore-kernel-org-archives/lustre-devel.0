From: Peter Braam <Peter.Braam@Sun.COM>
Date: Sat, 05 Jul 2008 21:20:53 -0600
Subject: [Lustre-devel] How store HSM metadata in MDT ?
In-Reply-To: <20080705165025.GI6239@webber.adilger.int>
Message-ID: <C4959635.4DA1%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




On 7/5/08 10:50 AM, "Andreas Dilger" <adilger@sun.com> wrote:

> What manages removal of the older copies in HPSS?  If HPSS can purge older
> files based on policy (leaving at least the most recent copy always), then
> it would be possible to defer the backup policy to HPSS and Lustre would
> only ever need to reference a single offline file.  Any queries for listing
> older versions of the file would be passed on from Lustre to HPSS in that
> case.
> 

The point is that there is a proposal here to have multiple pointers PER
INODE - that is not a good idea.

Regardless of what policies are in place and where they are managed, they
should not affect every inode with a new pointer for every backup object of
that inode.

Peter



> Cheers, Andreas
> --
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
