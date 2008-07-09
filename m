From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Wed, 09 Jul 2008 15:25:38 +0200
Subject: [Lustre-devel] How store HSM metadata in MDT ?
In-Reply-To: <C49902D6.4E45%peter.braam@sun.com>
References: <C49902D6.4E45%peter.braam@sun.com>
Message-ID: <4874BC52.10604@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter Braam a ?crit :
> 1. The HSM or a database associated with it implements a table to map FIDs
> to stored HSM versions of a file, with other metadata it may need to
> maintain its archives.

Ok

> 2. An HSM utility can query and learn about the versions stored for a fid
> (or file name).  A "restore" function can copy any version out of the HSM
> and place it in the file system.  This is similar to restoring a file from a
> backup archive.

Ok, that's copy-in.

> 3. The file system only has attributes to indicate the state of the primary
> archived copy (probably the last fully archived copy of the file), and can
> retrieve that file on demand (without user intervention).

Ok. Still need to store the purge window on MDT and OST to raise cache 
misses.
How Lustre will update this information if user can use a HSM command 
directly, by-passing Lustre? He can change the file copies present in 
the HSM without Lustre knowing it.

> 4. The HSM database will allow files in snapshots to be encoded with (fsid,
> fid) or something similar.

Can we consider there is always a default snapshot?
The ID will always be done with FSID+FID ? Or should we consider a 
special case when snapshotting is not enabled ?

>> There is no namespace tricks, no huge API changes, always one version of
>> a file in Lustre, just few functions added to 'lfs' command.
> 
> NO - this will not be an lfs command.  This is an HSM command.

Could you present a use case of how user will explicitly make backups 
and restore an older copy using the HSM command and no Lustre component?

Doing this, the client nodes should be able to communicate with the HSM 
infrastructure, using specific network protocols, and so on.
You will need to set up your Lustre network and then your HSM network 
even if HSM just need to talk with the Lustre agent.

> 1. how is a bare metal restore arranged (ie. How is metadata moved into the
> HSM)?  Can this restore put files in a file system different than Lustre?

Until now, the metadata were stored inside Lustre, so this was not 
needed. Now, we must add a way for the archiving tool to "setattr" this 
data when restoring a file.

About a different filesystem, this will depend on the features used by 
the archiving tool to copy back the data and metadata. If those are 
standard, the file could be put in a different filesystem.

> 2. how are small files grouped then "tar'd up" and how are we setting the
> attributes of the inodes of the files that have been placed in the HSM after
> this?  How does the index entry for the fids in the HSM database function?

Presently, just the archiving tool was supposed to support such feature, 
to avoid having to recode them later (various tools will be needed for 
the various existing HSMs and their development won't be centralized) 
when we will add this kind of feature.
There is no defined mechanism for grouping file into the HSM presently.

> 3. how are multiple coordinators and agents utilized to distribute load so
> that the HSM can keep up with massive small file creation?

One coordinator per MDT.
The coordinator deals only with its MDT files.
The coordinator dispatches their requests on the agents with a 
round-robin. Agents can refuse requests if they cannot handle them (too 
busy). Coordinator try another one. If no agent are available, it 
postpones the request.


-- 
Aurelien Degremont
CEA
