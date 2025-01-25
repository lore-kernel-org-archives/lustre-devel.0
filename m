Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id CA190C0218D
	for <lustre-devel@archiver.kernel.org>; Sat, 25 Jan 2025 23:26:00 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YgW5B29pRz20xv;
	Sat, 25 Jan 2025 15:25:50 -0800 (PST)
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YgW4p35tQz20xZ
 for <lustre-devel@lists.lustre.org>; Sat, 25 Jan 2025 15:25:30 -0800 (PST)
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org
 [IPv6:2a07:de40:b281:104:10:150:64:97])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by smtp-out1.suse.de (Postfix) with ESMTPS id 195EC21160;
 Sat, 25 Jan 2025 23:25:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1737847526; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=Ds+wWqylrX6DFn/CrNFCfWwEpzsl7CGbTaNZ8mdwVrM=;
 b=hG8Rtm5DbtDqIEQQ1mZBqNOhW2PbdZ8A5lWXE2w0j/fY1nGPAdgBMYwnEKI3xYsy807PmC
 JmBdujGiSz2XtUmme9R1TPfLOxocCj5OV8aRbKMmul/rxYNj2gFpbrz7I3+1+WBvYz4GG+
 ZVQXFlDNdE4o9zfRsg0eHZNSp/vXXR4=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1737847526;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=Ds+wWqylrX6DFn/CrNFCfWwEpzsl7CGbTaNZ8mdwVrM=;
 b=cgaPOkwwFWpR7wsjtOOrAHgubazZssvwh37sYDLYxsHdX8mUGccxlDjteqXHmycwC7KIXa
 9+USjToXAuuuFOCw==
Authentication-Results: smtp-out1.suse.de;
 dkim=pass header.d=suse.de header.s=susede2_rsa header.b=hG8Rtm5D;
 dkim=pass header.d=suse.de header.s=susede2_ed25519 header.b=cgaPOkww
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1737847526; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=Ds+wWqylrX6DFn/CrNFCfWwEpzsl7CGbTaNZ8mdwVrM=;
 b=hG8Rtm5DbtDqIEQQ1mZBqNOhW2PbdZ8A5lWXE2w0j/fY1nGPAdgBMYwnEKI3xYsy807PmC
 JmBdujGiSz2XtUmme9R1TPfLOxocCj5OV8aRbKMmul/rxYNj2gFpbrz7I3+1+WBvYz4GG+
 ZVQXFlDNdE4o9zfRsg0eHZNSp/vXXR4=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1737847526;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=Ds+wWqylrX6DFn/CrNFCfWwEpzsl7CGbTaNZ8mdwVrM=;
 b=cgaPOkwwFWpR7wsjtOOrAHgubazZssvwh37sYDLYxsHdX8mUGccxlDjteqXHmycwC7KIXa
 9+USjToXAuuuFOCw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 961F2137DB;
 Sat, 25 Jan 2025 23:25:24 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
 by imap1.dmz-prg2.suse.org with ESMTPSA id pIyeDuRylWfwDgAAD6G6ig
 (envelope-from <neilb@suse.de>); Sat, 25 Jan 2025 23:25:24 +0000
MIME-Version: 1.0
From: "NeilBrown" <neilb@suse.de>
To: "Alexey Lyahkov" <alexey.lyashkov@gmail.com>
In-reply-to: <8BDA07C1-B0B5-4B3F-8F6D-3B900067C20A@gmail.com>
References: <>, <8BDA07C1-B0B5-4B3F-8F6D-3B900067C20A@gmail.com>
Date: Sun, 26 Jan 2025 10:25:20 +1100
Message-id: <173784752079.22054.3143079741988346111@noble.neil.brown.name>
X-Rspamd-Queue-Id: 195EC21160
X-Spamd-Result: default: False [-4.51 / 50.00]; BAYES_HAM(-3.00)[100.00%];
 NEURAL_HAM_LONG(-1.00)[-1.000];
 R_DKIM_ALLOW(-0.20)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
 NEURAL_HAM_SHORT(-0.20)[-1.000]; MIME_GOOD(-0.10)[text/plain];
 MX_GOOD(-0.01)[]; TAGGED_RCPT(0.00)[];
 RCVD_VIA_SMTP_AUTH(0.00)[]; TO_DN_SOME(0.00)[];
 TO_DN_EQ_ADDR_SOME(0.00)[]; FREEMAIL_TO(0.00)[gmail.com];
 MIME_TRACE(0.00)[0:+]; MISSING_XM_UA(0.00)[]; ARC_NA(0.00)[];
 FREEMAIL_ENVRCPT(0.00)[gmail.com];
 FUZZY_BLOCKED(0.00)[rspamd.com]; RCVD_TLS_ALL(0.00)[];
 FROM_EQ_ENVFROM(0.00)[]; FROM_HAS_DN(0.00)[];
 RCPT_COUNT_THREE(0.00)[3]; RCVD_COUNT_TWO(0.00)[2];
 TO_MATCH_ENVRCPT_ALL(0.00)[];
 DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,imap1.dmz-prg2.suse.org:rdns];
 DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
 DKIM_TRACE(0.00)[suse.de:+]
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

T24gU2F0LCAyNSBKYW4gMjAyNSwgQWxleGV5IEx5YWhrb3Ygd3JvdGU6Cj4gCj4gCj4gICAgIDI1
INGP0L3Qsi4gMjAyNeKAr9CzLiwg0LIgMDI6MjQsIE5laWxCcm93biA8bmVpbGJAc3VzZS5kZT4g
0L3QsNC/0LjRgdCw0Lso0LApOgo+ICAgIAo+ICAgICBPbiBUaHUsIDIzIEphbiAyMDI1LCBBbGV4
ZXkgTHlhaGtvdiB3cm90ZToKPiAgICAKPiAgICAgICAgCj4gICAgICAgIAo+ICAgICAgICAKPiAg
ICAgICAgICAgIEtlZXBpbmcgZGlmZmVyZW50IGtlcm5lbHMgdXAgdG8gZGF0ZSB3aXRoIG5ldyB1
cGRhdGVzIGlzCj4gICAgICAgICBzb21ldGhpbmcKPiAgICAgICAgICAgIHRoYXQKPiAgICAgICAg
ICAgIHRoZSBsaW51eC1zdGFibGUgdGVhbSBkb2VzIGFsbCB0aGUgdGltZS4gIFdlIGRvIGl0IGF0
IFNVU0UKPiAgICAgICAgIHRvLiAgSXQKPiAgICAgICAgICAgIGlzbid0Cj4gICAgICAgICAgICB0
aGF0IGhhcmQuCj4gICAgICAgICAgICBZb3UgaWRlbnRpZnkgd2hpY2ggcGF0Y2hlcyAqbmVlZCog
dG8gYmUgYmFja3BvcnRlZCAoaWRlYWxseQo+ICAgICAgICAgd2hlbgo+ICAgICAgICAgICAgdGhl
Cj4gICAgICAgICAgICBwYXRjaCBpcyBjcmVhdGVkIGJ1dCB0aGF0IGlzbid0IGFsd2F5cyBlYXN5
KSBhbmQgeW91IHVzZQo+ICAgICAgICAgdG9vbHMgdG8KPiAgICAgICAgICAgIGhlbHAKPiAgICAg
ICAgICAgIHlvdSBiYWNrcG9ydCB0aGVtLgo+ICAgICAgICAKPiAgICAgICAgIFNvIEx1c3RyZSBk
ZXZlbG9wZXJzIG5lZWRzIGNvbnRyb2wgYWxsIHN0YWJsZSBrZXJuZWxzIGFuZCB0aGluawo+ICAg
ICAgICAgd2hpY2gKPiAgICAgICAgIHBhdGNoIG5lZWRzIGJhY2sgcG9ydGVkIGFuZCBzZW5kIGl0
IHRvIERpc3RybyBvd25lcgo+ICAgICAgICAgQW5kIGZvciBlYWNoIExUUyBrZXJuZWxzIG9uIHRo
ZSBrZXJuZWwub3JnLi4gSSB0aGluayBpdAo+ICAgICAgICAgaW5jcmVhc2UgYSB3b3JrCj4gICAg
ICAgICBkcmFtYXRpY2FsbHkuCj4gICAgCj4gICAgCj4gICAgIE5vLiAgTHVzdHJlIGRldmVsb3Bl
cnMgZG9uJ3QgbmVlZCB0byBjYXJlIGFib3V0IHRoZSBzdGFibGUga2VybmVscwo+ICAgICBhdAo+
ICAgICBhbGwuICBUaGUgc3RhYmxlIHRlYW0gZG9lcyB0aGF0IGFuIGV4cGxpY2l0bHkgc2F5IHRo
ZXkgZG9uJ3Qgd2FudAo+ICAgICBpdCB0bwo+ICAgICBiZSBhIGJ1cmRlbiBvbiBtYWludGFpbmVy
cy4KPiAKPiBMdXN0cmUgbWFpbnRhaW5lcnMgZG9u4oCZdCBuZWVkcyByZXZpZXcgY29kZSB3aGlj
aCBhZmZlY3RzIGEgTHVzdHJlPyBJdOKAmXMKPiBzb21ldGhpbmcgbmV3IGZvciBtZS4KCkl0IG1h
eSBiZSBuZXcsIGJ1dCBpdCBpcyBzdGlsbCB0cnVlIC0gcGFydGx5LgpUaGUgc3RhYmxlIHRlYW0g
b25seSBhcHBseSBwYXRjaGVzIHdoaWNoIGhhdmUgYWxyZWFkeSBsYW5kZWQgaW4KdXBzdHJlYW0s
IHNvIHRoZXkgaGF2ZSBhbHJlYWR5IGJlIHJldmlld2VkIGJ5IHVwc3RyZWFtIG1haW50YWluZXJz
LgpUaGV5IGRvIHNvbWV0aW1lcyBhcHBseSBvdGhlciBwYXRjaGVzIHdoZW4gYSBmaXggaXMgbmVl
ZGVkIGJ1dCBpdCBjYW5ub3QKYmUgYWNoaWV2ZWQgd2l0aCBhIHNpbXBsZSBiYWNrcG9ydCAtIGJ1
dCB0aG9zZSB3aWxsIG9ubHkgYmUgYWNjZXB0ZWQKZnJvbSBtYWludGFpbmVycy4KClNvIHRoZSBw
YXRjaGVzICpoYXZlKiBiZWVuIHJldmlld2VkLiAgVGhleSd2ZSBiZWVuIHJldmlld2VkIGluIGEg
ZGlmZmVyZW50CmNvbnRleHQgc28gdGhlIHJldmlldyBtaWdodCBub3Qgc3RpbGwgYXBwbHkgYW5k
IGNlcnRhaW5seSBwYXRjaGVzIGRvCmxhbmQgaW4gLXN0YWJsZSB3aGljaCBicmVhayB0aGluZ3Mg
aW4gYWxsIHNvcnRzIG9mIGRpZmZlcmVudCB3YXlzLiAgSXQKaXMgZ2VuZXJhbGx5IHRob3VnaHQg
dGhhdCB0aGlzIGNvc3QgaXMgc21hbGwgY29tcGFyZWQgdG8gdGhlIGJlbmVmaXQKb2YgZ2V0dGlu
ZyBsb3RzIG9mIGZpeGVzLgoKPiBJIHVuZGVyc3RhbmQgYSBkcml2ZXJzIGNoYW5nZXMgc2hvdWxk
IGRvbuKAmXQgcmV2aWV3ZWQgYnkgbHVzdHJlIHRlYW0uCj4gQnV0IGFyY2gv4oCmIGZzLyAuLiBt
bS8uLi4ga2VybmVsLyBuZWVkcyBhdHRlbnRpb24uCj4gTGFjayB0byByZXZpZXcgd2lsbCBjYXVz
ZSBhIHZlcnkgbGFyZ2UgcXVhbGl0eSBkZWdyYWRhdGlvbiBhZnRlciBzaG9ydAo+IHRpbWUuCj4g
QXMgSSBwb2ludCBlYXJseSAtIEkgdGhpbmsgbm9uZSBvZiBsaW51eCBtYWludGFpbmVycyBoYXZl
IGEgbHVzdHJlCj4gY2x1c3RlciB0byB0ZXN0IGEgcGF0Y2hlcyBiZWZvcmUgbGFuZC4KClRoZXkg
ZG9uJ3QgdG9kYXksIHBhcnRseSBiZWNhdXNlIGx1c3RyZSBpcyBub3QgbWFpbmxpbmUuICBUaGVy
ZSBhcmUgYQpudW1iZXIgb2YgdGVzdGluZyBlZmZvcnRzIGFyb3VuZCB0aGUga2VybmVsIHdoaWNo
IHJ1biBhbGwgc29ydCBvZgpkaWZmZXJlbnQgdGVzdHMuICBJZiB3ZSBtYWRlIGl0IGVhc3kgdG8g
c3BpbiB1cCBhIHZpcnR1YWwgbHVzdHJlIGNsdXN0ZXIKZm9yIHRlc3RpbmcgYW5kIHB1YmxpY2lz
ZWQgdGhhdCwgSSB0aGluayB0aGVyZSBpcyBhIHJlYXNvbmFibGUgY2hhbmNlCnRoYXQgc29tZSBw
ZW9wbGUgd2lsbCBydW4gaXQuICBJdCBkb2Vzbid0IG5lZWQgdG8gYmUgdGhlIHVwc3RyZWFtCm1h
aW50YWluZXJzLiAgSXQgY2FuIGJlIGFueW9uZSB3aXRoIHRoZSByZWxldmFudCByZXNvdXJjZXMu
Cgo+IFRoZXkgY2FuIGRvIHRlc3Qgb3duIHBhcnQgYW5kIGhvdyB0byBidWlsZCBhdCBhbGwuIEJ1
dCBob3cgaXQgYWZmZWN0cyBhCj4gTHVzdHJlPyBBIHNwZWNpYWxseSBpbiBwZXJmb3JtYW5jZSBh
cmVhLgo+IFNtYWxsIGV4YW1wbGVzIGZyb20gcGFzdC4KPiBTbWFsbCBvcHRpbWlzYXRpb24gZm9y
IHBhZ2VfYWNjZXNzZWQoKSBhbmQgTFJVIGxpc3RzIGZpeGVzIGEgcHJvYmxlbQo+IHdpdGggZXh0
NCBiaXRtYXAgaW4gbWVtb3J5IGFuZCBpbXByb3ZlIGx1c3RyZSBwZXJmb3JtYWNlIGZvciAxMCUu
IER1ZQo+IGxhY2sgb2YgcmVhZCBkdXJpbmcgd3JpdGUuIChodHRwczovL2x3bi5uZXQvQXJ0aWNs
ZXMvNTQ4ODMwLykKPiBTbWFsbCBjaGFuZ2UgaW4gamJkMiBjb2RlIC0gbGlrZSByZXBsYWNlIGxp
c3RfYWRkIHRvIGxpc3RfYWRkX3RhaWwgLQo+IGltcHJvdmUgcGVyZm9ybWFuY2UgZm9yIDUtMTUl
IGR1ZSBqb3VybmFsIGhhbmRsZSBzdGFydmF0aW9uIHNvbHZlZC4KPiAoaHR0cHM6Ly93d3cuc3Bp
bmljcy5uZXQvbGlzdHMvbGludXgtZXh0NC9tc2c4NDg4OC5odG1sKQo+IAo+IFNvIHllcywgTHVz
dHJlIGRldmVsb3BlcnMgY2FuIG1vdmUgIExUUyBrZXJuZWxzIGFzIHVuc3VwcG9ydGVkIGFyZWEg
YW5kCj4gaWYgaXTigJlzIGJyb2tlbiBqdXN0IHN1Z2dlc3QgdG8gaW5zdGFsbCBhbiBvdXQtb2Yt
dHJlZSBtb2R1bGUgd2l0aAo+IHN1cHBvcnRlZCBrZXJuZWwuIEJ1dCBkaWQgbGludXgga2VybmVs
IG5lZWRzIGEgYnJva2VuIGNvZGUgaW4gdHJlZQo+IHJlYWxseT8KCklmIHNvbWVvbmUgcmVwb3J0
cyB0aGF0IGFuIExUUyBrZXJuZWwgaXMgYnJva2VuIHRoZXkgc2hvdWxkIGJlIGRpcmVjdGVkCnRv
IHdob2V2ZXIgc3VwcG9ydHMgaXQsIG5vdCBqdXN0IHRvbGQgdG8gcmlwIG91dCB0aGUgY29kZS4K
SWYgdGhleSBjYW5ub3QgZmluZCBhbnlvbmUgdG8gc3VwcG9ydCBpdCB0aGV5IGNvdWxkIGJlIGd1
aWRlZCB0byB1c2UgYQpkaWZmZXJlbnQga2VybmVsIHRoYXQgZG9lcyBoYXZlIHN1cHBvcnQuCgo+
IAo+IAo+IAo+ICAgICBUaGUgbHVzdHJlIHRlYW0gKmNhbiogZGVjaWRlIHRvIGhhdmUgc29tZSBp
bnZvbHZlbWVudCAtIGFkZGluZwo+ICAgICBGaXhlcwo+ICAgICB0YWdzLCBhZGRpbmcgQ2M6IHN0
YWJsZSwgZXZlbiBzdWJtaXR0aW5nIGJhY2twb3J0cyB3aGljaCBkb24ndAo+ICAgICBhcHBseQo+
ICAgICB0cml2aWFsbHkuICBCdXQgdGhlcmUgaXMgbm8gcmVxdWlyZW1lbnQgZnJvbSBhbnl3aGVy
ZS4KPiAgICAKPiAKPiAgICAgVGhlIGx1c3RyZSBjb21tdW5pdHkgb25seSBuZWVkIHRvIGZvY3Vz
IG9uIG9uZSB1cHN0cmVhbS4KPiAKPiBBbmQgaGF2ZSBhIGJyb2tlbiBsdXN0cmUgY2xpZW50IG9u
Y2UgaXQgZG9u4oCZdCB0ZXN0ZWQuIE9yIGx1c3RyZSBjbGllbnQKPiB3aWxsIGhpdCBhIHBlcmZv
cm1hbmNlIGRlZ3JhZGF0aW9uLgoKWWVzLCBjb2RlIHRoYXQgaXMgbm90IG1haW50YWluZWQgd2ls
bCBzdWZmZXIgcmVncmVzc2lvbnMuICBUaGlzIGlzIGhvdwp2YXJpb3VzIHZlbmRvcnMgbWFrZSBt
b25leSAtIGJ5IHNlbGxpbmcgc3VwcG9ydCBhbmQgaGF2aW5nIGV4cGVydGlzZSB0bwpmaXggcmVn
cmVzc2lvbnMuCgo+IAo+IAo+IE5laWwsIFRpbSwgCj4gCj4gCj4gICAgIEx1c3RyZSBkZXZlbG9w
cyB3aG8gd29yayBmb3IgZW1wbG95ZXJzIHdobyBzZWxsIHN1cHBvcnQgZm9yIG9sZGVyCj4gICAg
IGtlcm5lbHMgbWlnaHQgbmVlZCB0byBoYW5kbGUgYmFja3BvcnRzIHRvIHRob3NlIGtlcm5lbHMg
YW5kIGl0IGlzCj4gICAgIGluCj4gICAgIGV2ZXJ5Ym9keSdzIGludGVyZXN0IG5vdCB0byBtYWtl
IHRoYXQgdW5kdWx5IGRpZmZlcmVudCBlLmcuICBieQo+ICAgICBzZXBhcmF0aW5nIGJ1ZyBmaXhl
cyBmcm9tIGZlYXR1cmVzIGV0Yy4KPiAgICAKPiAKPiBMdXN0cmUgcHJpbWFyeSBhcmVhIGlzIOKA
mG9sZGVy4oCZIGtlcm5lbHMuIEFzIEkgcG9pbnQgZWFybHkgaGFsZiBvZgo+IGN1c3RvbWVycyB1
c2VzIGEgUkhFTDcsIHNlY29uZCAzMCUgaXMgUkhFTDguCj4gQW5kIGp1c3QgMiUgdXNlcyBhIG1v
ZGVybiBrZXJuZWxzLgoKUkhFTCdzIHByaW1hcnkgYXJlYSBpcyBvbGRlciBrZXJuZWxzLiAgU0xF
UydzIHByaW1hcnkgYXJlYSBpcyBvbGRlciBrZXJuZWxzLgpXZSBzdGlsbCBjb250cmlidXRlIHBy
aW1hcmlseSB1cHN0cmVhbS4gIApXZSBrbm93IHVwc3RyZWFtIGlzIG5vdCBzdWl0YWJsZSBmb3Ig
b3VyIGN1c3RvbWVycy4gIEJlZm9yZSB3ZSBjaG9vc2UgYQprZXJuZWwgZm9yIGEgbmV3IHJlbGVh
c2Ugd2UgcnVuIGEgbG90IG9mIHRlc3Rpbmcgb24gYSByYW5nZSBvZgpjYW5kaWRhdGVzIGFuZCBw
aWNrIHRoZSBvbmUgdGhhdCBzZWVtcyB0byBoYXZlIHRoZSBsZWFzdCBwcm9ibGVtcy4gIFRoZW4K
d2Ugd29yayBpdCBpZGVudGlmeSBhbmQgZml4IHRoZSBwcm9ibGVtcyB0aGF0IGFyZSBtb3N0IGxp
a2VseSB0byBhZmZlY3QKb3VyIGN1c3RvbWVycy4KClRoZXJlIGlzIG5vIHJlYXNvbiB0aGF0IGx1
c3RyZSB2ZW5kb3JzIGNvdWxkbid0IHVzZSBhbmQgYmVuZWZpdCBmcm9tIHRoZQpzYW1lIG1vZGVs
LiAgTmV3IHdvcmsgZ29lcyB1cHN0cmVhbSwgQmFja3BvcnQgdGhlIGJpdHMgbmVlZGVkIGJ5IHlv
dXIKY3VzdG9tZXJzIHRvIHRoZSBrZXJuZWxzIHRoYXQgeW91ciBjdXN0b21lcnMgYXJlIHVzaW5n
LgoKSXQgaXNuJ3QgY2xlYXIgdG8gbWUgdGhhdCB0aGUgIkNvbW11bml0eSBlZGl0aW9uIiBvZiBs
dXN0cmUgbmVlZHMgdG8Kc3VwcG9ydCBvbGRlciBrZXJuZWxzIGF0IGFsbCAodGhvdWdoIEkgZG9u
J3Qgb2JqZWN0IHRvIHRoYXQpLiAgRWFjaAp2ZW5kb3IgY2FuIGNob29zZSB0aGUga2VybmVsIG9y
IGtlcm5lbHMgdGhhdCB0aGV5IHdhbnQgdG8gc3VwcG9ydCBhbmQKc2VsZWN0IHRoZSByZWxldmFu
dCBwYXRjaGVzIGZyb20gdXBzdHJlYW0gdG8gbWFrZSBpdCBmaXQgdGhlaXIgbmVlZHMuCkJ1Z2Zp
eGVzIHNob3VsZCBiZSBlYXN5IGFzIHRoZXkgc2hvdWxkIGJlIHRhZ2dlZCBhcyBidWcgZml4ZXMu
ICBGZWF0dXJlcwptaWdodCBiZSBhIGxpdHRsZSBoYXJkZXIgYnV0IG5vdCBlbm9ybW91c2x5IHNv
LgoKVGhhbmtzLApOZWlsQnJvd24KCgo+IAo+IAo+IAo+ICAgICBUaGUgbHVzdHJlIGNvbW11bml0
eSBtYXkgd2VsbCBjaG9vc2UgdG8gaG9zdCBhbmQgc2hhcmUgdGhvc2UKPiAgICAgYmFja3BvcnRz
LAo+ICAgICBhbmQgbWF5YmUgZXZlbiBpbmNsdWRlIHRoZW0gaW4gdGVzdGluZy4gIEJ1dCBJIHN1
c3BlY3QgdGhhdCB3b3VsZAo+ICAgICBiZQo+ICAgICBkcml2ZW4gYnkgdmVuZG9ycyB3aG8gc2Vs
bCBzdXBwb3J0LiAgSXQgY2VydGFpbmx5IHdvdWxkbid0IGJlCj4gICAgIGltcG9zZWQgYnkKPiAg
ICAgdGhlIHVwc3RyZWFtIGNvbW11bml0eS4KPiAgICAKPiAgICAgRXhhY3RseSBob3cgd2Ugd29y
ayB3aXRoIGRpc3Ryb3MgbGlrZSBSZWRoYXQsIFNVU0UsIFVidW50dSB3b3VsZAo+ICAgICBkZXBl
bmQKPiAgICAgb24gd2hhdCBjYW4gYmUgbmVnb3RpYXRlZCB3aXRoIHRoZW0uCj4gICAgIFNvbWUg
bWlnaHQgYmUgd2lsbGluZyB0byBhY2NlcHQgYmFja3BvcnRzIGFuZCByZWxlYXNlIHRoZW0gaW4K
PiAgICAgbWFpbnRlbmFuY2UgdXBkYXRlcy4gIFNvbWUgbWlnaHQgbm90Lgo+ICAgICBJbiB0aGF0
IGNhc2UgdGhlIHdheSB0byBzdXBwb3J0IHRoZWlyIGtlcm5lbCBmb3IgeW91ciBjdXN0b21lcnMK
PiAgICAgd291bGQgYmUKPiAgICAgdG8gc3RhcnQgd2l0aCB0aGUgc291cmNlIGZvciBhIHBhcnRp
Y3VsYXIgbWFpbnQgdXBkYXRlLCBhZGQgdGhlCj4gICAgIG1pc3NpbmcKPiAgICAgcGF0Y2hlcywg
YnVpbGQsIGFuZCBkaXN0cmlidXRlIHRoZSByZXN1bHQuCj4gICAgIFlvdSBwcm9iYWJseSB3b3Vs
ZCBvbmx5IG5lZWQgdG8gZG8gdGhpcyBmb3IgZWFjaCBzZXJ2aWUtcGFjaywgbm90Cj4gICAgIGZv
cgo+ICAgICBlYWNoIHVwZGF0ZS4KPiAgICAKPiAgICAgSXQgaXNuJ3QgcmVhbGx5IGRpZmZlcmVu
dCBmcm9tIHdoYXQgaXQgZG9uZSB0b2RheSwgYnV0IGl0IHdvdWxkIGJlCj4gICAgIGRvbmUKPiAg
ICAgaW4gYSBkaWZmZXJlbnQgd2F5Lgo+ICAgIAo+ICAgICBUaGFua3MsCj4gICAgIE5laWxCcm93
bgo+IAo+IAo+IAo+IAo+IAoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX18KbHVzdHJlLWRldmVsIG1haWxpbmcgbGlzdApsdXN0cmUtZGV2ZWxAbGlzdHMubHVz
dHJlLm9yZwpodHRwOi8vbGlzdHMubHVzdHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRldmVs
LWx1c3RyZS5vcmcK
