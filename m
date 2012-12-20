From: Alexey Lyahkov <alexey_lyashkov@xyratex.com>
Date: Thu, 20 Dec 2012 15:06:35 +0400
Subject: [Lustre-devel] OFLAGS change.
In-Reply-To: <1882637210201641A747464075FFC6490715A2@MX101CL02.corp.emc.com>
References: <D01411ED-E27A-4245-8614-86A69F168F95@xyratex.com>
	<CCF78FC7.BD6F%andreas.dilger@intel.com>
	<1882637210201641A747464075FFC6490715A2@MX101CL02.corp.emc.com>
Message-ID: <8D7891D2-223E-4D47-99A3-6A40EE583439@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Dec 20, 2012, at 06:32, Peng, Tao wrote:
>> 
>> 
>>> reason to use autoconf macroses - we can't trust a RHEL/SuSe kernel
>>> version/
> Well, there are situations that autoconf cannot handle properly, such as the open_flag change by upstream commit (8a5e929dd2e05ab4d3d89f58c5e8fca596af8f3a). The change is inline so we cannot tell it without grepping the source file (fs/namei.c) which is likely unavailable when users build Lustre client from source. We currently solved it by putting a LINUX_VERSION_CODE check there but as you see it is not trustworthy when vendors backport patches.
> 
> And IMO, the right way to solve such problems is to put Lustre in upstream/stable kernels and let vendors ship it so that they match in the first place.


static inline int ll_namei_to_lookup_intent_flag(int flag)
{
#if LINUX_VERSION_CODE >= KERNEL_VERSION(3, 1, 0)
<------>flag = (flag & ~O_ACCMODE) | OPEN_FMODE(flag);
#endif
<------>return flag;
}

if i correctly understand - that change have a dependence to the OPEN_FMODE macro - not a kernel version.
so for any kernels have a OPEN_FMODE - we need to use that function, otherwise use flags directly.

----------------------------------------------
Alexey Lyahkov
alexey_lyashkov at xyratex.com
