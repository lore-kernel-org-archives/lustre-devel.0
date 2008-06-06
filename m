From: Peter Braam <Peter.Braam@Sun.COM>
Date: Fri, 06 Jun 2008 06:21:46 -0600
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <20080606073313.GA21875@lore>
Message-ID: <C46E87FA.589E%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




On 6/6/08 1:33 AM, "Johann Lombardi" <johann@sun.com> wrote:

> On Thu, Jun 05, 2008 at 06:45:36AM -0700, Peter Braam wrote:
>> Well, this protocol hasn't been published yet; why not include the server
>> side uid / gid then?
> 
> I understood from Fanyong that according to the remote client design
> requirements, we should not allow the remote client to access the server-side
> uid/gid mapping.

You have two choices: break that rule OR let the MDS server do the ownership
changes.  It's not complicated, just make a choice.

> 
>> But more seriously, how is this encoded in such a way that the OST can trust
>> the information - it must be in the capability too?
> 
> hmm, I don't see any capability associated with this.

We had better find it, otherwise there is a security hole.


> 
> Johann
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
