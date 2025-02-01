Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id BB339C0218A
	for <lustre-devel@archiver.kernel.org>; Sat,  1 Feb 2025 22:19:18 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YlnH42s6hz1xRp;
	Sat, 01 Feb 2025 14:19:12 -0800 (PST)
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YlnH26qn5z1xNx
 for <lustre-devel@lists.lustre.org>; Sat, 01 Feb 2025 14:19:10 -0800 (PST)
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org
 [IPv6:2a07:de40:b281:104:10:150:64:97])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by smtp-out2.suse.de (Postfix) with ESMTPS id CD0061F44F;
 Sat,  1 Feb 2025 22:19:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1738448349; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=BDYOzJBO9gABD+etNQNRW2nydEaVAWgdhHWsBVswds0=;
 b=emjtFFKrmMaOWqSQ+50jArumme0N5cUJbYwDbBo/POQK6DexTAYIwmF4ABp7fBRHTSdNte
 6KS20HpJSsRIA36sXXayb5Yr/DQVa7TCABHDRheNwtQUJOb/Zr3wxv9+sfwicJmYWI0Uqw
 54lKdkbAWLlOPP+VA9QdZWFV5hYNqaQ=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1738448349;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=BDYOzJBO9gABD+etNQNRW2nydEaVAWgdhHWsBVswds0=;
 b=G8OOTyDol9p3OuNA2qqBCKDWLSBjNo19N6xCE5pTCu2KCJNhrZzF+inrx2ZpqCl6gVD4Dn
 80v88zumF45I1aAg==
Authentication-Results: smtp-out2.suse.de;
 dkim=pass header.d=suse.de header.s=susede2_rsa header.b=GawMPWdn;
 dkim=pass header.d=suse.de header.s=susede2_ed25519 header.b=Gojq7pmW
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1738448348; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=BDYOzJBO9gABD+etNQNRW2nydEaVAWgdhHWsBVswds0=;
 b=GawMPWdnvwKAemYqmlwtbbqgfGl4f1QlHoa/daXMkZzRQ+wBE8FXRPKKVf6wTMQa91DdJR
 hVLnwjFDw4Ra8B3z90LrcTfPYwmHa6z+qxx0SRd/zmww2PkuKuJI0tVkpxElTAvLVl2icY
 6yM085OPTw3WfCmSjRgGpR4qEsL9uhs=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1738448348;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=BDYOzJBO9gABD+etNQNRW2nydEaVAWgdhHWsBVswds0=;
 b=Gojq7pmW/6WJnqdraqzMwspndr//kEouLkxEk/1hZx+hOHs/qzYYbOx60WZxqwvAHCyCnz
 7G7GfEpUA9Pt0EAw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 8F3101365D;
 Sat,  1 Feb 2025 22:19:07 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
 by imap1.dmz-prg2.suse.org with ESMTPSA id WzjDENudnmeEVAAAD6G6ig
 (envelope-from <neilb@suse.de>); Sat, 01 Feb 2025 22:19:07 +0000
MIME-Version: 1.0
From: "NeilBrown" <neilb@suse.de>
To: "Oleg Drokin" <green@whamcloud.com>
In-reply-to: <d008c14bba74e39999ae70af871740a5d0c5c6eb.camel@whamcloud.com>
References: <>, <d008c14bba74e39999ae70af871740a5d0c5c6eb.camel@whamcloud.com>
Date: Sun, 02 Feb 2025 09:19:03 +1100
Message-id: <173844834301.22054.134358817491003595@noble.neil.brown.name>
X-Rspamd-Queue-Id: CD0061F44F
X-Rspamd-Action: no action
X-Spamd-Result: default: False [-4.51 / 50.00]; BAYES_HAM(-3.00)[100.00%];
 NEURAL_HAM_LONG(-1.00)[-1.000];
 R_DKIM_ALLOW(-0.20)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
 NEURAL_HAM_SHORT(-0.20)[-1.000]; MIME_GOOD(-0.10)[text/plain];
 MX_GOOD(-0.01)[]; FROM_HAS_DN(0.00)[];
 DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
 FUZZY_BLOCKED(0.00)[rspamd.com];
 RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from]; 
 TO_DN_EQ_ADDR_SOME(0.00)[]; ARC_NA(0.00)[];
 MIME_TRACE(0.00)[0:+];
 SPAMHAUS_XBL(0.00)[2a07:de40:b281:104:10:150:64:97:from];
 TO_MATCH_ENVRCPT_ALL(0.00)[]; RCVD_TLS_ALL(0.00)[];
 DKIM_TRACE(0.00)[suse.de:+];
 RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
 RCVD_COUNT_TWO(0.00)[2]; FROM_EQ_ENVFROM(0.00)[];
 TO_DN_SOME(0.00)[]; RCVD_VIA_SMTP_AUTH(0.00)[];
 MISSING_XM_UA(0.00)[];
 ASN(0.00)[asn:25478, ipnet:::/0, country:RU];
 RCPT_COUNT_THREE(0.00)[3];
 DBL_BLOCKED_OPENRESOLVER(0.00)[suse.de:dkim, imap1.dmz-prg2.suse.org:rdns,
 imap1.dmz-prg2.suse.org:helo]
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

T24gU2F0LCAyNSBKYW4gMjAyNSwgT2xlZyBEcm9raW4gd3JvdGU6Cj4gT24gU2F0LCAyMDI1LTAx
LTI1IGF0IDEwOjEyICsxMTAwLCBOZWlsQnJvd24gd3JvdGU6Cj4gPiBPbiBNb24sIDIwIEphbiAy
MDI1LCBPbGVnIERyb2tpbiB3cm90ZToKPiA+ID4gT24gU3VuLCAyMDI1LTAxLTE5IGF0IDA5OjQ4
ICsxMTAwLCBOZWlsQnJvd24gd3JvdGU6Cj4gPiA+ID4gCj4gPiA+ID4gT25jZSB0aGUgdHJhbnNp
dGlvbiBjb21wbGV0ZXMgdGhlcmUgd2lsbCBzdGlsbCBiZSBwcm9jZXNzCj4gPiA+ID4gZGlmZmlj
dWx0aWVzLAo+ID4gPiA+IGJ1dCB0aGVyZSBhcmUgcGxlbnR5IG9mIG9mIHByb2Nlc3MgZGlmZmlj
dWx0aWVzIG5vdyAoZ2Vycml0OiBob3cKPiA+ID4gPiBkbyBJCj4gPiA+ID4gaGF0ZSB0aGVlLCBs
ZXQgbWUgY291bnQgdGhlIHdheXMuLi4pIGJ1dCBwZW9wbGUgc2VlbSB0byBzaW1wbHkKPiA+ID4g
PiBpbmNsdWRlCj4gPiA+ID4gdGhhdCBpbiB0aGUgY29zdCBvZiBkb2luZyBidXNpbmVzcy4KPiA+
ID4gCj4gPiA+IGl0J3MgYmVlbiBhd2hpbGUgc2luY2UgSSBkaWQgcGF0Y2ggcmV2aWV3cyBieSBl
bWFpbHMsIGJ1dCBJIHRoaW5rCj4gPiA+IGdlcnJpdCBpcyBtdWNoIG1vcmUgdXNlci1mcmllbmRs
eSAoaWYgeW91IGhhdmUgaW50ZXJuZXQsIGFueXdheSkKPiA+IAo+ID4gSSBndWVzcyBpdCBpc24n
dCBleGFjdGx5IHRoZSBnZXJyaXQgaW50ZXJmYWNlIGJ1dCBtb3JlIHRoZSB3b3JrZmxvdwo+ID4g
dGhhdAo+ID4gaXQgZW5jb3VyYWdlcywgb3IgYXQgbGVhc3QgZW5hYmxlcy4KPiA+IFRoZSBjdXJy
ZW50IHdvcmtmbG93IHNlZW1zIHRvIGJlICJwYXRjaCBhdCBhIHRpbWUiIHJhdGhlciB0aGFuCj4g
PiAicGF0Y2hzZXQKPiA+IGF0IGEgdGltZSIuCj4gPiBUaGUgZmFjdCB0aGF0IHlvdSBjaGVycnkt
cGljayBwYXRjaGVzIGludG8gbWFzdGVyIGlzIGNvbXBsZXRlbHkKPiA+IGRpZmZlcmVudCB0byBo
b3cgbW9zdCAoYWxsPykgb2YgdGhlIHVwc3RyZWFtIGNvbW11bml0eSB3b3Jrcy7CoCBJdAo+ID4g
bWVhbnMKPiA+IHRoYXQgd2hvbGUgc2VyaWVzIGlzbid0IHZpc2libGUgaW4gdGhlIGZpbmFsIGdp
dCB0cmVlIHNvIHdlIGxvc2UKPiA+IGNvbnRleHQuwqAgQW5kIGl0IHNlZW1zIHRvIG1lYW4gdGhh
dCBhIGxvbmcgc2VyaWVzIHRha2VzIGEgbG9vb29vb25nCj4gPiB0aW1lCj4gPiB0byBsYW5kIGFz
IGl0IGRyaWJibGVzIGluIHRvIG1hc3Rlci4KPiAKPiBJbiBmYWN0IHRoZSB3aG9sZSBzZXJpZXMg
aXMgdmlzaWJsZSBpbiBnZXJyaXQgaWYgeW91IHN1Ym1pdCBpdCBhcyBzdWNoLgoKVHJ1ZSwgYnV0
IG5vdCBhcyBoZWxwZnVsIGFzIEkgbWlnaHQgbGlrZS4gIEkgY2Fubm90IHNlZSBhIHdheSB0byBh
ZGQKc29tZW9uZSBhcyBhIHJldmlld2VyIGZvciBhIHdob2xlIHNlcmllcywgYW5kIHRoZXJlIGlz
IG5vIHdheSBmb3IgdGhlbQp0byB0aGVuIGdpdmUgYSArMSBmb3IgdGhlIHdob2xlIHNlcmllcy4g
IFRoZXNlIGFyZSB0cml2aWFsIGFjdGlvbnMgd2hlbgp1c2luZyB1bnN0cnVjdHVyZWQgZW1haWwu
Cgo+IEJ1dCBhcyB5b3Ugbm90ZWQgbGF0ZXIgdGhlIHRlc3RpbmcgaXMgdW5mb3J0dW5hdGVseSBt
dWNoIGxlcyByZWxpYWJsZQo+IHRoYW4gd2Ugd2FudCwgYW5kIGJlY2F1c2Ugd2Ugb25seSBsYW5k
IHRoaW5ncyBpbiBvcmRlciB0aGV5IGFyZQo+IHN1Ym1pdHRlZCBpbiB0aGUgc2VyaWVzIC0gaWYg
eW91IGJ1bmNoIHVucmVsYXRlZCBzdHVmZiBhbGwgdG9nZXRoZXIKPiBzdWRkZW5seSBpdCBtaWdo
dCB0YWtlIG11Y2ggbG9uZ2VyIHRvIGxhbmQuCgpDZXJ0YWlubHkgb25seSBsYW5kIHRoZW0gaW4g
dGhlIG9yZGVyIHRoZXkgYXBwZWFyIGluIHRoZSBzZXJpZXMsIGJ1dCBteQptZW1vcnkgb2YgbXkg
ZXhwZXJpZW5jZSBpcyB0aGF0IGV2ZW4gd2hlbiB0aGV5IGFyZSByZWxhdGVkIHRoZXkgZG9uJ3QK
YWxsIGxhbmQgaW4gbWFzdGVyIGF0IG9uY2UuICBUaGlzIG1pZ2h0IGJlIGR1ZSB0byB0aGUgY29u
c3RhbnQgZmlnaHQKYWdhaW5zdCBmYWxzZSBwb3NpdGl2ZXMgd2l0aCB0ZXN0aW5nLCBhbmQgdGhl
IG5lZWQgdG8gZ2V0IHBlb3BsZSB0bwpyZS1yZXZpZXcgZXZlcnkgcGF0Y2ggd2hlbiBhIHNtYWxs
IHVwZGF0ZSBpcyBuZWVkZWQgaW4gYW4gZWFybGllciBwYXRjaC4KQnV0IGl0IHNlZW1zIHRvIGJl
IG1vcmUgdGhhbiB0aGF0LgoKPiAKPiA+IEkgd291bGQgTVVDSCByYXRoZXIgdGhhdCBhIHdob2xl
IHNlcmllcyB3YXMgYWNjZXB0ZWQgb3IgcmVqZWN0ZWQgYXMgYQo+ID4gd2hvbGUgLSBhbmQgd2Fz
IG1lcmdlZCByYXRoZXIgdGhhbiBjaGVycnktcGlja2VkIHRvIGtlZXAgY29tbWl0IGlkcwo+ID4g
c3RhYmxlLgo+IAo+IEdlcnJpdCBoYXMgc3VjaCBhIG1vZGUsIGJ1dCB3ZSBkZWNpZGVkIGl0IGRv
ZXMgbm90IHdvcmsgd2VsbCBmb3IgdXMgZm9yCj4gYSB2YXJpZXR5IG9mIHJlYXNvbnMuCgpJIHdv
bmRlciBpZiBpdCBtaWdodCBiZSB0aW1lIHRvIHJldmlldyB0aG9zZSByZWFzb25zLCBwYXJ0aWN1
bGFybHkgYXMgd2UKbmVlZCB0byByZXZpZXcgYSBsb3Qgb2YgcHJvY2VzcyBpZiB3ZSBhcmUgdG8g
bW92ZSB0b3dhcmQgd29ya2luZwp1cHN0cmVhbS4KV2UgZG9uJ3QgKmhhdmUqIHRvIGZvbGxvdyB3
aGF0IG90aGVyIHN1YnN5c3RlbXMgZG8gKGFuZCB0aGV5IGFyZW4ndCBhbGwKdGhlIHNhbWUpLCBi
dXQgd2Ugd291bGQgd2FudCB0byBoYXZlIGNsZWFyIHJlYXNvbnMsIHVuZGVyc3Rvb2QgYnkgYWxs
LApmb3IgZGV2aWF0aW5nIHNpZ25pZmljYW50bHkKCj4gCj4gPiBUaGVyZSBhcmUgdGltZXMgd2hl
biBJIHdvdWxkIGxpa2UgdGhlIGZpcnN0IGZldyBwYXRjaGVzIG9mIGEgc2VyaWVzCj4gPiB0bwo+
ID4gbGFuZCBlYXJsaWVyLCBidXQgdGhhdCBzaG91bGQgYmUgdXAgdG8gdGhlIHN1Ym1pdHRlciB0
byBzcGxpdCB0aGUKPiA+IHNlcmllcy4gCj4gCj4gQnV0IHlvdSBjYW5ub3QgaWYgdGhlc2UgbGF0
ZXIgcGF0Y2hlcyBkbyBkZXBlbmQgb24gdGhlIGVhcmxpZXIgb25lcz8KCk9ubHkgYmVjYXVzZSBn
ZXJyaXQgY2Fubm90IGNvcGUuClVzaW5nIGVtYWlsLCBJIG1pZ2h0IHN1Ym1pdCBhIHNldCBvZiAx
MCBwYXRjaGVzLCBnZXQgc29tZSBkaXNjdXNzaW9uLApkZWNpZGUgdGhhdCB0aGUgZmlyc3QgNSBy
ZWFsbHkgYXJlIGdvb2QtdG8tZ28gYnV0IHRoZSBsYXRlciBvbmVzIG5lZWQKc29tZSB3b3JrLiBT
byBJIHJlc3VibWl0IHRoZSBmaXJzdCA1LiAgVGhleSBjYW4gZWFzaWx5IGJlIGFwcGxpZWQgYnkg
dGhlCm1haW50YWluZXIuCldpdGggZ2Vycml0IEkgY291bGQgImFiYW5kb24iIHRoZSBsYXR0ZXIg
NSBidXQgSSBtaWdodCBub3Qgd2FudCB0byBkbwp0aGF0IC0gSSBtaWdodCB3YW50IHRvIHJldmlz
ZS4gIEJ1dCBwcm9iYWJseSBhYmFuZG9uaW5nIHdvdWxkIGJlIG9rLgpTdGlsbCBub3QgcXVpdGUg
YXMgZWFzeSBhcyBzaW1wbHkgbm90IHJlc3VibWl0dGluZyB0aGVtLgoKCj4gCj4gPiBBbmQgdGhl
IGF1dG9tYXRpYyB0ZXN0aW5nIGlzIGEgcmVhbCBwYW5lLsKgIENlcnRhaW5seSBpdCBpcyB2YWx1
YWJsZQo+ID4gYnV0Cj4gPiBpdCBoYXMgYSByZWFsIGNvc3QgdG9vLsKgIFRoZSBmYWxzZSBwb3Np
dGl2ZXMgYXJlIGEgbWFqb3IgcGFuZS7CoCBJCj4gPiB3b3VsZAo+ID4gcmF0aGVyIGFueSB0ZXN0
IHRoYXQgd2Fzbid0IHJlbGlhYmxlIHdlcmUgZGlzYWJsZWQgKG9mIGZpeGVkKSBhcyBhCj4gPiBw
cmlvcml0eS7CoCBPciBhdCBsZWFzdCBtYWRlIG5vbi1mYXRhbC4KPiA+IEFsc28sIGl0IHdvdWxk
IGJlIG11Y2ggbmljZXIgaWYgdGhlIGxhc3QgaW4gYSBzZXJpZXMgd2VyZSB0ZXN0ZWQKPiA+IGZp
cnN0Cj4gPiBhbmQgaWYgdGhhdCBmYWlsZWQgdGhlbiBkb24ndCB3YXN0ZWQgcmVzb3VyY2VzIHRl
c3RpbmcgYWxsIHRoZQo+ID4gb3RoZXJzLgo+ID4gQm9udXMgcG9pbnRzIGZvciBhICJiaXNlY3Qi
IHRvIGZpbmQgd2hlcmUgdGhlIGZhaWx1cmUgc3RhcnRzLCBidXQKPiA+IHRoYXQKPiA+IGNhbiBi
ZSB1cCB0byB0aGUgZGV2ZWxvcCB0byBleHBsaWNpdGx5IHJlcXVlc3QgdGVzdGluZyBhdCBzb21l
IHBvaW50cwo+ID4gaW4KPiA+IHRoZSBzZXJpZXMuCj4gCj4gWWVzLCAgSSBhZ3JlZSB0aGVyZSdz
IG11Y2ggdG8gYmUgaW1wcm92ZWQgdGVzdGluZy13aXNlLiBJIGRpZCBub3QgY29tZQo+IHVwIHdp
dGggbXkgb3duIHBhcmFsbGVsIHRlc3Rpbmcgc3lzdGVtIGJlY2F1c2UgSSB3YXMgaGFwcHkgd2l0
aCB0aGUKPiBkZWZhdWx0IG9uZSBhZnRlciBhbGwuCj4gQW5kIHRoZW4gbXkgb3duIHN5c3RlbSBk
ZXRlcmlvcmF0ZWQgKEF0IGxlYXN0IGl0IGRvZXMgbm90IHNldCAtMXMgbGVmdAo+IGFuZCByaWdo
dCwgdGhvdWdoIHRoYXQgbWVhbnMgcGVvcGxlIHRvdGFsbHkgaWdub3JlIHRob3NlIHJlc3VsdHMg
dG9vKQo+IAoKSSB0aGluayB5b3VyIHBhcmFsbGVsIHN5c3RlbSB0aGF0IGFkZHMgY29tbWVudHMg
dG8gZ2Vycml0IGlzIHNvbWV0aW1lcwp2ZXJ5IGhlbHBmdWwuICBXaGF0IGJvdGhlcnMgbWUgaXMg
dGhhdCB5b3UgaGF2ZSBhbm90aGVyIHRlc3Qgc2V0dXAgdGhhdAp5b3UgcnVuIG9uIG1hc3Rlci1u
ZXh0IGJlZm9yZSBhbmQgd29uJ3QgbGFuZCB0aGluZ3MgdW50aWwgdGhhdCBwYXNzZXMuCkl0IG1l
YW5zIHRoYXQgSSBjYW4gcGFzcyBhbGwgdGhlIGF1dG8gdGVzdGluZyBhbmQgZ2V0IGFsbCB0aGUg
cmV2aWV3cwphbmQgc3RpbGwgdGhlcmUgaXMgYSBxdWVzdGlvbiBtYXJrIG92ZXIgaWYvd2hlbiBp
dCB3aWxsIGxhbmQuICBGb3IgbWUKdGhhdCBjcmVhdGVkIGEgc2Vuc2Ugb2YgaGVscGxlc3NuZXNz
IHRoYXQgd2FzIHF1aXRlIGRlbW90aXZhdGluZy4KT2J2aW91c2x5IGl0IGlzIGdvb2QgdG8gZmlu
ZCBidWdzLCBhbmQgdGhvc2UgYnVncyBuZWVkIHRvIGJlIGZpeGVkLCBidXQKdGhleSBkb24ndCBu
ZWVkIHRvIHByZXZlbnQgbGFuZGluZy4KSSB3b3VsZCBmZWVsIG1vcmUgbW90aXZhdGVkIGlmIHRo
ZXJlIHdlcmUgYSBjbGVhciBwcm9jZXNzIHRoYXQgd2FzCmZvbGxvd2VkIG1vc3Qgb2YgdGhlIHRp
bWUgd2hlcmVieSBvbmNlIGEgc2VyaWVzIHBhc3NlZCBhdXRvLXRlc3RpbmcgYW5kCmhhZCBzdWZm
aWNpZW50IHJldmlld3MgaXQgd291bGQgYmUgZXhwZWN0ZWQgdG8gbGFuZCBlLmcuICB0aGUgbmV4
dApNb25kYXkuICBNYXliZSBpdCBkb2Vzbid0IGxhbmQgaW4gbWFzdGVyLCBtYXliZSBpbiBzb21l
dGhpbmcgZWxzZSB0aGF0CmdldHMgbWVyZ2VkIGFmdGVyIGEgc3RhYmlsaXNhdGlvbiB3aW5kb3cs
IGJ1dCBpdCBzaG91bGQgbGFuZC4KCklmIGFzeW5jaHJvbm91cyB0ZXN0aW5nIHRoZW4gcmVwb3J0
cyBhIHByb2JsZW0gdGhhdCBuZWVkcyB0byBiZQphZGRyZXNzZWQuICBXb3JzdC1jYXNlIHRoZSBw
YXRjaCBtaWdodCBiZSByZXZlcnRlZCBidXQgdGhhdCB3b3VsZCBiZQpyYXJlLiAgT2Z0ZW4gYSBz
bWFsbCBmaXggd2lsbCBtYWtlIHRoZSBwcm9ibGVtIGdvIGF3YXkuCgpUaGFua3MsCk5laWxCcm93
bgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpsdXN0cmUt
ZGV2ZWwgbWFpbGluZyBsaXN0Cmx1c3RyZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnCmh0dHA6Ly9s
aXN0cy5sdXN0cmUub3JnL2xpc3RpbmZvLmNnaS9sdXN0cmUtZGV2ZWwtbHVzdHJlLm9yZwo=
