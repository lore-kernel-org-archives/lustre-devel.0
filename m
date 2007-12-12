From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Wed, 12 Dec 2007 11:41:18 -0500
Subject: [Lustre-devel] read ahead
In-Reply-To: <200712121552.lBCFqLxr003560@cmf.nrl.navy.mil>
References: <200712121552.lBCFqLxr003560@cmf.nrl.navy.mil>
Message-ID: <6C95C14E-9F4E-4E3E-A435-5010C2EFC999@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Dec 12, 2007, at 10:52 AM, chas williams - CONTRACTOR wrote:
> In message <20071211234708.GT3214@webber.adilger.int>,Andreas Dilger  
> writes:
>> For random reads the code does understand the difference between e.g.
>> reads of 16 sequential pages (64kB generally) read at non-consecutive
>> offsets and 16 sequential 4kB page reads.  The former will NOT start
>> readahead, while the latter does.
> what about direct i/o?  it looks like doing direct i/o to a file
> will never trigger readahead.  is this intentional?

Yes it is.
DIRECT IO by it's nature is "direct", i.e. it gets straight into  
application buffers,
we are not to put any more data there than application said it can  
accept.
And we are not allowed to cache any of that data (or to use any cache  
to get
the data during reads) too.

Bye,
     Oleg
