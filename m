From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Fri, 19 Aug 2016 13:58:26 -0700
Subject: [lustre-devel] CentOS 6 - Build problems with kmod
In-Reply-To: <57B77146.6010201@cray.com>
References: <CY4PR11MB1751486ABC8E7B3723D5549ACB150@CY4PR11MB1751.namprd11.prod.outlook.com>
	<9957200e-17fe-2b8d-ad99-e8dfb5019f12@llnl.gov>
	<88922ad0-ba51-f28f-b062-69b2bcfafa16@llnl.gov>
	<CY4PR11MB1751A30F582F35F12E2543F2CB150@CY4PR11MB1751.namprd11.prod.outlook.com>
	<17c61f0e-5835-b14a-2c56-6dbe01dcdca5@llnl.gov>
	<57B77146.6010201@cray.com>
Message-ID: <665d003f-24fa-66c3-a713-4e8587623b8c@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 08/19/2016 01:51 PM, Patrick Farrell wrote:
> 
> On 08/19/2016 03:44 PM, Christopher J. Morrone wrote:
>> On 08/18/2016 03:11 PM, Patrick Farrell wrote:
>>> Chris,
>>>
>>>
>>> I agree with your contention about the kernel symbols, that's why I
>>> rebuilt from scratch and reinstalled.  Just did it again.  Still getting
>>> the error.
>>>
>>>
>>>> It sounds like you built your own kernel.  Did you install all the
>>>> resulting kernel packages before building lustre (including any
>>>> devel-related packages)?
>>> Yes, but this process doesn't produce anything other than the kernel
>>> RPM.
>> You are saying that literally only one rpm is produced?  If that isn't
>> what your are saying, please list all of the produced rpms, and also
>> list which ones you are installing.
> Yes, one non-source RPM.  I don't install any RPMs as part of the build
> process itself.

You should be installing RPMs as part of the build process.  You should
install Lustre's BuildRequires before building Lustre.

>> If you only have a single kernel rpm, then you almost certainly don't
>> have the correct packages installed to allow Lustre to compile against
>> that kernel.  Lustre is probably compiling against some other installed
>> kernel.
> It's compiling the whole kernel from source, so I don't need any other
> packages.  I build Lustre against the kernel bits directly, in the
> directories where they were built, not by installing any kernel RPMs.

That is only going to work if you don't want to make lustre RPM
packages.  If you want to build RPM packages, you need to follow
standard RPM practices.  In other words, you need to have Lustre's
prerequite packages installed before you build Lustre's RPMs.

So you are going to need to those other kernel packages, and you need to
install them before building Lustre.

Chris
