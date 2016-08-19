From: James Simmons <jsimmons@infradead.org>
Date: Fri, 19 Aug 2016 18:03:23 +0100 (BST)
Subject: [lustre-devel] CentOS 6 - Build problems with kmod
In-Reply-To: <57B736D7.9080508@cray.com>
References: <CY4PR11MB1751486ABC8E7B3723D5549ACB150@CY4PR11MB1751.namprd11.prod.outlook.com>
	<9957200e-17fe-2b8d-ad99-e8dfb5019f12@llnl.gov>
	<88922ad0-ba51-f28f-b062-69b2bcfafa16@llnl.gov>
	<CY4PR11MB1751A30F582F35F12E2543F2CB150@CY4PR11MB1751.namprd11.prod.outlook.com>
	<D3DC8811.A3FF%jevans@cray.com> <57B7256D.8050100@cray.com>
	<57B736D7.9080508@cray.com>
Message-ID: <alpine.LFD.2.20.1608191801010.7759@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Unfortunately, when I do that, I am apparently still missing something - lustre-osd is not found, and the lustre modules are
> not found when I try to load them.? (running depmod didn't help there)
> 
> Reverting LU-5614 solves this for me, for now.? I'm hoping someone who's still building and installing for CentOS 6 has some
> insight.

Do you have kabi-whitelist installed? I had a similar problem and if I 
remember right after I installed kabi-whitelist the issues went away.
Be aware you need the kabi-whitelist for the kernel you are building
against installed.

> On 08/19/2016 10:27 AM, Patrick Farrell wrote:
>       Thanks, Ben - That looks likely to work.? Still more than a bit weird.
> 
>       Looking at why things are still working internally at Cray for CentOS 6, I think it's because we're not using
>       lustre.spec (for boring and complicated reasons).
> 
>       It seems very likely the problem was introduced by LU-5614 - http://review.whamcloud.com/#/c/12063/
> 
>       Is Intel still building and installing on CentOS 6 automatically?? Or has all automated testing moved to CentOS 7?
> 
>       - Patrick
>       On 08/19/2016 08:57 AM, Ben Evans wrote:
>       When I ran into the problem, I did an rpm -I --nodeps and it worked fine. ?The errors you are seeing are
>       dependencies listed in the RPMs, not ones used by the actual .ko's.
> 
> I spent some time trying to dig up where the 'kmod-' prefix for all the kernel symbols was getting inserted, but
> couldn't track it down.
> 
> -Ben Evans
> 
> From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Patrick Farrell <paf@cray.com>
> Date: Thursday, August 18, 2016 at 6:11 PM
> To: "Christopher J. Morrone" <morrone2@llnl.gov>, "lustre-devel at lists.lustre.org" <lustre-devel@lists.lustre.org>
> Subject: Re: [lustre-devel] CentOS 6 - Build problems with kmod
> 
> 
> Chris,
> 
> 
> I agree with your contention about the kernel symbols, that's why I rebuilt from scratch and reinstalled. ?Just
> did it again.? Still getting the error.
> 
> 
> > It sounds like you built your own kernel.? Did you install all the
> > resulting kernel packages before building lustre (including any
> > devel-related packages)??
> 
> Yes, but this process doesn't produce anything other than the kernel?RPM.
> 
> 
> >?Is your custom kernel the newest kernel
> > installed on your system?
> 
> Yes. ?It's the newest and it's what's booted.
> 
> 
> So, does anyone have any insight in to what needs to change in the documented build process so I can build and
> install Lustre on CentOS 6? ?(ldisksfs, not ZFS, so I must build the kernel)? It seems likely that I'm missing
> some symbol RPMs or similar, but kernel-syms is a SuSE only thing, I believe. ?I believe Intel is still building
> and installing ldiskfs Lustre on CentOS 6, so there must be something...?
> 
> 
> - Patrick
> 
> ______________________________________________________________________________________________________________________________
> From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Christopher J. Morrone <morrone2@llnl.gov>
> Sent: Thursday, August 18, 2016 3:44:52 PM
> To: lustre-devel at lists.lustre.org
> Subject: Re: [lustre-devel] CentOS 6 - Build problems with kmod ?
> On 08/18/2016 01:43 PM, Christopher J. Morrone wrote:
> > Yes, those instructions should be taken with a huge grain of salt.? For
> > instance, instructions for compiling lustre should really employ a
> 
> s/should/should NOT/
> 
> > custom user and talk about "useradd" and such.? Also, most users can
> > skip the whole custom-patched-kernel section.? Hopefully all developers
> > will be able to stop that too by the time 2.9.0 comes out.
> >
> > The error you are seeing almost certainly means that you don't have a
> > kernel installed that offers symbols compatible with the kernel that
> > lustre was compiled against.
> >
> > It sounds like you built your own kernel.? Did you install all the
> > resulting kernel packages before building lustre (including any
> > devel-related packages)?? Is your custom kernel the newest kernel
> > installed on your system?
> >
> > Chris
> >
> > On 08/18/2016 01:00 PM, Patrick Farrell wrote:
> >> Good afternoon,
> >>
> >>
> >> I'm trying to build and install updated Lustre master on CentOS 6 for
> >> the first time in a month or two, and I'm having trouble.
> >>
> >>
> >> I use the build procedure documented here:
> >>
> >> https://wiki.hpdd.intel.com/pages/viewpage.action?pageId=8126821
> >>
> >>
> >> I've got some new kmod-* RPMs, and I need to install those to install
> >> Lustre, which is fine, except I get a huge string of messages like this
> >> when I try:
> >>
> >> error: Failed dependencies:
> >>???????? ksym(__init_waitqueue_head) = 0xffc7c184 is needed by
> >> kmod-lustre-2.8.56_44_g288e55b_dirty-1.el6.x86_64
> >>???????? ksym(__mutex_init) = 0x4bf79039 is needed by
> >> kmod-lustre-2.8.56_44_g288e55b_dirty-1.el6.x86_64
> >>
> >> I've rebuilt and reinstalled my kernel with this latest version of
> >> Lustre.? Error messages remain the same, and I can't install.
> >>
> >>
> >> Any thoughts or advice?
> >>
> >>
> >> - Patrick
> >>
> >>
> >>
> >> _______________________________________________
> >> lustre-devel mailing list
> >> lustre-devel at lists.lustre.org
> >> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> >>
> >
> > .
> >
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> 
> 
> 
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> 
> 
> 
> 
