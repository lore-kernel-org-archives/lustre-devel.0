From: Nicolas Williams <Nicolas.Williams@sun.com>
Date: Sun, 24 Jan 2010 22:05:16 -0600
Subject: [Lustre-devel] proposal on implementing a new readahead in clio
In-Reply-To: <4B5B9BFA.9080301@sun.com>
References: <4B56F907.3090308@sun.com> <4B598390.5030504@sun.com>
	<1264230566.11892.62.camel@berloga.shadowland>
	<4B5B9BFA.9080301@sun.com>
Message-ID: <20100125040516.GC1061@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jan 24, 2010 at 09:01:46AM +0800, jay wrote:
> Alexey Lyashkov wrote:
> > I correctly understand: you suggest a spawn one new thread per open
> > file?
> > so if client have 10 processes, and each process is open 100 files, you
> > need spawn 1000 new threads?
> >   
> No, per process readahead, or some system readahead thread pool, this is 
> because most of those threads are sleeping, and it consumes little time 
> to issue readahead requests. The idea behind the scheme is to issue 
> readahead rpcs async.

Sleeping threads do consume memory resources, and context switches
between them do add cache pressure.  The read ahead work should all be
async, in which case you need no more readahead threads than you have
CPUs.

> BTW, I'm not going to implement what you mentioned in linux, because I 
> don't think this is a good idea, as what I said in design doc. However, 
> we HAVE to have an async thread pool to implement readahead for windows. 
> Windows doesn't have an interface of issuing async read request, lack of 
> a mechanism to have page lock or similar things - what a pity!

But surely you can still do the readaheads asynchronously.  Say you
think that block N of some file will be needed soon: so you issue the
read ahead of time.  You'll need to place the data somewhere, and
hopefully that will be somewhere that the host OS's VFS sub-system
(Windows in your case) can either provide or accept -- if not you'll
need to do a copy later, but you're still able to send the read request,
and process the reply, asynchronously.

Nico
-- 
