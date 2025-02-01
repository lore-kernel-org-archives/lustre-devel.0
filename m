Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9AE7CC0218A
	for <lustre-devel@archiver.kernel.org>; Sat,  1 Feb 2025 22:59:06 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Ylp8y2yFcz1xPQ;
	Sat, 01 Feb 2025 14:58:58 -0800 (PST)
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Ylp8g22lYz1xP5
 for <lustre-devel@lists.lustre.org>; Sat, 01 Feb 2025 14:58:43 -0800 (PST)
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org
 [IPv6:2a07:de40:b281:104:10:150:64:97])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by smtp-out2.suse.de (Postfix) with ESMTPS id 23B061F443;
 Sat,  1 Feb 2025 22:58:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1738450721; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=ny3VTxffztROjjb4jkd0LKZ+/lzjpPDuT3UEcIYRucU=;
 b=YPprgdi0bGoaTdBq7RbNa2swozANWQ8BZW90aM01cGEVLSeYDkbXtW6wj9QHqPwRKSSafY
 OchI0QkiIzvcOZ5RMbFgwoLhlPAa6VfPslKGoiu544p2/hq8bwB8A5/dMsNgRHNpua5dwJ
 /1T3o3aw2aTuSe9RZbZLBtzE5t2h57g=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1738450721;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=ny3VTxffztROjjb4jkd0LKZ+/lzjpPDuT3UEcIYRucU=;
 b=6S15v+PXO797S6kWTAK/GUxp2auQKuTwPF8zG1Bln55qfAA43zAtTvbl1O9VZw8rOVlcf4
 7534VFix0fMrq2BQ==
Authentication-Results: smtp-out2.suse.de;
 dkim=pass header.d=suse.de header.s=susede2_rsa header.b=YPprgdi0;
 dkim=pass header.d=suse.de header.s=susede2_ed25519 header.b=6S15v+PX
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1738450721; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=ny3VTxffztROjjb4jkd0LKZ+/lzjpPDuT3UEcIYRucU=;
 b=YPprgdi0bGoaTdBq7RbNa2swozANWQ8BZW90aM01cGEVLSeYDkbXtW6wj9QHqPwRKSSafY
 OchI0QkiIzvcOZ5RMbFgwoLhlPAa6VfPslKGoiu544p2/hq8bwB8A5/dMsNgRHNpua5dwJ
 /1T3o3aw2aTuSe9RZbZLBtzE5t2h57g=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1738450721;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=ny3VTxffztROjjb4jkd0LKZ+/lzjpPDuT3UEcIYRucU=;
 b=6S15v+PXO797S6kWTAK/GUxp2auQKuTwPF8zG1Bln55qfAA43zAtTvbl1O9VZw8rOVlcf4
 7534VFix0fMrq2BQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id D8686136AD;
 Sat,  1 Feb 2025 22:58:39 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
 by imap1.dmz-prg2.suse.org with ESMTPSA id 0thsIh+nnmfXXQAAD6G6ig
 (envelope-from <neilb@suse.de>); Sat, 01 Feb 2025 22:58:39 +0000
MIME-Version: 1.0
From: "NeilBrown" <neilb@suse.de>
To: "Alexey Lyahkov" <alexey.lyashkov@gmail.com>
In-reply-to: <660D26F8-92F1-45AD-803A-5AD47988640E@gmail.com>
References: <>, <660D26F8-92F1-45AD-803A-5AD47988640E@gmail.com>
Date: Sun, 02 Feb 2025 09:58:36 +1100
Message-id: <173845071649.22054.5753395310812419468@noble.neil.brown.name>
X-Rspamd-Queue-Id: 23B061F443
X-Spamd-Result: default: False [-4.51 / 50.00]; BAYES_HAM(-3.00)[100.00%];
 NEURAL_HAM_LONG(-1.00)[-1.000];
 R_DKIM_ALLOW(-0.20)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
 NEURAL_HAM_SHORT(-0.20)[-1.000]; MIME_GOOD(-0.10)[text/plain];
 MX_GOOD(-0.01)[];
 DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
 FUZZY_BLOCKED(0.00)[rspamd.com]; FREEMAIL_TO(0.00)[gmail.com];
 RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from]; 
 SPAMHAUS_XBL(0.00)[2a07:de40:b281:104:10:150:64:97:from];
 TO_MATCH_ENVRCPT_ALL(0.00)[]; TO_DN_EQ_ADDR_SOME(0.00)[];
 ARC_NA(0.00)[]; FREEMAIL_ENVRCPT(0.00)[gmail.com];
 DKIM_TRACE(0.00)[suse.de:+]; MIME_TRACE(0.00)[0:+];
 RCVD_COUNT_TWO(0.00)[2];
 RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
 FROM_EQ_ENVFROM(0.00)[]; FROM_HAS_DN(0.00)[];
 RCVD_TLS_ALL(0.00)[]; TAGGED_RCPT(0.00)[];
 ASN(0.00)[asn:25478, ipnet:::/0, country:RU];
 RCVD_VIA_SMTP_AUTH(0.00)[]; RCPT_COUNT_THREE(0.00)[3];
 MISSING_XM_UA(0.00)[]; TO_DN_SOME(0.00)[]
X-Rspamd-Server: rspamd2.dmz-prg2.suse.org
X-Rspamd-Action: no action
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

T24gVGh1LCAzMCBKYW4gMjAyNSwgQWxleGV5IEx5YWhrb3Ygd3JvdGU6Cj4gCj4gCj4gPiBPbiAy
OSBKYW4gMjAyNSwgYXQgMjI6MDAsIERheSwgVGltb3RoeSA8dGltZGF5QGFtYXpvbi5jb20+IHdy
b3RlOgo+ID4gCj4gPj4+Pj4gVGhhdCdzIHdoeSB3ZSdsbAo+ID4+Pj4+IHN0aWxsIHN1cHBvcnQg
cnVubmluZyBsYXRlc3QgTHVzdHJlIG9uIG9sZGVyIGRpc3Ryb3MuIFNwZWNpZmljYWxseSwgaXQn
bGwgYmUgdGhlIEx1c3RyZQo+ID4+Pj4+IGNvZGUgZnJvbSBhIG1haW5saW5lIGtlcm5lbCBjb21i
aW5lZCB3aXRoIG91ciBsdXN0cmVfY29tcGF0LyBjb21wYXRpYmlsaXR5Cj4gPj4+Pj4gY29kZS4g
U28gbm9ybWFsIEx1c3RyZSByZWxlYXNlcyB3aWxsIGJlIGRlcml2ZWQgZGlyZWN0bHkgZnJvbSB0
aGUgaW4tdHJlZSBrZXJuZWwKPiA+Pj4+PiBjb2RlLiBUaGlzIHByb3ZpZGVzIGEgcGF0aCBmb3Ig
dmVuZG9ycyB0byBkZXBsb3kgYnVnIGZpeGVzLCBjdXN0b20gZmVhdHVyZXMsIGFuZAo+ID4+Pj4+
IGFsbG93cyB1c2VycyB0byBvcHRpb25hbGx5IHJ1biB0aGUgbGF0ZXN0IGFuZCBncmVhdGVzdCBM
dXN0cmUgY29kZS4KPiA+Pj4+IAo+ID4+Pj4gQW5kIE9PUFMuIEJvdGggY29kZXMgKGluLWtlcm5l
bCBhbmQgb3V0LW9mLXRyZWUpIGhhdmUgYSBzYW1lIHNvcnQgb2YgZGVmaW5lcyBpbiBjb25maWcu
aCB3aGljaCBoYXZlIGNvbmZsaWN0cyB3aXRoIGJ1aWxkaW5nIGZvciBvdXQtb2YtZnJlZSBMdXN0
cmUuCj4gPj4+PiBTb21lIGV4YW1wbGVzIGZvciBNT0ZFRCBoYWNrcyB0byBzb2x2ZSBzYW1lIHBy
b2JsZW0geW91IGNhbiBzZWUgaW4gdGhlIG8yaWJsbmQ6Cj4gPj4+Pj4+PiAKPiA+Pj4+ICNpZiBk
ZWZpbmVkKEVYVEVSTkFMX09GRURfQlVJTEQpICYmICFkZWZpbmVkKEhBVkVfT0ZFRF9JQl9ETUFf
TUFQX1NHX1NBTkUpCj4gPj4+PiAjdW5kZWYgQ09ORklHX0lORklOSUJBTkRfVklSVF9ETUEKPiA+
Pj4+ICNlbmRpZgo+ID4+Pj4+Pj4gCj4gPj4+PiBBcyBJIHJlbWVtYmVyIHRoaXMgcHJvYmxlbSBi
cm9rZSBhbiBhYmlsaXR5IHRvIGJ1aWxkIGEgbHVzdHJlIGFzIG91dC1vZi10cmVlIGtlcm5lbCBv
biB0aGUgdWJ1bnR1IDE4LjA2IHdpdGggbHVzdHJlIGluIHN0YWdpbmcvLgo+ID4+PiAKPiA+Pj4g
SSB0aGluayB3ZSBzaG91bGQgYmUgYWJsZSB0byB2YWxpZGF0ZSB0aGUgTHVzdHJlIHN0aWxsIGJ1
aWxkcyBhcyBhbgo+ID4+PiBvdXQtb2YtdHJlZSBtb2R1bGUgYnkgcmUtdXNpbmcgYSBsb3Qgb2Yg
dGhlIHRlc3Rpbmcgd2UgYWxyZWFkeQo+ID4+PiBkbyB0b2RheSBpbiBKZW5raW5zL01hbG9vLgo+
ID4+IAo+ID4+IFllcy4gTWUgZG8uIEJ1dCBpdCBuZWVkcyBtYW55IGV4dHJhIHJlc291cmNlcy4g
RGlkIEFtYXpvbiByZWFkeSB0byBwcm92aWRlIHN1Y2ggSFcgcmVzb3VyY2VzIGZvciBpdD8KPiA+
PiBPciB3aG8gd2lsbCBiZSBwYXkgZm9yIGl0PyBJdOKAmXMgY29zdCBvZiB0aGUgbW92aW5nIHRv
IHRoZSBrZXJuZWwuCj4gPiAKPiA+IEkgc3VwcG9zZSBJIGRpc2FncmVlIHRoYXQgdGhpcyB0ZXN0
aW5nIHJlcXVpcmVzIG1hbnkgZXh0cmEKPiA+IHJlc291cmNlcy4gVGhpcyBpcyBqdXN0IHZhbGlk
YXRlIHRoZSBzYW1lIHRoaW5ncyB3ZSB2YWxpZGF0ZQo+ID4gdG9kYXkgKGkuZS4gdGhhdCBMdXN0
cmUgaXMgZnVuY3Rpb25hbCBvbiBSSEVMIGtlcm5lbHMpLiBCdXQgdGhlCj4gPiBidWlsZCBwcm9j
ZXNzIGxvb2tzIGRpZmZlcmVudC4KPiA+IAo+IEFoLiBTbyB5b3UgZG9u4oCZdCBleHBlY3QgdG8g
ZG8gYW55IHBlcmZvcm1hbmNlIHRlc3Rpbmc/Cj4gUGVyZm9ybWFuY2UgdGVzdGluZyBuZWVkcyBh
IDIwIG5vZGVzIGNsdXN0ZXIgd2l0aCBJQiBIRFIgbmV0d29yayAoNDAwRykgYW5kIEUxMDAwIHdp
dGggTlZNZSBkcml2ZXMgYXMgbWluaW1hbC4gCj4gT3RoZXJ3aXNlIHNlcnZlcnMgLyBuZXR3b3Jr
IHdpbGwgYmUgYm90dGxlbmVjay4KPiBBbmQgd2VlayBvciBzbyBmb3IgbG9hZCB0byBiZSBzdXJl
IG5vIHJlZ3Jlc3Npb24gZXhpc3QuIFNvbWUgcHJvYmxlbXMgY2FuIGZvdW5kIGp1c3Qgd2l0aCA0
OGggY29udGludWFzIGxvYWQuCj4gQW5kIHRoYXQgaXMgbWluaW1hbCBwZXJmb3JtYW5jZSB0ZXN0
aW5nLgo+IEkgZG9u4oCZdCBzYXkgYWJvdXQgc2NhbGUgdGVzdGluZyB3aXRoIDEwMCsgY2xpZW50
IG5vZGVzLgo+IFlvdSB0aGluayB3ZSBuZWVkcyB0byBkcm9wIGl0PyBJZiBubyAtIHdobyB3aWxs
IHByb3ZpZGUgSFcgZm9yIHN1Y2ggdGVzdGluZy4KCldlIGF0IFNVU0UgaGF2ZSBwZXJmb3JtYW5j
ZSB0ZWFtLiAgV2UgZG8gc29tZSB0ZXN0aW5nIG9uIHVwc3RyZWFtCmJlY2F1c2UgdGhhdCBndWFy
ZHMgb3VyIGZ1dHVyZSwgYnV0IChJIGJlbGlldmUpIHdlIGRvIG1vc3QgdGVzdGluZyBvbgpvdXIg
b3duIHJlbGVhc2VzIHRvIGVuc3VyZSB3ZSBkb24ndCByZWdyZXNzIGFuZCB0byBmaW5kIHByb2Js
ZW1zIGJlZm9yZQpvdXIgY3VzdG9tZXJzLiAgVGhlIGtleSBvYnNlcnZhdGlvbiBpcyB0aGF0IExp
bnVzJyB1cHN0cmVhbSBrZXJuZWwKZG9lc24ndCBoYXZlIHRvIGJlIHBlcmZlY3QuICBUaGVyZSBh
cmUgcmVncmVzc2lvbnMgYWxsIHRoZSB0aW1lLiAgVGhhdAppcyB3aHkgd2UgaGF2ZSB0aGUgLXN0
YWJsZSB0cmVlcy4gIFRoYXQgaXMgaG93IGRpc3Ryb3MgbGlrZSBTVVNFIGFuZApSZWRoYXQgbWFr
ZSBtb25leS4KClllcywgd2Ugd2FudCB0byBiZSBkb2luZyBjb3JyZWN0bmVzcyBhbmQgcGVyZm9y
bWFuY2UgdGVzdGluZyBvbgptYWlubGluZSwgYnV0IHdlIGRvbid0IG5lZWQgdG8gZW5zdXJlIHdl
IGJsb2NrIGFueSByZWdyZXNzaW9ucy4gIFdlIG9ubHkKbmVlZCB0byBldmVudHVhbGx5IGZpbmQg
cmVncmVzc2lvbnMgYW5kIHRoZW4gZml4IHRoZW0uICBIb3BlZnVsbHkgd2UKZmluZCBhbmQgZml4
IGJlZm9yZSB0aGUgcmVncmVzc2lvbiBnZXRzIHRvIGFueSBvZiBvdXIgY3VzdG9tZXJzICh0aG91
Z2gKaXQgcmVhbGl0eSBvdXIgY3VzdG9tZXJzIGZpbmQgcXVpdGUgYSBmZXcgb2Ygb3VyIHJlZ3Jl
c3Npb25zKS4KCj4gCj4gCj4gPj4+IEFsbCB3ZSdkIG5lZWQgdG8gZG8gaXQga2ljayBvZmYgdGVz
dC9idWlsZAo+ID4+PiBzZXNzaW9ucyBvbmNlIHRoZSBtZXJnZSB3aW5kb3cgY2xvc2VzLiBCYXNl
ZCBvbiB0aGUgTU9GRUQKPiA+Pj4gZXhhbXBsZSB5b3UgZ2F2ZSwgaXQgc2VlbXMgbGlrZSB0aGlz
IGlzIHNvbHZhYmxlLgo+ID4+IAo+ID4+IFN1cmUsIEFsbCBjYW4gYmUgc29sdmVkLiBCdXQgd2hh
dCBhcmUgY29zdCBmb3IgdGhpcyBhbmQgY29zdCBmb3Igc3VwcG9ydCB0aGVzZSBjaGFuZ2VzPwo+
ID4+IEFuZCBuZXh0IHF1ZXN0aW9uIC0gd2hvIHdpbGwgcGF5IGZvciB0aGlzIGNvc3Q/IFdobyB3
aWxsIHByb3ZpZGUgYW4gSFcgZm9yIGV4dHJhIHRlc3Rpbmc/Cj4gPj4gU28gc2Vjb25kIGZhY2Ug
b2Yg4oCcbm8gY29zdCBmb3Iga2VybmVsIEFQSSBjaGFuZ2Vz4oCdIC0gaXQgd2lsbCBiZSBhIHBy
b2JsZW1zIHdpdGggYmFjayBwb3J0aW5nIHRoZXNlIGNoYW5nZXMgYW5kIGV4dHJhIHRlc3Rpbmcu
Cj4gPiAKPiA+IEkgZG9uJ3QgdGhpbmsgdGhlIGJhY2twb3J0aW5nIHdpbGwgYmUgbW9yZSBidXJk
ZW5zb21lCj4gPiB0aGFuIHBvcnRpbmcgTHVzdHJlIHRvIG5ldyBrZXJuZWxzLiBBbmQgd2UgZG9u
J3QgaGF2ZSB0bwo+ID4gdXJnZW50bHkgYmFja3BvcnQgZWFjaCB1cHN0cmVhbSByZWxlYXNlIHRv
IG9sZGVyIGtlcm5lbHMuCj4gTmVpbCBCLCBzYXkgd2UgbmVlZHMgdG8gbW92ZSBhbGwgZGV2ZWxv
cG1lbnQgdG8gdGhlIG1haW5zdHJlYW0uICBJdOKAmXMKPiBtZWFuIGtlcm5lbCB1cHN0cmVhbSB3
aWxsIGJlIHNhbWUgYXMg4oCYbWFzdGVy4oCZIGJyYW5jaCBub3cuCj4gU28gZWFjaCBjaGFuZ2Ug
bmVlZHMgdG8gYmUgYmFjayBwb3J0ZWQgdG8gb2xkZXIga2VybmVscyB0byBzeW5jIHdpdGgKPiBz
ZXJ2ZXJzIHdvcmsgYW5kIG1ha2UgcmVhZHkgZm9yIGx1c3RyZSByZWxlYXNlLgo+IE90aGVyd2lz
ZSB3ZSB3aWxsIGhhdmUgYSB0b24gY2hhbmdlcyBuZWVkcyB0byBiZSBiYWNrcG9ydGVkIG9uIGVh
Y2gKPiBsdXN0cmUgcmVsZWFzZS4gCj4gSSBzZWUgbm8gZGlmZmVyZW5jZXMgd2l0aCBwb3J0aW5n
IHRvIHVwc3RyZWFtLCBleGNlcHQgdGhpcyBwb3J0aW5nCj4gZnJvbSBtYWlubGluZSB0byBvbGQg
a2VybmVscyBzaG91bGQgYmUgaGFuZGxlZCBBU0FQIGRvIGF2b2lkIGx1c3RyZQo+IHJlbGVhc2Ug
ZGVsYXksIHdoaWxlIHBvcnRpbmcgdG8gdGhlIG1haW5zdHJlYW0gbWF5IGRlbGF5ZWQgYXMgaXQg
bm90Cj4gY3JpdGljYWwgZm9yIGN1c3RvbWVycy4KClBvcnRpbmcgdG8gdXBzdHJlYW0gZG9lc24n
dCB3b3JrLiAgVGhlIG1vdGl2YXRpb24gaXNuJ3Qgc3Ryb25nIGVub3VnaAphbmQgcGVvcGxlIGxl
YXZlIGl0IHRoZW4gZm9yZ2V0IGl0IGFuZCB5b3UgZ2V0IHRvbyBtdWNoIGRpdmVyZ2VuY2UgYW5k
Cml0IGJlY29tZSBoYXJkZXIgc28gcGVvcGxlIGRvIGl0IGV2ZW4gbGVzcy4gIFBlb3BsZSBoYXZl
IHRyaWVkLiAgUGVvcGxlCmhhdmUgZmFpbGVkLgoKQmFja3BvcnRpbmcgZnJvbSB1cHN0cmVhbSB0
byBhbiBvbGRlciBrZXJuZWwgaXNuJ3QgdGhhdCBoYXJkLiAgSSBkbyBhCmxvdCBvZiBpdCBhbmQg
d2l0aCB0aGUgcmlnaHQgdG9vbHMgaXQgaXMgbW9zdGx5IGVhc3kuICBPbmUgb2YgdGhlCmJpZ2dl
c3QgZGlmZmljdWx0aWVzIGlzIHdoZW4gd2UgdHJ5IHRvIGJhY2twb3J0IG9ubHkgYSBzZWxlY3Rp
b24gb2YKcGF0Y2hlcyBiZWNhdXNlIHdlIG1pZ2h0IG1pc3MgYW4gaW1wb3J0YW50IGRlcGVuZGVu
Y3kuICBTb21ldGltZXMgaXQgaXMKd29ydGggaXQgdG8gYXZvaWQgY2h1cm4sIHNvbWV0aW1lIGl0
IGlzIGJlc3QgdG8gYXBwbHkgZXZlcnl0aGluZwpyZWxldmFudC4gIEkgYXNzdW1lIHRoYXQgZm9y
IHRoZSBzZWxlY3Rpb24gb2Yga2VybmVscyB0aGF0IHdoYW1jbG91ZCAob3IKd2hvZXZlcikgd2Fu
dCB0byBzdXBwb3J0LCB0aGV5IHdvdWxkIGJhY2twb3J0IGV2ZXJ5dGhpbmcgdGhhdCBjb3VsZAph
cHBseS4gIEkgdGhpbmsgdGhhdCB3b3VsZCBiZSBsYXJnZWx5IG1lY2hhbmljYWwuCgpNYXliZSBp
dCB3b3VsZCBiZSBnb29kIGZvciBtZSB0byBwYWludCBhIG1vcmUgZGV0YWlscyBwaWN0dXJlIG9m
IHdoYXQgSQppbWFnaW5lIHdvdWxkIGhhcHBlbiAtIGFzc3VtaW5nIHdlIGRvIHRha2UgdGhlIHBh
dGggb2YgbGFuZGluZyBhbGwgb2YKbHVzdHJlLCBib3RoIGNsaWVudCBhbmQgc2VydmVyLCB1cHN0
cmVhbS4KCi0gd2Ugd291bGQgY2hhbmdlIHRoZSBrZXJuZWwgY29kZSBpbiBsdXN0cmUtcmVsZWFz
ZSBzbyB0aGF0IGl0IHdhcwogIGV4YWN0bHkgd2hhdCB3ZSBwbGFuIHRvIHN1Ym1pdCB1cHN0cmVh
bS4KLSB3ZSBzdWJtaXQgaXQgYW5kIG9uY2UgYWNjZXB0ZWQgd2UgaGF2ZSBpZGVudGljYWwgY29k
ZSBpbiB1cHN0cmVhbQogIGxpbnV4IGFuZCBsdXN0cmUtcmVsZWFzZQotIHdlIGZvcmsgbHVzdHJl
LXJlbGVhc2UgdG8gYSBuZXcgcGFja2FnZSBjYWxsZWQgKGUuZy4pIGx1c3RyZS10b29scyBhbmQg
CiAgcmVtb3ZlIGFsbCBrZXJuZWwgY29kZSBsZWF2aW5nIGp1c3QgdXRpbHMgYW5kIGRvY3VtZW50
YXRpb24gYW5kIAogIHRlc3QgY29kZS4gIFRoZSBraW5vZGUuYyBrZXJuZWwgbW9kdWxlIHRoYXQg
aXMgaW4gbHVzdHJlL3Rlc3RzL2tlcm5lbC8KICB3b3VsZCBuZWVkIHRvIGdvIHVwc3RyZWFtIHdp
dGggdGhlIHJlc3Qgb2YgdGhlIGtlcm5lbCBjb2RlIEkgdGhpbmsuCiAgbHVzdHJlLXRvb2xzIHdv
dWxkIGJlIGVhc2lseSBhY2Nlc3NpYmxlIGFuZCBidWlsZGFibGUgYnkgYW55b25lIHdobwogIHdh
bnRzIHRvIHRlc3QgbHVzdHJlCi0gd2UgZm9yayBsdXN0cmUtcmVsZWFzZSB0byBhbm90aGVyIG5l
dyBwYWNrYWdlIGx1c3RyZS1iYWNrcG9ydHMKICBhbmQgcmVtb3ZlIGFsbCBub24ta2VybmVsIGNv
ZGUgZnJvbSB0aGVyZS4gIFdlIGNvbmZpZ3VyZSBpdCB0byBidWlsZAogIG91dC1vZi10cmVlIG1v
ZHVsZXMgd2l0aCBuYW1lcyBsaWtlICJiYWNrcG9ydC1sdXN0cmUiICJiYWNrcG9ydC1sbmV0Igog
IGFuZCBwcm92aWRlIG1vZHByb2JlLmNvbmYgZmlsZXMgdGhhdCBhbGlhcyB0aGUgc3RhbmRhcmQg
bmFtZXMgdG8KICB0aGVzZS4gIFRoYXQgc2hvdWxkIGFsbG93IHRvIG92ZXItcmlkZSB0aGUgZGlz
dHJpYnV0ZWQgbW9kdWxlcyAoaWYKICBhbnkpIHdoZW4gcGVvcGxlIGNob29zZSB0byB1c2UgYmFj
a3BvcnRzLgotIHVwc3RyZWFtIGNvbW1pdHMgd2hpY2ggdG91Y2ggbHVzdHJlIG9yIGxuZXQgYXJl
IGF1dG9tYXRpY2FsbHkgYWRkIHRvCiAgbHVzdHJlLWJhY2twb3J0cyBhbmQgc29tZW9uZSBpcyBu
b3RpZmllZCB0byBoZWxwIHdoZW4gdGhleSBkb24ndCBhcHBseQogIApXaXRoIHRoaXM6CiBBbnlv
bmUgd2hvIHdhbnRzIHRvIHRlc3Qgb3IgdXNlIHRoZSBsdXN0cmUgaW5jbHVkZWQgd2l0aCBhIHBh
cnRpY3VsYXIKIGtlcm5lbCBjYW4gZG8gd2l0aCB3aXRoIG9ubHkgdGhlIGx1c3RyZS10b29scyBw
YWNrYWdlLiAgQW55b25lIHdobwogd2FudHMgdG8gdXNlIHRoZSBsYXRlc3QgbHVzdHJlIGNvZGUg
d2l0aCBhbiBvbGRlciBrZXJuZWwgY2FuIGJ1aWxkIGFuZAogdXNlIGx1c3RyZS1iYWNrcG9ydHMu
CgpUaGVyZSBhcmUgcHJvYmFibHkgcm91Z2gtZWRnZXMgd2l0aCB0aGlzIGJ1dCBJIHN1c3BlY3Qg
dGhleSBjYW4gYmUgZmlsZWQKZG93bi4KCnRoYW5rcywKTmVpbEJyb3duCgpfX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpsdXN0cmUtZGV2ZWwgbWFpbGluZyBs
aXN0Cmx1c3RyZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnCmh0dHA6Ly9saXN0cy5sdXN0cmUub3Jn
L2xpc3RpbmZvLmNnaS9sdXN0cmUtZGV2ZWwtbHVzdHJlLm9yZwo=
