From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Wed, 01 Apr 2009 11:02:04 -0400
Subject: [Lustre-devel] SeaStar message priority
In-Reply-To: <49D3644A.9090001@cray.com>
References: <74EA92D6-25E8-42DA-A4FD-BDDCED233244@Sun.COM>
	<49D3644A.9090001@cray.com>
Message-ID: <55153681-EA57-489A-ACD0-6A65EC03B6AB@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Apr 1, 2009, at 8:55 AM, Nic Henke wrote:
>>   It came to my attention that seastar network does not implement
>> message priorities for various reasons.
>>   I really think there is very valid case for the priorities of some
>> sort to allow MPI and other
>>   latency-critical traffic to go in front of bulk IO traffic on the
>> wire.
> In the ptllnd, the bulk traffic is setup via short messages, so if the
> barrier is sent right after the write() returns, it really isn't  
> backed
> up behind the bulk data.

Yes, it is.
Lustre starts to send RPCs as soon as 1M (+16) pages of data per RPC  
become
available for sending.
So by the time write() syscall for 250M returns, I already potentially  
have
16 (stripe count) * 4 (core count) * 8 (rpcs in flight) MB in flight
from this particular node (since chances are OSTs already accepted the
transfers if there are free threads).

> This sounds much more like barrier jitter than backup. The network is
> capable of servicing the 250M in < .15s. It would be my guess that  
> some
> of the writes() are taking longer than others and this is causing the
> barrier to be delayed.

No.
I time each individual write separately.
I know all writes start at the same time (there is barrier before them),
I know that each write finishes in aprox 0.5 sec as well.

> A few questions:
> - how many OSS/OSTs are you writing to ?

up to 16 * 4 from a single node.

> - can you post the MPI app you are using to do this ?

Sure.
Attached. (with example output)

> The application folks @ ORNL should be able to help you use Craypat or
> Apprentice to get some runtime data on this app to find where the time
> is going. Until we have hard data, I don't think we can blame the  
> network.

Interesting idea.
Please notice if I run the code at a scale of 4, barrier is instant.
As I scale up node count, barrier time begins to rise.

In the output you can see I run the code twice in a row.
This is done to make sure the grant is primed in case it was not, to  
take
entire amount of data into the cache (otherwise in some runs some
individual writes take significant time to complete invalidating the  
test).
Another thing of note is that since I did not want to take any chances,
the working files are precreated externally so that no files
share any ost for a single node, and the app itself just opens the  
files,
not creates them.


Bye,
     Oleg
-------------- next part --------------
A non-text attachment was scrubbed...
Name: writespeed-big.c
Type: application/octet-stream
Size: 3955 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090401/adcae1f6/attachment.obj>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: writespeed_big.o555745
Type: application/octet-stream
Size: 320418 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090401/adcae1f6/attachment-0001.obj>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: writespeed_big.pbs
Type: application/octet-stream
Size: 362 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090401/adcae1f6/attachment-0002.obj>
