Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 1F15FC02192
	for <lustre-devel@archiver.kernel.org>; Mon,  3 Feb 2025 17:33:55 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Ymtrn1Cv1z20th;
	Mon, 03 Feb 2025 09:33:45 -0800 (PST)
Received: from smtp-fw-2101.amazon.com (smtp-fw-2101.amazon.com [72.21.196.25])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Ymtrc5mCkz1xNc
 for <lustre-devel@lists.lustre.org>; Mon, 03 Feb 2025 09:33:36 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
 t=1738604018; x=1770140018;
 h=from:to:cc:date:message-id:references:in-reply-to:
 content-id:content-transfer-encoding:mime-version:subject;
 bh=gV9OXSptYX82o6mi2+t+tAnOSqqkpVD20/CF4WlyO3A=;
 b=Y650FshKyLP7URUHVqov4MySZDQVOHJvfeOL/81wIXohD1F28FiTLhMt
 2bh7xlcq1aPCcQBhevg1+YhzNPcUjdrJLrSOtHRLtBNIOil5WM/9iPweI
 lugKV4Bb6LpAmTMuni1CphqMtO6ZN/pjELJphXXKscqK4LMwc6TIgcBl0 I=;
X-IronPort-AV: E=Sophos;i="6.13,256,1732579200"; d="scan'208";a="463689420"
Thread-Topic: Re: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Received: from iad12-co-svc-p1-lb1-vlan3.amazon.com (HELO
 smtpout.prod.us-east-1.prod.farcaster.email.amazon.dev) ([10.43.8.6])
 by smtp-border-fw-2101.iad2.amazon.com with
 ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 03 Feb 2025 17:33:36 +0000
Received: from EX19MTAUEA002.ant.amazon.com [10.0.29.78:44299]
 by smtpin.naws.us-east-1.prod.farcaster.email.amazon.dev [10.0.61.141:2525]
 with esmtp (Farcaster)
 id 19f3790e-4077-41b0-8e02-a0d25d871c46; Mon, 3 Feb 2025 17:33:35 +0000 (UTC)
X-Farcaster-Flow-ID: 19f3790e-4077-41b0-8e02-a0d25d871c46
Received: from EX19D017UEA004.ant.amazon.com (10.252.134.70) by
 EX19MTAUEA002.ant.amazon.com (10.252.134.9) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.39;
 Mon, 3 Feb 2025 17:33:34 +0000
Received: from EX19D017UEA001.ant.amazon.com (10.252.134.93) by
 EX19D017UEA004.ant.amazon.com (10.252.134.70) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.39;
 Mon, 3 Feb 2025 17:33:34 +0000
Received: from EX19D017UEA001.ant.amazon.com ([fe80::bffb:623f:af5e:ebed]) by
 EX19D017UEA001.ant.amazon.com ([fe80::bffb:623f:af5e:ebed%3]) with
 mapi id 15.02.1258.039; Mon, 3 Feb 2025 17:33:34 +0000
From: "Day, Timothy" <timday@amazon.com>
To: NeilBrown <neilb@suse.de>, Alexey Lyahkov <alexey.lyashkov@gmail.com>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Index: AQHbdPzi17pIzYLeSkK1vD9oGPfqILM1hbQA
Date: Mon, 3 Feb 2025 17:33:34 +0000
Message-ID: <587A3C5F-5BA5-48E4-8F36-B368312FD7E6@amazon.com>
References: <660D26F8-92F1-45AD-803A-5AD47988640E@gmail.com>
 <173845071649.22054.5753395310812419468@noble.neil.brown.name>
In-Reply-To: <173845071649.22054.5753395310812419468@noble.neil.brown.name>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [10.252.141.28]
Content-ID: <A5705009F021DB4D9C1E1B7FE3CB0F9D@amazon.com>
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

PiBQb3J0aW5nIHRvIHVwc3RyZWFtIGRvZXNuJ3Qgd29yay4gVGhlIG1vdGl2YXRpb24gaXNuJ3Qg
c3Ryb25nIGVub3VnaA0KPiBhbmQgcGVvcGxlIGxlYXZlIGl0IHRoZW4gZm9yZ2V0IGl0IGFuZCB5
b3UgZ2V0IHRvbyBtdWNoIGRpdmVyZ2VuY2UgYW5kDQo+IGl0IGJlY29tZSBoYXJkZXIgc28gcGVv
cGxlIGRvIGl0IGV2ZW4gbGVzcy4gUGVvcGxlIGhhdmUgdHJpZWQuIFBlb3BsZQ0KPiBoYXZlIGZh
aWxlZC4NCj4NCj4gQmFja3BvcnRpbmcgZnJvbSB1cHN0cmVhbSB0byBhbiBvbGRlciBrZXJuZWwg
aXNuJ3QgdGhhdCBoYXJkLiBJIGRvIGENCj4gbG90IG9mIGl0IGFuZCB3aXRoIHRoZSByaWdodCB0
b29scyBpdCBpcyBtb3N0bHkgZWFzeS4gT25lIG9mIHRoZQ0KPiBiaWdnZXN0IGRpZmZpY3VsdGll
cyBpcyB3aGVuIHdlIHRyeSB0byBiYWNrcG9ydCBvbmx5IGEgc2VsZWN0aW9uIG9mDQo+IHBhdGNo
ZXMgYmVjYXVzZSB3ZSBtaWdodCBtaXNzIGFuIGltcG9ydGFudCBkZXBlbmRlbmN5LiBTb21ldGlt
ZXMgaXQgaXMNCj4gd29ydGggaXQgdG8gYXZvaWQgY2h1cm4sIHNvbWV0aW1lIGl0IGlzIGJlc3Qg
dG8gYXBwbHkgZXZlcnl0aGluZw0KPiByZWxldmFudC4gSSBhc3N1bWUgdGhhdCBmb3IgdGhlIHNl
bGVjdGlvbiBvZiBrZXJuZWxzIHRoYXQgd2hhbWNsb3VkIChvcg0KPiB3aG9ldmVyKSB3YW50IHRv
IHN1cHBvcnQsIHRoZXkgd291bGQgYmFja3BvcnQgZXZlcnl0aGluZyB0aGF0IGNvdWxkDQo+IGFw
cGx5LiBJIHRoaW5rIHRoYXQgd291bGQgYmUgbGFyZ2VseSBtZWNoYW5pY2FsLg0KPg0KPiBNYXli
ZSBpdCB3b3VsZCBiZSBnb29kIGZvciBtZSB0byBwYWludCBhIG1vcmUgZGV0YWlscyBwaWN0dXJl
IG9mIHdoYXQgSQ0KPiBpbWFnaW5lIHdvdWxkIGhhcHBlbiAtIGFzc3VtaW5nIHdlIGRvIHRha2Ug
dGhlIHBhdGggb2YgbGFuZGluZyBhbGwgb2YNCj4gbHVzdHJlLCBib3RoIGNsaWVudCBhbmQgc2Vy
dmVyLCB1cHN0cmVhbS4NCj4NCj4gLSB3ZSB3b3VsZCBjaGFuZ2UgdGhlIGtlcm5lbCBjb2RlIGlu
IGx1c3RyZS1yZWxlYXNlIHNvIHRoYXQgaXQgd2FzDQo+IGV4YWN0bHkgd2hhdCB3ZSBwbGFuIHRv
IHN1Ym1pdCB1cHN0cmVhbS4NCj4gLSB3ZSBzdWJtaXQgaXQgYW5kIG9uY2UgYWNjZXB0ZWQgd2Ug
aGF2ZSBpZGVudGljYWwgY29kZSBpbiB1cHN0cmVhbQ0KPiBsaW51eCBhbmQgbHVzdHJlLXJlbGVh
c2UNCj4gLSB3ZSBmb3JrIGx1c3RyZS1yZWxlYXNlIHRvIGEgbmV3IHBhY2thZ2UgY2FsbGVkIChl
LmcuKSBsdXN0cmUtdG9vbHMgYW5kDQo+IHJlbW92ZSBhbGwga2VybmVsIGNvZGUgbGVhdmluZyBq
dXN0IHV0aWxzIGFuZCBkb2N1bWVudGF0aW9uIGFuZA0KPiB0ZXN0IGNvZGUuIFRoZSBraW5vZGUu
YyBrZXJuZWwgbW9kdWxlIHRoYXQgaXMgaW4gbHVzdHJlL3Rlc3RzL2tlcm5lbC8NCj4gd291bGQg
bmVlZCB0byBnbyB1cHN0cmVhbSB3aXRoIHRoZSByZXN0IG9mIHRoZSBrZXJuZWwgY29kZSBJIHRo
aW5rLg0KPiBsdXN0cmUtdG9vbHMgd291bGQgYmUgZWFzaWx5IGFjY2Vzc2libGUgYW5kIGJ1aWxk
YWJsZSBieSBhbnlvbmUgd2hvDQo+IHdhbnRzIHRvIHRlc3QgbHVzdHJlDQo+IC0gd2UgZm9yayBs
dXN0cmUtcmVsZWFzZSB0byBhbm90aGVyIG5ldyBwYWNrYWdlIGx1c3RyZS1iYWNrcG9ydHMNCj4g
YW5kIHJlbW92ZSBhbGwgbm9uLWtlcm5lbCBjb2RlIGZyb20gdGhlcmUuIFdlIGNvbmZpZ3VyZSBp
dCB0byBidWlsZA0KPiBvdXQtb2YtdHJlZSBtb2R1bGVzIHdpdGggbmFtZXMgbGlrZSAiYmFja3Bv
cnQtbHVzdHJlIiAiYmFja3BvcnQtbG5ldCINCj4gYW5kIHByb3ZpZGUgbW9kcHJvYmUuY29uZiBm
aWxlcyB0aGF0IGFsaWFzIHRoZSBzdGFuZGFyZCBuYW1lcyB0bw0KPiB0aGVzZS4gVGhhdCBzaG91
bGQgYWxsb3cgdG8gb3Zlci1yaWRlIHRoZSBkaXN0cmlidXRlZCBtb2R1bGVzIChpZg0KPiBhbnkp
IHdoZW4gcGVvcGxlIGNob29zZSB0byB1c2UgYmFja3BvcnRzLg0KPiAtIHVwc3RyZWFtIGNvbW1p
dHMgd2hpY2ggdG91Y2ggbHVzdHJlIG9yIGxuZXQgYXJlIGF1dG9tYXRpY2FsbHkgYWRkIHRvDQo+
IGx1c3RyZS1iYWNrcG9ydHMgYW5kIHNvbWVvbmUgaXMgbm90aWZpZWQgdG8gaGVscCB3aGVuIHRo
ZXkgZG9uJ3QgYXBwbHkNCj4NCj4gV2l0aCB0aGlzOg0KPiBBbnlvbmUgd2hvIHdhbnRzIHRvIHRl
c3Qgb3IgdXNlIHRoZSBsdXN0cmUgaW5jbHVkZWQgd2l0aCBhIHBhcnRpY3VsYXINCj4ga2VybmVs
IGNhbiBkbyB3aXRoIHdpdGggb25seSB0aGUgbHVzdHJlLXRvb2xzIHBhY2thZ2UuIEFueW9uZSB3
aG8NCj4gd2FudHMgdG8gdXNlIHRoZSBsYXRlc3QgbHVzdHJlIGNvZGUgd2l0aCBhbiBvbGRlciBr
ZXJuZWwgY2FuIGJ1aWxkIGFuZA0KPiB1c2UgbHVzdHJlLWJhY2twb3J0cy4NCj4NCj4gVGhlcmUg
YXJlIHByb2JhYmx5IHJvdWdoLWVkZ2VzIHdpdGggdGhpcyBidXQgSSBzdXNwZWN0IHRoZXkgY2Fu
IGJlIGZpbGVkDQo+IGRvd24uDQoNCkkgZm91bmQgYW4gaW50ZXJlc3RpbmcgZGF0YSBwb2ludC4g
VkFTVCBzZWVtcyB0byB1c2UgYW4gdXBzdHJlYW0gTkZTDQpjbGllbnQgZnJvbSBhbiBMVFMga2Vy
bmVsIFsxXS4gVGhleSBoYXZlIGEgY29tcGF0IGxheWVyIHRvIHJ1biB0aGF0IGNsaWVudA0Kb24g
b2xkZXIga2VybmVscy4gVGhhdCdzIGVzc2VudGlhbGx5IHdoYXQgTHVzdHJlIHdvdWxkIGJlIGRv
aW5nLiBUaGV5DQphbHNvIHN1cHBvcnQgTWVsbGFub3gvR0RTIHdpdGggdGhpcyBjbGllbnQuIFlv
dSBjYW4gc2VlIGV4YWN0bHkgaG93DQp0aGV5IGRpZCBpdCBieSBkb3dubG9hZGluZyB0aGUgdGFy
YmFsbC4gRXZlbiBhIGxhcmdlIGNoYW5nZSBsaWtlIGZvbGlvDQpkaWRu4oCZdCBzZWVtIHRvIGhh
dmUgYSBodWdlIGltcGFjdCBvbiB0aGUgY29kZS4gSnVzdCBhIGxpdHRsZSBiaXQgb2YNCiNpZmRl
ZidpbmcuDQoNClNvIGFuIGFwcHJvYWNoIGxpa2UgdGhpcyBpcyBmZWFzaWJsZS4NCg0KWzFdIGh0
dHBzOi8vdmFzdG5mcy52YXN0ZGF0YS5jb20vZG9jcy80LjAvZG93bmxvYWQuaHRtbA0KDQpfX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpsdXN0cmUtZGV2ZWwg
bWFpbGluZyBsaXN0Cmx1c3RyZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnCmh0dHA6Ly9saXN0cy5s
dXN0cmUub3JnL2xpc3RpbmZvLmNnaS9sdXN0cmUtZGV2ZWwtbHVzdHJlLm9yZwo=
