From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Wed, 20 Oct 2010 10:35:41 -0600
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
In-Reply-To: <00d001cb705a$fd64cb80$f82e6280$@com>
References: <AANLkTimj53P0mnF1Wy=bN2+Sb=NnMyg8UgYKLyB7ks8=@mail.gmail.com>
	<AANLkTimyq1J0gcDTeYaTNP6zbg6cRCkvFZVZ_c5izKRo@mail.gmail.com>
	<D3E302FC-B752-4E9D-9E84-40F04626E8DA@oracle.com>
	<AANLkTik53-vQLA9DTj858=San9fgMB+94i8eChvHomEK@mail.gmail.com>
	<EF473480-D749-4AF4-B843-697A2EDE10A2@oracle.com>
	<4CBEA415.80307@gmail.com>
	<9C26CBA7-8DBD-4875-8E14-FB663B749096@oracle.com>
	<4CBEA8A9.9080802@gmail.com> <00d001cb705a$fd64cb80$f82e6280$@com>
Message-ID: <90E83093-2655-4C70-ACEA-E75D7E8C5511@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-10-20, at 7:30, Eric Barton <eeb@whamcloud.com> wrote:
>> On 10/20/10 12:24 PM, Andreas Dilger wrote:
>>> I'm reluctant to expose the whole FID namespace to applications, 
> 
> ??? It can just be opaque bytes to the app.

This was in reply to Alex Z's comments that we can just do open-by-FID from userspace.

>>> since this completely bypasses all directory permissions and allows
>>> opening files only based on their inode permissions.  If we require a
>>> name_to_handle() syscall to succeed first, before allowing
>>> open_by_handle() to work, then at least we know that one of the
>>> involved processes was able to do a full path traversal.
> 
> I think this defeats the scalability objective - we trying to avoid having
> to pull the namespace into every client aren't we?

The name_to_handle() only needs to be called on a single node, and open_by_handle() is called on the other nodes. I agree that this doesn't avoid the full O(n) RPCs for the open itself  but at least it does avoid the full path traversal from every client and on the MDS (replacing it with an MPI broadcast of the handle). 

> 

Cheers, Andreas
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101020/b4201823/attachment.htm>
