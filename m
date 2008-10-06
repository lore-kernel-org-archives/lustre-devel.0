From: Peter Braam <Peter.Braam@Sun.COM>
Date: Sun, 05 Oct 2008 21:19:50 -0600
Subject: [Lustre-devel] MDWBC and how much to trust clients
In-Reply-To: <1FEDA9D966B34039AF0EC15DBD0E4BAA@eblap>
Message-ID: <C50EDFF6.5F4C%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We discussed this in Moscow recently.  It seems possible to avoid much
mis-behavior by building relationships that have to be confirmed before a
commit can happen.

For example a directory entry creation must be accompanied by an object
creation or link-count change.

I think it is possible for an MDS or MDS cluster to know in which cases such
relationships need to be present  for operations to transition the name
space to a new namespace (and clients can indicate what operations are
correlated).

Peter



On 10/5/08 8:53 PM, "Eric Barton" <eeb@sun.com> wrote:

> Nikita,
> 
> Do you agree that a buggy or malicious MDWBC could disrupt the
> namespace (e.g. links to missing files, orphaned files) if
> it splits up operations across multiple MDTs into sub-operations
> for the individual targets?  I think it will be an issue for
> security if we just trust the MDWBC to do such operations
> correctly, and so I'm wondering how we can fix this.
> 
> Using a master MDT to coordinate the operation across itself and
> the remaining MDTs seems part of, but not all of the solution.
> We have to process batches in bulk to retain a significant
> performance advantage, so I wonder if that requires us to trust
> that these batches have been created correctly.
> 
> If so, we're stuck with the MDWBC being something we can only
> do in a single trust domain - i.e. not across a WAN. That seems
> unfortunate since WAN performance should be a major beneficiary
> of the MDWBC.  Maybe in this case, we can still send batches over
> the WAN, but to a single target which proxies for the remote client
> and can be trusted to split multi-target ops over batches correctly.
> 
> Thoughts?
> 
>     Cheers,
>               Eric
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
