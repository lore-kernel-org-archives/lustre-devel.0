From: LEIBOVICI Thomas <thomas.leibovici@cea.fr>
Date: Thu, 06 Oct 2011 13:01:45 +0200
Subject: [Lustre-devel] Erratum about indexes in robinhood DB
In-Reply-To: <038c01cc835f$2f30f090$8d92d1b0$@com>
References: <4E84346B.8060300@cea.fr> <038c01cc835f$2f30f090$8d92d1b0$@com>
Message-ID: <4E8D8A99.1010804@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello Eric,

With a fast enough feeder, the ingest rate robinhood can currently 
sustain is between 50.000/sec and 100.000/sec
(depending on insert/update/remove ratio) with a basic MySQL DB stored 
on a local disk.
This can certainly still be improved with MySQL tunings and/or better HW 
and/or enterprise class DB,
but for now, we notice it is easily high enough for reading a MDT 
changelog stream on a Petaflopic system.

This rate is actually lower when processing Lustre MDT changelogs (but I 
have no measurement) because of "stat" operations to get file attributes
(unfortunately, changelogs do not give the new value of what has just 
changed, e.g new uid for a chown operation, new size&mtime with a mtime 
event...)
SOM will probably improve that point, but it could be a good idea to add 
more info in changelogs.

Handling chglogs from multiple MDTs is indeed a very interesting point 
to address.
The main issue is the database scaling in terms of operation rate, 
volume and entry location.
A solution could be using an existing clustered DB engine (MySQL 
cluster, NOSQL DBs...),
thus we are going to take a look at the different alternatives and see 
if they could match the need.
For that, it would be interesting to know how records will be splitted 
into the multiple changelog streams:
is a given fid always reported by the same stream? what about the parent 
fid (like in create/unlink operations)?
If you have a document about DNE design, I think it would give a more 
precise idea about
what event and fid is supposed to be reported by each MDT.

Thanks,
Thomas

Eric Barton wrote:
> Thomas,
>
> Thanks a lot and I hope you don't mind me cc-ing lustre-devel as this
> seems to be of general interest.
>
> Do you have a feel (or measurements :) for the rate at which a changelog
> can be ingested into robinhood?  And I'm wondering about DNE and multiple
> changelogs coming from multiple MDTs.  I'd be very interested to know if
> you've thought about this and have views on what the maximum ingest rate
> could be and whether there will be issues coordinating/merging events
> across multiple feeds.
>
>           Cheers,
>                    Eric
>
> Eric Barton
> CTO Whamcloud, Inc.
>
>   
>> -----Original Message-----
>> From: LEIBOVICI Thomas [mailto:thomas.leibovici at cea.fr]
>> Sent: 29 September 2011 10:04 AM
>> To: Eric Barton
>> Subject: Erratum about indexes in robinhood DB
>>
>> Hello Eric,
>>
>> Re-thinking about your question on indexes in robinhood DB, my answer
>> was incomplete.
>> Actually, there are indexes on user/group/type/status, but there are not
>> on the main table:
>>
>> 1) As I said you, on the main table (the one that list all FS entries),
>> there are as few indexes as possible (just fid as primary key, and
>> parent fid)
>> in order to preserve a good insert/update rate on this table whatever
>> the FS size (the deeper the DB index trees, the slower those requests).
>>
>> 2) There is a secondary table where robinhood maintains aggregated
>> statitics like nbr entries, volume per user/group/type/(hsm)status and
>> which is updated on the fly.
>> This one as indexes on quite all its fields, which makes it possible to
>> get instantaneous stats per user, etc. without penalizing insert/update
>> rate on main table.
>> Indexes on this secondary table are less expensive, given that the set
>> of users is much more resticted that the nbr of entries.
>>
>> This time you have a more complete answer.
>>
>> Best regards
>> Thomas
>>     
>
>   
