From: Patrick Farrell <paf@cray.com>
Date: Fri, 19 Aug 2016 15:51:18 -0500
Subject: [lustre-devel] CentOS 6 - Build problems with kmod
In-Reply-To: <17c61f0e-5835-b14a-2c56-6dbe01dcdca5@llnl.gov>
References: <CY4PR11MB1751486ABC8E7B3723D5549ACB150@CY4PR11MB1751.namprd11.prod.outlook.com>
	<9957200e-17fe-2b8d-ad99-e8dfb5019f12@llnl.gov>
	<88922ad0-ba51-f28f-b062-69b2bcfafa16@llnl.gov>
	<CY4PR11MB1751A30F582F35F12E2543F2CB150@CY4PR11MB1751.namprd11.prod.outlook.com>
	<17c61f0e-5835-b14a-2c56-6dbe01dcdca5@llnl.gov>
Message-ID: <57B77146.6010201@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On 08/19/2016 03:44 PM, Christopher J. Morrone wrote:
> On 08/18/2016 03:11 PM, Patrick Farrell wrote:
>> Chris,
>>
>>
>> I agree with your contention about the kernel symbols, that's why I
>> rebuilt from scratch and reinstalled.  Just did it again.  Still getting
>> the error.
>>
>>
>>> It sounds like you built your own kernel.  Did you install all the
>>> resulting kernel packages before building lustre (including any
>>> devel-related packages)?
>> Yes, but this process doesn't produce anything other than the kernel RPM.
> You are saying that literally only one rpm is produced?  If that isn't
> what your are saying, please list all of the produced rpms, and also
> list which ones you are installing.
Yes, one non-source RPM.  I don't install any RPMs as part of the build 
process itself.
>
> If you only have a single kernel rpm, then you almost certainly don't
> have the correct packages installed to allow Lustre to compile against
> that kernel.  Lustre is probably compiling against some other installed
> kernel.
It's compiling the whole kernel from source, so I don't need any other 
packages.  I build Lustre against the kernel bits directly, in the 
directories where they were built, not by installing any kernel RPMs.  I 
just extract the kernel source, patch it, and then build it, then build 
Lustre against the results.  The path for Lustre ./configure 
--with-linux[or whatever that option is]= is down in the build 
directories for the kernel.  (It's definitely not building against 
another installed kernel - I can make modifications  in this source and 
have them show up on the nodes where I install Lustre and this kernel.)
>>> Is your custom kernel the newest kernel
>>> installed on your system?
>> Yes.  It's the newest and it's what's booted.
>> So, does anyone have any insight in to what needs to change in the
>> documented build process so I can build and install Lustre on CentOS 6?
>>   (ldisksfs, not ZFS, so I must build the kernel)  It seems likely that
>> I'm missing some symbol RPMs or similar, but kernel-syms is a SuSE only
>> thing, I believe.  I believe Intel is still building and installing
>> ldiskfs Lustre on CentOS 6, so there must be something...?
> There aren't separate "symbol" rpms for RHEL.
>
> I still think that it is likely that you compiled against a kernel on
> your build node that either does not exist on your lustre node, or the
> kernel that lustre compiled about on your build node was old enough that
> its symbols are incompatible with the booted kernel on your lustre node.
>
> Here are somethings that you can try to eliminate problems:
>
> 1) Remove the lustre-patched kernel altogether.  Purge it from your
> system.  Build Lustre against the stock kernel.
>
> 2) Figure out which kernel you are actually compiling against.  Or at
> the very least, which ones your lustre packages are compatible with.
>
> I would probably do one or both of these:
>
> - Run "rpm -qp --requires kmod-lustre-<whatever>.rpm".  Pick out a few
> of the required kernel symbols for which you saw complaints when trying
> to install your kernel.  This will eliminate the issue of your kernel
> build that seems to be going wrong.  You can come back to this later
> when you verify that the lustre build is working correctly.
>
> - Run "rpm -q --provides" on each installed kernel package (the packages
> that have the name of the form 'kernel-<version>'.  Rum that output
> through grep a few times for each of the specific symbol names that you
> picked in the previous step.  For example:
>
> # rpm -q --provides kernel-3.10.0-327.28.2.1chaos.ch6.x86_64 |grep
> __mutex_init
> kernel(__mutex_init) = 0x9a025cd5
>
> Now, compare the hex symbol version required by the kmod-lustre package
> with the hex symbol versions provided by the various kernels that you
> currently have installed.  Which are offering compatible symbols?
>
> For instance:
>
> # rpm -qp --requires
> kmod-lustre-2.8.0_0.0.llnlpreview.33-1.ch6.x86_64.rpm | grep __mutex_init
> kernel(__mutex_init) = 0x9a025cd5
>
> Look, they match!  I can install this lustre modules with this kernel
> installed, and have no rpm requirement complaints.
>
> You are going to find that you do _not_ have a kernel package installed
> that offers the symbols that the kmod-lustre- package(s) require.
>
> Chris
>
>
>> - Patrick
>>
>> ------------------------------------------------------------------------
>> *From:* lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf
>> of Christopher J. Morrone <morrone2@llnl.gov>
>> *Sent:* Thursday, August 18, 2016 3:44:52 PM
>> *To:* lustre-devel at lists.lustre.org
>> *Subject:* Re: [lustre-devel] CentOS 6 - Build problems with kmod
>>   
>> On 08/18/2016 01:43 PM, Christopher J. Morrone wrote:
>>> Yes, those instructions should be taken with a huge grain of salt.  For
>>> instance, instructions for compiling lustre should really employ a
>> s/should/should NOT/
>>
>>> custom user and talk about "useradd" and such.  Also, most users can
>>> skip the whole custom-patched-kernel section.  Hopefully all developers
>>> will be able to stop that too by the time 2.9.0 comes out.
>>>
>>> The error you are seeing almost certainly means that you don't have a
>>> kernel installed that offers symbols compatible with the kernel that
>>> lustre was compiled against.
>>>
>>> It sounds like you built your own kernel.  Did you install all the
>>> resulting kernel packages before building lustre (including any
>>> devel-related packages)?  Is your custom kernel the newest kernel
>>> installed on your system?
>>>
>>> Chris
>>>
>>> On 08/18/2016 01:00 PM, Patrick Farrell wrote:
>>>> Good afternoon,
>>>>
>>>>
>>>> I'm trying to build and install updated Lustre master on CentOS 6 for
>>>> the first time in a month or two, and I'm having trouble.
>>>>
>>>>
>>>> I use the build procedure documented here:
>>>>
>>>> https://wiki.hpdd.intel.com/pages/viewpage.action?pageId=8126821
>>>>
>>>>
>>>> I've got some new kmod-* RPMs, and I need to install those to install
>>>> Lustre, which is fine, except I get a huge string of messages like this
>>>> when I try:
>>>>
>>>> error: Failed dependencies:
>>>>          ksym(__init_waitqueue_head) = 0xffc7c184 is needed by
>>>> kmod-lustre-2.8.56_44_g288e55b_dirty-1.el6.x86_64
>>>>          ksym(__mutex_init) = 0x4bf79039 is needed by
>>>> kmod-lustre-2.8.56_44_g288e55b_dirty-1.el6.x86_64
>>>>
>>>> I've rebuilt and reinstalled my kernel with this latest version of
>>>> Lustre.  Error messages remain the same, and I can't install.
>>>>
>>>>
>>>> Any thoughts or advice?
>>>>
>>>>
>>>> - Patrick
>>>>
>>>>
>>>>
>>>> _______________________________________________
>>>> lustre-devel mailing list
>>>> lustre-devel at lists.lustre.org
>>>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>>>>
>>> .
>>>
>> _______________________________________________
>> lustre-devel mailing list
>> lustre-devel at lists.lustre.org
>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
