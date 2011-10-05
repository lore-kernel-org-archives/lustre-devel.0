From: Eric Barton <eeb@whamcloud.com>
Date: Wed, 5 Oct 2011 14:03:31 +0100
Subject: [Lustre-devel] Erratum about indexes in robinhood DB
In-Reply-To: <4E84346B.8060300@cea.fr>
References: <4E84346B.8060300@cea.fr>
Message-ID: <038c01cc835f$2f30f090$8d92d1b0$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Thomas,

Thanks a lot and I hope you don't mind me cc-ing lustre-devel as this
seems to be of general interest.

Do you have a feel (or measurements :) for the rate at which a changelog
can be ingested into robinhood?  And I'm wondering about DNE and multiple
changelogs coming from multiple MDTs.  I'd be very interested to know if
you've thought about this and have views on what the maximum ingest rate
could be and whether there will be issues coordinating/merging events
across multiple feeds.

          Cheers,
                   Eric

Eric Barton
CTO Whamcloud, Inc.

> -----Original Message-----
> From: LEIBOVICI Thomas [mailto:thomas.leibovici at cea.fr]
> Sent: 29 September 2011 10:04 AM
> To: Eric Barton
> Subject: Erratum about indexes in robinhood DB
> 
> Hello Eric,
> 
> Re-thinking about your question on indexes in robinhood DB, my answer
> was incomplete.
> Actually, there are indexes on user/group/type/status, but there are not
> on the main table:
> 
> 1) As I said you, on the main table (the one that list all FS entries),
> there are as few indexes as possible (just fid as primary key, and
> parent fid)
> in order to preserve a good insert/update rate on this table whatever
> the FS size (the deeper the DB index trees, the slower those requests).
> 
> 2) There is a secondary table where robinhood maintains aggregated
> statitics like nbr entries, volume per user/group/type/(hsm)status and
> which is updated on the fly.
> This one as indexes on quite all its fields, which makes it possible to
> get instantaneous stats per user, etc. without penalizing insert/update
> rate on main table.
> Indexes on this secondary table are less expensive, given that the set
> of users is much more resticted that the nbr of entries.
> 
> This time you have a more complete answer.
> 
> Best regards
> Thomas
