From: Kossey, Robert <bob.kossey@hp.com>
Date: Mon, 28 Jul 2008 10:38:08 -0400
Subject: [Lustre-devel]  Lustre version patchless kernel?
In-Reply-To: <488DD7C1.7010807@hp.com>
References: <488DD7C1.7010807@hp.com>
Message-ID: <488DD9D0.5080902@hp.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Yes, we see patchless reported on our RHEL5U1 Opteron servers with 
1.6.5.1and 1.6.4.3:

root at njxc4ad ~]# cat /proc/fs/lustre/version
lustre: 1.6.5.1
kernel: patchless
build:  
1.6.5.1-19691231190000-PRISTINE-.cache.OLDRPMS.20080618233454.linux-smp-
2.6.18-53.1.14.el5_lustre.1.6.5.1.x86_64-2.6.18-53.1.14.el5_lustre.1.6.5.1smp
[root at njxc4ad ~]# uname -a
Linux njxc4ad.usa.hp.com 2.6.18-53.1.14.el5_lustre.1.6.5.1smp #1 SMP Wed 
Jun 18
19:45:15 EDT 2008 x86_64 x86_64 x86_64 GNU/Linux
[root at njxc4ad ~]#

[root at ichpcsfsd1 ~]# cat /proc/fs/lustre/version
lustre: 1.6.5
kernel: patchless
build:  
1.6.5-19691231190000-PRISTINE-.usr.src.linux-2.6.18-53.1.13.el5_lustre.1
.6.4.3-2.6.18-53.1.13.el5_lustre.1.6.4.3smp
[root at ichpcsfsd1 ~]# uname -a
Linux ichpcsfsd1 2.6.18-53.1.13.el5_lustre.1.6.4.3smp #1 SMP Sun Feb 17 
08:38:44
EST 2008 x86_64 x86_64 x86_64 GNU/Linux
[root at ichpcsfsd1 ~]#

In  both cases, these nodes are running kernels from the 
kernel-lustre-smp RPMs downloaded from the Sun Lustre site. I don't see 
a bug reported for this, so I will submit one.

Thanks,
Bob
>
>> / We also see this on recent releases like 1.6.5.1.  Why do you 
>> bother to 
> />/ distribute kernel-lustre-smp RPMs if the kernels are not patched?
> /
> MDS and OSS kernels *are* patched.  My 1.6.5 here does not report it's
> patchless:
>
> lustre: 1.6.5
> kernel: 47
> build:  
> 1.6.5-19691231190000-PRISTINE-.cache.OLDRPMS.20080513015618.linux-smp-2.6.9-67.0.7.EL_lustre.1.6.5.i686-2.6.9-67.0.7.EL_lustre.1.6.5smp 
>
>
> If you are using our kernel on your MDS/OSS and it's reporting
> patchless, this indeed is a bug.  Could you please search our bugzilla
> to see if there is a similar bug and if not found, file a bug in our
> bugzilla about it?
>
> b.
>
>
