From: Peter Braam <Peter.Braam@Sun.COM>
Date: Sat, 07 Jun 2008 08:03:07 -0600
Subject: [Lustre-devel] Replacing a dead OST (fixed subject line)
In-Reply-To: <4846CF3A.8070602@sun.com>
Message-ID: <C46FF13B.591C%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




On 6/4/08 10:22 AM, "Nathaniel Rutman" <Nathan.Rutman@Sun.COM> wrote:

> Peter Braam wrote:
>> There is tremendous value in fixing this bug (15345), because it turns an
>> un-usual
>> usage of our tools for recovery into something that is done more routinely.
>> 
>> When I listened to this group, my impression was that it was not so hard to
>> rebuild the OSS, but it does require scanning the primary MDS, finding the
>> pathnames for affected files (with objects on the failed OSS), and using
>> that list of files to re-write on the cluster where the OSS was lost.
>> 
>> Nathan - this is a special case of the recovery mechanisms we are talking
>> about (with the log being constructed in a different way). I think you
>> should design the solution for this problem.
>>   
> I am taking this to mean we should design the general case of
> "dead/missing OST" into the HSM/migration architecture,

No - into the replication architecture.  You feed a list of files into your
scripts and re-create the objects.

> and not 
> something to do with recovery per se.   That's actually really
> interesting - you could deactivate an OST, and yet still read the files
> from it transparently.

No, you can only read them when the OST has been restored; no cache misses
(yet).

> 
> 
> Should I make a "luste-hsm" mail alias, or should we put it on lustre-devel?
> 
> 
