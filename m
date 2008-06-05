From: Johann Lombardi <johann@sun.com>
Date: Thu, 05 Jun 2008 14:27:08 +0200
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <C46D1785.5811%peter.braam@sun.com>
References: <20080605083957.GQ6283@lore> <C46D1785.5811%peter.braam@sun.com>
Message-ID: <20080605122708.GR6283@lore>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jun 05, 2008 at 04:09:41AM -0700, Peter Braam wrote:
> Quota are determined by the owner of the file, not by the uid of the
> process.

In my understanding, the client is not aware of the server-side uid/gid and
the file owner returned to the client is translated too. Please let me know
if I misunderstood how the uid/gid mapping feature works.

> We have been propagating owners / gid of files from MDS to OSS for this
> reason.
>
> I don't understand the issue.

The problem is that the owner / group is propagated to the OSTs through the
client the first time it sends a bulk write rpc (by setting the
OBD_MD_FLUID/GID flags) and those identifiers - supplied by the client -
must be translated too.

Johann
