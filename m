From: John Bauer <bauerj@iodoctors.com>
Date: Sat, 21 May 2016 15:01:22 -0500
Subject: [lustre-devel] [lustre-discuss] more on lustre striping
In-Reply-To: <38EA9F32-3869-43BA-B215-EB2E5BA62FD5@intel.com>
References: <1ef5a267-334c-be0d-13f4-c0fab917d1bf@iodoctors.com>
	<38EA9F32-3869-43BA-B215-EB2E5BA62FD5@intel.com>
Message-ID: <f4c0c992-1e1a-41d8-7a04-2fc5182c6b31@iodoctors.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas,

Thanks for the reply.  For what it's worth, extending a file that does 
not have layout set does work.

    % *rm -f file.dat*
    % *./no_stripe.exe file.dat*
    fd=3
    % *lfs getstripe file.dat*
    file.dat has no stripe info
    % *date >> file.dat*
    % *lfs getstripe file.dat*
    file.dat
    lmm_stripe_count:   1
    lmm_stripe_size:    1048576
    lmm_pattern:        1
    lmm_layout_gen:     0
    lmm_stripe_offset:  21
             obdidx           objid           objid           group
                 21         6143298       0x5dbd42                0

    %

The LD_PRELOAD is exactly what I am doing in my I/O library. 
Unfortunately, one can not intercept the open() that results from a call 
to fopen().  That open is hard linked to the open in libc and not 
satisfied by the runtime linker.  This is what is driving this topic for 
me. I can not conveniently set the striping for a file opened with 
fopen() and other functions where the open is called from inside libc. I 
used to believe that not too many application use stdio for heavy I/O, 
but I have been come across several recently.

John

On 5/21/2016 12:51 AM, Dilger, Andreas wrote:
> This is probably getting to be more of a topic for lustre-devel.
>
> There currently isn't any way to do what you ask, since (IIRC) it will 
> cause an error for apps that try to write to the files before the 
> layout is set.
>
> What you could do is to create an LD_PRELOAD library to intercept the 
> open() calls and set O_LOV_DELAY_CREATE and set the layout explicitly 
> for each file. This might be a win if each file needs a different 
> layout, but since it uses two RPCs per file it would be slower than 
> using the default layout.
>
> Cheers, Andreas
>
> On May 18, 2016, at 16:46, John Bauer <bauerj@iodoctors.com 
> <mailto:bauerj@iodoctors.com>> wrote:
>
>> Since today's topic seems to be Lustre striping, I will revisit a 
>> previous line of questions I had.
>>
>> Andreas had put me on to O_LOV_DELAY_CREATE which I have been 
>> experimenting with. My question is : Is there a way to flag a 
>> directory with O_LOV_DELAY_CREATE so that a file created in that 
>> directory will be created with O_LOV_DELAY_CREATE also.  Much like a 
>> file can inherit a directory's stripe count and stripe size, it would 
>> be convenient if a file could also inherit O_LOV_DELAY_CREATE? That 
>> way, for open()s that I can not intercept ( and thus can not set 
>> O_LOV_DELAY_CREATE in oflags) , such as those issued by fopen(), I 
>> can then get the fd with fileno() and set the striping withioctl(fd, 
>> LL_IOC_LOV_SETSTRIPE, lum).
>>
>> Thanks
>>
>> John
>>
>> -- 
>> I/O Doctors, LLC
>> 507-766-0378
>> bauerj at iodoctors.com
>> _______________________________________________
>> lustre-discuss mailing list
>> lustre-discuss at lists.lustre.org <mailto:lustre-discuss@lists.lustre.org>
>> http://lists.lustre.org/listinfo.cgi/lustre-discuss-lustre.org

-- 
I/O Doctors, LLC
507-766-0378
bauerj at iodoctors.com

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160521/35b3264d/attachment-0001.htm>
