From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Wed, 30 Jun 2010 14:23:37 -0400
Subject: [Lustre-devel] Attribute caching and OBD_CONNECT_ATTRFID
In-Reply-To: <9B242A89-CFDA-47D6-9726-4C2754DA141F@oracle.com>
Message-ID: <201006301823.o5UINbgU026948@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Alright, so, I had some time to stare at this code some more ... a few
questions.

>Currently, the Linux VFS will flag it as "DCACHE_INVALID" and it needs
>to be revalidated before use.

This is DCACHE_LUSTRE_INVALID, right?  I couldn't find DCACHE_INVALID
anywhere.

>> Could you point me to the section of the code in the Linux client that
>> does the inode invalidation upon lock cancellation?  I want to make sure
>> that I follow it and I'm doing the right thing.
>
>The majority of this work was done in bug 20433.

I see the patch has been re-worked a bit in more recent Lustre.  As I
read it ... this just gets rid of the dentry for the inode, right?
That forces a new name lookup the next time the file is accesed by
name, right?  I guess that's how the lack of CONNECT_ATTRFID hasn't
been noticed.

As a side question ... I know it hasn't really been resolved (from what
I've read on this thread), but going forward should I assume that
CONNECT_ATTRFID will not be available?  It sounds like from what you
are saying that it will eventually not be available.

--Ken
