From: Prakash Surya <surya1@llnl.gov>
Date: Tue, 18 Dec 2012 16:12:55 -0800
Subject: [Lustre-devel] [wc-discuss] Important changes to libcfs
 primitives usage.
In-Reply-To: <1355868747.22854.20.camel@brian-laptop>
References: <201212180412.qBI4CTe9028934@hedwig.cmf.nrl.navy.mil>
	<1355868747.22854.20.camel@brian-laptop>
Message-ID: <20121219001255.GB5622@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Dec 18, 2012 at 05:12:27PM -0500, Brian J. Murrell wrote:
> On Mon, 2012-12-17 at 23:12 -0500, Ken Hornstein wrote:
> > There's a HUGE
> > difference in practice between "feature X appears in Linux kernel
> > version Y" and "My RedHat release Z has a particular feature".  That's
> > where life gets complicated.  Many times we're stuck on a particular
> > kernel for various complicated reasons, yet we need to upgrade Lustre
> > ... or vice versa.  It's kind of like Infiniband in the Linux kernel ...
> > at best, it doesn't hurt us, but it's always the "wrong" version (or so
> > my Infiniband guys tell me).  We never end up using the Infiniband in
> > the kernel, and sometimes (depending on the vagarities of the distro)
> > that screws us up hard; part of that is because for a long time one
> > particular distro never would distribute the development symbols for
> > the Infiniband in the kernel that matched what the kernel was running.
> > That won't be an issue with Lustre, but you get the idea.
> 
> So let me just confirm I understand your issue here.  For example, the
> Linux kernel is at 3.12.1 (version numbers are purely hypothetical and
> far into the future) which has Lustre 2.6.3 in it.  But RHEL 9's kernel
> is only 3.8.1"ish" and has Lustre 2.4.2 (because that's what was in the
> upstream Linux 3.8.1 kernel) in it.
> 
> The complaint is that the Lustre (2.4.2) that's in the RHEL 9 kernel
> that you are using is too old for some reason?
> 
> So what's the remedy?  You can either (a) download the stand-alone
> Lustre module source for the version of Lustre you need and build it
> against the RHEL 9 kernel you want to use (assuming they are near enough
> to be compatible -- which is the same situation that exists today) or

That is a big assumption, and is most likely false. Currently autoconf
maintains the compatibility of Lustre with the different kernel versions.
If the client is in tree, are we really going to maintain the same level
of autoconf "foo" to be compatible with older kernels? And if not, we
would have to maintain a second package, outside of the kernel, which did
have this autoconf compatibility layer.

I don't think option (a) is the same as what we have now.

-- 
Cheers, Prakash

> (b) you download the entire upstream kernel that has the version of
> Lustre that you want to use and build that.
> 
> It seems to me that (a) is what everyone already has to do all of the
> time today anyway (assuming the binary RPM that we ship for the given
> vendor kernel is not new enough) and (b) just isn't even possible so
> that's gravy.
> 
> There might be something obvious that I'm missing, but I'm failing to
> see how having Lustre (client) in the kernel is any worse than the
> status quo (basically scenario (a) above) and indeed should provide
> Lustre compatibility to the current stable Linux sooner than we can
> typically turn it around.  
> 
> Cheers,
> b.
> 
