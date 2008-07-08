From: Peter Braam <Peter.Braam@Sun.COM>
Date: Tue, 08 Jul 2008 11:41:10 -0600
Subject: [Lustre-devel] How store HSM metadata in MDT ?
In-Reply-To: <48732AB1.10802@cea.fr>
Message-ID: <C49902D6.4E45%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I think we have come to the following conclusions:

1. The HSM or a database associated with it implements a table to map FIDs
to stored HSM versions of a file, with other metadata it may need to
maintain its archives.

2. An HSM utility can query and learn about the versions stored for a fid
(or file name).  A "restore" function can copy any version out of the HSM
and place it in the file system.  This is similar to restoring a file from a
backup archive.

3. The file system only has attributes to indicate the state of the primary
archived copy (probably the last fully archived copy of the file), and can
retrieve that file on demand (without user intervention).

4. The HSM database will allow files in snapshots to be encoded with (fsid,
fid) or something similar.

5. for now we ignore block level dedup in the HSM

Can the owner of the HLD make updates?  Please also read on - I have some
more questions below.


On 7/8/08 2:52 AM, "Aurelien Degremont" <aurelien.degremont@cea.fr> wrote:

> Lee Ward a ?crit :
>> If HSM, then, do you intend that the user be allowed to specify *which*
>> version of the file content is desired?
> 
> User could say:
>    "overwrite the current version of this file with this older copies
> which was made few time ago."
> 
> -The current file content is lost.
> -That is the only way to access the older copies content.

Yes, that is reasonable.
 
> There is no namespace tricks, no huge API changes, always one version of
> a file in Lustre, just few functions added to 'lfs' command.

NO - this will not be an lfs command.  This is an HSM command.

> The purpose is just, using the HSM infrastructure, simply add few
> feature to help people asking us for backup features, but this will not
> be a true backup system. This kind of utility requires much more
> development.

I think it would be good to review one more time the following aspects of
the design:

1. how is a bare metal restore arranged (ie. How is metadata moved into the
HSM)?  Can this restore put files in a file system different than Lustre?

2. how are small files grouped then "tar'd up" and how are we setting the
attributes of the inodes of the files that have been placed in the HSM after
this?  How does the index entry for the fids in the HSM database function?

3. how are multiple coordinators and agents utilized to distribute load so
that the HSM can keep up with massive small file creation?

For all of these we have seen sketchy answers in the past, let's dig in and
make sure that we have this right.

Regards,

Peter
