From: jay <Jinshan.Xiong@Sun.COM>
Date: Mon, 25 Jan 2010 14:17:13 +0800
Subject: [Lustre-devel] proposal on implementing a new readahead in clio
In-Reply-To: <1264324726.11892.76.camel@berloga.shadowland>
References: <4B56F907.3090308@sun.com> <4B598390.5030504@sun.com>
	<1264230566.11892.62.camel@berloga.shadowland>
	<4B5B9BFA.9080301@sun.com>
	<1264324726.11892.76.camel@berloga.shadowland>
Message-ID: <4B5D3769.9040703@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Nico and shadow,

Since you have the same question about windows, I just replied them in 
one email. Also I got Matt involved - he is a windows expert.


Alexey Lyashkov wrote:
> On Sun, 2010-01-24 at 09:01 +0800, jay wrote:
>   
>> Alexey Lyashkov wrote:
>>     
>>> We have an idea to spawn a per file readahead thread for each process,
>>> and this thread can be used to issue the readahead RPC async.
>>>   
>>> I correctly understand: you suggest a spawn one new thread per open
>>> file?
>>> so if client have 10 processes, and each process is open 100 files, you
>>> need spawn 1000 new threads?
>>>   
>>>       
>> No, per process readahead, or some system readahead thread pool, this is 
>> because most of those threads are sleeping, and it consumes little time 
>> to issue readahead requests. The idea behind the scheme is to issue 
>> readahead rpcs async.
>>     
> first case is same as i say (i think) - 10 processes reading from own
> files, so will be spawn 1000 new threads.
> in second case you will be lost readahead requests on hardloaded client.
>   
Nod - that's why I'm not going to do it in linux - as the design doc 
said - don't you see section 8.1? :-)
>   
>> BTW, I'm not going to implement what you mentioned in linux, because I 
>> don't think this is a good idea, as what I said in design doc. However, 
>> we HAVE to have an async thread pool to implement readahead for windows. 
>> Windows doesn't have an interface of issuing async read request, lack of 
>> a mechanism to have page lock or similar things - what a pity!
>>     
> hm.. looks i don't understand problem. Currently linux client is using
> ->readpage() to generate OST_READ RPC and sending via ptlrpcd-io.
> Why isn't generate this RPC directly for Windows? Or you mean about
> update asynchronous update VM cache ?
>   

The problem is that we have to wait for the RPC(which may just contain 
readahead pages) to be finished before we can return to user space. You 
may ask why we can't do this, the answer is that we should pipeline the 
readahead request, instead of reading a chunk of data to support readahead.

The problem of windows is that it's lack of interfaces to manipulate 
pages. I'm not a windows expert - please ask matt if you have windows 
specific questions.

>
>   


-- 
Good good study, day day up
