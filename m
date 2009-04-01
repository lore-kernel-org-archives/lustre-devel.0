From: Michael Booth <Michael.Booth@Sun.COM>
Date: Wed, 01 Apr 2009 07:41:44 -0400
Subject: [Lustre-devel] Oleg/Mike Work on Apps Metrics - FW: Mike	Booth
 week ending 2009.03.15
In-Reply-To: <5D5BFAF6-9BE2-4778-AE81-A5EEF2A7026A@Sun.COM>
References: <D691F7E6-6030-4EB9-896C-77201445D865@Sun.COM>
	<C5E2A328.36EE0%Daniel.Ferber@Sun.Com>
	<015c01c9a5a7$cb2f83a0$618e8ae0$@com>
	<52E982EB-3ADE-46FA-A7BC-D1645961DF0B@Sun.COM>
	<018101c9a5b6$25dbc300$71934900$@com>
	<48A6CF99-F630-4581-9FFC-05E3AFF66FA0@Sun.COM>
	<023201c9a636$a987e4b0$fc97ae10$@com>
	<5CE22E46-771C-47EE-9CAC-26A37C87C466@sun.com>
	<20090331185111.GL3199@webber.adilger.int> <49D2E0FC.4040605@sun.com>
	<9BDC2632-E80E-4BA8-9ACF-8D7E70A9B236@Sun.COM>
	<5D5BFAF6-9BE2-4778-AE81-A5EEF2A7026A@Sun.COM>
Message-ID: <D68D6931-6B66-468A-A869-9097FC36A08D@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



On Apr 1, 2009, at 12:34 AM, Oleg Drokin wrote:

> Hello!
>
> On Mar 31, 2009, at 11:55 PM, Michael Booth wrote:
>> (My Opinion) The large size of the I/O request put onto the SeaStar
>> by the Lustre client is giving it an artificially high priority.
>> Barriers are just a few bytes, the I/Os from the client are in
>> megabytes.   SeaStar has no priority in is queue, but  the amount of
>> time it takes to clear megabyte request results in a priority that
>> is thousands of times more impact on the hardware than the small
>> synchronization requests of many collectives.  I am wondering if the
>> interference from I/O to computation is more an artifact of message
>> size and bursts,  than of congestion or routing inefficiencies in
>> seastar..
>> If there are hundreds of megabytes of request queued up on the
>> network, and there is no priority way to push a barrier or other
>> small mpi request up on the queue, it is bound to create a  
>> disruption.
>> To borrow the elevator metaphor from Eric,  if all the elevators are
>> queued up from 8:00 to 9:00 delivering office supplies on carts that
>> occupy the entire elevator, maybe the carts should be smaller, and
>> limited to a few per elevator trip.
>
> As we discussed in the past, just sending small i/o messages is going
> to uncover all kinds of slowdowns all the way back to the disk  
> storage,
> and the collateral damage would be other tasks that do need fast i/o
> and do send big chunks of data.
>
> Bye,
>     Oleg
> _______________________________________________

Don't take my explanation as a general suggestion for all I/O, It is a  
suggestion for I/O taking place during times of need for high response  
for mpi.  How to know when the need is high is another issue.

To over extend the metaphor, can the size of the office supply carts  
be small and the amount number allowed on the elevator up be limited  
from 8:00 to 9:00 am when the office people traffic is in need of high  
response?

It is clear to the application  when they are doing synchronous i/o  
and don't care so much about mpi response and when they are in a stage  
that a collective response is important.  For example:  the barrier  
after an fsync is definitely desiring highest response to I/O  
request.   After a barrier is complete, mpi would likely need highest  
response, until another user synchronous i/o call, (not to include  
printf's).  I could even be an explicit call to the Lustre client from  
the application to switch the priority between states.

Mike
