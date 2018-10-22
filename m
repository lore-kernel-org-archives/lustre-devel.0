From: NeilBrown <neilb@suse.com>
Date: Mon, 22 Oct 2018 15:08:24 +1100
Subject: [lustre-devel] [PATCH 20/28] lustre: obdclass: deprecate
 OBD_GET_VERSION ioctl
In-Reply-To: <alpine.LFD.2.21.1810201947290.16676@casper.infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
 <1539543498-29105-21-git-send-email-jsimmons@infradead.org>
 <87a7ncc8a0.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1810201947290.16676@casper.infradead.org>
Message-ID: <87bm7m8vyf.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, Oct 20 2018, James Simmons wrote:

>> On Sun, Oct 14 2018, James Simmons wrote:
>> >  
>> > +		if (!warned) {
>> > +			warned = true;
>> > +			CWARN("%s: ioctl(OBD_GET_VERSION) is deprecated, use llapi_get_version_string() and/or relink\n",
>> > +			      current->comm);
>> > +		}
>> 
>> Is there a good reason not to use WARN_ON_ONCE() here?
>
> Oh that is much nicer. Didn't know about it. Shall I submit a new
> patch or will it be changed when applied to lustre-testing?

I've made the change directly - no need to resubmit.

Thanks,
NeilBrown




-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181022/ae48d8d9/attachment.sig>
