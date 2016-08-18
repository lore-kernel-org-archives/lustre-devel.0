From: Patrick Farrell <paf@cray.com>
Date: Thu, 18 Aug 2016 22:11:59 +0000
Subject: [lustre-devel] CentOS 6 - Build problems with kmod
In-Reply-To: <88922ad0-ba51-f28f-b062-69b2bcfafa16@llnl.gov>
References: <CY4PR11MB1751486ABC8E7B3723D5549ACB150@CY4PR11MB1751.namprd11.prod.outlook.com>
	<9957200e-17fe-2b8d-ad99-e8dfb5019f12@llnl.gov>,
	<88922ad0-ba51-f28f-b062-69b2bcfafa16@llnl.gov>
Message-ID: <CY4PR11MB1751A30F582F35F12E2543F2CB150@CY4PR11MB1751.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Chris,


I agree with your contention about the kernel symbols, that's why I rebuilt from scratch and reinstalled.  Just did it again.  Still getting the error.


> It sounds like you built your own kernel.  Did you install all the
> resulting kernel packages before building lustre (including any
> devel-related packages)?

Yes, but this process doesn't produce anything other than the kernel RPM.


> Is your custom kernel the newest kernel
> installed on your system?

Yes.  It's the newest and it's what's booted.


So, does anyone have any insight in to what needs to change in the documented build process so I can build and install Lustre on CentOS 6?  (ldisksfs, not ZFS, so I must build the kernel)  It seems likely that I'm missing some symbol RPMs or similar, but kernel-syms is a SuSE only thing, I believe.  I believe Intel is still building and installing ldiskfs Lustre on CentOS 6, so there must be something...?


- Patrick

________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Christopher J. Morrone <morrone2@llnl.gov>
Sent: Thursday, August 18, 2016 3:44:52 PM
To: lustre-devel at lists.lustre.org
Subject: Re: [lustre-devel] CentOS 6 - Build problems with kmod

On 08/18/2016 01:43 PM, Christopher J. Morrone wrote:
> Yes, those instructions should be taken with a huge grain of salt.  For
> instance, instructions for compiling lustre should really employ a

s/should/should NOT/

> custom user and talk about "useradd" and such.  Also, most users can
> skip the whole custom-patched-kernel section.  Hopefully all developers
> will be able to stop that too by the time 2.9.0 comes out.
>
> The error you are seeing almost certainly means that you don't have a
> kernel installed that offers symbols compatible with the kernel that
> lustre was compiled against.
>
> It sounds like you built your own kernel.  Did you install all the
> resulting kernel packages before building lustre (including any
> devel-related packages)?  Is your custom kernel the newest kernel
> installed on your system?
>
> Chris
>
> On 08/18/2016 01:00 PM, Patrick Farrell wrote:
>> Good afternoon,
>>
>>
>> I'm trying to build and install updated Lustre master on CentOS 6 for
>> the first time in a month or two, and I'm having trouble.
>>
>>
>> I use the build procedure documented here:
>>
>> https://wiki.hpdd.intel.com/pages/viewpage.action?pageId=8126821
>>
>>
>> I've got some new kmod-* RPMs, and I need to install those to install
>> Lustre, which is fine, except I get a huge string of messages like this
>> when I try:
>>
>> error: Failed dependencies:
>>         ksym(__init_waitqueue_head) = 0xffc7c184 is needed by
>> kmod-lustre-2.8.56_44_g288e55b_dirty-1.el6.x86_64
>>         ksym(__mutex_init) = 0x4bf79039 is needed by
>> kmod-lustre-2.8.56_44_g288e55b_dirty-1.el6.x86_64
>>
>> I've rebuilt and reinstalled my kernel with this latest version of
>> Lustre.  Error messages remain the same, and I can't install.
>>
>>
>> Any thoughts or advice?
>>
>>
>> - Patrick
>>
>>
>>
>> _______________________________________________
>> lustre-devel mailing list
>> lustre-devel at lists.lustre.org
>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>>
>
> .
>

_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160818/8f9908ea/attachment.htm>
