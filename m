From: Oleg Drokin <oleg.drokin@oracle.com>
Date: Wed, 30 Jun 2010 14:27:42 -0400
Subject: [Lustre-devel] Attribute caching and OBD_CONNECT_ATTRFID
In-Reply-To: <201006301823.o5UINbgU026948@hedwig.cmf.nrl.navy.mil>
References: <201006301823.o5UINbgU026948@hedwig.cmf.nrl.navy.mil>
Message-ID: <6B0FCD90-088D-4F32-8F6D-3AD95061B4CB@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Jun 30, 2010, at 2:23 PM, Ken Hornstein wrote:

> Alright, so, I had some time to stare at this code some more ... a few
> questions.
> 
>> Currently, the Linux VFS will flag it as "DCACHE_INVALID" and it needs
>> to be revalidated before use.
> This is DCACHE_LUSTRE_INVALID, right?  I couldn't find DCACHE_INVALID
> anywhere.

Yes.

>>> Could you point me to the section of the code in the Linux client that
>>> does the inode invalidation upon lock cancellation?  I want to make sure
>>> that I follow it and I'm doing the right thing.
>> The majority of this work was done in bug 20433.
> I see the patch has been re-worked a bit in more recent Lustre.  As I
> read it ... this just gets rid of the dentry for the inode, right?
> That forces a new name lookup the next time the file is accesed by
> name, right?  I guess that's how the lack of CONNECT_ATTRFID hasn't
> been noticed.

Right. The only way to encounter attr_by_fid is to execute something like fstat
on an already opened file descriptor.
Also there used to be NFS implications, I think.

> As a side question ... I know it hasn't really been resolved (from what
> I've read on this thread), but going forward should I assume that
> CONNECT_ATTRFID will not be available?  It sounds like from what you
> are saying that it will eventually not be available.

Actually it should be available going forward, at least I hope so.
This is a pretty important feature to ensure that open-unlinked files
work correctly.

Bye,
    Oleg
