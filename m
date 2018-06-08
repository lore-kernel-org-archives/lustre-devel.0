From: NeilBrown <neilb@suse.com>
Date: Fri, 08 Jun 2018 16:00:17 +1000
Subject: [lustre-devel] A new drivers/staging/lustre
In-Reply-To: <51E547E3-5876-4AE0-9226-FDE082213650@intel.com>
References: <874lifnxbp.fsf@notabene.neil.brown.name>
 <16129B94-CF52-4E5E-9A5A-2EC0E01BEEE0@intel.com>
 <MWHPR11MB2029D262448ACF23E0275C11D4640@MWHPR11MB2029.namprd11.prod.outlook.com>
 <51E547E3-5876-4AE0-9226-FDE082213650@intel.com>
Message-ID: <87zi05lswe.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jun 07 2018, Dilger, Andreas wrote:

> On Jun 7, 2018, at 16:53, Doug Oucharek <doucharek@cray.com> wrote:
>> 
>> Does this mean we would be pushing patches to Gerrit rather than having to email them out?  I believe for the test system to work automatically, the answer is yes.
>
> I'm not an expert with Gerrit configuration, so I'm not sure if there is an
> email-to-change gateway plugin for it or not.  I believe it can be configured
> to send the full patch in emails.  I get an email for every patch submitted,
> but I configure it to only deliver the commit message and not the whole patch.
>
> Since everyone is using Git anyway, using "git push" to submit patches to Gerrit
> for review (and forwards them to the list, if that is what people want) isn't
> more effort than "git send-email" to send them to the list directly.

I think that pushing patches to Gerrit for testing is essential.  I'm
less keen on using it for review because it doesn't fit my current
workflow, but I could probably adjust if necessary.  My preference would
be for people to develop patches doing their own local testing to avoid
the really embarrassing errors (I have a 4-node virtual cluster on my
desktop) and then post them to a list for wider review.  If that passes
then someone (maybe one of a small team other something) adds them to a
git tree (either with "git am" or "git pull", whatever works for people)
which gerrit runs tests on.  We would try to get this tree incorporated
into the 01.org testing so that we get even more coverage.  They might
not be able to run lustre-fs tests, but they do static analysis testing
which should cover lustre.

Code wouldn't migrate to the "main" tree until it had passed both review
and testing.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180608/a6a71e21/attachment.sig>
