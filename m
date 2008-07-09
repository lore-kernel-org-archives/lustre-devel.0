From: Peter Braam <Peter.Braam@Sun.COM>
Date: Wed, 09 Jul 2008 07:49:25 -0600
Subject: [Lustre-devel] How store HSM metadata in MDT ?
In-Reply-To: <4874BC52.10604@cea.fr>
Message-ID: <C49A1E05.4E85%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




On 7/9/08 7:25 AM, "Aurelien Degremont" <aurelien.degremont@cea.fr> wrote:
> 
>> 3. The file system only has attributes to indicate the state of the primary
>> archived copy (probably the last fully archived copy of the file), and can
>> retrieve that file on demand (without user intervention).
> 
> Ok. Still need to store the purge window on MDT and OST to raise cache
> misses.

Yes.

> How Lustre will update this information if user can use a HSM command
> directly, by-passing Lustre? He can change the file copies present in
> the HSM without Lustre knowing it.

NO - we said that the only operation we do is placing an entire file into
Lustre.


> 
>> 4. The HSM database will allow files in snapshots to be encoded with (fsid,
>> fid) or something similar.
> 
> Can we consider there is always a default snapshot?
> The ID will always be done with FSID+FID ? Or should we consider a
> special case when snapshotting is not enabled ?

Why would you?  You need to make sure that the index field is large enough.
Almost all our customers have more than one file system anyway, regardless
of snapshots.

> 
>>> There is no namespace tricks, no huge API changes, always one version of
>>> a file in Lustre, just few functions added to 'lfs' command.
>> 
>> NO - this will not be an lfs command.  This is an HSM command.
> 
> Could you present a use case of how user will explicitly make backups
> and restore an older copy using the HSM command and no Lustre component?

Hsm_copy_to_fs  <FID>   /mnt/lustre/braams_lost_file
 
> Doing this, the client nodes should be able to communicate with the HSM
> infrastructure, using specific network protocols, and so on.
> You will need to set up your Lustre network and then your HSM network
> even if HSM just need to talk with the Lustre agent.

The utility for restore is not essentially different from what the agent
invokes as a mover.

> 
>> 1. how is a bare metal restore arranged (ie. How is metadata moved into the
>> HSM)?  Can this restore put files in a file system different than Lustre?
> 
> Until now, the metadata were stored inside Lustre, so this was not
> needed. Now, we must add a way for the archiving tool to "setattr" this
> data when restoring a file.
> 
> About a different filesystem, this will depend on the features used by
> the archiving tool to copy back the data and metadata. If those are
> standard, the file could be put in a different filesystem.

Hmm.  This description has no content.  If you don't want to do this, say
so, or describe the entire process in detail.

> 
>> 2. how are small files grouped then "tar'd up" and how are we setting the
>> attributes of the inodes of the files that have been placed in the HSM after
>> this?  How does the index entry for the fids in the HSM database function?
> 
> Presently, just the archiving tool

HOW?

> was supposed to support such feature,
> to avoid having to recode them later (various tools will be needed for
> the various existing HSMs and their development won't be centralized)
> when we will add this kind of feature.
> There is no defined mechanism for grouping file into the HSM presently.

You need to describe this in detail - so far you are just repeating my
questions pretending they are answers.  What events are generated for small
files?  How are they grouped into something that is "tarred up"?  What
happens to all the individual inodes when the tarball hits the HSM?
 
>> 3. how are multiple coordinators and agents utilized to distribute load so
>> that the HSM can keep up with massive small file creation?
> 
> One coordinator per MDT.

No - these must be independent considerations.  A coordinator may be much
slower than an MDS node in handling a single file.  I say this because this
has been the experience in the industry so far - with small files the HSM
can not at all keep up.

> The coordinator deals only with its MDT files.
> The coordinator dispatches their requests on the agents with a
> round-robin.

No, I think a more sophisticated policy is needed.  Eg. Small files to these
agents, big files to others.


> Agents can refuse requests if they cannot handle them (too
> busy).

NO NO NO.

> Coordinator try another one. If no agent are available, it
> postpones the request.
> 

Please take time to respond with details.

Thanks.

Peter
