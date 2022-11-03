Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id DA6D2C433FE
	for <lustre-devel@archiver.kernel.org>; Thu,  3 Nov 2022 15:57:43 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4N37gc5N8Xz1wZk;
	Thu,  3 Nov 2022 08:57:32 -0700 (PDT)
Received: from smtp-fw-9103.amazon.com (smtp-fw-9103.amazon.com
 [207.171.188.200])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4N37gS02Rcz1wL9
 for <lustre-devel@lists.lustre.org>; Thu,  3 Nov 2022 08:57:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
 t=1667491044; x=1699027044; h=from:to:subject:date:message-id:
 content-transfer-encoding:mime-version;
 bh=xNGAbF1HydL/y3uWjhmXB30rziZDr80QAqnBj5BLXDA=;
 b=XdjwWhbfawL0btCW23x1+tqWZmUEKospB60XAdWCA2TvjUXKKH3vCLua
 x7TMOHEaDFTxGjrkvhhBma1HAzkErFLn6CqG8cUzNeCeID1C7BcJExR3g
 /42U7wZeai4WFdvOZoJTQw0TN+8anQeuRuH1Srjv7y14Ii0SkTlPbISBz g=;
X-IronPort-AV: E=Sophos;i="5.96,134,1665446400"; d="scan'208";a="1070394759"
Received: from pdx4-co-svc-p1-lb2-vlan3.amazon.com (HELO
 email-inbound-relay-pdx-2b-m6i4x-f253a3a3.us-west-2.amazon.com)
 ([10.25.36.214]) by smtp-border-fw-9103.sea19.amazon.com with
 ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 03 Nov 2022 15:57:14 +0000
Received: from EX13D01EUA001.ant.amazon.com
 (pdx1-ws-svc-p6-lb9-vlan2.pdx.amazon.com [10.236.137.194])
 by email-inbound-relay-pdx-2b-m6i4x-f253a3a3.us-west-2.amazon.com (Postfix)
 with ESMTPS id 55A1381D02; Thu,  3 Nov 2022 15:57:14 +0000 (UTC)
Received: from EX19D007EUA004.ant.amazon.com (10.252.50.76) by
 EX13D01EUA001.ant.amazon.com (10.43.165.121) with Microsoft SMTP Server (TLS)
 id 15.0.1497.42; Thu, 3 Nov 2022 15:57:13 +0000
Received: from EX19D007EUA004.ant.amazon.com (10.252.50.76) by
 EX19D007EUA004.ant.amazon.com (10.252.50.76) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.1118.15; Thu, 3 Nov 2022 15:57:12 +0000
Received: from EX19D007EUA004.ant.amazon.com ([fe80::30f7:c558:653e:6ed9]) by
 EX19D007EUA004.ant.amazon.com ([fe80::30f7:c558:653e:6ed9%3]) with
 mapi id 15.02.1118.015; Thu, 3 Nov 2022 15:57:12 +0000
To: "Simmons, James" <simmonsja@ornl.gov>, "lustre-devel@lists.lustre.org"
 <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] lnet selftest using large NIDs (16 byte)
Thread-Index: AdjvmzqoYatDxWt7SmSoSgMZ4pVxnw==
Date: Thu, 3 Nov 2022 15:57:12 +0000
Message-ID: <a775921addbf4469bacf8a9f4d0145ff@amazon.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [10.85.143.175]
MIME-Version: 1.0
Subject: [lustre-devel] lnet selftest using large NIDs (16 byte)
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
From: "Yitschak, Yehuda via lustre-devel" <lustre-devel@lists.lustre.org>
Reply-To: "Yitschak, Yehuda" <yehuday@amazon.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

DQo+PkhlbGxvIA0KPj4NCj4+SSBhbSB3b3JraW5nIG9uIGEgUG9DIGZvciBhIG5ldyBMTkQgd2hp
Y2ggbmVlZCB0byB1c2UgYSAxNiBieXRlcyBOSUQgYWRkcmVzcw0KPj5JIGFtIGN1cnJlbnRseSBm
YWNpbmcgaXNzdWVzIGFkZGluZyBhIDE2Ynl0ZSBOSUQgdG8gTG5ldCBzZWxmdGVzdCBzaW5jZSBp
dCBvbmx5IGhhbmRsZXMgNCBieXRlIE5JRHMNCj4+DQo+PkFyZSB0aGVyZSBhbnkgcGF0Y2hlcyBv
ciBXSVAgdG8gYWRkIDE2IGJ5dGUgTklEIHN1cHBvcnQgdG8gTFNUID8gDQo+WWVzLCB0aGVyZSBp
cyBidXQgaXTigJlzIHVuZGVyIGN1cnJlbnQgZGV2ZWxvcG1lbnQuIFRvIHRyeSBpdCBvdXQgeW91
IG5lZWQgdGhlIGxhdGVzdCBMdXN0cmUgY29kZSBwbHVzIGEgYnVuY2ggb2YgcGF0Y2hlcy4NCj5Z
b3UgY2FuIHNlZSB3aGVyZSB3ZSBhcmUgYXQgdGhpcyBsaW5rIGh0dHBzOi8vamlyYS53aGFtY2xv
dWQuY29tL2Jyb3dzZS9MVS0xMDM5MS4NCj4NCj5TaW5jZSBnb2luZyB0aHJvdWdoIHRoZSB0aWNr
ZXRzIGlzIGdvaW5nIHRvIGJlIGEgbG90LCBJIGNhbiBnaXZlIHlvdSBhIHF1aWNrIHN1bW1hcnku
IFRoZSBiYXNpYyBpbmZyYXN0cnVjdHVyZSBpcyBpbiB0aGUNCj5jb3JlIExOZXQgY29kZSBidXQg
dGhlIGJpZyBjaGFuZ2VzIG5lZWRlZCBhcmUgdGhlIHdpcmUgcHJvdG9jb2wgaGVhZGVycyBhbmQg
dXNlciBsYW5kIGludGVyZmFjZSB0b29scy4gTm90ZSBoYXZpbmcNCj5MdXN0cmUgdXNpbmcgbGFy
Z2UgTklEUyBpcyBhbm90aGVyIHNldCBvZiB0aWNrZXRzIHdoaWNoIGFyZSBub3QgdGhlcmUgeWV0
Lg0KDQpTdGlsbCBsZWFybmluZyBteSB3YXkgdGhyb3VnaCBMdXN0cmUg8J+Yii4gDQp5b3UgbWVh
biBhbGwgdGhlIHJlcXVpcmVkIHdvcmsgaXMgY292ZXJlZCBieSBXSVAgcGF0Y2hlcyBvciBzb21l
IHN0dWZmIGFyZSBzdGlsbCBub3QgY29kZWQgPw0KDQo+IEl0IGRvZXNu4oCZdCBzb3VuZCBsaWtl
IHlvdSBhcmUgbG9va2luZyBmb3IgYSBmdW5jdGlvbmFsIGZpbGUgc3lzdGVtIG9uIHRvcCBvZiB5
b3VyIGludGVyY29ubmVjdCBhdCB0aGlzIHBvaW50Lg0KDQp5b3UgYXJlIHJpZ2h0LiBJIGFtIG1v
c3RseSB0cnlpbmcgdG8gc2VlIHRoZSBCVyBwb3RlbnRpYWwgdXNpbmcgTG5ldCBzZWxmdGVzdC4N
CkkgYW0gY3VycmVudGx5IGhhY2tpbmcgdGhlIGFsbCBhZGRyZXNzaW5nIHRoaW5nIGJ1dCBsb25n
IHRlcm0gd2lsbCBwcm9iYWJseSBuZWVkIHRoZSBsYXJnZSBOSUQgc29sdXRpb24uDQoNCj4NCj5G
b3IgdGhlIHVzZXIgbGFuZCB0b29scyB3ZSBuZWVkIHRvIHVwZGF0ZSB0aGVtIHRvIHN1cHBvcnQg
bGFyZ2UgTklEIGFkZHJlc3NpbmcuIMKgVGhlIG1haW4gZnVuY3Rpb25hbGl0eSB3ZSBuZWVkDQo+
aXMgc3VwcG9ydCBvZiBzZXR1cCBvZiB0aGUgbG9jYWwgTkksIHBlZXJzLCBhbmQgcGluZ3MuIFdl
IGRvIG5lZWQgcm91dGVycyBhcyB3ZWxsIGJ1dCBpdOKAmXMgbm90IGEgaGFyZCByZXF1aXJlbWVu
dCBhdA0KPnRoaXMgcG9pbnQuIEEgcGF0Y2ggdG8gc3VwcG9ydCBsYXJnZSBOSUQgZm9yIGxvY2Fs
IE5JRCBpcyBpbiB0aGUgbWFzdGVyLW5leHQgYnJhbmNoIHNvIGlmIG91ciBnYXRlIGtlZXBlciBp
cyBoYXBweQ0KPkl0IHdpbGwgbGFuZCBpbiB0aGUgY29taW5nIHdlZWsuIFRoZSBwYXRjaCBpcyBh
dA0KPg0KPmh0dHBzOi8vcmV2aWV3LndoYW1jbG91ZC5jb20vYy9mcy9sdXN0cmUtcmVsZWFzZS8r
LzQ4ODE0DQo+DQo+V2l0aCB0aGlzIHBhdGNoIHlvdSBjYW4gcnVuIGxjdGwgbGlzdF9uaWRzIGFu
ZCBzZWUgdGhhdCBsYXJnZSBOSURzIHlvdSBzZXR1cC4gTm90ZSBJIGhhdmVu4oCZdCBmaW5pc2gg
bG5ldGN0bCBuZXQgc2hvdw0KPnN1cHBvcnQgc2luY2UgaXQgZ2l2ZXMgbW9yZSBpbi1kZXB0aCBp
bmZvIGNvbXBhcmVkIHRvIGxjdGwgbGlzdF9uaWRzLiBJIGhhdmUgYSB1bmZpbmlzaGVkIHBhdGNo
IGZvciB0aGF0IHdvcmsuIEkgYWxzbw0KPmhhdmUgYSBsY3RsIHBpbmcgLyBsbmV0Y3RsIHBpbmcg
cGF0Y2ggdG8gc3VwcG9ydCBsYXJnZSBOSURzIGluIHRoZSB3b3JrLiBJdCBoYXMgYSBmZXcgYnVn
cyBJIG5lZWQgdG8gd29yayBvdXQgYnV0IGl0cw0KPnNvbWV3aGF0IHdvcmtpbmcuIExOZXQgc2Vs
ZnRlc3QgYWxzbyBuZWVkcyB0byBiZSByZXdvcmtlZCB0byBzdXBwb3J0IGxhcmdlIE5JRHMuIEkg
aGF2ZSBhIHBhdGNoIHRvIHN0YXJ0IHRoaXMNCj5zdXBwb3J0Lg0KPg0KPmh0dHBzOi8vcmV2aWV3
LndoYW1jbG91ZC5jb20vYy9mcy9sdXN0cmUtcmVsZWFzZS8rLzQzMjk4DQo+DQo+SSBhbHNvIGhh
dmUgYSBsb2NhbCBwYXRjaCBmb3IgbG5ldCBzZWxmdGVzdCBncm91cCBoYW5kbGluZyB0aGF0IGlz
IG5vdCBmaW5pc2hlZC4gV2l0aCB0aGUgYWJpbGl0eSB0byBzZXQgdXAgbG9jYWwgTkkNCj53ZSBj
YW4gdGhlbiBhbGxvdyBzZWxmdGVzdCBncm91cCBzZXR1cC4gDQo+DQo+Rm9yIHRoZSB3aXJlIHBy
b3RvY29sIHdlIG5lZWQgdG8gc3VwcG9ydCBwaW5ncyBhbmQgdHJhbnNmZXJzIGkuZSBQVVQsIEdF
VCBldGMuIFBpbmcgaGFzIGJlZW4gaGVhdmlseSB3b3JrZWQNCj5vbiBhbmQgSSBoYXZlIGJlZW4g
dGVzdGluZyBpdCB3aXRoIG15IGluY29tcGxldGUgbGFyZ2UgTklEIHBpbmcgdG9vbCB1cGRhdGUu
IFRoZSBwYXRjaCBzZXJpZXMgaXMgaGVyZToNCj4NCj5odHRwczovL3Jldmlldy53aGFtY2xvdWQu
Y29tL2MvZnMvbHVzdHJlLXJlbGVhc2UvKy80NDYzNQ0KPg0KPllvdSB3aWxsIHNlZSBpbiBnZXJy
aXQgdGhlIHBhdGNoIHNldCBuZWVkZWQgdG8gZ2V0IHBpbmdzIHdvcmtpbmcuIFRoZSByZXN0IG9m
IExOZXQgZGF0YSB0cmFuc2ZlciBwcm90b2NvbA0KPndpbGwgcmVxdWlyZSBzZXR0aW5nIHVwIHRo
ZSBwcm9wZXIgd2lyZSBoZWFkZXIuIFRoZSBuZXcgd2lyZSBoZWFkZXJzIGFscmVhZHkgZXhpc3Qg
YnV0IGFyZSBub3Qgc2VudCBvdmVyDQo+dGhlIHdpcmUgYXQgdGhpcyBwb2ludC4gDQo+DQo+QXQg
dGhpcyBwb2ludCB0aGUgZ29hbCB3aWxsIGJlIHRvIGdldCBsbmV0IHNlbGZ0ZXN0IHRvIGRvIHBp
bmcgdGVzdCBvdmVyIHRoZSB3aXJlIGJldHdlZW4gdHdvIGxhcmdlIE5JRC4gSWYNCj55b3UgYXJl
IGludGVyZXN0ZWQgaW4gdGhpcyB3b3JrIGxldCBtZSBrbm93LiBJdCB3b3VsZCBiZSBncmVhdCBp
ZiB5b3UgY2FuIGJlIGFuIGVhcmx5IHRlc3Rlci4gSXQgd291bGQgYmUNCj5uaWNlIHRvIGdldCBm
ZWVkYmFjayBvbiB0aGlzIHdvcmsuDQoNCkkgd291bGQgYmUgZ2xhZCB0byB0cnkgaXQuIEl0IG1p
Z2h0IHRha2UgbWUgYSB3aGlsZSBiZWNhdXNlIEknbSBjdXJyZW50bHkgYmFzZWQgb24gMi4xMiBh
bmQgcmViYXNpbmcgbWlnaHQgYmUgYSBwYWluLg0KQnV0IEknbGwgZGVmaW5pdGVseSBtYWtlIHNv
bWUgdGltZSBmb3IgdGhhdCBhcyBzb29uIGFzIG15IExORCBjb2RlIHN0YWJpbGl6ZXMuICANCg0K
PldlIGhhdmUgYSBzbGFjayBjaGFubmVsIHdoZXJlIHdlIGhhdmUgZGlzY3Vzc2lvbnMgb24gdGhl
IHByb2dyZXNzDQo+b2YgdGhpcyB3b3JrLiBZb3Ugd2lsbCBoYXZlIHF1ZXN0aW9ucyBhYm91dCB0
aGUgY2hhbmdlcyBuZWVkZWQgdG8gcHJvcGVybHkgc3VwcG9ydCB5b3VyIExORCBkcml2ZXIgdGhl
IA0KPnNsYWNrIGNoYW5uZWwgaXMgdGhlIGJlc3QgcGxhY2UgdG8gYXNrIHRob3NlLiBGZWVsIGZy
ZWUgdG8gYXNrIGhlcmUgYXMgd2VsbCBpZiB5b3UgcHJlZmVyLiBTb21lb25lIHdpbGwgDQo+YW5z
d2VyLiBMZXQgbWUga25vdyBpZiB5b3Ugd2FudCB0byBqb2luIHRoZSBzbGFjayBjaGFubmVsLg0K
DQpTdXJlLCBJJ2xsIGJlIGhhcHB5IHRvIGpvaW4geW91ciBzbGFjayBjaGFubmVsLg0KVGhhbmtz
IGZvciB0aGUgYWxsIGluZm8gYW5kIHRoZSBzbGFjayBpbnZpdGUgISANCg0KWWVodWRhIA0KX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KbHVzdHJlLWRldmVs
IG1haWxpbmcgbGlzdApsdXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZwpodHRwOi8vbGlzdHMu
bHVzdHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRldmVsLWx1c3RyZS5vcmcK
