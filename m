From: John Bauer <bauerj@iodoctors.com>
Date: Fri, 10 Jun 2016 10:28:01 -0500
Subject: [lustre-devel] [lustre-discuss] more on lustre striping
In-Reply-To: <575AB28E.7090404@pittman.co.uk>
References: <1ef5a267-334c-be0d-13f4-c0fab917d1bf@iodoctors.com>
	<38EA9F32-3869-43BA-B215-EB2E5BA62FD5@intel.com>
	<f4c0c992-1e1a-41d8-7a04-2fc5182c6b31@iodoctors.com>
	<01EE2B9D-2359-49B5-A50F-E7C2D97E6696@intel.com>
	<44e2353d-3bef-ddd7-f15e-ad4bfdda040f@iodoctors.com>
	<EB476743-98B4-49D3-B436-7F257E3284DD@intel.com>
	<9ebe9f4c-d5a2-4c93-4f00-49029850cbbe@iodoctors.com>
	<575AB28E.7090404@pittman.co.uk>
Message-ID: <75a3831b-04ad-f8fd-1ec6-17e540d67e1d@iodoctors.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ashley

That is what I have done for this case.  But it does not solve the 
entire problem.  One stdio call that is problematic is the freopen().  
There is no way to pass the fd from open() to an existing FILE *.

Thanks,

John


On 6/10/2016 7:29 AM, Ashley Pittman wrote:
> On 22/05/16 02:56, John Bauer wrote:
>>
>> Oleg
>>
>> I can intercept the fopen(), but that does me no good as I can't set 
>> the O_LOV_DELAY_CREATE bit.  What I can not intercept is the open() 
>> downstream of fopen().  If one examines the symbols in libc you will 
>> see there are no unsatisfied externals relating to open, which means 
>> there is nothing for the runtime linker to find concerning open's.  I 
>> will have a look at the Lustre 1.8 source, but I seriously doubt that 
>> the open beneath fopen() was intercepted with LD_PRELOAD.  I would 
>> love to find a way to do that.  I could throw away a lot of code. 
>> Thanks,  John
>>
>
> Could you not intercept fopen() and implement it with calls to open() 
> and fdopen() yourself which would give you full control over what 
> you're looking for here?
>
> Ashley.

-- 
I/O Doctors, LLC
507-766-0378
bauerj at iodoctors.com
