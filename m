From: NeilBrown <neilb@suse.com>
Date: Tue, 08 Jan 2019 10:09:56 +1100
Subject: [lustre-devel] [PATCH 00/14] lustre: fixes for many test
 failures
In-Reply-To: <alpine.LFD.2.21.1901072153570.24234@casper.infradead.org>
References: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
 <87ftu5jbbm.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1901072153570.24234@casper.infradead.org>
Message-ID: <877efgjc8r.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jan 07 2019, James Simmons wrote:

>> On Sun, Jan 06 2019, James Simmons wrote:
>> 
>> > This patch series contains mostly fixes to resolve the majority of
>> > the testing failures seen. Besides that are UAPI headers fixes to
>> > prepare for when lustre will leave the staging tree. Include Neil's
>> > dump_page_cache patch as well since it was landed in the OpenSFS
>> > branch and the migration of lu_objects to rhashtables depended on
>> > it.
>> 
>> Thanks - I've applied these.
>> I haven't received all of the PFL series yet ... 16,17,18 still in limbo
>> - so I haven't applied those yet.
>> When the stragglers here here, I suspect they'll all go in.
>
> Do you recieve patch 16,17,18 ? I do see they made it to the mailing list
> archive :

Yes, they arrived eventually, thanks.  The whole series seemed to be
coming in dribs and drabs ... some mail server somewhere must have been
a bit sick.

I'll have a look through them all today.

Thanks,
NeilBrown


>
> http://lists.lustre.org/pipermail/lustre-devel-lustre.org/2019-January/thread.html
>
> Also they are showing up at the patchwork site:
>
> https://patchwork.kernel.org/project/lustre-devel/list
>
> which is much easier to work with as a patch. Lastly if you need I can 
> send you those patches directly to you again. Let me know what you want.
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190108/e46e461e/attachment.sig>
