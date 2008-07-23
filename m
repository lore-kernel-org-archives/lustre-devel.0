From: Kossey, Robert <bob.kossey@hp.com>
Date: Tue, 22 Jul 2008 23:22:15 -0400
Subject: [Lustre-devel] Lustre version patchless kernel?
In-Reply-To: <4886A29C.2000009@hp.com>
References: <4886A29C.2000009@hp.com>
Message-ID: <4886A3E7.6050904@hp.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We also see this on recent releases like 1.6.5.1.  Why do you bother to 
distribute kernel-lustre-smp RPMs if the kernels are not patched?

Thanks,
Bob

>> / 
> />/ For the lustre version, the kernel portion indicates patchless...
> />/ Should it be something else?
> />/ />/ [root at operon22 
> <http://lists.lustre.org/mailman/listinfo/lustre-devel> lustre]# more 
> /proc/fs/lustre/version
> />/ > lustre: 1.9.50
> />/ > kernel: patchless
> />/ > build:  
> 1.9.50-19691231190000-PRISTINE-.extra.linux-2.6.18-92.1.6-2.6.18-92.1.6-lustre-1.9.50 
>
> /
> This is correct.  For patched kernels there will be a version number 
> here,
> indicating the VFS patch API version number.  This hasn't changed in a
> long time because we are no longer changing the kernel VFS patches, and
> only a few older kernels still need them.
>
> Cheers, Andreas
> -- 
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
>
>
