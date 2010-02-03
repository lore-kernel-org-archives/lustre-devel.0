From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Wed, 03 Feb 2010 20:05:15 +0300
Subject: [Lustre-devel] SOM re-design, overview
In-Reply-To: <A2258830-1799-49C9-B1F5-97739051DD24@Sun.COM>
References: <A2258830-1799-49C9-B1F5-97739051DD24@Sun.COM>
Message-ID: <4B69ACCB.4020006@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2/3/10 7:46 PM, Vitaly Fertman wrote:
> I. Introduction.
>
> SOM is split to several simple mechanisms: invalidation, revalidation,
> llog cleanup.

for ones who are new with SOM (Size on MDS):

SOM attributes - i_size, i_blocks and i_atime of a file, currently we
take them from OST (meaning a bunch of RPCs, and 2 * RTT at least)

in order to improve some workloads (like ls -l) we'd like to cache SOM
attributes so that getattr can be done in RTT with 1 RPC.

revalidation - a process to cache SOM attributes on MDS. we can do
revalidation when file isn't open for write and all cached (dirty)
data is written.

invalidation - a process to drop cached SOM attributes on MDS. 
invalidation starts when file is open for write. from this point to
successful revalidation SOM attributes can't be cached on MDS and
instead should be taken from OST (as we do currently).


z.
