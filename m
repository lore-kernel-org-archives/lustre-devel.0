From: Nicolas Williams <Nicolas.Williams@sun.com>
Date: Mon, 25 Jan 2010 09:34:26 -0600
Subject: [Lustre-devel] proposal on implementing a new readahead in clio
In-Reply-To: <D37DCC00-CF98-4FDB-829B-3AEDE51AE58F@sun.com>
References: <4B56F907.3090308@sun.com> <4B598390.5030504@sun.com>
	<1264230566.11892.62.camel@berloga.shadowland>
	<4B5B9BFA.9080301@sun.com> <20100125040516.GC1061@Sun.COM>
	<4B5D404D.605@Sun.COM>
	<D37DCC00-CF98-4FDB-829B-3AEDE51AE58F@sun.com>
Message-ID: <20100125153426.GE1061@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jan 25, 2010 at 12:23:03AM -0700, Andreas Dilger wrote:
> On 2010-01-24, at 23:55, Matt Wu wrote:
> >We can group the threads by several ways:
> >1, request per random thread, without any specify order. we just
> >start a fixed number of threads and queue the readahead request to
> >any  thread of the thread pool.  this is the decision we made during
> >WNC readahead meeting last  week.
> >2, thread per file (file) or thread per open instance (fd)
> >3, thread per ost, we need divide the readahead request to several
> >which are stripe boundary aligned.
> 
> In order to keep the readahead pages local to the NUMA node that the  
> userspace thread is running on, I'd recommend at most a single  
> readahead thread per core.  That way, when the readahead thread is  
> allocating pages they will be on the right NUMA node.

That was my recommendation as well, but if I understand Matt correctly,
the Windows VFS makes it impossible to do readahead asynchronously,
which is why Matt suggests having many threads.  I have no clue as to
the relevant Windows kernel APIs, but if Matt's right about Windows,
then color me surprised.  Assuming that's correct and that there's no
reasonable way around the problem, then I'd recommend having a pool with
some number of threads (say, 3 * CPUs), with readaheads done only when
there are threads available in the pool.

Nico
-- 
