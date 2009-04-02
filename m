From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Wed, 01 Apr 2009 22:46:08 -0400
Subject: [Lustre-devel] SeaStar message priority
In-Reply-To: <1849D28F-423C-42F7-BE4A-EB0D79571557@Sun.COM>
References: <74EA92D6-25E8-42DA-A4FD-BDDCED233244@Sun.COM>
	<1238596005.5091.31.camel@wheel>
	<D3750FED-36ED-4B07-9499-A8ABA7A2FCDA@Sun.COM>
	<1238601506.5091.65.camel@wheel>
	<F939F52D-614F-4CA8-A80F-50CE31E3303A@Sun.COM>
	<1238613200.5091.184.camel@wheel>
	<1849D28F-423C-42F7-BE4A-EB0D79571557@Sun.COM>
Message-ID: <89655A8C-F417-461E-8D5E-8A6395200795@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Apr 1, 2009, at 4:17 PM, Oleg Drokin wrote:

>>>> when, scheduling occurs on two nodes is different. Any two nodes,  
>>>> even
>>>> running the same app with barrier synchronization, perform things  
>>>> at
>>>> different times outside of the barriers; They very quickly
>>>> desynchronize
>>>> in the presence of jitter.
>>> But since the only thing I have in my app inside barriers is write  
>>> call,
>>> there is no much way to desynchronize.
>> Modify your test to report the length of time each node spent in the
>> barrier (not just rank 0, as it is written now) immediately after the
>> write call, then? If you are correct, they will all be roughly the  
>> same.
>> If they have desynchronized, most will have very long wait times  
>> but at
>> least one will be relatively short.
> That's a fair point. I just scheduled the run.

Ok.
The results are in. I scheduled 2 runs. One at 4 threads/node and one
at 1 thread/node.

For the 4 threads/node case the 1st barrier took anywhere from 1.497  
sec to
3.025 sec with rank 0 reporting 1.627 sec.
The second barrier took 0.916 to 2.758 seconds with rank 0 reporting  
1.992 sec.
For the barrier 2 I can actually clearly observe that thread terminate  
in
groups of 4 with very close times, and ranks suggest those nids are on  
the same
nodes. On 1st barrier this trend is much less visible, though.

On the 1 thread/node case the fastest 1st barrier was 7.515 seconds and
slowest was 10.176
For the 2nd barrier, fastest was 0.085 and slowest 2.756 which is  
pretty close
to the difference between fastest and slowest 1st barrier, since  
amount of data
written per node in this case 4 smaller, I guess we just flushed all  
the data
to the disk before the 1st barrier finished and the difference in  
waiting was due
to the differences in start times.

As you can see, numbers tend to jump around, but there are still  
relatively big delays
due to something else than just threads getting out of sync.

Bye,
    Oleg
