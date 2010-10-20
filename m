From: Nikita Danilov <Nikita_Danilov@xyratex.com>
Date: Wed, 20 Oct 2010 12:38:44 +0400
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
In-Reply-To: <4CBEA8A9.9080802@gmail.com>
References: <AANLkTimj53P0mnF1Wy=bN2+Sb=NnMyg8UgYKLyB7ks8=@mail.gmail.com>
	<AANLkTimyq1J0gcDTeYaTNP6zbg6cRCkvFZVZ_c5izKRo@mail.gmail.com>
	<D3E302FC-B752-4E9D-9E84-40F04626E8DA@oracle.com>
	<AANLkTik53-vQLA9DTj858=San9fgMB+94i8eChvHomEK@mail.gmail.com>
	<EF473480-D749-4AF4-B843-697A2EDE10A2@oracle.com>
	<4CBEA415.80307@gmail.com>
	<9C26CBA7-8DBD-4875-8E14-FB663B749096@oracle.com>
	<4CBEA8A9.9080802@gmail.com>
Message-ID: <AANLkTiktq2eG3j_Q1q4Z_NfVs83vqRuM0yLqeV1sbqZU@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 20 October 2010 12:30, <bzzz.tomas@gmail.com> wrote:

> On 10/20/10 12:24 PM, Andreas Dilger wrote:
> > I'm reluctant to expose the whole FID namespace to applications, since
> this completely bypasses all directory permissions and allows opening files
> only based on their inode permissions.  If we require a name_to_handle()
> syscall to succeed first, before allowing open_by_handle() to work, then at
> least we know that one of the involved processes was able to do a full path
> traversal.
>
> yes, this is a good point. can be solved if you use FID +
> capability/signature ?
>
> >> another idea was to do whole path traversal on MDS within a single RPC.
> >> bug that'd require amount of changes to llite and/or VFS and keep MDS
> >> a bottleneck.
> >
> > This was discussed a long time ago, and has the potential drawback that
> if one of the path components is over-mounted on the client (e.g. local
> RAM-based tmpfs on a Lustre root filesystem) then the MDS-side path
> traversal would be incorrect.  It could return an entry underneath the
> mountpoint, instead of inside it.
>
> yes, and that could be solved if server returns a series of FIDs,
> then client could check whether any of those is over-mounted?
>

This is what sufficiently smart nfsv4 clients are supposed to do, by the
way, I believe: issue a compound RPC with a sequence of LOOKUP requests and
traverse returned sequence of file-id-s locally, checking for mount points.

Nikita.


>
> thanks, z
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101020/ae9ad024/attachment.htm>
