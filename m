From: Peter Braam <Peter.Braam@Sun.COM>
Date: Sun, 06 Jul 2008 16:53:02 -0600
Subject: [Lustre-devel] How store HSM metadata in MDT ?
In-Reply-To: <1215372287.17129.66.camel@wheel>
Message-ID: <C496A8EE.4DAC%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lee - Thank you for this clear explanation.

If solely the HSM can store multiple versions, we have already some
difficulties.  One might imagine setting a particular version in the HSM as
the primary one, meaning that this primary one will be transparently
restored or that a pre-staging utility will select this by default.

If the file is fully absent in the file system staging or restoring it will
work correctly.  However, if a part of the file remains in the file system,
this HSM versioning becomes complicated because the file will again have to
remember what HSM versions the fragments belong to, and we are almost back
where we were.

I think the emails so far make it clear that we don't want to have one
Lustre inode be associated with multiple objects in the HSM.

If the HSM system is used as a backup then the restore operations will have
user or operator involvement and this objection to storing multiple versions
in the HSM does not apply. However, the we still don't' want to store a
pointer to each version in the file system, that belongs in the HSM/backup
metadata store.

However, I don't want to end the discussion right here.

With DMU (or otherwise) we will get file systems where snapshots become
possible and common, and these snapshots will contain different versions of
the same file.  The way the namespace distinguishes these is that in the
pair (fsid, fid) the fsid is different for each snapshot.   So probably the
id in the HSM should allow for an fsid component.

Now DMU snapshot versions of one inode share blocks, and this leads to the
question if/how we can efficiently share blocks in the HSM also.  This
discussion would probably equally apply to upcoming "dedup" efforts for the
DMU, which the virtualization and "email attachment" community think are
very important.

Rick, Jeff  - how will we handle this?

Peter





On 7/6/08 1:24 PM, "Lee Ward" <lee@sandia.gov> wrote:

> Are you all talking about HSM, really, or simply backup?
> 
> If backup, read no further.
> 
> If HSM, then, do you intend that the user be allowed to specify *which*
> version of the file content is desired?
> 
> If yes and you also want the standard API and utilities to function,
> seamlessly, then the version must be exposed in the name space, no? I.e.
> For any file named "foo" with 3 versions, for instance, there would be
> foo;1, foo;2, foo;3, and "foo" which is an alias for "foo;1".
> 
> If no, then, you'll have to craft a special API that will motivate
> special tools. However, HPSS already has this API and set of tools so
> what's the point? Wouldn't it be better to just modify HPSS to
> understand versions?
> 
> If HSM, then, do you intend that two users might be allowed to work with
> two, or more, versions of the file content simultaneously?
> 
> If yes then same problem as above since those two versions might need to
> be in the same directory, at the same time, right?
> 
> No matter what you do, you have problems that can't be resolved when
> mixing a POSIX name space with file versions, I believe. Since POSIX
> reserves no characters you can't pick a scheme that includes version
> information in the name without at least being confusing and the API
> provides no other way to specify the version, no?
> 
> My personal choice would be to shy off direct version support by the
> native file system. It doesn't seem to have a reasonable solution
> without involving the user somehow to specify names or naming schemes.
> That kind of involvement just begs for a special utility and, once
> there, relieves the file system of the need to support any but the most
> recent version itself, anyway.
> 
> --Lee
> 
> On Sat, 2008-07-05 at 21:24 -0600, Peter Braam wrote:
>> 
>> 
>> On 7/4/08 8:37 AM, "Aurelien Degremont" <aurelien.degremont@cea.fr> wrote:
>> 
>>> Peter Braam a ?crit :
>>>> If there is more than one copy in the archive, it would be preferable if
>>>> the
>>>> archive could maintain a mapping from the Lustre fid of the file to the
>>>> archived copies.  Associated with the FID of the data would then be a list
>>>> of archived copies, timestamps etc.
>>> 
>>> Do you mean that the HSM will be aware of various versions of one same
>>> file, identified in Lustre by a FID ?
>>> Or this will be masked by the archiving tool , doing some tricks to
>>> simulate it ?
>>> 
>>>> Can that be done in HPSS?
>>> 
>>> HPSS alone cannot do versioning on its files presently.
>> 
>> But your archiving utility that copies from Lustre to HPSS can maintain
>> database of these objects - no need to store anything in Lustre.
>> 
>> 
>>> 
>>> 
>>>> If not, policy related operations like purging older files etc will become
>>>> very complex and not scalable.  For example, a search to find older files
>>>> in
>>>> the archive would require an e2scan operation to find the inodes and then
>>>> the objects in the archive.  If the file system was not available anymore
>>>> (for whatever reason), it is not even clear that such a purge could still
>>>> happen.
>>>> 
>>>> With an archive based database this can be an indexed search in the
>>>> archive,
>>>> which is faster and more appropriate.
>>> 
>>> By purgin do mean purging in Lustre or in the HSM?
>> 
>> The HSM.
>> 
>>> There's no issue with purging in Lustre because this do not imply the HSM.
>>> And removal of oldest copies in the HSM could be done asynchronously,
>>> slowly.
>> 
>> There is a rule in Lustre - no scanning, ever.  This rule will not be broken
>> by HSM.
>> 
>> So, you have to move your management of ID's of the archvied copies outside
>> of Lustre, in some database.  This will actually save you time - doing this
>> in the MDS will be no fun.
>> 
>> The MDS should only get attributes to indicate if and what version of a file
>> is in the archive and a cursor (maybe other information) in relation with
>> ongoing restores.
>> 
>> Peter
>> 
>> 
>>> 
>>> I'm not sure I see what you mean here
>>> 
>> 
>> 
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>> 
> 
> 
