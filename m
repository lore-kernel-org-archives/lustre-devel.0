Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C83D3C433F5
	for <lustre-devel@archiver.kernel.org>; Mon,  6 Dec 2021 20:45:06 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4EBC221F85E;
	Mon,  6 Dec 2021 12:45:06 -0800 (PST)
Received: from smtp-fw-80006.amazon.com (smtp-fw-80006.amazon.com
 [99.78.197.217])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 41DF23891FD
 for <lustre-devel@lists.lustre.org>; Wed, 24 Nov 2021 09:33:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.fr; i=@amazon.fr; q=dns/txt; s=amazon201209;
 t=1637775229; x=1669311229;
 h=from:to:subject:date:message-id:content-id:
 content-transfer-encoding:mime-version;
 bh=d7Keq/DDaAOI2tyce3gyUEDllRhUDwVfhAcJFZlvKcg=;
 b=msehL3HsdQI79pDSHDt6xnpkFWNEWzFVxRGJ1rRYZVInDulXeLEpdV1J
 pqH2Rm6qfqBbM88VqQE5gXlCOxkmYSbV3HjwFgDq2AzzqMtwKCDg7HgB3
 3o6P0zFKeGJHdwYGU9ajmSOZjBq6h2Cg5pmGY+migoO+sQIu8sS9EgDYo A=;
X-IronPort-AV: E=Sophos;i="5.87,260,1631577600"; d="scan'208";a="43981659"
Received: from pdx4-co-svc-p1-lb2-vlan3.amazon.com (HELO
 email-inbound-relay-pdx-1box-2b-eee1d651.us-west-2.amazon.com)
 ([10.25.36.214])
 by smtp-border-fw-80006.pdx80.corp.amazon.com with ESMTP;
 24 Nov 2021 17:33:31 +0000
Received: from EX13D21EUA001.ant.amazon.com
 (pdx1-ws-svc-p6-lb9-vlan3.pdx.amazon.com [10.236.137.198])
 by email-inbound-relay-pdx-1box-2b-eee1d651.us-west-2.amazon.com (Postfix)
 with ESMTPS id 050FE81115
 for <lustre-devel@lists.lustre.org>; Wed, 24 Nov 2021 17:33:31 +0000 (UTC)
Received: from EX13D21EUA004.ant.amazon.com (10.43.165.59) by
 EX13D21EUA001.ant.amazon.com (10.43.165.41) with Microsoft SMTP Server (TLS)
 id 15.0.1497.26; Wed, 24 Nov 2021 17:33:29 +0000
Received: from EX13D21EUA004.ant.amazon.com ([10.43.165.59]) by
 EX13D21EUA004.ant.amazon.com ([10.43.165.59]) with mapi id 15.00.1497.026;
 Wed, 24 Nov 2021 17:33:29 +0000
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: Recommendation for hsm_restore for directories
Thread-Index: AQHX4Vllf3Bwnicwgkmxm9xoW0myMA==
Date: Wed, 24 Nov 2021 17:33:29 +0000
Message-ID: <4A74832B-D0A9-435D-AF63-EA0ABF8D626E@amazon.com>
Accept-Language: fr-FR, en-US
Content-Language: fr-FR
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-exchange-transport-fromentityheader: Hosted
x-originating-ip: [10.43.164.131]
Content-ID: <D1D4FE425B4F854799146AC565F55935@amazon.com>
MIME-Version: 1.0
X-Mailman-Approved-At: Mon, 06 Dec 2021 12:45:04 -0800
Subject: [lustre-devel] Recommendation for hsm_restore for directories
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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
From: "Degremont, Aurelien via lustre-devel" <lustre-devel@lists.lustre.org>
Reply-To: "Degremont, Aurelien" <degremoa@amazon.fr>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

SGVsbG8gYWxsDQoNCkknbSBkb2luZyBzb21lIGVhcmx5IHdvcmsgdG93YXJkIGltcGxlbWVudGlu
ZyBhIGRpcmVjdG9yeS9uYW1lc3BhY2Ugc3VwcG9ydCBmb3IgTHVzdHJlL0hTTS4gVGhlIGlkZWEg
d291bGQgYmUgdG8gc3VwcG9ydCBzb21ldGhpbmcgc2ltaWxhciB0byBoc21fcmVzdG9yZS9oc21f
cmVsZWFzZSBidXQgZm9yIGRpcmVjdG9yaWVzLg0KDQpNeSBmaXJzdCB0aG91Z2h0IHdhcyBmb3Ig
dGhlIE1EVCB0byBub3QgZ3JhbnQgTERMTSBsb2NrIGZvciB0aGlzIGRpcmVjdG9yeSBhbmQgaG9s
ZCBpdCwgd2hpbGUgdGhlIGRpcmVjdG9yeSBpcyBnZXR0aW5nIHJlc3RvcmVkIGJ5IGNvcHl0b29s
LCBpbiBhIHNpbWlsYXIgZmFzaGlvbiB0aGFuIHdoYXQgaXMgZG9uZSBmb3IgZmlsZXMuIEJ1dCB0
aGUgaGFyZCBwYXJ0IGhlcmUsIGlzIHRvIGhhdmUgYSB3YXkgZm9yIGNvcHl0b29sIHRvIGFjY2Vz
cyB0aGUgZGlyZWN0b3J5IHdoaWxlIGl0cyBhY2Nlc3MgaXMgYWN0dWFsbHkgcHJldmVudGVkIGJ5
IHRoZSBhYm92ZSBsb2NraW5nLg0KUmVzdG9yaW5nIGEgZmlsZSBpcyB1c2luZyB0aGlzIHNtYXJ0
IHRyaWNrIG9mIHJlc3RvcmluZyBpdCBpbiBhIGRpZmZlcmVudCB0ZW1wb3JhcnkgZmlsZSBhbmQg
dXNpbmcgbGF5b3V0IHN3YXAgYXQgdGhlIGVuZCB0byBtb3ZlIGRhdGEgdG8gdGhlIGFjdHVhbCBy
ZWFsIGZpbGUuIEl0IGxvb2tzIGRpZmZpY3VsdCB0byBkbyB0aGUgc2FtZSB0aGluZyBoZXJlLg0K
DQpEbyB5b3UgaGF2ZSBhbnkgcmVjb21tZW5kYXRpb24gb24gdGhlIHJpZ2h0IHdheSB0byBmcmFt
ZSB0aGlzIGRpcmVjdG9yeSBhY2Nlc3MgZm9yIGNvcHl0b29scz8NCg0KQXVyw6lsaWVuDQoNCl9f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmx1c3RyZS1kZXZl
bCBtYWlsaW5nIGxpc3QKbHVzdHJlLWRldmVsQGxpc3RzLmx1c3RyZS5vcmcKaHR0cDovL2xpc3Rz
Lmx1c3RyZS5vcmcvbGlzdGluZm8uY2dpL2x1c3RyZS1kZXZlbC1sdXN0cmUub3JnCg==
