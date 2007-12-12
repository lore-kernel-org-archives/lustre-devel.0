From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Date: Wed, 12 Dec 2007 10:52:21 -0500
Subject: [Lustre-devel] read ahead
In-Reply-To: <20071211234708.GT3214@webber.adilger.int> 
Message-ID: <200712121552.lBCFqLxr003560@cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

In message <20071211234708.GT3214@webber.adilger.int>,Andreas Dilger writes:
>For random reads the code does understand the difference between e.g.
>reads of 16 sequential pages (64kB generally) read at non-consecutive
>offsets and 16 sequential 4kB page reads.  The former will NOT start
>readahead, while the latter does.

what about direct i/o?  it looks like doing direct i/o to a file
will never trigger readahead.  is this intentional?
