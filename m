Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A2BB2C02181
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Jan 2025 17:17:22 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YdW3M45Ksz1xPc;
	Wed, 22 Jan 2025 09:17:19 -0800 (PST)
Received: from smtp-fw-80007.amazon.com (smtp-fw-80007.amazon.com
 [99.78.197.218])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YdW3H0DZSz1wPR
 for <lustre-devel@lists.lustre.org>; Wed, 22 Jan 2025 09:17:15 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
 t=1737566235; x=1769102235;
 h=from:to:cc:date:message-id:references:in-reply-to:
 content-id:content-transfer-encoding:mime-version:subject;
 bh=h1wCO9z8mLG6vFxmTafc4qBGIXbZMbc5oKhwPACog1w=;
 b=T0foprqpWZsV2ZKcPHIFX9VcWxZJjN0uAG8O1DB2kTs4SpvfnPiezmTi
 NvaPbW8ZPnzp2lMoKzXXUb0IjdRyLkpeEN7JdV9oVevB1iuax8x7OZ3th
 RUSbXQoREptDQ68SO8gbUmJlUoohLflwK16JWX8BhsZ2JuT3hLpvgqW5b 8=;
X-IronPort-AV: E=Sophos;i="6.13,225,1732579200"; d="scan'208";a="371077238"
Thread-Topic: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Received: from pdx4-co-svc-p1-lb2-vlan2.amazon.com (HELO
 smtpout.prod.us-east-1.prod.farcaster.email.amazon.dev) ([10.25.36.210])
 by smtp-border-fw-80007.pdx80.corp.amazon.com with
 ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 22 Jan 2025 17:17:14 +0000
Received: from EX19MTAUEA002.ant.amazon.com [10.0.44.209:55816]
 by smtpin.naws.us-east-1.prod.farcaster.email.amazon.dev [10.0.4.122:2525]
 with esmtp (Farcaster)
 id 6c4ee7e8-0500-4328-b9df-f0d04cab6627; Wed, 22 Jan 2025 17:17:13 +0000 (UTC)
X-Farcaster-Flow-ID: 6c4ee7e8-0500-4328-b9df-f0d04cab6627
Received: from EX19D017UEA002.ant.amazon.com (10.252.134.77) by
 EX19MTAUEA002.ant.amazon.com (10.252.134.9) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.39;
 Wed, 22 Jan 2025 17:17:13 +0000
Received: from EX19D017UEA001.ant.amazon.com (10.252.134.93) by
 EX19D017UEA002.ant.amazon.com (10.252.134.77) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.39;
 Wed, 22 Jan 2025 17:17:12 +0000
Received: from EX19D017UEA001.ant.amazon.com ([fe80::bffb:623f:af5e:ebed]) by
 EX19D017UEA001.ant.amazon.com ([fe80::bffb:623f:af5e:ebed%3]) with
 mapi id 15.02.1258.039; Wed, 22 Jan 2025 17:17:12 +0000
From: "Day, Timothy" <timday@amazon.com>
To: Alexey Lyahkov <alexey.lyashkov@gmail.com>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Index: AQHbbL69uIfgJsGOtUiS+oiimL+WYrMitaMA
Date: Wed, 22 Jan 2025 17:17:12 +0000
Message-ID: <DC116704-CE6F-452B-BC75-1DECECD7B32B@amazon.com>
References: <3139EEF5-91BF-4F8E-A112-1D66455AE3D2@amazon.com>
 <3E182046-BEC0-4C44-953A-E0C7024D30B8@amazon.com>
 <3685F420-52D1-46C8-9A04-666B7FFF45F4@gmail.com>
In-Reply-To: <3685F420-52D1-46C8-9A04-666B7FFF45F4@gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [10.106.179.23]
Content-ID: <BD573FD853950E429CAEDD1043EE8AB6@amazon.com>
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

PiBPbiAxLzIyLzI1LCA2OjE0IEFNLCAiQWxleGV5IEx5YWhrb3YiIDxhbGV4ZXkubHlhc2hrb3ZA
Z21haWwuY29tIDxtYWlsdG86YWxleGV5Lmx5YXNoa292QGdtYWlsLmNvbT4+IHdyb3RlOg0KPg0K
PiBUaW1vdGh5LA0KPg0KPiA+IDIyINGP0L3Qsi4gMjAyNSDQsy4sINCyIDA5OjM1LCBEYXksIFRp
bW90aHkgPHRpbWRheUBhbWF6b24uY29tIDxtYWlsdG86dGltZGF5QGFtYXpvbi5jb20+PiDQvdCw
0L/QuNGB0LDQuyjQsCk6DQo+ID4NCj4gPiBJJ3ZlIGNyZWF0ZWQgYSBzZWNvbmQgZHJhZnQgb2Yg
dGhlIHRvcGljIGZvciBMU0YvTU0uIEkgdHJpZWQNCj4gPiB0byBpbmNsdWRlIGV2ZXJ5b25lJ3Mg
ZmVlZGJhY2suIEl0J3MgYXQgdGhlIGVuZCBvZiB0aGUgZW1haWwuDQo+ID4NCj4gPiBCZWZvcmUg
dGhhdCwgSSB3YW50ZWQgdG8gZWxhYm9yYXRlIG9uIE5laWwncyBpZGVhIGFib3V0IHVwZGF0aW5n
DQo+ID4gb3VyIGRldmVsb3BtZW50IG1vZGVsIHRvIGFuIHVwc3RyZWFtLWZvY3VzZWQgbW9kZWwu
IEZvciB1cHN0cmVhbWluZw0KPiA+IHRvIHdvcmssIHRoZSBub3JtYWwgZGV2ZWxvcG1lbnQgZmxv
dyBoYXMgdG8gZ2VuZXJhdGUgcGF0Y2hlcyB0byBtYWlubGluZQ0KPiA+IExpbnV4IC0gd2hpbGUg
c3RpbGwgc3VwcG9ydGluZyB0aGUgZGlzdHJvIGtlcm5lbHMgdGhhdCBtb3N0IHBlb3BsZSB1c2UN
Cj4gPiB0byBydW4gTHVzdHJlLiBJIHRoaW5rIHdlIGNhbiBnZXQgdGhpcyBwb2ludCBpbiBzdGFn
ZXMuIEkndmUgcHJvdmlkZWQNCj4gPiBhIGhpZ2gtbGV2ZWwgb3ZlcnZpZXcgaW4gdGhlIG5leHQg
c2VjdGlvbi4gVGhpcyB3b24ndCBiZSB3aXRob3V0DQo+ID4gY2hhbGxlbmdlcyAtIGJ1dCB0aGUg
bWFqb3JpdHkgb2YgdGhlIHRyYW5zaXRpb24gY291bGQgaGFwcGVuIHdpdGhvdXQNCj4gPiBpbnRl
cnJ1cHRpbmcgZmVhdHVyZSB3b3JrIG9yIG5vcm1hbCBkZXZlbG9wbWVudC4NCj4gPiANCj4NCj4g
Q2FuIHlvdSBleHBsYWluIGhvdyBMdXN0cmUgcGxhdGZvcm0gZnJhZ21lbnRhdGlvbiB3aWxsIGF2
b2lkID8NCj4NCj4NCj4gSSBwb3N0ZWQgZXhhbXBsZSBlYXJseSwNCj4gRGlzdHJvIGhhdmUgbG9j
a2VkIGEgTHVzdHJlIHZlcnNpb24gaW4gcmVsZWFzZSB0aW1lLiBCdXQgTHVzdHJlIHNlcnZlciBo
YXZlIGEgbGltaXRlZCBjb21wYXRpYmlsaXR5IC0gaW4gbW9zdCBjYXNlcyArLy0gMeKApjIgcmVs
ZWFzZXMgZ3VhcmF0ZWUgdG8gYmUgY29ubmVjdGVkLiBTbyBzdGFsZSBhbmQgYWdlZCBjbGllbnQg
d2lsbCBsaXZlIGluIHRoZSBkaXN0cmlidXRpb24ga2VybmVsLiBBbmQgaXQgd2lsbCBkb27igJl0
IHdvcmsgZm9yIG1vZGVybiBzZXJ2ZXJzLg0KPiBpdOKAmXMgdmVyeSBlYXN5IE9uY2UgZGlzdHJp
YnV0aW9uIGxpdmUgdGltZSB+OHkuIFNvIGNsaWVudHMgd2lsbCBiZSBuZWVkcyB0byBkcm9wIGlu
IGtlcm5lbCBsdXN0cmUgY2xpZW50IHN1cHBvcnQgYW5kIGluc3RhbGwgYSBsdXN0cmUgY2xpZW50
IGZyb20gYW4gZXh0ZXJuYWwgc291cmNlcy4gV2hpY2ggaGF2ZSBubyBkaWZmZXJlbmNlcyB3aXRo
IGN1cnJlbnQgc3RhdGUuDQo+IE5leHQgc3RlcCBpcyBzb3J0IG9mIGRpc3RyaWJ1dGlvbnMgd2hp
Y2ggaGF2ZSBhIGRpZmZlcmVudCBsdXN0cmUgdmVyc2lvbnMgd2hpY2ggbm90IGNvbXBhdGlibGUg
ZWFjaCB0byBvdGhlci4NCj4gQm90aCB0aGVzZSBpbmNyZWFzZSBhIHN1cHBvcnQgY29zdCAtIG9u
Y2UgbGFyZ2UgbnVtYmVyIHZlcnNpb25zIG5lZWRzIHN1cHBvcnRlZCwgc28gZGV2ZWxvcG1lbnQg
d2lsbCBkcm9wcyBhbmQgYWxsIHRpbWUgd2lsbCBzcGVudCB0byBzdXBwb3J0Lg0KDQpJIHRoaW5r
IHRoYXQncyBhIHJlYXNvbmFibGUgY29uY2Vybi4gSSBzcGVuZCBhIGxvdCBvZiB0aW1lIGRvaW5n
IGN1c3RvbWVyDQpzdXBwb3J0IGZvciBMdXN0cmU7IEkgZGVmaW5pdGVseSBkb24ndCB3YW50IHRv
IG1ha2UgdGhhdCBwYXJ0IG9mIG15IGpvYiBhbnkNCmhhcmRlciB0aGFuIGl0IGhhcyB0byBiZS4N
Cg0KSSdtIG15IHBlcnNvbmFsIGV4cGVyaWVuY2UsIEkndmUgc2VlbiAyLjEwIGFuZCAyLjE1IGlu
dGVyb3BlcmF0ZSB3ZWxsIHRvZ2V0aGVyLg0KVGhhdCBjb3ZlcnMgYSBnYXAgb2YgYXJvdW5kIH42
IHllYXJzIGF0IGxlYXN0LiBJZiBzb21lb25lIHN0dWNrIHdpdGggUkhFTDcsIHRoZQ0KZmlyc3Qg
Y2xpZW50IHRoZXkgY291bGQgdXNlIGlzIDIuNy4wIGFuZCB0aGUgbGFzdCBjbGllbnQgdGhleSBj
b3VsZCB1c2UgaXMgMi4xNi4wIFsxXS4NClNvIGlmIGEgY3VzdG9tZXIgZGlkbid0IHVwZGF0ZSBl
aXRoZXIgdGhlaXIgZGlzdHJvIG9yIGZpbGVzeXN0ZW0sIHRoZXkgY291bGQgdXNlIGFuDQp1cC10
by1kYXRlIEx1c3RyZSB2ZXJzaW9uIGZvciBhcm91bmQgMTAgeWVhcnMgY292ZXJpbmcgOSB2ZXJz
aW9ucy4gU28gSSB0aGluayB0aGVzZQ0KbGFyZ2UgdmVyc2lvbiBnYXBzIGFyZSBwb3NzaWJsZSB0
b2RheS4NCg0KVGhlcmUgaXMgYW4gaXNzdWUgaWYgZGlzdHJvcyBkb24ndCB3YW50IHRvIHVwZGF0
ZSB0aGVpciBjbGllbnRzLiBUaGF0J3Mgd2h5IHdlJ2xsDQpzdGlsbCBzdXBwb3J0IHJ1bm5pbmcg
bGF0ZXN0IEx1c3RyZSBvbiBvbGRlciBkaXN0cm9zLiBTcGVjaWZpY2FsbHksIGl0J2xsIGJlIHRo
ZSBMdXN0cmUNCmNvZGUgZnJvbSBhIG1haW5saW5lIGtlcm5lbCBjb21iaW5lZCB3aXRoIG91ciBs
dXN0cmVfY29tcGF0LyBjb21wYXRpYmlsaXR5DQpjb2RlLiBTbyBub3JtYWwgTHVzdHJlIHJlbGVh
c2VzIHdpbGwgYmUgZGVyaXZlZCBkaXJlY3RseSBmcm9tIHRoZSBpbi10cmVlIGtlcm5lbA0KY29k
ZS4gVGhpcyBwcm92aWRlcyBhIHBhdGggZm9yIHZlbmRvcnMgdG8gZGVwbG95IGJ1ZyBmaXhlcywg
Y3VzdG9tIGZlYXR1cmVzLCBhbmQNCmFsbG93cyB1c2VycyB0byBvcHRpb25hbGx5IHJ1biB0aGUg
bGF0ZXN0IGFuZCBncmVhdGVzdCBMdXN0cmUgY29kZS4NCg0KWzFdIEx1c3RyZSBjaGFuZ2Vsb2c6
IGh0dHBzOi8vZ2l0LndoYW1jbG91ZC5jb20vP3A9ZnMvbHVzdHJlLXJlbGVhc2UuZ2l0O2E9Ymxv
Yl9wbGFpbjtmPWx1c3RyZS9DaGFuZ2VMb2c7aGI9SEVBRA0KDQo+IEl0IHRoaXMgaXMgbm90IGVu
b3VnaCAtIGxldHMgb25lIG1vcmUuIEtlcm5lbCBBUEkgaXNu4oCZdCBzdGFibGUgZW5vdWdoIC0g
c28gbGFyZ2UgbnVtYmVyIHJlc291cmNlcyB3aWxsIGJlIG5lZWRzIHNwZW50IHRvIHNvbHZlIGVh
Y2gga2VybmVsIGNoYW5nZSBpbiBsdXN0cmUuIEN1cnJlbnRseSwgaXTigJlzIGluIHRoZSBiYWNr
Z3JvdW5kIGFuZCBkb27igJl0IGludGVycnVwdCBwcmltYXJ5IHdvcmsgZm9yIHN1cHBvcnRpbmcg
YW5kIGRldmVsb3BtZW50IGEgbmV3IEx1c3RyZSBmZWF0dXJlcy4NCj4NCj4gU28gdGhhdCBpcyBw
cm9ibGVtcyBmb3IgTHVzdHJlIHdvcmxkIC0gd2hhdCBpcyBiZW5lZml0cz8NCg0KQnkgdXBzdHJl
YW1pbmcgTHVzdHJlLCB3ZSdsbCBiZW5lZml0IGZyb20gZGV2ZWxvcGVycyB1cGRhdGluZyB0aGUg
a2VybmVsDQpBUEkgImZvciBmcmVlIi4gV2UgTHVzdHJlIHdhcyBpbiBzdGFnaW5nLywgdGhlcmUg
d2Fzbid0IGFzIG11Y2ggb2JsaWdhdGlvbg0KdG8ga2VlcCBMdXN0cmUgaW4gYSB3b3JraW5nIHN0
YXRlLiBCdXQgaWYgd2UgZ2V0IEx1c3RyZSBtZXJnZWQgcHJvcGVybHksDQpkZXZlbG9wZXIgd2ls
bCBub3QgYmUgYWJsZSB0byBtZXJnZSBjaGFuZ2VzIHRoYXQgYnJlYWsgTHVzdHJlLiBTbyB3ZSds
bA0KZ2V0IHN1cHBvcnQgZm9yIHRoZSBsYXRlc3QgYW5kIGdyZWF0ZXN0IGtlcm5lbHMgd2l0aCBs
ZXNzIGVmZm9ydC4gVGhhdCdzIG9uZQ0Kb2YgdGhlIG1haW4gYmVuZWZpdHMgb2YgdGhpcyBlZmZv
cnQuDQoNCldlIGFsc28gZ2V0IGJlbmVmaXQgZnJvbSBtb3JlIHNheSBvdmVyIHRoZSBmdXR1cmUg
b2YgdGhlIGtlcm5lbC4gQSBsb3QNCm9mIGRpZmZpY3VsdHkgd2l0aCB1cGRhdGluZyBMdXN0cmUg
Zm9yIG5ldyBrZXJuZWxzIGNvbWVzIHdoZW4gdXBzdHJlYW0NCmtlcm5lbCBkZXZlbG9wZXJzIGxv
Y2sgZG93biBzeW1ib2xzIG9yIGZlYXR1cmVzIHRvIGluLXRyZWUgbW9kdWxlcy4gVGhpcw0KY291
bGQgZ2V0IGV2ZW4gd29yc2UgaW4gdGhlIGZ1dHVyZSwgd2l0aCBzdHVmZiBsaWtlIHN5bWJvbCBu
YW1lc3BhY2VzIGdldA0KbW9yZSB1c2UgWzJdLg0KDQpFdmVuIGlmIG1vc3QgdXNlcnMgdXNlIHRo
ZSBvdXQtb2YtdHJlZSBiYWNrcG9ydGVkLWZyb20tbWFpbmxpbmUtTGludXgNCkx1c3RyZSByZWxl
YXNlLCBJIHRoaW5rIHdlJ2xsIHN0aWxsIGJlIGluIGEgc3Ryb25nZXIgcG9zaXRpb24gYWZ0ZXIN
CnVwc3RyZWFtaW5nLg0KDQpbMl0gaHR0cHM6Ly9sd24ubmV0L0FydGljbGVzLzc2MDA0NS8NCg0K
Pg0KPiBBbGV4DQo+DQoNClRpbSBEYXkNCg0KDQpfX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fXwpsdXN0cmUtZGV2ZWwgbWFpbGluZyBsaXN0Cmx1c3RyZS1kZXZl
bEBsaXN0cy5sdXN0cmUub3JnCmh0dHA6Ly9saXN0cy5sdXN0cmUub3JnL2xpc3RpbmZvLmNnaS9s
dXN0cmUtZGV2ZWwtbHVzdHJlLm9yZwo=
