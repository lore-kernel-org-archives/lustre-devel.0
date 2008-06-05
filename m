From: Peter Braam <Peter.Braam@Sun.COM>
Date: Thu, 05 Jun 2008 06:45:36 -0700
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <20080605122708.GR6283@lore>
Message-ID: <C46D3C11.5835%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Well, this protocol hasn't been published yet; why not include the server
side uid / gid then?

But more seriously, how is this encoded in such a way that the OST can trust
the information - it must be in the capability too?

Peter


On 6/5/08 5:27 AM, "Johann Lombardi" <johann@sun.com> wrote:

> On Thu, Jun 05, 2008 at 04:09:41AM -0700, Peter Braam wrote:
>> Quota are determined by the owner of the file, not by the uid of the
>> process.
> 
> In my understanding, the client is not aware of the server-side uid/gid and
> the file owner returned to the client is translated too. Please let me know
> if I misunderstood how the uid/gid mapping feature works.
> 
>> We have been propagating owners / gid of files from MDS to OSS for this
>> reason.
>> 
>> I don't understand the issue.
> 
> The problem is that the owner / group is propagated to the OSTs through the
> client the first time it sends a bulk write rpc (by setting the
> OBD_MD_FLUID/GID flags) and those identifiers - supplied by the client -
> must be translated too.
> 
> Johann
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
