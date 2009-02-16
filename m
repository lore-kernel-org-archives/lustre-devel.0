From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Sun, 15 Feb 2009 19:10:39 -0500
Subject: [Lustre-devel] Some investigations on  MDS creation rate
In-Reply-To: <49982E71.80902@cray.com>
References: <DC147A4B-16CC-41B7-9C27-2F9BE64805FD@Sun.COM>
	<49982E71.80902@cray.com>
Message-ID: <71D10645-A30D-4D50-A79A-F08285196425@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Feb 15, 2009, at 10:02 AM, Nic Henke wrote:
> Was this all of the changes ? Why remove the cfs_waitq_signal ?

Yes it was.
We remove cfs_waitq_signal since it wakes up another thread to process  
a message that we just moved from incoming queue to "to be processed"  
queue.
It helps me because I only have 1 message waiting at any one given time.
If there is more than one message waiting, the result is not entirely  
clear, but I think should be fine as well, essentially every incoming  
message
woke up one processing thread, and then they run racing to the  
incoming message queue first, pick 1 request at a time, and put it  
into processing queue,
then try to see if there are more incoming messages (if the MDS is  
lightly loaded, there is likely none, because another thread already  
took care
of them), and then process one request from processing queue.
I suspect that it would be beneficial to only process one incoming  
message and immediately start processing it to avoid processing it on  
a potentially
cache-cold cpu if there is no high priority handler registered. If  
there is high priority handler registered, we can exit early on once  
we met
high priority message in incoming message processing.

> We are having mdsrate issues on 1.6.5 as well - but so far we are  
> not CPU bound yet. We'll be trying things like increasing the number  
> of MDS threads and the create_count for the OSTs - If we are not CPU  
> bound, we are waiting on something else.

Are you not CPU-bound on MDS?
How many clients do you run with mdsrate (as in separate clients  
nodes) to how many cpu MDS?
Have you tried eliminating object creation overhead just to see how  
much effect that was having (mdsrate mknod option)?

Bye,
    Oleg
