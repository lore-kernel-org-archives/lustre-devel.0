Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C3797C02183
	for <lustre-devel@archiver.kernel.org>; Sun, 19 Jan 2025 08:04:23 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YbQwS37rXz1y1m;
	Sun, 19 Jan 2025 00:04:08 -0800 (PST)
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YbQwF0vc3z1wbw
 for <lustre-devel@lists.lustre.org>; Sun, 19 Jan 2025 00:03:57 -0800 (PST)
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org
 [IPv6:2a07:de40:b281:104:10:150:64:97])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by smtp-out1.suse.de (Postfix) with ESMTPS id 1875B21193;
 Sun, 19 Jan 2025 08:03:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1737273835; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=GpBsuQtL68sWCBab9SiXTKvwjgMDxlf1adDLcLPE/4E=;
 b=RJqSPN5bDQQ+wIEnG94h2alM2c0NT5eaY/FmedrRW1xxjRYIGmkGAgCUDJ3I+AKNBY7PHT
 CUUEjtnaHKb0OFjkyWbLldv7/hRUep+04CqKN3esKwOLCbma3U1jzaxD1+ITA9kf6MVXw/
 MCIismUwepJ64gPKKRq00W8RWjsesgc=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1737273835;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=GpBsuQtL68sWCBab9SiXTKvwjgMDxlf1adDLcLPE/4E=;
 b=3W1htcAwpYh8gXfU5r3hVTbyQ63uBaK4m+rNAcMYiK074mWrIT6xQerALF7pzyRrJFRuH/
 rnCz3vKYAwo3tyCg==
Authentication-Results: smtp-out1.suse.de;
 dkim=pass header.d=suse.de header.s=susede2_rsa header.b=RJqSPN5b;
 dkim=pass header.d=suse.de header.s=susede2_ed25519 header.b=3W1htcAw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1737273835; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=GpBsuQtL68sWCBab9SiXTKvwjgMDxlf1adDLcLPE/4E=;
 b=RJqSPN5bDQQ+wIEnG94h2alM2c0NT5eaY/FmedrRW1xxjRYIGmkGAgCUDJ3I+AKNBY7PHT
 CUUEjtnaHKb0OFjkyWbLldv7/hRUep+04CqKN3esKwOLCbma3U1jzaxD1+ITA9kf6MVXw/
 MCIismUwepJ64gPKKRq00W8RWjsesgc=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1737273835;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=GpBsuQtL68sWCBab9SiXTKvwjgMDxlf1adDLcLPE/4E=;
 b=3W1htcAwpYh8gXfU5r3hVTbyQ63uBaK4m+rNAcMYiK074mWrIT6xQerALF7pzyRrJFRuH/
 rnCz3vKYAwo3tyCg==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id D0EFE13834;
 Sun, 19 Jan 2025 08:03:53 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
 by imap1.dmz-prg2.suse.org with ESMTPSA id fOK0IOmxjGeiMAAAD6G6ig
 (envelope-from <neilb@suse.de>); Sun, 19 Jan 2025 08:03:53 +0000
MIME-Version: 1.0
From: "NeilBrown" <neilb@suse.de>
To: "Alexey Lyahkov" <alexey.lyashkov@gmail.com>
In-reply-to: <44B65570-32C4-465A-9F18-ACF95A5B57EE@gmail.com>
References: <>, <44B65570-32C4-465A-9F18-ACF95A5B57EE@gmail.com>
Date: Sun, 19 Jan 2025 19:03:45 +1100
Message-id: <173727382569.22054.1599040461487640062@noble.neil.brown.name>
X-Rspamd-Queue-Id: 1875B21193
X-Rspamd-Action: no action
X-Spamd-Result: default: False [-4.51 / 50.00]; BAYES_HAM(-3.00)[100.00%];
 NEURAL_HAM_LONG(-1.00)[-1.000];
 R_DKIM_ALLOW(-0.20)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
 NEURAL_HAM_SHORT(-0.20)[-1.000]; MIME_GOOD(-0.10)[text/plain];
 MX_GOOD(-0.01)[];
 DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
 FUZZY_BLOCKED(0.00)[rspamd.com]; FREEMAIL_TO(0.00)[gmail.com];
 ARC_NA(0.00)[]; TO_MATCH_ENVRCPT_ALL(0.00)[];
 MIME_TRACE(0.00)[0:+]; TO_DN_EQ_ADDR_SOME(0.00)[];
 FREEMAIL_ENVRCPT(0.00)[gmail.com]; DKIM_TRACE(0.00)[suse.de:+];
 TO_DN_SOME(0.00)[]; RCVD_COUNT_TWO(0.00)[2];
 FROM_EQ_ENVFROM(0.00)[]; FROM_HAS_DN(0.00)[];
 RCVD_TLS_ALL(0.00)[]; TAGGED_RCPT(0.00)[];
 ASN(0.00)[asn:25478, ipnet:::/0, country:RU];
 RCVD_VIA_SMTP_AUTH(0.00)[]; RCPT_COUNT_THREE(0.00)[3];
 MISSING_XM_UA(0.00)[];
 DBL_BLOCKED_OPENRESOLVER(0.00)[suse.de:dkim]
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
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

T24gU3VuLCAxOSBKYW4gMjAyNSwgQWxleGV5IEx5YWhrb3Ygd3JvdGU6Cj4gTmVpbCwgCj4gPiAK
PiA+IAo+ID4+IAo+ID4+IEl0IGRvZXMgbm90IGhlcCB0aGF0IHRoZXJlIGFyZSB3aGF0IDM/IDQ/
IHRyZWVzLCBub3QgImR1YWwtdHJlZSIgYnkgYW55Cj4gPj4gc3RyZXRjaCBvZiBpbWFnaW5hdGlv
bi4KPiA+PiAKPiA+PiBUaGVyZSdzIERETi93aGFtY2xvdWQgKHRoYXQncyByZWFsbHkgdHdvIHRy
ZWVzKSwgdGhlcmUncyBIUEUsIExMTkwKPiA+PiBrZWVwcyB0aGVpciBmb3JrIHN0aWxsIEkgdGhp
bmsgKHRob3VnaHQgaXQncyBtb3N0bHkgYmFja3BvcnRzPykuIFRoZXJlCj4gPj4gYXJlIGxpa2Vs
eSBvdGhlcnMgSSBhbSBsZXNzIGV4cG9zZWQgdG8uCj4gPiAKPiA+ICJkdWFsLXRyZWUiIG1heWJl
IGlzbid0IHRoZSBiZXN0IHdheSBvZiBkZXNjcmliaW5nIHdoYXQgd2FzIHdyb25nIHdpdGgKPiA+
IHRoZSBwcmV2aW91cyBhcHByb2FjaC4gICJ1cHN0cmVhbS1maXJzdCIgaXMgb25lIHdheSBvZiBk
ZXNjcmliaW5nIGhvdyBpdAo+ID4gc2hvdWxkIGJlIHJ1biwgdGhvdWdoIHRoYXQgbmVlZHMgdG8g
YmUgaW4gdW5kZXJzdG9vZCBjb3JyZWN0bHkuCj4gPiAKPiA+IFBhdGNoZXMgc2hvdWxkIGFsd2F5
cyBmbG93IHVwc3RyZWFtIGZpcnN0LCB0aGVuIGZsb3cgZG93bnN0cmVhbSBpbnRvCj4gPiBkaXN0
cm8uICBTbyBJIHdyaXRlIGEgcGF0Y2ggaW4gbXkgb3duIGRldmVsIHRyZWUuICBJIHBvc3QgaXQg
b3Igc3VibWl0IGEKPiA+IHB1bGwgcmVxdWVzdCBhbmQgZXZlbnR1YWxseSBpdCBpcyBhY2NlcHRl
ZCBpbnRvIHRoZSBtYWludGFpbmVycwo+ID4gInRlc3RpbmciIHRyZWUgKHVwc3JlYW0gZnJvbSBt
ZSkuICBUaGVyZSBpdCBnZXRzIG1vcmUgdGVzdGluZyBhbmQgbW92ZXMKPiA+IHRvIHRoZSBtYWlu
dGFpbmVycyAibmV4dCIgdHJlZSBmcm9tIHdoaWNoIGl0IGlzIHB1bGxlZCBpbnRvIGxpbnV4LW5l
eHQKPiA+IGZvciBpbnRlZ3JhdGlvbiB0ZXN0aW5nLiAgVGhlbiBpdCBnb2VzIHVwc3RyZWFtIHRv
IExpbnVzIChwb3NzaWJseQo+ID4gdGhyb3VnaCBhbiBpbnRlcm1lZGlhcnkpLiAgRnJvbSBMaW51
cyBpdCBnb2VzIHRvIC1zdGFibGUgYW5kIHRvIHZhcmlvdXMKPiA+IGRpc3Ryb3MgZXRjLiAgSW5k
aXZpZHVhbCBwYXRjaGVzIGFyZSBzZWxlY3RlZCBmb3IgZnVydGhlciBiYWNrcG9ydGluZyB0bwo+
ID4gYWxsIHNvcnRzIG9mIGRpZmZlcmVudCBMVFMgdHJlZS4KPiA+IAo+ID4gT2NjYXNpb25hbGx5
IHRoZXJlIGFyZSBzaG9ydC1jdXRzLiAgSSBtaWdodCBzdWJtaXQgYSBwYXRjaCBmcm9tIG15IHRy
ZWUKPiA+IHRvIGEgU1VTRSBrZXJuZWwgYmVmb3JlIGl0IGlzIGFjY2VwdGVkIHVwc3RyZWFtLCBv
ciBtYXliZSBldmVuIGJlZm9yZSBpdAo+ID4gaXMgc2VudCBpZiBpdCBpcyB1cmdlbnQuICBCdXQg
dGhlc2UgYXJlIG5vdCB0aGUgbm9ybS4KPiA+IAo+ID4gQnV0IHlvdSBrbm93IGFsbCB0aGlzIEkg
ZXhwZWN0LiAgSXQgaXNuJ3QgYWJvdXQgdGhlIHRvdGFsIG51bWJlciBvZgo+ID4gdHJlZXMuIEl0
IGlzIGFib3V0IHRoZSBmbG93IG9mIHBhdGNoZXMgd2hpY2ggbXVzdCBhbGwgZmxvdyB0aHJvdWdo
IExpbnVzLgo+ID4gQW5kIGRldmVsb3BlcnMgbXVzdCBkZXZlbG9wIGFnYWluc3QgY3VycmVudCBs
aW51cywgb3Igc29tZXRoaW5nIHZlcnkKPiA+IGNsb3NlIHRvIHRoYXQuICBEZXZlbG9waW5nIGFn
YWluc3QgYW4gb2xkZXIga2VybmVsIGlzIHNpbXBseSBtYWtpbmcgbW9yZQo+ID4gd29yayBmb3Ig
eW91cnNlbGYuCj4gCj4gVGhpcyB3aWxsIGRvbuKAmXQgd29yay4gTGV0IGV4cGxhaW4gc2l0dWF0
aW9uIGluIHBhc3QuCgpOby4gIEknbSBub3QgYXQgYWxsIGludGVyZXN0ZWQgaW4gZXhwbGFuYXRp
b25zIG9mIHdoeSBpdCB3b24ndCB3b3JrLgoKSSdtIG9ubHkgaW50ZXJlc3RlZCBpbiBzdWdnZXN0
aW9ucyBvZiBob3cgdG8gbWFrZSBpdCB3b3JrLCBhbmQgb2ZmZXJzIG9mCmhlbHAuCgpBbmQgeWVz
IC0gZGVzY3JpYmluZyBpbXBvcnRhbnQgdXNlLWNhc2VzIHdoaWNoIG5lZWQgdG8gd29yayBhbmQg
bWlnaHQgYmUKZGlmZmljdWx0IHdvdWxkIGJlIGEgaGVscGZ1bCB0aGluZyB0byBkby4KCk5laWxC
cm93bgoKCj4gSW4gcHJldmlvdXMgaXRlcmF0aW9uIC0gVWJ1bnR1IGhhZCBhbiBidWlsZCBhIGtl
cm5lbHMgd2l0aCBsdXN0cmUgc3VwcG9ydCBlbmFibGVkLgo+IEJ1dCBVYnVudHUgZG9u4oCZdCBo
YXZlIGEgcmVzb3VyY2VzIHRvIGZpeCBvd24ga2VybmVsIHdpdGggbHVzdHJlIGJhY2sgcG9ydHMu
Cj4gdGhlc2UgY2xpZW50cyBoYXZlIGluc3RhbGxlZCBhbmQgc29tZSBjbGllbnRzIGV4cGVjdCB0
byBiZSB3b3JrIGZpbmUuCj4gQnV0IHRoaXMgaXMgZmFsc2UsIGFuZCBidWlsZGluZyBhbiBuZXcg
bHVzdHJlIG1vZHVsZSBoYXZlIGEgY29uZmxpY3QgaW4gbmFtZXMgYmV0d2VlbiBrZXJuZWwgYW5k
IG91dC1vZiB0cmVlIGx1c3RyZS4KPiBGcm9tIG90aGVyIHNpZGUgLSBpdCBtYWtlIGEgTHVzdHJl
IHBsYXRmb3JtIGZyYWdtZW50YXRpb24uIE9uY2UgTHVzdHJlIHZlcnNpb24gaW4gdGhlIFVidW50
dSBjb2RlIGhhdmUgYSBzdGFsZSBhbmQgb3V0IGdlbmVyaWMgbHVzdHJlIHJ1bGUuCj4gQ29tcGF0
aWJpbGl0eSBzdXBwb3J0ZWQganVzdCBmb3Igb25lIHZlcnNpb24gdXAgYW5kIGRvd24uIEl0IGNh
dXNlZCBhIHNvIG11Y2ggcHJvYmxlbXMgZm9yIHN1cHBvcnQgdGVhbS4KPiAKPiBBbmQgVWJ1bnR1
IGp1c3Qgb25lIGRpc3Ryby4gUmVkSGF0LCBTdVNlLCBMVFMga2VybmVsc+KApiBhbGwgb2YgdGhl
bSB1c2VkIGluIEhQQyAtIGFsbCBvZiB0aGVuIGhhdmUgYW4gb3duIHJlbGVhc2UgY3ljbGUgYW5k
IHNvIG11Y2ggdmVyc2lvbnMgaGFkIGhvbGQgYSBzb21lIGx1c3RyZSB2ZXJzaW9uIHRvIHVzZS4K
PiAKPiAKPiBBbGV4CgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fXwpsdXN0cmUtZGV2ZWwgbWFpbGluZyBsaXN0Cmx1c3RyZS1kZXZlbEBsaXN0cy5sdXN0cmUu
b3JnCmh0dHA6Ly9saXN0cy5sdXN0cmUub3JnL2xpc3RpbmZvLmNnaS9sdXN0cmUtZGV2ZWwtbHVz
dHJlLm9yZwo=
