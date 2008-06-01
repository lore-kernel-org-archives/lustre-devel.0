From: Mike Shapiro <mws@Sun.COM>
Date: Sat, 31 May 2008 20:17:51 -0700
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <C4682C31.5617%peter.braam@sun.com>
References: <1212008833.14599.84.camel@localhost>
	<C4682C31.5617%peter.braam@sun.com>
Message-ID: <20080601031751.GA29401@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jun 01, 2008 at 10:36:33AM +0800, Peter Braam wrote:
> For CIFS quota and user ids get in touch with Matt Wu and Mike Shapiro.
> There are special interfaces in ZFS/DMU for better windows support that we
> probably need to leverage.
> 
> Peter

For the design doc of how we unified POSIX and Windows SIDs
in the underlying filesystem and kernel see:

opensolaris.org/os/community/arc/caselog/2007/064/final-materials/spec-txt/

The FUID system described there is implemented in ZFS now.  If you are
doing work to add user accounting to ZFS/DMU (which is wonderful news)
all of that should be implemented using the FUID tables, which will
result in it working transparently for both POSIX and Windows IDs.

Any upstack expressions of this that are meant to be persistent for
customers (i.e. a report) or sent over the wire should express the accounted-
for entities using the generic string form of SIDs that I describe in there.

-Mike

-- 
Mike Shapiro, Sun Microsystems Fishworks. blogs.sun.com/mws/
