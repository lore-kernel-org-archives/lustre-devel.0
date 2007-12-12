From: Mark Seger <Mark.Seger@hp.com>
Date: Tue, 11 Dec 2007 19:57:57 -0500
Subject: [Lustre-devel] read ahead
In-Reply-To: <20071211234708.GT3214@webber.adilger.int>
References: <475ED623.6090204@sun.com>	<18270.55813.185376.299242@gargle.gargle.HOWL>
	<20071211234708.GT3214@webber.adilger.int>
Message-ID: <475F3215.40602@hp.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I thought it was the 3rd read that triggers readahead.   When I track 
network and lustre I/O while doing 4, 8 and 12K random reads look at the 
network traffic:

#<-----------Network----------><-------Lustre Client------>
#netKBi pkt-in  netKBo pkt-out  Reads KBRead Writes KBWrite
      0      9       1      15      1      4      0       0
     18    149      16     165      0      0      0       0
     57    626      56     639      0      0      0       0
     34    382      34     392      2      8      0       0
     12     30       5      40      0      0      0       0
      0     10       1      23      0      0      0       0
      0      8       1      24      0      0      0       0
      1     20       1      23      3     12      0       0
   1087    758      32     422      0      0      0       0

Since this is a shared network, you're seeing 'noise' on the link on the 
order of about 10-50MB/sec, but the spike of over 1M is clearly a result 
due to the readahead.  I had also done earlier byte level tests in which 
reading 8192 bytes didn't do readahead while 8193 did.

If I do a 12K and then a 16K random reads and add readahead readhead 
stats to the output look at the following you can again see 1MB network 
traffic associated with the 12KB random read, but now we also see 3 
lustre cache misses since the readahead occurs on the 3rd page and 
nothing is in the cache yet.

#<-----------Network----------><-------------Lustre Client-------------->
#netKBi pkt-in  netKBo pkt-out  Reads KBRead Writes KBWrite   Hits Misses
      0      8       1      16      3     12      0       0      0      3
   1086    757      31     408      0      0      0       0      0      0
      0      7       1      22      0      0      0       0      0      0
      0      9       1      26      0      0      0       0      0      0
      0     10       2      29      0      0      0       0      0      0
      0      8       1      20      0      0      0       0      0      0
      0     10       1      21      4     16      0       0      1      3
   2159   1478      56     781      0      0      0       0      0      0

By my question is why are we seeing a 2MB readahead (network traffic) 
when I'm only reading 16KB?  Is it that lustre does a 1MB readahead when 
the 3th page is read and another 1MB when the forth page is read?  That 
doesn't sound right to me.  Further, looking at the hits/misses you can 
also see the first 3 pages are read over the network and the fourth 
comes out of cache because of the readahead on the 3rd.  So again, where 
is the 2MB coming from?

If anyone is interested, these stats come from collectl, which I've 
mentioned in the past: http://collectl.sourceforge.net/

There is an even more detailed format for readahead stats but I don't 
think anything else is relevant to this particular situation:

# LUSTRE CLIENT SUMMARY: READAHEAD
# Reads ReadKB  Writes WriteKB  Pend  Hits Misses NotCon MisWin LckFal  
Discrd ZFile ZerWin RA2Eof HitMax
      4     16       0       0     0     1      3      0      0      
0      0      0      0      0      0
      0      0       0       0     0     0      0      0      0      
0      0      0      0      0      0
      0      0       0       0     0     0      0      0      0      
0      0      0      0      0      0

-mark

Andreas Dilger wrote:
> On Dec 11, 2007  21:42 +0300, Nikita Danilov wrote:
>   
>> Peter Braam writes:
>>  > Can anyone tell me if read ahead in Lustre includes "early return" 
>>  > features.  I mean that if I read 4K and readahead decides to fetch 1M 
>>  > will my request get serviced when the first 4K arrives?  Is this important?
>>
>> Currently read system call will proceed when the first RPC (including
>> first 4K page and some number of read-ahead pages) is serviced:
>> generic_file_read() waits on a page lock, and lock is released by
>> completion routine (ll_ap_completion()).
>>     
>
> Another thing worth mentioning here is that if this is the FIRST 4kB read
> from the file, then only that 4kB will be returned in the RPC, because
> readahead hasn't done linear vs. random IO detection yet.  If it is the
> second read (and linear) then the client will get the _rest_ of the 1MB
> and will have to wait for that second RPC to complete.  For subsequent
> reads the readahead will of course prefetch the pages.
>
> For random reads the code does understand the difference between e.g.
> reads of 16 sequential pages (64kB generally) read at non-consecutive
> offsets and 16 sequential 4kB page reads.  The former will NOT start
> readahead, while the latter does.
>
> Two areas where our readahead is lacking are:
> - strided reads (may turn the above 16 x 4kB reads into a situation
>   where the client will prefetch pages instead of "random" IO, depending
>   on access pattern, and will avoid prefetch of data the client is not
>   expecting to use)
> - limiting the readahead to the rate that the client is actually consuming
>   it (currently once we detect sequential reads the readahead window grows
>   eventually to the maximum even if this is far more than what the client
>   needs)
>
> Cheers, Andreas
> --
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at clusterfs.com
> https://mail.clusterfs.com/mailman/listinfo/lustre-devel
>   
