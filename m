From: Nicolas Williams <Nicolas.Williams@oracle.com>
Date: Wed, 20 Oct 2010 09:45:25 -0500
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
In-Reply-To: <AANLkTiktq2eG3j_Q1q4Z_NfVs83vqRuM0yLqeV1sbqZU@mail.gmail.com>
References: <AANLkTimj53P0mnF1Wy=bN2+Sb=NnMyg8UgYKLyB7ks8=@mail.gmail.com>
	<AANLkTimyq1J0gcDTeYaTNP6zbg6cRCkvFZVZ_c5izKRo@mail.gmail.com>
	<D3E302FC-B752-4E9D-9E84-40F04626E8DA@oracle.com>
	<AANLkTik53-vQLA9DTj858=San9fgMB+94i8eChvHomEK@mail.gmail.com>
	<EF473480-D749-4AF4-B843-697A2EDE10A2@oracle.com>
	<4CBEA415.80307@gmail.com>
	<9C26CBA7-8DBD-4875-8E14-FB663B749096@oracle.com>
	<4CBEA8A9.9080802@gmail.com>
	<AANLkTiktq2eG3j_Q1q4Z_NfVs83vqRuM0yLqeV1sbqZU@mail.gmail.com>
Message-ID: <20101020144524.GQ1635@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Oct 20, 2010 at 12:38:44PM +0400, Nikita Danilov wrote:
> On 20 October 2010 12:30, <bzzz.tomas@gmail.com> wrote:
> > yes, and that could be solved if server returns a series of FIDs,
> > then client could check whether any of those is over-mounted?
> 
> This is what sufficiently smart nfsv4 clients are supposed to do, by the
> way, I believe: issue a compound RPC with a sequence of LOOKUP requests and
> traverse returned sequence of file-id-s locally, checking for mount points.

Yes.  The detection and replication of server-side mountpoints on the
client-side is called "mirror mounts" in Solaris, and it's quite handy.

For clients the main issue is going to be whether the VFS allows plugins
to resolve more than one path component at a time.
