From: Andreas Dilger <adilger@sun.com>
Date: Mon, 25 Jan 2010 00:23:03 -0700
Subject: [Lustre-devel] proposal on implementing a new readahead in clio
In-Reply-To: <4B5D404D.605@Sun.COM>
References: <4B56F907.3090308@sun.com> <4B598390.5030504@sun.com>
	<1264230566.11892.62.camel@berloga.shadowland>
	<4B5B9BFA.9080301@sun.com>
	<20100125040516.GC1061@Sun.COM> <4B5D404D.605@Sun.COM>
Message-ID: <D37DCC00-CF98-4FDB-829B-3AEDE51AE58F@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-01-24, at 23:55, Matt Wu wrote:
> We can group the threads by several ways:
> 1, request per random thread, without any specify order. we just  
> start a
> fixed number of threads and queue the readahead request to any  
> thread of
> the thread pool.
>    this is the decision we made during WNC readahead meeting last  
> week.
> 2, thread per file (file) or thread per open instance (fd)
> 3, thread per ost, we need divide the readahead request to several  
> which
> are stripe boundary aligned.

In order to keep the readahead pages local to the NUMA node that the  
userspace thread is running on, I'd recommend at most a single  
readahead thread per core.  That way, when the readahead thread is  
allocating pages they will be on the right NUMA node.

> On 2010/1/25 12:05, Nicolas Williams wrote:
>> On Sun, Jan 24, 2010 at 09:01:46AM +0800, jay wrote:
>>> Alexey Lyashkov wrote:
>>>> I correctly understand: you suggest a spawn one new thread per open
>>>> file?
>>>> so if client have 10 processes, and each process is open 100  
>>>> files, you
>>>> need spawn 1000 new threads?
>>>>
>>> No, per process readahead, or some system readahead thread pool,  
>>> this is
>>> because most of those threads are sleeping, and it consumes little  
>>> time
>>> to issue readahead requests. The idea behind the scheme is to issue
>>> readahead rpcs async.
>>
>> Sleeping threads do consume memory resources, and context switches
>> between them do add cache pressure.  The read ahead work should all  
>> be
>> async, in which case you need no more readahead threads than you have
>> CPUs.
>>
>>> BTW, I'm not going to implement what you mentioned in linux,  
>>> because I
>>> don't think this is a good idea, as what I said in design doc.  
>>> However,
>>> we HAVE to have an async thread pool to implement readahead for  
>>> windows.
>>> Windows doesn't have an interface of issuing async read request,  
>>> lack of
>>> a mechanism to have page lock or similar things - what a pity!
>>
>> But surely you can still do the readaheads asynchronously.  Say you
>> think that block N of some file will be needed soon: so you issue the
>> read ahead of time.  You'll need to place the data somewhere, and
>> hopefully that will be somewhere that the host OS's VFS sub-system
>> (Windows in your case) can either provide or accept -- if not you'll
>> need to do a copy later, but you're still able to send the read  
>> request,
>> and process the reply, asynchronously.
>>
>> Nico
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel


Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
