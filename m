From: Alex Lyashkov <Alexey.Lyashkov@Sun.COM>
Date: Sat, 08 Dec 2007 07:45:31 +0200
Subject: [Lustre-devel] Problems with make rpms
In-Reply-To: <4759CA18.6040406@datadirectnet.com>
References: <475863ED.30908@datadirectnet.com>
	<1197003271.3550.26.camel@bear.shadowland>
	<4759CA18.6040406@datadirectnet.com>
Message-ID: <1197092731.3550.35.camel@bear.shadowland>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, 2007-12-07 at 17:32 -0500, Kit Westneat wrote:
> Hi Alex,
> 
> This is using 2.6.9-55.0.9.EL_lustre.1.6.3smp, on a Centos4 machine. I 
> used the kernel-source rpm off of lustre.org, and then did make 
> oldconfig and make, after changing the EXTRAVERSION to say smp instead 
> of custom.
> 
> I've attached a capture of make rpms after doing a make clean. Let me 
> know if there is anything else that would be interesting.
In this rpm not included patch which added to kernel series after 1.6.3
released and new kernels for 1.6.4 is not released.
If you want build b1_6, you can have two cases:
1) install quilt and apply rhel4 CFS kernel series into stock redhat
kernel.
2) or need go into lustre/kernel_patches/patches and apply
modpost_external_module_updates_rhel4.patch to you kernel sources by
hand.

after it kernel need to rebuild (for second case not need install
because changes only on build rules and modpost utility)


> 
> Thanks,
> Kit
> 
> Alex Lyashkov wrote:
> > Hello Kit,
> >
> > What kernel you used? is you build new kernel before build lustre?
> > I'm ask about it, because some times ago in kernel series was added new
> > patch for correctly create Module.symvers, if kernel sources not have
> > this patch - this will be produce similar error.
> >
> > On Thu, 2007-12-06 at 16:04 -0500, Kit Westneat wrote:
> >   
> >> Hello,
> >>
> >> I'm trying to compile the b1_6 CVS branch, but I'm running into problems 
> >> with 'make rpms'. 'make' works fine, but when I do 'make rpms' I get:
> >>
> >> make[4]: *** No rule to make target 
> >> `/usr/src/redhat/BUILD/lustre-1.6.4.50/ldiskfs/Module.symvers', needed 
> >> by `Module.symvers'.  Stop.
> >>
> >> Any thoughts?
> >>
> >> Thanks,
> >> Kit
> >>
> >> _______________________________________________
> >> Lustre-devel mailing list
> >> Lustre-devel at clusterfs.com
> >> https://mail.clusterfs.com/mailman/listinfo/lustre-devel
> >>     
> >
> >   
> 
