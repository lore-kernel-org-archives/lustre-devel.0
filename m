From: NeilBrown <neilb@suse.com>
Date: Fri, 08 Jun 2018 07:50:37 +1000
Subject: [lustre-devel] A new drivers/staging/lustre
In-Reply-To: <DM3PR1101MB1213BB514F8D6E25F725BB1DCB640@DM3PR1101MB1213.namprd11.prod.outlook.com>
References: <874lifnxbp.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1806070557300.23188@casper.infradead.org>
 <87po12ncjv.fsf@notabene.neil.brown.name>
 <A139C7E5-0406-4078-B579-8DCF5B85F10F@cray.com>
 <DM3PR1101MB1213BB514F8D6E25F725BB1DCB640@DM3PR1101MB1213.namprd11.prod.outlook.com>
Message-ID: <87efhimfki.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jun 07 2018, Patrick Farrell wrote:

> Doug,
>
> Another thought about the core reason.
>
> Commitment to this.  The existing code state (weird, abandoned 2.4.something code) and merge rules seemingly made it impossible to shift development in this direction in any meaningful way, so perhaps it's chicken and egg...  but as long as Lustre is released and developed primarily out of tree, I can't see this working.  Would it just be a "sync everything but still do releases" approach?  Is that viable?  Etc.
>
> Thoughts appreciated.

Yes, commitment is important - from management was well as developers.
If you think getting lustre upstream is important then make sure you
manager understands why.

Having development in two separate tree  - one heading for upstream
inclusion, the other used by customers - could be a problem and
certainly needs an end date, but I think it is our best option at the
moment (even though Greg claimed it was part of his reason for ejecting
lustre from staging).

I think that imposing an upstream development module on (what I've
decided to call) legacy-lustre would be a constant battle with a low
success rate.  Conversely moving code from legacy-lustre into an
upstream work-flow should be quite manageable providing time and skills
are available.

I would really like to be able to point to a location in the
legacy-lustre git history and be able to say "linux-lustre has all
features up to this point", and then to progressively copy features
across and move that point forward.  As a feature is copied, we make
sure it conforms with upstream standards.  I won't be doing any of this
until I'm really happy with what is already in linux-lustre, but I won't
try to set priorities for other people.

Once we get to the point where linux-lustre has feature-parity with
legacy-lustre, then we can discuss doing development in linux-lustre
first, and copying it across to legacy-lustre only as long as people
care.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180608/7da00f5f/attachment.sig>
