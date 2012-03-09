From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 9 Mar 2012 15:36:49 +0800
Subject: [Lustre-devel] oldest lustre supported SUSE kernel
In-Reply-To: <F19688880B763E40B28B2B462677FBF805EC1D87AC@MX09A.corp.emc.com>
References: <F19688880B763E40B28B2B462677FBF805E803B132@MX09A.corp.emc.com>
	<9C0BB3E3-D296-42A0-89EA-67F299215215@whamcloud.com>
	<F19688880B763E40B28B2B462677FBF805EC1D87AC@MX09A.corp.emc.com>
Message-ID: <A9B334AF-99CD-4D1B-91ED-277FEB9E8282@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2012-03-08, at 10:55 PM, <tao.peng@emc.com> <tao.peng@emc.com> wrote:
>> Andreas Dilger <adilger@whamcloud.com> wrote:
>> On 2012-02-06, at 2:53, <tao.peng@emc.com> wrote:
>>> As I know, the oldest lustre supported RHEL kernel is 2.6.18-latest. What is the oldest SUSE kernel?
>> 
>> 2.6.32-latest?
>> 
>> That depends on which version of Lustre you are asking about, and whether you are asking about the client or server.
>> 
>> For Lustre 2.2+ servers it will be SLES11 SP1 (2.6.32), since it matches RHEL6 (2.6.32).
>> 
>> For clients it is RHEL5 (2.6.18) and SLES11 SP0 (2.6.27).
> 
> We found that latest master branch doesn't build client for SLES11 SP0 (2.6.27). Does it mean master has moved on dropping SLES11 SP0 or it should be fixed?

This looks like the page_mkwrite() prototype changing from "struct page *" (which is in kernels before 2.6.29) to "struct vm_fault *" (which is used in later kernels).  I don't have a SLES11 SP0 kernel available to check which one it is using, but it should be the "struct page *" based on the kernel version.  This should already be handled by the check for HAVE_VM_OP_FAULT, but possibly this is broken in newer versions of the SP0 kernel?

It often happens that vendor kernels backport code/APIs from newer kernels in order to make porting other drivers/filesystem code easier.

As you can tell, we do not build the SLES11 SP0 client ourselves automatically, only the SP1 client, but if the effort is not huge it would be preferable to keep this client working.  We typically try to keep the range of working clients as large as possible, since administrators may not have as much control over the running clients as they do over the servers.

I would guess (without having looked at the SP0 kernel) that it may just be possible to change lustre/autoconf/lustre-core.m4 to check this prototype, and move the two ll_page_mkwrite() helpers into their own "#ifdef HAVE_PAGE_MKWRITE_VM_FAULT" section separate from HAVE_VM_OP_FAULT.

If this analysis is incorrect, I apologize, but I'm travelling and unable to download the whole kernel at this time.

Cheers, Andreas

> From: Zhang, Kelly 
> Sent: Thursday, March 08, 2012 6:44 PM
> To: Peng, Tao
> Cc: China COE FastData
> Subject: RE: Conversation with Zhang, Kelly
> 
> The latest Lustre code also fails on suse11SP0(kernel version  linux-2.6.27.19-5.1), when building Lustre:
> cc1: warnings being treated as errors
> /home/master/kernel/rpmbuild/BUILD/lustre-2.2.50/lustre/llite/llite_mmap.c:585: error: initialization from incompatible pointer type
> make[8]: *** [/home/master/kernel/rpmbuild/BUILD/lustre-2.2.50/lustre/llite/llite_mmap.o] Error 1
> make[7]: *** [/home/master/kernel/rpmbuild/BUILD/lustre-2.2.50/lustre/llite] Error 2
> make[6]: *** [/home/master/kernel/rpmbuild/BUILD/lustre-2.2.50/lustre] Error 2
> make[5]: *** [_module_/home/master/kernel/rpmbuild/BUILD/lustre-2.2.50] Error 2
> make[5]: Leaving directory `/var/tmp/kernel-source-2.6.27.19-build/usr/src/linux-2.6.27.19-5.1'
> make[4]: *** [modules] Error 2
> make[4]: Leaving directory `/home/master/kernel/rpmbuild/BUILD/lustre-2.2.50'
> make[3]: *** [all-recursive] Error 1
> make[3]: Leaving directory `/home/master/kernel/rpmbuild/BUILD/lustre-2.2.50'
> make[2]: *** [all] Error 2
> make[2]: Leaving directory `/home/master/kernel/rpmbuild/BUILD/lustre-2.2.50'
> error: Bad exit status from /var/tmp/rpm-tmp.76807 (%build)
> 


Cheers, Andreas
--
Andreas Dilger                       Whamcloud, Inc.
Principal Lustre Engineer            http://www.whamcloud.com/
