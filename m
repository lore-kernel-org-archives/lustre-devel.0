From: James Simmons <jsimmons@infradead.org>
Date: Fri, 1 Apr 2016 20:59:54 +0100 (BST)
Subject: [lustre-devel] [RFC PATCH 0/3] staging: lustre: detypedef
In-Reply-To: <1459536253.1744.26.camel@perches.com>
References: <cover.1459515208.git.joe@perches.com>
	<0586F4EF-3E2B-419A-8343-3A4A7E34628D@intel.com>
	<1459536253.1744.26.camel@perches.com>
Message-ID: <alpine.LFD.2.20.1604012057180.17701@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, "<linux-kernel@vger.kernel.org>" <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "<devel@driverdev.osuosl.org>" <devel@driverdev.osuosl.org>, "<lustre-devel@lists.lustre.org>" <lustre-devel@lists.lustre.org>


> > I know James is working on cleaning up LNet, but I don't know if he has
> > anything this would be conflicting at this moment or not.
> > 
> > Thanks for the patches. I wonder if you are generating them automatically?
> > Because it would be great if it also fixes the alignment issues
> 
> It's pretty automatic.
> 
> It's a trivial variant of the detypedef perl script I wrote awhile ago:
> http://permalink.gmane.org/gmane.linux.drivers.driver-project.devel/18603
> 
> 
> I think changing the alignment issues is better done in a
> separate patch.
> 
> James isn't cc'd on these patches as he's not a listed
> maintainer. ?Maybe he should be added for all of it or
> some part of it?

Yes please add me to the maintainer list. Currently the work is divided 
between Oleg and I. I also actively test this client to find any
regressions. I have been working on the LNet, libcfs cleanups and bug 
fixes. Any libcfs/LNet changes please send my way.

Also now that LNet is close to being synced with our production code it 
means I have free cycles to find all the earlier dropped patches in
the Lustre code. We have gaps in various places where patches were 
dropped. So I will be working on pushing those patches as well. Oleg
still is the main person for the Lustre core client code. 
 
> I don't know what email address James prefers as there
> are several in git log for him.
> 
> James Simmons <uja.ornl@yahoo.com>
> James Simmons <uja.ornl@gmail.com>
> James Simmons <jsimmons@infradead.org>
> "Simmons, James A." <simmonsja@ornl.gov>

The infradead.org account is the main one. The ornl.gov is my day job
account. The yahoo and gmail accounts are used, for openid, to push
patches to the OpenSFS Lustre branch which is why you see those Signed-Off
with various patch ports.

> but maybe something like this:
> ---
> ?MAINTAINERS | 1 +
> ?1 file changed, 1 insertion(+)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 16ccda4..d585631 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -10578,6 +10578,7 @@ F:	drivers/staging/media/lirc/
> ?STAGING - LUSTRE PARALLEL FILESYSTEM
> ?M:	Oleg Drokin <oleg.drokin@intel.com>
> ?M:	Andreas Dilger <andreas.dilger@intel.com>
> +R:	James Simmons <jsimmons@infradead.org>
> ?L:	lustre-devel at lists.lustre.org (moderated for non-subscribers)
> ?W:	http://wiki.lustre.org/
> ?S:	Maintained
