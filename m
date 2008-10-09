From: Peter Braam <Peter.Braam@Sun.COM>
Date: Thu, 09 Oct 2008 08:04:08 -0600
Subject: [Lustre-devel] MDWBC and how much to trust clients
In-Reply-To: <18667.10276.857149.242018@gargle.gargle.HOWL>
Message-ID: <C5136B78.6085%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

You'll need to limit this to the requests that have dependencies.  With the
algorithm below every server starts looking at every request - that probably
kills the scaling you want to achieve.

Peter


On 10/7/08 3:13 AM, "Nikita Danilov" <Nikita.Danilov@Sun.COM> wrote:

> Nikita Danilov writes:
>> Eric Barton writes:
>>> Nikita,
>> 
>> Hello,
> 
> [...]
> 
>> 
>> as Peter mentioned, we discussed this topic during the Moscow
>> meeting. If I am not mistaken, we converged to the idea that before
>> committing an epoch, every mdt composes some kind of a `summary',
>> containing enough information for verification of a global consistency,
>> and this summary is passed though every server as a ticket, with every
> 
> This can be simplified. Suppose total amount of `data', describing all
> updates within given epoch is D, and there are N md servers in a cmd
> cluster. Then total network traffic incurred by this algorithm is
> 
>              D   /* updates from client to all servers */ +
>              D*N /* cycle summary through all servers */
> 
> that is, (N + 1)*D bytes, transferred in 2*N messages. So we won't
> increase network traffic by broadcasting _all_ epoch updates to _every_
> server (so that each server gets complete set of all updates within the
> epoch). In this latter case, servers can prove that epoch is consistent
> by
> 
>     - checking global consistency locally,
> 
>     - calculating md5 signature of all epoch updates, and
> 
>     - exchanging these signatures, to check that client sent the same
>       set of updates to everybody.
> 
> This results in
> 
>              D*N /* broadcast epoch updates to all servers */ +
>              e*N /* exchange signatures */
> 
> that is N*(D + e), for some small e, bytes transferred in 2*N
> messages. Having complete set of updates on every server would probably
> help in other places too.
> 
> 
>> server `approving' some bits in the summary accumulated so far, and
> 
> [...]
> 
>>> 
>>> Thoughts?
>>> 
>>>     Cheers,
>>>               Eric
>> 
> 
> Nikita.
