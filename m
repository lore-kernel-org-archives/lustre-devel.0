From: jay <Jinshan.Xiong@Sun.COM>
Date: Sun, 24 Jan 2010 09:01:46 +0800
Subject: [Lustre-devel] proposal on implementing a new readahead in clio
In-Reply-To: <1264230566.11892.62.camel@berloga.shadowland>
References: <4B56F907.3090308@sun.com> <4B598390.5030504@sun.com>
	<1264230566.11892.62.camel@berloga.shadowland>
Message-ID: <4B5B9BFA.9080301@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Alexey Lyashkov wrote:
> We have an idea to spawn a per file readahead thread for each process,
> and this thread can be used to issue the readahead RPC async.
>   
> I correctly understand: you suggest a spawn one new thread per open
> file?
> so if client have 10 processes, and each process is open 100 files, you
> need spawn 1000 new threads?
>   
No, per process readahead, or some system readahead thread pool, this is 
because most of those threads are sleeping, and it consumes little time 
to issue readahead requests. The idea behind the scheme is to issue 
readahead rpcs async.

BTW, I'm not going to implement what you mentioned in linux, because I 
don't think this is a good idea, as what I said in design doc. However, 
we HAVE to have an async thread pool to implement readahead for windows. 
Windows doesn't have an interface of issuing async read request, lack of 
a mechanism to have page lock or similar things - what a pity!

Jay
>
> On Fri, 2010-01-22 at 18:53 +0800, jay wrote:
>   
>> UP!!
>>
>> Here is a pdf version of design document. Also I'm attaching a picture 
>> because the pictures in pdf is not clear.
>>
>> Thanks,
>> Jay
>>
>> jay wrote:
>>     
>>> Hello,
>>>       
>
>
>   


-- 
Good good study, day day up
