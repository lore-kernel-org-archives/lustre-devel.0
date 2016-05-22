From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Sun, 22 May 2016 02:49:19 +0000
Subject: [lustre-devel] [lustre-discuss] more on lustre striping
In-Reply-To: <9ebe9f4c-d5a2-4c93-4f00-49029850cbbe@iodoctors.com>
References: <1ef5a267-334c-be0d-13f4-c0fab917d1bf@iodoctors.com>
	<38EA9F32-3869-43BA-B215-EB2E5BA62FD5@intel.com>
	<f4c0c992-1e1a-41d8-7a04-2fc5182c6b31@iodoctors.com>
	<01EE2B9D-2359-49B5-A50F-E7C2D97E6696@intel.com>
	<44e2353d-3bef-ddd7-f15e-ad4bfdda040f@iodoctors.com>
	<EB476743-98B4-49D3-B436-7F257E3284DD@intel.com>
	<9ebe9f4c-d5a2-4c93-4f00-49029850cbbe@iodoctors.com>
Message-ID: <2C5AD38E-7DB8-4D49-A6FA-46066E2416E7@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

$ nm -g lustre/liblustre/liblustre.so | grep open
0000000000237820 W __open
0000000000237820 W __open64
000000000023ba30 W __opendir
00000000002376c0 T _sysio_open
                 U fopen@@GLIBC_2.2.5
0000000000237820 T open
0000000000237820 W open64
000000000023ba30 T opendir


These are the open symbols we have in the .so
it most certainly intercepts the open syscall
no matter if it comes via open or fopen.

so I suspect you just need to catch __open* stuff and
this will catch both open and fopen for you too.
At least quick googling around seems to confirm this.

All intercepting was done via libsysio (since it reimplemented VFS in userspace),
so if you need more info, perhaps you can consult with Lee Ward who is the main
author of it.
I know he used to read this list too so he might decide to chime in.

On May 21, 2016, at 9:56 PM, John Bauer wrote:

> Oleg
> 
> I can intercept the fopen(), but that does me no good as I can't set the O_LOV_DELAY_CREATE bit.  What I can not intercept is the open() downstream of fopen().  If one examines the symbols in libc you will see there are no unsatisfied externals relating to open, which means there is nothing for the runtime linker to find concerning open's.  I will have a look at the Lustre 1.8 source, but I seriously doubt that the open beneath fopen() was intercepted with LD_PRELOAD.  I would love to find a way to do that.  I could throw away a lot of code. Thanks,  John
> % nm -g /lib64/libc.so.6 | grep open
> 0000000000033d70 T catopen
> 00000000003bfb80 B _dl_open_hook
> 00000000000b9a60 W fdopendir
> 000000000006b140 T fdopen@@GLIBC_2.2.5
> 00000000000755c0 T fmemopen
> 000000000006ba00 W fopen64
> 000000000006bb60 T fopencookie@@GLIBC_2.2.5
> 000000000006ba00 T fopen@@GLIBC_2.2.5
> 00000000000736f0 T freopen
> 0000000000074b50 T freopen64
> 00000000000ead40 T fts_open
> 0000000000022220 T iconv_open
> 000000000006b140 T _IO_fdopen@@GLIBC_2.2.5
> 0000000000077220 T _IO_file_fopen@@GLIBC_2.2.5
> 0000000000077170 T _IO_file_open
> 000000000006ba00 T _IO_fopen@@GLIBC_2.2.5
> 000000000006d1d0 T _IO_popen@@GLIBC_2.2.5
> 000000000006cee0 T _IO_proc_open@@GLIBC_2.2.5
> 0000000000130b20 T __libc_dlopen_mode
> 00000000000e7840 W open
> 00000000000e7840 W __open
> 00000000000ec690 T __open_2
> 00000000000e7840 W open64
> 00000000000e7840 W __open64
> 00000000000ec6b0 T __open64_2
> 00000000000e78d0 W openat
> 00000000000e79b0 T __openat_2
> 00000000000e78d0 W openat64
> 00000000000e79b0 W __openat64_2
> 00000000000f6e00 T open_by_handle_at
> 00000000000340b0 T __open_catalog
> 00000000000b9510 W opendir
> 00000000000f0850 T openlog
> 0000000000073e90 T open_memstream
> 00000000000731b0 T open_wmemstream
> 000000000006d1d0 T popen@@GLIBC_2.2.5
> 000000000012fbd0 W posix_openpt
> 00000000000e6460 T posix_spawn_file_actions_addopen
> %
> John
> 
> On 5/21/2016 7:33 PM, Drokin, Oleg wrote:
>> btw I find it strange that you cannot intercept fopen (and in fact intercepting every library call like that is counterproductive).
>> 
>> We used to have this "liblustre" library, that you an LD_PRELOAD into your application and it would work with Lustre even if you are not root and if Lustre is not mounted on that node
>> (and in fact even if the node is not Linux at all). That had no problems at all to intercept all sorts of opens by intercepting syscalls.
>> I wonder if you can intercept something deeper like sys_open or something like that?
>> Perhaps checkout lustre 1.8 sources (or even 2.1) and see how we did it back there?
>> 
>> On May 21, 2016, at 4:25 PM, John Bauer wrote:
>> 
>> 
>>> Oleg
>>> 
>>> So in my simple test, the second open of the file caused the layout to be created.  Indeed, a write to the original fd did fail.
>>> That complicates things considerably.
>>> 
>>> Disregard the entire topic.
>>> 
>>> Thanks
>>> 
>>> John
>>> 
>>> 
>>> On 5/21/2016 3:08 PM, Drokin, Oleg wrote:
>>> 
>>>> The thing is, when you open a file with no layout (the one you cteate with P_LOB_DELAY_CREATE) for write the next time - 
>>>> the default layout is created just the same as it would have been created on the first open.
>>>> So if you want custom layouts - you do need to insert setstripe call between the creation and actual open for write.
>>>> 
>>>> On the other hand if you open with O_LOV_DELAY_CREATE and then try to write into that fd - you will get a failure.
>>>> 
>>>> 
>>>> On May 21, 2016, at 4:01 PM, John Bauer wrote:
>>>> 
>>>> 
>>>> 
>>>>> Andreas,
>>>>> 
>>>>> Thanks for the reply.  For what it's worth, extending a file that does not have layout set does work.
>>>>> 
>>>>> % rm -f file.dat
>>>>> % ./no_stripe.exe file.dat
>>>>> fd=3
>>>>> % lfs getstripe file.dat
>>>>> file.dat has no stripe info
>>>>> % date >> file.dat
>>>>> % lfs getstripe file.dat
>>>>> file.dat
>>>>> lmm_stripe_count:   1
>>>>> lmm_stripe_size:    1048576
>>>>> lmm_pattern:        1
>>>>> lmm_layout_gen:     0
>>>>> lmm_stripe_offset:  21
>>>>>         obdidx           objid           objid           group
>>>>>             21         6143298       0x5dbd42                0
>>>>> 
>>>>> %
>>>>> The LD_PRELOAD is exactly what I am doing in my I/O library.  Unfortunately, one can not intercept the open() that results from a call to fopen().  That open is hard linked to the open in libc and not satisfied by the runtime linker.  This is what is driving this topic for me. I can not conveniently set the striping for a file opened with fopen() and other functions where the open is called from inside libc. I used to believe that not too many application use stdio for heavy I/O, but I have been come across several recently.
>>>>> 
>>>>> John
>>>>> 
>>>>> On 5/21/2016 12:51 AM, Dilger, Andreas wrote:
>>>>> 
>>>>> 
>>>>>> This is probably getting to be more of a topic for lustre-devel. 
>>>>>> 
>>>>>> There currently isn't any way to do what you ask, since (IIRC) it will cause an error for apps that try to write to the files before the layout is set. 
>>>>>> 
>>>>>> What you could do is to create an LD_PRELOAD library to intercept the open() calls and set O_LOV_DELAY_CREATE and set the layout explicitly for each file. This might be a win if each file needs a different layout, but since it uses two RPCs per file it would be slower than using the default layout. 
>>>>>> 
>>>>>> Cheers, Andreas
>>>>>> 
>>>>>> On May 18, 2016, at 16:46, John Bauer 
>>>>>> 
>>>>>> <bauerj@iodoctors.com>
>>>>>> 
>>>>>>  wrote:
>>>>>> 
>>>>>> 
>>>>>> 
>>>>>>> Since today's topic seems to be Lustre striping, I will revisit a previous line of questions I had.
>>>>>>> 
>>>>>>> Andreas had put me on to O_LOV_DELAY_CREATE which I have been experimenting with. My question is : Is there a way to flag a directory with O_LOV_DELAY_CREATE so that a file created in that directory will be created with O_LOV_DELAY_CREATE also.  Much like a file can inherit a directory's stripe count and stripe size, it would be convenient if a file could also inherit O_LOV_DELAY_CREATE?  That way, for open()s that I can not intercept ( and thus can not set O_LOV_DELAY_CREATE in oflags) , such as those issued by fopen(), I can then get the fd with fileno() and set the striping with ioctl(fd, LL_IOC_LOV_SETSTRIPE, lum).
>>>>>>> 
>>>>>>> Thanks
>>>>>>> 
>>>>>>> John
>>>>>>> -- 
>>>>>>> I/O Doctors, LLC
>>>>>>> 507-766-0378
>>>>>>> 
>>>>>>> 
>>>>>>> 
>>>>>>> bauerj at iodoctors.com
>>>>>>> 
>>>>>>> 
>>>>>>> _______________________________________________
>>>>>>> lustre-discuss mailing list
>>>>>>> 
>>>>>>> 
>>>>>>> lustre-discuss at lists.lustre.org
>>>>>>> http://lists.lustre.org/listinfo.cgi/lustre-discuss-lustre.org
>>>>> -- 
>>>>> I/O Doctors, LLC
>>>>> 507-766-0378
>>>>> 
>>>>> 
>>>>> 
>>>>> bauerj at iodoctors.com
>>>>> 
>>>>> 
>>>>> _______________________________________________
>>>>> lustre-discuss mailing list
>>>>> 
>>>>> 
>>>>> lustre-discuss at lists.lustre.org
>>>>> http://lists.lustre.org/listinfo.cgi/lustre-discuss-lustre.org
>>> -- 
>>> I/O Doctors, LLC
>>> 507-766-0378
>>> 
>>> 
>>> bauerj at iodoctors.com
> 
> -- 
> I/O Doctors, LLC
> 507-766-0378
> 
> bauerj at iodoctors.com
