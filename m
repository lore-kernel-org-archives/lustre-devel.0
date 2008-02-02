From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Sat, 02 Feb 2008 02:00:24 -0500
Subject: [Lustre-devel] Reducing amount of glimpses
In-Reply-To: <00dc01c86566$54235390$0281a8c0@ebpc>
References: <A1C83110-58BF-43A2-88F3-68C6C53BFB6C@sun.com>
	<00dc01c86566$54235390$0281a8c0@ebpc>
Message-ID: <D9759C99-E435-403A-88D0-3428F44E8E6F@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Feb 2, 2008, at 1:39 AM, Eric Barton wrote:

> Reduction (as you describe) is an absolutely essential strategy
> to achieve scalability.  So without having checked through all the
> details of your idea, it feels like absolutely the right solution.

Yes, I just afraid that a bit stale size data might be reported, and  
not yet
sure how critical is that to us.

> If your idea not only changes latencies but also significant  
> orderings,
> I'll feel less secure.  Have you thought it all through?

There is no ordering changes other than I would think perfectly normal  
race.
Let me explain with a control flow:

client3 holds highest write lock. clients 1 and 2 do glimpse.
Right now (racy scenario):

client 1 sends glimpse->server on its behalf sends glimpse ast to  
client3 -> client3 receives ast, sends reply
client 2 sends glimpse->server on its behalf sends glimpse ast to  
client3 ->
client3 writes some more data
glimpse on behalf of client2 arrives to client3 -> client3 sends in  
updated size
server now sends different sizes back to client 1 and client2.

If we consolidate, it will look like this:
client 1 sends glimpse->server on its behalf sends glimpse ast to  
client3 -> client3 receives ast, sends reply
client 2 sends glimpse->server notices there is glimpse ast in flight  
already to client3, and waits for it
client3 writes some more data
server receives reply and sends identical sizes to client1 and client2.

I tend to think this is normal race (kind of like with 2 processes  
doing stat on a local file and 3rd writing to file constantly,
it is possible that when two stats are done closely apart, they would  
come with identical size), but just want to check if
there are no objections about it.

Bye,
     Oleg
