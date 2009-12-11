From: Andreas Dilger <adilger@sun.com>
Date: Fri, 11 Dec 2009 16:21:10 -0700
Subject: [Lustre-devel] no reformating for test suite
In-Reply-To: <alpine.LFD.2.00.0912111926080.2668@casper.infradead.org>
References: <alpine.LFD.2.00.0912111926080.2668@casper.infradead.org>
Message-ID: <9CA5FD93-CDC1-4394-B57B-E56A99DA09C8@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2009-12-11, at 12:27, James Simmons wrote:
> Is there a way to stop the lustre test suite from reformating the disk
> when we run our test?


What version of Lustre are you testing?  In recent releases (the last  
9-12 months or so) it doesn't reformat the filesystem by default.

I _think_ (but don't recall for sure anymore) that it is also possible  
to specify REFORMAT="" so that it will not reformat.

Some tests, like conf-sanity.sh depend on being able to reformat, and  
can be run with a local config that just uses loopback files.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
