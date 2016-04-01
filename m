From: Joe Perches <joe@perches.com>
Date: Fri, 01 Apr 2016 11:44:13 -0700
Subject: [lustre-devel] [RFC PATCH 0/3] staging: lustre: detypedef
In-Reply-To: <0586F4EF-3E2B-419A-8343-3A4A7E34628D@intel.com>
References: <cover.1459515208.git.joe@perches.com>
	<0586F4EF-3E2B-419A-8343-3A4A7E34628D@intel.com>
Message-ID: <1459536253.1744.26.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: "<linux-kernel@vger.kernel.org>" <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "<devel@driverdev.osuosl.org>" <devel@driverdev.osuosl.org>, "<lustre-devel@lists.lustre.org>" <lustre-devel@lists.lustre.org>

On Fri, 2016-04-01 at 14:23 +0000, Drokin, Oleg wrote:
> On Apr 1, 2016, at 9:02 AM, Joe Perches wrote:
> > 
> > Question about removing lustre typedefs.
> > 
> > Various bits of lustre code use a mix of struct foo and foo_t.
> > 
> > When would be an appropriate time to submit patches similar to
> > below that individually remove various typedefs from lustre code?
> I think now is as good time as any.
> the only small correction is those are LNet typedefs.
> While LNet is technically part of Lustre, it's a bit of a separate
> thing useful without Lustre too.
> 
> I know James is working on cleaning up LNet, but I don't know if he has
> anything this would be conflicting at this moment or not.
> 
> Thanks for the patches. I wonder if you are generating them automatically?
> Because it would be great if it also fixes the alignment issues

It's pretty automatic.

It's a trivial variant of the detypedef perl script I wrote awhile ago:
http://permalink.gmane.org/gmane.linux.drivers.driver-project.devel/18603


I think changing the alignment issues is better done in a
separate patch.

James isn't cc'd on these patches as he's not a listed
maintainer. ?Maybe he should be added for all of it or
some part of it?

I don't know what email address James prefers as there
are several in git log for him.

James Simmons <uja.ornl@yahoo.com>
James Simmons <uja.ornl@gmail.com>
James Simmons <jsimmons@infradead.org>
"Simmons, James A." <simmonsja@ornl.gov>

but maybe something like this:
---
?MAINTAINERS | 1 +
?1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 16ccda4..d585631 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -10578,6 +10578,7 @@ F:	drivers/staging/media/lirc/
?STAGING - LUSTRE PARALLEL FILESYSTEM
?M:	Oleg Drokin <oleg.drokin@intel.com>
?M:	Andreas Dilger <andreas.dilger@intel.com>
+R:	James Simmons <jsimmons@infradead.org>
?L:	lustre-devel at lists.lustre.org (moderated for non-subscribers)
?W:	http://wiki.lustre.org/
?S:	Maintained
