From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Wed, 04 Jun 2008 10:22:02 -0700
Subject: [Lustre-devel] Replacing a dead OST (fixed subject line)
In-Reply-To: <C46BFD6B.5720%peter.braam@sun.com>
References: <C46BFD6B.5720%peter.braam@sun.com>
Message-ID: <4846CF3A.8070602@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter Braam wrote:
> There is tremendous value in fixing this bug (15345), because it turns an un-usual
> usage of our tools for recovery into something that is done more routinely.
>
> When I listened to this group, my impression was that it was not so hard to
> rebuild the OSS, but it does require scanning the primary MDS, finding the
> pathnames for affected files (with objects on the failed OSS), and using
> that list of files to re-write on the cluster where the OSS was lost.
>
> Nathan - this is a special case of the recovery mechanisms we are talking
> about (with the log being constructed in a different way). I think you
> should design the solution for this problem.
>   
I am taking this to mean we should design the general case of 
"dead/missing OST" into the HSM/migration architecture, and not 
something to do with recovery per se.   That's actually really 
interesting - you could deactivate an OST, and yet still read the files 
from it transparently.


Should I make a "luste-hsm" mail alias, or should we put it on lustre-devel?
