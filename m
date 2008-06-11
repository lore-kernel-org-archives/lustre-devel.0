From: Alexander Zarochentsev <Alexander.Zarochentsev@Sun.COM>
Date: Wed, 11 Jun 2008 20:46:13 +0400
Subject: [Lustre-devel] Commit on share
In-Reply-To: <C4754ABB.5AB3%peter.braam@sun.com>
References: <C4754ABB.5AB3%peter.braam@sun.com>
Message-ID: <200806112046.13903.alexander.zarochentsev@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 11 June 2008 19:26:19 Peter Braam wrote:
> On 6/11/08 8:21 AM, "Alexander Zarochentsev"
>
> <Alexander.Zarochentsev@Sun.COM> wrote:
> > Hello,
> >
> > On 27 May 2008 14:44:18 Peter Braam wrote:
> >> This HLD is definitely not ready at all.  It is very short, lacks
> >> interaction diagrams and the arguments made are not sufficiently
> >> detailed.
> >
> > is the following definition of dependent operation more clear?
> >
> > Operation B depends on operation A if:
> >
> > 1. A and B modify the same object
> > 2. B modifies the object after A (LDLM serializes object access)
> > 3. A isn't committed yet
> > 4. A and B are issued by different clients
>
> This shows a fundamental mistake, and one I was afraid of.  If a
> second client only reads uncommitted data there is already a
> dependency.

The definition above is intentionally done that way.
It is just to fit requirements from the arch page, one of them is
".. avoid non-recoverable requests". A non-recoverable request is a 
request which cannot be replayed due to object version / request 
version mismatch. CoS doesn't care about requests which are not 
replayable and the definition reflects that.

Well, I understand now you want more than an optimization to VBR but I 
had to explain the mistake.

s/modify/access/ :

1. A and B access the same object, A is a write access.
2. B accesses the object after A (LDLM serializes object access)
3. A isn't committed yet
4. A and B are issued by different clients

A question: the definition still counts parallel file creation as 
dependent operation but actually the operations can be replayed 
independently. Is the definition OK for CoS?

Or we can add (results implementation complexity)
5. A depends on the result of B: file creation and readdir, creation and 
deletion of the same file and so on.

> You need to read the database literature - this is standard stuff,
> here is a link to a great book:
>
> http://research.microsoft.com/~philbe/ccontrol/

> Peter

-- 
Alexander "Zam" Zarochentsev
Staff Engineer
Lustre Group, Sun Microsystems
