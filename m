Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 524E1C02185
	for <lustre-devel@archiver.kernel.org>; Mon, 20 Jan 2025 03:57:19 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YbxP76cqJz1xPW;
	Sun, 19 Jan 2025 19:57:15 -0800 (PST)
Received: from smtp-fw-80007.amazon.com (smtp-fw-80007.amazon.com
 [99.78.197.218])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YbxP40jRNz1wrG
 for <lustre-devel@lists.lustre.org>; Sun, 19 Jan 2025 19:57:12 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
 t=1737345432; x=1768881432;
 h=from:to:cc:date:message-id:references:in-reply-to:
 content-id:content-transfer-encoding:mime-version:subject;
 bh=EdkEWfl3PxR2yW7vKZUIPg5SCFZS5rp7hC10YgJFAhI=;
 b=XpQxYOLavqJAapM/3+2nhKgEVa/HHzvjCY0vVJGwJ9qkqCbomIqYYbn7
 gg4O062vw0dl8lL4humB9o36tK0d5OV9R7PJNgBiHr/Xx28i0Ux3eb8oK
 vTSAffFlwBvymOeNExmtpew2F5HxShcnlg9fPY0ud1ChI+Bp+rgRDbPlJ I=;
X-IronPort-AV: E=Sophos;i="6.13,218,1732579200"; d="scan'208";a="370282215"
Thread-Topic: Re: Re: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Received: from pdx4-co-svc-p1-lb2-vlan2.amazon.com (HELO
 smtpout.prod.us-east-1.prod.farcaster.email.amazon.dev) ([10.25.36.210])
 by smtp-border-fw-80007.pdx80.corp.amazon.com with
 ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 20 Jan 2025 03:57:11 +0000
Received: from EX19MTAUEA001.ant.amazon.com [10.0.29.78:33276]
 by smtpin.naws.us-east-1.prod.farcaster.email.amazon.dev [10.0.26.54:2525]
 with esmtp (Farcaster)
 id 64ec9297-b720-4f0c-8680-5d2602abf673; Mon, 20 Jan 2025 03:57:10 +0000 (UTC)
X-Farcaster-Flow-ID: 64ec9297-b720-4f0c-8680-5d2602abf673
Received: from EX19D017UEA001.ant.amazon.com (10.252.134.93) by
 EX19MTAUEA001.ant.amazon.com (10.252.134.203) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.39;
 Mon, 20 Jan 2025 03:57:03 +0000
Received: from EX19D017UEA001.ant.amazon.com (10.252.134.93) by
 EX19D017UEA001.ant.amazon.com (10.252.134.93) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.39;
 Mon, 20 Jan 2025 03:57:02 +0000
Received: from EX19D017UEA001.ant.amazon.com ([fe80::bffb:623f:af5e:ebed]) by
 EX19D017UEA001.ant.amazon.com ([fe80::bffb:623f:af5e:ebed%3]) with
 mapi id 15.02.1258.039; Mon, 20 Jan 2025 03:57:02 +0000
From: "Day, Timothy" <timday@amazon.com>
To: NeilBrown <neilb@suse.de>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Index: AQHbafdVmFBBly3qPEmigDcOTpqs0bMetvgA
Date: Mon, 20 Jan 2025 03:57:02 +0000
Message-ID: <06409D70-8900-4390-A867-ECA443A9FB10@amazon.com>
References: <78EDC1C6-0669-410A-9DCF-4CDCCA3324ED@amazon.com>
 <173723886905.22054.3178107130005088293@noble.neil.brown.name>
In-Reply-To: <173723886905.22054.3178107130005088293@noble.neil.brown.name>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [10.106.179.26]
Content-ID: <4F20696DD4F5A948981245E4CB5A70C3@amazon.com>
MIME-Version: 1.0
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
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

DQoNCu+7vz4gT24gMS8xOC8yNSwgNToyMSBQTSwgIk5laWxCcm93biIgPG5laWxiQHN1c2UuZGUg
PG1haWx0bzpuZWlsYkBzdXNlLmRlPj4gd3JvdGU6DQo+ID4gT24gU3VuLCAxOSBKYW4gMjAyNSwg
RGF5LCBUaW1vdGh5IHdyb3RlOg0KPiA+DQo+ID4gT24gdGhlIG90aGVyIGhhbmQsIEkgd29uZGVy
IGlmIHdlIHVwc3RyZWFtIHRoZSB3aG9sZSB0aGluZyBhbGwgYXQgb25jZS4gQmVzaWRlDQo+ID4g
dGhlIGNvZGUgYmVpbmcgYSBiaXQgbmljZXIsIHRoZSBjbGllbnQgaXNuJ3QgcmVhbGx5IHRoYXQg
bXVjaCBjbG9zZXIgdG8gYmVpbmcgdXBzdHJlYW0NCj4gPiB0aGFuIHRoZSBzZXJ2ZXIgaXMuIEFu
ZCBubyBvbmUgZWxzZSBjYW4gdGVzdCB0aGUgY2xpZW50IHdpdGhvdXQgaGF2aW5nIGEgTHVzdHJl
DQo+ID4gc2VydmVyIG9uLWhhbmQuIFNvIG5vLW9uZSBjYW4gZWFzaWx5IHJ1biB4ZnN0ZXN0cyBv
ciBzaW1pbGFyLiBBbmQgZG9pbmcgZXZlcnl0aGluZw0KPiA+IGFsbCBhdCBvbmNlIHdvdWxkIHBy
ZWVtcHQgcXVlc3Rpb25zIG9mIGNsaWVudC9zZXJ2ZXIgc3BsaXQgb3IgdGhlIHNlcnZlciB1cHN0
cmVhbWluZw0KPiA+IHRpbWVsaW5lLiBCdXQgdXBzdHJlYW1pbmcgc28gbXVjaCBhbGwgYXQgb25j
ZSBpcyBwcm9iYWJseSBtb3JlIHVucmVhbGlzdGljLg0KPg0KPg0KPiBUaGUgbWFpbiBkaWZmZXJl
bmNlIEkgc2VlIGJldHdlZW4gc2VydmVyIGFuZCBjbGllbnQgaW4gdXBzdHJlYW1pbmcgdGVybXMN
Cj4gaXMgdGhlIHN0b3JhZ2UgYmFja2VuZC4gSXQgd291bGQgbmVlZCB0byB1c2UgdW4tcGF0Y2hl
ZCBleHQ0IC0gaWRlYWxseQ0KPiB1c2luZyBWRlMgaW50ZXJmYWNlcyB0aG91Z2ggd2UgbWlnaHQg
YmUgYWJsZSB0byBuZWdvdGlhdGUgd2l0aCB0aGUgZXh0NA0KPiB0ZWFtIHRvIGdldCBzb21lIGV4
cG9ydHMuIEkgZG9uJ3Qga25vdyBtdWNoIGFib3V0IHRoZSBkZWx0YSBiZXR3ZWVuDQo+IGxkaXNr
ZnMgYW5kIGV4dDQgYW5kIHVuZGVyc3RhbmQgaXQgaXMgbXVjaCBzbWFsbGVyIHRoYW4gaXQgb25j
ZSB3YXMsIGJ1dA0KPiBpdCB3b3VsZCBuZWVkIHRvIGJlIHplcm8uIEknbSB3b3JraW5nIHRvd2Fy
ZHMgZ2V0dGluZyB0aGUgcGRpcm9wIHBhdGNoDQo+IHVwc3RyZWFtYWJsZS4gQW5kcmVhcyB3b3Vs
ZCBrbm93IHdoYXQgZWxzZSBpcyBuZWVkZWQgYmV0dGVyIHRoYW4gSS4NCg0KSSd2ZSBiZWVuIHdv
cmtpbmcgb24gYSB0aGlyZCBzdG9yYWdlIGJhY2tlbmQgWzFdLiBJdCdsbCBsaWtlbHkgYmUgZG9u
ZQ0Kd2VsbCBiZWZvcmUgd2Ugc3VibWl0IGFueXRoaW5nIHVwc3RyZWFtLiBJdCdzIGEganVzdCBt
ZW1vcnktb25seQ0KdGFyZ2V0LiBUaGF0IG1pZ2h0IGJlIGp1c3RpZmljYXRpb24gZW5vdWdoIHRv
IGtlZXAgdGhlIE9TRCBBUElzLg0KDQpbMV0gaHR0cHM6Ly9yZXZpZXcud2hhbWNsb3VkLmNvbS9j
L2ZzL2x1c3RyZS1yZWxlYXNlLysvNTU1OTQNCg0KPiBUaGUgb3RoZXIgZGlmZmVyZW5jZSBpcyB0
aGF0IGEgbG90IG9mIHRoZSAicmV2aXNlIGNvZGUgdG8gbWF0Y2ggdXBzdHJlYW0NCj4gc3R5bGUi
IHdvcmsgaGFzIGZvY3VzZWQgb24gY2xpZW50IGFuZCBpZ25vcmVkIHNlcnZlci1vbmx5IGNvZGUu
DQo+DQo+DQo+IEl0IG1pZ2h0IGJlIHNlbnNpYmxlIHRvIHNldCB0aGUgZ29hbCBhcyAiY2xpZW50
IGFuZCBzZXJ2ZXIiIGluY2x1ZGluZw0KPiBvbmx5IHRoZSBleHQ0IGJhY2tlbmQgYW5kIHBvc3Np
Ymx5IG9ubHkgdGhlIHNvY2tsbmQgbmV0d29yayBpbnRlcmZhY2UuDQo+IEl0IHdpbGwgYmUgYSBi
aWcgY29kZSBkcm9wIGVpdGhlciB3YXkuIFBlb3BsZSBhcmVuJ3QgZ29pbmcgdG8gZ28gb3Zlcg0K
PiBldmVyeSBsaW5lIHdpdGggYSBmaW5lLXRvb3RoLWNvbWIuIFRoZXkgd2lsbCBtb3N0bHkgbG9v
ayBhdCB3aGljaGV2ZXINCj4gYml0IHBhcnRpY3VsYXJseSBpbnRlcmVzdHMgdGhlbSwgYW5kIGxv
b2sgYXQgdGhlIHByb2Nlc3MgYW5kIGNvbW11bml0eQ0KPiBiZWhpbmQgdGhlIGNvZGUuDQo+DQo+
DQo+IEJlaW5nIGFibGUgdG8gYnVpbGQgYSBwdXJlIHVwc3RyZWFtIGtlcm5lbCwgYWRkIGEgdXNl
ci1zcGFjZSB0b29scw0KPiBwYWNrYWdlLCBhbmQgdGVzdCB3b3VsZCBjZXJ0YWlubHkgYmUgYSBw
bHVzLiBUaGF0IHdvdWxkIGJlIHNvbWV0aGluZw0KPiB3b3J0aCBjYW52YXNzaW5nIGF0IExTRiAt
IGlzIHRoZXJlIGFueSB2YWx1ZSBpbiBsYW5kaW5nIHRoZSBjbGllbnQNCj4gd2l0aG91dCB0aGUg
c2VydmVyPw0KDQpZZWFoLCBJJ20gbGVhbmluZyB0b3dhcmRzIHNldHRpbmcgdGhlIGdvYWwgYXMg
Ym90aCBjbGllbnQvc2VydmVyIGFuZA0KZ2F0aGVyaW5nIG9waW5pb25zIGZyb20gTFNGLiBUaGUg
Y2xpZW50IGFuZCBzZXJ2ZXIgYXJlIHN0aWxsIHByZXR0eQ0KaW50ZXJ0d2luZWQuIEkgdGhpbmsg
aGF2aW5nIHRoZSBjbGllbnQgZ28gdXBzdHJlYW0gYW5kIHRoZW4gYmFzaW5nDQp0aGUgc2VydmVy
IG9uIHRvcCBhbiBpbi10cmVlIGNsaWVudCB3b3VsZCBtYWtlIHNlcnZlciBkZXZlbG9wbWVudA0K
bm90aWNlYWJseSBtb3JlIGRpZmZpY3VsdC4gVGhpbmtpbmcgb24gaXQgbW9yZSAtIEkgZG9uJ3Qg
dGhpbmsNCnVwc3RyZWFtaW5nIHRoZSBzZXJ2ZXIgaXMgbW9yZSBhbWJpdGlvdXMgdGhhbiB0aGUg
Y2xpZW50LiBXZQ0KaGF2ZSBtb3JlIG9mIGEgcHJvY2VzcyBwcm9ibGVtIHRoYW4gYSBjb2RlIHBy
b2JsZW0uIEFuZCBJIGRvbid0DQp0aGluayB0aGUgc2VydmVyIGlzIGluIHBhcnRpY3VsYXJseSBi
YWQgc2hhcGUuDQoNCj4NCj4gTmVpbEJyb3duDQo+DQoNClRpbSBEYXkNCg0KX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KbHVzdHJlLWRldmVsIG1haWxpbmcg
bGlzdApsdXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZwpodHRwOi8vbGlzdHMubHVzdHJlLm9y
Zy9saXN0aW5mby5jZ2kvbHVzdHJlLWRldmVsLWx1c3RyZS5vcmcK
