From: Tom.Wang <Tom.Wang@Sun.COM>
Date: Sat, 12 Jul 2008 14:15:25 -0400
Subject: [Lustre-devel] Vector I/O api
In-Reply-To: <00e401c8e43e$e1775aa0$0281a8c0@ebpc>
References: <C49D8777.63F0%peter.braam@sun.com> <4878CFC8.3040203@sun.com>
	<00e401c8e43e$e1775aa0$0281a8c0@ebpc>
Message-ID: <4878F4BD.9020403@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

Yes, I just check source, we could use sys_readv here.
But there are a limit of 1024 IO segments for each call, maybe it
should not be a problem here. Actually, llite already include such
api (ll_file_readv/writev). Then it should be easy to implement this
by our lib. Sorry for the previous confuse reply.

Thanks
WangDi

Eric Barton wrote:
> Wangdi,
>
> There seems to be some momentum behind getting readx/writex 
> adopted as posix standard system calls.  That seems the right
> API to exploit (or anticipate if it's not implemented yet).
>
> Note that the memory and file descriptors are not required to
> be isomorphic (i.e. file and memory fragments don't have to
> correspond directly).
>
> struct iovec {
>         void   *iov_base; /* Starting address */
>         size_t  iov_len;  /* Number of bytes */
> };
>
> struct xtvec {
>         off_t   xtv_off; /* Starting file offset */
>         size_t  xtv_len; /* Number of bytes */
> };
>
> ssize_t readx(int fd, const struct iovec *iov, size_t iov_count,
>               struct xtvec *xtv, size_t xtv_count);
>
> ssize_t writex(int fd, const struct iovec *iov, size_t iov_count,
>                struct xtvec *xtv, size_t xtv_count);
>
>     Cheers,
>               Eric
>
>
>   
>> -----Original Message-----
>> From: lustre-devel-bounces at lists.lustre.org [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Tom.Wang
>> Sent: 12 July 2008 4:38 PM
>> To: Peter Braam
>> Cc: lustre-devel
>> Subject: Re: [Lustre-devel] Vector I/O api
>>
>>
>> Peter Braam wrote:
>>     
>>> Tom -
>>>
>>> In a recent call with CERN the request came up to construct a call 
>>> that can in parallel transfer an array of extents in a single file to 
>>> a list of buffers and vice-versa. 
>>> This call should be executed with read-ahead disabled, it will usually 
>>> be made when the user is well informed of the I/O that is about to 
>>> take place.
>>> Is this easy to get into the Lustre client (using our I/O library)? 
>>>  Do you have this already for MPI/IO use?
>>>
>>> Thanks.
>>>
>>> Peter
>>>       
>> Hello, Peter
>>
>> If you mean provide this list buffer read/write API in MPI by our 
>> library, it is easy.
>> Because MPI already provide such API, you can define proper 
>> discontingous buf_type
>> and file_type of these extents, and use (MPI_File_Write/read_all) to 
>> read/write these
>> buffers in one call . We only need disable read-ahead here. So it should 
>> be easy to
>> get into our I/O library.
>>
>> But if you mean provide such API in llite, I am not sure it is easy. 
>> because it seems we
>> could only use ioctl to implement such non-posix API IMHO, which always 
>> has page-size
>> limit for transferring buffers here? It is probably I misunderstand 
>> something here.
>>
>> Thanks
>> WangDi
>>     
>> This kind of list buffers transferring can be implemented with proper 
>> MPI file_view
>>     
>>> ------------------------------------------------------------------------
>>>
>>> _______________________________________________
>>> Lustre-devel mailing list
>>> Lustre-devel at lists.lustre.org
>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>>   
>>>       
>> -- 
>> Regards,
>> Tom Wangdi    
>> --
>> Sun Lustre Group
>> System Software Engineer 
>> http://www.sun.com
>>
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>
>>     
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   


-- 
Regards,
Tom Wangdi    
--
Sun Lustre Group
System Software Engineer 
http://www.sun.com
