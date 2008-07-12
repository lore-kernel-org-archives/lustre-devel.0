From: Tom.Wang <Tom.Wang@Sun.COM>
Date: Sat, 12 Jul 2008 11:37:44 -0400
Subject: [Lustre-devel] Vector I/O api
In-Reply-To: <C49D8777.63F0%peter.braam@sun.com>
References: <C49D8777.63F0%peter.braam@sun.com>
Message-ID: <4878CFC8.3040203@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Peter Braam wrote:
> Tom -
>
> In a recent call with CERN the request came up to construct a call 
> that can in parallel transfer an array of extents in a single file to 
> a list of buffers and vice-versa. 
> This call should be executed with read-ahead disabled, it will usually 
> be made when the user is well informed of the I/O that is about to 
> take place.
> Is this easy to get into the Lustre client (using our I/O library)? 
>  Do you have this already for MPI/IO use?
>
> Thanks.
>
> Peter
Hello, Peter

If you mean provide this list buffer read/write API in MPI by our 
library, it is easy.
Because MPI already provide such API, you can define proper 
discontingous buf_type
and file_type of these extents, and use (MPI_File_Write/read_all) to 
read/write these
buffers in one call . We only need disable read-ahead here. So it should 
be easy to
get into our I/O library.

But if you mean provide such API in llite, I am not sure it is easy. 
because it seems we
could only use ioctl to implement such non-posix API IMHO, which always 
has page-size
limit for transferring buffers here? It is probably I misunderstand 
something here.

Thanks
WangDi
>


This kind of list buffers transferring can be implemented with proper 
MPI file_view
> ------------------------------------------------------------------------
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
