From: Peng, Tao <tao.peng@emc.com>
Date: Fri, 21 Dec 2012 04:44:32 +0000
Subject: [Lustre-devel] [wc-discuss] Important changes to libcfs
 primitives usage.
In-Reply-To: <AC5F4785-D28C-486A-9952-6AD54215A7B5@xyratex.com>
References: <D01411ED-E27A-4245-8614-86A69F168F95@xyratex.com>
	<CCF78FC7.BD6F%andreas.dilger@intel.com>
	<1882637210201641A747464075FFC6490715A2@MX101CL02.corp.emc.com>
	<AC5F4785-D28C-486A-9952-6AD54215A7B5@xyratex.com>
Message-ID: <1882637210201641A747464075FFC64907227D@MX101CL02.corp.emc.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> -----Original Message-----
> From: Alexey Lyahkov [mailto:alexey_lyashkov at xyratex.com]
> Sent: Thursday, December 20, 2012 6:45 PM
> To: Peng, Tao
> Cc: Dilger, Andreas; Prakash Surya; hpdd-discuss at lists.01.org; WC-Discuss; <lustre-
> devel at lists.lustre.org>
> Subject: Re: [Lustre-devel] [wc-discuss] Important changes to libcfs primitives usage.
> 
> 
> On Dec 20, 2012, at 06:32, Peng, Tao wrote:
> >>
> >>
> >>> reason to use autoconf macroses - we can't trust a RHEL/SuSe kernel
> >>> version/
> > Well, there are situations that autoconf cannot handle properly, such as the open_flag change by
> upstream commit (8a5e929dd2e05ab4d3d89f58c5e8fca596af8f3a).
> i don't understand how it is affect to lustre, as that is internal change for VFS, but if you provide
> more details - i try to help you. But in different thread please.
> 
> hm.. some minutes latter - you talk about 'static inline int ll_namei_to_lookup_intent_flag(int flag)'
> change? can you point lustre commit in next time.
> 
> > The change is inline so we cannot tell it without grepping the source file (fs/namei.c) which is
> likely unavailable when users build Lustre client from source. We currently solved it by putting a
> LINUX_VERSION_CODE check there but as you see it is not trustworthy when vendors backport patches.
> >
> But what you will do if similar change will be backported by RH? they will have outdated client in own
> tree and 'stable' client in external repository. that is need to be resolved in portable way anyway.
> 
If Lustre is in kernel, RH will need to backport relative changes to Lustre as part of the process of backporting kernel commit. So we won't face such problems. It only remains a problem if Lustre is maintained separately out of RH kernel tree as is today.

> 
> 
> > And IMO, the right way to solve such problems is to put Lustre in upstream/stable kernels and let
> vendors ship it so that they match in the first place.
> >
> Vendor will freeze lustre source version and never update it, 
> but RHEL have ~5-7 years to support - so
> you will be need support that clients in own servers and maintain stable lustre client for that kernel.
> So none difference with current situation except a two additional versions to support
> 1) from stock vendor kernel
> 2) from stock vanila kernel.
> 
It is the same case for any in-tree kernel modules. Besides, vendor kernels are supported by vendors as well. So I don't think it is such a burden for Lustre. Other file systems all handle it pretty well.

> and that is solve very few problems with taking a much more resources for testing.
> 
> Put lustre code into kernel mainline good to have support a last kernel and for development without
> stable tree. But i don't like a support for very older clients in server code - RHEL4 isn't canceled
> to support (as i know) that is lustre 1.4 time. RHEL5 that is 1.6 time.
> but today we have talk about dropping lustre 1.8 clients support...
> 
It is already answered by Andreas. We can reach a more stable point for Lustre client and network protocol. http://lists.lustre.org/pipermail/lustre-devel/2012-December/004187.html

While I don't want to option about dropping 1.8 clients support, I think it is better to have a more stable support matrix than today. And if you are really serious about long term support as enterprise storage providers, most NAS vendors still support nfsv2 today. Forcing everyone to upgrade doesn't seem practical to me...

Cheers,
Tao

> > Cheers,
> > Tao
> >>
> >> Sure, we will need this for the out-of-tree Lustre code, as we do today,
> >> but not
> >> inside the kernel.  The benefit is that the in-tree code will be the
> >> "right"
> >> code for that particular kernel version, and no macros will be needed.
> >>
> >> Cheers, Andreas
> >>
> >>> On Dec 19, 2012, at 04:12, Prakash Surya wrote:
> >>>>>> ]unning.
> >>>>>> That won't be an issue with Lustre, but you get the idea.
> >>>>>
> >>>>> So let me just confirm I understand your issue here.  For example, the
> >>>>> Linux kernel is at 3.12.1 (version numbers are purely hypothetical and
> >>>>> far into the future) which has Lustre 2.6.3 in it.  But RHEL 9's kernel
> >>>>> is only 3.8.1"ish" and has Lustre 2.4.2 (because that's what was in the
> >>>>> upstream Linux 3.8.1 kernel) in it.
> >>>>>
> >>>>> The complaint is that the Lustre (2.4.2) that's in the RHEL 9 kernel
> >>>>> that you are using is too old for some reason?
> >>>>>
> >>>>> So what's the remedy?  You can either (a) download the stand-alone
> >>>>> Lustre module source for the version of Lustre you need and build it
> >>>>> against the RHEL 9 kernel you want to use (assuming they are near
> >>>>> enough
> >>>>> to be compatible -- which is the same situation that exists today) or
> >>>>
> >>>> That is a big assumption, and is most likely false. Currently autoconf
> >>>> maintains the compatibility of Lustre with the different kernel
> >>>> versions.
> >>>> If the client is in tree, are we really going to maintain the same level
> >>>> of autoconf "foo" to be compatible with older kernels? And if not, we
> >>>> would have to maintain a second package, outside of the kernel, which
> >>>> did
> >>>> have this autoconf compatibility layer.
> >>>>
> >>>> I don't think option (a) is the same as what we have now.
> >>>>
> >>>> --
> >>>> Cheers, Prakash
> >>>>
> >>>>> (b) you download the entire upstream kernel that has the version of
> >>>>> Lustre that you want to use and build that.
> >>>>>
> >>>>> It seems to me that (a) is what everyone already has to do all of the
> >>>>> time today anyway (assuming the binary RPM that we ship for the given
> >>>>> vendor kernel is not new enough) and (b) just isn't even possible so
> >>>>> that's gravy.
> >>>>>
> >>>>> There might be something obvious that I'm missing, but I'm failing to
> >>>>> see how having Lustre (client) in the kernel is any worse than the
> >>>>> status quo (basically scenario (a) above) and indeed should provide
> >>>>> Lustre compatibility to the current stable Linux sooner than we can
> >>>>> typically turn it around.
> >>>>>
> >>>>> Cheers,
> >>>>> b.
> >>>>>
> >>>
> >>> ----------------------------------------------
> >>> Alexey Lyahkov
> >>> alexey_lyashkov at xyratex.com
> >>>
> >>>
> >>> _______________________________________________
> >>> Lustre-devel mailing list
> >>> Lustre-devel at lists.lustre.org
> >>> http://lists.lustre.org/mailman/listinfo/lustre-devel
> >>>
> >>
> >>
> >> Cheers, Andreas
> >> --
> >> Andreas Dilger
> >>
> >> Lustre Software Architect
> >> Intel High Performance Data Division
> >>
> >>
> >> _______________________________________________
> >> Lustre-devel mailing list
> >> Lustre-devel at lists.lustre.org
> >> http://lists.lustre.org/mailman/listinfo/lustre-devel
> >
> 
> ----------------------------------------------
> Alexey Lyahkov
> alexey_lyashkov at xyratex.com
> 
> 
