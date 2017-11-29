From: NeilBrown <neilb@suse.com>
Date: Wed, 29 Nov 2017 22:37:54 +1100
Subject: [lustre-devel] [PATCH 08/10] staging: lustre: lov: use
 list_for_each_entry in lov_obd.c
In-Reply-To: <20171129094023.GA7597@kroah.com>
References: <150933945578.22133.8029060522107378499.stgit@noble>
 <150933956729.22133.13130557672702877610.stgit@noble>
 <20171124154341.GA16654@kroah.com> <87r2shwzyf.fsf@notabene.neil.brown.name>
 <20171129094023.GA7597@kroah.com>
Message-ID: <87bmjlwc19.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Wed, Nov 29 2017, Greg Kroah-Hartman wrote:

> On Wed, Nov 29, 2017 at 02:01:12PM +1100, NeilBrown wrote:
>> Subject: [PATCH] staging: lustre: lov: use list_for_each_entry in lov_obd.c
>
> Why is there a subject line in the body of the text here?  Will git
> figure this out correctly?

Because I wanted to leave the original subject unchanged so it would be
fairly clear to you the context of the email, but also wanted to be
certain picked up the right subject (though in this case it would have
worked right anyway I think).
Yes, "git am" will see the Subject: line in the body and over-ride the
Subject line in the headers.

Thanks,
NeilBrown


>
>> Using the *_entry macro simplifies the code slightly.
>> 
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>> 
>> Resubmitted with non-empty changelog text.
>
> Did I apply the others?  Can you just send a new series of whatever I
> didn't apply so it's obvious for me as to what to do?
>
> thanks,
>
> greg k-h
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20171129/2003f661/attachment.sig>
