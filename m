From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Wed, 01 Apr 2009 15:26:41 -0400
Subject: [Lustre-devel] SeaStar message priority
In-Reply-To: <49D3BD69.1070900@cray.com>
References: <74EA92D6-25E8-42DA-A4FD-BDDCED233244@Sun.COM>
	<1238596005.5091.31.camel@wheel>
	<D3750FED-36ED-4B07-9499-A8ABA7A2FCDA@Sun.COM>
	<1238601506.5091.65.camel@wheel>
	<F939F52D-614F-4CA8-A80F-50CE31E3303A@Sun.COM>
	<49D3BD69.1070900@cray.com>
Message-ID: <6A6E4D42-DFE4-4C5F-B969-470C2977FA70@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Apr 1, 2009, at 3:15 PM, Nicholas Henke wrote:
>> But since the only thing I have in my app inside barriers is write  
>> call,
>> there is no much way to desynchronize.
> Incorrect - you are running your app on all 4 CPUs on the node at  
> the same time Lustre is sending RPCs. The kernel threads will get  
> scheduled and run, pushing your app to the side and desynchronizing  
> the barrier for the app as a whole.

But I am measuring each write and I see that none of them  
significantly exceeds 0.5 seconds.
Let it be 0.1 seconds difference.
So then 4.5 seconds - 0.1 seconds for the write speed difference = 4.4  
seconds.

> What we really need to "prove" is where the delay is occurring. The  
> MPI_Barrier messages are 0-byte sends, effectively turning them into  
> Portals headers and these are sent and processed very fast. In fact,  
> the total amount of data being sent is _much_ less than the NIC is  
> capable of. A rough estimate for 2 nodes talking to each other is  
> 1700 MB/s and 50K lnet pings/s.

Yes. I understand this point.

> One thing to try is changing your aprun to use fewer CPUs per node:
> aprun -n 1200 -N [1,2,3] -cc 1-3.

I just run with 1 cpu per node, 1200 threads. Leaving 3 cpus/core for  
kernel and whatnot.
The actual write syscall return time decreased, but the barrier is  
not, even though we know
that less data is in time at any given time now (due to only 16 osts  
accessed per node, not 16*4).
So something is going on, but I do not think we can blindly attribute  
it to just "ah kernel ate your
cpu for important things pushing the data"
0: barrier after write time: 4.528383 sec
0: barrier after write 2 time: 4.043252 sec

The pre-write barrier took only 0.096675 sec (to rule out general  
network congestion).

Bye,
     Oleg
