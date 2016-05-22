From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Sun, 22 May 2016 00:33:59 +0000
Subject: [lustre-devel] [lustre-discuss] more on lustre striping
In-Reply-To: <44e2353d-3bef-ddd7-f15e-ad4bfdda040f@iodoctors.com>
References: <1ef5a267-334c-be0d-13f4-c0fab917d1bf@iodoctors.com>
	<38EA9F32-3869-43BA-B215-EB2E5BA62FD5@intel.com>
	<f4c0c992-1e1a-41d8-7a04-2fc5182c6b31@iodoctors.com>
	<01EE2B9D-2359-49B5-A50F-E7C2D97E6696@intel.com>
	<44e2353d-3bef-ddd7-f15e-ad4bfdda040f@iodoctors.com>
Message-ID: <EB476743-98B4-49D3-B436-7F257E3284DD@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

btw I find it strange that you cannot intercept fopen (and in fact intercepting every library call like that is counterproductive).

We used to have this "liblustre" library, that you an LD_PRELOAD into your application and it would work with Lustre even if you are not root and if Lustre is not mounted on that node
(and in fact even if the node is not Linux at all). That had no problems at all to intercept all sorts of opens by intercepting syscalls.
I wonder if you can intercept something deeper like sys_open or something like that?
Perhaps checkout lustre 1.8 sources (or even 2.1) and see how we did it back there?

On May 21, 2016, at 4:25 PM, John Bauer wrote:

> Oleg
> 
> So in my simple test, the second open of the file caused the layout to be created.  Indeed, a write to the original fd did fail.
> That complicates things considerably.
> 
> Disregard the entire topic.
> 
> Thanks
> 
> John
> 
> 
> On 5/21/2016 3:08 PM, Drokin, Oleg wrote:
>> The thing is, when you open a file with no layout (the one you cteate with P_LOB_DELAY_CREATE) for write the next time - 
>> the default layout is created just the same as it would have been created on the first open.
>> So if you want custom layouts - you do need to insert setstripe call between the creation and actual open for write.
>> 
>> On the other hand if you open with O_LOV_DELAY_CREATE and then try to write into that fd - you will get a failure.
>> 
>> 
>> On May 21, 2016, at 4:01 PM, John Bauer wrote:
>> 
>> 
>>> Andreas,
>>> 
>>> Thanks for the reply.  For what it's worth, extending a file that does not have layout set does work.
>>> 
>>> % rm -f file.dat
>>> % ./no_stripe.exe file.dat
>>> fd=3
>>> % lfs getstripe file.dat
>>> file.dat has no stripe info
>>> % date >> file.dat
>>> % lfs getstripe file.dat
>>> file.dat
>>> lmm_stripe_count:   1
>>> lmm_stripe_size:    1048576
>>> lmm_pattern:        1
>>> lmm_layout_gen:     0
>>> lmm_stripe_offset:  21
>>>         obdidx           objid           objid           group
>>>             21         6143298       0x5dbd42                0
>>> 
>>> %
>>> The LD_PRELOAD is exactly what I am doing in my I/O library.  Unfortunately, one can not intercept the open() that results from a call to fopen().  That open is hard linked to the open in libc and not satisfied by the runtime linker.  This is what is driving this topic for me. I can not conveniently set the striping for a file opened with fopen() and other functions where the open is called from inside libc. I used to believe that not too many application use stdio for heavy I/O, but I have been come across several recently.
>>> 
>>> John
>>> 
>>> On 5/21/2016 12:51 AM, Dilger, Andreas wrote:
>>> 
>>>> This is probably getting to be more of a topic for lustre-devel. 
>>>> 
>>>> There currently isn't any way to do what you ask, since (IIRC) it will cause an error for apps that try to write to the files before the layout is set. 
>>>> 
>>>> What you could do is to create an LD_PRELOAD library to intercept the open() calls and set O_LOV_DELAY_CREATE and set the layout explicitly for each file. This might be a win if each file needs a different layout, but since it uses two RPCs per file it would be slower than using the default layout. 
>>>> 
>>>> Cheers, Andreas
>>>> 
>>>> On May 18, 2016, at 16:46, John Bauer 
>>>> <bauerj@iodoctors.com>
>>>>  wrote:
>>>> 
>>>> 
>>>>> Since today's topic seems to be Lustre striping, I will revisit a previous line of questions I had.
>>>>> 
>>>>> Andreas had put me on to O_LOV_DELAY_CREATE which I have been experimenting with. My question is : Is there a way to flag a directory with O_LOV_DELAY_CREATE so that a file created in that directory will be created with O_LOV_DELAY_CREATE also.  Much like a file can inherit a directory's stripe count and stripe size, it would be convenient if a file could also inherit O_LOV_DELAY_CREATE?  That way, for open()s that I can not intercept ( and thus can not set O_LOV_DELAY_CREATE in oflags) , such as those issued by fopen(), I can then get the fd with fileno() and set the striping with ioctl(fd, LL_IOC_LOV_SETSTRIPE, lum).
>>>>> 
>>>>> Thanks
>>>>> 
>>>>> John
>>>>> -- 
>>>>> I/O Doctors, LLC
>>>>> 507-766-0378
>>>>> 
>>>>> 
>>>>> bauerj at iodoctors.com
>>>>> 
>>>>> _______________________________________________
>>>>> lustre-discuss mailing list
>>>>> 
>>>>> lustre-discuss at lists.lustre.org
>>>>> http://lists.lustre.org/listinfo.cgi/lustre-discuss-lustre.org
>>> -- 
>>> I/O Doctors, LLC
>>> 507-766-0378
>>> 
>>> 
>>> bauerj at iodoctors.com
>>> 
>>> _______________________________________________
>>> lustre-discuss mailing list
>>> 
>>> lustre-discuss at lists.lustre.org
>>> http://lists.lustre.org/listinfo.cgi/lustre-discuss-lustre.org
> 
> -- 
> I/O Doctors, LLC
> 507-766-0378
> 
> bauerj at iodoctors.com
