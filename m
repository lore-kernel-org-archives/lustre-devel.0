From: Peter Braam <Peter.Braam@Sun.COM>
Date: Tue, 11 Dec 2007 11:59:13 -0700
Subject: [Lustre-devel] read ahead
In-Reply-To: <88917D9B-1A3F-4C20-8764-FD9A4A2FB973@sun.com>
References: <475ED623.6090204@sun.com>
	<88917D9B-1A3F-4C20-8764-FD9A4A2FB973@sun.com>
Message-ID: <475EDE01.2070408@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This might be quite damaging in some situations - for example, if the 
server has the 4K data cached in RAM it should refuse to do a disk read 
probably, but in order to do so it would need to know that part of the 
request is optional, while the 4K is mandatory.

Can we give hints to the OSC about what part of I/O is requested by 
applications and what is requested for read-ahead?  If so, could we use 
a more interesting IOV to do this faster?

- Peter -

Oleg Drokin wrote:
> Hello!
>
> On Dec 11, 2007, at 1:25 PM, Peter Braam wrote:
>
>> Can anyone tell me if read ahead in Lustre includes "early return" 
>> features.  I mean that if I read 4K and readahead decides to fetch 1M 
>> will my request get serviced when the first 4K arrives?  Is this 
>> important?
>
> I think this is impossible to implement with current architecture.
> We have one bulk RPC (1M in size) that until received completely, 
> won't issue any callbacks.
> So only when that entire 1M is received your 4k request would return.
> On the other hand if your example is 4k and 2M, then we will return 
> after 1M that contains requested 4k is received (but there is no 
> guarantee at the moment we won't receive second 2M first, I believe).
>
> Bye,
>     Oleg
