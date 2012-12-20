From: Alexey Lyahkov <alexey_lyashkov@xyratex.com>
Date: Thu, 20 Dec 2012 20:18:14 +0400
Subject: [Lustre-devel] OFLAGS change.
In-Reply-To: <AE8E737235CD0640B291384BFC2D8A354A3A7744@MX10A.corp.emc.com>
References: <D01411ED-E27A-4245-8614-86A69F168F95@xyratex.com>
	<CCF78FC7.BD6F%andreas.dilger@intel.com>
	<1882637210201641A747464075FFC6490715A2@MX101CL02.corp.emc.com>
	<8D7891D2-223E-4D47-99A3-6A40EE583439@xyratex.com>
	<AE8E737235CD0640B291384BFC2D8A354A3A7744@MX10A.corp.emc.com>
Message-ID: <2A3EBFA8-6539-4378-B146-C0EC72CE6CF2@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I have checked on last kernel from kernel.org, so may be for other kernels that is may wrong..
comments is appreciated. 

some assumption 
- intent.open.file->f_flags filled before call a vfs code for kernels RHEL6 and up (checked for -131 kernel is first), so ANY kernels with OPEN_FMODE macro will have a f_flags filled correctly (checked by __dentry_open for all available kernels).
- for kernels without OPEN_FMODE flag we may trust a flags from intent - because they already have a conversion to FMODE for lover bits.

so we need - 
1) check if OPEN_FMODE exist, use a to conversion via OPEN_FMODE(intent.open.file->f_flags) | ~O_ACCMODE;
2) if that macro don't exist we trust oit->flags as that don't have a FMODE -> O_ flags conversion.

PS.
that is need to pass additional parameter to ll_convert_intent nd->intent.open.file.
may be need better check - when f_flag filled before call a vfs function..





On Dec 20, 2012, at 16:08, Liu, Xuezhao wrote:

> "if i correctly understand - that change have a dependence to the OPEN_FMODE macro - not a kernel version.
> so for any kernels have a OPEN_FMODE - we need to use that function, otherwise use flags directly."
> 
> OPEN_FMODE was introduced at kernel 2.6.34 (5300990c0370e804e49d9a59d928c5d53fb73487).
but exists in RHEL6 kernel - 2.6.32-343 (last 6.4 beta) - patchset for that kernel don't available on RHN, so not able to see which patch introduce it.

> open_to_namei_flags was changed at kernel 3.1 (8a5e929dd2e05ab4d3d89f58c5e8fca596af8f3a).
> So we cannot only depend on OPEN_FMODE for that.
> 
if you look to tree - changes was applied to code what to restore a O_ flags from FMODE_ part of open flags.
FS (like xfs) want to use a FMODE continue to use a OPEN_FMODE and FMODE_ macroses 


> Thanks,
> Xuezhao
> -----Original Message-----
> From: lustre-devel-bounces at lists.lustre.org [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Alexey Lyahkov
> Sent: 2012?12?20? 19:07
> To: Peng, Tao
> Cc: hpdd-discuss at lists.01.org; WC-Discuss; <lustre-devel@lists.lustre.org>
> Subject: [Lustre-devel] OFLAGS change.
> 
> 
> On Dec 20, 2012, at 06:32, Peng, Tao wrote:
>>> 
>>> 
>>>> reason to use autoconf macroses - we can't trust a RHEL/SuSe kernel 
>>>> version/
>> Well, there are situations that autoconf cannot handle properly, such as the open_flag change by upstream commit (8a5e929dd2e05ab4d3d89f58c5e8fca596af8f3a). The change is inline so we cannot tell it without grepping the source file (fs/namei.c) which is likely unavailable when users build Lustre client from source. We currently solved it by putting a LINUX_VERSION_CODE check there but as you see it is not trustworthy when vendors backport patches.
>> 
>> And IMO, the right way to solve such problems is to put Lustre in upstream/stable kernels and let vendors ship it so that they match in the first place.
> 
> 
> static inline int ll_namei_to_lookup_intent_flag(int flag) { #if LINUX_VERSION_CODE >= KERNEL_VERSION(3, 1, 0) <------>flag = (flag & ~O_ACCMODE) | OPEN_FMODE(flag); #endif <------>return flag; }
> 
> if i correctly understand - that change have a dependence to the OPEN_FMODE macro - not a kernel version.
> so for any kernels have a OPEN_FMODE - we need to use that function, otherwise use flags directly.
> 
> ----------------------------------------------
> Alexey Lyahkov
> alexey_lyashkov at xyratex.com
> 
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 

----------------------------------------------
Alexey Lyahkov
alexey_lyashkov at xyratex.com
