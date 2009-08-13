From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Thu, 13 Aug 2009 14:00:55 -0400
Subject: [Lustre-devel] Role of the Metadata Server during File I/O
In-Reply-To: <20090811172405.5AA7420DBF8C@hailoo.com>
References: <20090810223137.E018520DBF8C@hailoo.com>
	<034001ca1a93$cd8ec140$68ac43c0$@com>
	<20090811172405.5AA7420DBF8C@hailoo.com>
Message-ID: <A1589B4A-DAE8-4022-A352-8D3709C163D5@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Aug 11, 2009, at 1:24 PM, office at hailoo.com wrote:

> Thanks for the information.  Doesn't this entail that for every call  
> to write() involving a striped file, Lustre must necessarily consult  
> all OSSs, in order to determine 1) the file size and 2) if the  
> current write operation will extend the file?

Why does write need to know the entire file size? We only care if we  
are extending currently accessed stripe. We know this the moment we  
obtained the lock on
the stripe region we are interested in.
> If so, then I think it would be advisable for Lustre clients working  
> with striped files to avoid small unbuffered file writes, since  
> every call to write() requires a lot of network overhead.
>

It is indeed not advisable to use small unbuffered writes (though we  
relieved the situation somewhat), but not because of the network  
overhead, rather the lustre
code is not exactly light-weight doing thelock processing and lookup  
and stuff.
I remember when LLNL performed experiments, and 4 byte unbuffered  
writes were 100 times slower than 1M writes.
But since then we improved the situation and I am no longer sure how  
these compare.

Bye,
     Oleg
