From: Tom.Wang <Tom.Wang@Sun.COM>
Date: Fri, 22 Aug 2008 14:44:11 -0400
Subject: [Lustre-devel] Readx issue
In-Reply-To: <20080822171805.GZ3392@webber.adilger.int>
References: <48AE46F0.9060105@sun.com> <C4D3A486.57CB%peter.braam@sun.com>
	<20080822171805.GZ3392@webber.adilger.int>
Message-ID: <48AF08FB.8010705@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
> On 8/21/08 10:56 PM, "Tom.Wang" <Tom.Wang@Sun.COM> wrote:
>   
>> Since the target here is to issue the vector read extents req parallel,
>> so I chosed to implement that by read-ahead
>> group io, which is async and parallel. And also by this way, it will not
>> touch other module of lustre.
>>
>> In vector read-ahead, each read request will control their read-ahead by
>> itself, instead of by the current read-ahead window, where multi
>> read-threads(for the same file) use single read ahead window.
>>
>> Because current read-ahead
>>   1)Use a single continuous RA window to control the read ahead.
>>   2)The read-ahead moves forward according to the global RA window(for
>> all the read threads of this file), so it tries to favour all the read
>> threads of the file,
>>     
>
> Tom,
> the current readahead mechanism is done on a per-file-descriptor basis.
> Are the threads in question here actually sharing the same file descriptor
> (i.e. file was opened once, then threads forked and descriptor is copied),
> or is each thread opening the file itself?  In the latter case we _should_
> have a separate readahead window for each thread already...
>
>   
Hi, Andreas
I am not sure which case readx might met, probably in most cases, only 1
read thread for each file.  The point here is that it is hard for readx 
to merge
the discontinuous read-ahead extents in the current read-ahead window, once
several threads access the same file descriptor(although it is rare). 
And also
it is not easy to to control these discontinuous read-ahead extents by 
current
read-ahead window pointers (ras_next_readahead, ras_start/end). So I choose
to put those vector extents to the ll_ra_read and attached to each 
thread instead
of file. And also with this way, you do not need touch current 
read-ahead algorithm
for readx.

Thanks
WangDi
>> This algorithm is not very nice for vector read-ahead. because
>>  1) It is hard to manage the multi discontinuous read-ahead window, for
>> example add/remove the extents from the window will be very subtle.
>>  2) It is hard to favour all the vector read-threads(for the file) by 1
>> single read-ahead window.
>>
>> So I let each vector read threads control their read-ahead themselves,
>> which will make implementation very easy, and it will also not touch
>> original read-ahead algorithm for non-vector read.  If you disagree
>> about this, please tell me.
>>     
>
> Cheers, Andreas
> --
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   
