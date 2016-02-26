From: 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>
Date: Fri, 26 Feb 2016 16:18:18 +0000
Subject: [lustre-devel] [PATCH v2 0/6] staging: lustre: update modinfo
	data
In-Reply-To: <3d8510f665034cd1a28eee812d572736@EXCHCS32.ornl.gov>
References: <1456448832-959-1-git-send-email-jsimmons@infradead.org>
	<20160226060343.GA29216@kroah.com>
	<54D84798-42F5-44E9-BE99-CBD9A7DF6E51@intel.com>
	<20160226062525.GB1895@kroah.com>
	<3d8510f665034cd1a28eee812d572736@EXCHCS32.ornl.gov>
Message-ID: <20160226161818.GA12212@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Simmons, James A." <simmonsja@ornl.gov>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, Feb 26, 2016 at 03:46:02PM +0000, Simmons, James A. wrote:
> >On Fri, Feb 26, 2016 at 06:11:07AM +0000, Drokin, Oleg wrote:
> >> 
> >> On Feb 26, 2016, at 1:03 AM, Greg Kroah-Hartman wrote:
> >> 
> >> > On Thu, Feb 25, 2016 at 08:07:06PM -0500, James Simmons wrote:
> >> >> The module information for Lustre is stale or in some cases
> >> >> completely missing. This collection of patches brings the
> >> >> modinfo up to date as well as filling in any missing information.
> >> >> This patch set has been redone to rebase it on Oleg's latest
> >> >> patch set to avoid collisons in merging.
> >> >> 
> >> >> Andreas Dilger (4):
> >> >>  staging: lustre: add missing MODULE_AUTHOR for LNet selftest module
> >> >>  staging: lustre: update the MODULE_DESCRIPTION for all lustre modules
> >> >>  staging: lustre: make module_init/exit naming consistent
> >> >>  staging: lustre: update comment for lnet_lib_init/exit
> >> >> 
> >> >> James Simmons (2):
> >> >>  staging: lustre: move module info to end of libcfs module.c file
> >> >>  staging: lustre: update the MODULE_VERSION for all lustre modules
> >> > 
> >> > What changed to need a v2 of this series?
> >> > 
> >> > Please ALWAYS say what the difference is, don't expect us to "just
> >> > know".
> >> > 
> >> > Please send a v3 of this, describing the changes, in the correct format,
> >> > in each patch.  You know better than this?
> >> 
> >> I think it says above that the rebase was done on top of my patchset
> >> to resolve the conflict that arose?
> >
> >Where?  Ugh, yeah, kind of, but where is the big v2: marking or some
> >such thing like is required?  It's very easy to miss this (as I did.)
> >Please make it easy for maintainers, not hard on them...
> 
> Sorry, in the future I will add a ChangeLog section for newer versions of patches.
> The good news is the patches from Oleg's that conflicted landed already which
> means the this patch set is ready to land.

Can you please resend it with the proper format?  It's out of my queue
now...

thanks,

greg k-h
