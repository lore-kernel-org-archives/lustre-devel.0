From: Peter Braam <Peter.Braam@Sun.COM>
Date: Sat, 12 Jul 2008 22:30:14 -0600
Subject: [Lustre-devel] Vector I/O api
In-Reply-To: <48796EA6.1060707@sun.com>
Message-ID: <C49EE0F6.6425%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This seems fundamental enough that it should be implemented in the kernel.

We would get far too many threads.

The files may well be used again, so they should be cached.

So I think direct I/O is not the right path to get there.

peter


On 7/12/08 8:55 PM, "jay" <Jinshan.Xiong@Sun.COM> wrote:

> 
> Sounds like what customer needs is just a non-cache read/write? So how
> likely to implement it via directIO, which would be multithreaded
> driven, and each for a stripe to get better performance.. We don't need
> to put it in kernel side at all
> 
> jay
> 
> Tom.Wang wrote:
>> Hello,
>> 
>> Unfortunately, Readx/writex is still not included in linux kernel yet.
>> 
>> So we may have these 2 options:
>> 
>> 1) Use ioctl to transfer iovec and xvetc to llite, and then do
>> read/write for
>>     each IO sec.  Not sure if nikita's CLIO did something to minimize these
>>     IO's round trip.
>>    
>> or
>> 
>> 2) Provide such API in  liblustreapi.a, then do each read/write for each
>> IO sec
>>     there, where we can also use "read_all first, then copy the buffer
>>     to each seg" to minimize the number of round trips. But it depends
>> on the
>>     distance between the disjoint extents. And also it may need extra
>> buffer allocation,
>>     If putting this list buffer API to llite is a *must* requirement.
>> Forget this option.
>> 
>> Thanks
>> WangDi
>> 
>> Peter Braam wrote:
>>   
>>> Hi -
>>> 
>>> 1024 segments is fine.
>>> b
>>> Readv is the wrong call - it reads contiguous areas from files.
>>> 
>>> Readx/writex sound good, but making this available asap through our I/O
>>> library is important.
>>> 
>>> It should be coded to somewhat minimize the number of round trips over the
>>> network to get the I/O done.
>>> 
>>> So what are our options?
>>> 
>>> 
>>> On 7/12/08 12:15 PM, "Tom.Wang" <Tom.Wang@Sun.COM> wrote:
>>> 
>>>   
>>>     
>>>> Hello,
>>>> 
>>>> Yes, I just check source, we could use sys_readv here.
>>>> But there are a limit of 1024 IO segments for each call, maybe it
>>>> should not be a problem here. Actually, llite already include such
>>>> api (ll_file_readv/writev). Then it should be easy to implement this
>>>> by our lib. Sorry for the previous confuse reply.
>>>> 
>>>> Thanks
>>>> WangDi
>>>> 
>>>> Eric Barton wrote:
>>>>     
>>>>       
>>>>> Wangdi,
>>>>> 
>>>>> There seems to be some momentum behind getting readx/writex
>>>>> adopted as posix standard system calls.  That seems the right
>>>>> API to exploit (or anticipate if it's not implemented yet).
>>>>> 
>>>>> Note that the memory and file descriptors are not required to
>>>>> be isomorphic (i.e. file and memory fragments don't have to
>>>>> correspond directly).
>>>>> 
>>>>> struct iovec {
>>>>>         void   *iov_base; /* Starting address */
>>>>>         size_t  iov_len;  /* Number of bytes */
>>>>> };
>>>>> 
>>>>> struct xtvec {
>>>>>         off_t   xtv_off; /* Starting file offset */
>>>>>         size_t  xtv_len; /* Number of bytes */
>>>>> };
>>>>> 
>>>>> ssize_t readx(int fd, const struct iovec *iov, size_t iov_count,
>>>>>               struct xtvec *xtv, size_t xtv_count);
>>>>> 
>>>>> ssize_t writex(int fd, const struct iovec *iov, size_t iov_count,
>>>>>                struct xtvec *xtv, size_t xtv_count);
>>>>> 
>>>>>     Cheers,
>>>>>               Eric
>>>>> 
>>>>> 
>>>>>   
>>>>>       
>>>>>         
>>>>>> -----Original Message-----
>>>>>> From: lustre-devel-bounces at lists.lustre.org
>>>>>> [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Tom.Wang
>>>>>> Sent: 12 July 2008 4:38 PM
>>>>>> To: Peter Braam
>>>>>> Cc: lustre-devel
>>>>>> Subject: Re: [Lustre-devel] Vector I/O api
>>>>>> 
>>>>>> 
>>>>>> Peter Braam wrote:
>>>>>>     
>>>>>>         
>>>>>>           
>>>>>>> Tom -
>>>>>>> 
>>>>>>> In a recent call with CERN the request came up to construct a call
>>>>>>> that can in parallel transfer an array of extents in a single file to
>>>>>>> a list of buffers and vice-versa.
>>>>>>> This call should be executed with read-ahead disabled, it will usually
>>>>>>> be made when the user is well informed of the I/O that is about to
>>>>>>> take place.
>>>>>>> Is this easy to get into the Lustre client (using our I/O library)?
>>>>>>>  Do you have this already for MPI/IO use?
>>>>>>> 
>>>>>>> Thanks.
>>>>>>> 
>>>>>>> Peter
>>>>>>>       
>>>>>>>           
>>>>>>>            
>>>>>> Hello, Peter
>>>>>> 
>>>>>> If you mean provide this list buffer read/write API in MPI by our
>>>>>> library, it is easy.
>>>>>> Because MPI already provide such API, you can define proper
>>>>>> discontingous buf_type
>>>>>> and file_type of these extents, and use (MPI_File_Write/read_all) to
>>>>>> read/write these
>>>>>> buffers in one call . We only need disable read-ahead here. So it should
>>>>>> be easy to
>>>>>> get into our I/O library.
>>>>>> 
>>>>>> But if you mean provide such API in llite, I am not sure it is easy.
>>>>>> because it seems we
>>>>>> could only use ioctl to implement such non-posix API IMHO, which always
>>>>>> has page-size
>>>>>> limit for transferring buffers here? It is probably I misunderstand
>>>>>> something here.
>>>>>> 
>>>>>> Thanks
>>>>>> WangDi
>>>>>>     
>>>>>> This kind of list buffers transferring can be implemented with proper
>>>>>> MPI file_view
>>>>>>     
>>>>>>         
>>>>>>           
>>>>>>> ------------------------------------------------------------------------
>>>>>>> 
>>>>>>> _______________________________________________
>>>>>>> Lustre-devel mailing list
>>>>>>> Lustre-devel at lists.lustre.org
>>>>>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>>>>>>   
>>>>>>>       
>>>>>>>           
>>>>>>>            
>>>>>> -- 
>>>>>> Regards,
>>>>>> Tom Wangdi  
>>>>>> --
>>>>>> Sun Lustre Group
>>>>>> System Software Engineer
>>>>>> http://www.sun.com
>>>>>> 
>>>>>> _______________________________________________
>>>>>> Lustre-devel mailing list
>>>>>> Lustre-devel at lists.lustre.org
>>>>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>>>>> 
>>>>>>     
>>>>>>         
>>>>>>           
>>>>> _______________________________________________
>>>>> Lustre-devel mailing list
>>>>> Lustre-devel at lists.lustre.org
>>>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>>>>   
>>>>>       
>>>>>         
>>>   
>>>     
>> 
>> 
>>   
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
