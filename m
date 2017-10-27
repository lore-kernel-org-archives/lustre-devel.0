From: NeilBrown <neilb@suse.com>
Date: Fri, 27 Oct 2017 22:10:27 +1100
Subject: [lustre-devel] [PATCH 9/9] staging: lustre: ldlm: remove unused
 field 'fwd_generation'
In-Reply-To: <C206A005-681E-462C-83DB-0A9320D28CDA@intel.com>
References: <150871988297.3340.4522589460981284121.stgit@noble>
 <150872002986.3340.15607846693582678949.stgit@noble>
 <C206A005-681E-462C-83DB-0A9320D28CDA@intel.com>
Message-ID: <87h8ukdexo.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dilger, Andreas" <andreas.dilger@intel.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>

On Fri, Oct 27 2017, Dilger, Andreas wrote:

> On Oct 22, 2017, at 18:53, NeilBrown <neilb@suse.com> wrote:
>> 
>> With this field gone, we don't need local variables 'imp' or 'obd'
>> any more.
>> 
>> Signed-off-by: NeilBrown <neilb@suse.com>
>
> Thanks for the patches.

And thanks a lot for the review!

NeilBrown

>
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20171027/3fafb17e/attachment.sig>
