From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Fri, 19 Aug 2016 14:25:00 -0700
Subject: [lustre-devel] CentOS 6 - Build problems with kmod
In-Reply-To: <57B775AD.6060600@cray.com>
References: <CY4PR11MB1751486ABC8E7B3723D5549ACB150@CY4PR11MB1751.namprd11.prod.outlook.com>
	<9957200e-17fe-2b8d-ad99-e8dfb5019f12@llnl.gov>
	<88922ad0-ba51-f28f-b062-69b2bcfafa16@llnl.gov>
	<CY4PR11MB1751A30F582F35F12E2543F2CB150@CY4PR11MB1751.namprd11.prod.outlook.com>
	<17c61f0e-5835-b14a-2c56-6dbe01dcdca5@llnl.gov>
	<57B77146.6010201@cray.com>
	<665d003f-24fa-66c3-a713-4e8587623b8c@llnl.gov>
	<57B775AD.6060600@cray.com>
Message-ID: <d7419452-5858-561e-4bfe-9855bd0d7f59@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 08/19/2016 02:10 PM, Patrick Farrell wrote:
> 
> On 08/19/2016 03:58 PM, Christopher J. Morrone wrote:
>> On 08/19/2016 01:51 PM, Patrick Farrell wrote:
>>> On 08/19/2016 03:44 PM, Christopher J. Morrone wrote:
>>>> On 08/18/2016 03:11 PM, Patrick Farrell wrote:
>>>>> Chris,
>>>>>
>>>>>
>>>>> I agree with your contention about the kernel symbols, that's why I
>>>>> rebuilt from scratch and reinstalled.  Just did it again.  Still
>>>>> getting
>>>>> the error.
>>>>>
>>>>>
>>>>>> It sounds like you built your own kernel.  Did you install all the
>>>>>> resulting kernel packages before building lustre (including any
>>>>>> devel-related packages)?
>>>>> Yes, but this process doesn't produce anything other than the kernel
>>>>> RPM.
>>>> You are saying that literally only one rpm is produced?  If that isn't
>>>> what your are saying, please list all of the produced rpms, and also
>>>> list which ones you are installing.
>>> Yes, one non-source RPM.  I don't install any RPMs as part of the build
>>> process itself.
>> You should be installing RPMs as part of the build process.  You should
>> install Lustre's BuildRequires before building Lustre.
> Huh.  OK.  I have never needed to do so before when building everything
> from scratch.
> 
> Is this build process documented somewhere, so I can switch to it in my
> testing environment?  I don't know how to invoke a CentOS kernel build
> to create those RPMs I now need.

I don't know.  That sounds like something you should look up in
CentOS/RHEL/Fedora documentation.

Or you maybe you can just skip the custom kernel altogether.  That is
largly what I do.  I haven't built a kernel myself in years, actually.
When LU-684's patch lands, Lustre-owned custom kernels can be a thing of
the past for everyone!

Get on the bandwagon early and stop using Lustre-patched kernels now. :)

Chris
