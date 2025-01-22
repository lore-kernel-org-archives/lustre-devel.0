Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E5244C02181
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Jan 2025 20:54:26 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Ydbsr5X8Zz1xPn;
	Wed, 22 Jan 2025 12:54:24 -0800 (PST)
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Ydbsn2YNcz1wPR
 for <lustre-devel@lists.lustre.org>; Wed, 22 Jan 2025 12:54:21 -0800 (PST)
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by smtp-out2.suse.de (Postfix) with ESMTPS id AF63F1F385;
 Wed, 22 Jan 2025 20:54:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1737579259; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=FSlvSC0f/rbfjuD6n0/A1FaCdS53aTWEynYHrrhmMhA=;
 b=yCJIB/YtDlUPXvr8HELupZA4vxLIP7joyNnyLbUZ2fK07SUROeaDUHxeRiuIVTcgAyxwca
 WExbInV1lyXguNHGM2hzrpVutvdh6BGNf2HLranaWUfbXa57KEPJYK8TbVPu2hx9Xi8UAT
 Lt635HCBg8CtY832N6RWhiaf3csrREg=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1737579259;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=FSlvSC0f/rbfjuD6n0/A1FaCdS53aTWEynYHrrhmMhA=;
 b=EmnMkEIEJ4k/T/vjhDULG+U6+4Me/Z7WDWXEgBM37GMGkKeSH23YZPRJvkNUB8C5lsQj8C
 8Bu2+FzT4gsalcBA==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1737579259; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=FSlvSC0f/rbfjuD6n0/A1FaCdS53aTWEynYHrrhmMhA=;
 b=yCJIB/YtDlUPXvr8HELupZA4vxLIP7joyNnyLbUZ2fK07SUROeaDUHxeRiuIVTcgAyxwca
 WExbInV1lyXguNHGM2hzrpVutvdh6BGNf2HLranaWUfbXa57KEPJYK8TbVPu2hx9Xi8UAT
 Lt635HCBg8CtY832N6RWhiaf3csrREg=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1737579259;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=FSlvSC0f/rbfjuD6n0/A1FaCdS53aTWEynYHrrhmMhA=;
 b=EmnMkEIEJ4k/T/vjhDULG+U6+4Me/Z7WDWXEgBM37GMGkKeSH23YZPRJvkNUB8C5lsQj8C
 8Bu2+FzT4gsalcBA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 74B21136A1;
 Wed, 22 Jan 2025 20:54:18 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
 by imap1.dmz-prg2.suse.org with ESMTPSA id N+Q9CvpakWexQQAAD6G6ig
 (envelope-from <neilb@suse.de>); Wed, 22 Jan 2025 20:54:18 +0000
MIME-Version: 1.0
From: "NeilBrown" <neilb@suse.de>
To: "Alexey Lyahkov" <alexey.lyashkov@gmail.com>
In-reply-to: <7459DF85-7A0F-4DC8-9EC3-CA6F3C86234E@gmail.com>
References: <>, <7459DF85-7A0F-4DC8-9EC3-CA6F3C86234E@gmail.com>
Date: Thu, 23 Jan 2025 07:54:11 +1100
Message-id: <173757925141.22054.738723965751021240@noble.neil.brown.name>
X-Spamd-Result: default: False [-4.17 / 50.00]; BAYES_HAM(-3.00)[100.00%];
 NEURAL_HAM_LONG(-1.00)[-0.998]; MIME_GOOD(-0.10)[text/plain];
 NEURAL_HAM_SHORT(-0.07)[-0.364]; ARC_NA(0.00)[];
 RCVD_VIA_SMTP_AUTH(0.00)[]; TO_DN_SOME(0.00)[];
 TO_DN_EQ_ADDR_SOME(0.00)[]; MISSING_XM_UA(0.00)[];
 TAGGED_RCPT(0.00)[]; MIME_TRACE(0.00)[0:+];
 FREEMAIL_TO(0.00)[gmail.com];
 FREEMAIL_ENVRCPT(0.00)[gmail.com];
 DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
 FROM_EQ_ENVFROM(0.00)[]; FROM_HAS_DN(0.00)[];
 RCPT_COUNT_THREE(0.00)[3]; RCVD_TLS_ALL(0.00)[];
 TO_MATCH_ENVRCPT_ALL(0.00)[]; RCVD_COUNT_TWO(0.00)[2];
 FUZZY_BLOCKED(0.00)[rspamd.com];
 DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,suse.de:email]
Subject: Re: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

T24gTW9uLCAyMCBKYW4gMjAyNSwgQWxleGV5IEx5YWhrb3Ygd3JvdGU6Cj4gCj4gPiBPbiAxOSBK
YW4gMjAyNSwgYXQgMTE6MDMsIE5laWxCcm93biA8bmVpbGJAc3VzZS5kZT4gd3JvdGU6Cj4gPiAK
PiA+IE9uIFN1biwgMTkgSmFuIDIwMjUsIEFsZXhleSBMeWFoa292IHdyb3RlOgo+ID4+IE5laWws
Cj4gPj4+IAo+ID4+PiAKPiA+Pj4+IAo+ID4+Pj4gSXQgZG9lcyBub3QgaGVwIHRoYXQgdGhlcmUg
YXJlIHdoYXQgMz8gND8gdHJlZXMsIG5vdCAiZHVhbC10cmVlIiBieSBhbnkKPiA+Pj4+IHN0cmV0
Y2ggb2YgaW1hZ2luYXRpb24uCj4gPj4+PiAKPiA+Pj4+IFRoZXJlJ3MgREROL3doYW1jbG91ZCAo
dGhhdCdzIHJlYWxseSB0d28gdHJlZXMpLCB0aGVyZSdzIEhQRSwgTExOTAo+ID4+Pj4ga2VlcHMg
dGhlaXIgZm9yayBzdGlsbCBJIHRoaW5rICh0aG91Z2h0IGl0J3MgbW9zdGx5IGJhY2twb3J0cz8p
LiBUaGVyZQo+ID4+Pj4gYXJlIGxpa2VseSBvdGhlcnMgSSBhbSBsZXNzIGV4cG9zZWQgdG8uCj4g
Pj4+IAo+ID4+PiAiZHVhbC10cmVlIiBtYXliZSBpc24ndCB0aGUgYmVzdCB3YXkgb2YgZGVzY3Jp
YmluZyB3aGF0IHdhcyB3cm9uZyB3aXRoCj4gPj4+IHRoZSBwcmV2aW91cyBhcHByb2FjaC4gICJ1
cHN0cmVhbS1maXJzdCIgaXMgb25lIHdheSBvZiBkZXNjcmliaW5nIGhvdyBpdAo+ID4+PiBzaG91
bGQgYmUgcnVuLCB0aG91Z2ggdGhhdCBuZWVkcyB0byBiZSBpbiB1bmRlcnN0b29kIGNvcnJlY3Rs
eS4KPiA+Pj4gCj4gPj4+IFBhdGNoZXMgc2hvdWxkIGFsd2F5cyBmbG93IHVwc3RyZWFtIGZpcnN0
LCB0aGVuIGZsb3cgZG93bnN0cmVhbSBpbnRvCj4gPj4+IGRpc3Ryby4gIFNvIEkgd3JpdGUgYSBw
YXRjaCBpbiBteSBvd24gZGV2ZWwgdHJlZS4gIEkgcG9zdCBpdCBvciBzdWJtaXQgYQo+ID4+PiBw
dWxsIHJlcXVlc3QgYW5kIGV2ZW50dWFsbHkgaXQgaXMgYWNjZXB0ZWQgaW50byB0aGUgbWFpbnRh
aW5lcnMKPiA+Pj4gInRlc3RpbmciIHRyZWUgKHVwc3JlYW0gZnJvbSBtZSkuICBUaGVyZSBpdCBn
ZXRzIG1vcmUgdGVzdGluZyBhbmQgbW92ZXMKPiA+Pj4gdG8gdGhlIG1haW50YWluZXJzICJuZXh0
IiB0cmVlIGZyb20gd2hpY2ggaXQgaXMgcHVsbGVkIGludG8gbGludXgtbmV4dAo+ID4+PiBmb3Ig
aW50ZWdyYXRpb24gdGVzdGluZy4gIFRoZW4gaXQgZ29lcyB1cHN0cmVhbSB0byBMaW51cyAocG9z
c2libHkKPiA+Pj4gdGhyb3VnaCBhbiBpbnRlcm1lZGlhcnkpLiAgRnJvbSBMaW51cyBpdCBnb2Vz
IHRvIC1zdGFibGUgYW5kIHRvIHZhcmlvdXMKPiA+Pj4gZGlzdHJvcyBldGMuICBJbmRpdmlkdWFs
IHBhdGNoZXMgYXJlIHNlbGVjdGVkIGZvciBmdXJ0aGVyIGJhY2twb3J0aW5nIHRvCj4gPj4+IGFs
bCBzb3J0cyBvZiBkaWZmZXJlbnQgTFRTIHRyZWUuCj4gPj4+IAo+ID4+PiBPY2Nhc2lvbmFsbHkg
dGhlcmUgYXJlIHNob3J0LWN1dHMuICBJIG1pZ2h0IHN1Ym1pdCBhIHBhdGNoIGZyb20gbXkgdHJl
ZQo+ID4+PiB0byBhIFNVU0Uga2VybmVsIGJlZm9yZSBpdCBpcyBhY2NlcHRlZCB1cHN0cmVhbSwg
b3IgbWF5YmUgZXZlbiBiZWZvcmUgaXQKPiA+Pj4gaXMgc2VudCBpZiBpdCBpcyB1cmdlbnQuICBC
dXQgdGhlc2UgYXJlIG5vdCB0aGUgbm9ybS4KPiA+Pj4gCj4gPj4+IEJ1dCB5b3Uga25vdyBhbGwg
dGhpcyBJIGV4cGVjdC4gIEl0IGlzbid0IGFib3V0IHRoZSB0b3RhbCBudW1iZXIgb2YKPiA+Pj4g
dHJlZXMuIEl0IGlzIGFib3V0IHRoZSBmbG93IG9mIHBhdGNoZXMgd2hpY2ggbXVzdCBhbGwgZmxv
dyB0aHJvdWdoIExpbnVzLgo+ID4+PiBBbmQgZGV2ZWxvcGVycyBtdXN0IGRldmVsb3AgYWdhaW5z
dCBjdXJyZW50IGxpbnVzLCBvciBzb21ldGhpbmcgdmVyeQo+ID4+PiBjbG9zZSB0byB0aGF0LiAg
RGV2ZWxvcGluZyBhZ2FpbnN0IGFuIG9sZGVyIGtlcm5lbCBpcyBzaW1wbHkgbWFraW5nIG1vcmUK
PiA+Pj4gd29yayBmb3IgeW91cnNlbGYuCj4gPj4gCj4gPj4gVGhpcyB3aWxsIGRvbuKAmXQgd29y
ay4gTGV0IGV4cGxhaW4gc2l0dWF0aW9uIGluIHBhc3QuCj4gPiAKPiA+IE5vLiAgSSdtIG5vdCBh
dCBhbGwgaW50ZXJlc3RlZCBpbiBleHBsYW5hdGlvbnMgb2Ygd2h5IGl0IHdvbid0IHdvcmsuCj4g
PiAKPiA+IEknbSBvbmx5IGludGVyZXN0ZWQgaW4gc3VnZ2VzdGlvbnMgb2YgaG93IHRvIG1ha2Ug
aXQgd29yaywgYW5kIG9mZmVycyBvZgo+ID4gaGVscC4KPiA+IAo+IElmIHlvdSBoYXZlIGEgZ29v
ZCB3YXkgaG93IHRvIHNvbHZlIHN1Y2ggc2l0dWF0aW9uLCB3aGljaCBoYWQgY3JhenkgYnJhaW4g
aW4gcGFzdC4KPiBQbGVhc2Ugc2hhcmUgYSB3YXkgaG93IHRvIGF2b2lkIGx1c3RyZSBzb3VyY2Ug
Y29kZSBmcmFnbWVudGF0aW9uIGJlY2F1c2Ugb2YgZnJlZXplIGEgY29kZSBhdCB0aGUgZGlmZmVy
ZW50IHN0YWdlIGluIGRpZmZlcmVudCBkaXN0cmlidXRpb25zLgo+IFVidW50dSBtaWdodCBoYXZl
IGEgbW9kZXJuIGx1c3RyZSB3aXRoIDYuNSBrZXJuZWwsIGJ1dCBSZWRoYXQgaGFkIGZyb3plbiBh
IGx1c3RyZSB2ZXJzaW9uIGluIDMgcmVsZWFzZXMgaW4gcGFzdCBhbmQgdGhlc2UgY2xpZW50cyBu
b3QgY29tcGF0aWJsZSBlYWNoIG90aGVyLgo+IEFuZCBub3QgY29tcGF0aWJsZSB3aXRoIGluc3Rh
bGxlZCBzZXJ2ZXIuCj4gU28gcXVlc3Rpb24gLSB3aG8gd2lsbCBkbyBzdWNoIHN1cHBvcnQgPyBE
aWQgeW91IGhhdmUgYW4gaWRlYXMgaG93IHRvIHNvbHZlIHRoaXMgcHJvYmxlbT8KPiAKCnNvcnJ5
IC0gSSBkaWRuJ3QgbWVhbiB0byBnbyBxdWl0ZSBvbiB5b3UgLSBJJ3ZlIGJlZW4gYnVzeSA6LSkK
Ckl0J3Mgbm90IGVudGlyZWx5IGNsZWFyIHRvIG1lIHdoYXQgdGhlIHByb2JsZW0gaXMuCllvdSB0
YWxrIGFib3V0IGNsaWVudHMgbm90IGJlaW5nIGNvbXBhdGlibGUgd2l0aCBlYWNoIG90aGVyIG9y
IHdpdGggdGhlCnNlcnZlciwgYnV0IEFuZHJlYXMgaGFzIHNhaWQgdGhhdCB0aGVyZSBpcyBnb29k
IGNvbXBhdGliaWxpdHkgYmV0d2VlbgpkaWZmZXJlbnQgdmVyc2lvbnMgc28gSSB3b25kZXIgaWYg
dGhhdCBpcyByZWFsbHkgKHN0aWxsKSBhbiBpc3N1ZS4KCktlZXBpbmcgZGlmZmVyZW50IGtlcm5l
bHMgdXAgdG8gZGF0ZSB3aXRoIG5ldyB1cGRhdGVzIGlzIHNvbWV0aGluZyB0aGF0CnRoZSBsaW51
eC1zdGFibGUgdGVhbSBkb2VzIGFsbCB0aGUgdGltZS4gIFdlIGRvIGl0IGF0IFNVU0UgdG8uICBJ
dCBpc24ndAp0aGF0IGhhcmQuCllvdSBpZGVudGlmeSB3aGljaCBwYXRjaGVzICpuZWVkKiB0byBi
ZSBiYWNrcG9ydGVkIChpZGVhbGx5IHdoZW4gdGhlCnBhdGNoIGlzIGNyZWF0ZWQgYnV0IHRoYXQg
aXNuJ3QgYWx3YXlzIGVhc3kpIGFuZCB5b3UgdXNlIHRvb2xzIHRvIGhlbHAKeW91IGJhY2twb3J0
IHRoZW0uCgpDZXJ0YWlubHkgdGhlcmUgaXMgZWZmb3J0IGludm9sdmVkLCBidXQgbWFpbnRhaW5p
bmcgYSBwYWNrYWdlIHRoYXQgd29ya3MKb24gYSBsYXJnZSBzZXQgb2Yga2VybmVscyBhbHNvIGlu
dm9sdmVzIGVmZm9ydC4gIEl0IGlzbid0IGNsZWFyIHRvIG1lCnRoYXQgaXQgaXMgKm1vcmUqIGVm
Zm9ydCwganVzdCAqZGlmZmVyZW50KiBlZmZvcnQuCgpOZWlsQnJvd24KX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KbHVzdHJlLWRldmVsIG1haWxpbmcgbGlz
dApsdXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZwpodHRwOi8vbGlzdHMubHVzdHJlLm9yZy9s
aXN0aW5mby5jZ2kvbHVzdHJlLWRldmVsLWx1c3RyZS5vcmcK
