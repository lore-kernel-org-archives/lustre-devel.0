From: Andreas Dilger <adilger@sun.com>
Date: Mon, 28 Jul 2008 10:07:49 -0600
Subject: [Lustre-devel] Lustre version patchless kernel?
In-Reply-To: <1217250183.22114.110.camel@pc.ilinx>
References: <4886A29C.2000009@hp.com> <4886A3E7.6050904@hp.com>
	<1217250183.22114.110.camel@pc.ilinx>
Message-ID: <20080728160749.GB3342@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jul 28, 2008  09:03 -0400, Brian J. Murrell wrote:
> On Tue, 2008-07-22 at 23:22 -0400, Kossey, Robert wrote:
> > We also see this on recent releases like 1.6.5.1.  Why do you bother to 
> > distribute kernel-lustre-smp RPMs if the kernels are not patched?
> 
> MDS and OSS kernels *are* patched.  My 1.6.5 here does not report it's
> patchless:
> 
> lustre: 1.6.5
> kernel: 47
> build:  1.6.5-19691231190000-PRISTINE-.cache.OLDRPMS.20080513015618.linux-smp-2.6.9-67.0.7.EL_lustre.1.6.5.i686-2.6.9-67.0.7.EL_lustre.1.6.5smp
> 
> If you are using our kernel on your MDS/OSS and it's reporting
> patchless, this indeed is a bug.  Could you please search our bugzilla
> to see if there is a similar bug and if not found, file a bug in our
> bugzilla about it?

Brian,
you are being confused by exactly what "patchless" means.  In the context
here, "patchless" means "no VFS patches" and that "clients can run on
patchless kernels".

This has nothing to do with whether the kernel has any of our patches on
it.  Any server kernel HAS to have patches in order to run.

The fact that your kernel reports a "kernel: 47" is because that is the
version of the VFS patch API that is being used on your RHEL4 2.6.9 kernel.
Newer kernels (RHEL5, SLES10, vanilla 2.6.16+) will report "patchless"
here.


Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
